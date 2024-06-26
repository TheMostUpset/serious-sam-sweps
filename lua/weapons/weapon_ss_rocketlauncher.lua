
if CLIENT then

	SWEP.PrintName			= "XPML21 Rocket Launcher"
	SWEP.Author				= "Upset"
	SWEP.Slot				= 3
	SWEP.SlotPos			= 0
	SWEP.ViewModelFOV		= 65
	SWEP.WepIcon			= "icons/serioussam/RocketLauncher"
	killicon.Add("ss_rocket", SWEP.WepIcon, Color(255, 255, 255, 255))
	
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	local delay, dmg = self.Primary.Delay, self.Primary.Damage
	if self:IsDeathmatchRules() then
		delay, dmg = self.Primary.DelayDM, self.Primary.DamageDM
	end
	self:SetNextPrimaryFire(CurTime() + delay)
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self:WeaponSound(self.Primary.Sound)
	self:TakeAmmo(1)
	self:IdleStuff()
	self:CreateRocket(dmg)
	self:HolsterDelay()
end

function SWEP:CreateRocket(dmg)
	if SERVER then
		local pos = self.Owner:GetShootPos()
		local ang = self.Owner:GetAimVector():Angle()
		pos = pos +ang:Right() *1 -ang:Up() *7 -ang:Forward() *9
		local ent = ents.Create(self.EntityProjectile)
		ent:SetAngles(ang)
		ent:SetPos(pos)
		ent:SetOwner(self.Owner)
		ent:SetDamage(dmg)
		ent:SetVelocity(ang:Up() *40 +ang:Forward() *1500)
		ent:Spawn()
	end
end

if SERVER then

	function SWEP:GetNPCBulletSpread()
		return 10
	end

	function SWEP:GetNPCBurstSettings()
		return 1, 1, self.Primary.Delay * 2
	end

	function SWEP:GetNPCRestTimes()
		return self.Primary.Delay, self.Primary.Delay * 3
	end
	
end

SWEP.HoldType			= "crossbow"
SWEP.Base				= "weapon_ss_base"
SWEP.Category			= "Serious Sam"
SWEP.Spawnable			= true

SWEP.EntityPickup		= "ss_pickup_rocketl"
SWEP.EntityAmmo			= "ss_ammo_rockets"

SWEP.ViewModel			= "models/weapons/serioussam/v_rocketlauncher.mdl"
SWEP.WorldModel			= "models/weapons/serioussam/w_rocketlauncher.mdl"

SWEP.Primary.Sound			= Sound("weapons/serioussam/rocketlauncher/fire.wav")
SWEP.Primary.Damage			= 100
SWEP.Primary.DamageDM		= 80
SWEP.Primary.Delay			= .7
SWEP.Primary.DelayDM		= .6
SWEP.Primary.DefaultClip	= 5
SWEP.Primary.Ammo			= "RPG_Round"

SWEP.DeployDelay			= 1

SWEP.EntityProjectile		= "ss_rocket"