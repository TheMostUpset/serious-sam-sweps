AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Model = Model("models/projectiles/serioussam/rocket.mdl")
ENT.FlySound = Sound("weapons/serioussam/RocketFly.wav")

function ENT:Initialize()
	self:SetModel(self.Model)
	self:SetMoveType(MOVETYPE_FLY)
	self:SetSolid(SOLID_BBOX)
	self:SetCollisionBounds(Vector(), Vector())
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)

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
	
	self:EmitSound(self.FlySound)
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

function ENT:Explode(pos, norm)
	self:ExplosionEffects(pos + norm * 2, norm)
	self:EmitSound("weapons/serioussam/Explosion02.wav", 100, 100)
	
	local owner = IsValid(self.Owner) and self.Owner or self
	local dmg = DamageInfo()
	dmg:SetInflictor(self)
	dmg:SetAttacker(owner)
	dmg:SetDamage(self.Damage)
	dmg:SetDamageType(bit.bor(DMG_BLAST, DMG_AIRBOAT))
	util.BlastDamageInfo(dmg, pos, 256)
	
	self:Remove()
end

function ENT:Touch(ent)
	if !ent:IsSolid() then return end

	if self.didHit then return end
	self.didHit = true
	
	local tr = self:GetTouchTrace()
	
	local start = tr.HitPos - tr.HitNormal
    local endpos = tr.HitPos + tr.HitNormal
	if tr.HitWorld then
		util.Decal("Scorch", start, endpos)
	end

	self:Explode(tr.HitPos, tr.HitNormal)
end

function ENT:OnRemove()
	self:StopSound(self.FlySound)
end

function ENT:Think()
	self:SetLocalVelocity(self:GetForward() * 1024)
end