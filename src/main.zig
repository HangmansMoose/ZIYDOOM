const std = @import("std");
const WADLoader = @import("wadloader.zig").WADLoader;
const Map = @import("map.zig").Map;

pub fn main() !u8 {
    const wad_filename = "DOOM.WAD";

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    defer arena.deinit();
    const allocator = arena.allocator();
    var wadloader: WADLoader = try .init(allocator, wad_filename);
    try wadloader.OpenAndLoad();

    //const map = Map.init("E1M1");
    //try wadloader.LoadMapData(map);

    return 0;
}
