
if CLIENT then

	SWEP.PrintName			= "M1-A2 Thompson"
	SWEP.Author				= "Upset"
	SWEP.Slot				= 2
	SWEP.SlotPos			= 2
	SWEP.ViewModelFOV		= 52
	SWEP.WepIcon			= "icons/serioussam/TommyGun"
	killicon.Add("weapon_ss_tommygun", SWEP.WepIcon, Color(255, 255, 255, 255))
	
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self:WeaponSound(self.Primary.Sound)
	self:ShootBullet(self.Primary.Damage, self.Primary.NumShots, self.Primary.Cone)
	self:SeriousFlash()
	self:TakeAmmo(self.AmmoToTake)
	self:IdleStuff()
	self:HolsterDelay()
	
	if self.EnableEndSmoke then
		self.SmokeAmount = self.SmokeAmount + 1
	end
end

function SWEP:SpecialThink()
	if self.Owner:KeyReleased(IN_ATTACK) or self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0 then
		if self.SmokeAmount > 0 then
			local num = game.SinglePlayer() and 90 or 200
			self.SmokeTime = CurTime() + math.min(self.SmokeAmount/num, 1.5)
			self.SmokeAmount = 0
		end
	end
end

function SWEP:OnRemove()
	self.SmokeAmount = 0
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