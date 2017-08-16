-- Mass Mayhem Mod (MMM)
-- Written by BillyS
-- license: whatever

local jailMod = false
for i, name in ipairs(minetest.get_modnames()) do
	if name == "jail" then
		jailMod = true
	end
end

local checkDelay = 5 -- If this mod gets too laggy, increase this number
local defrostTime = 15
local spawnPos = {x=0, y=49, z=0}
local expRad = 3

local function freezeCheck(player)
	local pos = player:get_pos()
	local pos2 = player:get_pos()
	pos2.y = pos2.y + 1
	local nodeName = minetest.get_node(pos).name;
	if nodeName == "mmm:liquid_nitrogen" or nodeName == "mmm:liquid_nitrogen_flowing" then
		return true
	end
	local nodeName2 = minetest.get_node(pos2).name;
	if nodeName2 == "mmm:liquid_nitrogen" or nodeName2 == "mmm:liquid_nitrogen_flowing" then
		return true
	end
end

local function spawnCheck(player)
	local pos = player:get_pos()
	local pos2 = player:get_pos()
	pos2.y = pos2.y + 1
	local nodeName = minetest.get_node(pos).name;
	if nodeName == "mmm:spawn_fluid" or nodeName == "mmm:spawn_fluid_flowing" then
		return true
	end
	local nodeName2 = minetest.get_node(pos2).name;
	if nodeName2 == "mmm:spawn_fluid" or nodeName2 == "mmm:spawn_fluid_flowing" then
		return true
	end
end

local function liquidCheck()
	for _, player in ipairs(minetest.get_connected_players()) do
		if jailMod then
			if freezeCheck(player) then
				freezePlayer (player:get_player_name())
			elseif frozen_players[player:get_player_name()] then
				minetest.after(defrostTime, defrostPlayer, player:get_player_name())
			end
		end
		if spawnCheck(player) then
			player:setpos(spawnPos)
		end
	end
	minetest.after(checkDelay, liquidCheck)
end

--nuclear self destruct

minetest.register_node("mmm:nsd", {
	description = "Nuclear Self Destruct (NSD)",
	tiles = {
		"nuke_top.png",
		"nuke_sides.png",
		"nuke_sides.png",
		"nuke_sides.png",
		"nuke_sides.png",
		"nuke_sides.png",
	},
	is_ground_content = false,
	groups = {snappy = 2},
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", 
		"size[4,4]" ..
		"label[-0.1,0;WARNING! This is a Self-Destruct Unit!]" ..
		"pwdfield[0.75,1.25;3,1;passwd;Password;]" ..
		"field[0.75,2.5;3,1;channel;Channel;]" ..
		"button_exit[0.5,3.25;3,1;setpwd;Done]"
		)
		meta:set_string("owner", placer:get_player_name())
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		local name = sender:get_player_name()
		local meta = minetest.get_meta(pos)
		if minetest.is_protected(pos, name) and not minetest.check_player_privs(name, {protection_bypass=true}) then
			minetest.record_protection_violation(pos, name)
			return
		end
		if fields.channel then
			meta:set_string("digichannel", fields.channel)
		else return end
		if fields.passwd then
			meta:set_string("passwd", fields.passwd)
		else return end
		meta:set_string("placer", sender)
	end,
	digiline = {
		receptor = {},
		effector = {
			action = function (pos, node, msgChan, msg)
				local meta = minetest.get_meta(pos)
				local searchChan = meta:get_string("digichannel")
				local passwd = meta:get_string("passwd")
				local owner = meta:get_string("owner")
				local air = minetest.get_content_id("air")
				if msgChan == searchChan then
					if msg == passwd then
						for z = -expRad, expRad do
							for y = -expRad, expRad do
								for x = -expRad, expRad do
									local nodePos = {x = pos.x + x, y = pos.y + y, z = pos.z + z}
									if not minetest.is_protected(nodePos, owner) then
										if (x * x) + (y * y) + (z * z) <= (expRad * expRad) then
											minetest.set_node(nodePos, {name="air"})
										end
									end
								end
							end
						end
					end
				end
			end
		},
	}
})

--liquid nitrogen

minetest.register_node("mmm:liquid_nitrogen", {
	description = "Liquid Nitrogen",
	drawtype = "liquid",
	tiles = {
		{
			name = "ln_source_animated.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0,
			},
		},
	},
	special_tiles = {
		-- New-style water source material (mostly unused)
		{
			name = "ln_source_animated.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0,
			},
			backface_culling = false,
		},
	},
	alpha = 250,
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquidtype = "source",
	liquid_alternative_flowing = "mmm:liquid_nitrogen_flowing",
	liquid_alternative_source = "mmm:liquid_nitrogen",
	liquid_viscosity = 2,
	post_effect_color = {a = 103, r = 30, g = 60, b = 90},
	groups = {water = 3, liquid = 3, puts_out_fire = 3, cools_lava = 3},
})

minetest.register_node("mmm:liquid_nitrogen_flowing", {
	description = "Flowing Liquid Nitrogen",
	drawtype = "flowingliquid",
	tiles = {"ln_flowing_animated.png"},
	special_tiles = {
		{
			name = "ln_flowing_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2,
			},
		},
		{
			name = "ln_flowing_animated.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2,
			},
		},
	},
	alpha = 250,
	paramtype = "light",
	paramtype2 = "flowingliquid",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquidtype = "flowing",
	liquid_alternative_flowing = "mmm:liquid_nitrogen_flowing",
	liquid_alternative_source = "mmm:liquid_nitrogen",
	liquid_viscosity = 2,
	post_effect_color = {a = 103, r = 30, g = 60, b = 90},
	groups = {water = 3, liquid = 3, puts_out_fire = 3,
		not_in_creative_inventory = 1, cools_lava = 3},
})

-- spawn fluid

minetest.register_node("mmm:spawn_fluid", {
	description = "Spawn Fluid",
	drawtype = "liquid",
	tiles = {
		{
			name = "sf_source.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0,
			},
		},
	},
	special_tiles = {
		-- New-style water source material (mostly unused)
		{
			name = "sf_source.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0,
			},
			backface_culling = false,
		},
	},
	alpha = 250,
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquidtype = "source",
	liquid_alternative_flowing = "mmm:spawn_fluid_flowing",
	liquid_alternative_source = "mmm:spawn_fluid",
	liquid_viscosity = 2,
	post_effect_color = {a = 103, r = 30, g = 60, b = 90},
	groups = {water = 3, liquid = 3},
})

minetest.register_node("mmm:spawn_fluid_flowing", {
	description = "Flowing Spawn Fluid",
	drawtype = "flowingliquid",
	tiles = {"sf_flowing_animated.png"},
	special_tiles = {
		{
			name = "sf_flowing_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2,
			},
		},
		{
			name = "sf_flowing_animated.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2,
			},
		},
	},
	alpha = 250,
	paramtype = "light",
	paramtype2 = "flowingliquid",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquidtype = "flowing",
	liquid_alternative_flowing = "mmm:spawn_fluid_flowing",
	liquid_alternative_source = "mmm:spawn_fluid",
	liquid_viscosity = 2,
	post_effect_color = {a = 103, r = 30, g = 60, b = 90},
	groups = {water = 3, liquid = 3, not_in_creative_inventory = 1},
})

if bucket then
	if bucket.register_liquid then
		bucket.register_liquid (
			"mmm:liquid_nitrogen",
			"mmm:liquid_nitrogen_flowing",
			"mmm:liquid_nitrogen_bucket",
			"ln_bucket.png",
			"Liquid Nitrogen Bucket"
		)
		bucket.register_liquid (
			"mmm:spawn_fluid",
			"mmm:spawn_fluid_flowing",
			"mmm:spawn_fluid_bucket",
			"sf_bucket.png",
			"Spawn Fluid Bucket"
		)
	end
end

minetest.after(checkDelay, liquidCheck)

minetest.register_node("mmm:super_ice", {
	description = "Super Ice",
	tiles = {"super_ice.png"},
	groups = {cracky = 3, puts_out_fire = 1, cools_lava = 1},
	sounds = default.node_sound_glass_defaults(),
})

local on_ice = {}
local function round(x)
	return math.floor(x + 0.5)
end

minetest.register_globalstep(function (dtime)
	for _,player in pairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		
		local pos = player:getpos()
		local rounded = {x=round(pos.x), y=round(pos.y), z=round(pos.z)}
		local below = vector.subtract(rounded, {x=0,y=1,z=0})
		
		if minetest.get_node(below).name == "mmm:super_ice" then
			if not on_ice[name] then
				on_ice[name] = true
				player:set_physics_override({speed = -0.1})
			end
		elseif on_ice[name] then
			on_ice[name] = false
			player:set_physics_override({speed = 1})
		end
	end
end)
