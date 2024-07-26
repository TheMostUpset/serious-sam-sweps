local function SS_SettingsPanel(Panel)
	Panel:AddControl("Label", {Text = "Server"})
	Panel:AddControl("Slider", {Label = "Ammo Equip Multiplier", Command = "ss_ammomultiplier", Type = "Integer", Min = 0, Max = 10})
	Panel:AddControl("CheckBox", {Label = "Player Sounds (Sam Classic models)", Command = "ss_playersounds"})
	Panel:AddControl("CheckBox", {Label = "TFE Lasergun Sound", Command = "ss_laser_tfe"})
	Panel:AddControl("CheckBox", {Label = "Unlimited Ammo", Command = "ss_unlimitedammo"})
	Panel:AddControl("Label", {Text = "Client"})
	Panel:AddControl("CheckBox", {Label = "Fire Lighting", Command = "ss_firelight"})
	Panel:AddControl("CheckBox", {Label = "Weapon Bobbing", Command = "ss_bob"})
	Panel:AddControl("CheckBox", {Label = "HUD", Command = "ss_hud"})
	Panel:AddControl("CheckBox", {Label = "Show Ammo Icons", Command = "ss_hud_ammoicons"})
	Panel:AddControl("Slider", {Label = "Crosshair", Command = "ss_crosshair", Type = "Integer", Min = 0, Max = 7})
	Panel:AddControl("Slider", {Label = "HUD Skin (TFE/TSE)", Command = "ss_hud_skin", Type = "Integer", Min = 1, Max = 2})
	Panel:AddControl("Color", {Label = "TFE HUD Color (Default is 0 255 0)", Red = "ss_hud_color_r", Green = "ss_hud_color_g", Blue = "ss_hud_color_b"})
end

local function SS_PopulateToolMenu()
	spawnmenu.AddToolMenuOption("Utilities", "Serious Sam", "SSSettings", "Serious Sam Settings", "", "", SS_SettingsPanel)
end

hook.Add("PopulateToolMenu", "SS_PopulateToolMenu", SS_PopulateToolMenu)

list.Set("ContentCategoryIcons", "Serious Sam", "vgui/serioussam_16.png")