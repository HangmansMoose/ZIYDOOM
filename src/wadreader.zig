const std = @import("std");
const WADLoader = @import("wadloader.zig");
//const Datatypes = @import("datatypes.zig");
//const WADHeader = Datatypes.WADHeader;
//const WADDirectory = Datatypes.WADDirectory;
//const Vertex = Datatypes.Vertex;
//const Linedef = Datatypes.Linedef;
//
//// Using a struct in this way without any member variables is the same as a namespace in C++
//pub const WADReader = struct {
//
//    // Read two bytes from offset and store in buffer.
//    pub fn ReadTwoBytes(_: *WADReader, wad_data: []const u8, offset: usize, buffer: *[]u8) !void {
//        buffer.* = wad_data[offset..(offset + 2)];
//    }
//
//    // Read four bytes from offset and store in buffer.
//    pub fn ReadFourBytes(_: *WADReader, wad_data: []const u8, offset: usize, buffer: *[]u8) !void {
//        buffer.* = wad_data[offset..(offset + 4)];
//    }
//
//    pub fn ReadHeaderData(_: *WADReader, wad_data: *std.array_list.AlignedManaged([]u8, null), offset: usize) !WADHeader {
//        //_ = offset;
//        var header_buffer: [@sizeOf(WADHeader)]u8 align(@alignOf(WADHeader)) = undefined;
//        // Reads until it fills the buffer. seek cursor should then sit at end of header?
//        // TODO: confirm this is correct
//        //_ = try wad_file.read(&header_buffer);
//
//        header_buffer = wad_data.*[offset..(@sizeOf(WADHeader))];
//
//        const header: *WADHeader = @ptrCast(&header_buffer);
//
//        return header.*;
//
//        //const wad_ident_str: []const u8 = @ptrCast(&header.wad_ident);
//        //std.debug.print("WAD type: {s}\n", .{wad_ident_str});
//        //std.debug.print("Dir count: {d}\n", .{header.directory_count});
//        //std.debug.print("First dir offset: {d}\n", .{header.directory_offset});
//    }
//
//    pub fn ReadDirectoryData(_: *WADReader, wad_file: std.fs.File, offset: usize) !WADDirectory {
//        const directory_buffer: [@sizeOf(WADDirectory)]u8 align(@alignOf(WADDirectory)) = undefined;
//
//        _ = try wad_file.seekTo(offset);
//        _ = try wad_file.read(&directory_buffer);
//
//        const directory: *WADDirectory = @ptrCast(&directory_buffer);
//
//        return directory.*;
//    }
//
//    pub fn ReadMapVertex(_: *WADReader, wad_data: []const u8, offset: usize, vertex: *Vertex) !void {
//        const vertex_buffer: [@sizeOf(Vertex)]u8 align(@alignOf(Vertex)) = wad_data[offset..(@sizeOf(Vertex))];
//        vertex = @ptrCast(&vertex_buffer);
//    }
//
//    pub fn ReadMapLinedef(_: *WADReader, wad_data: []const u8, offset: usize, linedef: *Linedef) !void {
//        const linedef_buffer: [@sizeOf(Linedef)]u8 align(@alignOf(Linedef)) = wad_data[offset..(@sizeOf(Linedef))];
//        linedef = @ptrCast(&linedef_buffer);
//    }
//};
//
