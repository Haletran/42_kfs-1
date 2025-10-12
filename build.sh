mkdir -p out
if [ -f "out/kfs.iso" ]; then
  rm out/kfs.iso
fi
if [ ! -d "tools" ]; then
    wget https://github.com/lordmilko/i686-elf-tools/releases/download/7.1.0/i686-elf-tools-linux.zip
    unzip i686-elf-tools-linux.zip -d tools
    rm i686-elf-tools-linux.zip
fi

./tools/bin/i686-elf-as src/c/boot.s -o out/boot.o
./tools/bin/i686-elf-gcc -c src/c/kernel.c -o out/kernel.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra
./tools/bin/i686-elf-gcc -T src/c/linker.ld -o out/kfs.bin -ffreestanding -O2 -nostdlib out/boot.o out/kernel.o -lgcc
grub-file --is-x86-multiboot out/kfs.bin
cp out/kfs.bin iso/boot/kfs.bin
grub-mkrescue -o out/kfs.iso iso
# qemu-system-i386 -cdrom out/kfs.iso doesn't work with iso file idk why
qemu-system-i386 -kernel out/kfs.bin
rm -rf out/*.o out/kfs.bin
rm -rf iso/boot/kfs.bin