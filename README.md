# ZIYDOOM
Learning Zig by porting @amroibrahim's DIYDOOM (https://github.com/amroibrahim/DIYDoom). At this stage it is a solid maybe as to whether I keep some form of a dev diary in here. Hopefully I can finish this in the next week and a half, but I fear that I may be kidding myself..

Oh well, rip and tear...

### TODO:
##### This is a list of things I would like to improve once things are working
 - Allocators: This is probably an exellent use case for an arena allocator
 - Errors/Error checking: want to try to ensure that it wont panic, everything should be caught (probably naive)
 - I can clean things up plenty in the wadloader, I am passing around the wad itself unecessarily when I can just
   return data from the function and then store it in the WADLoader.

## DAY 1 - WAD Loading
https://github.com/amroibrahim/DIYDoom/blob/master/DIYDoom/Notes001/notes/README.md 
(yes I am aware that I am directly copying some of this, however writing this stuff down for myself helps me to parse it).
Today we start by implementing WAD file parsing. WADs contain lumps with all the game data in them, that includes audio, sprites, and level maps
WAD consists of a Header, 'Lump(s)' containing the game data, and directories for each of the lumps at the end of the WAD

#### Header Format

| Field Size  | Data Type    |               Content                       |
|-------------|--------------|---------------------------------------------|
| 0x00 - 0x03 | 4 ASCII char | ASCII String (either 'IWAD' or 'PWAD')      | 
| 0x04 - 0x07 | uint         | Number of entries in the directory          |
| 0x08 - 0x0b | uint         | Offset in bytes to the directory in the WAD |


#### Directories Format
 
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

### Lessons
Zig is in a little bit of a state right now where there has been a significant change in the way I/O is handled.
These changes where introduced in version 0.15.1, and as of now (Sep 2025), most documentation and tutorials
use the previous iterations of Zig. I am not yet confident enough to make tutorials myself, but perhaps one day. 

 -  After spending days tilting at windmills trying to figure out how to read in the WAD files maintaining the correct
    offsets and trying to understand the reader/writer paradigm in Zig, I stumbled across a question on ziggit talking
    about the use of packed structs and then just reading the file directly into the packed struct, removing the need
    to directly handle the offsets and data types while reading. This also relied on the use of `align` and @alignOf


## DAY 2 - Basic Map Data 

Noting that reading in the lumps can be much more complex than reading the WADS, to start we are going to implement the 
Automap feature, which is a top-down view of a map.

##### Map Anatomy
Each mission is comprised of a set of lumps. These lumps are always in the same sequence in the original DOOM WAD
 1.  VERTEXES
 2.  LINEDEFS
 3.  SIDEDEFS
 4.  SECTORS
 5.  SSECTORS
 6.  SEGS
 7.  NODES
 8.  THINGS
 9.  REJECT
 10. BLOCKMAP


 - **VERTEXES** are the endpoints of a wall in 2D. Two connected VERTEXES form one LINEDEF
 - **LINEDEFS** are the lines connecting vertexes, forming walls. Not all walls behave the same, this is defined by a flag
 - **SIDEDEFS** hold the texture information for a wall
 - **SECTORS**  are the rooms created by connecting LINEDEFS together. Each has information such as floor and ceiling height,
                textures, light values, special actions such as moving platforms, etc.
 - **SSECTORS** (SubSECTORS) these form convex areas within a SECTOR whcih are sued to aid in rendering and aids in determining
                where the player is within a level (including verticality).
 - **SEGS**     these are fractions of walls/LINEDEFS (or SEGmentS). The world is drawn by traversing a BSP tree to determine
                which walls to draw first (closest to farthest). These SEGS are then used ot render walls rather than the LINEDEF
 - **NODES**    BSP nodes used to store subsector data. Used to determine which sector the player is in and Elimate SEGS that
                aren't in the players view.
 - **THINGS**   the missions decorations and actors. Each entry provides the information such as type, spawn point, facing direction
                etc.
 - **REJECT**   This lump contains information about which sectors are visible from other sectors, which can be used to determine
                when an enemy can become aware of the players presence. It is also used to determine how far noises created by 
                the player will travel. This lump can also be used to aid in collision detection of projectile weapons.
 - **BLOCKMAP** Collision detection information for player and THING movement. It is a grid encompassing the entire mission geometry
                Each cell within the grid contains a list of LINEDEFS that either completely exist within or cross through it. 
                This is used to speed up collision detection since the tests will only need to be against a small subset of player/THING.


#### Vertex Format

| Field Size  | Data Type    |               Content                       |
|-------------|--------------|---------------------------------------------|
| 0x00 - 0x01 | signed short | X position                                  | 
| 0x02 - 0x03 | signed shor  | Y position                                  | 


#### Linedef Format
 
| Field Size  | Data Type      |               Content                              |
|-------------|----------------|----------------------------------------------------|
| 0x00 - 0x01 | unsigned short | Start vertex                                       | 
| 0x02 - 0x03 | unsigned short | End vertex                                         |
| 0x04 - 0x05 | unsigned short | Flags                                              |
| 0x06 - 0x07 | unsigned short | Line type / Action                                 |
| 0x08 - 0x09 | unsigned short | Sector tag                                         |
| 0x0a - 0x0b | unsigned short | Right sidedef (0xFFFF side not present)            |
| 0x0c - 0x0d | unsigned short | Left sidedef (0xFFFF side not present)             |


#### Linedef Flags
 
| Bit |    Function                              |
|-----|------------------------------------------|
|  0  | Blocks players and monsters              | 
|  1  | Blocks monsters                          |
|  2  | Two sided                                | 
|  3  | Upper Texture is unpegged                |
|  4  | Lower texture is unpegged                |
|  5  | Secret (appears as one-sided on automap) |
|  6  | Blocks sound                             |
|  7  | Never shows on automap                   |
|  8  | Always shows on automap                  |

#### Day 2 Goals
 1. Create a map class
 2. Read vertext data
 3. Read linedef data 


#### NOTES (DELETE)
so I think I do need to abstract out the reading functions into another namespace (struct without fields is just a namespace),
otherwise I have to try to drag the wadloader everwhere and that feels bad. 

