const std = @import("std");
const Datatypes = @import("datatypes.zig");
const Vertex = Datatypes.Vertex;
const Linedef = Datatypes.Linedef;

pub const Map = struct {
    m_name: []u8,
    m_vertexes: std.array_list.Managed(Vertex),
    m_linedefs: std.array_list.Managed(Linedef),

    pub fn init(allocator: std.mem.Allocator, name: []u8) *Map
    {
        return .{
            .m_name = name,
            .m_vertexes = std.array_list.Managed(Vertex).init(allocator),
            .m_linedefs = std.array_list.Managed(Linedef).init(allocator)
        };
    }

    pub fn GetName(self: *Map) []u8
    {
        return self.m_name;
    }

    pub fn AddVertex(self: *Map, v: *Vertex) !void
    {
        try self.m_vertexes.append(v);
    }

    pub fn AddLinedef(self: *Map, l: *Linedef) !void
    {
        try self.m_linedefs.append(l);
    }
};

