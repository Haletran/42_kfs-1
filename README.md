# KFS-1

## Requirements

- Install GRUB on an virtual image
- Write an ASM boot code that handles multiboot header, and use GRUB to init and
call main function of the kernel itself.
- Write basic kernel code of the choosen language.
- Compile it with correct flags, and link it to make it bootable.
- Once all of those steps above are done, you can write some helpers like kernel types
or basic functions (strlen, strcmp, ...)
- Your work must not exceed 10 MB.
- Code the interface between your kernel and the screen.
- Display "42" on the screen.

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

## Starting point

-> ***GRUB*** two-stage bootloader



## Ressources

[Osdev](https://wiki.osdev.org/Expanded_Main_Page)

[Littleosbook](littleosbook.github.io)

[Osdev wiki](https://osdev.wiki/wiki/Expanded_Main_Page)

