use <camera.scad>;


// Units are in mm

/// Universal variables

mm_per_inch = 25.4;

// Stop time at this value
$t = 0;

render_fast = false;

// Create a variable that goes from 0 .. 1 .. 0 over time as a curve
sin_t = sin($t * 180);

/// User variables

// SCREWS

// #10 - 32 x 3/4" hex head threaded bolt
follow_focus_plate_bolt_hex       = 0.311 * mm_per_inch * 1.05; // distance between hex parallel surfaces
follow_focus_plate_bolt_hex_depth = 0.134 * mm_per_inch;
follow_focus_plate_bolt_radius    = ((0.186 * mm_per_inch) / 2)  * 1.05;

// #8 - 32 x 3/4" round head threaded bolt
hex_size          = 0.338 * mm_per_inch * 1.05;
hex_height        = 0.125 * mm_per_inch * 1.05;
screw_hole_radius = ((0.161 * mm_per_inch) / 2) * 1.05;
screw_washer_radius = 0.39 * mm_per_inch / 2;

// Undecided screw
gearbox_hole_radius = 1;

// 1/4" - 20
camera_hole_radius = ((0.246 * mm_per_inch) / 2) * 1.05;
camera_hex_size    = 0.432 * mm_per_inch * 1.05;
camera_hex_depth   = 0.219 * mm_per_inch * 1.05;

follow_focus_shaft_radius = 4 / 2;
retaining_screw_radius = screw_hole_radius / 2;
retaining_nut_size = 3;
retaining_nut_depth = 1;

bearing_inner_dia = 4;
bearing_outer_dia = 8;
bearing_height = 3;

// TUBES

tube_diameter = 5/8 * mm_per_inch;
tube_diameter = 16.5;  // may change after further printer calibration
tube_radius   = tube_diameter / 2;
tube_distance = tube_diameter * 3;

// HANDLE BARS

handle_bar_hole_radius = camera_hole_radius;
handle_bar_radius      = tube_radius;
handle_bar_height      = 4 * mm_per_inch;

// BRACKET SIZING

bracket_length = 15; // length along tube
bracket_bridge_space = 2; // size of space which gets tightened
bracket_wall_thickness = 3;

// DSLR bracket
dslr_bracket_length = bracket_length * 2;
dslr_access_height  = 15;
dslr_top_thickness  = 15;

// Figure out where camera sits on top of the DSLR bracket
camera_z = dslr_access_height + dslr_top_thickness + bracket_bridge_space / 2 + bracket_wall_thickness;

// Follow focus bracket and plate
follow_focus_bracket_length = 33;
follow_focus_groove_size = 5; // angle groove
bracket_top_groove_depth = follow_focus_plate_bolt_hex_depth;
angle_groove_height = sqrt(pow(follow_focus_groove_size, 2) * 2);

// Angled rail connector
lower_rails_x_offset = -110;
lower_rails_z_offset = -40;
angle_bracket_connector_height = tube_diameter - bracket_wall_thickness * 2;

/// Ready to print objects

/// Rail connector bracket, split (x 4)
// rotate(90, [1, 0, 0]) railConnectorBracketSplit(lower_rails_x_offset, lower_rails_z_offset);

/// DSLR mounting bracket
// rotate(90, [1, 0, 0]) bracketWithDSLR();

/// Follow focus bracket
// rotate(90, [1, 0, 0]) bracketWithHexGroove();

/// Follow focus plate
// rotate(180, [1, 0, 0]) followFocusPlate();

/// Follow focus L bracket
// rotate(90, [0, 1, 0]) followFocusBracket();

/// Handle bar bracket
// rotate([90, 0, 0]) handleBarBracket();

/// Preview objects

rig();
// previewSplitConnectorBrackets();
// followFocusRig();

// miterGear();
// followFocus();
// gearBox();

// counterWeightAssembly();

/// Display objects 

module bearing (inner_dia, outer_dia, height) {
	inner_dia = bearing_inner_dia;
	outer_dia = bearing_outer_dia;
	height    = bearing_height;
	
	difference () {
		cylinder(r = outer_dia / 2, h = height, center = true);
		cylinder(r = inner_dia / 2, h = height + 0.1, center = true, $fn = 20);
	}
}

module previewSplitConnectorBrackets () {
	translate([-1 * lower_rails_x_offset / 2, 0, -1 * lower_rails_z_offset / 2]) {
		railConnectorBracketSplit(lower_rails_x_offset, lower_rails_z_offset);
		
		translate([lower_rails_x_offset - sin_t * 20, 0, lower_rails_z_offset - sin_t * 5])
			rotate(180, [0, 1, 0])
			railConnectorBracketSplit(lower_rails_x_offset, lower_rails_z_offset);
	
		translate([0, bracket_length * 2, 0])
		railConnectorBrackets(lower_rails_x_offset, lower_rails_z_offset);
	}
}

module followFocusRig () {
	// Upper rails and objects

	translate([0, 105, 0]) {
		translate([0, -60, 0])
			% rails(9 * mm_per_inch);
	
		bracketWithDSLR();
	
		translate([0, 0, camera_z])
			rotate(180, [0, 0, 1])
			% canonT2i();
	}

	followFocus();
}

module rig () {
	// Upper rails and objects

	translate([0, -60, 0])
		% rails(9 * mm_per_inch);

	for (bracket_y_pos = [25, -60]) {
		translate([0, bracket_y_pos, 0]) {
			if (render_fast == true) {
				railConnectorBrackets(lower_rails_x_offset, lower_rails_z_offset);
			}
			else {
				railConnectorBracketSplit(lower_rails_x_offset, lower_rails_z_offset);
				
				translate([lower_rails_x_offset, 0, lower_rails_z_offset])
					rotate(180, [0, 1, 0])
					railConnectorBracketSplit(lower_rails_x_offset, lower_rails_z_offset);
			}
		}
	}

	bracketWithDSLR();

	translate([0, 0, camera_z])
		rotate(180, [0, 0, 1])
		% canonT2i();

	translate([0, -95, 0]) followFocus();
	
	// Lower rails	

	translate([lower_rails_x_offset, 0, lower_rails_z_offset]) {
		translate([0, -130, 0])
			rotate([0, 0, 180])
			handleBarBracket(draw_handlebar = true);
		translate([0, 70, 0])
			% rails(18 * mm_per_inch);

		translate([0, 240, 0])
			counterWeightAssembly();
	}
}

module followFocus () {
	bracketWithHexGroove(bracket_length = follow_focus_bracket_length);
	translate([0, 0, tube_radius + bracket_wall_thickness - bracket_top_groove_depth + sin_t * 8])
		followFocusPlate();
	translate([sin_t * 8, 0, sin_t * 16]) {
		translate([0, 0, tube_radius + bracket_wall_thickness + 0.9])
			followFocusBracket();
		translate([54.75, 0, 33]) rotate([180, 0, 0])
			gearBox();
	}
}

module counterWeightAssembly () {
	translate([0, 0, bracket_wall_thickness * 2 + sin_t * 10])
		counterWeightPlate(draw_weight = true);
	
	for (forward_backward = [-1, 1]) {
		translate([0, forward_backward * tube_distance / 3, 0])
			counterWeightBracket();
	}

	translate([0, 0, 23]) counterWeightCap();
}

/// Printable objects

module gearBox () {
	show_gears = true;

	cube_wall_thickness = 2;
	cube_size   = follow_focus_bracket_length - cube_wall_thickness * 2;
	cube_height = 28;

	lens_shaft_x_offset = -3;
	handle_shaft_y_offset = 3;

	difference () {
		cube([ cube_size + cube_wall_thickness * 2, cube_size + cube_wall_thickness * 2, cube_height ], center = true);
		translate([0, 0, cube_wall_thickness])
			cube([cube_size, cube_size, cube_height], center = true);
		
		// Shaft holes
		rotate([90, 0, 0]) translate([lens_shaft_x_offset, 0, (cube_size + cube_wall_thickness) / 2])
			cylinder(r = follow_focus_shaft_radius * 1.05, h =  cube_wall_thickness + 1, center = true, $fn = 20);
		rotate([0, -90, 0]) translate([0, handle_shaft_y_offset, -1 * (cube_size + cube_wall_thickness) / 2])
			cylinder(r = follow_focus_shaft_radius * 1.05, h =  cube_wall_thickness + 1, center = true, $fn = 20);
	}

	// ground_steel 8mm;


	if (show_gears) {
		
		// Shafts
		rotate([90, 0, 0]) translate([lens_shaft_x_offset, 0, -1 * (cube_size + cube_wall_thickness) / 2 + 1])
			% cylinder(r = follow_focus_shaft_radius, h = 46, center = false, $fn = 20);

		rotate([0, 90, 0]) translate([0, handle_shaft_y_offset, 2])
			% cylinder(r = follow_focus_shaft_radius, h = 30, center = false, $fn = 20);

		// Lens shaft gear and bearings
		translate([lens_shaft_x_offset, 0, 0]) rotate([-90, 0, 0]) translate([0, 0, -10])  {
			rotate([0, 0, 10]) miterGear();
			translate([0, 0, -1 * (bearing_height / 2) - 1]) bearing();
			translate([0, 0, 21]) bearing();
		
			// Focus gear
			% translate([0, 0, -17]) cylinder(r = 22, h = 8, center = true);
		}

		// Handle shaft gear and bearings
		translate([0, handle_shaft_y_offset, 0]) rotate([0, -90, 0]) translate([0, 0, -10]) {
			miterGear();
			translate([0, 0, -1 * (bearing_height / 2) - 1]) bearing();
			translate([0, 0, -1 * (bearing_height / 2) - 7.5]) bearing();

			// Handle
			union () {
				% translate([0, 0, -17]) cylinder(r = 30, h = 8, center = true);
				% translate([0, 0, -24]) cylinder(r = 22, h = 8, center = true);
			}
		}
	}
}

module miterGear () {	
	difference () {
		scale (1.1) translate([0, 0, 4]) {
			difference () {
				union () {
					rotate([90, 0, 0])
						import_stl("lm0_8_20.stl", convexity = 5);
		
					// Reduce overhang distance
					// translate([0, 0, -4.7])
						// cylinder(r = 7.3, h = 8, center = true);
			
					// Fill existing hole
					translate([0, 0, -1])
					 	cylinder(r = 3, h = 8, center = true);
				}
	
				// Clip off bottom
				translate([0, 0, -6.5])
					cylinder(r = 8, h = 5, center = true);
	
			}
		}

		// Screw hole
		translate([0, 0, 4.5])
			cylinder(r = follow_focus_shaft_radius, h = 14, center = true, $fn = 20);

		// Holding screw hole
		for (angle = [0, -120, 120]) {
			translate([0, 0, 2.0]) rotate([90, 0, angle]) {
				translate([0, -3/2, 4])
					cube([ retaining_nut_size, retaining_nut_size + 3, retaining_nut_depth ], center = true);
				cylinder(r = retaining_screw_radius, h = 12, center = false, $fn = 20);
				
			}
		}
	}
}

module counterWeightCap () {
	cyl_radius = 12;
	cyl_height = 5;
	knob_height = 0.2 * mm_per_inch;
	knob_radius = 1.25 * mm_per_inch;

	difference () {
		union () {
			translate([0, 0, -1 * cyl_height / 2 + 0.1])
				cylinder(r = cyl_radius, h = cyl_height, center = true);
			translate([0, 0, knob_height / 2])
				cylinder(r = knob_radius, h = knob_height, center = true);
		}
		cylinder(r = camera_hole_radius, h = knob_height + cyl_height + 1, center = true);
		translate([0, 0, knob_height - camera_hex_depth / 2 + 0.1])
			regHexagon(camera_hex_size, camera_hex_depth);
	}
	
}

module counterWeightPlate () {
	cyl_height = 4;
	cyl_radius = 12;
	plate_height = bracket_wall_thickness + hex_height;

	translate ([0, 0, plate_height / 2])
	difference () {
		union () {
			cube([tube_distance, tube_distance, plate_height], center = true);
			translate([0, 0, plate_height / 2 - 0.1 + cyl_height / 2])
				cylinder(r = cyl_radius, h = cyl_height, center = true);
		}

		// Screw holes in plate
		for (corner = [[1, 1], [-1, 1], [1, -1], [-1, -1]]) {
			translate([ corner[0] * tube_distance / 3, corner[1] * tube_distance / 3, 0 ])
			union () {
				cylinder(r = screw_hole_radius, h = plate_height + 1, center = true, $fn = 20);
				translate([0, 0, hex_height / 2])
					cylinder(r = screw_washer_radius, h = hex_height, center = true, $fn = 20);
			}
		}
		translate([0, 0, cyl_height / 2])
			cylinder(r = camera_hole_radius, h = cyl_height + plate_height + 1, center = true);
		
		translate([0, 0, -1 * (cyl_height / 2)])
			regHexagon(camera_hex_size, camera_hex_depth);
	/*
		// Screw holes in post
		for (iter = [1:5]) {
			translate([0, 0, plate_height / 2 + (cyl_height / 6) * iter])
			rotate([90, 0, iter * 60])
			cylinder(r = screw_hole_radius, h = cyl_radius * 2 + 1, center = true, $fn = 20);
		}
	*/
	}
	
	// 1-1/4 lb weight is: OD: 9.6cm, ID: 2.5cm, Height: 1cm
	weight_height = 10;
	weight_radius = 96 / 2;
	weight_inner_radius = 25 / 2;

	// 2-1/2 lb weight is: OD: 12.5cm, ID: 2.5cm, Height: 1.25cm
	// 5 lb weight is: OD: 16cm, ID: 2.5cm, Height: 2cm

	if (draw_weight) {
		% translate([0, 0, plate_height + weight_height / 2 + 0.1])
			difference () {
				cylinder(r = weight_radius, h = weight_height, center = true);
				cylinder(r = weight_inner_radius, h = weight_height + 0.1, center = true);
			}
	}

}

module counterWeightBracket () {
	plate_height = bracket_wall_thickness + hex_height;

	difference () {
		union () {
			basicBracket(bracket_length, bracket_wall_thickness);
			for (left_right = [-1, 1]) {
				translate([left_right * (tube_distance / 2 + tube_radius / 2), 0, (tube_radius + bracket_wall_thickness) / 2])
					cube([tube_radius, bracket_length, tube_radius + bracket_wall_thickness], center = true);
			}
		}

		basicBracket(bracket_length + 2, 0);
	
		for (left_right = [-1, 1]) {
			translate([ left_right * (tube_distance / 3), 0, 0 ]) {
				cylinder(r = screw_hole_radius, h = tube_diameter + bracket_wall_thickness * 2 + 1, center = true, $fn = 20);
				translate([0, 0, -1 * (bracket_wall_thickness + bracket_bridge_space / 2 + hex_height / 2)])
				rotate(30, [0, 0, 1])
				regHexagon(hex_size, hex_height);
			}
		}
	}
}

module handleBarBracket () {
	overhang_width = handle_bar_radius * 2;
	overhang_height = bracket_wall_thickness * 2 + bracket_bridge_space / 2 + tube_radius + bracket_wall_thickness;
	overhang_z_center = -1 * ((tube_diameter + bracket_wall_thickness * 2) - overhang_height) / 2;

	difference () {
		union () {
			rotate([180, 0, 0])
				basicBracketWithHex(bracket_length, bracket_wall_thickness);
			translate([ tube_distance / 2 + tube_diameter + overhang_width / 2 - tube_radius / 2, 0,  overhang_z_center])
				cube([ overhang_width + tube_radius, bracket_length, overhang_height ], center = true);
			translate([ tube_distance / 2 - overhang_width / 2 + tube_radius / 2, 0,  overhang_z_center])
				cube([ overhang_width + tube_radius, bracket_length, overhang_height ], center = true);
		}

		// Subtract space of bracket
		basicBracket(bracket_length + 0.1, 0);
	
		// Slice out the bridge spacing in the overhang
		translate([ tube_distance / 2 + tube_diameter + overhang_width / 2, 0, 0 ])
			cube([ overhang_width * 1.1, bracket_length + 0.1, bracket_bridge_space ], center = true);
		
		// Hole on overhang
		translate([ tube_distance / 2 + tube_diameter + overhang_width / 2, 0, overhang_z_center])
			cylinder(r = handle_bar_hole_radius, h = overhang_height * 1.1, center = true, $fn = 20);
		translate([ tube_distance / 2 - overhang_width / 2, 0, overhang_z_center])
			cylinder(r = handle_bar_hole_radius, h = overhang_height * 1.1, center = true, $fn = 20);
	}

	if (draw_handlebar == true) {
		translate([ tube_distance / 2 + tube_diameter + overhang_width / 2, 0, -1 * (tube_radius + bracket_wall_thickness + handle_bar_height / 2) ])
			% cylinder(r = handle_bar_radius, h = handle_bar_height, center = true);
	}

}

module railConnectorBracketSplit (x_offset, z_offset) {
	difference () {
		union () {
			basicBracketWithHex(bracket_length, bracket_wall_thickness);
			railConnector(x_offset, z_offset, split = true);
		}
		basicBracket(bracket_length + 0.1, 0);
	}
}

module railConnectorBrackets (x_offset, z_offset) {
	difference () {
		union () {
			// Top rail, knob on bottom
			basicBracketWithHex(bracket_length, bracket_wall_thickness);

			// Lower rail, knob on top
			translate([x_offset, 0, z_offset])
				rotate(180, [1, 0, 0])
				basicBracketWithHex(bracket_length, bracket_wall_thickness);
			railConnector(x_offset, z_offset);
		}

		basicBracket(bracket_length + 0.1, 0);
		translate([x_offset, 0, z_offset])
			basicBracket(bracket_length + 0.1, 0);
	}
}

module followFocusBracket () {
	gearbox_overhang = 30;
	plate_length = follow_focus_bracket_length;
	plate_width = tube_distance + tube_radius * 4 + gearbox_overhang;
	attachment_height = 15;

	difference () {
		union () {	
			// Angled groove insert
			translate([gearbox_overhang / 2, 0, angle_groove_height / 2])
				rotate(45, [1, 0, 0])
				cube(size = [ plate_width, follow_focus_groove_size, follow_focus_groove_size ], center = true);
			// Top plate
			translate([gearbox_overhang / 2, 0, angle_groove_height * 0.75 ])
				cube(size = [ plate_width, plate_length, angle_groove_height * 0.5 ], center = true);

	/*
			
			// Attachment point of gearbox and gear
			translate([plate_width / 2 - plate_length / 2, 0, angle_groove_height + attachment_height / 2 - 0.1])
				difference () {
					cube(size = [ plate_length, plate_length, attachment_height ], center = true);
				translate([0, 0, 0])
					rotate(90, [0, 1, 0])
					cylinder(r = gearbox_hole_radius, h = plate_length + 0.1, center = true, $fn = 20);
				}
	*/
	
		}
		union () {
			// Screw slide hole
			translate([0, 0, angle_groove_height / 2 ])
				cube(size = [ tube_distance - 15, screw_hole_radius * 2, angle_groove_height + 0.1 ], center = true);

			// Taper the slide hole with a tear drop
			for (left_right = [-1, 1])  {	
				translate([ left_right * (tube_distance - 15) / 2, 0, 5 ])
					rotate(90 * (left_right - 1), [0, 0, 1])
					tearDrop(10, screw_hole_radius);
			}
		}
	}
}

module followFocusPlate () {
	gearbox_overhang = 30;
	plate_length = tube_distance + tube_radius * 4 + gearbox_overhang;
	difference () {
		union () {
			translate([0, 0, bracket_top_groove_depth / 2 ])
				cube(size = [ tube_distance - 10, follow_focus_bracket_length, bracket_top_groove_depth ], center = true);
			translate([gearbox_overhang / 2, 0, bracket_top_groove_depth + angle_groove_height / 4 + 0.5 - 0.1 ])
				cube(size = [ plate_length, follow_focus_bracket_length, angle_groove_height / 2 + 1 ], center = true);
		}
	
		union () {
			// Angled groove
			translate([gearbox_overhang / 2, 0, bracket_top_groove_depth + angle_groove_height / 2 + 1 - 0.1 ])
				rotate(45, [1, 0, 0])
				cube(size = [ plate_length + 2, follow_focus_groove_size, follow_focus_groove_size ], center = true);
			
			// Screw hole in center
			translate([0, 0, bracket_top_groove_depth])
				cylinder(r = follow_focus_plate_bolt_radius, h = bracket_top_groove_depth * 4, center = true, $fn = 20);

			// Nut hole, hex shaped, underneath
			translate([ 0, 0, follow_focus_plate_bolt_hex_depth / 2 - 0.1 ])
				rotate(30, [0, 0, 1])
				regHexagon(follow_focus_plate_bolt_hex, follow_focus_plate_bolt_hex_depth);
		}
	}
}

module bracketWithDSLR () {
	nut_plate_height = bracket_bridge_space / 2 + bracket_wall_thickness
		+ dslr_access_height + dslr_top_thickness;
	plate_width = tube_distance + tube_radius * 4;
	access_hole_rounding_radius = 5;

	difference () {
		// Construct larger object which will be subtracted from
		union () {
			basicBracket(dslr_bracket_length, bracket_wall_thickness);
	
			// Nut plate
			translate([ 0, 0, nut_plate_height / 2 ])
				cube(size = [ plate_width, dslr_bracket_length, nut_plate_height ], center = true);
		}
		
		union () {
			basicBracket(dslr_bracket_length + 10, 0);
			
			// Screw hole for camera
			translate([0, 0, nut_plate_height - (nut_plate_height - dslr_access_height) / 2])
				cylinder(h = nut_plate_height - dslr_access_height, center = true, r = camera_hole_radius, $fn = 20);
	
			// Nut hole, hex shaped
			translate([ 0, 0, nut_plate_height])
				rotate(30, [0, 0, 1])
				regHexagon(camera_hex_size, 6);

			// Screw hole for bridge
			translate([0, 0, 0])
				cylinder(h = nut_plate_height - dslr_access_height, center = true, r = screw_hole_radius, $fn = 20);

			// Nut hole, hex shaped, for bridge
			translate([ 0, 0, bracket_wall_thickness * 2 + bracket_bridge_space / 2 - 0.9  ])
				rotate(30, [0, 0, 1])
				regHexagon(hex_size, 2);

			// Nut and knob access ("access hole")
			translate([ 0, 0, dslr_access_height / 2 + bracket_wall_thickness * 2 + bracket_bridge_space / 2 ])
				cube(size = [
					tube_distance - bracket_wall_thickness * 2,
					dslr_bracket_length + 1,
					dslr_access_height
				], center = true, edge_radius = access_hole_rounding_radius);
		}
	}
}

module bracketWithHexGroove () {
	nut_plate_height = bracket_wall_thickness + tube_radius;
	nut_plate_length = tube_distance + tube_radius * 4;
	difference () {
		// Construct larger object which will be subtracted from
		union () {
			basicBracket(bracket_length, bracket_wall_thickness);
	
			// Nut plate
			translate([ 0, 0, nut_plate_height / 2 ])
				cube(size = [ nut_plate_length, bracket_length, nut_plate_height ], center = true);
		}
		
		union () {
			basicBracket(bracket_length + 10, 0);
			
			// Screw hole
			cylinder(h = nut_plate_height * 2 + 1, center = true, r = screw_hole_radius, $fn = 20);
	
			// Nut hole, hex shaped, from just above basicBracket to to nut plate
			translate([
					0, 0,
				bracket_bridge_space / 2 + bracket_wall_thickness + 0.1 +
						(nut_plate_height - bracket_bridge_space / 2 - bracket_wall_thickness) / 2
				])
				rotate(30, [0, 0, 1])
				regHexagon(hex_size, nut_plate_height - bracket_bridge_space / 2 - bracket_wall_thickness);
	
			// Top groove
			translate([ 0, 0, nut_plate_height - (bracket_top_groove_depth / 2) + 0.1 ])
				cube(size = [ tube_distance - 10, bracket_length + 0.1, bracket_top_groove_depth ], center = true);
		}
	}
}

/// Helper objects

module rails (length) {
	for (left_right = [-1, 1]) {
		translate([ left_right * (tube_distance / 2 + tube_radius), 0, 0 ]) 
			rotate(90, [ 1, 0, 0 ])
			cylinder(h = length, r = tube_radius - 0.2, center = true, $fn = 100);
/*
		// Draw three centered rails just for demonstration sake
		rotate(90, [ 1, 0, 0 ])
			cylinder(h = length, r = tube_radius - 0.2, center = true, $fn = 100);
		translate([ left_right * tube_diameter, 0, 0 ]) 
			rotate(90, [ 1, 0, 0 ])
			cylinder(h = length, r = tube_radius - 0.2, center = true, $fn = 100);
*/
	}
}

module basicBracketWithHex (length, expand_thickness) {
	hex_plate_z = bracket_wall_thickness + bracket_bridge_space / 2 + hex_height / 2;
	difference () {
		basicBracket(length, expand_thickness);
		
		// Screw hole
		cylinder(h = hex_plate_z * 3 + 1, center = true, r = screw_hole_radius, $fn = 20);

		// Nut hole, hex shaped, for bridge
		translate([ 0, 0, hex_plate_z + 0.1 ])
			rotate(30, [0, 0, 1])
			regHexagon(hex_size, hex_height);
	}
}

module basicBracket (length, expand_thickness) {
	excess = 0; // set to 1 if you want to avoid shared planes
	difference () {
		union () {
			// Left and right tube (with excess of 2)
			for (left_right = [-1, 1]) {
				translate([ left_right * (tube_distance / 2 + tube_radius), 0, 0 ]) 
					rotate(90, [ 1, 0, 0 ])
					cylinder(h = length + 2 * excess, r = tube_radius + expand_thickness, center = true);
			}
			
			// Bridge between tubes (with excess of 4)
			cube(size = [
				tube_distance + tube_radius * 2,
				length + 4 * excess,
				expand_thickness * 4 + bracket_bridge_space - 0.2
			], center = true);
		}

		if (excess > 0) {
			// Crop off the excess
			for (front_back = [-1, 1]) {
				translate([0, front_back * (length / 2 + 2), 0])
				cube(size = [
					tube_distance + tube_radius * 4 + expand_thickness * 2 + 1,
					4,
					tube_radius * 2 + expand_thickness * 2 + 1
				], center = true);
			}
		}
	}
}

module railConnector (x_offset, z_offset) {
	// Calculate the x offset from center tube to center tube
	tube_x_offset = -1 * (abs(x_offset) - tube_distance - tube_diameter);
	
	angle_bracket_connector_width = sqrt(
		abs(tube_x_offset * tube_x_offset) + abs(z_offset * z_offset)
	);
	
	angle_bracket_connector_angle = atan(z_offset / tube_x_offset);

	slot_width = angle_bracket_connector_width - tube_diameter * 2;	
	slot_height = angle_bracket_connector_height - bracket_wall_thickness * 2;

	split_width = angle_bracket_connector_width / 2;	
	split_endcrop_width = (angle_bracket_connector_width - split_width) / 2;

	screw_recess_radius = screw_washer_radius;
	screw_recess_depth = angle_bracket_connector_height / 5;

	translate([x_offset / 2, 0, z_offset / 2])
		rotate(-angle_bracket_connector_angle, [0, 1, 0])
		difference () {
			cube([angle_bracket_connector_width, bracket_length, angle_bracket_connector_height],
				center = true);
			if (split == true) {
				union () {
					// Screw hole and recess
					for (left_right = [-1, 1]) {
						translate([left_right * split_width / 4, 0, 0])
							rotate(90, [0, 0, 1])
							cylinder(r = screw_hole_radius, h = angle_bracket_connector_height + 1, center = true, $fn = 20);
							//tearDrop(radius = screw_hole_radius, height = angle_bracket_connector_height + 1);
						translate([left_right * split_width / 4, 0, -1 * (angle_bracket_connector_height / 2) + screw_recess_depth / 2 - 0.1])
							rotate(90, [0, 0, 1])
							cylinder(r = screw_recess_radius, h = screw_recess_depth, center = true, $fn = 20);
							//tearDrop(radius = screw_recess_radius, height = screw_recess_depth);
					}

					// Clip the top of the connector
					translate([0, 0, angle_bracket_connector_height / 4])
						cube([ split_width, bracket_length + 0.1, angle_bracket_connector_height / 2 + 0.1 ],
							center = true);
					// Clip the end of the connector
					translate([ -1 * (split_width + split_endcrop_width) / 2, 0, 0 ])
						cube([split_endcrop_width + 0.2, bracket_length + 0.2, angle_bracket_connector_height + 0.1 ], center = true);
				}
			}
/*
				union () {
					cube([slot_width, bracket_length + 0.1, slot_height], center = true);
					for (left_right = [-1, 1]) {
						translate([left_right * slot_width / 2, 0, 0])
							rotate(90, [1, 0, 0])
							cylinder(r = slot_height / 2, h = bracket_length + 0.1, center = true);
					}
				}
*/
		}
}

// Generic modules

module tearDrop (height, radius) {
	union () {
		cylinder(h = height, r = radius, center = true, $fn = 20);
		intersection () {
			rotate(45, [0, 0, 1]) cube([radius * 2, radius * 2, height], center = true);
			translate([2.75 * radius, 0, 0]) cube ([radius * 4, radius * 2, height + 1], center = true);
		}
	}
}

module box(xBox, yBox, zBox) {
	scale ([xBox, yBox, zBox]) {
		cube(1, true);
	}
}

module regHexagon(boxWidth, height) {
	// boxWidth=size*1.75;
	size = boxWidth / 1.75;
	union () {
		for (angle = [0, 60, -60]) {
			rotate([0, 0, angle]) box(size, boxWidth, height);
		}
	}
}

module hollowHexagon(size, hexaHeight, thickness) {
	difference() {
		regHexagon(size, hexaHeight);
		regHexagon(size - thickness, hexaHeight + 2);
	}
}
