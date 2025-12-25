# Synchronized Scroll Mobile UI in Flutter

*A Practical, Performance‑Focused Developer Walkthrough*

This Flutter UI demonstrates **pixel‑perfect synchronized scrolling** with a clear focus on **smooth performance (≈60 FPS)**, **minimal rebuilds**, and **predictable state updates**. This document explains not just *what* the UI does, but *why* certain architectural and technical decisions were made—especially those that keep scrolling fluid and prevent unnecessary rebuilds.

The goal throughout was to build something that feels solid in the hand, holds up under fast interaction, and is easy for another developer to reason about.

---

## Overview: What the App Does

The screen is composed of three main parts:

1. **A sticky header** that remains fixed at the top
2. **A scrollable top container** that scrolls away naturally
3. **A synchronized content section**, split into:

   * A vertical list of circular items on the left
   * A grid of content on the right

From the user’s perspective, everything scrolls as **one continuous surface**. There’s no sense of competing scroll areas or nested behavior—the interaction feels natural, predictable, and responsive.

---

## High‑Level Structure

```
HomeScreen (StatefulWidget)
├─ Sticky Header (Fixed)
└─ Global Scroll View (SingleChildScrollView)
    ├─ Top Scrollable Container
    └─ Synchronized Content Row
        ├─ Left: Circle List (fixed width)
        └─ Right: Grid View (expanded)
```

This structure intentionally isolates the header from scrolling logic while allowing the rest of the screen to behave like a single scrollable document.

---

## The Core Idea: One Global Scroll Controller

The most important architectural decision was using **a single global `ScrollController`** as the source of truth for vertical scrolling.

### Why This Matters

* One scroll position means **zero synchronization drift**
* No nested scroll physics competing with each other
* Fewer listeners and callbacks per frame
* Predictable scroll math with fewer edge cases

Rather than coordinating multiple independently scrolling widgets, scrolling is treated as a **shared data stream** that passive views simply react to.

---

## User Interaction Without Extra Rebuilds

Users can scroll from **either the left list or the right grid**. To support this without making those widgets independently scrollable or stateful, pointer input is intercepted and forwarded directly to the global scroll controller.

```dart
Listener(
onPointerSignal: (event) {
if (event is PointerScrollEvent) {
final newOffset =
globalScrollController.offset + event.scrollDelta.dy;

globalScrollController.jumpTo(
newOffset.clamp(
0.0,
globalScrollController.position.maxScrollExtent,
),
);
}
},
child: CircleListView(),
)
```

### Why `Listener` Instead of State Updates

* Pointer events **do not trigger widget rebuilds**
* Scroll offset changes live entirely inside controllers
* UI remains responsive during fast or aggressive scrolling

This separation between input handling and widget state is a key reason the UI consistently holds **near‑60 FPS**.

---

## Internal Controllers as Passive Followers

Both the list and the grid still have their own controllers, but they are intentionally configured as **non‑interactive**:

```dart
physics: const NeverScrollableScrollPhysics()
```

These controllers:

* Never receive direct user scroll input
* Never own scroll state
* Simply follow the global controller’s offset

This avoids feedback loops and keeps scroll behavior deterministic and easy to reason about.

---

## State Management Strategy (Reactive, Not Scroll‑Driven)

A core design goal was ensuring that **scrolling itself never causes widget rebuilds**.

### Reactive State with `ValueNotifier`

The UI relies on `ValueNotifier` for lightweight, explicit reactive state:

```dart
final ValueNotifier<List<int>> _circleItems = ValueNotifier([]);
final ValueNotifier<List<int>> _gridItems = ValueNotifier([]);
final ValueNotifier<int> _selectedIndex = ValueNotifier(0);
final ValueNotifier<bool> _isInitialLoading = ValueNotifier(true);
final ValueNotifier<bool> _isPaging = ValueNotifier(false);
final ValueNotifier<bool> _isRefreshing = ValueNotifier(false);
```

### What Triggers Rebuilds

Rebuilds occur **only** when meaningful state changes happen:

* Initial data load
* Pagination appending new items
* Loading indicator visibility changes
* User selection updates

### What Does *Not* Trigger Rebuilds

* Scroll offset changes
* Pointer movement
* Scroll synchronization logic

This keeps rebuilds **event‑driven**, not interaction‑driven—an important distinction for performance.

### Why `ValueNotifier` Over `setState`

`ValueNotifier` was chosen over `setState` for its simplicity and precision:

* Updates are **granular and localized**
* Only listening widgets rebuild
* No accidental full‑tree rebuilds
* State changes are explicit and traceable

```dart
// Instead of setState(() => _items.addAll(newItems));
_gridItems.value = [..._gridItems.value, ...newItems];
```

---

## Pagination Without Scroll Jank

### Trigger Threshold

Pagination is triggered when the user reaches roughly **80% of the current scroll extent**:

```dart
final scrollPercentage =
        position.pixels / position.maxScrollExtent;

if (scrollPercentage >= 0.8) {
_loadMoreGridItems();
}
```

This buffer ensures new data is ready before the user reaches the end of the list.

---

### Preserving Scroll Position

To avoid visual jumps when new items are added:

```dart
final currentOffset = globalScrollController.offset;

_gridItems.value = [..._gridItems.value, ...newItems];

WidgetsBinding.instance.addPostFrameCallback((_) {
globalScrollController.jumpTo(currentOffset);
});
```

### Why This Works

* Layout completes first
* Scroll position is restored after render
* No lost momentum or sudden jumps

This timing detail has a significant impact on perceived smoothness.

---

## Loading Indicator (Intentionally Simple)

The loading indicator is a basic `CircularProgressIndicator`, placed exactly where new content appears.

No overlays, no animations, no layout shifts. The goal is clarity, not distraction.

---

## Scroll Physics Choices

* **Global scroll:** `ClampingScrollPhysics`
* **Child views:** `NeverScrollableScrollPhysics`

This combination prevents bounce conflicts, reduces overdraw, and keeps behavior consistent across platforms.

---

## GridView Inside a Scroll View: Trade‑Off Explained

```dart
shrinkWrap: true,
physics: const NeverScrollableScrollPhysics(),
```

While `shrinkWrap` has a known layout cost, pagination keeps the total item count small enough that:

* Layout cost remains predictable
* Memory usage stays controlled
* Frame rates remain stable

For this use case, the trade‑off is deliberate and acceptable.

---

## Data‑Level Lazy Loading

Instead of complex sliver‑based virtualization, data is loaded in **small, predictable batches** (six items at a time).

This approach:

* Keeps the mental model simple
* Makes debugging easier
* Reduces architectural complexity

Sometimes the most maintainable solution is also the fastest.

---

## Stability & Edge‑Case Handling

* `_isSyncing` flag prevents infinite feedback loops
* `hasClients` checks before controller access
* Offset clamping for safety
* Divide‑by‑zero guards

These small details ensure the UI remains stable under heavy or unexpected interaction.

---

## Performance Summary

**Why this UI feels fast:**

* Scrolling never triggers rebuilds
* Reactive updates are granular and intentional
* Controllers handle motion; widgets handle layout
* Pagination is buffered and predictable

In practice, this keeps frame times low and scrolling smooth, even during aggressive interaction.
