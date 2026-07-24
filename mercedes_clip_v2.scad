// Mercedes Sprinter paperwork clip — V2, tuned for brittle PLA.
// Based on mercedes_clip.scad (reverse-engineered from thing:4555576).
// Changes vs v1:
//  * hooks thickened OUTBOARD by hook_extra (inner faces + bore stay put,
//    so the fit against the rod mounts is unchanged)
//  * U-slots through the plate beside each hook: the hook rides on a long
//    plate tongue, so it flexes over ~7mm instead of ~2mm (softer snap,
//    less peak stress) while being thicker
// Domed disc, flat back with registration ribs, and two closed barrel
// clips that slide over a vertical rod. All back geometry measured from
// the mesh to ~0.1mm; the front dome is aesthetic (measured profile,
// smoothed).
//
// Model frame: XY = the back plate (X = STL x, Y = STL z), +Z = back
// features, dome at -Z. as_stl() maps into the original STL's frame so
// renders/exports line up with the reference for diffing.
// Units: mm.

$fn = 96;

// ---------- Disc ----------
disc_c = [-6.6, 0.7];   // disc center in XY (kept from the STL)
disc_r = 19.08;
dome_d = 5;             // front dome depth
plate_t = 0;            // back plate surface sits at z=0

// front profile: flat center, parabolic rise to the rim
// (fits the measured mesh within ~0.1mm; purely aesthetic)
dome_flat_r = 8;
dome_prof = concat([[0,-dome_d]], [for (i=[0:40])
    let(r = dome_flat_r + (disc_r-dome_flat_r)*i/40)
    [r, -dome_d + dome_d*pow((r-dome_flat_r)/(disc_r-dome_flat_r), 2)]]);

// ---------- Barrel clips (the functional rod clamp) ----------
bar_cx    = -5.65;   // barrel/bore center x
bore_z    = 4.72;    // bore axis height above plate
bore_r    = 2.05;    // bore radius (rod fit -- tweak me)
bar_hw    = 4.2;     // barrel half width; also outer stadium radius
bar_arc_c = 4.55;    // height of the stadium arc center (crown at 8.75)
bar_th    = 2.0;     // barrel thickness along the rod
bar1_y    = [16.5, 18.5];   // top barrel extent (STL z)
mir_y     = 1.05;    // bottom barrel = mirror of top about this y
// ---------- V2 flexibility mods ----------
hook_extra = 0.6;   // extra hook thickness, added on the outboard side
slot_w     = 1.2;   // width of the flex slots beside each hook
slot_root  = 12;    // slots run from the rim inward to this y; smaller =
                    // longer tongue = softer snap (v1 root was ~16.5)

// outboard countersink (lead-in) cone: z(rho) = cs_apex - cs_slope*rho
// apex sits 0.5 beyond the outboard face
cs_apex  = bar1_y[1] + hook_extra + 0.5;
cs_slope = 0.4;
cs_hw    = 3.2;      // countersink limited to |x - bar_cx| < cs_hw

// ---------- Back features ----------
// pocket: rounded trough, flat floor at -1 with r2.3 fillets all around;
// opening measures x[-9.0,-2.5], y[-7.1,2.9]
pocket_flat = [[-7.1, -6.15], [-4.4, 1.95]]; // flat-floor rect
pocket_fr   = 2.3;                           // fillet radius
pocket_d    = 1;                             // depth
rib_h1   = 1;   rib_h15 = 1.5;  rib_h2 = 2;  rib_h24 = 2.4;  prong_h = 4;

// height envelope for the right-side features: flat prong_h in the
// middle, parabolic falloff, band plateau, round-over to the rim
env_flat_r = 9.7;     // parabola start
env_k      = 0.0341;  // parabola coefficient (fit to mesh)
band_r0    = 16.55;   // rim band inner radius
band_r1    = 17.0;    // band plateau end, round-over start
env_round  = [[17.5,2.22],[17.9,1.99],[18.31,1.76],[18.7,1.22],
              [18.9,0.93],[19.05,0.3],[19.08,0]];

module rect(a, b) translate(a) square([b[0]-a[0], b[1]-a[1]]);
module prism(a, b, h) translate([0,0,-0.3]) linear_extrude(h+0.3) rect(a, b);

// ---------- Height envelope (revolved around disc center) ----------
function env_parab(n=8) = [for (i=[1:n])
    let(r = env_flat_r + (band_r0-env_flat_r)*i/n)
    [r, prong_h - env_k*pow(r-env_flat_r, 2)]];

module envelope() translate(disc_c) rotate_extrude()
    polygon(concat([[0,-0.3],[0,prong_h],[env_flat_r,prong_h]],
                   env_parab(), [[band_r1, rib_h24]], env_round,
                   [[disc_r,-0.3]]));

// ---------- Plate with dome ----------
module plate() difference() {
    translate(disc_c) rotate_extrude()
        polygon(concat([[0,0]], dome_prof));
    hull() for (px = [pocket_flat[0][0], pocket_flat[1][0]],
                py = [pocket_flat[0][1], pocket_flat[1][1]])
        translate([px, py, pocket_fr - pocket_d])
            scale([1, 0.5, 1]) sphere(pocket_fr);   // steeper end walls
}

// ---------- Left rib ladder ----------
module ladder() {
    for (yy = [[-6.6,-5.5],[0.03,1.13],[7.0,8.1]])
        prism([-21.1, yy[0]], [-12.3, yy[1]], rib_h1);      // rungs
    prism([-13.5,-15.52], [-12.3,16.7], rib_h1);            // spine
    prism([-22.2,-6.6], [-21.1,8.1], rib_h2);               // end wall
    for (yy = [[-12.4,-11],[13,14.4]])
        prism([-13.5, yy[0]], [-11, yy[1]], rib_h15);       // pads
}

// ---------- Right-side registration (fork + rim band) ----------
module right_side() {
    prism([-11,13], [2,14.4], rib_h24);                     // top beam
    prism([-11,-12.4], [2,-11], rib_h24);                   // bottom beam
    difference() {                                          // wall x 1..2
        intersection() {   // wall runs rim to rim with sloped ends
            translate([1,0,0]) rotate([90,0,90]) linear_extrude(1)
                polygon([[-18.6,-0.3],[-18.6,0.83],[-14.1,rib_h24],
                         [15.8,rib_h24],[18.6,1.03],[18.6,-0.3]]);
            translate(disc_c) cylinder(r=disc_r, h=8, center=true);
        }
        prism([0.5,-0.3], [2.5,2.0], 10);   // gap between the prongs
    }
    for (yy = [[-5.2,-4.2],[6.1,7.1]])
        prism([2, yy[0]], [9.5, yy[1]], rib_h24);           // bars
    for (yy = [[-1.2,-0.3],[2.0,3.1]])
        prism([1, yy[0]], [10.5, yy[1]], prong_h+1);        // fork prongs
    intersection() {                                        // rim band
        translate(disc_c) rotate_extrude()
            polygon(concat([[band_r0,-0.3],[band_r0,rib_h24],[band_r1,rib_h24]],
                           env_round, [[disc_r,-0.3]]));
        prism([2,-16.5], [13.5,18.6], 3);   // right-side arc only
    }
}

// ---------- Barrel clip ----------
// drawn for the top barrel (outboard = +y), in place
module barrel(y0, y1) {
    ob = y1;   // outboard face
    difference() {
        union() {
            translate([0, y1, 0]) rotate([90,0,0]) linear_extrude(y1-y0)
                stadium2d();
            // parabolic ramp from the plate up the inboard face
            translate([bar_cx-bar_hw, 0, 0]) rotate([90,0,90])
                linear_extrude(2*bar_hw) polygon(concat(
                    [for (i=[0:8]) let(dy = 2*i/8)
                        [y0-2+dy, 0.343*dy*dy]], [[y0,-0.3],[y0-2,-0.3]]));
        }
        // bore
        translate([bar_cx, y0-1, bore_z]) rotate([-90,0,0])
            cylinder(r=bore_r, h=y1-y0+2);
        // outboard countersink: everything above a cone about the bore
        // axis (apex at y=cs_apex, surface y = cs_apex - cs_slope*rho)
        difference() {
            translate([bar_cx-cs_hw, ob-1.7, bore_z]) cube([2*cs_hw, 3, 8]);
            translate([bar_cx, cs_apex, bore_z]) rotate([90,0,0])
                cylinder(r1=0, r2=4/cs_slope, h=4);
        }
    }
}
module stadium2d() {   // barrel cross-section in (x, height)-plane
    hull() {
        translate([bar_cx, bar_arc_c]) circle(bar_hw);
        translate([bar_cx-bar_hw, 0]) square([2*bar_hw, 0.01]);
    }
}

module back_features() {
    intersection() {
        union() { ladder(); right_side(); }
        envelope();
    }
    barrel(bar1_y[0], bar1_y[1] + hook_extra);
    translate([0, 2*mir_y, 0]) mirror([0,1,0])
        barrel(bar1_y[0], bar1_y[1] + hook_extra);
}

// through-slots beside each hook, open at the rim: the hook + its strip
// of plate become a cantilever rooted at slot_root
module hook_slots() for (m = [0, 1])
    translate([0, m ? 2*mir_y : 0, 0]) mirror([0, m, 0])
        for (sx = [bar_cx - bar_hw - slot_w, bar_cx + bar_hw])
            translate([sx, slot_root, -6]) cube([slot_w, 12, 12]);

module clip() difference() { union() { plate(); back_features(); }
                             hook_slots(); }

// map into the original STL's coordinate frame (for diff vs reference)
module as_stl() rotate([-90,0,0]) mirror([0,1,0]) children();

// "stl": aligned with the reference STL (disc standing upright)
// "print": dome down, flat back + hooks up — prints without supports
//          (dome skirt is <=42 deg, rests on the flat 16mm center)
orient = "print";

if (orient == "print") clip();
else as_stl() clip();
