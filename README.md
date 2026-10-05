# Apache 3800 Cyberdeck — panels CAD

Parametric OpenSCAD panels for a cyberdeck built into a Harbor Freight
**Apache 3800** case (item 63927).

- **Lid:** screen panel + screen clips + lid brackets (this repo).
- **Base:** keyboard / ports faceplate that screws onto the
  [Apache 3800 Panel Bracket](https://www.printables.com/model/1478000-apache-3800-panel-bracket)
  by JohnS - N0CTL (print that ring separately; its hole pattern is built in here).

![assembly](img/assembly.png)

## Layout

| File | What it is |
|---|---|
| `config.scad` | **Every dimension lives here.** Case, screen preset, ports, keyboard, printer bed, fasteners. |
| `parts/lid_panel.scad` | Screen bezel: window with 45° bevel, retainer bosses on the back, countersunk mount holes. |
| `parts/screen_retainer.scad` | Flat clips that screw onto the bosses and clamp the screen. |
| `parts/lid_bracket.scad` | Posts for the lid floor (insert top + bottom) — lid-side equivalent of the Printables bracket. |
| `parts/base_faceplate.scad` | Keyboard opening, port cutouts, vent grille, holes matching the Printables bracket ring. |
| `assembly.scad` | Fit-check: case opened flat with both panels. Preview only. |
| `scripts/export.sh` | Renders every part to `stl/` and previews to `img/`. |
| `ref/` | Notes on reference dimensions. |

Coordinates: origin at the centre of the case opening; **−Y = handle (front)**,
**+Y = hinge (back)**; panel front face is the top (+Z).

## Workflow

1. Edit `config.scad` (screen preset, port list, keyboard size, `bed`).
2. Open `assembly.scad` in OpenSCAD, press **F5** to fit-check.
3. Export STLs from Git Bash in the repo root:
   ```bash
   scripts/export.sh
   ```
   (~30 min on the full set — CGAL renders are slow.) Single part:
   `openscad -D 'piece=[0,1]' -o out.stl parts/lid_panel.scad`.

## Splitting for the printer

The panels are ~380 × 270 mm. If they exceed `bed` (default 256 × 256) they are
cut into tiles with a **half-lap joint**: the back half of one tile overlaps the
front half of its neighbour across a `lap_w` band. Each seam gets M3 countersunk
screws (front) + hex-nut pockets (back) every `seam_hole_pitch` mm — glue the lap
too. Force a layout with e.g. `lid_split_x = [0]; lid_split_y = [];`, or set
both to `[]` for a single piece on a big bed. Tiles export as
`<part>_tile_<i>_<j>.stl`.

## What's measured vs. assumed

**From the Printables bracket STEP (v8):**
- Case interior at bracket height: **380 × 270 mm, R17 corners.**
- 16 M3 insert positions of the 4-piece bracket ring → `base_mount_holes`.
- Bracket height 17 mm.

**From Harbor Freight spec:** inside 383 × 271 mm at the rim, lid depth 44 mm,
base depth 108 mm.

**MEASURE before printing** (tagged in `config.scad`):
- `lid_panel_drop` — how far below the lid rim the screen panel sits (gasket lip).
- `base_panel_drop` — where your brackets end up below the base rim.
- Screen preset dimensions — all approximate; caliper your panel + driver board.
- Port type sizes — generic panel-mount extensions vary.
- `kb_cutout` — your keyboard + ~1 mm clearance.

## Screen: portable "travel" monitor

Default `screen = "travel15.6"` (also `"travel14"`). A travel monitor is a whole
unit in its own ~9 mm shell, so the panel frames its glass and the clips clamp
the shell edge — no teardown needed. To fit yours, measure and edit its preset:

- outer shell width × height × thickness (`module_w/h/t`)
- visible picture area width × height (`active_w/h`)
- picture-centre offset: travel monitors have a thicker bottom chin, so the
  picture sits **higher** than the shell centre (`active_off_y`, ~+5–10 mm)

Things to plan for: its USB-C / mini-HDMI ports and OSD buttons are on the shell
edges, which end up behind the panel — check that the cable plugs (often
right-angle ones are needed) clear the lid brackets, and set brightness before
mounting.

## Credits

- **Apache 3800 Panel Bracket** by JohnS - N0CTL —
  [Printables 1478000](https://www.printables.com/model/1478000-apache-3800-panel-bracket),
  [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). Original STEP included
  unmodified in `ref/`; `base_mount_holes` and the case interior/corner dimensions
  are derived from it. See `ref/printables-bracket.md`.

## Hardware

- M3 heat-set inserts (M3 × 5.7, 4.0 mm hole)
- M3 countersunk screws: 8–10 mm (panels), M3 hex nuts (seams)
- Foam tape for `screen_shim`
- Print: PETG / ABS / ASA-GF, 4 walls, 4 top/bottom, 30–45 % infill.
  Print panels front-face-down for a clean visible side.
