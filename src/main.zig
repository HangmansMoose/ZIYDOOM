const std = @import("std");
const WADLoader = @import("wadloader.zig").WADLoader;

pub fn main() !void {
    const wad_filename = "DOOM.WAD";
    
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var loaded_wad = try WADLoader.init(wad_filename);
    try loaded_wad.Load();


}
