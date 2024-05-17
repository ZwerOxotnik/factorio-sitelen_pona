local M = {}


local sitelen_pona = require("sitelen_pona/sitelen_pona")

---@type table<string, uint> https://lua-api.factorio.com/latest/LuaBootstrap.html#LuaBootstrap.generate_event_name
local custom_events = {
	on_sitelen = script.generate_event_name() -- Don't use in any events, it'll cause desyncs
}

--#region Global data
local _muted_players
--#endregion


--#region Constants
--#endregion


--#region Utils


---@param message string
---@param _player LuaPlayer?
---@return boolean?, boolean? # is valid players, is player muted
function send_sitelen_pona_message_to_chat(message, _player)
	if _player ~= nil and not _player.valid then return false, false end
	if _muted_players[_player.index]        then return false, true end

	local nickname = "SERVER"
	if _player then
		nickname = _player.name
	end

	local _sitelen_pona = sitelen_pona.toki_pona_mute_to_sitelen_pona(message)
	local text_parts = {}
	local text_mono_parts = {}
	local big_text_parts = {}
	local big_text_mono_parts = {}
	local is_sitelen_pona_part = false
	local i = 0
	for _, part in ipairs(_sitelen_pona) do
		if part.is_new_line then
			goto continue
		end
		local text = part.sitelep_pona or part.original
		if not part.sitelep_pona then
			if is_sitelen_pona_part then
				i = i + 1
				text_parts[i] = "[/font]"
				text_mono_parts[i] = "[/font]"
				big_text_parts[i] = "[/font]"
				big_text_mono_parts[i] = "[/font]"
			end
			i = i + 1
			text_parts[i] = text
			text_mono_parts[i] = text
			big_text_parts[i] = text
			big_text_mono_parts[i] = text
			is_sitelen_pona_part = false
		else
			if not is_sitelen_pona_part then
				i = i + 1
				text_parts[i] = "[font=sitelenselikiwenjuniko_chat]"
				text_mono_parts[i] = "[font=sitelenselikiwenmonojuniko_chat]"
				big_text_parts[i] = "[font=big_sitelenselikiwenjuniko_chat]"
				big_text_mono_parts[i] = "[font=big_sitelenselikiwenmonojuniko_chat]"
			end
			i = i + 1
			text_parts[i] = text
			text_mono_parts[i] = text
			big_text_parts[i] = text
			big_text_mono_parts[i] = text
			is_sitelen_pona_part = true
		end
		if  not is_sitelen_pona_part and part.is_add_space then
			i = i + 1
			text_parts[i] = " "
			text_mono_parts[i] = " "
			big_text_parts[i] = " "
			big_text_mono_parts[i] = " "
		end

	    ::continue::
	end
	local result_text          = {"", nickname, {"colon"}, " ", table.concat(text_parts, "")}
	local result_mono_text     = {"", nickname, {"colon"}, " ", table.concat(text_mono_parts, "")}
	local big_result_text      = {"", nickname, {"colon"}, " ", table.concat(big_text_parts,  "")}
	local big_result_mono_text = {"", nickname, {"colon"}, " ", table.concat(big_text_mono_parts, "")}

	-- TODO: add mute support
	for _, player in pairs(game.players) do
		if not player.valid then
			goto continue
		end

		local is_big_text = player.mod_settings["sitelen_pona-use_enlarged_symbols"].value
		if player.mod_settings["sitelen_pona-use_monospaced_font"].value then
			if is_big_text then
				player.print(big_result_mono_text)
			else
				player.print(result_mono_text)
			end
		else
			if is_big_text then
				player.print(big_result_text)
			else
				player.print(result_text)
			end
		end

		:: continue ::
	end

	script.raise_event(
		custom_events.on_sitelen,
		{player_index = _player.index, message = message}
	)
	return true, false
end

--#endregion


--#region Functions of events

local function on_player_muted(event)
	local player = game.get_player(event.player_index)
	if not (player and player.valid) then return end

	_muted_players[event.player_index] = true
end

local function on_player_unmuted(event)
	_muted_players[event.player_index] = nil
end

local function delete_player_data(event)
	_muted_players[event.player_index] = nil
end

--#endregion


--#region Commands

local function sitelen_command(cmd)
	if cmd.player_index == 0 then -- server
		send_sitelen_pona_message_to_chat(cmd.parameter)
		return
	end

	send_sitelen_pona_message_to_chat(cmd.parameter, game.get_player(cmd.player_index))
end

--#endregion


--#region Pre-game stage

local interface = {
	get_event_name = function(name)
		-- return custom_events[name] -- usually, it's enough
		game.print("ID: " .. tostring(custom_events[name]))
	end,
	toki_pona_mute_to_sitelen_pona = sitelen_pona.toki_pona_mute_to_sitelen_pona,
	toki_pona_to_sitelen_pona = sitelen_pona.toki_pona_to_sitelen_pona,
	send_sitelen_pona_message_to_chat = send_sitelen_pona_message_to_chat
}

local function add_remote_interface()
	-- https://lua-api.factorio.com/latest/LuaRemote.html
	remote.remove_interface("sitelen_pona") -- For safety
	remote.add_interface("sitelen_pona", interface)
end
-- You can create interface outside events
-- However, the game have to "load" with the mod in order to use functions of the interface
remote.add_interface("sitelen_pona", interface)


local function link_data()
	_muted_players = global.muted_players
end

local function update_global_data()
	global.muted_players = global.muted_players or {}

	link_data()

	for player_index in pairs(_muted_players) do
		if not game.get_player(player_index) then
			_muted_players[player_index] = nil
		end
	end
end


M.on_init = update_global_data
M.on_configuration_changed = update_global_data
M.on_load = link_data
M.add_remote_interface = add_remote_interface

--#endregion


M.events = {
	[defines.events.on_player_muted]   = on_player_muted,
	[defines.events.on_player_unmuted] = on_player_unmuted,
	[defines.events.on_player_removed] = delete_player_data,
}


M.commands = {
	sitelen = sitelen_command,
}


return M
