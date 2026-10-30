// BASE plate, aluminium version: one flat sheet (base_metal_t thick), no
// tiles. Same keyboard slot / ports / vents as the printed faceplate, plain
// M3 clearance holes onto the Printables bracket inserts.
// 2D part — scripts/export.sh writes cut/base_plate.svg (Cricut mock-up,
// 1:1 mm) and, via scripts/cut_files.py, a clean cut/base_plate.dxf + .step
// for the cutting service (OpenSCAD's own DXF is rejected by strict quoters).
include <../lib/common.scad>

echo(str("BASE_T ", base_metal_t));   // parsed by scripts/export.sh for the STEP thickness

echo(str("Base mount holes used: ", len(used_mount_holes), " of ", len(base_mount_holes)));
echo(str("Mounting: plate top ", base_panel_drop_in, " in below the rim; bracket tops ",
          base_bracket_drop / 25.4, " in (", base_bracket_drop, " mm) below the rim"));
echo(str("Base plate ", base_L, " x ", base_W, " mm (", base_L / 25.4, " x ", base_W / 25.4, " in)"));

base_plate_2d();
