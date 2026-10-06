// Lid posts: blocks that stand on the lid's wall-to-floor fillet against a
// long wall and carry an M3 insert on top for the screen panel — the lid-side
// counterpart of the Printables base bracket. Shape: lid_post() in
// lib/common.scad. Fix each with a screw through the lid wall into the back
// insert, and/or VHB / epoxy on the back face. Screw the panel onto the
// posts first, then fix the posts, so they end up at the right height.
// One per entry in lid_mount_holes. Print standing up (top insert up).
include <../lib/common.scad>

for (k = [0 : len(lid_mount_holes) - 1])
    translate([(k % 4) * (lid_bracket_size[0] + 6), floor(k / 4) * (lid_bracket_size[1] + 6), 0])
        lid_post();
