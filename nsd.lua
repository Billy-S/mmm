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
	groups = {snappy = 2, not_in_creative_inventory = 1},
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
		if minetest.is_protected(pos, name) then
			minetest.chat_send_player(name, "You don't own this NSD!")
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
