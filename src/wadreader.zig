const std = @import("std");
const WADLoader = @import("wadloader.zig");
const Datatypes = @import("datatypes.zig");
const WADHeader = Datatypes.WADHeader;
const WADDirectory = Datatypes.WADDirectory;
const Vertex = Datatypes.Vertex;
const Linedef = Datatypes.Linedef;

// Using a struct in this way without any member variables is the same as a namespace in C++
pub const WADReader = struct {

    //// Read two bytes from offset and store in buffer.
    //pub fn ReadTwoBytes(_: *WADReader, wad_file_reader: std.fs.File.Reader, offset: usize, buffer: *[]u8) !*[]u8
    //{
    //
    //    buffer.* = wad_data[offset..(offset + 2)];
    //}

    //// Read four bytes from offset and store in buffer.
    //pub fn ReadFourBytes(_: *WADReader, wad_data: []const u8, offset: usize, buffer: *[]u8) !void {
    //    buffer.* = wad_data[offset..(offset + 4)];
    //}

    pub fn ReadHeaderData(_: *WADReader, wad_buffer: *[]u8, offset: usize) WADHeader {
        const header_buffer = wad_buffer.*[offset..][0..@sizeOf(WADHeader)];

        var header: *WADHeader = undefined;
        header = @ptrCast(@alignCast(header_buffer));
        const wad_ident_str: []const u8 = @ptrCast(&header.wad_type);
        std.debug.print("WAD type: {s}\n", .{wad_ident_str});
        std.debug.print("Dir count: {d}\n", .{header.directory_count});
        std.debug.print("First dir offset: {d}\n", .{header.directory_offset});

        return header.*;
    }

    pub fn ReadDirectoryData(_: *WADReader, wad_buffer: *[]u8, offset: usize) WADDirectory {
        var dir_ptr: *[@sizeOf(WADDirectory)]u8 align(@alignOf(WADDirectory)) = undefined;
        dir_ptr = wad_buffer.*[offset..][0..@sizeOf(WADDirectory)];
        var dir_deref = dir_ptr.*;
        var directory: *WADDirectory = undefined;
        directory = @ptrCast(@alignCast(&dir_deref));
        const dir_name_str: [:0]const u8 = @ptrCast(&directory.lump_name);
        std.debug.print("Lump name: {s}\n", .{dir_name_str});
        std.debug.print("Lump size: {d}\n", .{directory.lump_size});
        std.debug.print("Lump offset: {d}\n", .{directory.lump_offset});

        return directory.*;
    }

    pub fn ReadMapVertex(_: *WADReader, wad_data: *[]const u8, offset: usize) !Vertex {
        const vertex_buffer: *[@sizeOf(Vertex)]u8 align(@alignOf(Vertex)) = wad_data.*[offset..][0..@sizeOf(Vertex)];
        const vertex: *Vertex = @ptrCast(&vertex_buffer);

        return vertex.*;
    }

    pub fn ReadMapLinedef(_: *WADReader, wad_data: *[]const u8, offset: usize) !Linedef {
        const linedef_buffer: *[@sizeOf(Linedef)]u8 align(@alignOf(Linedef)) = wad_data.*[offset..][0..@sizeOf(Linedef)];
        const linedef: *Linedef = @ptrCast(&linedef_buffer);

        return linedef.*;
    }
};
