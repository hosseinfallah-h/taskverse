# 🎨 TASKVERSE DESIGN SYSTEM

> Every screen is born premium. This is the law.

**Version:** 1.0
**Locked:** 2026-10-12
**Status:** 🟢 Active

---

## 1. Philosophy

TaskVerse must feel **alive**. Not animated for the sake of animation — alive
because every interaction has weight, response, and warmth.

Three rules:

1. **Warm, not sterile.** No pure white backgrounds in light mode. Ever.
2. **Motion with meaning.** Every animation communicates state, not decoration.
3. **Haptic honesty.** Every meaningful tap *feels* like something happened.

Persian-first: RTL layout, IranSans typography, Jalali calendar native,
right-aligned everything by default.

---

## 2. Palette — "Garden at Dawn"

### 2.1 Core tokens

| Token | Light | Dark | AMOLED |
|-------|-------|------|--------|
| `background` | `#F5F1EA` (sand) | `#0A0F0D` (night) | `#000000` |
| `surface` | `#FBF9F5` (paper) | `#151B19` (nightSoft) | `#000000` |
| `surfaceElevated` | `#FFFFFF` (cloud) | `#1F2724` (nightElevated) | `#0A0A0A` |
| `onBackground` | `#1A1F1D` (ink) | `#EDEFEE` | `#FFFFFF` |
| `onSurface` | `#1A1F1D` | `#EDEFEE` | `#FFFFFF` |
| `onSurfaceMuted` | `#5A6663` (inkSoft) | `#98A29E` | `#98A29E` |
| `onSurfaceSubtle` | `#98A29E` (inkMuted) | `#5A6663` | `#5A6663` |

### 2.2 Brand & accents

| Token | Hex | Purpose |
|-------|-----|---------|
| `brandPrimary` | `#0F5132` | Primary buttons, headers |
| `brandPrimaryDeep` | `#083D24` | Pressed state |
| `mint` | `#00C896` | Success, checkmarks |
| `mintSoft` | `#C8F3E4` | Success surfaces |
| `sunGold` | `#F2B33D` | XP, rewards, accents |
| `sunGoldSoft` | `#FCEFCE` | Achievement surfaces |
| `rose` | `#E85D75` | Overdue, urgent |
| `roseSoft` | `#FBD9E0` | Error surfaces |
| `sky` | `#5AA9E6` | Info, links |
| `skySoft` | `#D6E9F7` | Info surfaces |
| `plum` | `#7A5AA8` | Content/creative mode |
| `plumSoft` | `#E5DDF0` | Creative surfaces |

### 2.3 Semantic priority colors

| Priority | Color | Dot |
|----------|-------|-----|
| P0 (urgent) | `#E85D75` rose | ●●●● |
| P1 (high) | `#F2B33D` sunGold | ●●● |
| P2 (normal) | `#5AA9E6` sky | ●● |
| P3 (low) | `#98A29E` inkMuted | ● |

### 2.4 Gradients (sparingly)

```
# "Sunrise" (used on hero cards, XP bar)
linear-gradient(135deg, #F2B33D 0%, #E85D75 100%)

# "Garden" (used on success/streak cards)
linear-gradient(135deg, #00C896 0%, #0F5132 100%)

# "Dawn" (used on splash, empty states)
linear-gradient(180deg, #F5F1EA 0%, #C8F3E4 100%)
```

Rule: **one gradient per screen max.** Gradients are seasoning, not the meal.

---

## 3. Typography

**Primary font:** IranSans (Vazirmatn fallback).  
**Numeric:** IranSans numerals (Persian) with Latin fallback for phone/date.

| Token | Size | Weight | Usage |
|-------|------|--------|-------|
| `display` | 34 | 800 | Screen heroes |
| `headline` | 24 | 700 | Section titles |
| `title` | 18 | 600 | Card titles |
| `body` | 16 | 400 | Default text |
| `label` | 14 | 500 | Buttons, chips |
| `caption` | 12 | 500 | Meta, timestamps |

Line height: 1.6 for Persian text (farsi needs more breathing room than Latin).

---

## 4. Spacing Scale

Only use these. No magic numbers.

```
xxs = 4
xs  = 8
sm  = 12
md  = 16
lg  = 24
xl  = 32
xxl = 48
```

---

## 5. Radius

```
sm  = 12   (chips, small cards)
md  = 16   (inputs, buttons)
lg  = 20   (cards)
xl  = 28   (hero cards, sheets)
full = 999 (pills)
```

---

## 6. Elevation & Shadows

**No default Material shadows.** We use soft colored glows instead.

```dart
// Card glow (subtle, ambient)
BoxShadow(
  color: brandPrimary.withValues(alpha: 0.06),
  blurRadius: 24,
  offset: Offset(0, 8),
)

// Accent glow (on primary buttons, FAB)
BoxShadow(
  color: mint.withValues(alpha: 0.32),
  blurRadius: 32,
  offset: Offset(0, 12),
)

// Danger glow (overdue tasks)
BoxShadow(
  color: rose.withValues(alpha: 0.24),
  blurRadius: 24,
  offset: Offset(0, 8),
)
```

---

## 7. Motion System

Every transition has a named curve + duration.

| Motion | Duration | Curve | Used for |
|--------|----------|-------|----------|
| `instant` | 100ms | `Curves.easeOut` | Hover, ripple |
| `quick` | 200ms | `Curves.easeOutCubic` | Chip taps, state toggles |
| `standard` | 300ms | `Curves.easeInOutCubic` | Page push, dialogs |
| `emphasized` | 450ms | `Curves.easeOutExpo` | Hero transitions |
| `celebrate` | 700ms | `Curves.elasticOut` | XP gain, streak |

**Shared axis transitions** between related screens.  
**Container transform** when a card expands into a detail screen.  
**Hero** for avatar + task title.

---

## 8. Haptics

Every meaningful interaction gets haptic feedback.

| Action | Haptic |
|--------|--------|
| Button tap | `HapticFeedback.selectionClick()` |
| Task completion | `HapticFeedback.mediumImpact()` |
| XP gain / streak | `HapticFeedback.heavyImpact()` |
| Error / validation | `HapticFeedback.vibrate()` |
| Long-press select | `HapticFeedback.lightImpact()` |
| Swipe (delete, complete) | `HapticFeedback.selectionClick()` |

---

## 9. Component Library (target)

Every component must exist in 3 modes (light / dark / AMOLED).

**Layout:**
- `TaskVerseScaffold` — base wrapper
- `TaskVerseBottomNav` — pill-shaped bottom navigation
- `TaskVerseAppBar` — transparent, RTL-aware

**Cards:**
- `TaskCard` — with priority dot, tags, time, subtasks
- `HeroCard` — big metric with gradient accent
- `PersonCard` — avatar + name + birthday badge
- `ProjectCard` — two-tone color blocks (from inspiration)

**Inputs:**
- `TaskVerseInput` — filled, soft, with label
- `TaskVerseButton` — filled/outlined/text, 52px height
- `ChipPicker` — for tags, categories, priorities
- `TimeRangePicker` — split START/END

**Feedback:**
- `Toast` — bottom, animated
- `BottomSheet` — rounded top, drag handle
- `Skeleton` — shimmer, matches final layout
- `EmptyState` — illustration + action

**Charts (Sprint 6):**
- `ProgressRing` — animated circular
- `TimelineBars` — the overlapping bar chart from inspiration #2
- `Heatmap` — for habit/content streak
- `Sparkline` — inline mini charts

---

## 10. Bottom Navigation (from inspiration #1)

Pill-shaped bar with icon + label. Active state = filled dark pill.

```
┌─────────────────────────────────────────────┐
│  [Home]  [Projects]  [ + ]  [Calendar] [Me] │
└─────────────────────────────────────────────┘
```

- Center `+` is a **FAB**, elevated with mint glow
- Others are tappable pill slots
- Active slot animates with shared axis

---

## 11. Home Screen (Today view) — Wireframe

```
┌─────────────────────────────────────────┐
│  [avatar]  Good morning, Hossein   [🔔] │
│            شنبه ۱۲ مهر                   │
│                                         │
│  Today's Progress                       │
│  ┌───────────────────────────────────┐  │
│  │  ◯ 72%   4 of 12 done             │  │
│  │          3 high priority          │  │
│  │  ▓▓▓▓▓▓▓▓░░░░░░░░░                │  │
│  └───────────────────────────────────┘  │
│                                         │
│  [To Do]  [In Progress]  [Done]        │
│                                         │
│  ● P0  Design landing page              │
│       09:00 – 11:30  +2  ⋯              │
│  ● P1  Reply to brand email             │
│       11:45 – 12:15  ⋯                  │
│  ● P2  Content shoot — Reels #12        │
│       14:00 – 16:00  ⋯                  │
│                                         │
│  ┌─────────────────────────────────────┐│
│  │  Home  Projects  +  Calendar  Me    ││
│  └─────────────────────────────────────┘│
└─────────────────────────────────────────┘
```

---

## 12. "Alive" — Concrete Rules

To honor the "completely alive" mandate:

1. **Every card enters with a stagger** (20ms offset per card).
2. **Every checkbox** has a spring + confetti on P0 completion.
3. **XP bar** animates from previous to new value over 700ms.
4. **Streak flames** pulse gently (0.95 → 1.05 scale, 2s loop).
5. **FAB** breathes (subtle 8px → 12px shadow pulse, 3s loop).
6. **Loading** = shimmer, never a spinner.
7. **Empty states** have an illustration + one clear CTA.
8. **Pull-to-refresh** uses a custom mint droplet animation.
9. **Tab switches** use shared axis X.
10. **Dark ↔ AMOLED** cross-fades over 300ms.

---

## 13. Anti-Patterns (Never Do These)

- ❌ Pure white `#FFFFFF` as a background in light mode
- ❌ Default Material elevation shadows
- ❌ Red without rose softness (`#FBD9E0`)
- ❌ Green without warmth (always paired with mint/gold)
- ❌ Emojis in critical UI (only in user content)
- ❌ Icon-only buttons without labels (except bottom nav)
- ❌ Latin numerals in Persian UI (use Persian numerals)
- ❌ More than one gradient per screen
- ❌ Animation longer than 700ms (except celebration)
- ❌ Toasts in the top half of the screen

---

## 14. Design Inspirations (locked for reference)

Three references drive the visual language:

1. **"Productive Day"** — pastel progress ring, pill filters, rounded bottom nav.
2. **"Delivery App UI Kit"** — hero metric cards, timeline bars, center FAB.
3. **"Hello John!"** — two-tone project cards, category pills, time-range widget.

**How we fuse them:**
- Progress ring → `TodayProgressCard` (Home)
- Pill filter row → task filters
- Bottom nav → `TaskVerseBottomNav`
- Hero metric card → streaks + XP card
- Timeline bars → reports (Sprint 6)
- Two-tone cards → project cards
- Category pills → task editor tags
- Time range → task scheduling sheet

**All adapted to:**
- RTL layout
- IranSans font
- Garden-at-Dawn palette
- Persian numerals
- Jalali dates

---

## 15. Files (implementation)

| File | Purpose |
|------|---------|
| `mobile/lib/core/theme/app_theme.dart` | Light/dark/AMOLED ThemeData |
| `mobile/lib/core/theme/colors.dart` | Color tokens |
| `mobile/lib/core/theme/typography.dart` | Text styles |
| `mobile/lib/core/theme/spacing.dart` | Spacing + radius |
| `mobile/lib/core/theme/motion.dart` | Curves + durations |
| `mobile/lib/core/theme/haptics.dart` | Haptic helpers |
| `mobile/lib/shared/widgets/` | All reusable components |

---

**This is the law. Every PR must comply.**