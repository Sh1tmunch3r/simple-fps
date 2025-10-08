# Block Pickup and Placement System

## Overview
This system allows players to pick up blocks from the world and place them in a LEGO-style grid system.

## Features

### Block Pickup
- Walk over a block (Area3D with pickup script) to automatically collect it
- Blocks are added to your inventory counter
- Pickup blocks are removed from the world after collection

### Tool Switching
- **Press 1** to switch to the gun (default tool)
- **Press 2** to switch to the block placer
- When switching tools, the gun model is shown/hidden appropriately

### Block Placement
- With the block placer equipped (press 2), click to place blocks
- Blocks are placed using a raycast from the camera
- Maximum placement distance: 5 units
- Blocks snap to a grid based on their size (0.64 x 0.092 x 0.155)

### LEGO-Style Stacking
- **Vertical Stacking**: When placing on top of a surface (floor or another block), blocks automatically stack with proper grid alignment
- **Grid Snapping**: Blocks snap to a grid on all axes for clean, organized placement
- **Overlap Prevention**: The system checks for existing blocks before placement to prevent overlap
- **Multi-block Placement**: Place multiple blocks rapidly to build structures

## How It Works

### Scripts
1. **block.gd** - Attached to pickup blocks (Area3D)
   - Detects when player enters the area
   - Calls player's pickup_block() method
   - Removes itself from scene after pickup

2. **player.gd** - Enhanced with:
   - `block_count` - Tracks inventory
   - `current_tool` - Tracks active tool ("gun" or "block_placer")
   - `switch_tool()` - Switches between tools
   - `pickup_block()` - Increments block inventory
   - `place_block()` - Places blocks using raycast
   - `snap_to_grid()` - Aligns blocks to grid
   - `is_position_occupied()` - Checks for block overlap

### Scenes
1. **block.tscn** - Pickup block (Area3D)
   - Has collision shape for pickup detection
   - Includes block model
   - Runs block.gd script

2. **PlacedBlock.tscn** - Placed block (StaticBody3D)
   - Static collision for placed blocks
   - Same model as pickup block
   - Cannot be picked up after placement

3. **World.tscn** - Updated with 5 pickup blocks at various locations

## Controls
- **WASD** - Move
- **Space** - Jump
- **Mouse** - Look around
- **Left Click** - Shoot (gun) or Place Block (block placer)
- **1** - Switch to gun
- **2** - Switch to block placer
- **ESC** - Release mouse

## Usage Example
1. Start the game and spawn into the world
2. Walk over one of the 5 blocks scattered around the map
3. Press **2** to switch to block placer
4. Aim at the floor or another block
5. Click to place a block - it will snap to the grid
6. Continue placing blocks to build structures
7. Press **1** to switch back to the gun

## Technical Details

### Block Size and Grid
- Block dimensions: 0.64 x 0.092 x 0.155 (width x height x depth)
- Grid snapping rounds positions to nearest block-size multiple
- Vertical stacking adds half block height offset for proper alignment

### Collision Detection
- Pickup blocks use Area3D with collision layer/mask 3
- Placed blocks use StaticBody3D with collision layer/mask 3
- Overlap detection uses PhysicsShapeQueryParameters3D

### Placement Algorithm
1. Raycast from camera to find hit point
2. Get hit normal to determine surface orientation
3. Snap position to grid based on normal direction
4. Check for overlapping blocks at target position
5. If clear, instantiate PlacedBlock.tscn at target position
6. Decrement block inventory

## Multiplayer Notes
- Block pickup and placement are authority-checked
- Only the local player can pick up and place blocks
- Placed blocks are visible to all players (added to current_scene)
- Block count is stored locally per player

## Future Enhancements
- Block removal/destruction
- Different block types or colors
- Block rotation before placement
- Save/load placed block positions
- Limit on total placeable blocks
- UI indicator showing block count
