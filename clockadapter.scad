/* * Clock adapter

* Units: Millimeters (mm)

*/

$fn = 64; // Smoothness for high-quality curves/fillets

module shell(d, fillet = 0) {
    translate([0, d]) difference() {
        offset(r = -fillet) offset(r = d + fillet) children();
        children();
    }
}

module droplet2(rb = 12, rt = 4, length = 0, fillet = 0) {
    width = min(rt, rb) * 2;
    height = rb + rt + length;
    offset(r = -fillet) offset(r = fillet)
        translate([0, rb])
            union() {
                circle(rb);
                translate([-width/2, 0]) square([width, height]);
                translate([0, height]) circle(rt);
            }
}

module adapter() {
    thickness = 3;
    offset_in = 4;
    inner_diam = 5; // min 4, max 6
    outter_diam = 9;
    
    radius_clockthing = 2;
    height_clockthing = 10;
    elongate_clockthing = 3;
    
    linear_extrude(height = 1.75) difference() {
        droplet2(rb = outter_diam + thickness, rt = inner_diam + thickness, fillet = 10, length = -thickness - inner_diam);
        translate([0, thickness + outter_diam]) droplet2(rb = outter_diam / 2, rt = inner_diam / 2, fillet = 6);
    }
    
    translate([0, offset_in / 2 + radius_clockthing]) {
      hull() {
        for (y = [0, elongate_clockthing]) translate([0, y]) cylinder(h = height_clockthing, r = radius_clockthing);
      }

      hull() {
        for (y = [0, elongate_clockthing]) translate([0, y, height_clockthing]) sphere(r = radius_clockthing + 2);
      }
    }
}

color("Silver") adapter();
