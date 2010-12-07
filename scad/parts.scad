// Units are in mm

/// User variables

tube_diameter = 15;
tube_radius = tube_diameter / 2;

// Distance from surface of one tube to surface of the other
tube_distance = 60 - tube_diameter;

bracket_length = 20; // length along tube
bracket_bridge_space = 2; // size of space which gets tightened
bracket_wall_thickness = 2;

hex_size = 6;
hex_height = 3;

bracket_top_groove_depth = 2;

screw_hole_radius = 2;
gearbox_hole_radius = 2;
hex_size = 4;

follow_focus_groove_size = 4;
/// a^2 + b^2 = c^2, a = b = follow_focus_groove_size, c = sqrt(a^2 * 2)
angle_groove_height = sqrt((follow_focus_groove_size * follow_focus_groove_size) * 2);

sin_t = sin($t * 180);

/// Main

translate([0, 100, 0])
	bracketWithDSLR(20);

translate([0, 0, 0])
	bracketWithHexGroove();
translate([0, 0, tube_radius + bracket_wall_thickness - bracket_top_groove_depth + sin_t * 4])
	followFocusPlate();
translate([sin_t * 8, 0, tube_radius + bracket_wall_thickness + 0.9 + sin_t * 8])
	followFocusBracket();

// Semi-transparent rails

% rails(300);


/// Final objects

module tearDrop (height, radius) {
	union () {
		cylinder(h = height, r = radius, center = true, $fn = 20);
		intersection () {
			rotate(45, [0, 0, 1]) cube([radius * 2, radius * 2, height], center = true);
			translate([2.75 * radius, 0, 0]) cube ([radius * 4, radius * 2, height + 1], center = true);
		}
	}
}

module followFocusBracket () {
	plate_length = follow_focus_groove_size * 3;
	plate_width = tube_distance + tube_radius * 2;
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
					rotate(90, [1, 0, 0])
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
	difference () {
		union () {
			translate([0, 0, bracket_top_groove_depth / 2 ])
				cube(size = [ tube_distance - 10, bracket_length, bracket_top_groove_depth ], center = true);
			translate([0, 0, bracket_top_groove_depth + angle_groove_height / 4 + 0.5 - 0.1 ])
				cube(size = [ tube_distance + tube_radius * 2, bracket_length, angle_groove_height / 2 + 1 ], center = true);
		}
	
		union () {
			// Angled groove
			translate([0, 0, bracket_top_groove_depth + angle_groove_height / 2 + 1 - 0.1 ])
				rotate(45, [1, 0, 0])
				cube(size = [ tube_distance + tube_radius * 2 + 2, follow_focus_groove_size, follow_focus_groove_size ], center = true);
			
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
	nut_plate_height = bracket_bridge_space / 2 + bracket_wall_thickness + access_hole_height + 6;

	difference () {
		// Construct larger object which will be subtracted from
		union () {
			basicBracket(bracket_length, bracket_wall_thickness);
	
			// Nut plate
			translate([ 0, 0, nut_plate_height / 2 ])
				cube(size = [ tube_distance + tube_radius * 2, bracket_length, nut_plate_height ], center = true);
		}
		
		
		union () {
			basicBracket(bracket_length + 10, 0);
			
			// Screw hole
			cylinder(h = nut_plate_height * 2 + 1, center = true, r = screw_hole_radius, $fn = 20);
	/*
			// Nut hole, hex shaped
			translate([ 0, 0, nut_plate_height])
				rotate(30, [0, 0, 1])
				regHexagon(hex_size, 4);
	*/

			// Nut hole, hex shaped, for bridge
			translate([ 0, 0, bracket_wall_thickness + bracket_bridge_space / 2 + 1.1 ])
				rotate(30, [0, 0, 1])
				regHexagon(hex_size, 2);

			// Nut and knob access
			translate([ 0, 0, access_hole_height / 2 + bracket_wall_thickness * 2 + bracket_bridge_space / 2 ])
			cube(size = [
				tube_distance - bracket_wall_thickness * 2,
				bracket_length + 0.1,
				access_hole_height
			], center = true);
		}
	}
}

module bracketWithHexGroove () {
	nut_plate_height = bracket_wall_thickness + tube_radius;
	difference () {
		// Construct larger object which will be subtracted from
		union () {
			basicBracket(bracket_length, bracket_wall_thickness);
	
			// Nut plate
			translate([ 0, 0, nut_plate_height / 2 ])
				cube(size = [ tube_distance + tube_radius * 2, bracket_length, nut_plate_height ], center = true);
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

module rails (length) {
	for (left_right = [-1, 1]) {
		translate([ left_right * (tube_distance / 2 + tube_radius), 0, 0 ]) 
			rotate(90, [ 1, 0, 0 ])
			cylinder(h = length, r = tube_radius - 0.2, center = true, $fn = 100);
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
				expand_thickness * 2 + bracket_bridge_space
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