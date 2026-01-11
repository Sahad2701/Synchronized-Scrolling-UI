## Synchronized Scroll UI

### Problem Statement

* Screen has a fixed app bar, a scrollable header, and two side-by-side scroll views
* ListView and GridView must scroll **together first**
* After the header scrolls out, they must scroll **independently**
* Pagination in GridView must not break alignment
* No lag, no offset mismatch, no scroll drift

---

## Key Challenge

* Flutter does not handle multi-view scroll synchronization reliably
* Multiple scroll controllers cause:

   * Offset drift
   * Feedback loops
   * Jank during pagination
* The real issue is **scroll ownership**, not syncing math

---

## Core Idea

* Never sync two scroll controllers at the same time
* Only **one scroll owner exists at any moment**
* Scrolling is divided into **two deterministic phases**

---

## Phase 1: Synchronized Scroll

* Header is visible
* AppBar is fixed
* ListView and GridView are **not scrollable**
* A single global scroll controller handles user input
* Both views move using the same scroll offset
* Views are visually positioned, not independently scrolling

**Result**

* Pixel-perfect sync
* Zero delay
* No feedback loops

---

## Phase 2: Independent Scroll

* Header is fully scrolled out
* Global scroll stops
* ListView and GridView get their own controllers
* Both are pinned below the app bar
* Scrolling one does not affect the other

---

## Phase Transition

* Switch happens when:

```
globalOffset >= headerHeight
```

* Remaining offset is transferred instantly
* No animation
* No jump
* Scroll ownership changes cleanly

---

## Pagination Strategy

* Pagination only allowed in Phase 2
* GridView appends items without modifying scroll offset
* Pagination is disabled during synchronized scrolling
* Prevents layout jumps and desync

---

## Overscroll & Physics

* Shared scroll uses clamping physics
* Independent scroll uses default platform physics
* Prevents bounce from breaking alignment

---

## State Management

* Used `ValueNotifier` instead of `setState`
* Scroll position changes do not trigger rebuilds
* Only mode changes and data updates rebuild UI

---

## Performance Considerations

* No `animateTo`
* No delayed sync logic
* No continuous listener-based syncing
* Minimal rebuilds
* Stable 60 FPS under continuous scroll

---

## Why This Works

* Two scroll controllers never fight each other
* Sync is deterministic, not reactive
* Pagination is isolated from synchronization logic
* Scroll behavior is predictable and testable

---


## Additional Problem Observed (Important Edge Case)

During implementation, a practical UX issue appeared when **ListView and GridView are synchronized**.

## Problem Description

While ListView and GridView scroll together:

* User selects an item in the ListView (e.g. last category)
* User scrolls down using the GridView
* User scrolls the GridView back to the top

At this point:

* Global scrolling becomes active again
* Header reappears
* ListView scrolls back to the top
* The previously selected list item is no longer visible
* User loses visual context of the selection

This behavior feels broken from a UX perspective, even though it is technically correct.

---

## Root Cause

* In synchronized mode, ListView does not control its own scroll position
* Global scroll ownership resets the ListView position
* Selection state still exists in data, but is lost visually

This is a **side-effect of global scroll ownership**, not a ListView bug.

---

## Competitive Analysis (Real Apps)

Apps like **JioMart, Swiggy, and Zepto** handle this case more gracefully.

Observed behavior:

* Selected category is remembered
* Selection remains visible or highlighted
* Works even when the header reappears
* Scroll position is not the source of truth for selection

They decouple **selection state** from **scroll position**.

---

## Solution Approach

Instead of relying on scroll position:

* Maintain an explicit `selectedIndex` for ListView
* On switching back to global scroll:

   * Do not force ListView to scroll to absolute top
   * Restore scroll so the selected item remains visible
   * Or visually pin / highlight the selected item

**Key principle:**
Selection state must be independent of scroll state.

---

## Design Decision

* Scroll synchronization is responsible only for movement
* Selection is managed separately
* Scroll resets never override user intent

This prevents:

* Loss of context
* Sudden list jumps
* Confusion when switching scroll modes

---

## Why This Matters

This is not a technical bug, but a **product-level edge case**.

If ignored:

* UI feels unstable
* User thinks selection is lost
* Experience feels jumpy and unreliable

Handling this correctly makes the interaction feel **intentional and polished**.