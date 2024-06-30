
if CLIENT then

	SWEP.PrintName			= "Schofield .45"
	SWEP.Author				= "Upset"
	SWEP.Slot				= 1
	SWEP.SlotPos			= 0
	SWEP.ViewModelFOV		= 58
	SWEP.WepIcon			= "icons/serioussam/Colt"
	killicon.Add("weapon_ss_colt", SWEP.WepIcon, Color(255, 255, 255, 255))

end

function SWEP:SpecialDataTables()
	self:NetworkVar("Float", 5, "NextReload")
	self:NetworkVar("Float", 6, "SecondReload")
end

function SWEP:SpecialDeploy()
	self.DeployAnim = ACT_VM_DRAW
	self:SetDeploySpeed(self.DeployDelay)
end

function SWEP:DelayedHolster(wep)
	local hTime = self.HolsterTime
	self:SetNewWeapon(wep)
	self:SetIdleDelay(0)
	if wep:GetClass() == self:GetClass().."_dual" then
		hTime = 0
		wep:SetClip1(self:Clip1() * 2)
		wep.DeployAnim = ACT_VM_IDLE
		wep:SetDeploySpeed(self.DeployDelayToDual)
	else
		self:SendWeaponAnim(ACT_VM_HOLSTER)
	end
	-- self:SetNextPrimaryFire(CurTime() + hTime + .05)
	-- self:SetNextReload(CurTime() + hTime + .05)
	self:SetBeingHolster(true)
	self:SetHolsterTime(CurTime() + hTime)
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:WeaponSound(self.Primary.Sound)
	self:Attack()
	self:SeriousFlash()
	self:IdleStuff()
end

function SWEP:Attack()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)	
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self:ShootBullet(self.Primary.Damage, self.Primary.NumShots, self.Primary.Cone)
	if !self.Owner:IsNPC() then self:TakePrimaryAmmo(1) end
	self:SetNextReload(CurTime() +self.Primary.Delay +.2)
	self:HolsterDelay()
end

function SWEP:Reload()
	if self:Clip1() > 0 and CurTime() < self:GetNextReload() then return end
	if self:Clip1() >= self.Primary.ClipSize or !self:CanUseWeapon() then return end
	self:HolsterDelay(CurTime() +1)
	self:SendWeaponAnim(ACT_VM_RELOAD)
	self.Owner:SetAnimation(PLAYER_RELOAD)
	self:SetClip1(self.Primary.ClipSize)
	self:EmitSound(self.ReloadSound)
	self:SetNextPrimaryFire(CurTime() +1)
	self:IdleStuff()
end

function SWEP:CanPrimaryAttack()
	if !self:CanUseWeapon() then return false end

	if self:Clip1() <= 0 then
		self:SetNextPrimaryFire(CurTime() + .2)
		self:Reload()
		return false
	end 
	return true
end

if SERVER then	
	function SWEP:GetNPCBulletSpread()
		return 5
	end
end

SWEP.HoldType			= "pistol"
SWEP.Base				= "weapon_ss_base"
SWEP.Category			= "Serious Sam"
SWEP.Spawnable			= true

SWEP.EntityPickup		= "ss_pickup_colt"

SWEP.ViewModel			= "models/weapons/serioussam/v_colt.mdl"
SWEP.WorldModel			= "models/weapons/serioussam/w_colt.mdl"

SWEP.Primary.Sound			= Sound("weapons/serioussam/colt/Fire.wav")
SWEP.Primary.Cone			= .01
SWEP.Primary.ClipSize		= 6
SWEP.Primary.Delay			= .45
SWEP.Primary.DefaultClip	= 6

SWEP.ReloadSound			= "weapons/serioussam/colt/Reload.wav"

SWEP.DeployDelay			= 1.9
SWEP.DeployDelayToDual		= 3
SWEP.DeployDelayToSingle	= 13