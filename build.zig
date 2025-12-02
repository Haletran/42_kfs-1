const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .x86,
        .os_tag = .freestanding,
        .abi = .none,
    });

    const optimize = b.standardOptimizeOption(.{
        .preferred_optimize_mode = .ReleaseSmall,
    });

    const root_module = b.createModule(.{
        .root_source_file = b.path("src/zig/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const kernel = b.addObject(.{
        .name = "kernel",
        .root_module = root_module,
    });

    // Disable stack probing and provide compiler-rt builtins for freestanding target
    kernel.bundle_compiler_rt = true;

    const install_kernel = b.addInstallFile(
        kernel.getEmittedBin(),
        "kernel.o",
    );

    b.default_step.dependOn(&install_kernel.step);

    const clean_step = b.step("clean", "Remove build artifacts");
    const clean_cmd = b.addSystemCommand(&.{
        "rm",
        "-rf",
        "zig-out",
        "zig-cache",
        "out",
    });
    clean_step.dependOn(&clean_cmd.step);
}
