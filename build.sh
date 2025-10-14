mkdir -p out
if [ -f "out/kfs.iso" ]; then
  rm out/kfs.iso
fi

./tools/bin/i686-elf-as src/boot.s -o out/boot.o
zig build
#./tools/bin/i686-elf-gcc -c src/c/kernel.c -o out/kernel.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra
./tools/bin/i686-elf-gcc -T src/linker.ld -o out/kfs.bin -ffreestanding -O2 -nostdlib out/boot.o out/kernel.o -lgcc
grub-file --is-x86-multiboot out/kfs.bin
cp out/kfs.bin iso/boot/kfs.bin
grub-mkrescue -o out/kfs.iso iso
qemu-system-i386 -cdrom out/kfs.iso
rm -rf out/*.o out/kfs.bin
rm -rf iso/boot/kfs.bin