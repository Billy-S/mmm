minetest.register_node("mmm:ship_drive", {
	description = "Drive for a spaceship",
	tiles = {
		{
			name = "ship_drive.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 64,
				aspect_h = 64,
				length = 2.0,
			},
		},
	},
	is_ground_content = false,
	groups = {cracky = 2},
	drawtype = "mesh",
	mesh = "ship_drive.obj"
})
