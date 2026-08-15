// Keg button clip, asymmetric. Snaps sideways onto the button shaft and
// sits under the cap. Button: shaft d10.95, cap d21, height 7.35.
//
// Anti-leverage shape: the collar around the shaft (15mm od) hides
// entirely under the 21mm cap, so the ONLY thing sticking out is one
// rounded paddle opposite the mouth. With a single arm there is no
// opposing lever: bumping a neighboring component can transmit at most
// a direct push, never an amplified torque. Units: mm.

$fn = 96;

shaft_d = 10.95;
bore_d  = shaft_d;  // no margin: tight grip on the shaft
bore_r  = bore_d / 2;
height  = 7.35;     // exactly the button height

throat_w = 9.3;     // opening at the mouth; < shaft_d so the arms snap
wall     = 2.0;     // collar thickness; the two side arcs between the
                    // paddle root and the lips are the springs
neck_r   = 2.8;     // stalk half-width at the collar
paddle_r = 4;       // rounded paddle tip; taper widens toward it so
                    // pulling fingers wedge on instead of slipping off
paddle_y = -11;     // tip center; tip reaches paddle_y - paddle_r.
                    // short on purpose: fingers fit under the cap, the
                    // paddle only needs enough surface to pinch

lip_y     = sqrt(bore_r*bore_r - throat_w*throat_w/4);
collar_or = bore_r + wall;

module body2d() {
    difference() {
        union() {
            circle(collar_or);
            // the one arm: tapered paddle on a narrow neck at the collar
            // bottom, so the side arcs stay free to flex during snap-on
            hull() {
                translate([0, -4.5]) circle(neck_r);
                translate([0, paddle_y]) circle(paddle_r);
            }
        }
        circle(bore_r);
        // mouth: throat at the lips, flared lead-in
        polygon([[-throat_w/2, lip_y], [throat_w/2, lip_y],
                 [6.6, collar_or + 1], [-6.6, collar_or + 1]]);
    }
}

// self-checks against the button's real dimensions
assert(height == 7.35, "height must be exactly the button height");
assert(2*collar_or < 21, "collar must hide under the 21 cap");
assert(-(paddle_y - paddle_r) > 21/2 + 3, "paddle must offer grab surface past the cap");
assert(throat_w < bore_d, "throat must be narrower than bore to latch");

linear_extrude(height) body2d();
