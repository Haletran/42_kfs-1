import os

frames_dir = "src/zig/frames"
output_file = "src/zig/frames_data.zig"

frame_files = sorted([f for f in os.listdir(frames_dir) if f.endswith('.txt')])

with open(output_file, 'w') as f:
    f.write("// Auto-generated file - do not edit manually\n\n")
    
    for i, frame_file in enumerate(frame_files):
        f.write(f'const frame{i:05d} = @embedFile("frames/{frame_file}");\n')
    
    f.write("\n")
    
    # Générer le tableau de frames
    f.write("pub const all_frames = [_][]const u8{\n")
    for i in range(len(frame_files)):
        f.write(f"    frame{i:05d},\n")
    f.write("};\n")

print(f"Generated {len(frame_files)} frame imports")
