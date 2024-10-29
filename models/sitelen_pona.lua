local M = {}


local sitelen_pona = require("sitelen_pona/main")

---@type table<string, uint> https://lua-api.factorio.com/latest/LuaBootstrap.html#LuaBootstrap.generate_event_name
local custom_events = {
	on_sitelen = script.generate_event_name() -- Don't use in any events, it'll cause desyncs
}

--#region Global data
local __muted_players
--#endregion


--#region Constants
local FONT_NAMES = {
	["sitelenselikiwen"] = {
		big_chat      = "[font=big_sitelenselikiwenjuniko_chat]",
		chat          = "[font=sitelenselikiwenjuniko_chat]",
		mono_big_chat = "[font=big_sitelenselikiwenmonojuniko_chat]",
		mono_chat     = "[font=sitelenselikiwenmonojuniko_chat]",
	},
	["nasin-nanpa"] = {
		big_chat      = "[font=big_nasin-nanpa_chat]",
		chat          = "[font=nasin-nanpa_chat]",
	}
}
--#endregion


--#region Utils


---@param message string
---@param _player LuaPlayer?
---@param language string
---@param font string
---@return boolean?, boolean? # is valid players, is player muted
function send_transripted_message_to_chat(message, _player, language, font)
	if _player ~= nil and not _player.valid then return false, false end
	if __muted_players[_player.index]       then return false, true end

	local nickname = "SERVER"
	if _player then
		nickname = _player.name
	end

	local FONT_DATA = FONT_NAMES[font]
	local has_mono_font = (FONT_DATA.mono_chat ~= nil)
	local _sitelen_pona = sitelen_pona.transcribe(language, font, message)
	local _ligatured_sitelen_pona, is_ligatured = sitelen_pona.ligature(language, font, _sitelen_pona)
	local text_parts = {}
	local text_mono_parts = {}
	local big_text_parts = {}
	local big_text_mono_parts = {}
	local ligatured_text_parts = {}
	local ligatured_text_mono_parts = {}
	local ligatured_big_text_parts = {}
	local ligatured_big_text_mono_parts = {}
	local is_ConScript_part = false
	local i = 0
	for _, part in ipairs(_sitelen_pona) do
		if part.is_new_line then
			goto continue
		end
		local text = part.result_text or part.original
		if not part.result_text then
			if is_ConScript_part then
				i = i + 1
				big_text_parts[i] = "[/font]"
				text_parts[i]     = "[/font]"
				if has_mono_font then
					big_text_mono_parts[i] = "[/font]"
					text_mono_parts[i]     = "[/font]"
				end
			end
			i = i + 1
			big_text_parts[i] = text
			text_parts[i]     = text
			if has_mono_font then
				big_text_mono_parts[i] = text
				text_mono_parts[i]     = text
			end
			is_ConScript_part = false
		else
			if not is_ConScript_part then
				i = i + 1
				big_text_parts[i] = FONT_DATA.big_chat
				text_parts[i]     = FONT_DATA.chat
				if has_mono_font then
					big_text_mono_parts[i] = FONT_DATA.mono_big_chat
					text_mono_parts[i]     = FONT_DATA.mono_chat
				end
			end
			i = i + 1
			big_text_parts[i] = text
			text_parts[i]     = text
			if has_mono_font then
				big_text_mono_parts[i] = text
				text_mono_parts[i]     = text
			end
			is_ConScript_part = true
		end
		if not is_ConScript_part and part.is_add_space then
			i = i + 1
			big_text_parts[i] = " "
			text_parts[i]     = " "
			if has_mono_font then
				big_text_mono_parts[i] = " "
				text_mono_parts[i]     = " "
			end
		end

	    ::continue::
	end

	if is_ConScript_part then
		is_ConScript_part = false
		i = i + 1
		big_text_parts[i] = "[/font]"
		text_parts[i]     = "[/font]"
		if has_mono_font then
			big_text_mono_parts[i] = "[/font]"
			text_mono_parts[i]     = "[/font]"
		end
	end

	if is_ligatured then
		i = 0
		for _, part in ipairs(_ligatured_sitelen_pona) do
			if part.is_new_line then
				goto continue
			end
			local text = part.result_text or part.original
			if not part.result_text then
				if is_ConScript_part then
					i = i + 1
					ligatured_big_text_parts[i] = "[/font]"
					ligatured_text_parts[i]     = "[/font]"
					if has_mono_font then
						ligatured_big_text_mono_parts[i] = "[/font]"
						ligatured_text_mono_parts[i]     = "[/font]"
					end
				end
				i = i + 1
				ligatured_text_parts[i]     = text
				ligatured_big_text_parts[i] = text
				if has_mono_font then
					ligatured_big_text_mono_parts[i] = text
					ligatured_text_mono_parts[i]     = text
				end
				is_ConScript_part = false
			else
				if not is_ConScript_part then
					i = i + 1
					ligatured_big_text_parts[i] = FONT_DATA.big_chat
					ligatured_text_parts[i]     = FONT_DATA.chat
					if has_mono_font then
						ligatured_big_text_mono_parts[i] = FONT_DATA.mono_big_chat
						ligatured_text_mono_parts[i]     = FONT_DATA.mono_chat
					end
				end
				i = i + 1
				ligatured_big_text_parts[i] = text
				ligatured_text_parts[i]     = text
				if has_mono_font then
					ligatured_big_text_mono_parts[i] = text
					ligatured_text_mono_parts[i]     = text
				end
				is_ConScript_part = true
			end

			if not is_ConScript_part and part.is_add_space then
				i = i + 1
				ligatured_big_text_parts[i] = " "
				ligatured_text_parts[i]     = " "
				if has_mono_font then
					ligatured_big_text_mono_parts[i] = " "
					ligatured_text_mono_parts[i]     = " "
				end
			end

			::continue::
		end

		if is_ConScript_part then
			is_ConScript_part = false
			i = i + 1
			ligatured_big_text_parts[i] = "[/font]"
			ligatured_text_parts[i]     = "[/font]"
			if has_mono_font then
				ligatured_big_text_mono_parts[i] = "[/font]"
				ligatured_text_mono_parts[i]     = "[/font]"
			end
		end
	end

	local result_text          = {"", nickname, {"colon"}, " ", table.concat(text_parts, "")}
	local result_big_text      = {"", nickname, {"colon"}, " ", table.concat(big_text_parts,  "")}
	local result_mono_text, result_big_mono_text
	if has_mono_font then
		result_mono_text     = {"", nickname, {"colon"}, " ", table.concat(text_mono_parts, "")}
		result_big_mono_text = {"", nickname, {"colon"}, " ", table.concat(big_text_mono_parts, "")}
	end

	local ligatured_result_text, ligatured_result_mono_text, ligatured_result_big_text, ligatured_result_big_mono_text
	if is_ligatured then
		ligatured_result_text          = {"", nickname, {"colon"}, " ", table.concat(ligatured_text_parts, "")}
		ligatured_result_mono_text     = {"", nickname, {"colon"}, " ", table.concat(ligatured_text_mono_parts, "")}
		if has_mono_font then
			ligatured_result_big_text      = {"", nickname, {"colon"}, " ", table.concat(ligatured_big_text_parts,  "")}
			ligatured_result_big_mono_text = {"", nickname, {"colon"}, " ", table.concat(ligatured_big_text_mono_parts, "")}
		end
	end

	-- TODO: add mute support
	for _, player in pairs(game.players) do
		if not player.valid then
			goto continue
		end

		local is_ligatured_text = player.mod_settings["sitelen_pona-ligature_logograms"].value or player.mod_settings["sitelen_pona-ligature_complex_logograms"].value
		local is_big_text = player.mod_settings["sitelen_pona-use_enlarged_symbols"].value

		if is_ligatured_text and is_ligatured then
			if has_mono_font and player.mod_settings["sitelen_pona-use_monospaced_font"].value then

				player.print((is_big_text and ligatured_result_big_mono_text) or ligatured_result_mono_text)
			else
				player.print((is_big_text and ligatured_result_big_text) or ligatured_result_text)
			end
		else
			if has_mono_font and player.mod_settings["sitelen_pona-use_monospaced_font"].value then
				player.print((is_big_text and result_big_mono_text) or result_mono_text)
			else
				player.print((is_big_text and result_big_text) or result_text)
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

	__muted_players[event.player_index] = true
end

local function on_player_unmuted(event)
	local player_index = event.player_index
	local player = game.get_player(player_index)
	if not (player and player.valid) then return end

	__muted_players[player_index] = nil
end

local function delete_player_data(event)
	__muted_players[event.player_index] = nil
end

--#endregion


--#region Commands

local function sitelen_command(cmd)
	if cmd.player_index == 0 then -- server
		send_transripted_message_to_chat(cmd.parameter, nil, "sitelen_pona", "sitelenselikiwen")
		return
	end

	send_transripted_message_to_chat(cmd.parameter, game.get_player(cmd.player_index), "sitelen_pona", "sitelenselikiwen")
end

local function sitelen2_command(cmd)
	if cmd.player_index == 0 then -- server
		send_transripted_message_to_chat(cmd.parameter, nil, "sitelen_pona", "nasin-nanpa")
		return
	end

	send_transripted_message_to_chat(cmd.parameter, game.get_player(cmd.player_index), "sitelen_pona", "nasin-nanpa")
end

local function ilu_tuki_command(cmd)
	if cmd.player_index == 0 then -- server
		send_transripted_message_to_chat(cmd.parameter, nil, "tuki_tiki", "sitelenselikiwen")
		return
	end

	send_transripted_message_to_chat(cmd.parameter, game.get_player(cmd.player_index), "tuki_tiki", "sitelenselikiwen")
end

--#endregion


--#region Pre-game stage

local interface = {
	get_event_name = function(name)
		-- return custom_events[name] -- usually, it's enough
		game.print("ID: " .. tostring(custom_events[name]))
	end,
	send_sitelen_pona_message_to_chat = send_transripted_message_to_chat,
	transcribe = sitelen_pona.transcribe,
	ligature = sitelen_pona.ligature,
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
	__muted_players = storage.muted_players
end

local function update_global_data()
	storage.muted_players = storage.muted_players or {}

	link_data()

	for player_index in pairs(__muted_players) do
		if not game.get_player(player_index) then
			__muted_players[player_index] = nil
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
	sitelen  = sitelen_command,
	sitelen2 = sitelen2_command,
	["ilu-tuki"] = ilu_tuki_command,
}


return M
