const std = @import("std");

pub fn build(b: *std.Build) void {
    const build_obj = b.addSystemCommand(&.{
        "zig",                     "build-obj",    "src/zig/main.zig",
        "-femit-bin=out/kernel.o", "-target",      "x86-freestanding-none",
        "-O",                      "ReleaseSmall",
    });

    b.default_step.dependOn(&build_obj.step);
}
