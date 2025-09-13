const std = @import("std");
const Datatypes = @import("datatypes.zig");
const WADReader = @import("wadreader.zig").WADReader;
const Map = @import("map.zig");
const WADDirectory = Datatypes.WADDirectory;
const WADHeader = Datatypes.WADHeader;
const Vertex = Datatypes.Vertex;
const Linedef = Datatypes.Linedef;

// Here I went back to the DOOM source (https://github.com/id-software/DOOM)
// to get a better understanding of how it was done without C++ streams

pub const WADLoader = struct {
    // wad_path: std.fs.Dir, // Directory where WADs are stored
    wad_buffer: []u8,
    wad_allocator: std.mem.Allocator,
    wad_file: std.fs.File,
    wad_header: WADHeader,
    wad_reader: WADReader,
    wad_directories: std.array_list.Managed(WADDirectory),

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator, file_to_load: []const u8) !Self {
        _ = file_to_load;

        var loader = Self{
            .wad_buffer = undefined,
            .wad_allocator = allocator,
            .wad_file = try std.fs.cwd().openFile("assets/DOOM.WAD", .{}),
            .wad_header = undefined,
            .wad_reader = undefined,
            .wad_directories = undefined,
        };

        const file_stat = try loader.wad_file.stat();
        loader.wad_buffer = try allocator.alloc(u8, file_stat.size);

        // Instatiate the directories list

        return loader;
    }

    pub fn deinit(self: *Self) void {
        self.wad_allocator.free(self.wad_buffer);
    }

    pub fn OpenAndLoad(self: *Self) !void {
        const file_stat = try self.wad_file.stat();
        self.wad_buffer = try self.wad_file.readToEndAlloc(self.wad_allocator, file_stat.size);
        self.wad_header = self.wad_reader.ReadHeaderData(&self.wad_buffer, 0);
        self.wad_directories = std.array_list.Managed(WADDirectory).init(self.wad_allocator);
        try self.ReadDirectories();
    }

    fn ReadDirectories(self: *Self) !void {
        for (0..self.wad_header.directory_count) |i| {
            // TODO: not sure where the * 16 comes from. Need to go back through it
            const dir = self.wad_reader.ReadDirectoryData(&self.wad_buffer, self.wad_header.directory_offset + i * 16);
            try self.wad_directories.append(dir);
        }
    }
};
