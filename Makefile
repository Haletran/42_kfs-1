all:
	@-zig build

run:
	@-zig build run

clean:
	@-zig build clean

re:
	make clean && make all

.PHONY: all run clean re
.SILENT: