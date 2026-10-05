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
| Screen | **Portable "travel" monitor, 15.6"**, USB-C class, in its own ~9 mm shell | exact model **unknown** — preset `travel15.6` is a typical unit |
| Keyboard | **Logitech K400 Plus** (keyboard + touchpad, wireless, 2×AA) | decided; modelled from a STEP |
| Base mounting | **Printables 1478000 "Apache 3800 Panel Bracket"** (4-piece ring, M3 heat-set inserts) | owner has the STEP + a Bambu `.3mf` for it |
| Printer | **Bambu X1C**, 256 × 256 bed | → panels split into 2 × 2 tiles |
| Computer / battery / I/O boards | **not chosen** | don't assume; ask |

## 2. Case

Harbor Freight spec: inside 383 × 271 mm at the rim (15.063" × 10.688"), lid
depth 44 mm (1.75"), base depth 108 mm (4.25"). The walls taper: at bracket
height the bracket STEP gives **380 × 270 mm, R17 corners** (fillet centres
±173, ±118). Front = handle side, hinge at the back.

Unmeasured (tagged `MEASURE`): `lid_panel_drop` (how far below the lid rim the
screen panel face sits — must clear the gasket lip), `base_panel_drop` (where
the brackets end up below the base rim).

## 3. Lid — screen panel

Files: `parts/lid_panel.scad`, `parts/screen_retainer.scad`, `parts/lid_bracket.scad`.

- **Panel**: 381 × 269 mm, R16, 4 mm thick (`case_in − 2·panel_gap`).
- **Window**: active area + 0.5 mm/side = **345.2 × 194.6 mm**, centred at
  (0, +8) because travel monitors have a thicker bottom chin (picture sits
  high). 45° × 2 mm bevel on the viewing side.
- **Monitor retention**: 8 bosses on the panel back (2 per long edge at
  x = ±89.25, y = ±116; 2 per short edge at x = ±183, y = ±55.75), height =
  monitor thickness + 0.5 mm foam shim, M3 heat-set insert each. 8 flat clips
  (`screen_retainer`) screw on and overlap the monitor shell by 4 mm. Short
  edges use 2 bosses so y = 0 stays free for the tile seam.
- **Mounting**: 12 countersunk M3 holes (`lid_mount_holes`) — 4 per long wall
  at x = ±50, ±150, 2 per end wall at y = ±90 — onto **12 printed posts**
  (`lid_bracket`, 18 × 14 × **34 mm** = lid depth − drop − panel) with inserts
  top and bottom; fix posts with a screw through the lid skin or VHB/epoxy.
  Holes avoid the seams (x = 0, y = 0) and the bosses.
- The monitor's own ports/buttons end up behind the panel — right-angle cables
  likely needed; set brightness before mounting.
- **Fit**: 15.6" shell 357 × 223 sits inside the 381 × 269 panel; boss tops of
  the long edges clear the lid posts by ~1.5 mm.

Presets in `screen_presets` (all approximate): `7`, `10.1`, `13.3`, `15.6`
(bare panels) and `travel15.6`, `travel14`, `custom`. Format
`[module_w, module_h, module_t, active_w, active_h, active_off_x, active_off_y]`.

## 4. Base — keyboard / ports faceplate

Files: `parts/base_faceplate.scad`, `parts/kb_hanger.scad`.

### 4.1 Plate and the Printables bracket ring

- **Plate**: `base_plate = [378, 268, 16]` → ~1 mm gap to the 380 × 270 R17 walls
  at bracket height, 4 mm thick.
- **Bracket ring** (from `ref/apache-3800-panel-bracket-v8.step`, see
  `ref/printables-bracket.md`): four bodies — Front (x −120…120, y −135…−123),
  Back (mirror), two L-shaped end pieces wrapping the corners (x ±115…±190).
  17 mm tall; the plate rests on the 12 mm-wide top face (inner faces at
  y = ±123 and x = ±178); a 5 mm strip continues down the wall with
  horizontal Ø4 holes (screws into the case wall).
- **16 insert positions** (`base_mount_holes`): Front/Back y = ∓128 at
  x = −70, 0, 70; ends at (±140, ±128) and (±183, −85 / 0 / 85).
  **12 are used** — the four at (±183, −85) and (±183, 0) would sit ~1.5 mm
  from the keyboard opening, so the plate skips them automatically
  (`used_mount_holes`); those inserts simply stay empty.

### 4.2 Keyboard: K400 Plus, drop-in flush

Measured from the GrabCAD STEP (see `ref/k400-plus.md`):

| Feature | Value |
|---|---|
| Outline at widest shell edge | 355 × 140 mm (spec 354.3 × 139.9 × 23.5) |
| Widest edge band | 2–7 mm below the frame top |
| Keys | stand ~2 mm above the frame top |
| Flat underside | 12 mm below frame top, front ~105 mm of depth |
| Battery hump | 20 mm below frame top, rear ~26 mm, ±168.5 mm wide — faces **+Y** (hinge) |
| Touchpad | right side |

Design:
- **Opening** 357 × 142 mm (1 mm clearance), R4, centred at (0, −40) →
  y −111…+31. Pushed toward the hinge so the front hangers fit between the
  keyboard and the Printables front bracket (~1 mm to spare).
- **Flush**: keyboard frame top = plate top (`kb_top_drop = 0`); keys 2 mm proud.
  Lid clearance when closed is fine (base plate 10 mm below rim, lid panel
  6 mm below its rim).
- **Hangers** (`kb_hanger`): 4 front + 4 back at x = ±50, ±145, 16 mm wide, 3 mm
  thick, 11 mm flange under the plate, M3 countersunk screw from the top + nut
  under the flange (bolts at y = −118 and y = +38). Front ledge **8 mm** below
  the plate underside (6 mm foot), back ledge **16 mm** (8 mm foot, under the
  battery hump). Print lying on the profile face — no supports. Lift the
  keyboard out to use wirelessly / change batteries.
- ⚠ **End-bracket clearance ≈ 0.5 mm per side**: the K400's widest edge
  (±177.5) sits level with the end brackets' inner faces (±178). Owner must
  test-fit; if it binds, sand ~1 mm off the top ~8 mm of each end bracket's
  inner face between y ≈ −110 and +30.

### 4.3 Ports, vent

`ports` (type, x, y, rot) on a row at **y = 106**: 2× USB-A, USB-C, HDMI, RJ45,
12 mm and 16 mm round (switch / LED / GX16). Sizes in `port_types` are
**generic panel-mount extension guesses** — measure the real parts. One vent
grille `[110, 76, 120, 26]` (2.5 mm slots @ 6 mm) between the seam band and
the port row. Port/vent placement is placeholder until the owner picks
internals.

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
  (windows, cutouts, mount holes, bosses, hanger bolts). A mount/hanger screw
  landing in a lap band clamps it instead.
- Current layout: **lid** 2 × 2, seams x = 0 / y = 0, **4 seam screws** (sparse
  — big window; glue the laps). **Base** 2 × 2, seams x = 0 / y = 44 (forced
  behind the keyboard), **8 seam screws**; where the x = 0 seam crosses the
  front strip, the bracket screw at (0, −128) is the only fastener — glue it.
- Tiles export as `stl/<part>_tile_<i>_<j>.stl` (i along X, j along Y,
  0 = negative side). Print front-face-down for the best visible surface.

## 6. Hardware list (current design)

- M3 heat-set inserts (Ø4 hole, 5.7 mm): 8 (screen bosses) + 24 (lid posts,
  top + bottom) + 16 for the Printables brackets (12 used).
- M3 countersunk screws: 12 base mount, 12 lid mount, 8 hangers, 12 seam
  (lengths 8–10 mm; hangers/seams need nuts); 8 pan/button heads for clips;
  lid-post fixing screws if not glued.
- M3 hex nuts: 8 hangers + 12 seams.
- Foam tape (0.5 mm) for the monitor shim. Glue (e.g. CA/epoxy) for laps.

## 7. Measured vs. assumed

| Value | Source | Confidence |
|---|---|---|
| Case rim interior, depths | Harbor Freight spec | good |
| Interior at bracket height 380 × 270 R17 | bracket STEP | good |
| Bracket insert positions, heights | bracket STEP | good (as designed; real install may vary) |
| K400 outline / underside profile | GrabCAD STEP + Logitech spec | good |
| Travel monitor dimensions | typical 15.6" unit | **assumed** — needs the real model |
| Port sizes | generic | **assumed** |
| `lid_panel_drop`, `base_panel_drop` | guesses | **assumed** |
| Lid wall taper (`lid_draft_inset = 0`) | not measured | **assumed** |

## 8. Open questions / next steps

1. **Travel monitor model** — get shell w × h × t, picture w × h, and how much
   thicker the bottom bezel is; update `travel15.6` (or add a named preset).
2. **K400 end-bracket clearance** (0.5 mm/side) — test-fit result pending.
3. **Internals** — computer (e.g. SBC/mini PC), power (battery / power bank:
   owner mentioned a "battery spot" but never specified — ask before designing),
   cable routing between lid and base, hub. Ports/vent positions follow from this.
4. **Measure** `lid_panel_drop`, `base_panel_drop`, real port hardware.
5. Seam strength (lid: 4 screws) — consider more screws/glue tabs once the
   monitor is known.
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
  (CC BY 4.0), noted in `LICENSE`.
