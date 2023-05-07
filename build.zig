//! This file is meant to serve as a template for people trying to write their
//! own TKey app in Zig

const std = @import("std");
const tkey = @import("tkey-libs/build.zig");

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(
        .{ .preferred_optimize_mode = .ReleaseSmall },
    );

    const app = b.addExecutable(.{
        .name = "app.elf",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = tkey.tillitis_target,
        .optimize = optimize,
    });
    tkey.linkArtifact(app);

    // Only necessary when intermediate elf file is needed, persumably for
    // debugging reasons
    b.installArtifact(app);

    // The main binary loaded with `tkey-runapp`
    const bin = tkey.getObjcopyBin(b, app, "app.bin");
    b.getInstallStep().dependOn(&bin.step);

    const run_cmd = tkey.addTkeyRunappCmd(b, bin);
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Requires `tkey-runapp` to be in `$PATH`");
    run_step.dependOn(&run_cmd.step);
}
