// BASE faceplate: keyboard opening, port cutouts, vents. Screws onto the
// M3 inserts of the Printables Apache 3800 panel brackets (model 1478000).
// Top face (user side) is z = panel_t.
include <../lib/common.scad>

piece = "all";   // "all" (exploded tiles), "whole", or [i, j]

// base_L / base_W / base_R come from base_plate in config.scad.
base_n  = auto_split(base_L, base_W);
base_xs = resolve_seams(base_split_x, base_L, base_n[0]);
base_ys = resolve_seams(base_split_y, base_W, base_n[1]);

// Bracket holes that would leave a sliver next to the keyboard opening are
// skipped (that bracket insert just goes unused).
kb_hole_keepout = [kb_offset[0], kb_offset[1],
                   kb_cutout[0] + m3_csk_d + 6, kb_cutout[1] + m3_csk_d + 6];
used_mount_holes = [for (p = base_mount_holes) if (!in_rect(p, kb_hole_keepout)) p];
echo(str("Base mount holes used: ", len(used_mount_holes), " of ", len(base_mount_holes)));

// Seam screws stay out of cutouts. A bracket/hanger screw that lands on a
// seam clamps the lap itself, so seam screws near those are dropped too.
base_keepouts = concat(
    [[kb_offset[0], kb_offset[1], kb_cutout[0] + 12, kb_cutout[1] + 12]],
    [for (v = vents) [v[0], v[1], v[2] + 12, v[3] + 12]],
    point_keepouts([for (p = ports) [p[1], p[2]]], 40),
    point_keepouts(used_mount_holes),
    point_keepouts(kb_hanger_bolts())
);

module port_cut(type) {
    p = preset(type, port_types);
    w = p[0]; h = p[1]; r = p[2]; sp = p[3]; sd = p[4];
    translate([0, 0, -1]) linear_extrude(panel_t + 2) {
        if (h == 0) circle(d = w);
        else rrect(w, h, r);
        if (sp > 0) for (sx = [-sp / 2, sp / 2]) translate([sx, 0]) circle(d = sd);
    }
}

module vent_cut(v) {
    x = v[0]; y = v[1]; w = v[2]; h = v[3];
    n = floor((w - vent_slot_w) / vent_slot_pitch) + 1;
    span = (n - 1) * vent_slot_pitch;
    translate([x - span / 2, y, -1])
        for (k = [0 : n - 1])
            translate([k * vent_slot_pitch, 0, 0]) linear_extrude(panel_t + 2) rrect(vent_slot_w, h, vent_slot_w / 2);
}

module base_faceplate_whole() {
    difference() {
        plate(base_L, base_W, base_R, panel_t);
        translate(concat(kb_offset, [-1])) linear_extrude(panel_t + 2) rrect(kb_cutout[0], kb_cutout[1], kb_corner_r);
        for (p = ports) translate([p[1], p[2], 0]) rotate(p[3]) port_cut(p[0]);
        for (v = vents) vent_cut(v);
        for (p = used_mount_holes) translate(p) m3_csk(panel_t);
        for (p = kb_hanger_bolts()) translate(p) m3_csk(panel_t);
        for (p = seam_holes(base_xs, base_ys, base_L, base_W, base_keepouts)) translate(p) seam_screw(panel_t);
    }
}

tiled(piece, base_xs, base_ys, panel_t) base_faceplate_whole();
