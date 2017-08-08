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
	minetest.after(checkDelay, liquidCheck)
end

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
	tiles = {"sf_flowing.png"},
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

if jailMod then
	minetest.after(checkDelay, liquidCheck)
end
