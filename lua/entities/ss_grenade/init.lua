AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Model = Model("models/projectiles/serioussam/grenade.mdl")
ENT.ExplodeOnWallHit = true -- enable explosion on wall hit
ENT.ExplodeOnWallHitSpeed = 1000 -- min speed to explode at wall

function ENT:Initialize()
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetMass(5)
		phys:Wake()
		phys:AddAngleVelocity(Vector(math.random(-1,1) *300,-200,0))
	end
end

function ENT:SetExplodeDelay(flDelay)
	self.delayExplode = CurTime() + flDelay
end

function ENT:SetDamage(dmg)
	self.Damage = dmg
end

ENT.HitNormal = Vector(0,0,0)

function ENT:PhysicsCollide(data, phys)
	self.HitNormal = data.HitNormal
	if self.ExplodeOnWallHit and data.Speed >= self.ExplodeOnWallHitSpeed then
		self:Explode()
	else
		if data.DeltaTime > 0.05 then self:EmitSound("weapons/serioussam/grenadelauncher/Bounce.wav") end
		local impulse = -data.Speed * data.HitNormal * 1.5
		phys:ApplyForceCenter(impulse)
	end
end

function ENT:Think()
	if !self.delayExplode || CurTime() < self.delayExplode then return end
	self.delayExplode = nil
	self:Explode()
end

function ENT:ExplosionEffects(pos, ang)
	local effectdata = EffectData()
	effectdata:SetAngles(ang)
	effectdata:SetOrigin(pos)
	effectdata:SetScale(3.8)
	util.Effect("ss_shockwave", effectdata)
	
	local explosion = EffectData()
	explosion:SetOrigin(pos)
	explosion:SetMagnitude(3)
	explosion:SetScale(2)
	explosion:SetRadius(4)
	util.Effect("Sparks", explosion)
	util.Effect("ss_exprocket", explosion)
	util.Effect("ss_expparticles", explosion)
end

function ENT:Explode(exppos)
	local pos = self:GetPos()
	exppos = exppos or pos
	
	local tr = util.TraceHull({
		start = pos,
		endpos = exppos,
		filter = self
	})
	
	pos = tr.HitPos
	
	self.delayExplode = nil

	self:ExplosionEffects(pos, self.HitNormal:Angle())
	
	local trace = util.TraceLine({start = self:GetPos() + Vector(0,2,0), endpos = self:GetPos() - Vector(0,0,32), filter=self})
	util.Decal("Scorch", trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal)
	
	self:EmitSound("weapons/serioussam/Explosion02.wav", 100, 100)
	local owner = self:GetOwner()
	if !IsValid(owner) then owner = self end
	util.BlastDamage(self, owner, pos, 256, self.Damage)
	self:Remove()
end

function ENT:StartTouch(ent)
	if ent:IsValid() and ent:IsPlayer() or ent:IsNPC() or ent:Health() > 0 then
 		self:Explode(ent:GetPos())
	end
end
ENT.Exploded = nil
function ENT:OnTakeDamage(dmginfo)
	if self.Exploded then return end
	if dmginfo:GetInflictor() != self and dmginfo:IsExplosionDamage() and dmginfo:GetDamage() > 50 then
		self.Exploded = true
		self:Explode()
	end
end