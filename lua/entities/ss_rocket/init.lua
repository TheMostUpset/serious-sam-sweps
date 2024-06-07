
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Model = Model("models/projectiles/serioussam/rocket.mdl")

function ENT:Initialize()
	self:SetModel(self.Model)
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_CUSTOM)

	local glow = ents.Create("env_sprite")
	glow:SetKeyValue("rendercolor","255 180 60")
	glow:SetKeyValue("GlowProxySize","2")
	glow:SetKeyValue("HDRColorScale","1")
	glow:SetKeyValue("renderfx","14")
	glow:SetKeyValue("rendermode","3")
	glow:SetKeyValue("renderamt","100")
	glow:SetKeyValue("model","sprites/flare1.spr")
	glow:SetKeyValue("scale","1.5")
	glow:Spawn()
	glow:SetParent(self)
	glow:SetPos(self:GetPos())
	self:SetRenderMode(RENDERMODE_TRANSALPHA)

	//util.SpriteTrail(self, 0, Color(200, 200, 200), false, 10, 46, .5, 1 / 150, "trails/smoke.vmt")
	
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:SetMass(1)
		phys:EnableDrag(false)
		phys:EnableGravity(false)
		phys:SetBuoyancyRatio(0)
	end
	
	self.flysound = CreateSound(self, "weapons/serioussam/RocketFly.wav")
	self.flysound:Play()
	ParticleEffectAttach("rocket_smoke_trail", PATTACH_ABSORIGIN_FOLLOW, self, 0)
end

function ENT:SetDamage(dmg)
	self.Damage = dmg
end

function ENT:ExplosionEffects(pos, norm)
	local effectdata = EffectData()
	effectdata:SetAngles(norm:Angle())
	effectdata:SetOrigin(pos)
	effectdata:SetScale(3.8)
	util.Effect("ss_shockwave", effectdata)
	//effectdata:SetNormal(norm)
	//util.Effect("ss_exprocket_world", effectdata)
	//util.Effect("ss_expparticles_world", effectdata)
	
	local explosion = EffectData()
	explosion:SetOrigin(pos)
	explosion:SetMagnitude(3)
	explosion:SetScale(2)
	explosion:SetRadius(4)
	util.Effect("Sparks", explosion)
	util.Effect("ss_exprocket", explosion)
	util.Effect("ss_expparticles", explosion)
end

function ENT:Explode(exppos, norm)
	local tr = util.TraceHull({
		start = self:GetPos(),
		endpos = exppos,
		filter = self
	})	
	local pos = tr.HitPos

	self:ExplosionEffects(pos, norm)
	self:EmitSound("weapons/serioussam/Explosion02.wav", 100, 100)
	util.BlastDamage(self, self:GetOwner(), pos, 256, self.Damage)
	self:Remove()
end

function ENT:PhysicsCollide(data, physobj)
	local start = data.HitPos + data.HitNormal
    local endpos = data.HitPos - data.HitNormal
	util.Decal("Scorch", start, endpos)
	
	local hitent = data.HitEntity
	local pos = hitent:Health() > 0 and hitent:GetPos() or data.HitPos
	self:Explode(pos, data.HitNormal)
end

function ENT:OnRemove()
	if self.flysound then self.flysound:Stop() end
end

function ENT:Think()
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then phys:SetVelocity(self:GetAngles():Forward() *1024) return end
end