# Simple FPS - Multiplayer Game

A fully-featured multiplayer first-person shooter with building mechanics, built in Godot 4.

## 🎮 Features

### Multiplayer
- **Host/Join System**: Easy lobby system for hosting or joining games
- **Player Synchronization**: Real-time position, rotation, and state sync
- **World State Sync**: All players see the same world (blocks, loot, pickups)
- **Up to 8 Players**: Supports 2-8 players in a session

### Combat
- **PvP Combat**: Damage other players (15-20 damage per hit)
- **Health System**: 100 HP with death and respawn mechanics
- **ADS (Aim Down Sights)**: Right-click to zoom and increase damage
- **Reloading**: Ammo management with reload system (30/30 + 90 reserve)
- **Gun Pickups**: Find gun pickups for more ammo

### Building
- **Two Block Types**: Regular blocks and Block2 (cubes)
- **Block Placement**: Grid-snapped placement with rotation
- **Block Removal**: Remove placed blocks with E key
- **Synchronized**: All block placements sync across clients

### Loot System
- **Loot Boxes**: 3 lootable boxes spawn in the world
- **Contents**: Blocks, Block2, items, and ammo
- **Synchronized**: Looted state syncs to prevent duplicate looting

### UI
- **Health Display**: See your current HP
- **Ammo Counter**: Track bullets and reserve ammo
- **Inventory**: View all collected items
- **Crosshair**: Center screen aiming reticle
- **Controls Guide**: On-screen control reference

## 🚀 Quick Start

### Play in 2 Minutes
1. Open project in Godot 4.x
2. Press F5 or click "Run Project"
3. Click **"Host Game"** or enter IP and click **"Join Game"**
4. Start playing!

**See [QUICK_START.md](QUICK_START.md) for detailed instructions.**

## 🎯 Controls

| Action | Key |
|--------|-----|
| Move | WASD |
| Jump | Space |
| Look | Mouse |
| Shoot | Left Click |
| Aim (ADS) | Right Click (Hold) |
| Reload | R |
| Switch to Gun | 1 |
| Switch to Block Placer | 2 |
| Switch Block Type | Q |
| Rotate Block | R (in block placer mode) |
| Remove Block | E (in block placer mode) |
| Place Block | Left Click (in block placer mode) |
| Interact | F |
| Release Mouse | ESC |

## 📁 Project Structure

```
simple-fps/
├── Scenes/
│   ├── Main.tscn              # Main menu and lobby
│   ├── World.tscn             # Game world
│   ├── Player.tscn            # Player character
│   ├── block.tscn             # Regular block pickup
│   ├── Block2.tscn            # Block2 pickup (NEW)
│   ├── PlacedBlock.tscn       # Placed regular block
│   ├── PlacedBlock2.tscn      # Placed Block2 (NEW)
│   ├── LootBox.tscn           # Lootable box
│   ├── GunPickup.tscn         # Gun/ammo pickup (NEW)
│   ├── Bullet.tscn            # Bullet projectile
│   └── InventoryUI.tscn       # HUD overlay
├── Scripts/
│   ├── main.gd                # Main menu logic
│   ├── network_manager.gd     # Network connection handling
│   ├── world.gd               # World initialization
│   ├── world_spawner.gd       # Item spawning with sync
│   ├── player.gd              # Player controller (enhanced)
│   ├── block.gd               # Block pickup logic
│   ├── loot_box.gd            # Loot box interaction
│   ├── gun_pickup.gd          # Gun pickup logic (NEW)
│   ├── bullet.gd              # Bullet physics and damage
│   ├── inventory_ui.gd        # UI management
│   └── game_manager.gd        # Game state management
└── Documentation/
    ├── README.md              # This file
    ├── QUICK_START.md         # Quick start guide
    ├── MULTIPLAYER_ENHANCEMENTS.md  # Feature documentation
    ├── TESTING_GUIDE.md       # Testing procedures
    ├── PR_IMPLEMENTATION_SUMMARY.md # Implementation details
    └── Other docs...
```

## 🔧 Technical Details

### Requirements
- **Godot 4.x** (tested on Godot 4.0+)
- **ENet Multiplayer** (built-in)
- **No external dependencies**

### Network Architecture
- **Server-Authoritative Model**: Server manages world state
- **RPC Communication**: Player actions synced via RPCs
- **MultiplayerSynchronizer**: Real-time position/health sync
- **Low Bandwidth**: Efficient event-driven networking

### Key Systems

#### Multiplayer Sync
- `request_world_state()` - Client requests world data
- `sync_world_state()` - Server sends spawn positions
- `spawn_placed_block_rpc()` - Syncs block placement
- `take_damage()` - Syncs player damage
- `set_looted()` - Syncs loot box state

#### Player Features
- Health: 100 HP, damage 15-20 per hit
- Respawn: 3-second delay at random position
- ADS: FOV 70→50, damage +5
- Reload: 2-second reload time
- Inventory: Tracks multiple item types

#### Building System
- Grid snapping for clean placement
- Two block types with different sizes
- Rotation support (0°, 90°, 180°, 270°)
- Overlap prevention
- Network synchronized

## 📚 Documentation

- **[QUICK_START.md](QUICK_START.md)** - Get started in 2 minutes
- **[MULTIPLAYER_ENHANCEMENTS.md](MULTIPLAYER_ENHANCEMENTS.md)** - Complete feature documentation
- **[TESTING_GUIDE.md](TESTING_GUIDE.md)** - 25 test cases with procedures
- **[PR_IMPLEMENTATION_SUMMARY.md](PR_IMPLEMENTATION_SUMMARY.md)** - Implementation details
- **[BLOCK_SYSTEM_README.md](BLOCK_SYSTEM_README.md)** - Building system details

## 🧪 Testing

### Run Tests
1. Open two instances of Godot
2. Host game in first instance
3. Join from second instance
4. Test features from TESTING_GUIDE.md

### Quick Test
- [ ] Both players visible and movable
- [ ] Shooting deals damage
- [ ] Block placement syncs
- [ ] Loot boxes work and sync
- [ ] Death and respawn works

## 🐛 Known Limitations

1. **Friendly Fire**: Players can damage themselves
2. **No Teams**: All players are hostile to each other
3. **Late Join Blocks**: Late joiners don't see pre-placed blocks
4. **No Respawn**: Picked-up items don't respawn
5. **No Effects**: No particle or sound effects

*These are documented as future enhancements.*

## 🔮 Future Enhancements

- Team system (red vs blue)
- Scoreboard and kill tracking
- Weapon variety
- Particle effects (muzzle flash, impacts)
- Sound effects
- Power-ups
- More block types
- Save/load world state
- Chat system
- Voice communication

## 🤝 Contributing

This is a solo project, but feedback and suggestions are welcome!

## 📝 License

This project is open source. Feel free to use, modify, and learn from it.

## 🎮 Credits

Built with Godot Engine 4.x

## 📞 Support

For issues or questions:
1. Check the documentation files
2. Review console output for errors
3. See TESTING_GUIDE.md for troubleshooting
4. Check GitHub issues

## 🎉 Have Fun!

Jump in, shoot some friends, build some structures, and enjoy! 

Remember: It's all in good fun - everyone respawns! 😄

---

**Version**: 2.0 (Multiplayer Enhanced)
**Last Updated**: 2024
**Status**: Fully Functional ✅
