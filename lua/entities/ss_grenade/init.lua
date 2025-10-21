AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Model = Model("models/projectiles/serioussam/grenade.mdl")
ENT.ExplodeOnWallHit = true -- enable explosion on wall hit
ENT.ExplodeOnWallHitSpeed = 1400 -- min speed to explode at wall

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

ENT.HitNormal = Vector(0,0,0)

function ENT:PhysicsCollide(data, phys)
	if self.didHit then return end
	self.HitNormal = data.HitNormal
	if self.ExplodeOnWallHit and data.HitEntity:IsWorld() and data.Speed >= self.ExplodeOnWallHitSpeed then
		self.didHit = true
		self:Explode(data.HitPos, self.HitNormal)
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

function ENT:Explode(exppos, hitnorm, hitEnt)
	if self.Exploded then return end
	self.Exploded = true
	
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
	
	if hitnorm then
		util.Decal("Scorch", pos + hitnorm, pos - hitnorm)
	else
		local trace = util.TraceLine({start = self:GetPos() + Vector(0,2,0), endpos = self:GetPos() - Vector(0,0,32), filter=self})
		util.Decal("Scorch", trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal)
	end
	
	self:EmitSound("weapons/serioussam/Explosion02.wav", 100, 100)
	local owner = self:GetOwner()
	if !IsValid(owner) then owner = self end
	self:DoSplashDamage(pos, self.DamageSplash, owner)
	self:DoDirectDamage(hitEnt, self.DamageDirect, owner)
	self:Remove()
end

function ENT:StartTouch(ent)
	if ent:IsValid() and ent:IsPlayer() or ent:IsNPC() or ent:Health() > 0 then
 		self:Explode(ent:GetPos(), nil, ent)
	end
end

function ENT:OnTakeDamage(dmginfo)
	if dmginfo:GetInflictor() != self and dmginfo:GetDamage() >= 20 then
		self:Explode()
	end
end