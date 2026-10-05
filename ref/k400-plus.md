# Logitech K400 Plus — extracted data

Sources:
- Logitech spec: 354.3 × 139.9 × 23.5 mm, 390 g.
- GrabCAD model **"LOGITECH K400 PLUS"** by Tomáš Stroka (2018),
  https://grabcad.com/library/logitech-k400-plus-2 (`Logitech_K400_PLUS.stp`).
  Not redistributed here (GrabCAD terms) — download it from GrabCAD.

Measured from the STEP vertices (model axes: X width, Y thickness, Z depth):

| Feature | Value |
|---|---|
| Outline at widest shell edge | 355 × 140 mm |
| Shell edge band (full width) | 2–7 mm below the frame top |
| Frame top → key tops | keys stand ~2 mm proud |
| Frame top → flat underside | 12 mm (front ~105 mm of depth) |
| Battery hump (rear) | 20 mm below frame top, ±168.5 mm wide, rear ~26 mm |
| Touchpad | right side, ~X 83…165 |

Hump footprint through the plate (used for the plate slot) — from horizontal
cross-sections of the STL (`ref/local/k400_plus.stl`) placed on the plate,
depth measured below the flat underside:

| Depth | Width | Front edge, from the back edge |
|---|---|---|
| 0.1 mm | ±177.4 (full width) | 38.3 mm |
| 0.5 mm | ±177.4 | 36.0 mm |
| 3 mm | ±176.6 | 32.3 mm |
| 5.9 mm | ±174.3 | 30.3 mm |

The thick back runs the full width and blends into the underside with a
large fillet; its back corners are R≈15 in plan. (An earlier reading from
the STEP vertices, ±172.5 × 33 mm, was too small; the slot built on it did
not fit.) Config: `kb_hump_size = [355, 38.5]`.

The keyboard sits on top of the base plate; only the hump passes through
(`kb_hump_size`, `kb_slot_clear` in config.scad).
