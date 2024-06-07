if CLIENT then

	SWEP.PrintName			= "XL4-P Beam Gun"
	SWEP.Author				= "Upset"
	SWEP.Slot				= 4
	SWEP.SlotPos			= 3
	SWEP.ViewModelFOV		= 54
	SWEP.WepIcon			= "icons/serioussam/ghostbuster"
	killicon.Add("weapon_ss_ghostbuster", SWEP.WepIcon, Color(255, 255, 255, 255))
	
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	
	if !self:GetAttack() then
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		self:SetIdleDelay(0)
	end
	
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetAttack(true)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self:TakeAmmo()
	
	if !self.FireSound then
		self.FireSound = CreateSound(self.Owner, self.Primary.Sound)
		self.FireSound:SetSoundLevel(100)
	end
	if self.FireSound and !self.FireSound:IsPlaying() then
		self.FireSound:Play()
	end
	
	if SERVER then self.Owner:LagCompensation(true) end
	local tr = util.TraceLine({
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.HitDist,
		filter = self.Owner
	})
	
	if IsFirstTimePredicted() then
		local ef_ray = EffectData()
		ef_ray:SetOrigin(self.Owner:GetShootPos())
		ef_ray:SetStart(tr.HitPos)
		ef_ray:SetEntity(self)
		ef_ray:SetAttachment(1)
		util.Effect("ss_lightning", ef_ray)
	
		local ef_hit = EffectData()
		ef_hit:SetOrigin(tr.HitPos)
		util.Effect("ss_lightning_hit", ef_hit)
	end
	
	/*if tr.HitWorld then
		local hit1, hit2 = tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal
		util.Decal("FadingScorch", hit1, hit2)
	end*/

	if !IsValid(tr.Entity) then
		tr = util.TraceHull({
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.HitDist,
		filter = self.Owner,
		mins = Vector(-4, -4, -4),
		maxs = Vector(4, 4, 4)
		})
	end
	
	if SERVER then
		if tr.Hit then				
			local dmginfo = DamageInfo()
			local attacker = self.Owner
			if !IsValid(attacker) then attacker = self end
			dmginfo:SetAttacker(attacker)
			dmginfo:SetInflictor(self)
			dmginfo:SetDamageType(DMG_SHOCK)
			dmginfo:SetDamage(self.Primary.Damage)
			dmginfo:SetDamageForce(self.Owner:GetUp() *2000 +self.Owner:GetForward() *20000)
			dmginfo:SetDamagePosition(tr.HitPos)
			tr.Entity:TakeDamageInfo(dmginfo)			
		end
		self.Owner:LagCompensation(false)
	end

	self:HolsterDelay(CurTime() + .1)
end

function SWEP:OnRemove()
	self:SetAttack(false)
	if self.FireSound then self.FireSound:Stop() end
end

function SWEP:SpecialThink()
	if self:GetAttack() and (self.Owner:KeyReleased(IN_ATTACK) or self:Ammo1() <= 0) then
		self:OnRemove()
		self:IdleStuff()
	end
end

local mat = Material("sprites/serioussam/lightning")
local flare = Material("sprites/serioussam/effectflare")

function SWEP:ViewModelDrawn(vm)
	local bone = vm:LookupBone("rotator")	
	if !bone then return end
	
	local pos, ang = vm:GetBonePosition(bone)
	pos = pos + vm:GetForward() * 3
	local right, up = ang:Forward(), ang:Up()
	local width = 2
	local size = 3
	local move = CurTime() * 4
	
	render.SetMaterial(mat)
	for i = -2, 2 do
		render.DrawBeam(pos + up * size, pos - right * size, width, move, move-i, Color(255, 255, 255, 255))
		render.DrawBeam(pos + up * size, pos + right * size, width, move, move+i, Color(255, 255, 255, 255))
		render.DrawBeam(pos + right * size, pos - up * size, width, move, move+i, Color(255, 255, 255, 255))
		render.DrawBeam(pos - up * size, pos - right * size, width, move, move+i, Color(255, 255, 255, 255))
	end
	render.SetMaterial(flare)
	render.DrawBeam(pos + up * size, pos - right * size, width, 0, 1, Color(255, 255, 255, 255))
	render.DrawBeam(pos + up * size, pos + right * size, width, 0, 1, Color(255, 255, 255, 255))
	render.DrawBeam(pos + right * size, pos - up * size, width, 0, 1, Color(255, 255, 255, 255))
	render.DrawBeam(pos - up * size, pos - right * size, width, 0, 1, Color(255, 255, 255, 255))	
end

SWEP.HoldType			= "crossbow"
SWEP.Base				= "weapon_ss_base"
SWEP.Category			= "Serious Sam"
SWEP.Spawnable			= true

SWEP.ViewModel			= "models/weapons/serioussam/v_ghostbuster.mdl"
SWEP.WorldModel			= "models/weapons/serioussam/w_ghostbuster.mdl"

SWEP.Primary.Sound			= Sound("weapons/serioussam/ghostbuster/fire.wav")
SWEP.Primary.Damage			= 15
SWEP.Primary.Delay			= .04
SWEP.Primary.DefaultClip	= 100
SWEP.Primary.Ammo			= "ar2"

SWEP.HitDist				= 1500