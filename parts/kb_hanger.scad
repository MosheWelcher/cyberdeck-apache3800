// Keyboard hangers: bolt under the base faceplate at the edge of the keyboard
// opening; a foot reaches under the keyboard so it sits flush with the plate.
// Front hangers support the flat underside, back hangers the battery hump.
// Fasten with M3 countersunk screws from the plate top + nut under the flange.
//
// Profile (side view, v = outward from the opening, z = down from plate):
//      opening edge
//   foot |leg| flange
//          ___________
//         |  |  o     |   <- plate underside, bolt at kb_bolt_v
//         |  |‾‾‾‾‾‾‾‾
//    _____|  |
//   |________|            <- ledge top at kb_ledge_z
//
// Modelled lying on the profile face so it prints without supports.
include <../lib/common.scad>

module kb_hanger_profile(depth, foot) {
    t = kb_hanger_t;
    union() {
        translate([0, -t]) square([kb_hanger_flange, t]);          // flange
        translate([0, -depth]) square([t, depth]);                 // leg
        translate([-foot, -depth - t]) square([foot + t, t]);      // foot
    }
}

module kb_hanger(depth, foot) {
    w = kb_hanger_w;
    difference() {
        linear_extrude(w) kb_hanger_profile(depth, foot);
        // bolt hole through the flange, nut sits under it
        translate([kb_bolt_v, 1, w / 2]) rotate([90, 0, 0]) cylinder(d = m3_clear_d, h = kb_hanger_t + 2);
    }
}

n = len(kb_hanger_x);
for (k = [0 : n - 1]) {
    translate([0, k * (kb_ledge_z[0] + 12), 0]) kb_hanger(kb_ledge_z[0], kb_hanger_foot[0]);
    translate([40, k * (kb_ledge_z[1] + 12), 0]) kb_hanger(kb_ledge_z[1], kb_hanger_foot[1]);
}
echo(str("KB hangers: ", n, " front (ledge ", kb_ledge_z[0], " mm), ", n, " back (ledge ", kb_ledge_z[1], " mm)"));
