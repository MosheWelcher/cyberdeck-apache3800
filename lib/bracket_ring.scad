// Printables "Apache 3800 Panel Bracket" ring (JohnS - N0CTL, CC BY 4.0),
// approximated from ref/apache-3800-panel-bracket-v8.step for fit checks.
// Gamma profile: a 12 mm-wide lip on top (plate rests on it, M3 inserts),
// then a 5 mm strip down the case wall. z = 0 is the lip top (plate underside).
// Values live here because they describe the bracket, not our design.

bracket_outer   = [380, 270, 17];   // at the case wall: [x, y, corner_r]
bracket_lip     = [356, 246, 5];    // lip inner face (±178, ±123), inner corner r
bracket_strip   = [370, 260, 15];   // wall-strip inner face (±185, ±130)
bracket_lip_t   = 7;
bracket_h       = 17;

module bracket_ring(holes = []) {
    difference() {
        union() {
            translate([0, 0, -bracket_lip_t]) linear_extrude(bracket_lip_t) difference() {
                rrect(bracket_outer[0], bracket_outer[1], bracket_outer[2]);
                rrect(bracket_lip[0], bracket_lip[1], bracket_lip[2]);
            }
            translate([0, 0, -bracket_h]) linear_extrude(bracket_h - bracket_lip_t + 0.01) difference() {
                rrect(bracket_outer[0], bracket_outer[1], bracket_outer[2]);
                rrect(bracket_strip[0], bracket_strip[1], bracket_strip[2]);
            }
        }
        for (p = holes) translate([p[0], p[1], -bracket_lip_t - 1]) cylinder(d = 4, h = bracket_lip_t + 2);
    }
}
