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
    wad_data: std.array_list.AlignedManaged([]u8, null) = undefined,
    wad_filename: []const u8,
    wad_file_ptr: std.fs.File = undefined,
    wad_allocator: std.heap.GeneralPurposeAllocator(.{}) = std.heap.GeneralPurposeAllocator(.{}){},
    wad_header: *WADHeader = undefined,
    wad_directories: std.array_list.Managed(WADDirectory) = undefined,
    wad_reader: WADReader = WADReader{},

    pub fn Load(self: *WADLoader, wad_filename: []const u8) !void {
        self.wad_filename = wad_filename;
        const allocator = self.wad_allocator.allocator();
        const cwd = std.fs.cwd();
        const wad_rel_path = "assets/DOOM.WAD";
        self.wad_file_ptr = try cwd.openFile(wad_rel_path, .{});
        defer self.wad_file_ptr.close();

        const file_stat = try self.wad_file_ptr.stat();
        const buffer = try allocator.alloc(u8, file_stat.size);

        //var wad_reader: WADReader = undefined;
        var file_reader: std.fs.File.Reader = undefined;
        file_reader = self.wad_file_ptr.reader(buffer);

        // _ = try self.wad_file_ptr.readAll(buffer);

        // NOTE: New Idea. Reading the whole WAD into an array_list. I am hoping this removes
        // any need for knowing offsets at comptime.
        self.wad_data = std.array_list.AlignedManaged([]u8, null).init(allocator);
        while (!file_reader.atEnd()) {
            const byte: []u8 = undefined;
            _ = try file_reader.read(byte);
            _ = try self.wad_data.append(byte);
        }

        self.wad_directories = std.array_list.Managed(WADDirectory).init(allocator);
        defer self.wad_directories.deinit();

        // TODO: Look at errors and their implementation
        try self.ReadDirectories();
    }

    pub fn ReadDirectories(self: *WADLoader) !void {
        // Read in header
        // NOTE: I dont need to store the header once the dirs are loaded I dont think I need to
        // care about the header anymore
        var header_buffer: [@sizeOf(WADHeader)]u8 align(@alignOf(WADHeader)) = undefined;
        header_buffer = self.wad_reader.ReadHeaderData(&self.wad_data, 0);
        _ = try self.wad_file.read(&header_buffer);

        const header: *WADHeader = @ptrCast(&header_buffer);

        const wad_ident_str: []const u8 = @ptrCast(&header.wad_ident);
        std.debug.print("WAD type: {s}\n", .{wad_ident_str});
        std.debug.print("Dir count: {d}\n", .{header.directory_count});
        std.debug.print("First dir offset: {d}\n", .{header.directory_offset});

        for (0..header.directory_count) |i| {
            // TODO: not sure where the * 16 comes from. Need to go back through it
            try self.ReadInDirectory(header.directory_offset + i * 16);
        }
    }

    // TODO: in time this will be changed to use a map structure like unordered_map in C++
    //       so the key can simply be the map name
    pub fn FindMapIndex(self: WADLoader, map: *Map) !i32 {
        for (0..self.wad_directories.items.len) |index| {
            if (std.mem.eql(self.wad_directories[index].lump_name, map.GetName())) {
                return index;
            }
        }
        return -1;
    }

    // TODO: This can be redone in a zig way, the iterations could be much cleaner
    pub fn ReadMapVertex(self: WADLoader, map: *Map) !bool {
        var map_index = self.FindMapIndex(map);

        if (map_index == -1) return false;

        map_index += Datatypes.EMAPLUMPSINDEX.eVERTICES;

        if (!std.mem.eql(self.wad_directories[map_index].lump_name, "VERTEXES")) {
            return false;
        }

        const vertex_size_in_bytes = @sizeOf(Vertex);
        const total_vertex_count = self.wad_directories[map_index].lump_size / vertex_size_in_bytes;

        var vertex: Vertex = undefined;

        for (0..total_vertex_count) |i| {
            self.wad_reader.ReadMapVertex(self.wad_data, self.wad_directories[map_index].lump_offset + i * vertex_size_in_bytes, &vertex);

            map.AddVertex(vertex);

            std.debug.print("Vertex x: {d}\n", .{vertex.x_pos});
            std.debug.print("Vertex y: {d}\n", .{vertex.y_pos});
        }

        return true;
    }

    pub fn ReadMapLinedef(self: WADLoader, map: *Map) !bool {
        var map_index = self.FindMapIndex(map);

        if (map_index == -1) return false;

        map_index += Datatypes.EMAPLUMPSINDEX.eLINEDEFS;

        if (!std.mem.eql(self.wad_directories[map_index].lump_name, "LINEDEFS")) {
            return false;
        }

        const linedef_size_in_bytes = @sizeOf(Linedef);
        const total_linedef_count = self.wad_directories[map_index].lump_size / linedef_size_in_bytes;

        var linedef: Linedef = undefined;

        for (0..total_linedef_count) |i| {
            self.wad_reader.ReadMapLinedef(self.wad_data, self.wad_directories[map_index].lump_offset + i * linedef_size_in_bytes, &linedef);

            map.AddLinedef(linedef);

            std.debug.print("start_vertex:  {d}\n", .{linedef.start_vertex});
            std.debug.print("end_vertex:    {d}\n", .{linedef.end_vertex});
            std.debug.print("flags:         {d}\n", .{linedef.flags});
            std.debug.print("line_type:     {d}\n", .{linedef.line_type});
            std.debug.print("sector_tag:    {d}\n", .{linedef.sector_tag});
            std.debug.print("right_sidedef: {d}\n", .{linedef.right_sidedef});
            std.debug.print("left_sidedef:  {d}\n", .{linedef.left_sidedef});
        }

        return true;
    }

    pub fn LoadMapData(map: *Map) !bool {
        if (!ReadMapVertex(map)) {
            std.debug.print("Error: Failed to load map {s}\n", .{map.GetName()});
            return false;
        }

        if (!ReadMapLinedef(map)) {
            std.debug.print("Error: Failed to load map {s}\n", .{map.GetName()});
            return false;
        }
    }

    //                  NOTE: LEAVING THIS HERE TO REMEBER WHAT I TRIED AND DIDNT WORK

    // Need to remember to pass as a reference if I want to alter the struct, otherwise it is const and cant be altered
    //fn OpenAndLoadWAD(self: *WADLoader) !void
    //{
    //    //read in header
    //    const allocator = self.wad_allocator.allocator();
    //    var file_reader = self.wad_file.reader(self.wad_data);
    //    const reader: *std.Io.Reader = &file_reader.interface;
    //    const bytes_read = try reader.readAlloc(allocator, try self.wad_file.getEndPos());

    //    _ = bytes_read;
    //

    //}

    //fn ReadDirectories(self: *WADLoader) !void
    //{
    //

    //    var header: WADHeader = undefined;
    //    // Add sentinal terminator
    //    // NOTE: Will need to do this for the directory as well

    //    try WADReader.ReadHeaderData(&self.wad_data, 0, &header);

    //    // Terrible, but print is anus at the moment apparently, particularly on windows
    //    //var print_buf: [1024]u8 = undefined;
    //    //var output_writer: std.fs.File.Writer = std.fs.File.stdout().writer(&print_buf);
    //    //const writer = &output_writer.interface;

    //}
};
