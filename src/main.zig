// SPDX-FileCopyrightText: 2024 Sage Hane <sage@sagehane.com>
//
// SPDX-License-Identifier: CC0-1.0

//! A sample program that makes the TKey flash colours

// https://dev.tillitis.se/memory/
var mmio_tk1_led: *volatile u32 = @ptrFromInt(0xff000024);

/// The time slept seems to depend on factors such as the optimisation mode and
/// binary size
fn sleep(n: u32) void {
    for (n) |_| {
        asm volatile ("nop");
    }
}

export fn main() noreturn {
    const sleep_time = 1_000_000;

    while (true) {
        mmio_tk1_led.* = @as(u3, @truncate(mmio_tk1_led.* + 1));
        sleep(sleep_time);
    }
}
