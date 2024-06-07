local cvar_enable = CreateClientConVar("ss_hud", 0)
local cvar_ammoicons = CreateClientConVar("ss_hud_ammoicons", 1)

SeriousHUD = {}

-- you can override these functions in gamemodes to force HUD to be enabled or something

function SeriousHUD:Enabled()
	return cvar_enable:GetBool()
end

function SeriousHUD:AmmoIconsEnabled()
	return cvar_ammoicons:GetBool()
end

function SeriousHUD:GetHUDScale()
	return 1
end

local function CreateSeriousFonts()
	local scale = SeriousHUD:GetHUDScale()

	surface.CreateFont("seriousHUDfont", {
		font = "default",
		size = ScrH()/12 * scale,
		weight = 600,
		blursize = 1
	})

	surface.CreateFont("seriousHUDfontHL2", {
		font = "HL2MP",
		size = ScrH()/20 * scale,
		shadow = false
	})

	surface.CreateFont("seriousHUDpickuptext", {
		font = "Roboto",
		size = ScrH() / 45 * scale
	})
end
CreateSeriousFonts()

local pickuptext
local pickupamount = 0
local pickuptextTime = RealTime()
net.Receive("SSPickupText", function()
	local msg, amount = net.ReadString(), net.ReadUInt(8)
	
	if (pickuptextTime and pickuptextTime < RealTime()) or pickuptext != msg then
		pickupamount = 0
	end
	
	pickuptext = msg
	if amount > 0 then
		pickupamount = pickupamount + amount
	end
	pickuptextTime = RealTime() + 2
end)

local t_hearth = surface.GetTextureID("vgui/serioussam/hud/HSuper")
local ArMedium = surface.GetTextureID("vgui/serioussam/hud/ArMedium")

local WCannon = surface.GetTextureID("vgui/serioussam/hud/WCannon")
local WChainsaw = surface.GetTextureID("vgui/serioussam/hud/WChainsaw")
local WColt = surface.GetTextureID("vgui/serioussam/hud/WColt")
local WDoubleShotgun = surface.GetTextureID("vgui/serioussam/hud/WDoubleShotgun")
local WFlamer = surface.GetTextureID("vgui/serioussam/hud/WFlamer")
local WGhostBuster = surface.GetTextureID("vgui/serioussam/hud/WGhostBuster")
local WGrenadeLauncher = surface.GetTextureID("vgui/serioussam/hud/WGrenadeLauncher")
local WKnife = surface.GetTextureID("vgui/serioussam/hud/WKnife")
local WLaser = surface.GetTextureID("vgui/serioussam/hud/WLaser")
local WMinigun = surface.GetTextureID("vgui/serioussam/hud/WMinigun")
local WRocketLauncher = surface.GetTextureID("vgui/serioussam/hud/WRocketLauncher")
local WSingleShotgun = surface.GetTextureID("vgui/serioussam/hud/WSingleShotgun")
local WSniper = surface.GetTextureID("vgui/serioussam/hud/WSniper")
local WTommygun = surface.GetTextureID("vgui/serioussam/hud/WTommygun")

local AmBullets = surface.GetTextureID("vgui/serioussam/hud/AmBullets")
local AmCannonBall = surface.GetTextureID("vgui/serioussam/hud/AmCannonBall")
local AmElectricity = surface.GetTextureID("vgui/serioussam/hud/AmElectricity")
local AmFuelReservoir = surface.GetTextureID("vgui/serioussam/hud/AmFuelReservoir")
local AmGrenades = surface.GetTextureID("vgui/serioussam/hud/AmGrenades")
local AmRockets = surface.GetTextureID("vgui/serioussam/hud/AmRockets")
local AmShells = surface.GetTextureID("vgui/serioussam/hud/AmShells")
local AmSniperBullets = surface.GetTextureID("vgui/serioussam/hud/AmSniperBullets")

local weps = {
	["weapon_ss_knife"] = WKnife,
	["weapon_ss_chainsaw"] = WChainsaw,
	["weapon_ss_colt"] = WColt,
	["weapon_ss_colt_dual"] = WColt,
	["weapon_ss_singleshotgun"] = WSingleShotgun,
	["weapon_ss_doubleshotgun"] = WDoubleShotgun,
	["weapon_ss_tommygun"] = WTommygun,
	["weapon_ss_minigun"] = WMinigun,
	["weapon_ss_ghostbuster"] = WGhostBuster,
	["weapon_ss_grenadelauncher"] = WGrenadeLauncher,
	["weapon_ss_rocketlauncher"] = WRocketLauncher,
	["weapon_ss_flamer"] = WFlamer,
	["weapon_ss_sniper"] = WSniper,
	["weapon_ss_laser"] = WLaser,
	["weapon_ss_cannon"] = WCannon,

	["weapon_sshd_knife"] = WKnife,
	["weapon_sshd_chainsaw"] = WChainsaw,
	["weapon_sshd_colt"] = WColt,
	["weapon_sshd_colt_dual"] = WColt,
	["weapon_sshd_singleshotgun"] = WSingleShotgun,
	["weapon_sshd_doubleshotgun"] = WDoubleShotgun,
	["weapon_sshd_tommygun"] = WTommygun,
	["weapon_sshd_minigun"] = WMinigun,
	["weapon_sshd_grenadelauncher"] = WGrenadeLauncher,
	["weapon_sshd_rocketlauncher"] = WRocketLauncher,
	["weapon_sshd_flamer"] = WFlamer,
	["weapon_sshd_sniper"] = WSniper,
	["weapon_sshd_laser"] = WLaser,
	["weapon_sshd_cannon"] = WCannon
}

local hl2weapons = {
	["weapon_crowbar"] = "6",
	["weapon_physcannon"] = ",",
	["weapon_physgun"] = ",",
	["weapon_pistol"] = "-",
	["weapon_357"] = ".",
	["weapon_smg1"] = "/",
	["weapon_ar2"] = "2",
	["weapon_shotgun"] = "0",
	["weapon_crossbow"] = "1",
	["weapon_frag"] = "4",
	["weapon_rpg"] = "3",
	["weapon_bugbait"] = "5",
	["weapon_stunstick"] = "!",
	["weapon_slam"] = "*"
}

local ammoicons = {
	[7] = {icon = AmShells, maxammo = 100},
	[4] = {icon = AmBullets, maxammo = 500},
	[8] = {icon = AmRockets, maxammo = 50},
	[10] = {icon = AmGrenades, maxammo = 50},
	["napalm"] = {icon = AmFuelReservoir, maxammo = 500},
	["sniperround"] = {icon = AmSniperBullets, maxammo = 50},
	[1] = {icon = AmElectricity, maxammo = 400},
	["cannonball"] = {icon = AmCannonBall, maxammo = 30}
}

local ammoicons_list = {
	[8] = 7,
	[7] = 4,
	[6] = 8,
	[5] = 10,
	[4] = "napalm",
	[3] = "sniperround",
	[2] = 1,
	[1] = "cannonball",
}

local ammonum = 0
local ammo_jit_x = 0
local ammo_jit_y = 0
local ammochangetime = 0
local ammo_jit_div = 2

local healthnum = 0
local health_jit_x = 0
local health_jit_y = 0
local healthchangetime = 0
local health_jit_div = 2

local armornum = 0
local armor_jit_x = 0
local armor_jit_y = 0
local armorchangetime = 0
local armor_jit_div = 2

local jit_bound = 6
local jit_speed = 100

local function OnAmmoNumChange(ply, ammo)
	if ammonum != ammo then
		ammochangetime = RealTime() +1.5
		ammo_jit_div = math.Rand(1.5, 2.5)
	end	
	ammonum = ammo
	local jit_time = math.min(RealTime() - ammochangetime, 0)
	ammo_jit_x = math.sin(RealTime() * jit_speed) * jit_bound * jit_time
	ammo_jit_y = math.sin(RealTime() * jit_speed/ammo_jit_div) * jit_bound * jit_time
end

local function OnAmmoNumIconChange(ply, ammo, id)
	ply:SetVar("SSammonumIcon"..id, ammo)
	timer.Simple(.1, function()
		ply:SetVar("SSammonumIcon_new"..id, ammo)
	end)
	if ply:GetVar("SSammonumIcon"..id) != ply:GetVar("SSammonumIcon_new"..id) then
		ply:SetVar("ammochangetimeIcon"..id, RealTime() +1.5)
	end
	if ply:GetVar("ammochangetimeIcon"..id) then
		ply:SetVar("ammo_icon_jit"..id, math.Rand(-6,6) * math.min(RealTime() -ply:GetVar("ammochangetimeIcon"..id), 0))
	end
end

local function OnHealthNumChange(ply, health)
	if healthnum != health then
		healthchangetime = RealTime() +1.5
		health_jit_div = math.Rand(1.5, 2.5)
	end	
	healthnum = health
	local jit_time = math.min(RealTime() - healthchangetime, 0)
	health_jit_x = math.sin(RealTime() * jit_speed) * jit_bound * jit_time
	health_jit_y = math.sin(RealTime() * jit_speed/health_jit_div) * jit_bound * jit_time
end

local function OnArmorNumChange(ply, armor)
	if armornum != armor then
		armorchangetime = RealTime() +1.5
		armor_jit_div = math.Rand(1.5, 2.5)
	end	
	armornum = armor
	local jit_time = math.min(RealTime() - armorchangetime, 0)
	armor_jit_x = math.sin(RealTime() * jit_speed) * jit_bound * jit_time
	armor_jit_y = math.sin(RealTime() * jit_speed/armor_jit_div) * jit_bound * jit_time
end

local function SeriousText(t, x, y, c)
	local font = "seriousHUDfont"
	x = x - 2
	draw.SimpleText(t, font, x+2, y+2, Color(20, 20, 20, 180), TEXT_ALIGN_LEFT)
	draw.SimpleText(t, font, x, y, c, TEXT_ALIGN_LEFT)
end

function SeriousHUD:Draw()
	if SeriousHUD:Enabled() then
		local client = LocalPlayer()
		local awep = client:GetActiveWeapon()
		
		local size = ScrH() / 14.75 * SeriousHUD:GetHUDScale()
		local gap_screen = ScrH() / 80
		local gap_rect = 7
		local y = ScrH() - size - gap_screen
		local armor_y = y * .908
		local widerect_w = size * 2.42
		local widerectleft_x = size + gap_screen + gap_rect
		local text_align_y = size / 5
		
		local cntr = widerectleft_x + widerect_w + ScrW() / 8 - 52
		local ammorectx = cntr + size + gap_rect
		local ammoiconrectx = ammorectx + widerect_w + gap_rect
		
		local hudr, hudg, hudb = 90, 120, 180
		local rect, recta = 0, 160
		
		local armor = client:Alive() and client:Armor() or 0

		surface.SetDrawColor(rect, rect, rect, recta)
		surface.DrawRect(gap_screen +health_jit_x, y +health_jit_y, size, size)
		surface.DrawRect(widerectleft_x, y, widerect_w, size)
		if armor > 0 then
			surface.DrawRect(gap_screen +armor_jit_x, armor_y +armor_jit_y, size, size)
			surface.DrawRect(widerectleft_x, armor_y, widerect_w, size)
		end
		surface.SetDrawColor(hudr, hudg, hudb, 255)
		surface.DrawOutlinedRect(gap_screen +health_jit_x, y +health_jit_y, size, size)
		surface.DrawOutlinedRect(widerectleft_x, y, widerect_w, size)
		if armor > 0 then
			surface.DrawOutlinedRect(gap_screen +armor_jit_x, armor_y +armor_jit_y, size, size)
			surface.DrawOutlinedRect(widerectleft_x, armor_y, widerect_w, size)
		end
		
		
		//hp
		
		local hp = math.max(client:Health(), 0)

		local hpcolr = 255
		local hpcolg = 230
		local hpcolb = 0
		if hp > 100 then
			hpcolr = 100
			hpcolg = 255
			hpcolb = 100
		elseif hp <= 50 and hp > 25 then
			hpcolg = 120
		elseif hp <= 25 then
			hpcolg = 0
		end

		if math.min(RealTime() - healthchangetime + .75, 0) != 0 then
			hpcolr = 255
			hpcolg = 255
			hpcolb = 255
		end
		
		local iccol = 255
		
		if hp <= 10 then
			iccol = math.max(math.sin(RealTime() * 12.5) * 4000, 40)
		end
		
		surface.SetTexture(t_hearth)
		surface.SetDrawColor(iccol, iccol, iccol, 255)
		surface.DrawTexturedRect(gap_screen +health_jit_x, y +health_jit_y, size, size)	
		
		surface.SetFont("seriousHUDfont")
		local textsize_w, textsize_h = surface.GetTextSize(hp)
		SeriousText(hp, (widerectleft_x) + (widerect_w - textsize_w) / 2, y - text_align_y, Color(hpcolr, hpcolg, hpcolb, 255))
		
		OnHealthNumChange(client, hp)
		
		//armor
		
		if armor > 0 then
			surface.SetTexture(ArMedium)
			surface.SetDrawColor(255, 255, 255, 255)
			surface.DrawTexturedRect(gap_screen +armor_jit_x, armor_y +armor_jit_y, size, size)
			local textsize_w, textsize_h = surface.GetTextSize(armor)
			SeriousText(armor, (widerectleft_x) + (widerect_w - textsize_w) / 2, armor_y - text_align_y, Color(255, 230, 0, 255))
		end
		OnArmorNumChange(client, armor)	
		
		//ammo
		
		if awep != NULL then
		
			local curammo = awep:GetPrimaryAmmoType()
			
			surface.SetDrawColor(rect, rect, rect, recta)
			surface.DrawRect(cntr +ammo_jit_x, y +ammo_jit_y, size, size)
			if curammo != -1 then
				surface.DrawRect(ammorectx, y, widerect_w, size)
				surface.DrawRect(ammoiconrectx, y, size, size)
			end
			surface.SetDrawColor(hudr, hudg, hudb, 255)
			surface.DrawOutlinedRect(cntr +ammo_jit_x, y +ammo_jit_y, size, size)
			if curammo != -1 then
				surface.DrawOutlinedRect(ammorectx, y, widerect_w, size)
				surface.DrawOutlinedRect(ammoiconrectx, y, size, size)
			end

			local class = awep:GetClass()
			
			local wicn = weps[class]
			local hl2 = hl2weapons[class]
			if wicn then		
				surface.SetTexture(wicn)
				surface.SetDrawColor(255, 255, 255, 255)
				surface.DrawTexturedRect(cntr +ammo_jit_x, y +ammo_jit_y, size, size)
			elseif hl2 then		
				draw.SimpleText(hl2, "seriousHUDfontHL2", cntr+size/2 +ammo_jit_x, y*1.05 +ammo_jit_y, Color(255, 230, 180, 255), TEXT_ALIGN_CENTER, 1)
			end	
			
			local atype = awep:GetPrimaryAmmoType()
			local anum = client:GetAmmoCount(atype)
			local clipammo = awep:Clip1()
			local ammotexture

			local ammocount
			if clipammo == -1 then
				ammocount = anum
			else
				ammocount = clipammo + anum
			end
			
			local ammonumcol = 230
			local ammoiconcol = 255
			local findammotype = awep:IsScripted() and ammoicons[awep.Primary.Ammo] or ammoicons[atype]
			if findammotype and awep:IsScripted() and (awep.Base == "weapon_ss_base" or awep.Base == "weapon_sshd_base") then
				if ammocount <= math.ceil(findammotype.maxammo / 3.5) then
					ammonumcol = 120
				end
				if ammocount <= math.ceil(findammotype.maxammo / 8) then
					ammonumcol = 0
				end
				if ammocount <= math.floor(findammotype.maxammo / 15) then
					ammoiconcol = math.max(math.sin(RealTime() *12.5) *4000, 40)
				end
			end
			if ammocount <= 0 then
				ammonumcol = 0
				ammoiconcol = math.max(math.sin(RealTime() *12.5) *4000, 40)
			end
			
			if curammo != -1 then
				surface.SetFont("seriousHUDfont")
				local textsize_w, textsize_h = surface.GetTextSize(ammocount)
				SeriousText(ammocount, ammorectx + (widerect_w - textsize_w) / 2, y - text_align_y, Color(255, ammonumcol, 0, 255))
				OnAmmoNumChange(client, ammocount)
			else
				ammo_jit_x = 0
				ammo_jit_y = 0
			end
			
			if findammotype then
				surface.SetTexture(findammotype.icon)
				surface.SetDrawColor(ammoiconcol, ammoiconcol, ammoiconcol, 255)
				surface.DrawTexturedRect(ammoiconrectx, y, size, size)
			end
		
		end
		
		//ammo icons
		if SeriousHUD:AmmoIconsEnabled() then
			local ammosize = size/1.25
			local ammoy = y+ammosize/4
			local icon_gap = 5.5
			local iconpos = ScrW() - gap_screen + icon_gap + 1
			for k,v in ipairs(ammoicons_list) do
				local ammoc = client:GetAmmoCount(v)
				if ammoc > 0 then
					OnAmmoNumIconChange(client, ammoc, k)
					iconpos = iconpos - ammosize - icon_gap
					surface.SetDrawColor(rect, rect, rect, recta)
					surface.DrawRect(iconpos, ammoy+client:GetVar("ammo_icon_jit"..k, 0), ammosize, ammosize)
					surface.SetDrawColor(hudr, hudg, hudb, 255)
					surface.DrawOutlinedRect(iconpos, ammoy+client:GetVar("ammo_icon_jit"..k, 0), ammosize, ammosize)
					
					surface.SetTexture(ammoicons[v].icon)
					surface.SetDrawColor(255, 255, 255, 255)
					surface.DrawTexturedRect(iconpos+2, ammoy+2+client:GetVar("ammo_icon_jit"..k, 0), ammosize/1.075, ammosize/1.075)
					
					local ammocolr, ammocolg, ammocolb = 255, math.min(ammosize / (ammoicons[v].maxammo / ammoc), ammosize), 0
					local ammobar = ammocolg/1.125
					if math.min(RealTime() -client:GetVar("ammochangetimeIcon"..k, 0)+.75, 0) != 0 then
						ammocolr = 255
						ammocolg = 255
						ammocolb = 255
					end
					surface.SetDrawColor(ammocolr, ammocolg*4.25, ammocolb, 220)
					surface.DrawRect(iconpos+ammosize/1.375, ammoy+ammosize/1.06-math.floor(ammobar)+client:GetVar("ammo_icon_jit"..k, 0), ammosize/4.75, ammobar)
				end
			end
		end
	end

	if pickuptext and pickuptextTime and pickuptextTime > RealTime() then
		local text = pickupamount > 0 and pickuptext.." +".. pickupamount or pickuptext
		draw.SimpleText(text, "seriousHUDpickuptext", ScrW() / 2 + 1, ScrH() / 1.24 + 1, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER)
		draw.SimpleText(text, "seriousHUDpickuptext", ScrW() / 2 + 2, ScrH() / 1.24 + 2, Color(0, 0, 0, 100), TEXT_ALIGN_CENTER)
		draw.SimpleText(text, "seriousHUDpickuptext", ScrW() / 2, ScrH() / 1.24, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
	end
end
hook.Add("HUDPaint", "SeriousHUD", SeriousHUD.Draw)

local tohide = {
	["CHudHealth"] = true,
	["CHudBattery"] = true,
	["CHudAmmo"] = true,
	["CHudSecondaryAmmo"] = true
}

local function HUDShouldDraw(name)
	if SeriousHUD:Enabled() and tohide[name] then
		return false
	end
end

hook.Add("HUDShouldDraw", "SeriousHUD", HUDShouldDraw)