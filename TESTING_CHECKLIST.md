# Block System Testing Checklist

## Manual Testing Guide

### Setup
- [ ] Game launches without errors
- [ ] World scene loads with floor, lighting, and blocks
- [ ] Player spawns successfully
- [ ] 5 pickup blocks are visible in the world

### Block Pickup
- [ ] Walk near a block
- [ ] Block disappears when player touches it
- [ ] Console shows "[Block] Player picked up block!"
- [ ] Console shows block count increment "[Player] Picked up block! Total blocks: 1"
- [ ] Can pick up multiple blocks
- [ ] Block count increases correctly

### Tool Switching
- [ ] Press 1 - switches to gun
- [ ] Console shows "[Player] Switched to gun"
- [ ] Gun model is visible
- [ ] Press 2 - switches to block placer
- [ ] Console shows "[Player] Switched to block placer (X blocks)"
- [ ] Gun model becomes hidden

### Block Placement - Basic
- [ ] With block placer equipped, aim at floor
- [ ] Click to place block
- [ ] Block appears at target location
- [ ] Block is aligned to grid
- [ ] Block count decrements
- [ ] Console shows "[Player] Placed block at ... Remaining: X"

### Block Placement - Stacking
- [ ] Place a block on the floor
- [ ] Aim at top of placed block
- [ ] Place another block on top
- [ ] New block stacks vertically
- [ ] Blocks are aligned in grid
- [ ] Can stack multiple blocks vertically

### Block Placement - Grid Adjacent
- [ ] Place multiple blocks next to each other
- [ ] Blocks snap to grid positions
- [ ] Blocks align properly without gaps
- [ ] Can create horizontal rows of blocks

### Block Placement - Edge Cases
- [ ] Try to place block with 0 blocks in inventory
- [ ] Console shows "[Player] No blocks to place!"
- [ ] Nothing happens
- [ ] Try to place block too far away (>5 units)
- [ ] Console shows "[Player] No valid surface to place block"
- [ ] Try to place block where one already exists
- [ ] Console shows "[Player] Position occupied, cannot place block"
- [ ] Block is not placed

### Rapid Placement
- [ ] Pick up multiple blocks (3-5)
- [ ] Switch to block placer
- [ ] Click rapidly while moving camera
- [ ] Multiple blocks place successfully
- [ ] Blocks form grid/stack structures
- [ ] No blocks overlap

### Physics and Collision
- [ ] Placed blocks have collision
- [ ] Player cannot walk through placed blocks
- [ ] Can jump on placed blocks
- [ ] Can place blocks on placed blocks
- [ ] Bullets collide with placed blocks

### Tool Functionality
- [ ] Switch back to gun (press 1)
- [ ] Gun works normally
- [ ] Can shoot bullets
- [ ] Switch to block placer (press 2)
- [ ] Clicking places blocks instead of shooting
- [ ] Tool state persists across switches

## Expected Console Output Examples

### Picking up block:
```
[Block] Pickup block ready
[Block] Player picked up block!
[Player] Picked up block! Total blocks: 1
```

### Switching tools:
```
[Player] Switched to gun
[Player] Switched to block placer (3 blocks)
```

### Placing blocks:
```
[Player] Placed block at (1.92, 0.046, 1.86). Remaining: 2
[Player] Placed block at (1.92, 0.138, 1.86). Remaining: 1
```

### Error cases:
```
[Player] No blocks to place!
[Player] No valid surface to place block
[Player] Position occupied, cannot place block
```

## Known Limitations
- Blocks cannot be removed after placement
- No UI indicator for block count (console only)
- Blocks are placed locally (no multiplayer sync in this implementation)
- Block rotation is not implemented
- All blocks use the same model/appearance

## Success Criteria
✅ All pickup blocks can be collected
✅ Tool switching works smoothly
✅ Blocks place with proper grid alignment
✅ Blocks stack vertically on top of each other
✅ Blocks can be placed adjacent to form structures
✅ Overlap prevention works correctly
✅ Rapid placement works without issues
✅ Collision detection works for placed blocks
