-- Mass Mayhem Mod (MMM)
-- Written by BillyS
-- license: whatever

local modPath = minetest.get_modpath(minetest.get_current_modname())
minetest.register_privilege("freeze", { description = "Allows one to freeze/defrost players" })

dofile(modPath .. "/security.lua")
dofile(modPath .. "/nsd.lua")
dofile(modPath .. "/admin_teleporter.lua")
dofile(modPath .. "/space.lua")

local defrostTime = 15
local spawnPos = minetest.setting_get_pos("spawn")
if not spawnPos then spawnPos = {x=0, y=49, z=0} end
frozen_players = {}

function freezePlayer (pName)
	local player = minetest.env:get_player_by_name(pName)
	if player and not frozen_players[pName] then
		player:set_physics_override({speed = 0, jump = 0, gravity = 1.0, sneak = false, sneak_glitch = false})
		minetest.chat_send_player(pName, "You have been frozen!")
		frozen_players[pName] = true
		return true
	end
end

function defrostPlayer (pName)
	local player = minetest.env:get_player_by_name(pName)
	if player and frozen_players[pName] then
		player:set_physics_override({speed = 1.0, jump = 1.0, gravity = 1.0, sneak = true, sneak_glitch = false})
		minetest.chat_send_player(pName, "You have been defrosted!")
		frozen_players[pName] = false
		return true
	end
end

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
		if freezeCheck(player) then
			freezePlayer (player:get_player_name())
		elseif frozen_players[player:get_player_name()] then
			minetest.after(defrostTime, defrostPlayer, player:get_player_name())
		end
		if spawnCheck(player) then
			player:setpos(spawnPos)
		end
	end
end


minetest.register_chatcommand("freeze", {
	params = "<player>",
	description = "Immobilizes a player",
	privs = {freeze=true},
	func = function (name, param)
		freezePlayer(param)
	end,	
})

minetest.register_chatcommand("defrost", {
	params = "<player>",
	description = "Remobilizes a player",
	privs = {freeze=true},
	func = function (name, param)
		defrostPlayer(param)
	end,	
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
	groups = {water = 3, liquid = 3, puts_out_fire = 3, cools_lava = 3, not_in_creative_inventory = 1},
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
	groups = {water = 3, liquid = 3, not_in_creative_inventory = 1},
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
			"Liquid Nitrogen Bucket",
			{not_in_creative_inventory = 1}
		)
		bucket.register_liquid (
			"mmm:spawn_fluid",
			"mmm:spawn_fluid_flowing",
			"mmm:spawn_fluid_bucket",
			"sf_bucket.png",
			"Spawn Fluid Bucket",
			{not_in_creative_inventory = 1}
		)
	end
end

minetest.register_node("mmm:super_ice", {
	description = "Super Ice",
	tiles = {"super_ice.png"},
	groups = {cracky = 3, puts_out_fire = 1, cools_lava = 1},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_abm({
	label = "Liquid Nitrogen And Water",
	nodenames = {"default:water_source", "default:water_flowing"},
	neighbors = {"mmm:liquid_nitrogen", "mmm:liquid_nitrogen_flowing"}, 
	interval = 20.0,
	chance = 2,
	action = function(pos, node, active_object_count, active_object_count_wider)
		minetest.set_node(pos, {name = "default:ice"})
	end
})

minetest.register_abm({
	label = "Liquid Nitrogen And Spawn Fluid",
	nodenames = {"mmm:spawn_fluid", "mmm:spawn_fluid_flowing"},
	neighbors = {"mmm:liquid_nitrogen", "mmm:liquid_nitrogen_flowing"}, 
	interval = 20.0,
	chance = 2,
	action = function(pos, node, active_object_count, active_object_count_wider)
		minetest.set_node(pos, {name = "mmm:super_ice"})
	end
})

local on_ice = {}
local function round(x)
	return math.floor(x + 0.5)
end

minetest.register_globalstep(liquidCheck)

minetest.register_globalstep(function (dtime)
	for _,player in pairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		if not frozen_players[name] then
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
	end
end)
