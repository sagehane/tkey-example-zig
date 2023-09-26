//! A sample program that makes the TKey flash colours

// https://github.com/tillitis/tillitis-key1/blob/TK1-23.03.1/doc/system_description/system_description.md#memory-mapped-hardware-functions
// https://github.com/tillitis/tkey-libs/blob/673f6aff3c8f76da3afd8b258a08feb8a87b0cef/include/tk1_mem.h#L79
var mmio_tk1_led: *volatile u32 = @ptrFromInt(0xff000024);

/// The time slept depends on the optimisation mode too
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
