# Apache 3800 case — CAD measurements

Source: "Apache 3800 Weatherproof Case from Harbor Freight" CAD model
(FreeCAD + STEP: `Lid.step`, `Bottom.step`, `Handle.step`,
`3800 Case Assembly.step`), downloaded by the owner as
`apache-3800-weatherproof-case-from-harbor-freight-1.snapshot.4.zip`
(GrabCAD-style snapshot). **Not committed** — no redistribution rights
checked; the owner keeps the zip in Downloads. Only measurements are used.

How it was measured (2026-10-06): `Lid.step` meshed with gmsh (lid shell =
volume 7; volume 4 is the gasket, 3/6 the latches, 1/8 hinge bits), then sliced
with planes in a small Python script.

## Lid (CAD frame = deck frame: rim top z = 0, opening up, origin = centre)

| Feature | Value |
|---|---|
| Inside at the rim (z −1) | x ±189.97, y ±134.97 → **379.9 × 269.9** |
| Inside at z −12 (panel back) | 379.4 × 269.4 |
| Inside at z −20 (monitor back) | 379.0 × 269.0 |
| Inside at z −28 | 378.4 × 268.4 → wall lean ≈ **0.03 mm per mm** |
| Inside corner radius (plan) | **R20** (fit error < 0.03 mm) |
| Inside floor | **z −46.5** (outside skin −52, feet/ribs to −54.8) |
| Wall-to-floor fillet | ≈ **R21**; wall is 1 mm in at z −32, 5.7 at −40, 10.7 at −44, 16 at −46 |
| Gasket groove | in the top of the wall, x 193.8…201.4 / y 138.8…146.4, 8 deep — outside the cavity, no lip into it |
| Wall thickness (z −20) | 5.5 mm |
| Interior features | none (no bosses or ribs inside the cavity) |

Harbor Freight's spec (383 × 271, lid 1.75" = 44.5) is close but not exact;
`config.scad` now uses the CAD numbers for the lid.

Not yet checked against this model: the base (`Bottom.step`) — the base plate
is sized from the Printables bracket STEP (380 × 270 R17 at bracket height).
