-- See https://wiki.factorio.com/Tutorial:Mod_settings#Reading_settings

require("defines")


--- Adds settings for commands
if mods["BetterCommands"] then
	local is_ok, better_commands = pcall(require, "__BetterCommands__/BetterCommands/control")
	if is_ok then
		better_commands.COMMAND_PREFIX = MOD_SHORT_NAME
		better_commands.create_settings(MOD_PATH, MOD_SHORT_NAME) -- Adds switchable commands
	end
end


data:extend({
	{
		type = "bool-setting",
		name = "sitelen_pona-use_monospaced_font",
		setting_type = "runtime-per-user",
		default_value = false,
		hidden = false
	}, {
		type = "bool-setting",
		name = "sitelen_pona-use_compound_symbols",
		setting_type = "runtime-per-user",
		default_value = true,
		hidden = false
	}, {
		type = "bool-setting",
		name = "sitelen_pona-use_complex_compound_symbols",
		setting_type = "runtime-per-user",
		default_value = false,
		hidden = false
	}, {
		type = "bool-setting",
		name = "sitelen_pona-use_enlarged_symbols",
		setting_type = "runtime-per-user",
		default_value = false,
		hidden = false
	},
})
