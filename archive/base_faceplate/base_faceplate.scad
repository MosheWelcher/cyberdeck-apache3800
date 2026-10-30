// ARCHIVED 2026-10-30 — replaced by the aluminium plate (parts/base_plate_metal.scad).
// Kept working for reference; not exported by scripts/export.sh. Render by hand:
//   openscad --backend=manifold -D 'piece=[0,1]' -o out.stl archive/base_faceplate/base_faceplate.scad
//
// BASE faceplate (3D-printed version): the K400 Plus sits flat on top; its
// battery hump drops through a slot. Port cutouts, vents. Screws onto the M3
// inserts of the Printables Apache 3800 panel brackets (model 1478000).
// Cutout shapes are shared with the aluminium plate (lib/common.scad).
// Top face (user side) is z = panel_t.
include <../../lib/common.scad>

piece = "all";   // "all" (exploded tiles), "whole", or [i, j]

// base_L / base_W / base_R come from base_plate in config.scad.
base_n  = auto_split(base_L, base_W);
base_xs = resolve_seams(base_split_x, base_L, base_n[0]);
base_ys = resolve_seams(base_split_y, base_W, base_n[1]);

echo(str("Base mount holes used: ", len(used_mount_holes), " of ", len(base_mount_holes)));

// Seam screws stay out of cutouts. A bracket screw that lands on a seam
// clamps the lap itself, so seam screws near those are dropped too.
base_keepouts = concat(
    [[kb_slot_c[0], kb_slot_c[1], kb_slot[0] + 12, kb_slot[1] + 12]],
    [for (v = vents) [v[0], v[1], v[2] + 12, v[3] + 12]],
    point_keepouts([for (p = ports) [p[1], p[2]]], 40),
    point_keepouts(used_mount_holes)
);

module base_faceplate_whole() {
    difference() {
        plate(base_L, base_W, base_R, panel_t);
        translate([0, 0, -1]) linear_extrude(panel_t + 2) base_cutouts_2d();
        for (p = used_mount_holes) translate(p) m3_csk(panel_t);
        for (p = seam_holes(base_xs, base_ys, base_L, base_W, base_keepouts)) translate(p) seam_screw(panel_t);
    }
}

tiled(piece, base_xs, base_ys, panel_t) base_faceplate_whole();
