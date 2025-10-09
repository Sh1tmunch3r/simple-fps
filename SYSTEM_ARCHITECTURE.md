# System Architecture

This document provides a visual overview of how all systems interact in the upgraded FPS game.

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         GAME WORLD                              │
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐        │
│  │ WorldSpawner │  │    Player    │  │  Inventory   │        │
│  │              │  │              │  │     UI       │        │
│  │ - Spawns     │◄─┤ - Movement   │◄─┤ - Display    │        │
│  │   blocks     │  │ - Tools      │  │ - Updates    │        │
│  │ - Spawns     │  │ - Inventory  │  └──────────────┘        │
│  │   loot boxes │  │ - Building   │                           │
│  └──────────────┘  └──────┬───────┘                           │
│                            │                                    │
│                            │ Interacts with                     │
│                            ▼                                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐        │
│  │ Pickup Block │  │  Loot Box    │  │ Placed Block │        │
│  │              │  │              │  │              │        │
│  │ - Collectible│  │ - Lootable   │  │ - Static     │        │
│  │ - Has type   │  │ - One-time   │  │ - Removable  │        │
│  │ - Disappears │  │ - Visual FB  │  │ - Rotatable  │        │
│  └──────────────┘  └──────────────┘  └──────────────┘        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Component Interaction Diagram

```
Player (player.gd)
    │
    ├─► inventory{} ──────────────────┐
    │   (tracks all items)             │
    │                                  │
    ├─► pickup_block(type) ◄──────────┤
    │   (adds to inventory)            │
    │                                  │
    ├─► place_block() ────────────────┤
    │   (uses inventory)               │
    │                                  │
    ├─► remove_block() ───────────────┤
    │   (returns to inventory)         │
    │                                  │
    ├─► rotate_block() ───────────────┤
    │   (changes rotation angle)       │
    │                                  │
    ├─► interact_with_object() ───────┤
    │   (calls loot box interact)      │
    │                                  │
    └─► update_inventory_ui() ────────┤
        (notifies UI to update)        │
                                       │
                                       ▼
                            InventoryUI (inventory_ui.gd)
                                       │
                                       ├─► find_player()
                                       │   (locates local player)
                                       │
                                       ├─► update_inventory_display()
                                       │   (reads player.inventory)
                                       │
                                       └─► show/hide prompts
                                           (contextual feedback)
```

## Data Flow Diagram

### Block Pickup Flow
```
1. Player walks over Pickup Block (block.tscn)
2. Block's Area3D detects body_entered
3. Block calls player.pickup_block(block_type)
4. Player increments inventory[block_type]
5. Player calls update_inventory_ui()
6. InventoryUI reads player.inventory
7. InventoryUI updates label text
8. Block calls queue_free() (removes itself)
```

### Block Placement Flow
```
1. Player presses left-click in block_placer mode
2. Player calls place_block()
3. Raycast from camera (PhysicsRayQueryParameters3D)
4. If hit:
   a. Get position and normal
   b. Call snap_to_grid(pos, normal)
   c. Call is_position_occupied(pos)
   d. If not occupied:
      - Call spawn_placed_block(pos, rotation)
      - Decrement inventory["blocks"]
      - Call update_inventory_ui()
5. PlacedBlock.tscn instantiated in world
```

### Block Removal Flow
```
1. Player presses E in block_placer mode
2. Player calls remove_block()
3. Raycast from camera
4. If hit StaticBody3D:
   a. Check if it's in current_scene (not world object)
   b. If valid:
      - Call hit_object.queue_free()
      - Increment inventory["blocks"]
      - Call update_inventory_ui()
5. Block disappears from world
```

### Loot Box Interaction Flow
```
1. Player presses F
2. Player calls interact_with_object()
3. Raycast from camera
4. If hit has interact() method:
   a. Call hit_object.interact(self)
5. LootBox.interact(player):
   a. Check if can_loot == true
   b. If yes:
      - Call player.pickup_block() multiple times
      - Set can_loot = false
      - Call update_appearance() (gold → gray)
6. Player inventory updates
7. UI refreshes
```

## File Dependencies

```
World.tscn
├── ExtResource: world.gd
├── ExtResource: world_spawner.gd
├── ExtResource: InventoryUI.tscn
│   └── ExtResource: inventory_ui.gd
└── Children:
    ├── Floor (CSGBox3D)
    ├── Light (DirectionalLight3D)
    └── WorldSpawner (Node3D)
        └── Spawns dynamically:
            ├── block.tscn (10x)
            │   └── ExtResource: block.gd
            └── LootBox.tscn (3x)
                └── ExtResource: loot_box.gd

Player.tscn
└── ExtResource: player.gd
    └── Uses:
        ├── PlacedBlock.tscn (on placement)
        └── Communicates with:
            ├── block.gd (pickup)
            ├── loot_box.gd (interact)
            └── inventory_ui.gd (updates)
```

## State Machine Diagram

### Player Tool State
```
┌──────┐   Press 1    ┌──────┐
│ GUN  │ ◄───────────┤      │
│      │              │      │
│ - Shoot allowed     │ Tool │
│ - Place disabled    │Switch│
│ - Remove disabled   │ State│
└──┬───┘              │      │
   │                  │      │
   │ Press 2          │      │
   ▼                  │      │
┌──────┐              │      │
│BLOCK │ ◄───────────┴──────┘
│PLACER│
│      │
│ - Shoot disabled
│ - Place allowed
│ - Remove allowed
│ - Rotate allowed
└──────┘
```

### Loot Box State
```
┌─────────────┐
│  UNLLOOTED  │
│ (gold box)  │
│ can_loot = true
└──────┬──────┘
       │
       │ Player presses F
       ▼
┌─────────────┐
│   LOOTED    │
│  (gray box) │
│ can_loot = false
└─────────────┘
       │
       │ (permanent)
       ▼
   No more loot
```

## System Initialization Sequence

```
1. Game Start
   │
2. World._ready()
   │
   ├─► spawn_player()
   │   (creates Player instance)
   │
   └─► WorldSpawner._ready()
       │
       ├─► spawn_pickup_blocks()
       │   (creates 10 blocks)
       │
       └─► spawn_loot_boxes()
           (creates 3 boxes)

3. Player._ready()
   │
   ├─► add_to_group("players")
   │   (for UI to find)
   │
   └─► Initialize inventory{}

4. InventoryUI._ready()
   │
   ├─► find_player()
   │   (searches "players" group)
   │
   └─► update_inventory_display()
       (initial UI setup)

5. Game Running
   │
   └─► All systems ready
```

## Multiplayer Architecture

```
Server (Host)
├─► Spawns WorldSpawner items (authoritative)
│   ├─► 10 pickup blocks (visible to all)
│   └─► 3 loot boxes (visible to all)
│
├─► Player 1 (Server's player)
│   ├─► Has authority over own actions
│   ├─► Local inventory (not synced)
│   └─► UI shows own inventory
│
└─► Placed blocks (added to scene, visible to all)

Client
├─► Player 2 (Client's player)
│   ├─► Has authority over own actions
│   ├─► Local inventory (not synced)
│   └─► UI shows own inventory
│
└─► Sees all placed blocks and items
```

## Performance Characteristics

### Time Complexity
- **Inventory Access**: O(1) - Dictionary lookup
- **Raycast**: O(log n) - Physics engine handles
- **UI Update**: O(1) - String concatenation
- **Block Placement**: O(1) - Direct instantiation
- **Overlap Check**: O(m) - m = nearby objects

### Space Complexity
- **Inventory**: O(1) - Fixed size dictionary
- **UI**: O(1) - Fixed labels
- **World Items**: O(n) - n = spawned items
- **Placed Blocks**: O(p) - p = player-placed blocks

### Bottlenecks
- **Raycasting**: Limited by physics engine (acceptable)
- **UI Updates**: Minimal (text only)
- **Block Spawning**: One-time cost at start
- **Memory**: Linear with placed blocks (acceptable)

## Error Handling

```
Player Actions
├─► place_block()
│   ├─► Check inventory > 0 → "No blocks to place!"
│   ├─► Check raycast hit → "No valid surface"
│   └─► Check occupied → "Position occupied"
│
├─► remove_block()
│   ├─► Check raycast hit → "No block to remove"
│   └─► Check valid target → "Cannot remove this object"
│
└─► interact_with_object()
    ├─► Check raycast hit → (silent)
    └─► Check has interact → "Cannot interact"

LootBox
└─► interact()
    └─► Check can_loot → "Already been looted"

WorldSpawner
└─► _ready()
    └─► Check is_server → (skip if client)
```

## Scaling Considerations

### Current Limits
- **Pickup Blocks**: 10 (configurable)
- **Loot Boxes**: 3 (configurable)
- **Inventory Items**: Unlimited (no cap)
- **Placed Blocks**: Unlimited (performance may degrade)

### Recommended Limits
- **Placed Blocks**: 500-1000 per player (for performance)
- **Active Items**: 50-100 in world (for rendering)
- **Players**: 4-8 (for network bandwidth)

### Future Optimizations
- Object pooling for blocks
- Chunk system for large builds
- Level of Detail (LOD) for distant blocks
- Occlusion culling for placed blocks

---

This architecture is designed for:
- ✅ Modularity (easy to extend)
- ✅ Performance (minimal overhead)
- ✅ Maintainability (clear structure)
- ✅ Scalability (can handle growth)
- ✅ Multiplayer (safe for networking)
