# Block Pickup and Placement System (v2.0)

## Overview
This comprehensive building system allows players to pick up blocks/items from the world, place them in a LEGO-style grid system, rotate and remove blocks, and loot boxes for resources. Features include an inventory UI, multiple item types, and interactive world objects.

## Features

### Inventory System
- **Multi-item inventory**: Tracks blocks, red blocks, blue blocks, and items separately
- **Real-time UI display**: Shows current inventory counts in the top-left corner
- **Visual feedback**: Inventory updates immediately when picking up or placing items

### Block Pickup
- Walk over a block (Area3D with pickup script) to automatically collect it
- Blocks are added to your inventory by type
- Pickup blocks are removed from the world after collection
- Random spawn points throughout the world (10 blocks by default)

### Tool Switching
- **Press 1** to switch to the gun (default tool)
- **Press 2** to switch to the block placer
- When switching tools, the gun model is shown/hidden appropriately
- Current tool displayed in the inventory UI

### Block Placement
- With the block placer equipped (press 2), click to place blocks
- Blocks are placed using a raycast from the camera (Godot 4.x compatible)
- Maximum placement distance: 5 units
- Blocks snap to a grid based on their size (0.64 x 0.092 x 0.155)

### Block Rotation
- **Press R** to rotate blocks in 90-degree increments before placing
- Rotation angle displayed in the inventory UI
- Blocks maintain rotation after placement

### Block Removal
- **Press E** while looking at a placed block to remove it
- Removed blocks return to your inventory
- Works only on blocks you've placed, not on world objects

### LEGO-Style Stacking
- **Vertical Stacking**: When placing on top of a surface (floor or another block), blocks automatically stack with proper grid alignment
- **Grid Snapping**: Blocks snap to a grid on all axes for clean, organized placement
- **Overlap Prevention**: The system checks for existing blocks before placement to prevent overlap
- **Multi-block Placement**: Place multiple blocks rapidly to build structures

### Loot Box System
- **3 loot boxes** spawn randomly in the world
- **Press F** to interact with loot boxes
- Each box contains 5 blocks and 2 items
- Boxes can only be looted once
- Visual feedback: Gold when lootable, gray when looted

## How It Works

### Scripts
1. **block.gd** - Attached to pickup blocks (Area3D)
   - Detects when player enters the area
   - Supports multiple block types via @export variable
   - Calls player's pickup_block() method with type
   - Removes itself from scene after pickup

2. **player.gd** - Enhanced with:
   - `inventory` - Dictionary tracking multiple item types
   - `current_tool` - Tracks active tool ("gun" or "block_placer")
   - `block_rotation` - Current rotation angle for block placement
   - `switch_tool()` - Switches between tools
   - `pickup_block(type)` - Adds items to inventory by type
   - `place_block()` - Places blocks using raycast with rotation
   - `remove_block()` - Removes blocks and returns to inventory
   - `rotate_block()` - Rotates block placement angle
   - `interact_with_object()` - Interacts with world objects
   - `snap_to_grid()` - Aligns blocks to grid
   - `is_position_occupied()` - Checks for block overlap
   - `update_inventory_ui()` - Updates UI display

3. **loot_box.gd** - Attached to loot boxes (StaticBody3D)
   - `interact(player)` - Gives loot to player
   - `can_loot` - Tracks if box has been looted
   - Visual feedback for looted/unlooted state

4. **world_spawner.gd** - Spawns world items (Node3D)
   - Spawns pickup blocks randomly
   - Spawns loot boxes randomly
   - Only runs on server/single-player

5. **inventory_ui.gd** - UI overlay (Control)
   - Finds local player automatically
   - Displays inventory in real-time
   - Shows current tool and rotation
   - Displays controls guide

### Scenes
1. **block.tscn** - Pickup block (Area3D)
   - Has collision shape for pickup detection
   - Includes block model
   - Runs block.gd script
   - Configurable block_type export variable

2. **PlacedBlock.tscn** - Placed block (StaticBody3D)
   - Static collision for placed blocks
   - Same model as pickup block
   - Cannot be picked up after placement
   - Supports rotation

3. **LootBox.tscn** - Lootable box (StaticBody3D)
   - 1x1x1 cube mesh
   - Collision for interaction detection
   - Runs loot_box.gd script
   - Visual feedback system

4. **InventoryUI.tscn** - UI overlay (Control)
   - Inventory display (top-left)
   - Controls guide (bottom-right)
   - Interaction prompt (center)
   - Always visible, mouse-transparent

5. **World.tscn** - Updated with spawner system
   - WorldSpawner node for random item spawning
   - InventoryUI for player feedback
   - Floor and lighting

## Controls
- **WASD** - Move
- **Space** - Jump
- **Mouse** - Look around
- **Left Click** - Shoot (gun) or Place Block (block placer)
- **1** - Switch to gun
- **2** - Switch to block placer
- **R** - Rotate block (block placer mode only)
- **E** - Remove block (block placer mode only)
- **F** - Interact with objects (loot boxes, etc.)
- **ESC** - Release mouse

## Usage Examples

### Basic Building
1. Start the game and spawn into the world
2. Walk over one of the 10 blocks scattered around the map
3. Press **2** to switch to block placer
4. Aim at the floor or another block
5. Click to place a block - it will snap to the grid
6. Continue placing blocks to build structures
7. Press **1** to switch back to the gun

### Advanced Building
1. Press **2** to switch to block placer
2. Press **R** multiple times to rotate the block
3. Place blocks with different rotations for variety
4. Press **E** while looking at a misplaced block to remove it
5. The removed block returns to your inventory

### Looting Boxes
1. Look for gold-colored boxes in the world (3 spawn randomly)
2. Approach a box and press **F** to loot it
3. Receive 5 blocks and 2 items instantly
4. Box turns gray and cannot be looted again
5. Use your new resources to build!

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
1. Raycast from camera to find hit point (PhysicsRayQueryParameters3D)
2. Get hit normal to determine surface orientation
3. Snap position to grid based on normal direction
4. Check for overlapping blocks at target position
5. If clear, instantiate PlacedBlock.tscn at target position with rotation
6. Decrement block inventory
7. Update UI display

### Removal Algorithm
1. Raycast from camera to find target block
2. Check if hit object is a StaticBody3D (placed block)
3. Verify it's in the current scene (not a world object)
4. Remove block from scene
5. Increment block inventory
6. Update UI display

## Multiplayer Notes
- Block pickup and placement are authority-checked
- Only the local player can pick up and place blocks
- Placed blocks are visible to all players (added to current_scene)
- Block count is stored locally per player

## Implemented Features (v2.0)
- ✅ Block removal/destruction with inventory return
- ✅ Multiple item types (blocks, red blocks, blue blocks, items)
- ✅ Block rotation before placement
- ✅ UI showing inventory counts and controls
- ✅ Loot box system with random spawning
- ✅ Random block spawn points
- ✅ Godot 4.x compatible raycasting

## Future Enhancements
- Save/load placed block positions
- Limit on total placeable blocks per player
- Craft different colored blocks from base blocks
- Larger variety of loot box contents
- Preview ghost block before placement
- Sound effects for placement, removal, and looting
