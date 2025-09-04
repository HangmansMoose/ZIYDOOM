# ZIYDOOM
Learning Zig by porting @amroibrahim's DIYDOOM (https://github.com/amroibrahim/DIYDoom). At this stage it is a solid maybe as to whether I keep some form of a dev diary in here. Hopefully I can finish this in the next week and a half, but I fear that I may be kidding myself..

Oh well, rip and tear...

## Day 1
https://github.com/amroibrahim/DIYDoom/blob/master/DIYDoom/Notes001/notes/README.md 
(yes I am aware that I am directly copying some of this, however writing this stuff down for myself helps me to parse it).
Today we start by implementing WAD file parsing. WADs contain lumps with all the game data in them, that includes audio, sprites, and level maps
WAD consists of a Header, 'Lump(s)' containing the game data, and directories for each of the lumps at the end of the WAD

### Header Format

| Field Size  | Data Type    |               Content                       |
|-------------|--------------|---------------------------------------------|
| 0x00 - 0x03 | 4 ASCII char | ASCII String (either 'IWAD' or 'PWAD')      | 
| 0x04 - 0x07 | uint         | Number of entries in the directory          |
| 0x08 - 0x0b | uint         | Offset in bytes to the directory in the WAD |


### Directories Format
 
| Field Size  | Data Type    |               Content                             |
|-------------|--------------|---------------------------------------------------|
| 0x00 - 0x03 | uint         | Offset to the start of then lump data in  the WAD | 
| 0x04 - 0x07 | uint         | The size of the lump in bytes                     |
| 0x08 - 0x0f | 8 ASCII char | ASCII name of the lump                            |


##### Changes
Noting that DIYDoom was written in C++ there are a number of implementations that need to be revisted (at least
until I know zig better). A couple of these of note is the use of streams, and the need to find the appropriate
use of allocators, ie what can be known at compiletime, what should just be general, and should I just use an
arena allocator, noting the small size...

(DELETE THIS WHEN YOU RETURN)
----- Taking a break, next steps are allocating memory for the WAD, and then reading it in and storing it in the heap


