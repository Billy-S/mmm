--admin teleporter

minetest.register_node("mmm:admin_teleporter", {
	tiles = {"admin_teleporter.png"},
	is_ground_content = false,
	groups = {snappy = 2, not_in_creative_inventory = 1},
	after_place_node = function(pos, placer, itemstack, pointed_thing) 
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", "size[3,1.75]field[0.3,0.5;3,1;channel;Channel;]button_exit[0,1;3,1;setchan;Done]")
		meta:set_string("owner", placer:get_player_name())
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		local name = sender:get_player_name()
		local meta = minetest.get_meta(pos)
		if minetest.is_protected(pos, name) then
			minetest.chat_send_player(name, "You don't own this teleporter!")
			minetest.record_protection_violation(pos, name)
			return
		end
		if fields.channel then
			meta:set_string("digichannel", fields.channel)
		else return end
	end,
	digiline = {
		receptor = {},
		effector = {
			action = function (pos, node, msgChan, msg)
				local meta = minetest.get_meta(pos)
				local searchChan = meta:get_string("digichannel")
				if msgChan == searchChan then
					local count = 0
					local params = {}
					for param in msg:gmatch("%-?%w+") do
						count = count + 1
						table.insert(params, param)
					end
					if count ~= 4 then return end
					local coords = {x = tonumber(params[1]), y = tonumber(params[2]), z = tonumber(params[3])}
					if coords.x and coords.y and coords.z then
						local player = minetest.get_player_by_name(params[4])
						if not player then return end
						player:setpos(coords)
					else return end
				end
			end
		}
	}
})
