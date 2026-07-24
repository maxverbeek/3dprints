// ---------------------------------------------------------------
// Box with friction-fit slide-on lid (square corners)
//
// The top `lip_height` of the box wall is stepped inward so the
// lid's skirt slides over it and sits flush with the outer wall.
// Friction between skirt and lip holds the lid in place.
// ---------------------------------------------------------------

/* [Inside dimensions] */
inside_x = 64;   // interior length
inside_y = 95;   // interior width
inside_z = 40;   // interior height (floor to underside of lid top)

/* [Walls] */
wall   = 3;      // box wall thickness (also floor thickness)
lid_top = 3;     // lid top plate thickness

/* [Lid fit] */
lip_height = 15;   // depth of the lid skirt / height of the inset lip
skirt     = 1.5;   // lid skirt wall thickness
clearance = 0.15;  // gap between skirt and lip per side; tune for friction

/* [Bottom cutout] */
finger_hole_d = 25;  // diameter of the push-out hole in the floor; 0 = no hole

/* [View] */
// "print"     -> both parts flat on the bed, side by side
// "assembled" -> lid on the box
// "open"      -> lid hovering above the box
view = "print"; // [print, assembled, open]

// ---------------------------------------------------------------
// Derived dimensions
// ---------------------------------------------------------------
outer_x = inside_x + 2 * wall;
outer_y = inside_y + 2 * wall;
box_h   = wall + inside_z;           // outer box height (floor + interior)

lip_wall = wall - skirt - clearance; // remaining wall thickness at the lip
lip_x = inside_x + 2 * lip_wall;     // lip outer footprint
lip_y = inside_y + 2 * lip_wall;

assert(lip_wall >= 0.8, "wall too thin: increase wall or reduce skirt/clearance");
assert(inside_z > lip_height, "inside_z must exceed lip_height");

// ---------------------------------------------------------------
// Parts
// ---------------------------------------------------------------
module box() {
    difference() {
        // full outer shell
        cube([outer_x, outer_y, box_h]);
        // interior cavity
        translate([wall, wall, wall])
            cube([inside_x, inside_y, inside_z + 1]);
        // push-out hole in the floor
        if (finger_hole_d > 0)
            translate([outer_x / 2, outer_y / 2, -1])
                cylinder(d = finger_hole_d, h = wall + 2, $fn = 64);
        // step the top of the wall inward to form the lip
        difference() {
            translate([-1, -1, box_h - lip_height])
                cube([outer_x + 2, outer_y + 2, lip_height + 1]);
            translate([(outer_x - lip_x) / 2, (outer_y - lip_y) / 2, box_h - lip_height - 1])
                cube([lip_x, lip_y, lip_height + 2]);
        }
    }
}

module lid() {
    // modeled upside down (top plate on the bed) - print orientation
    difference() {
        cube([outer_x, outer_y, lid_top + lip_height]);
        // cavity that receives the lip (15mm deep -> friction)
        translate([(outer_x - lip_x) / 2 - clearance,
                   (outer_y - lip_y) / 2 - clearance,
                   lid_top])
            cube([lip_x + 2 * clearance, lip_y + 2 * clearance, lip_height + 1]);
    }
}

// lid flipped right-side up and placed on the box
module lid_on_box(lift = 0) {
    translate([0, 0, box_h + lid_top + lift])
        rotate([180, 0, 0])
            translate([0, -outer_y, 0])
                lid();
}

// ---------------------------------------------------------------
// Layout
// ---------------------------------------------------------------
if (view == "print") {
    box();
    translate([outer_x + 5, 0, 0]) lid();
} else if (view == "assembled") {
    box();
    lid_on_box();
} else { // open
    box();
    lid_on_box(30);
}
