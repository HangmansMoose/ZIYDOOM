const std = @import("std");
const Datatypes = @import("datatypes.zig");
//const WADReader = @import("wadreader.zig").WADReader;
const Map = @import("map.zig");
const WADDirectory = Datatypes.WADDirectory;
const WADHeader = Datatypes.WADHeader;
const Vertex = Datatypes.Vertex;
const Linedef = Datatypes.Linedef;

// Here I went back to the DOOM source (https://github.com/id-software/DOOM)
// to get a better understanding of how it was done without C++ streams

pub const WADLoader = struct {
    // wad_path: std.fs.Dir, // Directory where WADs are stored
    wad_data: std.array_list.Managed([]u8) = undefined,
    wad_file: std.fs.File = undefined,
    wad_allocator: std.mem.Allocator,
    wad_header: *WADHeader = undefined,
    wad_directories: std.array_list.Managed(WADDirectory) = undefined,

    pub fn Load(self: *WADLoader, gpa: *std.heap.GeneralPurposeAllocator(.{}), wad_filename: []const u8) !void {
        // TODO: this will be a thing once I get everything else working
        _ = wad_filename;
        self.wad_allocator = gpa.allocator();

        // const cwd = std.fs.cwd();
        // const path_str = try cwd.realpathAlloc(self.wad_allocator, ".");
        // std.debug.print("cwd: {s}\n", .{path_str});

        const wad_rel_path = "assets/DOOM.WAD";
        self.wad_file = try std.fs.cwd().openFile(wad_rel_path, .{});
        defer self.wad_file.close();

        //self.wad_data = try self.wad_allocator.alloc(u8, try self.wad_file.getEndPos());
        //self.wad_directories = std.array_list.Managed(WADDirectory).init(self.wad_allocator);

        // TODO: Look at errors and their implementation
        try self.ReadInDirectories();
        // try self.OpenAndLoadWAD();

        // try self.ReadDirectories();
    }

    fn ReadInDirectories(self: *WADLoader) !void {
        // Read in header
        // NOTE: I dont need to store the header once the dirs are loaded I dont think I need to
        // care about the header anymore
        // const buffer = try self.wad_allocator.alloc(u8, try self.wad_file.getEndPos());

        var reader: std.Io.Reader = undefined;
        const file_stat = try self.wad_file.stat();
        const file_size = file_stat.size;

        reader = std.Io.Reader.fixed(try self.wad_file.readToEndAlloc(self.wad_allocator, file_size));

        var header = try self.wad_allocator.alloc(WADHeader, 1);
        header = try reader.takeStruct(WADHeader, .little);
        self.wad_header = &header;
        //var header_buffer: [@sizeOf(WADHeader)]u8 align(@alignOf(WADHeader)) = undefined;
        //_ = try self.wad_file.read(&header_buffer);

        //self.wad_header = @ptrCast(&header_buffer);

        const wad_ident_str: []const u8 = @ptrCast(&self.wad_header.wad_type);
        std.debug.print("WAD type: {s}\n", .{wad_ident_str});
        std.debug.print("Dir count: {d}\n", .{self.wad_header.directory_count});
        std.debug.print("First dir offset: {d}\n", .{self.wad_header.directory_offset});

        for (0..self.wad_header.directory_count) |i| {
            // TODO: not sure where the * 16 comes from. Need to go back through it
            try self.ReadInDirectory(self.wad_header.directory_offset + i * 16);
        }
    }

    fn ReadInDirectory(self: *WADLoader, offset: usize) !void {
        // const offset: u64 = self.wad_header.directory_offset;
        var buffer: [@sizeOf(WADDirectory)]u8 align(@alignOf(WADDirectory)) = undefined;
        _ = try self.wad_file.seekTo(offset);
        _ = try self.wad_file.read(&buffer);

        const directory: *WADDirectory = @ptrCast(&buffer);
        try self.wad_directories.append(directory.*);

        const dir_name_str: [:0]const u8 = @ptrCast(&directory.lump_name);
        std.debug.print("Lump name: {s}\n", .{dir_name_str});
        std.debug.print("Lump size: {d}\n", .{directory.lump_size});
        std.debug.print("Lump offset: {d}\n", .{directory.lump_offset});
    }
};
