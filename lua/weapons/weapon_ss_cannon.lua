
if CLIENT then

	SWEP.PrintName			= "SBC Cannon"
	SWEP.Author				= "Upset"
	SWEP.Slot				= 5
	SWEP.SlotPos			= 0
	SWEP.ViewModelFOV		= 52
	SWEP.WepIcon			= "icons/serioussam/Cannon"
	killicon.Add("ss_cannonball", SWEP.WepIcon, Color(255, 255, 255, 255))
	
end

function SWEP:SpecialDeploy()
	self:SetNextPrimaryFire(CurTime() +.7)
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() or self:GetAttackDelay() > 0 then return end
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK_1)
	self:SetAttackDelay(CurTime() +.95)
	self:HolsterDelay(self:GetAttackDelay())
	self.ChargeSound = CreateSound(self.Owner, self.Primary.Special)
	self.ChargeSound:Play()	
end

function SWEP:SpecialThink()
	if game.SinglePlayer() and CLIENT then return end
	local attdelay = self:GetAttackDelay()
	if attdelay > 0 then
		if CurTime() +.9 > attdelay and !self.Owner:KeyDown(IN_ATTACK) or CurTime() > attdelay then
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
	self:IdleStuff()
	self:HolsterDelay()
	local attdelay = self:GetAttackDelay()
	local pos = self.Owner:GetShootPos()
	local ang = self.Owner:GetAimVector():Angle()
	local damage = math.Clamp(self.Primary.Damage *(CurTime() - attdelay+1.65), self.Primary.Damage, 750)
	damage = math.Round(damage)
	pos = pos +ang:Forward() *-20 +ang:Right() *2
	if SERVER then
		local ent = ents.Create("ss_cannonball")
		ent:SetPos(pos)
		ent:SetAngles(ang)
		ent:SetOwner(self.Owner)
		ent:SetExplodeDelay(9.5)
		ent:SetDamage(damage)
		ent:Spawn()
		ent:Activate()
		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetMass(10000)
			phys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)
			local vel = ang:Forward() *1800 *(CurTime() - attdelay+1.7)*1.25 +ang:Up() *10
			phys:SetVelocity(vel)
		end
	end
	self:OnRemove()
end

function SWEP:OnRemove()
	self:SetAttackDelay(0)
	if self.ChargeSound then self.ChargeSound:Stop() end
end

SWEP.HoldType			= "shotgun"
SWEP.Base				= "weapon_ss_base"
SWEP.Category			= "Serious Sam"
SWEP.Spawnable			= true

SWEP.ViewModel			= "models/weapons/serioussam/v_cannon.mdl"
SWEP.WorldModel			= "models/weapons/serioussam/w_cannon.mdl"

SWEP.Primary.Sound			= Sound("weapons/serioussam/cannon/Fire.wav")
SWEP.Primary.Special		= Sound("weapons/serioussam/cannon/Prepare.wav")
SWEP.Primary.Damage			= 500
SWEP.Primary.Delay			= 1.3
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Ammo			= "cannonball"