// ---------------------------------------------------------------
// Box with friction-fit slide-on lid and one divider (square corners)
//
// Same construction as sliding_lid_box.scad, plus a divider wall
// across the depth axis splitting the interior into two compartments.
// All compartment sizes are inside dimensions.
// ---------------------------------------------------------------

/* [Inside dimensions] */
main_width = 91; // interior width of the divided section
side_width = 35; // interior width of the full-depth compartment next to it
depth_a  = 16;   // interior depth of first compartment
depth_b  = 51;   // interior depth of second compartment
inside_z = 63;   // interior height (floor to underside of lid top)

/* [Walls] */
wall    = 2;     // box wall thickness (also floor and divider thickness)
lid_top = 2;     // lid top plate thickness

/* [Lid fit] */
lip_height = 15;   // depth of the lid skirt / height of the inset lip
skirt     = 1;     // lid skirt wall thickness
clearance = 0.15;  // gap between skirt and lip per side; tune for friction
edge_drop = 8;     // mm of full box wall carried by the lid (above the skirt)

/* [View] */
// "print"     -> both parts flat on the bed, side by side
// "assembled" -> lid on the box
// "open"      -> lid hovering above the box
view = "print"; // [print, assembled, open]

// ---------------------------------------------------------------
// Derived dimensions
// ---------------------------------------------------------------
inside_x = main_width + wall + side_width; // total interior width incl. wall
inside_y = depth_a + wall + depth_b;   // total interior span incl. divider
outer_x = inside_x + 2 * wall;
outer_y = inside_y + 2 * wall;
box_inside_z = inside_z - edge_drop;   // interior height of the box part alone
box_h   = wall + box_inside_z;         // outer box height (floor + interior)

lip_wall = wall - skirt - clearance;   // remaining wall thickness at the lip
lip_x = inside_x + 2 * lip_wall;       // lip outer footprint
lip_y = inside_y + 2 * lip_wall;

assert(lip_wall >= 0.8, "wall too thin: increase wall or reduce skirt/clearance");
assert(box_inside_z > lip_height, "inside_z - edge_drop must exceed lip_height");

// ---------------------------------------------------------------
// Parts
// ---------------------------------------------------------------
module box() {
    difference() {
        // full outer shell
        cube([outer_x, outer_y, box_h]);
        // compartment A
        translate([wall, wall, wall])
            cube([main_width, depth_a, box_inside_z + 1]);
        // compartment B (divider wall left standing in between)
        translate([wall, wall + depth_a + wall, wall])
            cube([main_width, depth_b, box_inside_z + 1]);
        // side compartment: full depth, no divider
        translate([wall + main_width + wall, wall, wall])
            cube([side_width, inside_y, box_inside_z + 1]);
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
        cube([outer_x, outer_y, lid_top + edge_drop + lip_height]);
        // interior: the top edge_drop of the box lives in the lid (full wall)
        translate([wall, wall, lid_top])
            cube([inside_x, inside_y, edge_drop + lip_height + 1]);
        // cavity that receives the lip (friction fit)
        translate([(outer_x - lip_x) / 2 - clearance,
                   (outer_y - lip_y) / 2 - clearance,
                   lid_top + edge_drop])
            cube([lip_x + 2 * clearance, lip_y + 2 * clearance, lip_height + 1]);
    }
}

// lid flipped right-side up and placed on the box
module lid_on_box(lift = 0) {
    translate([0, 0, box_h + edge_drop + lid_top + lift])
        rotate([180, 0, 0])
            translate([0, -outer_y, 0])
                lid();
}

// ---------------------------------------------------------------
// Layout
// ---------------------------------------------------------------
if (view == "print") {
    box();
    translate([0, outer_y + 5, 0]) lid();
} else if (view == "assembled") {
    box();
    lid_on_box();
} else { // open
    box();
    lid_on_box(30);
}
