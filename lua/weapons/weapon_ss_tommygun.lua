
if CLIENT then

	SWEP.PrintName			= "M1-A2 Thompson"
	SWEP.Author				= "Upset"
	SWEP.Slot				= 2
	SWEP.SlotPos			= 2
	SWEP.ViewModelFOV		= 52
	SWEP.WepIcon			= "icons/serioussam/TommyGun"
	killicon.Add("weapon_ss_tommygun", SWEP.WepIcon, Color(255, 255, 255, 255))
	
end

if SERVER then	
	function SWEP:GetNPCBulletSpread()
		return 6
	end

	function SWEP:GetNPCBurstSettings()
		return 1, 5, .1
	end

	function SWEP:GetNPCRestTimes()
		return .2, .4
	end
end

SWEP.HoldType			= "smg"
SWEP.Base				= "weapon_ss_base"
SWEP.Category			= "Serious Sam"
SWEP.Spawnable			= true

SWEP.EntityPickup		= "ss_pickup_tommygun"
SWEP.EntityAmmo			= "ss_ammo_bullets"

SWEP.ViewModel			= "models/weapons/serioussam/v_tommygun.mdl"
SWEP.WorldModel			= "models/weapons/serioussam/w_tommygun.mdl"

SWEP.Primary.Sound			= Sound("weapons/serioussam/tommygun/Fire.wav")
SWEP.Primary.Cone			= .015
SWEP.Primary.Delay			= .09
SWEP.Primary.DefaultClip	= 50
SWEP.Primary.Ammo			= "smg1"

SWEP.MuzzleScale			= 12
SWEP.EnableEndSmoke			= true
SWEP.SmokeAmount			= 0