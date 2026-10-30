// BASE plate, aluminium version: one flat sheet (base_metal_t thick), no
// tiles. Same keyboard slot / ports / vents as the printed faceplate, plain
// M3 clearance holes onto the Printables bracket inserts.
// 2D part — export as DXF (cutting service) or SVG (Cricut mock-up, 1:1 mm):
//   openscad -o cut/base_plate.dxf parts/base_plate_metal.scad
//   openscad -o cut/base_plate.svg parts/base_plate_metal.scad
include <../lib/common.scad>

echo(str("Base mount holes used: ", len(used_mount_holes), " of ", len(base_mount_holes)));
echo(str("Base plate ", base_L, " x ", base_W, " mm (", base_L / 25.4, " x ", base_W / 25.4, " in)"));

base_plate_2d();
