//const std = @import("std");
//const WADLoader = @import("wadloader.zig");
//const Datatypes = @import("datatypes.zig");
//const WADHeader = Datatypes.WADHeader;
//const WADDirectory = Datatypes.WADDirectory;
//// Using a struct in this way without any member variables
//// is the same as a namespace in C++
//pub const WADReader =  struct {
    //    My Original code. Using @memcpy means that you must know all values at comptime, which cant be done here 
    //    This includes the string concatenation
   
    

    //fn Read2Bytes(buffer: []u8, ptr_wad_data: *const []u8, offset: i32) void {
    //    @memcpy(buffer, ptr_wad_data.*[offset..(offset + 3)]);
    //}

    //fn Read4Bytes(buffer:  []u8, ptr_wad_data: *const []u8, offset: i32) void {
    //    @memcpy(buffer, ptr_wad_data.*[@intCast(offset)..@intCast(offset + 5)]);

    //}

   // pub fn ReadHeaderData(allocator: std.mem.Allocator, ptr_wad_data: *const []u8, offset: usize, header: *WADHeader) !*WADHeader
    //{
    //    //  parse wad
    //    // NOTE: relatively sure that the upper bounds of the slice is non-inclusive.
    //    // Copy wad_ident (4 bytes)
    //    NOTE: If this works I got the idea from https://ziggit.dev/t/mapping-64-u8-buffer-to-a-struct/6052
    //          This leverages packed structs

    //    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    //    const allocator = gpa.allocator();

    //    const ident_store: []u8 = try allocator.alloc(u8, 4);
    //    
    //    @memcpy(ident_store, ptr_wad_data.*[@intCast(offset)..@intCast(offset + 4)]);
    //    for (ident_store, 0..) |char, i| {
    //        header.*.wad_ident[i] = char;
    //    }
    //    


    //    const dir_count_buf: []u8 = try allocator.alloc(u8, 4);
    //    const dir_offset_buf: []u8 = try allocator.alloc(u8, 4);
    //    Read4Bytes(dir_count_buf, ptr_wad_data, @intCast(offset + 4));
    //    Read4Bytes(dir_offset_buf, ptr_wad_data, @intCast(offset + 8));
    //    header.*.directory_count = @bitCast(dir_count_buf[0..4]);
    //    header.*.directory_offset = @bitCast(dir_offset_buf[0..4]);
    //}
    //
   // pub fn ReadDirectoryData(ptr_wad_data: *const []u8, offset: i32, directory: *WADDirectory) !void 
    //{
    //   @memcpy(directory.*.lump_offset, ptr_wad_data[offset..(offset + 4)]);
    //   @memcpy(directory.*.lump_size, ptr_wad_data[(offset + 4)..(offset + 8)]);
    //   @memcpy(directory.*.lump_name, ptr_wad_data[(offset + 8)..(offset + 16)] ++ "\\0");

    //}

    //// Corrected code 
    //pub fn ReadHeaderData(wad_data: *const []u8, offset: i32, header: *WADHeader) !void {
    //    // Ensure the slice has enough data
    //    if (offset < 0 or offset + 12 > wad_data.*.len) {
    //        return error.InvalidOffset;
    //    }

    //    // Copy wad_ident (4 bytes)
    //    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    //    const allocator = gpa.allocator();

    //    const ident_store: []u8 = try allocator.alloc(u8, 4);
    //    
    //    @memcpy(ident_store, wad_data.*[@intCast(offset)..@intCast(offset + 4)]);
    //    for (ident_store, 0..) |char, i| {
    //        header.*.wad_ident[i] = char;
    //    }

    //    // Read directory_count (i32, 4 bytes)
    //    // First need to convert the slice to an i32, endianess is required here.
    //    
    //    const dir_count = readVarInt(i32, wad_data.*[@intCast(offset + 4)..@intCast(offset + 8)], std.builtin.Endian.little);
    //    header.directory_count = dir_count;

    //    // Read directory_offset (i32, 4 bytes)
    //    const dir_offset = readVarInt(i32, wad_data.*[@intCast(offset + 8)..@intCast(offset + 12)], std.builtin.Endian.little);
    //    header.directory_offset = dir_offset;
    //}

    //pub fn ReadDirectoryData(wad_data: *const []u8, offset: i32, directory: *WADDirectory) !void {
    //    // Ensure the slice has enough data
    //    if (offset < 0 or offset + 16 > wad_data.*.len) {
    //        return error.InvalidOffset;
    //    }

    //    // Read lump_offset (i32, 4 bytes)
    //    const converted_lump_offset = readVarInt(i32, wad_data.*[@intCast(offset)..@intCast(offset + 4)], 
    //                                          std.builtin.Endian.little);
    //    directory.lump_offset = converted_lump_offset;

    //    // Read lump_size (i32, 4 bytes)

    //    const converted_lump_size = readVarInt(i32, wad_data.*[@intCast(offset + 4)..@intCast(offset + 8)], 
    //                                        std.builtin.Endian.little);
    //    directory.lump_size = converted_lump_size;

    //    // Copy lump_name (8 bytes)
    //    @memcpy(&directory.lump_name, wad_data.*[@intCast(offset + 8)..@intCast(offset + 16)]);
    //}
//};

