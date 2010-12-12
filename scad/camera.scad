canonT2i();

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