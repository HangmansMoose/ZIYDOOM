const std = @import("std");
const WADLoader = @import("wadloader.zig").WADLoader;
const Map = @import("map.zig").Map;

pub fn main() !u8 {
    const wad_filename = "DOOM.WAD";

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var wadloader: WADLoader = undefined;
    try wadloader.Load(&gpa, wad_filename);

    //const map = Map.init("E1M1");
    //try wadloader.LoadMapData(map);

    return 0;
}
