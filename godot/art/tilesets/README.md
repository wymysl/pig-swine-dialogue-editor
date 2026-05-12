# TileSets Documentation

This directory contains Godot `TileSet` resources (`.tres`) for the various rooms and environments in the Pig & Swine RPG.

## Office TileSet (`office_tileset.tres`)

**Used by:** `pig_swine_office.tscn`

**Source Image Mappings:**
- **Floor Terrain (Terrain 0):** Mapped to `art/tiles/office_marble_tiles.png`. Contains the base cream marble tiles and any prepared variants, sliced into a 64x64 grid. These tiles have no collision.
- **Wall Terrain (Terrain 1):** Mapped to `art/tiles/office_wall.png`. Contains the warm honey wood paneling walls. Configured with a 64x64 rectangular collision shape on each tile to serve as physical boundaries.

*Note: If wall corner pieces and edge variants are added to the wall tilesheet later, this TileSet should be updated to configure the auto-tile terrain set peering bits accordingly.*
