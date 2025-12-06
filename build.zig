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
        .root_source_file = b.path("src/kernel/kmain.zig"),
        .target = target,
        .optimize = optimize,
    });

    const kernel = b.addObject(.{
        .name = "kernel",
        .root_module = root_module,
    });

    kernel.bundle_compiler_rt = true;

    const install_kernel = b.addInstallFile(
        kernel.getEmittedBin(),
        "kernel.o",
    );

    const mkdir_zig_out = b.addSystemCommand(&.{ "mkdir", "-p", "zig-out" });

    const compile_asm = b.addSystemCommand(&.{
        "nasm",
        "-f",
        "elf32",
        "src/boot/boot.asm",
        "-o",
        "zig-out/boot.o",
    });
    compile_asm.step.dependOn(&mkdir_zig_out.step);

    const link_everything = b.addSystemCommand(&.{
        "i686-elf-gcc",
        "-T",
        "src/boot/linker.ld",
        "-o",
        "zig-out/kfs.bin",
        "-ffreestanding",
        "-O2",
        "-nostdlib",
        "zig-out/boot.o",
        "zig-out/kernel.o",
        "-lgcc",
    });
    link_everything.step.dependOn(&install_kernel.step);
    link_everything.step.dependOn(&compile_asm.step);

    const verify_multiboot = b.addSystemCommand(&.{
        "grub-file",
        "--is-x86-multiboot",
        "zig-out/kfs.bin",
    });
    verify_multiboot.step.dependOn(&link_everything.step);

    const mkdir_iso_boot = b.addSystemCommand(&.{ "mkdir", "-p", "iso/boot" });
    const copy_to_iso = b.addSystemCommand(&.{
        "cp",
        "zig-out/kfs.bin",
        "iso/boot/kfs.bin",
    });
    copy_to_iso.step.dependOn(&verify_multiboot.step);
    copy_to_iso.step.dependOn(&mkdir_iso_boot.step);

    const create_iso = b.addSystemCommand(&.{
        "grub-mkrescue",
        "-o",
        "zig-out/kfs.iso",
        "iso",
    });
    create_iso.step.dependOn(&copy_to_iso.step);

    b.default_step.dependOn(&create_iso.step);

    const run_step = b.step("run", "Run the application");
    const run_cmd = b.addSystemCommand(&.{
        "qemu-system-i386",
        "-cdrom",
        "zig-out/kfs.iso",
    });
    run_step.dependOn(&run_cmd.step);

    const clean_step = b.step("clean", "Remove build artifacts");
    const clean_cmd = b.addSystemCommand(&.{
        "rm",
        "-rf",
        "zig-out",
        ".zig-cache",
        "out",
        "iso/boot/kfs.bin",
    });
    clean_step.dependOn(&clean_cmd.step);
}
