# Design record — Apache 3800 cyberdeck panels

Everything an agent or collaborator needs to continue the design: what was
decided, why, where every number came from, what is still open. Keep it
current — append to the decision log when you change something.

Coordinates: mm, origin at the centre of the case opening, **−Y = front
(handle)**, **+Y = hinge**, +X = right. Numbers below are for the current
`config.scad` defaults.

---

## 1. Hardware (decided by the owner)

| Item | Choice | Status |
|---|---|---|
| Case | Harbor Freight **Apache 3800** (item 63927) | owned |
| Screen | **VILVA V156F1** 15.6" FHD portable monitor ([amazon.com/dp/B0BTSFVMLV](https://www.amazon.com/dp/B0BTSFVMLV)), USB-C + mini-HDMI | model known (2026-10-05); preset `vilva15.6` from the listing — **not measured yet** |
| Keyboard | **Logitech K400 Plus** (keyboard + touchpad, wireless, 2×AA) | decided; modelled from a STEP |
| Base mounting | **Printables 1478000 "Apache 3800 Panel Bracket"** (4-piece ring, M3 heat-set inserts) | owner has the STEP + a Bambu `.3mf` for it |
| Printer | **Bambu X1C**, 256 × 256 bed | → panels split into 2 × 2 tiles |
| Computer / battery / I/O boards | **not chosen** | don't assume; ask |

## 2. Case

Harbor Freight spec: inside 383 × 271 mm at the rim (15.063" × 10.688"), lid
depth 44 mm (1.75"), base depth 108 mm (4.25"). Front = handle side, hinge at
the back.

**Source ranking (owner, 2026-10-06):** 1. the Printables bracket STEP
(photos show it fitted in real cases) → **380 × 270 mm, R17 corners**
(fillet centres ±173, ±118), used for both halves; 2. the Harbor Freight spec
→ lid depth **44**; 3. a third-party case CAD from the web (`Lid.step`, see
`ref/apache-3800-case.md`, low trust) → only what 1 and 2 don't cover, tagged
`MEASURE`: walls lean in **0.03 mm per mm**, **≈R21 rounded corner** where the
lid walls meet the floor (starts ~28 mm down; 16 mm wide at the floor),
gasket groove in the top of the wall with nothing sticking into the cavity.
It disagrees with 1/2 on corner radius (R20) and lid depth (46.5).

Unmeasured (tagged `MEASURE`): `lid_panel_drop` (how far below the lid rim the
screen panel face sits; the CAD shows no gasket lip inside, so 6 is a free
choice), `base_panel_drop` (where the brackets end up below the base rim).

## 3. Lid — screen panel

Files: `parts/lid_panel.scad`, `parts/screen_retainer.scad`, `parts/lid_bracket.scad`.

- **Panel**: 377.3 × 267.3 mm, R15.6, 6 mm thick (`case_in − 2·(panel_gap +
  lid_draft_inset)`; the draft inset is the wall lean at the panel's back face).
- **Monitor**: VILVA V156F1 (`vilva15.6`). Listing: 14.48 × 8.85 × 0.30" →
  **367.8 × 224.8 × 7.6 mm** (photos say 0.19" = 4.8 mm at the thin edge, so
  7.6 is the thickest point), 1.68–1.88 lb, 1920 × 1080 IPS → standard 15.6"
  active area 344.2 × 193.6. Thin top/side bezels, thick bottom chin: picture
  centre estimated **+10 mm** above the shell centre from product photos.
  **Controls are on both short edges** (manual's "Function Keys & Ports"
  diagram): one edge has mini-HDMI + 2 × USB-C; the other has the 3.5 mm
  jack, OTG USB, the **multi-function wheel** (push up = brightness, press =
  menu), a power LED and the **power button**. Both groups sit in the thick
  chin end; rough diagram reading: wheel ≈ 49 mm, power ≈ 68 mm from the
  bottom edge. Which edge is left/right is not confirmed. (Earlier notes said
  "all on the right" — wrong.)
- **Window**: active area + 0.5 mm/side = **345.2 × 194.6 mm**, centred at
  (0, +10). 45° × 2 mm bevel on the viewing side.
- **Monitor retention**: 8 bosses on the panel back, **all on the long edges**
  (4 per edge at x = ±46, ±137.9, y = ±116.9), height = monitor thickness +
  0.5 mm foam shim, M3 heat-set insert each. 8 flat clips (`screen_retainer`)
  screw on and overlap the monitor shell by 4 mm. No short-edge bosses: the
  368 mm shell leaves only ~4.7 mm per side inside the 377 mm panel. Even count
  keeps x = 0 free for the seam. If the shell is wedge-shaped (4.8 → 7.6 mm),
  the thin-edge clips need extra foam.
- **Mounting**: 8 countersunk M3 holes (`lid_mount_holes`, y = ±127.9) — 4
  per long wall at x = ±50, ±150 — onto **8 printed posts** (`lid_post()` in
  `lib/common.scad`, exported as `lid_bracket`): 18 × 12 × **32 mm** (lid
  depth − drop − panel). The posts **sit on the floor fillet** (their bottom is
  cut to the R21 curve with a 0.3 mm glue gap) with the back face 0.3 mm off
  the wall — they cannot reach the flat floor, the fillet fills the bottom
  16 mm next to the wall. Sized for the 44 mm spec depth: if the lid is
  really 46.5 deep (case CAD), they hang up to 2.5 mm above the fillet and
  the wall screw / glue holds them — so they fit either way. Inserts: top (panel screw) and **back face** (screw
  sideways through the 5.5 mm lid wall), and/or VHB/epoxy on the back. Fit
  order: screw the panel onto the posts, set it in the lid, then fix the posts. The former 4 end-wall posts
  (x = ±184.5, y = ±90) were dropped: they sat under the monitor. Holes avoid
  the seams (x = 0, y = 0) and the bosses.
- **Fit checks** (`lid_panel.scad` asserts — the render stops with a message):
  every boss inside the panel, no boss on a lid post, no lid post under the
  monitor, monitor inside the leaning lid walls (echo `LID monitor-to-wall
  gap`). Current margins: boss edge ↔ post 1.0 mm; monitor end ↔ lid wall
  **5.5 mm**, top/bottom 22 mm. Also checked visually against the
  third-party lid CAD (sections through a post and the monitor end).
- Both monitor ends sit behind the panel, 5.5 mm from the wall: **the power
  button and brightness wheel are not reachable** as designed (open question
  0), and the cables need **very low-profile right-angle plugs** (5.5 mm is
  less than most right-angle USB-C heads) that turn back toward the lid
  floor (~24 mm free behind the monitor).

Presets in `screen_presets` (all approximate): `7`, `10.1`, `13.3`, `15.6`
(bare panels), `travel15.6`, `travel14` (generic travel monitors),
`vilva15.6` (the owner's, default) and `custom`. Format
`[module_w, module_h, module_t, active_w, active_h, active_off_x, active_off_y]`.

## 4. Base — keyboard / ports faceplate

File: `parts/base_faceplate.scad`.

### 4.1 Plate and the Printables bracket ring

- **Plate**: `base_plate = [378, 268, 16]` → ~1 mm gap to the 380 × 270 R17 walls
  at bracket height, 6 mm thick (bracket tops 22 mm below the rim = drop + thickness).
- **Bracket ring** (from `ref/apache-3800-panel-bracket-v8.step`, see
  `ref/printables-bracket.md`): four bodies — Front (x −120…120, y −135…−123),
  Back (mirror), two L-shaped end pieces wrapping the corners (x ±115…±190).
  17 mm tall; the plate rests on the 12 mm-wide top face (inner faces at
  y = ±123 and x = ±178); a 5 mm strip continues down the wall with
  horizontal Ø4 holes (screws into the case wall).
- **16 insert positions** (`base_mount_holes`): Front/Back y = ∓128 at
  x = −70, 0, 70; ends at (±140, ±128) and (±183, −85 / 0 / 85).
  **14 are used**: `used_mount_holes` auto-skips any hole that would land
  within ~6 mm of the keyboard slot, which drops the two middle end-bracket
  holes (±183, 0) since the slot became full keyboard width.

### 4.2 Keyboard: K400 Plus, sits on top

Measured from the GrabCAD STEP (see `ref/k400-plus.md`):

| Feature | Value |
|---|---|
| Outline at widest shell edge | 355 × 140 mm (spec 354.3 × 139.9 × 23.5) |
| Keys | stand ~2 mm above the frame top |
| Flat underside | 12 mm below frame top — rests on the plate |
| Battery hump | 8 mm below the flat underside (20 below frame top), along the back edge — faces **+Y** (hinge) |
| Hump footprint at the plate top | full width ±177.4 × 38.5 mm from the back edge (front blends in with a large fillet; at the plate underside, 6 mm down: ±174.3 × 30.3). Back corners R≈15 in plan. From cross-sections of the STL |
| Touchpad | right side |

Design (owner's choice: keyboard flat on the plate, minimal hole — keeps the
plate simple, e.g. for a possible future aluminium plate; **don't start
aluminium work until asked**):
- Keyboard centred at `kb_offset = (0, −40)` → occupies y −110…+30.
- **Hump slot** 357 × 40.5 mm (footprint + 1 mm/side), **R6** corners,
  centred (0, 10.75) → y −9.5…31. The hump hangs ~2 mm below the plate
  underside. Fit checked against the real model (keyboard ∩ plate = empty):
  clears up to ~R10 and still clears with the slot 0.5 mm smaller per side
  at R6; R13+ hits the front corners. The slot also
  locates the keyboard; velcro dots optional. Lift off to use wirelessly /
  change batteries.
- **Lid clearance**: keyboard top (keys) stands 14 mm above the plate. With
  `base_panel_drop = 16` the keys are 2 mm below the base rim; the lid panel
  face is 6 mm below the lid rim → **~8 mm** clearance closed. (At the old
  10 mm drop it would have been only 2 mm.) Brackets must be installed so
  the plate top is at that depth.
- The slot leaves ~10.5 mm of plate at each end beside it; the strip behind
  the slot is tied to the back tiles by the y = 44 seam screws.

### 4.3 Ports, vent

`ports` (type, x, y, rot) on a row at **y = 106**: 2× USB-A, USB-C, HDMI, RJ45,
12 mm and 16 mm round (switch / LED / GX16). Sizes in `port_types` are
**generic panel-mount extension guesses** — measure the real parts. One vent
grille `[110, 76, 120, 26]` (2.5 mm slots @ 6 mm) between the seam band and
the port row. Port/vent placement is placeholder until the owner picks
internals.

**Battery charge input**: [Adafruit 4218](https://www.adafruit.com/product/4218)
USB-C round panel-mount extension (`usbc_round`, 22 mm hole = 21.5 min +
0.5 print clearance) at **(−160, 106)** — back-left corner, left end of the
port row. Its nut (~29.5 mm OD) on the back stays ~3 mm clear of the left end
bracket (inner face x = −178), ~2 mm of the back bracket (y = 123), ~8 mm of
the USB-A at −120, and clear of the bracket screws (−140, 128) / (−183, 85);
panel limit 16 mm (plate is 6).
Back side is a 30 cm USB-C cable to the (not yet designed) battery.
Spec in `ref/adafruit-4218.md`.

## 5. Printing: tiles and lap joints

`lib/common.scad` splits any panel larger than `bed − bed_margin` into tiles
(`auto_split` picks the orientation needing fewer tiles; seams can be forced
with `lid_split_x/y`, `base_split_x/y` lists).

- **Half-lap joint**: in a `lap_w` = 20 mm band at each seam, the back half
  (z < t/2) belongs to the left/lower tile and the front half to the
  right/upper tile (`tile_mask` shifts the seam ±lap/2 per layer). Visible
  face shows one clean line.
- **Seam screws**: M3 countersunk from the front + hex-nut pocket on the back,
  spaced ~`seam_hole_pitch` along each seam, always including one
  `seam_edge_inset` from each panel edge, minus any in a keep-out
  (windows, cutouts, mount holes, bosses, the lid monitor's footprint — the
  back-side nut would hold the monitor off the panel). A mount screw
  landing in a lap band clamps it instead.
- Current layout: **lid** 2 × 2, seams x = 0 / y = 0, **2 seam screws**, both
  on x = 0 at y = ±123.5. The y = 0 seam has **none** (window in the middle,
  monitor over both ends) — it is glue-only; each tile is still screwed to its
  own 2 lid posts. **Base** 2 × 2, seams x = 0 / y = 44 (forced
  behind the keyboard), **9 seam screws** (one at (0, −61.5) sits under the
  keyboard — countersunk flush); the bracket screws at (0, ±128) also clamp
  the x = 0 lap. Glue the laps.
- Tiles export as `stl/<part>_tile_<i>_<j>.stl` (i along X, j along Y,
  0 = negative side). Print front-face-down for the best visible surface.

## 6. Hardware list (current design)

- M3 heat-set inserts (Ø4 hole, 5.7 mm): 8 (screen bosses) + 16 (lid posts,
  top + bottom) + 14 for the Printables brackets (2 of its 16 positions unused).
- M3 countersunk screws: 14 base mount, 8 lid mount, 11 seam (9 base + 2
  lid; M3 × 10 mm, seams need nuts); 8 pan/button heads for clips;
  lid-post fixing screws if not glued.
- M3 hex nuts: 11 (seams).
- Velcro dots for the keyboard (optional).
- Foam tape (0.5 mm) for the monitor shim. Glue (e.g. CA/epoxy) for laps.

## 7. Measured vs. assumed

| Value | Source | Confidence |
|---|---|---|
| Case rim interior, depths | Harbor Freight spec | good |
| Interior at bracket height 380 × 270 R17 | bracket STEP | good |
| Bracket insert positions, heights | bracket STEP | good (as designed; real install may vary) |
| K400 outline / underside profile | GrabCAD STEP + Logitech spec | good |
| Monitor shell 367.8 × 224.8 × 7.6 | VILVA Amazon listing (B0BTSFVMLV) | listing only — **measure** |
| Monitor picture offset +10 mm, port side | product photos | **estimated** |
| Port sizes | generic | **assumed** |
| USB-C charge port hole (Adafruit 4218) | Adafruit spec | good (not test-fitted) |
| `lid_panel_drop`, `base_panel_drop` | guesses | **assumed** |
| Lid wall lean 0.03/mm, floor fillet R21 | third-party case CAD (`Lid.step`) | **low** — measure |
| Lid depth 44 | HF spec (case CAD says 46.5) | **assumed** — posts work for both |
| VILVA control layout (two edges, wheel/power positions) | manual diagram | layout good, positions **rough** |

## 8. Open questions / next steps

0. **Power button + brightness wheel access** — unreachable as designed
   (5.5 mm gap, covered by the panel). Owner to choose an approach (options
   given 2026-10-06: access notch in the panel end / printed button
   extenders / rely on auto-on + software brightness). Also confirm which
   edge has the controls and where.
1. **Measure the VILVA when it arrives** — shell w × h (listing: 367.8 ×
   224.8), thickness at top and bottom edge (wedge?), picture w × h and its
   distance from the bottom/top shell edge; update `vilva15.6`. If the real
   shell is ≤ ~355 mm wide, end-wall posts and short-edge clips could return.
2. ~~K400 end-bracket clearance~~ — gone: keyboard now sits on top of the plate.
3. **Internals** — computer (e.g. SBC/mini PC), power (battery / power bank:
   owner mentioned a "battery spot" but never specified — ask before designing),
   cable routing between lid and base, hub. Ports/vent positions follow from this.
4. **Measure** `lid_panel_drop`, real port hardware; confirm the brackets can
   be installed with the plate top 16 mm below the rim (`base_panel_drop`).
5. Seam strength — lid now has only 2 seam screws and the y = 0 seam is
   glue-only. Options if it feels weak: flush nut pockets so screws can sit
   under the monitor, or a glued backing strip across the side frames.
6. ~~Repo license~~ — MIT chosen (see decision log).

## 9. Decision log

All 2026-10-05.

- Project scaffolded: OpenSCAD, config-first, lid screen panel + base
  faceplate, 2×2 lap-jointed tiles for a 256 bed.
- Printables bracket STEP parsed → base hole pattern, case R17 / 380 × 270.
  Bracket credited (owner confirmed CC BY 4.0); STEP added to `ref/`.
- Screen → portable travel monitor; `travel15.6` default; short-edge bosses 2
  per side; lid mount holes moved off seams; seam screws gained edge-inset +
  keep-outs.
- Keyboard → K400 Plus, **drop-in flush on hangers** (owner chose over
  "sits on top" and "just a hole"). Opening moved to (0, −40); base seam forced
  to y = 44; ports to y = 106; end-bracket holes beside the opening skipped.
- Plate outline set to 378 × 268 R16 (1 mm wall gap all round).
- Owner asked for bracket "inner-lip" fit checks/gauges, then **asked to remove
  them** — don't re-add.
- OpenSCAD dev build (Manifold) adopted: export ~35 min → ~10 s.
- Repo made **public**; commits use the GitHub noreply email; work lives on
  `main`.
- Licensed **MIT** (© MosheWelcher); third-party bracket STEP excluded
  (CC BY 4.0), listed in `NOTICE`.
- Keyboard mount changed: K400 now **sits flat on top of the plate**; only a
  347 × 35 mm slot for its battery hump. Hangers, the big opening and the
  hole-skipping beside it removed (all 16 bracket holes used again).
  `base_panel_drop` 10 → 16 mm so the closed lid clears the keys (~8 mm).
  Reason: simpler flat plate, possibly aluminium (heat sink) later — owner
  said **not to start aluminium work yet**.
- Panels thickened **4 → 6 mm** (lid + base; owner found 4 mm too thin):
  ~3.4× stiffer, lap halves 3 + 3 mm, lid posts now 32 mm. The base plate top
  stays 16 mm below the rim, so the brackets install 2 mm lower (tops 22 mm
  below the rim) and keyboard height / ~8 mm lid clearance are unchanged.
  Aluminium heat-sink plate discussed: ~3 mm 5052/6061 *if* done later
  (not started).
- Real K400 model added to the previews (`k400_preview()`; STEP → STL with
  gmsh into the ignored `ref/local/`). Visual check: keyboard sits flat on the
  plate, hump in the slot with ~1.4 mm front / ~1 mm rear clearance, ~11.5 mm
  of plate either side. **(Wrong — see next entry.)**
- Hump slot corrected and rounded (owner asked for rounder corners and a
  verified fit). Cross-sections of the real model through the plate showed
  the old 347 × 35 slot did **not** fit: the K400's thick back runs the full
  width (±177.4 at the plate top) and blends forward with a fillet to
  y ≈ −8.5, so the keyboard would have sat on the slot edges. Slot now from
  the model + 1 mm: `kb_hump_size = [355, 38.5]` → 357 × 40.5, R6 (owner
  chose R6 over R10, the largest that clears). Fit checked by intersecting the
  model with the plate (empty, also with 0.5 mm extra margin). Cost: the two
  middle end-bracket holes (±183, 0) are auto-skipped → 14 of 16 used; seam
  screws unchanged (9).
- **USB-C battery charge port** added (owner's pick: Adafruit 4218 round
  panel-mount extension): new port type `usbc_round` (Ø22), placed at
  (80, 106) on the port row. Only the battery *input* — the battery itself
  is still unspecified (ask before designing a bay). Seam screws unchanged.
- USB-C charge port moved to the **back-left corner** (−160, 106) at the
  owner's request ("top left" read as hinge side, left).
- **Monitor chosen: VILVA V156F1** (owner sent amazon.com/dp/B0BTSFVMLV).
  New preset `vilva15.6` = 367.8 × 224.8 × 7.6, picture offset +10 (listing +
  photos; not measured). 11 mm wider than the generic preset, so: clip bosses
  moved to the long edges only (4 + 4), the 4 end-wall lid posts dropped
  (12 → 8), monitor footprint added to the lid seam-screw keep-outs (removes
  the y = 0 seam screws — they would have pressed the nut into the monitor;
  the old 357 mm preset already overlapped by ~4 mm), and fit-check asserts
  added to `lid_panel.scad`.

2026-10-06:

- **Lid checked against the real case CAD** (owner's Apache 3800 FreeCAD/STEP
  model; `ref/apache-3800-case.md`). The monitor fits (5.5 mm per end, 22 mm
  top/bottom), but the old lid panel (381 × 269 R16) was ~1.6 mm too long with
  too-tight corners, and the lid posts ran into the wall and up to ~11 mm into
  the wall-to-floor fillet (and were 2.5 mm short of the real floor). Fixed:
  case numbers from the CAD (380 × 270, R20, depth 46.5, wall lean 0.03/mm,
  fillet R21) → panel 377.3 × 267.3 R18.6; posts 18 × 12 × 34.5, bottom cut to
  the fillet, back insert for a screw through the wall; new monitor-in-lid
  assert. Base geometry unchanged.
- **Source ranking set by the owner**: the Printables bracket STEP (seen
  installed in real cases) outranks the downloaded case CAD ("from random
  joe"). Corner radius back to **R17** (bracket; CAD said R20) → panel
  R15.6; lid depth back to the HF spec **44** (CAD said 46.5) → posts 32 mm,
  still cut for the fillet so they fit a deeper lid too. CAD-only values
  (wall lean, fillet) tagged `MEASURE`.
- VILVA manual read: controls are split over both short edges (power +
  wheel on one), not all on the right. They are not reachable once mounted —
  open question 0.
