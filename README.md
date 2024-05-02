<!--
SPDX-FileCopyrightText: 2024 Sage Hane <sage@sagehane.com>

SPDX-License-Identifier: CC0-1.0
-->

## Minimal Zig example for the TKey
Note: The README assumes the user is on Linux as other platforms were never tested

The TKey is an open source and hackable security key device. More info is
available at https://www.tillitis.se/.

The `build.zig` is also meant to serve as a template for people interested in
targetting for the TKey.

### Prerequisites
1. Get a TKey or use their [custom QEMU fork](https://dev.tillitis.se/tools/#qemu-emulator)
2. Get a recent copy of the Zig binary (ideally from https://ziglang.org/download/)
3. Make sure `tkey-runapp` from https://github.com/tillitis/tkey-devtools is in `$PATH`
4. [Have access to the serial port or add a system rule for the TKey](https://dev.tillitis.se/devapp/#linux-users) (For running the app with the physical key)

### Running
```sh-session
$ git clone https://github.com/sagehane/tkey-example-zig.git
$ cd tkey-example-zig
$ git submodule update --init
$ zig build # To build the app
$ zig build run # To run the sample app (TKey must be plugged in and detected)
$ zig build run -- --port <desired port> # To specify a port (needed for QEMU support)
```
