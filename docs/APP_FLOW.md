# App Flow

### Initial State

When the app launches:
- Fixed app bar at the top
- Top container (Container-1) visible below the app bar
- Circle list on the left (12 items by default)
- Grid view on the right (8 items by default)
- Both views are synchronized and scroll together

### Synchronized Scrolling Phase

While the top container is visible:
- User scrolls using either the circle list or grid view
- Both views move together pixel-perfectly
- A single global scroll controller manages all scrolling
- Circle list and grid view use `NeverScrollableScrollPhysics` - they don't control their own scrolling
- Scrolling is handled by the parent `SingleChildScrollView`

### Transition to Independent Scrolling

When the user scrolls past the top container:
- Global scroll offset reaches or exceeds the container height
- `isContainer1Visible` becomes `false`
- Scroll physics change:
  - Circle list gets `BouncingScrollPhysics` (can scroll independently)
  - Grid view gets `BouncingScrollPhysics` (can scroll independently)
  - Global scroll gets `NeverScrollableScrollPhysics` (stops scrolling)
- Circle list becomes positioned fixed below the app bar
- Both views can now scroll independently

### Independent Scrolling Phase

After transition:
- Circle list scrolls independently on the left
- Grid view scrolls independently on the right
- Each view has its own scroll controller
- Scrolling one view does not affect the other
- Pagination is enabled for the grid view

### Circle Selection

When user taps a circle item:
- Selected index updates
- Grid content refreshes (resets to 6 new items)
- Grid scroll position resets to top
- Circle list scrolls to show selected item (centered if possible)
- Container does not automatically reappear
- User must manually scroll grid to top to bring container back

### Pagination

When scrolling near the bottom of the grid:
- Pagination triggers at 70% scroll progress
- Loading indicator appears at bottom of grid
- 10 new items are added to the grid
- Scroll position is preserved to prevent visual jumps
- Works in both synchronized and independent modes

### Return to Synchronized Mode

When grid view is scrolled back to top:
- Grid scroll offset reaches 0
- Container automatically reappears
- Global scroll animates to show the top container
- Views transition back to synchronized mode
- Circle list scroll position resets to match grid

## Architecture

### Component Structure

**HomeScreen** (`lib/screens/home_screen.dart`)
- Root screen widget
- Manages global scroll controller
- Measures top container height
- Coordinates overall layout

**SynchronizedContent** (`lib/widgets/synchronized_content.dart`)
- Main content coordinator
- Manages circle list and grid scroll controllers
- Handles circle selection and grid refresh
- Coordinates between ScrollSyncManager and PaginationManager

**ScrollSyncManager** (`lib/widgets/synchronized_content/scroll_sync_manager.dart`)
- Handles scroll synchronization logic
- Manages phase transitions (synchronized ↔ independent)
- Updates container visibility
- Syncs scroll positions between views

**PaginationManager** (`lib/widgets/synchronized_content/pagination_manager.dart`)
- Monitors scroll position for pagination triggers
- Loads additional grid items
- Preserves scroll position during content updates

**ContentState** (`lib/widgets/synchronized_content/content_state.dart`)
- Centralized state management using ValueNotifiers
- Holds: items, loading states, selected index, scroll physics
- Prevents unnecessary rebuilds

### Widget Hierarchy

```
HomeScreen
├── AppBar (fixed)
└── SingleChildScrollView (global scroll)
    ├── TopContainer
    └── SynchronizedContent
        ├── CircleListView (left)
        └── GridViewContainer (right)
```

### Scroll Controllers

1. **Global Scroll Controller** (`_globalScrollController`)
   - Controls overall page scroll
   - Active when top container is visible
   - Manages synchronized scrolling phase

2. **Circle List Scroll Controller** (`_circleListScrollController`)
   - Controls circle list scrolling
   - Active in independent scrolling phase
   - Used for positioning selected items

3. **Grid Scroll Controller** (`_gridScrollController`)
   - Controls grid view scrolling
   - Active in independent scrolling phase
   - Monitored for pagination triggers

## Implementation Details

### Scroll Synchronization Strategy

The app uses a two-phase approach to avoid scroll controller conflicts:

**Phase 1: Synchronized Scrolling**
- Only one scroll controller (global) is active
- Circle list and grid views are visually positioned using `jumpTo()`
- Views use `NeverScrollableScrollPhysics` to prevent independent scrolling
- Pixel-perfect synchronization with zero delay

**Phase 2: Independent Scrolling**
- Global scroll controller stops (uses `NeverScrollableScrollPhysics`)
- Circle list and grid get their own active controllers
- Each view scrolls independently
- No synchronization logic runs

### State Management

Uses `ValueNotifier` instead of `setState` for scroll-related state:
- Prevents rebuilds during scroll position changes
- Only rebuilds when mode changes or data updates
- Maintains smooth 60 FPS scrolling performance

#### Why ContentState?

The app uses `ContentState` with `ValueNotifier` instead of `setState` for state management. This solves a critical performance problem:

**The Problem:** Scroll positions change constantly (potentially 60 times per second). Using `setState` would rebuild the entire widget tree on every scroll event, causing severe jank and frame drops.

**The Solution:** `ContentState` uses `ValueNotifier` for reactive state. This allows:
- Only specific listeners rebuild, not the entire widget tree
- Scroll position changes don't trigger full rebuilds
- Smooth 60 FPS scrolling performance maintained
- State updates are efficient

This approach ensures the app maintains smooth scrolling even during rapid position changes and phase transitions.

### Phase Transition

Transition happens when:
```
globalScrollOffset >= container1Height
```

During transition:
- Container visibility updates instantly
- Scroll physics change immediately
- Remaining scroll offset transfers to appropriate controller
- No animation or delay

### Pagination Strategy

Pagination only triggers in independent scrolling mode or after scrolling past container:
- Monitors scroll position relative to content height
- Triggers at 70% scroll progress
- Preserves scroll position before adding items
- Restores scroll position after layout completes

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── screens/
│   └── home_screen.dart        # Main screen
├── widgets/
│   ├── synchronized_content.dart
│   ├── top_container.dart
│   ├── circle_list/
│   │   ├── circle_list_view.dart
│   │   └── circle_list_item.dart
│   ├── grid_view/
│   │   ├── grid_view_container.dart
│   │   ├── grid_container_item.dart
│   │   └── grid_loading_placeholder.dart
│   └── synchronized_content/
│       ├── content_state.dart
│       ├── scroll_sync_manager.dart
│       └── pagination_manager.dart
├── constants/
│   ├── app_colors.dart
│   ├── app_dimensions.dart
│   ├── app_spacing.dart
│   └── app_strings.dart
└── theme/
    ├── app_theme.dart
    └── app_typography.dart
```

## Development Guidelines

### Key Design Decisions

1. **Single Scroll Owner**: Only one scroll controller is active at any time to prevent conflicts
2. **Instant Transitions**: No animations during phase changes to maintain responsiveness
3. **ValueNotifier State**: Scroll position changes don't trigger rebuilds
4. **Position Preservation**: Scroll positions preserved during pagination to prevent jumps
5. **Selection Independence**: Circle selection state separate from scroll position

### Adding New Features

**To add a new scrollable view:**
1. Create scroll controller in `SynchronizedContent`
2. Add scroll listener to `ScrollSyncManager`
3. Update `syncToGlobalScroll()` to include new view
4. Add physics ValueNotifier to `ContentState`

**To modify pagination behavior:**
1. Edit `PaginationManager.checkPagination()`
2. Adjust trigger threshold (currently 70%)
3. Modify `loadMoreItems()` to change item count or loading behavior

**To change transition behavior:**
1. Modify `ScrollSyncManager.updateContainer1Visibility()`
2. Adjust transition threshold or add animation
3. Update physics assignment logic

### Testing Checklist

- Test synchronized scrolling smoothness
- Verify phase transitions don't cause jumps
- Check pagination preserves scroll position
- Ensure circle selection works in both phases
- Test container reappearance when scrolling to top

### Performance Optimizations

- Uses `RepaintBoundary` to isolate repaints
- `cacheExtent` set to 500px for smooth scrolling
- `addAutomaticKeepAlives: false` to reduce memory
- Minimal rebuilds during scrolling
- No `animateTo` calls during synchronization

#### Why RepaintBoundary?

`RepaintBoundary` is used around individual list and grid items (`CircleListItem` and `GridContainerItem`) to optimize rendering performance:

**The Problem:** During scrolling, Flutter repaints the entire visible area by default. When one item changes (like selection state or animations), it can trigger repaints of neighboring items and the entire scroll view, causing unnecessary work and potential jank.

**The Solution:** `RepaintBoundary` creates an isolated rendering layer for each item. This means:
- Only the specific item that changes gets repainted, not its neighbors
- Reduces GPU work during scrolling and animations
- Prevents repaint cascades when items update independently
- Improves scrolling performance, especially with many items

**Benefits:**
- Isolated repaints: Changes to one item don't affect others
- Better scrolling performance: Less work during rapid scroll events
- Smoother animations: Item animations don't trigger full view repaints
- Reduced GPU load: Only changed regions are redrawn

This is especially important in this app because:
- Circle items have selection animations and press effects
- Grid items are frequently scrolled and may update independently
- Both views scroll simultaneously, requiring efficient rendering

## Troubleshooting

**Views not synchronizing:**
- Check that `isContainer1Visible` is true
- Verify scroll physics are set correctly
- Ensure global scroll controller has clients

**Pagination not triggering:**
- Verify scroll position calculation
- Check that `isPaging` is not already true
- Ensure grid has enough content to scroll

**Container not reappearing:**
- Check grid scroll offset reaches 0
- Verify `isRefreshingFromCircleSelection` is false
- Ensure bring-back logic is enabled

## Related Documentation

- [Technical Implementation Details](SCROLL_SYNC_README.md) - Deep dive into scroll synchronization algorithms and edge cases
