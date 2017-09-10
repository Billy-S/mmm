baseGuards = {}

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
	player:set_hp(player:get_hp() - 2)
end

function checkBaseBlock(baseNodePos)
	local meta = minetest.get_meta(baseNodePos)
	if meta:get_string("enabled") == "yes" then
		local allObjs = minetest.get_objects_inside_radius(baseNodePos, tonumber(meta:get_string("radius")))
		for indx,obj in ipairs(allObjs) do
			if obj:is_player() then
				local currPName = obj:get_player_name()
				local allowed = false
				for pName in meta:get_string("allowed"):gmatch("[^,]+") do
					if currPName == pName then
						allowed = true
						break
					end
				end
				if not allowed then
					minetest.chat_send_player(currPName, "You are not allowed in this area")
					obj:set_pos({x=60,y=-2.5, z=267})
				end
			end
		end
	end
end

-- In-place taser

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
	collisionbox = {-0.35, 0, -0.35, 0.35, 1.8, 0.35},
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
			"button_exit[2.5,1.5;1,0.5;okay;Okay]"
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

-- Base guard. Keeps unwanted visitors out of a radius
minetest.register_node("mmm:base_guard", {
	description = "Base Guard",
	tiles = {
		"base_guard_front.png",
		"base_guard_sides.png",
		"base_guard_sides.png",
		"base_guard_sides.png",
		"base_guard_sides.png",
		"base_guard_sides.png",
	},
	is_ground_content = false,
	groups = {snappy = 1, not_in_creative_inventory = 1},
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec",
			"size[4,3]" ..
			"field[0.5,0.5;3,1;radius;Radius;]" ..
			"field[0.5,1.6;3,1;players;Allowed Players;]" ..
			"button_exit[1,2.3;2,1;okay;Okay]" 
		)
		meta:set_string("enabled", "no")
		meta:set_string("allowed", "")
		meta:set_string("radius", "0")
		table.insert(baseGuards, pos)
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		local name = sender:get_player_name()
		local meta = minetest.get_meta(pos)
		minetest.chat_send_all("ran")
		if minetest.is_protected(pos, name) then
			minetest.chat_send_player(name, "You don't own this system!")
			minetest.record_protection_violation(pos, name)
			return
		end
		meta:set_string("enabled", "yes")
		if fields.players then
			meta:set_string("allowed", fields.players)
		end
		if tonumber(fields.radius) then
			meta:set_string("radius", fields.radius)
		end
	end,
	on_destruct = function (pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("enabled", "no")
	end
})

minetest.register_globalstep(function(dtime)
	for _,baseGuard in ipairs(baseGuards) do
		checkBaseBlock(baseGuard)
	end
end)
