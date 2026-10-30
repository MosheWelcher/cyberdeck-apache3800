# Archive

Retired designs, kept for reference. Not exported by `scripts/export.sh`.

| Folder | What | Why retired |
|---|---|---|
| `base_faceplate/` | 3D-printed base faceplate: 6 mm, 2 × 2 lap-jointed tiles (`.scad`, STLs, preview). | 2026-10-30: base plate is now one flat aluminium sheet (`parts/base_plate_metal.scad`, `cut/`). The owner has no 3D printer and JLC3DP refused it in ABS (6 mm is under their FDM minimum part size). |

The archived `.scad` still renders (it shares the cutouts in `lib/common.scad`
with the aluminium plate), e.g.
`openscad --backend=manifold -D 'piece=[0,1]' -o out.stl archive/base_faceplate/base_faceplate.scad`.
Its STLs are a snapshot from when it was archived and won't follow later
config changes.
