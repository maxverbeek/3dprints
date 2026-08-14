// Vogelbox — behuizing v1
// Gegenereerd vanaf docs/tekening-behuizing.html (werktekening, 4 bladen).
//
// Eenheid: mm. Nulpunt: buitenhoek linksonder van het VOORAANZICHT.
// X = breedte (naar rechts), Y = hoogte (omhoog), Z = diepte (de kast in).
// Beide delen liggen printklaar: kast met de voorkant op het bed,
// paneel met de binnenkant op het bed. Geen support nodig.
//
// Renderen:
//   openscad -o kast.stl         -D 'part="kast"'   omhulsel.scad
//   openscad -o achterpaneel.stl -D 'part="paneel"' omhulsel.scad

part    = "kast";   // "kast" | "paneel"
cutaway = false;    // true: halve kast, om binnenwerk te inspecteren

/* ---------- hoofdmaten ---------- */
box_w    = 160;    // buitenbreedte
box_h    = 90;     // buitenhoogte
box_d    = 70;     // buitendiepte inclusief achterpaneel
wall     = 2.4;    // wanddikte = 6 rupsen bij 0,4-nozzle
panel_t  = 3.0;    // dikte achterpaneel
corner_r = 3;      // afronding staande buitenhoeken

shell_d  = box_d - panel_t;   // dieptemaat van de kast zelf (67)

/* ---------- hoekbosjes / paneelschroeven ---------- */
boss_inset  = 8.5;   // hart uit beide buitenranden
boss_d      = 8;     // diameter bosje
boss_hole   = 2.8;   // boorgat zelftappende M3
boss_hole_l = 12;    // diepte boorgat
panel_hole  = 3.4;   // doorloopgat in paneel
panel_csink = 6.5;   // verzinking (90 graden) buitenzijde paneel

/* ---------- speaker (50 mm Visaton) ---------- */
spk_cx       = 45;    // hart t.o.v. nulpunt
spk_cy       = 45;
grille_d     = 44;    // roosterzone
grille_hole  = 4;     // gaatjes
grille_pitch = 6;     // hexagonale steek
ring_id      = 50.6;  // locatiering binnen  (speaker Ø50 + speling)  * meet na
ring_od      = 56;    // locatiering buiten
ring_h       = 3;     // hoogte ring op binnenkant voorwand

/* ---------- OLED 0.91" 128x32 ---------- */
oled_cx       = 115;   // hart venster
oled_cy       = 58;
oled_win_w    = 24;    // venster in voorwand
oled_win_h    = 7;
oled_pcb_w    = 38.6;  // pocket = PCB + 0,4 speling                 * meet na
oled_pcb_h    = 12.6;
oled_pocket_z = 1.8;   // pocketdiepte in de voorwand
oled_pcb_t    = 1.2;   // PCB-dikte (voor de klemlippen)
lip_w         = 4;     // klemlip breedte
lip_over      = 1.0;   // klemlip overhang de pocket in

/* ---------- PIR AM312 ---------- */
pir_cx   = 115;
pir_cy   = 30;
pir_hole = 10.2;   // lens vlak in het gat                            * meet na

/* ---------- kabeldoorvoer (bodemwand, tegen achterrand) ---------- */
cable_cx = 100;
cable_w  = 12;
cable_h  = 8;

/* ---------- ESP32 DevKit 30-pins op de bodem ---------- */
esp_w    = 28.5;   // boardbreedte                                    * meet na
esp_l    = 51.5;   // boardlengte                                     * meet na
esp_cx   = 100;    // hart in X
esp_z0   = 5;      // voorrand board (USB wijst naar de open achterkant)
esp_pcb  = 1.6;    // PCB-dikte
riser_h  = 3;      // pads onder het board (ruimte voor soldeer)
guide_t  = 1.8;    // dikte geleiders
guide_h  = 6;      // hoogte geleiders
esp_play = 0.25;   // speling rond het board

/* ---------- DFPlayer Mini op de bodem ---------- */
dfp_w  = 21.1;     // breedte                                          * meet na
dfp_l  = 20.8;     // lengte
dfp_cx = 135;
dfp_cz = 28;
dfp_play = 0.2;

/* ---------- sleutelgaten achterpaneel ---------- */
kh_pitch  = 80;    // hartafstand
kh_d      = 8;     // rond gat (schroefkop erdoor)
kh_slot_w = 4;     // sleufbreedte
kh_slot_l = 10;    // sleuflengte omhoog
kh_cy     = 68;    // hoogte rond gat
kh_head_d = 7.6;   // kopruimte-groef aan buitenzijde
kh_head_z = 1.8;   // diepte kopruimte

$fs = 0.4;
$fa = 4;
eps = 0.01;

/* ================= hulpvormen ================= */

// rechthoek met afgeronde hoeken, zelfde omhullende maat
module rrect(w, h, r) {
    offset(r = r) offset(delta = -r) square([w, h]);
}

// Uitsteeksel op de bodem met 45-graden aanloop zodat het supportvrij print
// (printrichting = +Z). dir=+1: aanloop aan de -Z-kant, dir=-1: aan de +Z-kant.
// Het volledige blok beslaat y: wall..wall+h en z: (dir>0 ? z0+h..z0+dz : z0..z0+dz-h).
module floorpad(x0, dx, z0, dz, h, dir = 1) {
    hull() {
        translate([x0, wall - eps, z0]) cube([dx, 2 * eps, dz]);
        if (dir > 0)
            translate([x0, wall - eps, z0 + h]) cube([dx, h + eps, dz - h]);
        else
            translate([x0, wall - eps, z0]) cube([dx, h + eps, dz - h]);
    }
}

/* ================= kast ================= */

module grille_holes() {
    lim = (grille_d - grille_hole) / 2;
    for (j = [-4:4], i = [-8:8]) {
        x = i * grille_pitch + (abs(j) % 2) * grille_pitch / 2;
        y = j * grille_pitch * sin(60);
        if (sqrt(x * x + y * y) <= lim + eps)
            translate([spk_cx + x, spk_cy + y, -1])
                cylinder(d = grille_hole, h = wall + 2);
    }
}

module kast_cuts() {
    // speakerrooster
    grille_holes();

    // OLED-venster
    translate([oled_cx - oled_win_w / 2, oled_cy - oled_win_h / 2, -1])
        cube([oled_win_w, oled_win_h, wall + 2]);

    // OLED-pocket (uitsparing in de binnenkant van de voorwand)
    translate([oled_cx - oled_pcb_w / 2, oled_cy - oled_pcb_h / 2, wall - oled_pocket_z])
        cube([oled_pcb_w, oled_pcb_h, oled_pocket_z + eps]);

    // PIR-lensgat
    translate([pir_cx, pir_cy, -1]) cylinder(d = pir_hole, h = wall + 2);

    // kabeldoorvoer in de bodemwand, open naar de achterrand
    translate([cable_cx - cable_w / 2, -1, shell_d - cable_h])
        cube([cable_w, cable_h + 1, cable_h + 1 + eps]);

    // tiewrap-sleuven naast de ESP32 (2 paar)
    for (x = [esp_cx - esp_w / 2 - 4.5, esp_cx + esp_w / 2 + 1.5],
         z = [esp_z0 + 11, esp_z0 + 39])
        translate([x, -1, z]) cube([3, wall + 2, 4]);
}

module boss_posts() {
    for (x = [boss_inset, box_w - boss_inset],
         y = [boss_inset, box_h - boss_inset])
        translate([x, y, wall - eps])
            cylinder(d = boss_d, h = shell_d - wall + eps);
}

module boss_pilots() {
    for (x = [boss_inset, box_w - boss_inset],
         y = [boss_inset, box_h - boss_inset])
        translate([x, y, shell_d - boss_hole_l])
            cylinder(d = boss_hole, h = boss_hole_l + 1);
}

module speaker_ring() {
    translate([spk_cx, spk_cy, wall - eps]) difference() {
        cylinder(d = ring_od, h = ring_h + eps);
        translate([0, 0, -1]) cylinder(d = ring_id, h = ring_h + 2);
    }
}

module oled_lips() {
    for (ys = [-1, 1]) {
        y_edge = oled_cy + ys * oled_pcb_h / 2;                 // pocketrand
        y0 = (ys > 0) ? y_edge - lip_over : y_edge - 1.5;       // 1,0 de pocket in + 1,5 anker
        translate([oled_cx - lip_w / 2, y0, wall - oled_pocket_z + oled_pcb_t + 0.2])
            cube([lip_w, lip_over + 1.5, 1.2]);
    }
}

module esp_mount() {
    x0 = esp_cx - esp_w / 2;   // 85,75
    x1 = esp_cx + esp_w / 2;   // 114,25

    // 4 pads onder de boardhoeken
    for (x = [x0, x1 - 6]) {
        floorpad(x, 6, esp_z0 - 3, 9, riser_h, 1);                     // voor
        floorpad(x, 6, esp_z0 + esp_l - 9, 9 + 3, riser_h, -1);        // achter
    }
    // aanslagribben op de voorwand (elke laag gedragen door de wand)
    for (x = [esp_cx - 14, esp_cx + 10])
        translate([x, wall, wall]) cube([4, 6, esp_z0 - wall]);
    // zijgeleiders halverwege het board
    for (x = [x0 - esp_play - guide_t, x1 + esp_play])
        floorpad(x, guide_t, esp_z0 + 14, 18, guide_h, 1);
    // aanslag aan de USB-kant, links en rechts van de kabeldoorvoer
    for (x = [esp_cx - 16, esp_cx + 8])
        floorpad(x, 8, esp_z0 + esp_l + esp_play - 6, 7.8, guide_h, 1);
}

module dfp_mount() {
    px0 = dfp_cx - dfp_w / 2 - dfp_play;   // pocket binnenkant
    px1 = dfp_cx + dfp_w / 2 + dfp_play;
    pz0 = dfp_cz - dfp_l / 2 - dfp_play;
    pz1 = dfp_cz + dfp_l / 2 + dfp_play;

    // zijwanden (langs Z)
    for (x = [px0 - guide_t, px1])
        floorpad(x, guide_t, pz0 - 6, (pz1 - pz0) + 12, guide_h, 1);
    // voor- en achterwand (langs X)
    floorpad(px0, px1 - px0, pz0 - guide_t - 6, guide_t + 6, guide_h, 1);
    floorpad(px0, px1 - px0, pz1, guide_t + 6, guide_h, -1);
    // pads onder de hoeken (soldeerruimte)
    for (x = [px0, px1 - 5]) {
        floorpad(x, 5, pz0 - 2, 7, 2, 1);
        floorpad(x, 5, pz1 - 5, 7, 2, -1);
    }
}

module kast() {
    difference() {
        union() {
            difference() {
                // schaal: buitenvorm minus binnenruimte
                difference() {
                    linear_extrude(shell_d) rrect(box_w, box_h, corner_r);
                    translate([wall, wall, wall])
                        linear_extrude(shell_d)
                            rrect(box_w - 2 * wall, box_h - 2 * wall,
                                  max(corner_r - wall / 2, 0.6));
                }
                kast_cuts();
            }
            boss_posts();
            speaker_ring();
            oled_lips();
            esp_mount();
            dfp_mount();
        }
        boss_pilots();
        if (cutaway) translate([-1, spk_cy, -1]) cube([box_w + 2, box_h, box_d + 2]);
    }
}

/* ================= achterpaneel ================= */

module keyhole(x) {
    // rond gat + sleuf omhoog (ophangen: kast zakt over de schroefkop)
    translate([x, kh_cy, -1]) cylinder(d = kh_d, h = panel_t + 2);
    translate([x - kh_slot_w / 2, kh_cy, -1])
        cube([kh_slot_w, kh_slot_l, panel_t + 2]);
    // groef voor de schroefkop aan de buitenzijde
    hull() for (y = [kh_cy + 1.5, kh_cy + kh_slot_l])
        translate([x, y, panel_t - kh_head_z])
            cylinder(d = kh_head_d, h = kh_head_z + 1);
}

module paneel() {
    difference() {
        linear_extrude(panel_t) rrect(box_w, box_h, corner_r);
        // 4 verzonken schroefgaten, verzinking aan de buitenzijde (bovenkant print)
        for (x = [boss_inset, box_w - boss_inset],
             y = [boss_inset, box_h - boss_inset]) {
            translate([x, y, -1]) cylinder(d = panel_hole, h = panel_t + 2);
            translate([x, y, panel_t - (panel_csink - panel_hole) / 2])
                cylinder(d1 = panel_hole, d2 = panel_csink,
                         h = (panel_csink - panel_hole) / 2 + eps);
            translate([x, y, panel_t - eps]) cylinder(d = panel_csink, h = 1);
        }
        // sleutelgaten voor wandmontage
        for (x = [box_w / 2 - kh_pitch / 2, box_w / 2 + kh_pitch / 2]) keyhole(x);
    }
}

/* ================= selectie ================= */

if (part == "kast") kast();
else if (part == "paneel") paneel();
else echo("onbekend part — kies \"kast\" of \"paneel\"");
