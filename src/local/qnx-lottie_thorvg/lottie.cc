/*
 * Copyright (c) 2025, BlackBerry Limited. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

#include <cstdlib>
#include <cstring>
#include <sys/mman.h>
#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <thorvg.h>
#include <sys/neutrino.h>

static int              window_width = 1024;
static int              window_height = 800;
static uint64_t         tick_ns = 50000000;
static bool             full_screen = false;
static int              delay_animation = 0;

static uint32_t        *canvas_buffer;
static uint32_t        *frame_buffer;
static size_t           buffer_size;
static uint32_t         stride;

static tvg::SwCanvas   *canvas;
static tvg::Animation  *animation;
static tvg::Picture    *picture;
static int              picture_width;
static int              picture_height;

static int              verbose;
static uint64_t         ticks = 0;

extern "C" {
    extern uintptr_t get_paddr_frame_buffer(int, int, size_t *, uint32_t *);
    extern void free_frame_buffer(uintptr_t);
}

static bool
load_lottie(char const * const filename)
{
    // Create the animation and picture objects.
    animation = tvg::Animation::gen();
    picture = animation->picture();

    // Load lottie file.
    tvg::Result res = picture->load(filename);
    switch (res) {
    case tvg::Result::Success:
        if (verbose) {
            printf("Loaded %s\n", filename);
        }
        break;

    case tvg::Result::InvalidArguments:
        printf("Failed to load %s: invalid argument\n", filename);
        return EXIT_FAILURE;

    case tvg::Result::NonSupport:
        printf("Failed to load %s: not supported\n", filename);
        return EXIT_FAILURE;

    default:
        printf("Failed to load %s: unknown reason\n", filename);
        return EXIT_FAILURE;
    }

    float width;
    float height;

    picture->size(&width, &height);
    if (verbose > 0) {
        printf("Picture dimesions %.2fx%.2f\n", width, height);
    }

    picture_width = static_cast<int>(width);
    picture_height = static_cast<int>(height);
    window_width = picture_width;
    window_height = picture_height;

    return true;
}

static bool
create_canvas()
{
    // thorVG seems to expect the stride in pixels, not bytes.
    stride /= 4;
    if (verbose > 0) {
        printf("Stride %d\n", stride);
    }

    // Create a canvas and associate it with the window buffer.
    canvas = tvg::SwCanvas::gen();
    canvas->target(canvas_buffer, stride, window_width, window_height,
                   tvg::ColorSpace::ARGB8888);

    // Add the picture to the canvas.
    canvas->push(picture);

    return true;
}

static bool
event_loop()
{
    uint64_t const start = clock_gettime_mon_ns();
    uint64_t next = start;
    uint64_t last_ticks = 0;
    int frame = 0;

    for (;;) {
        // Update animation.
        animation->frame(frame);
        canvas->push(animation->picture());
        canvas->update();
        canvas->draw(true);
        canvas->sync();

        while (true) {
          // Sleep up to tne next frame time.
          uint64_t timeout = tick_ns - (clock_gettime_mon_ns() - next);
          TimerTimeout(CLOCK_MONOTONIC, _NTO_TIMEOUT_NANOSLEEP, NULL, &timeout, NULL);

          // Determine how many ticks have elapsed since the beginning.
          // This compensates for any delays in the timer.
          ticks = (clock_gettime_mon_ns() - start) / tick_ns;
          if (ticks != last_ticks) { break; }
        }

        // Copy drawn frame into frame_buffer
        memcpy(frame_buffer, canvas_buffer, buffer_size);

        frame += ticks - last_ticks;
        if (frame > animation->totalFrame()) {
            break;
        }

        next += (ticks - last_ticks) * tick_ns;
        last_ticks = ticks;
    }

    return true;
}

int
main(int argc, char **argv)
{
    for (;;) {
        int const opt = getopt(argc, argv, "d:fv");
        if (opt == 'd') {
            delay_animation = strtol(optarg, NULL, 0);
        } else if (opt == 'f') {
            full_screen = true;
        } else if (opt == 'v') {
            verbose++;
        } else {
            break;
        }
    }

    if (optind == argc) {
        printf("usage: rpi-lottie FILENAME\n");
        return EXIT_FAILURE;
    }

    char const * const filename = argv[optind];

    // Initialize ThorVG library.
    tvg::Initializer::init(0);

    // Load the lottie file.
    if (!load_lottie(filename)) {
        return EXIT_FAILURE;
    }

    // Get pointer from mbox for main window graphics
    uintptr_t const paddr = get_paddr_frame_buffer(window_width, window_height,
                                                    &buffer_size, &stride);
    if (paddr == 0) {
      perror("Failed to get mbox paddr");
      return EXIT_FAILURE;
    }

    // Create the main window with pointer.
    void * temp_buffer = mmap(0, buffer_size, PROT_READ | PROT_WRITE | PROT_NOCACHE,
          MAP_SHARED | MAP_PHYS, NOFD, paddr);

    if (temp_buffer == MAP_FAILED) {
      perror("mmap");
      free_frame_buffer(paddr);
      return EXIT_FAILURE;
    }
    frame_buffer = reinterpret_cast<uint32_t *>(temp_buffer);

    // Initialize the ThorVG canvas.
    try {
      canvas_buffer = new uint32_t[buffer_size];
    } catch (const std::bad_alloc&) {
      free_frame_buffer(paddr);
      perror("new[]");
      return EXIT_FAILURE;
    }

    if (!create_canvas()) {
      free_frame_buffer(paddr);
      return EXIT_FAILURE;
    }

    if (verbose > 0) {
      printf("Delay: %d\n", delay_animation);
    }
    sleep(delay_animation);

    // Run the event loop.
    bool event_ret = event_loop();

    // Free main window memory
    delete [] canvas_buffer;
    free_frame_buffer(paddr);

    if (event_ret) { return EXIT_SUCCESS; }
    else { return EXIT_FAILURE; }
}
