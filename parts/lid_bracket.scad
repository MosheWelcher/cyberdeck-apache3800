// Lid brackets: blocks that stand on the lid floor and carry an M3 insert
// on top for the screen panel — the lid-side counterpart of the Printables
// base bracket. Fix each to the lid with a screw from outside (bottom
// insert) or with VHB / epoxy. One per entry in lid_mount_holes.
include <../lib/common.scad>

bracket_h = lid_depth - lid_panel_drop - panel_t;   // lid floor -> panel back

module lid_bracket() {
    l = lid_bracket_size[0]; w = lid_bracket_size[1];
    difference() {
        translate([-l / 2, -w / 2, 0]) cube([l, w, bracket_h]);
        // top insert (panel screw)
        translate([0, 0, bracket_h - m3_insert_depth]) cylinder(d = m3_insert_d, h = m3_insert_depth + 1);
        // bottom insert (screw through the lid skin)
        translate([0, 0, -1]) cylinder(d = m3_insert_d, h = m3_insert_depth + 1);
        // lightening core between the two inserts
        if (bracket_h > 2 * m3_insert_depth + 4)
            translate([0, 0, m3_insert_depth + 2])
                cylinder(d = m3_clear_d, h = bracket_h - 2 * m3_insert_depth - 4);
    }
}

for (k = [0 : len(lid_mount_holes) - 1])
    translate([(k % 4) * (lid_bracket_size[0] + 6), floor(k / 4) * (lid_bracket_size[1] + 6), 0])
        lid_bracket();
