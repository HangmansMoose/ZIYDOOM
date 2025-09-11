// File to store various data types used across multiple struct and functions
// not necessarily belonging to one

// This enum is from DIYDOOM to avoid the use of magic numbers
pub const EMAPLUMPSINDEX = enum(u32) {
    eTHINGS = 1,
    eLINEDEFS,
    eSIDEDDEFS,
    eVERTEXES,
    eSEAGS,
    eSSECTORS,
    eNODES,
    eSECTORS,
    eREJECT,
    eBLOCKMAP,
    eCOUNT
};

pub const ELINEDEFFLAGS = enum(u32)
{
    eBLOCKING = 0,
    eBLOCKMONSTERS = 1,
    eTWOSIDED = 2,
    eDONTPEGTOP = 4,
    eDONTPEGBOTTOM = 8,
    eSECRET = 16,
    eSOUNDBLOCK = 32,
    eDONTDRAW = 64,
    eDRAW = 128
};

pub const WADHeader = packed struct 
{
    wad_type: u32, // Extra char for sentinel
    directory_count: u32,
    directory_offset: u32, // Offset to the first directory
};

pub const WADDirectory = packed struct 
{
    lump_offset: u32,
    lump_size: u32,
    lump_name: u64 // Need an extra char for the sentinel
};

pub const Vertex = packed struct 
{
    x_pos: i16,
    y_pos: i16,
};

pub const Linedef = packed struct
{
    start_vertex: u16,
    end_vertex: u16,
    flags: u16,
    line_type: u16,
    sector_tag: u16,
    right_sidedef: u16, // 0xFF means there is no sidedef
    left_sidedef: u16, // 0xFF means there is no sidedef

};
