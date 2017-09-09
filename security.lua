--digiline-controlled taser
function tasePlayer(obj)
	local pos = obj:get_pos()
	minetest.add_particlespawner({
		amount = 20,
		time = 1,
		minpos = {x=pos.x - 0.5, y=pos.y, z=pos.z - 0.5},
		maxpos = {x=pos.x + 0.5, y=pos.y + 2, z=pos.z + 0.5},
		minvel = {x=-0.1, y=-0.1, z=-0.1},
		maxvel = {x=0.1, y=0.1, z=0.1},
		minacc = {x=0, y=0, z=0},
		maxacc = {x=0, y=0, z=0},
		minexptime = 0.5,
		maxexptime = 1,
		minsize = 4,
		maxsixe = 10,
		collisiondetection = false,
		vertical = false,
		texture = "taser_particle.png"
	})
	default.player_attached[obj:get_player_name()] = true
	default.player_set_animation(obj, "lay")
	local nothing = minetest.add_entity(pos, "mmm:nothing")
	obj:set_attach(nothing, "", {x=0,y=10,z=0}, {x=0,y=0,z=0})
	minetest.after(5, detasePlayer, obj)
	minetest.after(5, function (nothing) nothing:remove() end, nothing)
end

function detasePlayer(player)
	player:set_detach()
	default.player_attached[player:get_player_name()] = false
	default.player_set_animation(player, "stand")
end

local taserBox = {
			type = "fixed",
			fixed = {
				{-0.3, -0.5, -0.3, 0.3, -0.2, 0.3},
				{-0.2, -0.2, -0.2, 0.2, 0.5, 0.2}
				},
			}

minetest.register_entity("mmm:nothing", {
	hp_max = 1000,
	physical = true,
	weight = 5,
	collisionbox = {-0.35, -0, -0.35, 0.35, 1.8, 0.35},
	visual = "mesh",
	mesh = "cube.obj",
	textures = {"nothing.png"},
	visual_size = 1,
	is_visible = true,
	makes_footstep_sound = false,
    automatic_rotate = false,
})

minetest.register_node("mmm:security_taser", {
		description = "Digiline-activated Taser",
		tiles = {"security_taser.png"},
		drawtype = "mesh",
		mesh = "taser.obj",
		groups = {snappy = 1},
		selection_box = taserBox,
		collision_box = taserBox,
		after_place_node = function(pos, placer, itemstack, pointed_thing)
			local meta = minetest.get_meta(pos)
			meta:set_string("formspec",
			"size[6,2]" ..
			"field[0.75,0.5;5,1;channel;Channel;]" ..
			"button_exit[2.5,1.5;1,0.5;exit;Exit]"
			)
		end,
		on_receive_fields = function(pos, formname, fields, sender)
			local name = sender:get_player_name()
			local meta = minetest.get_meta(pos)
			if minetest.is_protected(pos, name) then
				minetest.chat_send_player(name, "You don't own this system!")
				minetest.record_protection_violation(pos, name)
				return
			end
			if fields.channel then
				meta:set_string("digichannel", fields.channel)
			end
		end,
		digiline = {
			receptor = {},
			effector = {
				action = function (pos, node, msgChan, msg)
					local meta = minetest.get_meta(pos)
					local searchChan = meta:get_string("digichannel")
					local detectedPlayers = minetest.get_objects_inside_radius(pos, 4)
					if msgChan == searchChan then
						for pName in msg:gmatch("[^,]+") do
							for _,obj in ipairs(detectedPlayers) do
								if obj:is_player() then
									if obj:get_player_name() == pName then
										tasePlayer(obj)
									end
								end
							end
						end
					end
				end,
			},
		},
})
