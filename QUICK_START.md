# Quick Start Guide

## 🎮 Play the Game in 2 Minutes

### Setup (First Time Only)
1. Open project in Godot 4.x
2. Press F5 or click "Run Project"
3. Main menu appears

### Host a Game
1. Click **"Host Game"** button
2. Wait for "Server started! Loading game..." message
3. World loads with you as the host
4. Share your IP address with friends

### Join a Game
1. Enter the host's IP address (e.g., "192.168.1.100" or "127.0.0.1" for local)
2. Click **"Join Game"** button
3. Wait for "Connected! Loading game..." message
4. You spawn into the host's world

---

## 🎯 Basic Controls

### Movement
- **WASD**: Move forward/left/back/right
- **Space**: Jump
- **Mouse**: Look around
- **ESC**: Release mouse cursor

### Combat
- **Left Click**: Shoot
- **Right Click** (Hold): Aim Down Sights (zoom + more damage)
- **R**: Reload (2 seconds)

### Building
- **1**: Switch to Gun
- **2**: Switch to Block Placer
- **Q**: Switch Block Type (regular blocks ↔ Block2)
- **R**: Rotate block 90° (when in block placer mode)
- **E**: Remove block (when in block placer mode)
- **Left Click**: Place block (when in block placer mode)

### Other
- **F**: Interact with loot boxes

---

## 🎓 Your First Game

### As Host (1 minute)
1. Host the game
2. Look around - you'll see blocks, loot boxes, and gun pickups scattered
3. Walk over a block to pick it up
4. Press **2** to switch to block placer
5. Click to place a block
6. Press **1** to switch back to gun
7. Shoot the ground to test shooting

### As Client (1 minute)
1. Join the host's game
2. You'll see the same world as the host
3. Walk around, pick up items
4. Try shooting the host (friendly PvP!)
5. Try placing blocks - host will see them

---

## 💡 What Can You Do?

### Combat
- ✅ Shoot other players (15 damage, 20 when aiming)
- ✅ Take damage and die (respawn after 3s)
- ✅ Reload when out of ammo
- ✅ Pick up gun pickups for more ammo

### Building
- ✅ Pick up blocks and Block2 from the world
- ✅ Place them to build structures
- ✅ Rotate blocks before placing
- ✅ Remove blocks you've placed

### Looting
- ✅ Find 3 golden loot boxes in the world
- ✅ Press F to loot (gives blocks, items, ammo)
- ✅ Box turns gray after looting (can't loot again)

### Multiplayer
- ✅ Everything syncs between players
- ✅ See other players move and shoot
- ✅ See blocks other players place
- ✅ See loot boxes turn gray when others loot them

---

## 📊 UI Explanation

### Top-Left (Inventory)
```
=== INVENTORY ===
Health: 100/100        ← Your current health
Blocks: 5              ← Regular blocks count
Block2: 3              ← Block2 count
Items: 2               ← Items count

Tool: GUN              ← Current tool (GUN or BLOCK_PLACER)
Ammo: 25/30            ← Current ammo / Max ammo
Reserve: 60            ← Reserve ammo for reloading
ADS: OFF               ← Aiming status
```

### Center
- **"+"** symbol = Crosshair for aiming
- **"[F] to interact"** = Shows when near loot box

### Bottom-Right (Controls)
```
=== CONTROLS ===
1 - Gun | 2 - Block Placer
LClick - Shoot/Place
RClick - Aim (Gun)
R - Reload/Rotate
Q - Switch Block Type
E - Remove Block
F - Interact
```

---

## 🎯 Pro Tips

1. **ADS Before Shooting**: Right-click to aim for more damage (15 → 20)
2. **Reload Often**: Don't run out of ammo mid-fight
3. **Loot First**: Get loot boxes early for extra resources
4. **Build Cover**: Use blocks to create defensive structures
5. **Block2 is Different**: Cube-shaped, different size than regular blocks
6. **Watch Your Health**: Respawn takes 3 seconds

---

## 🐛 Troubleshooting

### Can't Connect?
- Check IP address is correct
- Make sure host has started the game
- Try 127.0.0.1 for local testing

### Can't See Items?
- Wait 1 second after joining
- Items should sync automatically
- Check console for errors

### Can't Shoot?
- Press **1** to switch to gun
- Check ammo (top-left UI)
- Press **R** to reload if out of ammo

### Can't Place Blocks?
- Press **2** to switch to block placer
- Check you have blocks (top-left UI)
- Pick up blocks from the world first

### Game is Laggy?
- Check network connection
- Reduce number of placed blocks
- Close other applications

---

## 📚 More Information

- **Full Features**: See `MULTIPLAYER_ENHANCEMENTS.md`
- **Testing Guide**: See `TESTING_GUIDE.md`
- **Implementation**: See `PR_IMPLEMENTATION_SUMMARY.md`

---

## 🎉 Have Fun!

You now know everything to enjoy the game. Jump in, shoot some friends, build some structures, and have fun!

Remember: It's all in good fun - everyone respawns! 😄
