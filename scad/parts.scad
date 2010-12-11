// Units are in mm

/// Universal variables

mm_per_inch = 25.4;

// Stop time at this value
$t = 0;

render_fast = false;

// Create a variable that goes from 0 .. 1 .. 0 over time as a curve
sin_t = sin($t * 180);

/// User variables

tube_diameter = 5/8 * mm_per_inch;
tube_radius = tube_diameter / 2;

// Distance from surface of one tube to surface of the other
tube_distance = tube_diameter * 3;

bracket_length = 15; // length along tube
bracket_bridge_space = 2; // size of space which gets tightened
bracket_wall_thickness = 2;

hex_size = 4.5;
hex_height = 2;

bracket_top_groove_depth = 2;

screw_hole_radius = 2;
gearbox_hole_radius = 1;
small_screw_hole_radius = 1.5;

camera_hole_radius = (1/4 * mm_per_inch) / 2;
camera_hex_size = 7;

// Follow focus bracket and plate
follow_focus_groove_size = 4;

// a^2 + b^2 = c^2, a = b = follow_focus_groove_size, c = sqrt(a^2 * 2)
angle_groove_height = sqrt((follow_focus_groove_size * follow_focus_groove_size) * 2);

// Angled rail connector
lower_rails_x_offset = -110;
lower_rails_z_offset = -40;
angle_bracket_connector_height = tube_diameter - bracket_wall_thickness * 2;

/// Ready to print objects

/// Rail connector bracket, split (x 4)
// rotate(90, [1, 0, 0]) railConnectorBracketSplit(lower_rails_x_offset, lower_rails_z_offset);

/// DSLR mounting bracket
// rotate(90, [1, 0, 0]) bracketWithDSLR(15);

/// Follow focus bracket
// rotate(90, [1, 0, 0]) bracketWithHexGroove();

/// Follow focus plate
// rotate(180, [1, 0, 0]) followFocusPlate();

/// Follow focus bracket
// rotate(90, [0, 1, 0]) followFocusBracket();

/// Preview objects

rig();
//previewSplitConnectorBrackets();

/// Display objects 

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

	bracketWithDSLR(15);

	translate([0, 0, 30])
		rotate(180, [0, 0, 1])
		% canonT2i();

	translate([0, -80, 0]) followFocus();
	
	// Lower rails	

	translate([lower_rails_x_offset, 0, lower_rails_z_offset]) {


		translate([0, 70, 0])
			% rails(18 * mm_per_inch);
	}
}

module canonT2i () {
	width = 126;
	height = 75; // sans viewfinder
	depth = 60;
	bottom_depth = 40;
	viewfinder_width = 35;
	viewfinder_height = 22;
	viewfinder_x_offset = -15;

	lens_mount_diameter = 65;
	lens_mount_radius = lens_mount_diameter / 2;
	
	// Center the object so that it pivots on the screw hole
	translate([-viewfinder_x_offset, 10, 0]) {

		difference () {
			union () {
				// Base body
				translate([0, 0, height / 2])
					cube([ width, depth, height ], center = true);
				// Viewfinder
				translate([viewfinder_x_offset, 0, height + viewfinder_height / 2])
					cube([ viewfinder_width, depth, viewfinder_height ], center = true);
			}
			
			// Lens mount
			translate([viewfinder_x_offset, depth / 2, lens_mount_radius + 5])
				rotate(90, [1, 0, 0])
				cylinder(r = lens_mount_radius, h = 10, center = true); 
	
			// Bevel the front underside up to the lens mount
			translate([ 0, depth / 2 - 20 / 2 + 1, 0 ])
				rotate(10, [1, 0, 0])
				cube([ width + 0.1, 20 + 0.1, 5 ], center = true);
		}
	
		translate([viewfinder_x_offset, depth / 2, 5 + lens_mount_radius])
			rotate(-90, [1, 0, 0])
			canon85_18();
	}
}

module canon28_18 () {
	canonLens(focus_diameter = 72, focus_offset = 27, focus_width = 11, length = 56, lens_diameter = 58);
}

module canon85_18 () {
	canonLens(focus_diameter = 74.8, focus_offset = 29, focus_width = 17, length = 70, lens_diameter = 58);
}

module canonLens () {
	// Draw canon lens, assuming we're centered at lens mount point
	lens_mount_diameter = 65;
	union () {
		translate([0, 0, length / 2])
			cylinder(r = lens_mount_diameter / 2, h = length, center = true);
		translate([0, 0, focus_offset + focus_width / 2])
			cylinder(r = focus_diameter / 2, h = focus_width, center = true);
		translate([0, 0, length])
			cylinder(r = lens_diameter / 2, h = 4, center = true);
	}
}

module followFocus () {
	bracketWithHexGroove();
	translate([0, 0, tube_radius + bracket_wall_thickness - bracket_top_groove_depth + sin_t * 8])
		followFocusPlate();
	translate([sin_t * 8, 0, tube_radius + bracket_wall_thickness + 0.9 + sin_t * 16])
		followFocusBracket();
}

/// Printable objects

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
	plate_length = follow_focus_groove_size * 3;
	plate_width = tube_distance + tube_radius * 4;
	attachment_height = 15;

	difference () {
		union () {	
			// Angled groove insert
			translate([0, 0, angle_groove_height / 2])
				rotate(45, [1, 0, 0])
				cube(size = [ plate_width, follow_focus_groove_size, follow_focus_groove_size ], center = true);
			// Top plate
			translate([0, 0, angle_groove_height * 0.75 ])
				cube(size = [ plate_width, plate_length, angle_groove_height * 0.5 ], center = true);
			
			// Attachment point of gearbox and gear
			translate([plate_width / 2 - plate_length / 2, 0, angle_groove_height + attachment_height / 2 - 0.1])
				difference () {
					cube(size = [ plate_length, plate_length, attachment_height ], center = true);
				translate([0, 0, 0])
					rotate(90, [0, 1, 0])
					cylinder(r = gearbox_hole_radius, h = plate_length + 0.1, center = true, $fn = 20);
				}
			
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
	plate_length = tube_distance + tube_radius * 4;
	difference () {
		union () {
			translate([0, 0, bracket_top_groove_depth / 2 ])
				cube(size = [ tube_distance - 10, bracket_length, bracket_top_groove_depth ], center = true);
			translate([0, 0, bracket_top_groove_depth + angle_groove_height / 4 + 0.5 - 0.1 ])
				cube(size = [ plate_length, bracket_length, angle_groove_height / 2 + 1 ], center = true);
		}
	
		union () {
			// Angled groove
			translate([0, 0, bracket_top_groove_depth + angle_groove_height / 2 + 1 - 0.1 ])
				rotate(45, [1, 0, 0])
				cube(size = [ plate_length + 2, follow_focus_groove_size, follow_focus_groove_size ], center = true);
			
			// Screw hole in center
			translate([0, 0, bracket_top_groove_depth])
				cylinder(r = screw_hole_radius, h = bracket_top_groove_depth * 3, center = true, $fn = 20);

			// Nut hole, hex shaped, underneath
			translate([ 0, 0, bracket_top_groove_depth/ 2 - 0.2 ])
				rotate(30, [0, 0, 1])
				regHexagon(hex_size, bracket_top_groove_depth + 0.3);

		}
	}
}

module bracketWithDSLR (access_hole_height) {
	nut_plate_height = bracket_bridge_space / 2 + bracket_wall_thickness + access_hole_height + 12;
	// Since this has to support the camera, the length needs to be a bit larger
	bracket_length = bracket_length * 2;
	plate_width = tube_distance + tube_radius * 4;

	difference () {
		// Construct larger object which will be subtracted from
		union () {
			basicBracket(bracket_length, bracket_wall_thickness);
	
			// Nut plate
			translate([ 0, 0, nut_plate_height / 2 ])
				cube(size = [ plate_width, bracket_length, nut_plate_height ], center = true);
		}
		
		union () {
			basicBracket(bracket_length + 10, 0);
			
			// Screw hole for camera
			translate([0, 0, nut_plate_height - (nut_plate_height - access_hole_height) / 2])
				cylinder(h = nut_plate_height - access_hole_height, center = true, r = camera_hole_radius, $fn = 20);
	
			// Nut hole, hex shaped
			translate([ 0, 0, nut_plate_height])
				rotate(30, [0, 0, 1])
				regHexagon(camera_hex_size, 6);

			// Screw hole for bridge
			translate([0, 0, 0])
				cylinder(h = nut_plate_height - access_hole_height, center = true, r = screw_hole_radius, $fn = 20);

			// Nut hole, hex shaped, for bridge
			translate([ 0, 0, bracket_wall_thickness + bracket_bridge_space / 2 + 1.1 ])
				rotate(30, [0, 0, 1])
				regHexagon(hex_size, 2);

			// Nut and knob access ("access hole")
			translate([ 0, 0, access_hole_height / 2 + bracket_wall_thickness * 2 + bracket_bridge_space / 2 ])
				cube(size = [
					tube_distance - bracket_wall_thickness * 2,
					bracket_length + 1,
					access_hole_height
				], center = true);
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
	screw_hole_radius = small_screw_hole_radius;

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

	screw_recess_radius = screw_hole_radius * 2.5;
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

module regHexagon(size, height) {
	boxWidth=size*1.75;
	union(){
		box(size, boxWidth, height);
		rotate(60, [0,0,1]){
			box(size, boxWidth, height);
		}
		rotate(-60, [0,0,1]){
			box(size, boxWidth, height);
		}
	}
}

module hollowHexagon(size, hexaHeight, thickness) {
	difference() {
		regHexagon(size, hexaHeight);
		regHexagon(size - thickness, hexaHeight + 2);
	}
}