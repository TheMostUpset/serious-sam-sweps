
if CLIENT then

	SWEP.PrintName			= "Double Barrel Coach Gun"
	SWEP.Author				= "Upset"
	SWEP.Slot				= 2
	SWEP.SlotPos			= 1
	SWEP.ViewModelFOV		= 52
	SWEP.WepIcon			= "icons/serioussam/DoubleShotgun"
	killicon.Add("weapon_ss_doubleshotgun", SWEP.WepIcon, Color(255, 255, 255, 255))
	
end

function SWEP:SpecialThink()
	if self.ReloadSoundDelay and CurTime() > self.ReloadSoundDelay then
		self.ReloadSoundDelay = nil
		self:EmitSound(self.ReloadSound)
	end
end

function SWEP:WeaponSound(snd)
	self:EmitSound(snd, 100, 100, 1, CHAN_AUTO)
	self.ReloadSoundDelay = CurTime() +.3
end

if SERVER then

	function SWEP:GetNPCBulletSpread()
		return 12
	end

	function SWEP:GetNPCBurstSettings()
		return 1, 1, self.Primary.Delay
	end

	function SWEP:GetNPCRestTimes()
		return self.Primary.Delay, self.Primary.Delay * 3
	end
	
end

SWEP.HoldType			= "shotgun"
SWEP.Base				= "weapon_ss_base"
SWEP.Category			= "Serious Sam"
SWEP.Spawnable			= true

SWEP.ViewModel			= "models/weapons/serioussam/v_doubleshotgun.mdl"
SWEP.WorldModel			= "models/weapons/serioussam/w_doubleshotgun.mdl"

SWEP.Primary.Sound			= Sound("weapons/serioussam/doubleshotgun/Fire.wav")
SWEP.Primary.NumShots		= 14
SWEP.Primary.Cone			= .08
SWEP.Primary.Delay			= 1.65
SWEP.Primary.DefaultClip	= 20
SWEP.Primary.Ammo			= "Buckshot"

SWEP.AmmoToTake				= 2

SWEP.ReloadSound			= Sound("weapons/serioussam/doubleshotgun/Reload.wav")

SWEP.MuzzleScale			= 32
SWEP.EnableSmoke			= true