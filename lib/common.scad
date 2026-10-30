// Shared helpers. Parts do: include <../lib/common.scad>
include <../config.scad>

BIG = 2000;

function preset(name, table) = table[search([name], table)[0]][1];

// ---------- 2D / basic solids ----------
module rrect(l, w, r) {
    r2 = max(min(r, l/2 - 0.01, w/2 - 0.01), 0.01);
    offset(r = r2) square([l - 2*r2, w - 2*r2], center = true);
}

module plate(l, w, r, t) linear_extrude(t) rrect(l, w, r);

// Countersunk M3 through-hole, head on the top face (z = t).
module m3_csk(t) {
    h = (m3_csk_d - m3_clear_d) / 2;
    translate([0, 0, -1]) cylinder(d = m3_clear_d, h = t + 2);
    translate([0, 0, t - h]) cylinder(d1 = m3_clear_d, d2 = m3_csk_d, h = h + 0.01);
    translate([0, 0, t]) cylinder(d = m3_csk_d, h = 1);
}

// ---------- Base faceplate outline ----------
base_L = base_plate[0];
base_W = base_plate[1];
base_R = base_plate[2];

// ---------- Keyboard (sits on top) + battery-hump slot ----------
kb_back_y = kb_offset[1] + kb_size[1] / 2;          // keyboard back edge (hump side)
kb_slot   = [kb_hump_size[0] + 2 * kb_slot_clear, kb_hump_size[1] + 2 * kb_slot_clear];
kb_slot_c = [kb_offset[0], kb_back_y - kb_hump_size[1] / 2];   // slot centre

// ---------- Base plate cutouts (2D: aluminium plate + archived printed faceplate) ----------
// Bracket holes that would leave a sliver next to the hump slot are skipped
// (that bracket insert just goes unused). With the default full-width slot the
// two middle end-bracket holes (±183, 0) are skipped.
kb_hole_keepout = [kb_slot_c[0], kb_slot_c[1], kb_slot[0] + m3_csk_d + 6, kb_slot[1] + m3_csk_d + 6];
used_mount_holes = [for (p = base_mount_holes) if (!in_rect(p, kb_hole_keepout)) p];

module port_cut_2d(type) {
    p = preset(type, port_types);
    w = p[0]; h = p[1]; r = p[2]; sp = p[3]; sd = p[4];
    if (h == 0) circle(d = w);
    else rrect(w, h, r);
    if (sp > 0) for (sx = [-sp / 2, sp / 2]) translate([sx, 0]) circle(d = sd);
}

module vent_cut_2d(v) {
    x = v[0]; y = v[1]; w = v[2]; h = v[3];
    n = floor((w - vent_slot_w) / vent_slot_pitch) + 1;
    span = (n - 1) * vent_slot_pitch;
    translate([x - span / 2, y])
        for (k = [0 : n - 1])
            translate([k * vent_slot_pitch, 0]) rrect(vent_slot_w, h, vent_slot_w / 2);
}

// Every through-cut except the bracket mount holes (the printed plate
// countersinks those; the aluminium plate uses plain clearance holes).
module base_cutouts_2d() {
    translate(kb_slot_c) rrect(kb_slot[0], kb_slot[1], kb_slot_r);
    for (p = ports) translate([p[1], p[2]]) rotate(p[3]) port_cut_2d(p[0]);
    for (v = vents) vent_cut_2d(v);
}

// Aluminium base plate: outline minus every cut, M3 clearance mount holes.
module base_plate_2d() {
    difference() {
        rrect(base_L, base_W, base_R);
        base_cutouts_2d();
        for (p = used_mount_holes) translate(p) circle(d = m3_clear_d);
    }
}

// K400 for previews, positioned with its flat underside on z = 0 (= plate top).
// Real model if kb_model_stl is set (rotate maps model X,Y,Z -> deck X,-Z,Y so the
// hump faces +Y), otherwise a box stand-in from the measured profile.
module k400_preview() {
    if (kb_model_stl != "")
        color([0.15, 0.15, 0.17])
            translate([kb_offset[0], kb_offset[1], -kb_model_underside])
                rotate([90, 0, 0]) import(str("../", kb_model_stl));
    else {
        color([0.12, 0.12, 0.12]) {
            translate(concat(kb_offset, [0])) linear_extrude(kb_floor_depth) rrect(kb_size[0], kb_size[1], 3);
            translate([kb_offset[0], kb_back_y - kb_hump_size[1] / 2, -(kb_hump_depth - kb_floor_depth)])
                linear_extrude(kb_hump_depth - kb_floor_depth + 0.01) rrect(kb_hump_size[0], kb_hump_size[1], 3);
        }
        color([0.3, 0.3, 0.3]) translate([kb_offset[0], kb_offset[1], kb_floor_depth])
            linear_extrude(2) translate([-50, 0]) rrect(240, 110, 2);
    }
}

// ---------- Lid posts (stand on the lid floor fillet, hug a wall) ----------
// Local frame: X along the wall, +Y toward the wall, z = 0 at the lid floor.
lid_post_h = lid_depth - lid_panel_drop - panel_t;   // lid floor -> panel back

module lid_post() {
    l = lid_bracket_size[0]; w = lid_bracket_size[1];
    R = lid_fillet_r;
    yc = w / 2 + lid_post_gap - R;                     // floor-fillet centre (Y, Z = R)
    side_z = (R + lid_post_h - m3_insert_depth) / 2;   // wall-screw insert: between fillet top and top insert
    difference() {
        translate([-l / 2, -w / 2, 0]) cube([l, w, lid_post_h]);
        // the lid's rounded wall-to-floor corner (post sits on it)
        difference() {
            translate([-l, yc, -1]) cube([2 * l, R + w, R + 1]);
            translate([-l, yc, R]) rotate([0, 90, 0]) cylinder(r = R - lid_post_gap, h = 2 * l, $fn = 96);
        }
        // top insert (panel screw)
        translate([0, 0, lid_post_h - m3_insert_depth]) cylinder(d = m3_insert_d, h = m3_insert_depth + 1);
        // back insert (screw through the lid wall)
        translate([0, w / 2 + 1, side_z]) rotate([90, 0, 0]) cylinder(d = m3_insert_d, h = m3_insert_depth + 1);
    }
}

// Rotation that turns a post at hole p to face its nearest wall.
function lid_post_rot(p) = abs(p[1]) / case_in_w > abs(p[0]) / case_in_l
    ? (p[1] > 0 ? 0 : 180)
    : (p[0] > 0 ? -90 : 90);

// ---------- Splitting oversized panels into lap-jointed tiles ----------
// Seams evenly spaced so each tile (+ margin) fits the bed.
function n_tiles(len, axis_bed) = max(1, ceil(len / (axis_bed - bed_margin)));
function seams(len, n) = n <= 1 ? [] : [for (k = [1 : n - 1]) -len/2 + k * len / n];

// Pick the bed orientation that needs fewer tiles.
function auto_split(l, w) =
    let(a = [n_tiles(l, bed[0]), n_tiles(w, bed[1])],
        b = [n_tiles(l, bed[1]), n_tiles(w, bed[0])])
    (a[0] * a[1] <= b[0] * b[1]) ? a : b;

function resolve_seams(spec, len, n_auto) = spec == "auto" ? seams(len, n_auto) : spec;

// Range of tile k along one axis. s shifts the seams (+lap/2 for the back
// half, -lap/2 for the front half) so neighbours overlap as a half-lap.
function lo(b, k, s) = k == 0 ? -BIG : b[k - 1] + s;
function hi(b, k, s) = k == len(b) ? BIG : b[k] + s;

module tile_mask(xs, ys, i, j, t) {
    // [z_from, z_to, seam_shift]
    for (layer = [[-BIG/2, t/2, lap_w/2], [t/2, BIG/2, -lap_w/2]]) {
        s = layer[2];
        x0 = lo(xs, i, s); x1 = hi(xs, i, s);
        y0 = lo(ys, j, s); y1 = hi(ys, j, s);
        translate([x0, y0, layer[0]]) cube([x1 - x0, y1 - y0, layer[1] - layer[0]]);
    }
}

// Evenly spaced points along a seam of length len, always including one
// seam_edge_inset from each panel edge (narrow bezels still get screwed).
function seam_line(len) =
    let(span = len - 2 * seam_edge_inset, n = max(1, round(span / seam_hole_pitch)))
    [for (k = [0 : n]) -span / 2 + k * span / n];

function in_rect(p, r) = abs(p[0] - r[0]) < r[2] / 2 && abs(p[1] - r[1]) < r[3] / 2;
function in_any(p, rects) = len([for (r = rects) if (in_rect(p, r)) 1]) > 0;

// Keep-out box around each point (e.g. mount holes): [cx, cy, size, size].
function point_keepouts(pts, size = 16) = [for (p = pts) [p[0], p[1], size, size]];

// Screw positions along every seam (centre of the lap band), minus any
// that fall in a keep-out rect [cx, cy, w, h] (windows, cutouts, mounts).
function seam_holes(xs, ys, l, w, keep = []) = [
    for (p = concat([for (x = xs) for (y = seam_line(w)) [x, y]],
                    [for (y = ys) for (x = seam_line(l)) [x, y]]))
        if (!in_any(p, keep)) p
];

// Seam hardware: countersunk M3 from the front, hex-nut pocket on the back.
module seam_screw(t) {
    m3_csk(t);
    translate([0, 0, -1]) rotate(30) cylinder(d = m3_nut_af / cos(30), h = 1 + 1.2, $fn = 6);
}

// Render one tile [i, j], every tile exploded ("all"), or the unsplit part
// ("whole"). children(0) = the whole panel solid.
module tiled(piece, xs, ys, t, gap = 15) {
    nx = len(xs) + 1; ny = len(ys) + 1;
    echo(str("TILES ", nx, " ", ny));
    if (piece == "whole") children();
    else if (piece == "all")
        for (i = [0 : nx - 1], j = [0 : ny - 1])
            translate([i * gap, j * gap, 0])
                intersection() { children(); tile_mask(xs, ys, i, j, t); }
    else
        intersection() { children(); tile_mask(xs, ys, piece[0], piece[1], t); }
}
