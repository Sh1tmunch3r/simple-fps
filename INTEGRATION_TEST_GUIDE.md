# Integration Test Guide

This guide provides a comprehensive testing checklist for all features implemented in the upgrade.

## Pre-Test Setup

1. Open project in Godot 4.x
2. Ensure all scripts are loaded without errors
3. Check console for any warnings
4. Start Main.tscn scene

## Test Categories

### 1. Core Fixes - Raycasting

**Objective**: Verify PhysicsRayQueryParameters3D works correctly

**Steps**:
1. Start game
2. Switch to block placer (key 2)
3. Look at floor
4. Click to place block
5. **Expected**: Block should place successfully with no console errors

**Pass Criteria**:
- ✅ No "PhysicsRayQuery3D not found" errors
- ✅ Block places correctly
- ✅ Console shows "[Player] Placed block at..." message

---

### 2. Inventory System

#### Test 2.1: Initial State
**Steps**:
1. Start game
2. Look at top-left UI

**Expected**:
- Inventory display visible
- All counts showing 0
- Tool showing "GUN"

#### Test 2.2: Pickup Blocks
**Steps**:
1. Walk around to find pickup blocks (orange/brown cubes)
2. Walk into them
3. Watch inventory UI

**Expected**:
- Block count increases
- Console shows "[Player] Picked up blocks! Total: X"
- Block disappears from world

#### Test 2.3: Multiple Item Types
**Steps**:
1. If different colored blocks are spawned, collect them
2. Watch inventory UI

**Expected**:
- Different item types show separate counts
- Each type tracked independently

---

### 3. Block Building System

#### Test 3.1: Basic Placement
**Steps**:
1. Collect at least 3 blocks
2. Press 2 to switch to block placer
3. Look at floor
4. Click to place block

**Expected**:
- Block appears at grid-aligned position
- Inventory decreases by 1
- Console shows placement message
- UI updates immediately

#### Test 3.2: Grid Snapping
**Steps**:
1. Place multiple blocks in a row
2. Try to place blocks at various angles

**Expected**:
- All blocks align to grid
- No floating blocks
- Blocks stack properly when placing on top

#### Test 3.3: Overlap Prevention
**Steps**:
1. Place a block
2. Try to place another block in same location

**Expected**:
- Second block doesn't place
- Console shows "Position occupied" message
- Inventory doesn't decrease

#### Test 3.4: Block Rotation
**Steps**:
1. Switch to block placer
2. Press R multiple times
3. Watch UI rotation angle
4. Place blocks with different rotations

**Expected**:
- Rotation cycles through 0, 90, 180, 270
- UI shows current rotation
- Placed blocks have correct rotation
- Console shows rotation messages

#### Test 3.5: Block Removal
**Steps**:
1. Place several blocks
2. Look at a placed block
3. Press E to remove it

**Expected**:
- Block disappears
- Inventory increases by 1
- Console shows removal message
- UI updates immediately

#### Test 3.6: Cannot Remove World Objects
**Steps**:
1. Look at the floor
2. Press E

**Expected**:
- Floor doesn't get removed
- Console shows "Cannot remove this object"
- No inventory change

---

### 4. Loot Box System

#### Test 4.1: Box Spawning
**Steps**:
1. Start game
2. Look around the world

**Expected**:
- 3 gold/brown colored boxes visible
- Boxes at different random locations
- Console shows "[WorldSpawner] Spawned loot box at..." messages

#### Test 4.2: Interaction Detection
**Steps**:
1. Walk towards a loot box
2. Look at it from ~5 units away

**Expected**:
- Yellow "[F] to interact" prompt appears
- Prompt follows your view
- Prompt disappears when looking away

#### Test 4.3: Looting
**Steps**:
1. Approach a loot box
2. Look at it
3. Press F

**Expected**:
- Inventory increases by 5 blocks and 2 items
- Box color changes to gray
- Console shows loot message
- UI updates immediately

#### Test 4.4: One-Time Loot
**Steps**:
1. After looting a box, try to loot it again
2. Press F while looking at it

**Expected**:
- No additional loot given
- Console shows "already been looted" message
- Box stays gray
- Interaction prompt may or may not appear (depends on implementation)

#### Test 4.5: Multiple Boxes
**Steps**:
1. Loot all 3 boxes

**Expected**:
- Each box gives loot once
- All 3 boxes turn gray
- Total gain: 15 blocks, 6 items

---

### 5. UI System

#### Test 5.1: Inventory Display
**Steps**:
1. Throughout gameplay, watch top-left corner

**Expected**:
- Always visible
- Updates in real-time
- Shows correct counts
- Shows current tool
- Shows rotation when in block placer mode

#### Test 5.2: Controls Guide
**Steps**:
1. Look at bottom-right corner

**Expected**:
- Always visible
- Shows all controls
- Easy to read

#### Test 5.3: Interaction Prompt
**Steps**:
1. Approach various objects
2. Look at loot boxes

**Expected**:
- Only appears for lootable boxes
- Centered on screen
- Yellow and visible
- Disappears when appropriate

#### Test 5.4: No Input Blocking
**Steps**:
1. Try to click through UI elements
2. Move mouse over UI while playing

**Expected**:
- UI doesn't block mouse input
- Can still shoot, look, place blocks
- No interaction with UI elements

---

### 6. Multiplayer Compatibility

#### Test 6.1: Two Players
**Steps**:
1. Start as host
2. Have second client join
3. Both players collect blocks
4. Both players place blocks

**Expected**:
- Each player has separate inventory
- Each player sees their own UI
- Placed blocks visible to both players
- No inventory sync issues

#### Test 6.2: Loot Box in Multiplayer
**Steps**:
1. Host and client near same loot box
2. Host presses F to loot

**Expected**:
- Host gets loot
- Client sees box turn gray
- Client cannot loot same box
- OR: Implement per-player loot (design choice)

#### Test 6.3: World Spawning
**Steps**:
1. Check server console logs
2. Check client console logs

**Expected**:
- Only server shows spawning messages
- Client doesn't spawn duplicate items
- All spawned items visible to clients

---

### 7. Tool Switching

#### Test 7.1: Switch to Gun
**Steps**:
1. Press 1

**Expected**:
- Gun becomes visible
- UI shows "Tool: GUN"
- Can shoot bullets
- Cannot place blocks
- Console message appears

#### Test 7.2: Switch to Block Placer
**Steps**:
1. Press 2

**Expected**:
- Gun becomes invisible
- UI shows "Tool: BLOCK_PLACER"
- Cannot shoot
- Can place blocks
- Rotation angle appears in UI
- Console message appears

#### Test 7.3: Tool-Specific Actions
**Steps**:
1. In gun mode, try pressing R and E
2. In block placer mode, try left-clicking

**Expected**:
- Gun mode: Left click shoots, R/E do nothing (or only in block mode)
- Block placer: Left click places, R rotates, E removes

---

### 8. World Spawning

#### Test 8.1: Block Spawns
**Steps**:
1. Start fresh game
2. Count visible blocks

**Expected**:
- 10 pickup blocks spawned
- Spread across ~20 unit radius
- All at correct height (0.5)
- Random but reasonable positions

#### Test 8.2: Loot Box Spawns
**Steps**:
1. Start fresh game
2. Count visible loot boxes

**Expected**:
- 3 loot boxes spawned
- Spread across world
- All at correct height
- Gold/brown colored

#### Test 8.3: No Overlap
**Steps**:
1. Check spawn positions

**Expected**:
- Items don't spawn inside each other
- Items don't spawn inside floor
- Items don't spawn outside play area

---

## Performance Testing

### Frame Rate
**Steps**:
1. Place 50+ blocks
2. Check FPS

**Expected**:
- Minimal impact (<5 FPS drop)
- No stuttering
- Smooth gameplay

### Memory
**Steps**:
1. Pick up and place many blocks
2. Loot all boxes
3. Play for 5+ minutes

**Expected**:
- No memory leaks
- Stable memory usage
- No growing memory footprint

---

## Edge Cases

### Test E1: Empty Inventory
**Steps**:
1. Start with 0 blocks
2. Try to place block

**Expected**:
- Console message: "No blocks to place!"
- No block placed
- No crash

### Test E2: Maximum Distance
**Steps**:
1. Look at object >5 units away
2. Try to place/remove/interact

**Expected**:
- Console message about no valid target
- No action performed
- No crash

### Test E3: Rapid Actions
**Steps**:
1. Rapidly press R many times
2. Rapidly place and remove blocks
3. Spam F near loot box

**Expected**:
- No crashes
- No duplicate actions
- System handles rapid input gracefully

---

## Console Output Verification

Throughout testing, console should show clear messages:

```
[WorldSpawner] Spawning items in world...
[WorldSpawner] Spawned pickup block at (x, y, z)
[WorldSpawner] Spawned loot box at (x, y, z)
[Player] Ready! Peer ID: ...
[InventoryUI] Found local player: ...
[Player] Picked up blocks! Total: X
[Player] Switched to block placer (X blocks)
[Player] Block rotation: X degrees
[Player] Placed block at (x, y, z). Remaining: X
[Player] Removing block at (x, y, z)
[Player] Block removed! Total blocks: X
[Player] Interacting with LootBox
[LootBox] Player looting box!
[LootBox] Box looted! Gave X blocks and X items
```

---

## Bug Reporting

If any test fails, report:
1. Which test failed
2. Expected behavior
3. Actual behavior
4. Steps to reproduce
5. Console output
6. Screenshots/video if applicable

---

## Sign-Off

Once all tests pass:
- [ ] All core fixes working
- [ ] Inventory system functional
- [ ] Block building complete (place/rotate/remove)
- [ ] Loot boxes working
- [ ] World spawning correct
- [ ] UI displaying properly
- [ ] Multiplayer compatible
- [ ] No console errors
- [ ] Performance acceptable
- [ ] Documentation complete

**Tested by**: _______________
**Date**: _______________
**Version**: v2.0
**Status**: _______________
