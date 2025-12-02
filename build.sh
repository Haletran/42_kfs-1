#!/usr/bin/env bash

build_process() {
  zig build || return 1

  ## everything here should be replaced by a rule in the zig build system
  ./tools/bin/i686-elf-as src/boot.s -o out/boot.o || return 1
  mv zig-out/kernel.o out/kernel.o && rm -rf zig-out
  ./tools/bin/i686-elf-gcc -T src/linker.ld -o out/kfs.bin -ffreestanding -O2 -nostdlib out/boot.o out/kernel.o -lgcc || return 1
  grub-file --is-x86-multiboot out/kfs.bin || return 1
  grub-file --is-x86-multiboot out/kfs.bin || return 1
  cp out/kfs.bin iso/boot/kfs.bin || return 1
  grub-mkrescue -o out/kfs.iso iso || return 1
  return 0
}

clean_process() {
  zig build clean
}

mkdir -p out
if [ -f "out/kfs.iso" ]; then
  rm out/kfs.iso
fi
main_process() {
  build_process || { echo "Build failed"; exit 1; }
  qemu-system-i386 -cdrom out/kfs.iso
  clean_process
}

main_process