// Stone Badge (Hoenn / Emerald)
// Built axis-aligned: two overlapping squares with a diagonal strip cut
// between them (leaving a bridge in the middle), then rotated 45 for
// display. Measured from the sprite.
// Units: mm. Badge lies flat in XY, front face up. ~40mm wide, 37.5mm tall.

$fn = 32;

sq        = 22.6;         // square side (= diamond half-diagonal 16 * sqrt2)
sq_c      = [4.3, -1.8];  // square center offset (mirrored for the other)
gap_w     = 6;            // width of the diagonal cut strip
bridge_l  = 22;           // length of the center bridge left in the cut
bridge_w  = 6.4;          // slightly wider than gap to fuse cleanly
base_t    = 3;            // main slab thickness
facet_t   = 1.5;          // bevel rise height
facet_in  = 2.5;          // bevel inset from edge (slope = facet_t/facet_in)
bar_l     = 17;           // dark bar on top, runs along the cut diagonal
bar_w     = 6.5;
bar_t     = 1.0;          // bar rise above slab (kept below the facets)
bar_in    = 1.0;          // bar bevel inset
bar_gap   = 0.5;          // reveal gap around the bar in its channel
groove_in = 0.8;          // facet outline groove: inset from plateau edge
groove_w  = 0.6;
groove_d  = 0.5;

C_GOLD = [0.85, 0.72, 0.35];
C_PINK = [0.80, 0.45, 0.50];
C_BAR  = [0.45, 0.38, 0.15];

// square pyramid, base faces parallel to the XY axes (for mitred bevels)
module pyramid(r, h) rotate(45) cylinder(r1 = r, r2 = 0.01, h = h, $fn = 4);

// the diagonal cut, minus the middle where the bridge bridges it
module notches2d() rotate(45) {
    translate([bridge_l / 2, -gap_w / 2]) square([50, gap_w]);
    translate([-bridge_l / 2 - 50, -gap_w / 2]) square([50, gap_w]);
}

module arrows2d() difference() {
    for (m = [0, 1]) mirror([m, 0]) mirror([0, m])
        translate(sq_c) square(sq, center = true);
    rotate(45) square([200, gap_w], center = true);  // full diagonal cut
}

module bridge2d() rotate(45) square([bridge_l, bridge_w], center = true);

module silhouette2d() { arrows2d(); bridge2d(); }

module bar2d() square([bar_l, bar_w], center = true);

module stone_badge() {
    color(C_GOLD) difference() {
        union() {
            linear_extrude(base_t) arrows2d();
            // beveled edges rising to a flat inner facet: minkowski of the
            // inset face with a 4-sided pyramid whose faces are parallel to
            // the square edges -> flat slopes, sharp mitred corners
            translate([0, 0, base_t]) minkowski() {
                linear_extrude(0.01) offset(-facet_in) arrows2d();
                pyramid(facet_in, facet_t);
            }
        }
        // recessed channel where the bar crosses the arrows
        translate([0, 0, base_t]) linear_extrude(10) offset(bar_gap) bar2d();
        // engraved inner outline on the facet plateaus
        translate([0, 0, base_t + facet_t - groove_d]) linear_extrude(10)
            difference() {
                offset(-facet_in - groove_in) arrows2d();
                offset(-facet_in - groove_in - groove_w) arrows2d();
            }
    }

    color(C_PINK) linear_extrude(base_t) bridge2d();

    // dark bar along the cut diagonal: lower than the facets, beveled too
    color(C_BAR) translate([0, 0, base_t])
        minkowski() {
            linear_extrude(0.01) offset(-bar_in) bar2d();
            pyramid(bar_in, bar_t);
        }
}

// display orientation: squares become the diamonds of the sprite
module stone_badge_display() rotate(45) stone_badge();

stone_badge_display();
