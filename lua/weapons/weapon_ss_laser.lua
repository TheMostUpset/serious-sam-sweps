
if CLIENT then

	SWEP.PrintName			= "XL2 Lasergun"
	SWEP.Author				= "Upset"
	SWEP.Slot				= 4
	SWEP.SlotPos			= 2
	SWEP.ViewModelFOV		= 70
	SWEP.WepIcon			= "icons/serioussam/Laser"
	killicon.Add("weapon_ss_laser", SWEP.WepIcon, Color(255, 255, 255, 255))
	
end

function SWEP:SpecialDataTables()
	self:NetworkVar("Int", 1, "Barrel")
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self:WeaponSound(self.Primary.Sound)
	self:TakeAmmo(1)	

	local pos = self.Owner:GetShootPos()
	local ang = self.Owner:GetAimVector():Angle()
	local barrel = self:GetBarrel()
	
	if barrel == 0 then
		self:SetBarrel(1)
		pos = pos -ang:Up() *6
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK_1)
	elseif barrel == 1 then
		self:SetBarrel(2)
		pos = pos -ang:Right() *1 -ang:Up() *9
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK_2)
	elseif barrel == 2 then
		self:SetBarrel(3)
		pos = pos +ang:Right() *9 -ang:Up() *6
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK_3)
	elseif barrel == 3 then
		self:SetBarrel(0)
		pos = pos +ang:Right() *10 -ang:Up() *9
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK_4)
	end
		
	if SERVER then
		local ent = ents.Create("ss_laser")
		ent:SetAngles(ang)
		ent:SetPos(pos +ang:Forward() *2)
		ent:SetOwner(self.Owner)
		ent:SetDamage(self.Primary.Damage)
		ent:Spawn()
		ent:Activate()
		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetVelocity(ang:Up() *2 +ang:Forward() *4096 +ang:Right() *-2)
		end
	end
	self:HolsterDelay()
	self:IdleStuff()
end

function SWEP:SpecialThink()
	if self.Owner:KeyReleased(IN_ATTACK) then
		self:OnRemove()
	end
end

function SWEP:OnRemove()
	self:SetBarrel(0)
end

SWEP.HoldType			= "crossbow"
SWEP.Base				= "weapon_ss_base"
SWEP.Category			= "Serious Sam"
SWEP.Spawnable			= true

SWEP.ViewModel			= "models/weapons/serioussam/v_laser.mdl"
SWEP.WorldModel			= "models/weapons/serioussam/w_laser.mdl"

SWEP.Primary.Sound			= Sound("weapons/serioussam/laser/fire.wav")
SWEP.Primary.Damage			= 20
SWEP.Primary.Delay			= .1
SWEP.Primary.DefaultClip	= 50
SWEP.Primary.Ammo			= "ar2"

SWEP.LaserPos				= true

SWEP.DeployDelay			= .9