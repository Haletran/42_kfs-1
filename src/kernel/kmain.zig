const v = @import("variables.zig");
const utils = @import("utils.zig");

const VGA_WIDTH = v.VGA_WIDTH;
const VGA_HEIGHT = v.VGA_HEIGHT;
const vga_color = v.vga_color;

fn init_term() void {
    v.terminal_color = utils.vga_entry_color(@intFromEnum(vga_color.VGA_COLOR_BLACK), @intFromEnum(vga_color.VGA_COLOR_WHITE));
    for (0..VGA_HEIGHT) |y| {
        for (0..VGA_WIDTH) |x| {
            const index: usize = y * VGA_WIDTH + x;
            v.buffer[index] = utils.vga_entry(' ', v.terminal_color);
        }
    }
}

fn welcome_screen() void {
    utils.put_string(" _   ___ _______ \n", @intFromEnum(vga_color.VGA_COLOR_WHITE));
    utils.put_string("| | |   |       |\n", @intFromEnum(vga_color.VGA_COLOR_WHITE));
    utils.put_string("| |_|   |____   |\n", @intFromEnum(vga_color.VGA_COLOR_WHITE));
    utils.put_string("|       |____|  |\n", @intFromEnum(vga_color.VGA_COLOR_WHITE));
    utils.put_string("|___    | ______|\n", @intFromEnum(vga_color.VGA_COLOR_WHITE));
    utils.put_string("    |   | |_____ \n", @intFromEnum(vga_color.VGA_COLOR_WHITE));
    utils.put_string("    |___|_______|\n", @intFromEnum(vga_color.VGA_COLOR_WHITE));
    utils.put_string("-> Bienvenue dans ce super kernel en zig :) <-\n", @intFromEnum(vga_color.VGA_COLOR_WHITE));
    utils.put_string("          by bapasqui and pirulenc", @intFromEnum(vga_color.VGA_COLOR_LIGHT_GREEN));
    utils.put_string("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n", @intFromEnum(vga_color.VGA_COLOR_GREEN));
    utils.put_string("PS: OSDev le goat\n", @intFromEnum(vga_color.VGA_COLOR_LIGHT_GREY));
}

export fn kernel_main() void {
    init_term();
    welcome_screen();
}
