# UI Layout Guide

## Visual Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│ ┌─────────────────────────┐                                             │
│ │ === INVENTORY ===       │                                             │
│ │ Blocks: 5               │                                             │
│ │ Red Blocks: 0           │                                             │
│ │ Blue Blocks: 0          │                                             │
│ │ Items: 2                │                                             │
│ │                         │                                             │
│ │ Tool: BLOCK_PLACER      │                                             │
│ │ Rotation: 90°           │                                             │
│ └─────────────────────────┘                                             │
│                                                                           │
│                                                                           │
│                                                                           │
│                              [ F to interact ]                           │
│                           (when near loot box)                           │
│                                                                           │
│                                                                           │
│                                                                           │
│                                                                           │
│                                      ┌─────────────────────────────────┐ │
│                                      │ === CONTROLS ===                │ │
│                                      │ 1 - Gun                         │ │
│                                      │ 2 - Block Placer                │ │
│                                      │ R - Rotate block                │ │
│                                      │ E - Remove block                │ │
│                                      │ F - Interact                    │ │
│                                      └─────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────┘
```

## UI Elements

### 1. Inventory Display (Top-Left)
**Position**: 10px from left, 10px from top
**Size**: ~240x150 pixels
**Content**:
- Header: "=== INVENTORY ==="
- Item counts for each type
- Current tool indicator
- Block rotation (only when in block placer mode)

**Style**:
- White text with black shadow
- Font size: 14px
- Always visible
- Mouse-transparent (doesn't block game input)

### 2. Interaction Prompt (Center)
**Position**: Centered horizontally, slightly below center
**Size**: 300x30 pixels
**Content**: "[F] to interact"

**Style**:
- Yellow text with black shadow
- Font size: 18px
- Only visible when near interactable object
- Mouse-transparent

**Trigger**: When player is within 5 units of a loot box

### 3. Controls Guide (Bottom-Right)
**Position**: 10px from right, 10px from bottom
**Size**: ~290x110 pixels
**Content**:
- Header: "=== CONTROLS ==="
- List of all keybindings

**Style**:
- Gray text with black shadow
- Font size: 12px
- Always visible
- Mouse-transparent

## Color Scheme

- **Primary Text**: White (#FFFFFF)
- **Secondary Text**: Gray (#CCCCCC)
- **Highlight Text**: Yellow (#FFFF00)
- **Shadow**: Black (#000000)
- **Background**: None (transparent)

## Responsive Behavior

- UI scales with screen resolution
- Anchors maintain position relative to screen edges
- Mouse input passes through all UI elements
- No performance impact (static labels, minimal updates)

## State Changes

### Inventory Updates
- Updates every frame (minimal cost, just text change)
- Shows real-time item counts
- Tool name updates immediately on switch
- Rotation angle updates immediately on R press

### Interaction Prompt
- Hidden by default
- Shows when raycast detects loot box within range
- Hides when player moves away or looks away
- Instant show/hide (no animation)

## Accessibility

- High contrast text with shadows
- Clear, readable fonts
- Large enough text size (14-18px)
- Important info in corners (not center of view)
- No flashing or rapid changes

## Technical Implementation

```gdscript
# inventory_ui.gd updates display every frame
func _process(_delta):
    if player:
        update_inventory_display()

# Text formatting
var text = "=== INVENTORY ===\n"
text += "Blocks: " + str(inv["blocks"]) + "\n"
# ... etc
inventory_label.text = text
```

## Testing the UI

1. **Start Game**: Inventory should show 0 for all items
2. **Pick Up Block**: Count should increment immediately
3. **Switch Tool**: Tool name should update
4. **Rotate Block**: Rotation angle should appear and update
5. **Near Loot Box**: Yellow prompt should appear
6. **Away from Box**: Prompt should disappear
7. **Controls Guide**: Should always be visible bottom-right

## Known Issues

- None currently

## Future Improvements

- Add item icons next to counts
- Add progress bars for inventory limits
- Add crosshair in center
- Add health/ammo display
- Add minimap
- Add animation for text updates
