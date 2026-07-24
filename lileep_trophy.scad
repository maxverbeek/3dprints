// Lileep holding the Stone Badge — office trophy, ~100mm tall, one piece.
// Anatomy from official art: lumpy base blob -> banded stalk -> goblet cup
// -> black face dome with yellow eyes -> 8 pink tentacles arcing over.
// Units: mm.

use <stone_badge.scad>

$fn = 48;

// ---------- Colors (preview only) ----------
C_PURPLE = [0.62, 0.55, 0.75];
C_YELLOW = [0.93, 0.83, 0.55];
C_BLACK  = [0.12, 0.10, 0.12];
C_PINK   = [0.93, 0.68, 0.68];

// ---------- Key heights ----------
base_h    = 16;   // top of base blob
stalk_top = 34;   // stalk emerges from blob, ends here (elongated)
cup_z     = 32;   // cup bottom
cup_h     = 32;   // cup height
rim_r     = 22;   // cup radius at rim
dome_z    = 69;   // face dome center height
dome_r    = 13.5;
head_tilt  = 30;  // forward tilt of everything above the stalk
stalk_lean = 18;  // stalk leans backward so the tilted head stays centered
stalk_sy   = (stalk_top - 10) * sin(stalk_lean);       // stalk top offset
stalk_sz   = 10 + (stalk_top - 10) * cos(stalk_lean);

// ---------- Base blob: squashed sphere + droopy flaps ----------
module base_blob() color(C_PURPLE) {
    difference() {
        union() {
            translate([0, 0, 6]) scale([1, 1, 0.5]) sphere(24);
            // droopy flap feet: chain of squashed balls stepping down in
            // slope so the blend into the blob has no hard crease
            for (a = [18 : 72 : 359]) rotate([0, 0, a]) {
                hull() {
                    translate([9, 0, 0]) scale([1, 1.3, 0.85]) sphere(10);
                    translate([16, 0, 1]) scale([1.1, 1, 0.55]) sphere(7.5);
                }
                hull() {
                    translate([16, 0, 1]) scale([1.1, 1, 0.55]) sphere(7.5);
                    translate([22, 0, 0.8]) scale([1.25, 0.7, 0.4]) sphere(6.5);
                }
            }
            // hump the stalk rises from
            translate([0, 0, 8]) scale([1, 1, 0.9]) sphere(10);
        }
        translate([0, 0, -50]) cylinder(r = 60, h = 50);  // flatten bottom
    }
}

// ---------- Banded yellow stalk ----------
module stalk() color(C_YELLOW)
    translate([0, 0, 10]) rotate([-stalk_lean, 0, 0]) translate([0, 0, -10]) {
        translate([0, 0, 10]) cylinder(r = 4.5, h = stalk_top - 10);
        for (z = [16, 23, 30]) translate([0, 0, z]) sphere(6);
    }

// ---------- Round bowl body ----------
module cup() color(C_PURPLE) difference() {
    union() {
        translate([0, 0, cup_z + 22]) sphere(24);          // round bowl
        translate([0, 0, cup_z - 2])                       // neck into bowl
            cylinder(r1 = 6, r2 = 14, h = 12);
    }
    translate([0, 0, cup_z + cup_h]) cylinder(r = 40, h = 40);  // rim plane
    // inner dish: 8mm deep, opening r16 -- visibly a bowl but mostly filled
    translate([0, 0, cup_z + cup_h + 12]) sphere(20);
}

// ---------- Face dome with eyes ----------
module face_dome() {
    color(C_BLACK) translate([0, 0, dome_z]) sphere(dome_r);
    // hidden pedestal: anchors the dome to the bowl through the inner dish;
    // flares wide so the dome underside self-supports (no trapped supports
    // inside the bowl cavity)
    color(C_BLACK) translate([0, 0, cup_z + 4])
        cylinder(r1 = 6, r2 = 12.5, h = dome_z - cup_z - 4);
    // yellow oval eyes on the front (-y)
    // eyes sit high on the dome so they read straight-on after the head tilt
    color(C_YELLOW)
        for (sx = [-1, 1])
            translate([sx * 4.2, -10, dome_z + 6.4])
                rotate([90, 0, 0]) scale([1, 1.5, 1]) sphere(2.5);
}

// ---------- Tentacle: circular arc sweep of hulled spheres ----------
// tilt0: start angle from vertical (deg, + = outward)
// bend: total arc turn (deg); L: arc length; r0/r1: root/tip radius
module tentacle(L = 48, r0 = 5.2, r1 = 2.6, tilt0 = -5, bend = 170) {
    steps = 14;
    R = L / (bend * PI / 180);
    for (i = [0 : steps - 1]) hull() {
        tent_ball(i / steps, R, tilt0, bend, r0, r1);
        tent_ball((i + 1) / steps, R, tilt0, bend, r0, r1);
    }
}
module tent_ball(t, R, tilt0, bend, r0, r1) {
    th = tilt0 + bend * t;
    translate([R * (cos(tilt0) - cos(th)), 0, R * (sin(th) - sin(tilt0))])
        sphere(r0 + (r1 - r0) * t);
}

// buried continuation below a tentacle root, so it emerges from the bowl
// fill instead of starting abruptly on the rim (local: -x = inward)
module root_anchor(r0) hull() {
    sphere(r0);
    translate([-3, 0, -5]) sphere(r0 - 0.5);
}

// ---------- Crown of tentacles around the rim ----------
module crown() color(C_PINK) {
    // roots perch ON the rim wall (solid, ~7mm thick) so nothing floats
    // inside the deep bowl cavity
    // grip pair: rise along the badge's side edges, tips embedding into it
    for (a = [0, 180])
        rotate([0, 0, a]) translate([rim_r - 5, 0, cup_z + cup_h + 1]) {
            tentacle(L = 30, r0 = 5, r1 = 3.2, tilt0 = -15, bend = 45);
            root_anchor(5);
        }
    // the rest fountain outward like the art
    for (i = [0 : 5])
        rotate([0, 0, [67.5, 112.5, 202.5, 247.5, 292.5, 337.5][i]])
            translate([rim_r - 4.5, 0, cup_z + cup_h + 1]) {
            tentacle(tilt0 = 35, bend = 140 + 20 * sin(i * 77));
            root_anchor(5.2);
        }
}

// ---------- Badge, held tilted in the crown ----------
module held_badge()
    // 38 + 30 head tilt = 68 absolute: leans back for readability
    translate([0, 4, 95]) rotate([38, 0, 0])
        scale(1.15) stone_badge_display();

// chain of hulled spheres along explicit 3D points, radius tapering r0->r1
module blob_chain(pts, r0, r1) {
    n = len(pts);
    for (i = [0 : n - 2]) hull() {
        translate(pts[i]) sphere(r0 + (r1 - r0) * i / (n - 1));
        translate(pts[i + 1]) sphere(r0 + (r1 - r0) * (i + 1) / (n - 1));
    }
}

// tip nudge: short continuation past the grip tentacle tip whose angle
// straightens where it presses on the badge edge -- a subtle kink
module grip_nudges() color(C_PINK)
    for (m = [0, 1]) mirror([m, 0, 0])
        blob_chain([[20.8, 0, 94], [21.5, 0, 95.8], [21.9, 0, 97.7]],
                   3.2, 2.5);

// hidden stub from the dome up to the badge's lower back: anchors the badge
// (and is the glue surface when printing in two parts)
module badge_stub() color(C_BLACK) hull() {
    translate([0, 0, dome_z + 7]) sphere(5);
    translate([0, -2, 90]) sphere(3.5);   // meets the badge's back, hidden
}

// glue pocket for the badge: its silhouette extruded with 0.3mm clearance
// (a cheap slab -- the detailed badge would blow up the CSG preview tree)
module badge_socket()
    translate([0, 4, 95]) rotate([38, 0, 0]) scale(1.15) rotate(45)
        translate([0, 0, -0.3]) linear_extrude(5.6) offset(0.3) silhouette2d();

// head transform: tilts forward, pivoting at the stalk top, which itself
// moved back because of the stalk lean
module head_xform() translate([0, stalk_sy, stalk_sz - stalk_top])
    translate([0, 0, stalk_top]) rotate([head_tilt, 0, 0])
    translate([0, 0, -stalk_top]) children();

// ---------- Assembly ----------
// part = "all"   : full trophy, one piece
// part = "body"  : lileep with a badge-shaped socket (print with supports)
// part = "badge" : badge alone, flat on its back (print without supports)
part = "all";
cutaway = false;   // true: slice away x < 0 to inspect internal connections

difference() {
    union() {
        if (part == "badge") {
            scale(1.15) stone_badge_display();
        } else {
            base_blob();
            stalk();
            difference() {
                head_xform() {
                    cup();
                    face_dome();
                    crown();
                    badge_stub();
                    grip_nudges();
                    if (part == "all") held_badge();
                }
                if (part == "body") head_xform() badge_socket();
            }
        }
    }
    if (cutaway) translate([-200, -100, -1]) cube([200, 200, 200]);
}
