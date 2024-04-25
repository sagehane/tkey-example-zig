//! This file is meant to serve as a template for people trying to write their
//! own TKey app in Zig

const std = @import("std");
const Step = std.Build.Step;
const Target = std.Target;
const riscv = Target.riscv;

comptime {
    const current = @import("builtin").zig_version;
    const minimum = std.SemanticVersion.parse("0.12.0") catch unreachable;

    if (current.order(minimum) == .lt) {
        @compileError(std.fmt.comptimePrint("Your Zig version v{} does not meet the minimum build requirement of v{}", .{ current, minimum }));
    }
}

/// https://dev.tillitis.se/hw/#cpu
/// https://github.com/tillitis/tillitis-key1/blob/TK1-23.03.2/hw/application_fpga/Makefile
const tillitis_target = Target.Query{
    .cpu_arch = .riscv32,
    .cpu_model = .{ .explicit = &riscv.cpu.generic_rv32 },
    .cpu_features_add = riscv.featureSet(&.{ .c, .zmmul }),
    .os_tag = .freestanding,
    // mabi seems to be set to `ilp32` but idk what the Zig/LLVM equivalent is
    //.abi = .gnuilp32,
};

pub fn linkArtifact(b: *std.Build, artfiact: *Step.Compile) void {
    // Requires a `build.zig.zon` entry
    const tkey_libs = b.dependency("tkey-libs", .{});

    artfiact.addAssemblyFile(tkey_libs.path("/libcrt0/crt0.S"));
    artfiact.setLinkerScript(tkey_libs.path("app.lds"));
}

/// Might become unnecessary with `std.Target.ObjectFormat.raw`.
/// https://github.com/ziglang/zig/blob/0.12.0/src/link.zig#L866
pub fn getObjcopyBin(b: *std.Build, cs: *Step.Compile, name: []const u8) *Step.InstallFile {
    const objcopy = cs.addObjCopy(.{ .basename = name });
    return b.addInstallBinFile(objcopy.getOutput(), name);
}

/// Requires `tkey-runapp` to be in `$PATH`
/// https://dev.tillitis.se/devapp/#running-a-tkey-device-application
pub fn addTkeyRunappCmd(b: *std.Build, bin: *Step.InstallFile) *Step.Run {
    const run_cmd = b.addSystemCommand(&.{"tkey-runapp"});
    run_cmd.addFileArg(bin.source);

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    return run_cmd;
}

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(
        .{ .preferred_optimize_mode = .ReleaseSmall },
    );

    const app = b.addExecutable(.{
        .name = "app.elf",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = b.resolveTargetQuery(tillitis_target),
        .optimize = optimize,
         // Setting this doesn't seem to affect the resulting binary?
         // https://releases.llvm.org/16.0.0/tools/clang/docs/ClangCommandLineReference.html#cmdoption-clang-mcmodel
        .code_model = .medium,
    });
    linkArtifact(b, app);

    // Only necessary when intermediate elf file is needed, persumably for
    // debugging reasons
    b.installArtifact(app);

    // The main binary loaded with `tkey-runapp`
    const bin = getObjcopyBin(b, app, "app.bin");
    b.getInstallStep().dependOn(&bin.step);

    const run_cmd = addTkeyRunappCmd(b, bin);
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Requires `tkey-runapp` to be in `$PATH`");
    run_step.dependOn(&run_cmd.step);
}
