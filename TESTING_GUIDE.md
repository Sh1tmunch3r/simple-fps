# Testing Guide for Multiplayer FPS Enhancements

## Quick Start Testing

### Setup
1. Open the project in Godot 4.x
2. Run the Main scene (Main.tscn)
3. Host will click "Host Game"
4. Client will enter host IP and click "Join Game"

### Basic Multiplayer Test (5 minutes)

#### Test 1: Host Setup
1. Host clicks "Host Game"
2. Wait for world to load
3. Verify you see:
   - Floor and environment
   - 10 regular blocks scattered
   - 5 Block2 blocks (cubes) scattered
   - 3 golden loot boxes
   - 4 gun pickups (cylinders)
   - Your player (capsule)
   - Inventory UI (top-left)
   - Crosshair (center)
   - Controls guide (bottom-right)

#### Test 2: Client Join
1. Client enters host IP (127.0.0.1 for local)
2. Click "Join Game"
3. Wait for world to load
4. Verify client sees:
   - Same items as host (same positions)
   - Host's player (capsule, moving around)
   - Own player (controllable)
   - All UI elements

#### Test 3: Movement and Visibility
1. Host moves with WASD
2. Client should see host moving
3. Client moves with WASD
4. Host should see client moving
5. Both press Space to jump
6. Both should see each other jumping

**Expected**: Players are visible and movement syncs smoothly.

### Combat Testing (10 minutes)

#### Test 4: Basic Shooting
1. Both players: Press 1 (gun mode)
2. Both players: Aim at ground and left-click
3. Verify:
   - Bullet spawns
   - Ammo decreases (30 → 29)
   - UI updates

#### Test 5: PvP Combat
1. Host aims at client player
2. Host left-clicks to shoot
3. Verify:
   - Client health decreases (visible in client's UI)
   - Console shows "[Player] Took X damage"
4. Client shoots back at host
5. Verify host health decreases

#### Test 6: Death and Respawn
1. Host shoots client until health reaches 0
2. Verify:
   - Client player becomes invisible
   - Console shows death message
   - After 3 seconds, client respawns
   - Client appears at new random location
   - Client health restored to 100

#### Test 7: ADS (Aim Down Sights)
1. Player holds right mouse button
2. Verify:
   - FOV zooms in (narrower view)
   - UI shows "ADS: ON"
3. Release right mouse button
4. Verify:
   - FOV returns to normal
   - UI shows "ADS: OFF"
5. Shoot while aiming (should do 20 damage vs 15 normal)

#### Test 8: Reloading
1. Shoot until ammo is 0/30
2. Press R to reload
3. Verify:
   - UI shows "RELOADING..."
   - Cannot shoot for 2 seconds
   - After reload: ammo is 30/30
   - Reserve ammo decreased (90 → 60)

### Building Testing (10 minutes)

#### Test 9: Block Placement (Host)
1. Host walks over a block to pick it up
2. Press 2 (block placer mode)
3. UI should show blocks count increased
4. Aim at floor, left-click to place
5. Verify:
   - Block appears on floor
   - Client sees the block appear
   - Host inventory decreases

#### Test 10: Block Placement (Client)
1. Client picks up a block
2. Press 2 (block placer)
3. Place block on floor
4. Verify:
   - Block appears for client
   - Host sees the block appear
   - Client inventory decreases

#### Test 11: Block2 Usage
1. Pick up a Block2 (cube shape)
2. Press 2 (block placer)
3. Press Q to switch to Block2
4. UI should show "Block Type: BLOCK2"
5. Place Block2
6. Verify:
   - Cube block appears
   - Other player sees it
   - Block2 inventory decreases

#### Test 12: Block Rotation
1. Press 2 (block placer)
2. Press R multiple times
3. Verify UI shows rotation: 0° → 90° → 180° → 270° → 0°
4. Place block while at 90°
5. Block should be rotated

#### Test 13: Block Removal
1. Press 2 (block placer)
2. Look at a placed block
3. Press E to remove
4. Verify:
   - Block disappears
   - Inventory increases
   - Other player sees removal

### Loot Box Testing (5 minutes)

#### Test 14: Loot Box Interaction (Host)
1. Host approaches a golden loot box
2. Press F to loot
3. Verify:
   - Box turns gray
   - Inventory increases (blocks, block2, items)
   - Reserve ammo increases (+30)
   - Console shows loot received

#### Test 15: Loot Box Sync (Client)
1. Client looks at the box host looted
2. Verify:
   - Box is gray (not golden)
   - Cannot loot (already looted)
3. Client finds different box (golden)
4. Client presses F to loot
5. Verify:
   - Host sees box turn gray
   - Client receives loot

### Gun Pickup Testing (5 minutes)

#### Test 16: Gun Pickup
1. Player walks over gun pickup (cylinder)
2. Verify:
   - Pickup disappears
   - Ammo increases (up to max 30)
   - Reserve ammo increases (+60)
   - Console shows pickup message

#### Test 17: Gun Pickup Sync
1. Host picks up a gun
2. Verify:
   - Client sees gun disappear
3. Client picks up different gun
4. Verify:
   - Host sees gun disappear

### Edge Case Testing (10 minutes)

#### Test 18: No Ammo Scenario
1. Shoot until ammo is 0/30
2. Try to shoot
3. Verify:
   - Nothing happens
   - Console shows "Out of ammo! Press R to reload"

#### Test 19: Reloading with Empty Reserve
1. Reload until reserve is 0
2. Try to reload again
3. Verify:
   - Cannot reload
   - Console shows "No reserve ammo!"

#### Test 20: No Blocks Scenario
1. Use all blocks from inventory
2. Try to place block
3. Verify:
   - Nothing happens
   - Console shows "No blocks to place!"

#### Test 21: Dead Player Cannot Act
1. Player dies
2. Try to move, shoot, place blocks
3. Verify:
   - Cannot do any actions
   - Wait 3 seconds for respawn

#### Test 22: Respawn Clears States
1. Player aims (right-click)
2. Player starts reloading (R)
3. Player dies before reload finishes
4. Verify after respawn:
   - Not aiming (normal FOV)
   - Not reloading
   - Full health and ammo

### Stress Testing (5 minutes)

#### Test 23: Rapid Block Placement
1. Pick up multiple blocks
2. Place 10+ blocks rapidly (spam click)
3. Verify:
   - All blocks appear for both players
   - No crashes or errors
   - Inventory updates correctly

#### Test 24: Rapid Shooting
1. Hold left-click to shoot rapidly
2. Verify:
   - Ammo depletes correctly
   - Bullets spawn
   - No crashes

#### Test 25: World State After Late Join
1. Host spawns world and plays for a minute
2. Host places some blocks
3. Client joins late
4. Verify:
   - Client sees original spawned items
   - Client sees host-placed blocks
   - Everything syncs correctly

## Known Issues to Watch For

1. **Friendly Fire**: Players can damage themselves with their own bullets
2. **No Team System**: All players are hostile to each other
3. **Placed Blocks Not Synced on Join**: Late joiners won't see blocks placed before they joined (only world-spawned items)
4. **No Pickup Respawn**: Picked-up items don't respawn

## Performance Checks

- Framerate should stay stable (30+ FPS)
- No lag when placing blocks
- Smooth player movement
- No network errors in console

## Bug Reporting

If you find issues, report:
1. What you were doing
2. What you expected
3. What actually happened
4. Console error messages (if any)
5. Which player experienced it (host/client)
6. Can you reproduce it?

## Success Criteria

✅ Players can join and see the same world
✅ Players can see each other move
✅ Players can damage each other
✅ Death and respawn works
✅ ADS and reloading work
✅ Block placement syncs
✅ Block2 works as expected
✅ Loot boxes sync state
✅ Gun pickups work and sync

If all criteria pass, the multiplayer system is working correctly!
