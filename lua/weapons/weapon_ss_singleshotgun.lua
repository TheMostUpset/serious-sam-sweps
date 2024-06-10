
if CLIENT then

	SWEP.PrintName			= "Pump-Action Shotgun"
	SWEP.Author				= "Upset"
	SWEP.Slot				= 2
	SWEP.SlotPos			= 0
	SWEP.ViewModelFOV		= 43
	SWEP.WepIcon			= "icons/serioussam/SingleShotgun"
	killicon.Add("weapon_ss_singleshotgun", SWEP.WepIcon, Color(255, 255, 255, 255))
	
else
	
	function SWEP:GetNPCBulletSpread()
		return 10
	end

	function SWEP:GetNPCBurstSettings()
		return 1, 1, self.Primary.Delay
	end

	function SWEP:GetNPCRestTimes()
		return self.Primary.Delay, self.Primary.Delay * 2
	end
	
end

SWEP.HoldType			= "shotgun"
SWEP.Base				= "weapon_ss_base"
SWEP.Category			= "Serious Sam"
SWEP.Spawnable			= true

SWEP.ViewModel			= "models/weapons/serioussam/v_singleshotgun.mdl"
SWEP.WorldModel			= "models/weapons/serioussam/w_singleshotgun.mdl"

SWEP.Primary.Sound			= Sound("weapons/serioussam/singleshotgun/Fire.wav")
SWEP.Primary.NumShots		= 7
SWEP.Primary.Cone			= .08
SWEP.Primary.Delay			= 1.1
SWEP.Primary.DelayDM		= .9
SWEP.Primary.DefaultClip	= 10
SWEP.Primary.Ammo			= "Buckshot"

SWEP.MuzzleScale			= 32
SWEP.EnableSmoke			= true