local cvar_enable = CreateClientConVar("ss_hud", 0, true, false, "Enable Serious Sam Classic HUD", 0, 1)
local cvar_ammoicons = CreateClientConVar("ss_hud_ammoicons", 1, true, false, "Show ammo icons on Serious Sam Classic HUD", 0, 1)
local cvar_skin = CreateClientConVar("ss_hud_skin", 2, true, false, "1 - TFE, 2 - TSE", 1, 2)
local cvar_colR = CreateClientConVar("ss_hud_color_r", 0)
local cvar_colG = CreateClientConVar("ss_hud_color_g", 255)
local cvar_colB = CreateClientConVar("ss_hud_color_b", 0)

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

function SeriousHUD:GetSkin()
	return cvar_skin:GetInt()
end

function SeriousHUD:GetColor()
	if SeriousHUD:GetSkin() == 1 then
		return cvar_colR:GetInt(), cvar_colG:GetInt(), cvar_colB:GetInt()
	end
	return 255, 255, 255
end

function SeriousHUD:GetFrameColor()
	if SeriousHUD:GetSkin() == 1 then
		return SeriousHUD:GetColor()
	end
	return 90, 120, 180
end

function SeriousHUD:GetTextColor()
	if SeriousHUD:GetSkin() == 1 then
		return SeriousHUD:GetColor()
	end
	return 255, 230, 0
end

function SeriousHUD:GetBlinkColor()
	return math.Clamp(math.sin(RealTime() * 12.5) * 4000, 40, 255)
end

local function CreateSeriousFonts()
	local scale = SeriousHUD:GetHUDScale()

	surface.CreateFont("seriousHUDfont", {
		font = "Tahoma",
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
function SeriousHUD:DrawPickupText()
	if pickuptext and pickuptextTime and pickuptextTime > RealTime() then
		local text = pickupamount > 0 and pickuptext.." +".. pickupamount or pickuptext
		draw.SimpleText(text, "seriousHUDpickuptext", ScrW() / 2 + 1, ScrH() / 1.24 + 1, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER)
		draw.SimpleText(text, "seriousHUDpickuptext", ScrW() / 2 + 2, ScrH() / 1.24 + 2, Color(0, 0, 0, 100), TEXT_ALIGN_CENTER)
		draw.SimpleText(text, "seriousHUDpickuptext", ScrW() / 2, ScrH() / 1.24, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
	end
end

local HSuper = 1
local ArMedium = 2

local WCannon = 3
local WChainsaw = 4
local WColt = 5
local WColtDual = 6
local WDoubleShotgun = 7
local WFlamer = 8
local WGhostBuster = 9
local WGrenadeLauncher = 10
local WKnife = 11
local WLaser = 12
local WMinigun = 13
local WRocketLauncher = 14
local WSingleShotgun = 15
local WSniper = 16
local WTommygun = 17

local AmBullets = 18
local AmCannonBall = 19
local AmElectricity = 20
local AmFuelReservoir = 21
local AmGrenades = 22
local AmRockets = 23
local AmShells = 24
local AmSniperBullets = 25

SeriousHUD.Textures = {
	{
		[HSuper] = surface.GetTextureID("vgui/serioussam/hud_tfe/HSuper"),
		[ArMedium] = surface.GetTextureID("vgui/serioussam/hud_tfe/ArStrong"),

		[WCannon] = surface.GetTextureID("vgui/serioussam/hud_tfe/WCannon"),
		[WChainsaw] = surface.GetTextureID("vgui/serioussam/hud_tfe/WChainsaw"),
		[WColt] = surface.GetTextureID("vgui/serioussam/hud_tfe/WColt"),
		[WColtDual] = surface.GetTextureID("vgui/serioussam/hud_tfe/WColtDual"),
		[WDoubleShotgun] = surface.GetTextureID("vgui/serioussam/hud_tfe/WDoubleShotgun"),
		[WFlamer] = surface.GetTextureID("vgui/serioussam/hud_tfe/WFlamer"),
		[WGhostBuster] = surface.GetTextureID("vgui/serioussam/hud_tfe/WGhostBuster"),
		[WGrenadeLauncher] = surface.GetTextureID("vgui/serioussam/hud_tfe/WGrenadeLauncher"),
		[WKnife] = surface.GetTextureID("vgui/serioussam/hud_tfe/WKnife"),
		[WLaser] = surface.GetTextureID("vgui/serioussam/hud_tfe/WLaser"),
		[WMinigun] = surface.GetTextureID("vgui/serioussam/hud_tfe/WMinigun"),
		[WRocketLauncher] = surface.GetTextureID("vgui/serioussam/hud_tfe/WRocketLauncher"),
		[WSingleShotgun] = surface.GetTextureID("vgui/serioussam/hud_tfe/WSingleShotgun"),
		[WSniper] = surface.GetTextureID("vgui/serioussam/hud_tfe/WSniper"),
		[WTommygun] = surface.GetTextureID("vgui/serioussam/hud_tfe/WTommygun"),

		[AmBullets] = surface.GetTextureID("vgui/serioussam/hud_tfe/AmBullets"),
		[AmCannonBall] = surface.GetTextureID("vgui/serioussam/hud_tfe/AmCannon"),
		[AmElectricity] = surface.GetTextureID("vgui/serioussam/hud_tfe/AmElectricity"),
		[AmFuelReservoir] = surface.GetTextureID("vgui/serioussam/hud_tfe/AmFuelReservoir"),
		[AmGrenades] = surface.GetTextureID("vgui/serioussam/hud_tfe/AmGrenades"),
		[AmRockets] = surface.GetTextureID("vgui/serioussam/hud_tfe/AmRockets"),
		[AmShells] = surface.GetTextureID("vgui/serioussam/hud_tfe/AmShells"),
		[AmSniperBullets] = surface.GetTextureID("vgui/serioussam/hud_tfe/AmSniperBullets")
	},
	{
		[HSuper] = surface.GetTextureID("vgui/serioussam/hud/HSuper"),
		[ArMedium] = surface.GetTextureID("vgui/serioussam/hud/ArMedium"),

		[WCannon] = surface.GetTextureID("vgui/serioussam/hud/WCannon"),
		[WChainsaw] = surface.GetTextureID("vgui/serioussam/hud/WChainsaw"),
		[WColt] = surface.GetTextureID("vgui/serioussam/hud/WColt"),
		[WColtDual] = surface.GetTextureID("vgui/serioussam/hud/WColtDual"),
		[WDoubleShotgun] = surface.GetTextureID("vgui/serioussam/hud/WDoubleShotgun"),
		[WFlamer] = surface.GetTextureID("vgui/serioussam/hud/WFlamer"),
		[WGhostBuster] = surface.GetTextureID("vgui/serioussam/hud/WGhostBuster"),
		[WGrenadeLauncher] = surface.GetTextureID("vgui/serioussam/hud/WGrenadeLauncher"),
		[WKnife] = surface.GetTextureID("vgui/serioussam/hud/WKnife"),
		[WLaser] = surface.GetTextureID("vgui/serioussam/hud/WLaser"),
		[WMinigun] = surface.GetTextureID("vgui/serioussam/hud/WMinigun"),
		[WRocketLauncher] = surface.GetTextureID("vgui/serioussam/hud/WRocketLauncher"),
		[WSingleShotgun] = surface.GetTextureID("vgui/serioussam/hud/WSingleShotgun"),
		[WSniper] = surface.GetTextureID("vgui/serioussam/hud/WSniper"),
		[WTommygun] = surface.GetTextureID("vgui/serioussam/hud/WTommygun"),

		[AmBullets] = surface.GetTextureID("vgui/serioussam/hud/AmBullets"),
		[AmCannonBall] = surface.GetTextureID("vgui/serioussam/hud/AmCannonBall"),
		[AmElectricity] = surface.GetTextureID("vgui/serioussam/hud/AmElectricity"),
		[AmFuelReservoir] = surface.GetTextureID("vgui/serioussam/hud/AmFuelReservoir"),
		[AmGrenades] = surface.GetTextureID("vgui/serioussam/hud/AmGrenades"),
		[AmRockets] = surface.GetTextureID("vgui/serioussam/hud/AmRockets"),
		[AmShells] = surface.GetTextureID("vgui/serioussam/hud/AmShells"),
		[AmSniperBullets] = surface.GetTextureID("vgui/serioussam/hud/AmSniperBullets")
	}
}

SeriousHUD.WeaponIcons = {
	["weapon_ss_knife"] = WKnife,
	["weapon_ss_chainsaw"] = WChainsaw,
	["weapon_ss_colt"] = WColt,
	["weapon_ss_colt_dual"] = WColtDual,
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
	["weapon_sshd_colt_dual"] = WColtDual,
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

function SeriousHUD:GetTexTable()
	return SeriousHUD.Textures[SeriousHUD:GetSkin()]
end

function SeriousHUD:GetTexture(tex)
	return SeriousHUD:GetTexTable()[tex]
end

function SeriousHUD:GetWeaponIcon(class)
	return SeriousHUD:GetTexture(SeriousHUD.WeaponIcons[class])
end

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
	["Buckshot"] = {icon = AmShells, maxammo = 100},
	["SMG1"] = {icon = AmBullets, maxammo = 500},
	["RPG_Round"] = {icon = AmRockets, maxammo = 50},
	["Grenade"] = {icon = AmGrenades, maxammo = 50},
	["napalm"] = {icon = AmFuelReservoir, maxammo = 500},
	["SniperRound"] = {icon = AmSniperBullets, maxammo = 50},
	["AR2"] = {icon = AmElectricity, maxammo = 400},
	["cannonball"] = {icon = AmCannonBall, maxammo = 30}
}

local ammoicons_list = {
	[8] = "Buckshot",
	[7] = "SMG1",
	[6] = "RPG_Round",
	[5] = "Grenade",
	[4] = "napalm",
	[3] = "SniperRound",
	[2] = "AR2",
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

local col_update_speed = .75 -- how fast health/ammo numbers going to be white on change

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
		local obstarget = LocalPlayer():GetObserverTarget()
		local isSpectating = IsValid(obstarget)
		if isSpectating then
			client = obstarget
		end
		
		local hud_color_r, hud_color_g, hud_color_b = SeriousHUD:GetColor()
		local hud_skin = SeriousHUD:GetSkin()
		
		local awep = client:GetActiveWeapon()
		
		local icons = SeriousHUD:GetTexTable()
		
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
		
		local hudr, hudg, hudb = SeriousHUD:GetFrameColor()
		local textr, textg, textb = SeriousHUD:GetTextColor()
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

		local hpcolr, hpcolg, hpcolb = textr, textg, textb		
		if hud_skin == 1 then
			if hp <= 20 then
				hpcolr, hpcolg, hpcolb = 255, 0, 0
			end
		else
			if hp <= 25 then
				hpcolr, hpcolg, hpcolb = 255, 0, 0
			elseif hp <= 50 then
				hpcolr, hpcolg, hpcolb = 255, 120, 0
			elseif hp > 100 then
				hpcolr, hpcolg, hpcolb = 100, 255, 100
			end
		end

		if math.min(RealTime() - healthchangetime + col_update_speed, 0) != 0 then
			hpcolr, hpcolg, hpcolb = 255, 255, 255
		end
		
		local hp_icon_r, hp_icon_g, hp_icon_b = hud_color_r, hud_color_g, hud_color_b
		local hp_icon_blink = 1		
		if hp <= 10 then
			hp_icon_blink = SeriousHUD:GetBlinkColor() / 255
		end
		
		surface.SetTexture(icons[HSuper])
		surface.SetDrawColor(hp_icon_r*hp_icon_blink, hp_icon_g*hp_icon_blink, hp_icon_b*hp_icon_blink, 255)
		surface.DrawTexturedRect(gap_screen +health_jit_x, y +health_jit_y, size, size)	
		
		surface.SetFont("seriousHUDfont")
		local textsize_w, textsize_h = surface.GetTextSize(hp)
		SeriousText(hp, (widerectleft_x) + (widerect_w - textsize_w) / 2, y - text_align_y, Color(hpcolr, hpcolg, hpcolb, 255))
		
		OnHealthNumChange(client, hp)
		
		//armor
		
		if armor > 0 then
			local armor_icon_r, armor_icon_g, armor_icon_b = hud_color_r, hud_color_g, hud_color_b
			surface.SetTexture(icons[ArMedium])
			surface.SetDrawColor(armor_icon_r, armor_icon_g, armor_icon_b, 255)
			surface.DrawTexturedRect(gap_screen +armor_jit_x, armor_y +armor_jit_y, size, size)
			local textsize_w, textsize_h = surface.GetTextSize(armor)
			SeriousText(armor, (widerectleft_x) + (widerect_w - textsize_w) / 2, armor_y - text_align_y, Color(textr, textg, textb, 255))
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
			
			local wicn = SeriousHUD.WeaponIcons[class]
			local hl2 = hl2weapons[class]
			local wep_icon_r, wep_icon_g, wep_icon_b = hud_color_r, hud_color_g, hud_color_b
			if wicn then
				surface.SetTexture(icons[wicn])
				surface.SetDrawColor(wep_icon_r, wep_icon_g, wep_icon_b, 255)
				surface.DrawTexturedRect(cntr +ammo_jit_x, y +ammo_jit_y, size, size)
			elseif hl2 then
				if hud_skin != 1 then
					wep_icon_r, wep_icon_g, wep_icon_b = 255, 230, 180
				end	
				draw.SimpleText(hl2, "seriousHUDfontHL2", cntr+size/2 +ammo_jit_x, y*1.05 +ammo_jit_y, Color(wep_icon_r, wep_icon_g, wep_icon_b, 255), TEXT_ALIGN_CENTER, 1)
			else
				local icon = awep.WepIcon or awep.WepSelectIcon
				if icon then
					surface.SetTexture(icon)
					surface.SetDrawColor(wep_icon_r, wep_icon_g, wep_icon_b, 255)
					surface.DrawTexturedRect(cntr +ammo_jit_x, y +ammo_jit_y, size, size)
				end
			end
			
			local atype = awep:GetPrimaryAmmoType()
			local atypeName = game.GetAmmoName(atype)
			local anum = client:GetAmmoCount(atype)
			local clipammo = awep:Clip1()

			local ammocount
			if clipammo == -1 then
				ammocount = anum
			else
				ammocount = clipammo + anum
			end
			
			local ammo_text_r, ammo_text_g, ammo_text_b = textr, textg, textb
			local ammo_icon_r, ammo_icon_g, ammo_icon_b = hud_color_r, hud_color_g, hud_color_b
			local ammo_icon_blink = 1
			local findammotype = ammoicons[atypeName]
			if findammotype and awep:IsScripted() and (awep.Base == "weapon_ss_base" or awep.Base == "weapon_sshd_base") then
				if hud_skin == 1 then
					if ammocount <= findammotype.maxammo / 5 then
						ammo_text_r, ammo_text_g, ammo_text_b = 255, 0, 0
					end
					if ammocount <= findammotype.maxammo / 8 then
						ammo_icon_blink = SeriousHUD:GetBlinkColor() / 255
					end
				else
					if ammocount <= math.ceil(findammotype.maxammo / 3.5) then
						ammo_text_r, ammo_text_g, ammo_text_b = 255, 120, 0
					end
					if ammocount <= math.ceil(findammotype.maxammo / 8) then
						ammo_text_r, ammo_text_g, ammo_text_b = 255, 0, 0
					end
					if ammocount <= math.floor(findammotype.maxammo / 15) then
						ammo_icon_blink = SeriousHUD:GetBlinkColor() / 255
					end
				end
			end
			if ammocount <= 0 then
				ammo_text_r, ammo_text_g, ammo_text_b = 255, 0, 0
				ammo_icon_blink = SeriousHUD:GetBlinkColor() / 255
			end
			if hud_skin == 1 then
				if math.min(RealTime() - ammochangetime + col_update_speed, 0) != 0 then
					ammo_text_r, ammo_text_g, ammo_text_b = 255, 255, 255
				end
			end
			
			if curammo != -1 then
				surface.SetFont("seriousHUDfont")
				local textsize_w, textsize_h = surface.GetTextSize(ammocount)
				SeriousText(ammocount, ammorectx + (widerect_w - textsize_w) / 2, y - text_align_y, Color(ammo_text_r, ammo_text_g, ammo_text_b, 255))
				OnAmmoNumChange(client, ammocount)
			else
				ammo_jit_x = 0
				ammo_jit_y = 0
			end
			
			if curammo != -1 then
				if findammotype then
					surface.SetTexture(icons[findammotype.icon])
					surface.SetDrawColor(ammo_icon_r*ammo_icon_blink, ammo_icon_g*ammo_icon_blink, ammo_icon_b*ammo_icon_blink, 255)
				else
					surface.SetTexture(icons[AmBullets])
					surface.SetDrawColor(ammo_icon_r*ammo_icon_blink, ammo_icon_g*ammo_icon_blink, ammo_icon_b*ammo_icon_blink, 255)
				end
				surface.DrawTexturedRect(ammoiconrectx, y, size, size)
			end
		
		end
		
		//ammo icons
		if SeriousHUD:AmmoIconsEnabled() then
			local ammosize = size/1.25
			local ammoy = y+ammosize/4
			local icon_gap = 5.5
			local iconpos = ScrW() - gap_screen + icon_gap + 1
			local curammo = IsValid(awep) and awep:GetPrimaryAmmoType()
			for k,v in ipairs(ammoicons_list) do
				local ammoc = client:GetAmmoCount(v)
				if ammoc > 0 then
					OnAmmoNumIconChange(client, ammoc, k)
					iconpos = iconpos - ammosize - icon_gap
					surface.SetDrawColor(rect, rect, rect, recta)
					surface.DrawRect(iconpos, ammoy+client:GetVar("ammo_icon_jit"..k, 0), ammosize, ammosize)
					surface.SetDrawColor(hudr, hudg, hudb, 255)
					surface.DrawOutlinedRect(iconpos, ammoy+client:GetVar("ammo_icon_jit"..k, 0), ammosize, ammosize)
					
					local ammodata = ammoicons[v]
					if ammodata then
						local icon_r, icon_g, icon_b = hud_color_r, hud_color_g, hud_color_b
						if hud_skin == 1 and curammo == game.GetAmmoID(v) then
							icon_r, icon_g, icon_b = 255, 255, 255
						end
						surface.SetTexture(icons[ammodata.icon])
						surface.SetDrawColor(icon_r, icon_g, icon_b, 255)
						surface.DrawTexturedRect(iconpos+2, ammoy+2+client:GetVar("ammo_icon_jit"..k, 0), ammosize/1.075, ammosize/1.075)
						
						local idk = math.min(ammosize / (ammodata.maxammo / ammoc), ammosize)
						local ammobar = idk/1.125
						local ammocolr, ammocolg, ammocolb = 255, idk*4.25, 0
						if hud_skin == 1 then
							ammocolr, ammocolg, ammocolb = hud_color_r, hud_color_g, hud_color_b
							if ammoc <= ammodata.maxammo / 5 then
								ammocolr, ammocolg, ammocolb = 255, 0, 0
							end
						end
						if math.min(RealTime() -client:GetVar("ammochangetimeIcon"..k, 0)+col_update_speed, 0) != 0 then
							ammocolr, ammocolg, ammocolb = 255, 255, 255
						end
						surface.SetDrawColor(ammocolr, ammocolg, ammocolb, 220)
						surface.DrawRect(iconpos+ammosize/1.375, ammoy+ammosize/1.06-math.floor(ammobar)+client:GetVar("ammo_icon_jit"..k, 0), ammosize/4.75, ammobar)
					end
				end
			end
		end
	end

	SeriousHUD:DrawPickupText()
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