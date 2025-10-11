# KFS-1

## Requirements

- A kernel you can boot via GRUB
- An ASM bootable base
- A basic kernel library, with basics functions and types
- Some basic code to print some stuff on the screen
- A basic "Hello world" kernel

You should use those flags for compilation : 
- -fno-builtin
- -fno-exception
- -fno-stack-protector
- -fno-rtti
- -nostdlib
- -nodefaultlibs

The ***i386 (x86)*** architecture is mandatory

You must create a ***linker*** for your kernel. Be carefull, you CAN use the ’ld’ binary available on your host, but you CANNOT use the
.ld file of your host.

The makefile must compile all your source files with the right flags and the right compiler. Keep in mind that your kernel will use at least two different languages (ASM and
whatever-you-choose), so make (<- joke) your Makefile’s rules correctly. After compilation, all the objects must be linked together in order to create the final
Kernel binary.

## Start

-> [Starting point](https://osdev.wiki/wiki/Boot_Sequence)




## Ressources

[Osdev](https://wiki.osdev.org/Expanded_Main_Page)

[Littleosbook](littleosbook.github.io)

[Osdev wiki](https://osdev.wiki/wiki/Expanded_Main_Page)

