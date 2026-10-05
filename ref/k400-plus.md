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

Hump footprint where it meets the flat underside (used for the plate slot):
±172.5 mm wide, from the back edge forward 33 mm (model z −70 … −37.4);
deeper than 4 mm below the underside it narrows to ±168.9 × 31 mm.

The keyboard sits on top of the base plate; only the hump passes through
(`kb_hump_size`, `kb_slot_clear` in config.scad).
