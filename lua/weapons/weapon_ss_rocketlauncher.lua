
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
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self:WeaponSound(self.Primary.Sound)
	self:TakeAmmo(1)
	self:IdleStuff()
	
	if SERVER then
		local pos = self.Owner:GetShootPos()
		local ang = self.Owner:GetAimVector():Angle()
		pos = pos +ang:Right() *1 -ang:Up() *7 -ang:Forward() *9
		local ent = ents.Create("ss_rocket")
		ent:SetAngles(ang)
		ent:SetPos(pos)
		ent:SetOwner(self.Owner)
		ent:SetDamage(self.Primary.Damage)
		ent:SetVelocity(ang:Up() *40 +ang:Forward() *1500)
		ent:Spawn()
	end
	self:HolsterDelay()
end

SWEP.HoldType			= "crossbow"
SWEP.Base				= "weapon_ss_base"
SWEP.Category			= "Serious Sam"
SWEP.Spawnable			= true

SWEP.ViewModel			= "models/weapons/serioussam/v_rocketlauncher.mdl"
SWEP.WorldModel			= "models/weapons/serioussam/w_rocketlauncher.mdl"

SWEP.Primary.Sound			= Sound("weapons/serioussam/rocketlauncher/fire.wav")
SWEP.Primary.Damage			= 100
SWEP.Primary.Delay			= .7
SWEP.Primary.DefaultClip	= 5
SWEP.Primary.Ammo			= "RPG_Round"

SWEP.DeployDelay			= 1