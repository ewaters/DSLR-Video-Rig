// Units are in mm

/// User variables

tube_diameter = 15;
tube_radius = tube_diameter / 2;

// Distance from surface of one tube to surface of the other
tube_distance = 45;

bracket_length = 20; // length along tube
bracket_bridge_space = 2; // size of space which gets tightened
bracket_wall_thickness = 2;

hex_size = 6;
hex_height = 3;

bracket_top_groove_depth = 2;

screw_hole_radius = 2;
hex_size = 4;

/// Main

bracketWithDSLR(20);

translate([0, 50, 0])
	bracketWithHexGroove();

// Semi-transparent rails

% rails(300);

/// Final objects

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
			cylinder(h = nut_plate_height * 2 + 1, center = true, r = screw_hole_radius, $fn = 10);
	
			// Nut hole, hex shaped
			translate([ 0, 0, nut_plate_height])
				rotate(30, [0, 0, 1])
				regHexagon(hex_size, 4);

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
			cylinder(h = nut_plate_height * 2 + 1, center = true, r = screw_hole_radius, $fn = 10);
	
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