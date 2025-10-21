
if CLIENT then

	SWEP.PrintName			= "MK III Grenade Launcher"
	SWEP.Author				= "Upset"
	SWEP.Slot				= 3
	SWEP.SlotPos			= 1
	SWEP.ViewModelFOV		= 48
	SWEP.WepIcon			= "icons/serioussam/GrenadeLauncher"
	killicon.Add("ss_grenade", SWEP.WepIcon, Color(255, 255, 255, 255))
	
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() or self:GetAttackDelay() > 0 then return end
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK_1)
	self:SetAttackDelay(CurTime() +.85)
	self:HolsterDelay(self:GetAttackDelay())
end

function SWEP:SpecialThink()
	if game.SinglePlayer() and CLIENT then return end
	local attdelay = self:GetAttackDelay()
	if attdelay > 0 then
		if CurTime() +.75 > attdelay and !self.Owner:KeyDown(IN_ATTACK) or CurTime() > attdelay then
			self:Release()
		end
	end
end

function SWEP:Release()
	self:SetNextPrimaryFire(CurTime() +self.Primary.Delay)
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self:WeaponSound(self.Primary.Sound)
	self:TakeAmmo(1)
	self:HolsterDelay()
	local attdelay = self:GetAttackDelay()
	local pos = self.Owner:GetShootPos()
	local ang = self.Owner:GetAimVector():Angle()
	pos = pos +ang:Forward() *10 +ang:Right() *2 +ang:Up() *-8
	if SERVER then
		local ent = ents.Create("ss_grenade")
		ent:SetPos(pos)
		ent:SetAngles(ang)
		ent:SetOwner(self.Owner)
		ent:SetExplodeDelay(2.5)
		ent:SetDamage(self.Primary.Damage, self.Primary.DamageSplash)
		ent:Spawn()
		ent:Activate()
		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then
			local vel = ang:Forward() *2200 *(CurTime() - attdelay+.95) +ang:Up() *100
			phys:SetVelocity(vel)
		end
	end
	self:OnRemove()
end

function SWEP:OnRemove()
	self:SetAttackDelay(0)
end

SWEP.HoldType			= "crossbow"
SWEP.Base				= "weapon_ss_base"
SWEP.Category			= "Serious Sam"
SWEP.Spawnable			= true

SWEP.EntityPickup		= "ss_pickup_grenadel"
SWEP.EntityAmmo			= "ss_ammo_grenades"

SWEP.ViewModel			= "models/weapons/serioussam/v_grenadelauncher.mdl"
SWEP.WorldModel			= "models/weapons/serioussam/w_grenadelauncher.mdl"

SWEP.Primary.Sound			= Sound("weapons/serioussam/grenadelauncher/Fire.wav")
SWEP.Primary.Damage			= 75 -- direct damage
SWEP.Primary.DamageSplash	= 100 -- splash damage
SWEP.Primary.Delay			= .3
SWEP.Primary.DefaultClip	= 5
SWEP.Primary.Ammo			= "Grenade"

SWEP.EnableIdle				= true