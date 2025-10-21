AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Model = Model("models/projectiles/serioussam/rocket.mdl")
ENT.FlySound = Sound("weapons/serioussam/RocketFly.wav")
ENT.TrailTexture = "trails/laser"
ENT.TrailLifeTime = .8

function ENT:Initialize()
	self:SetModel(self.Model)
	self:SetMoveType(MOVETYPE_FLY)
	self:SetSolid(SOLID_BBOX)
	self:SetCollisionBounds(Vector(), Vector())
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)

	self.glow = ents.Create("env_sprite")
	local glow = self.glow
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
	-- ParticleEffectAttach("rocket_smoke_trail", PATTACH_ABSORIGIN_FOLLOW, self, 0)
	util.SpriteTrail(self, 0, Color(200, 200, 200), true, 50, 2.5, self.TrailLifeTime, 1 / ( 15 + 1 ) * 0.5, self.TrailTexture)
end

function ENT:Explode(pos, norm, hitEnt)
	self:ExplosionEffects(pos + norm * 2, norm:Angle())
	self:EmitSound("weapons/serioussam/Explosion02.wav", 100, 100)
	
	local owner = IsValid(self.Owner) and self.Owner or self
	self:DoSplashDamage(pos, self.DamageSplash, owner)
	self:DoDirectDamage(hitEnt, self.DamageDirect, owner)
	
	-- fake remove
	self:OnRemove()
	self:SetLocalVelocity(Vector())
	self:SetMoveType(MOVETYPE_NONE)
	self:AddEffects(EF_NODRAW)
	self:AddSolidFlags(FSOLID_NOT_SOLID)
	if self.glow and IsValid(self.glow) then self.glow:Remove() end
	SafeRemoveEntityDelayed(self, self.TrailLifeTime)
end

function ENT:Touch(ent)
	if !ent:IsSolid() then return end

	if self.didHit then return end
	self.didHit = true
	
	local tr = self:GetTouchTrace()

	self:CreateDecal(tr)
	self:Explode(tr.HitPos, tr.HitNormal, tr.Entity)
end

function ENT:OnRemove()
	self:StopSound(self.FlySound)
end

function ENT:Think()
	if self.didHit then return end
	self:SetLocalVelocity(self:GetForward() * 1024)
end

function ENT:CreateDecal(tr)	
	local start = tr.HitPos - tr.HitNormal
    local endpos = tr.HitPos + tr.HitNormal
	if tr.HitWorld then
		util.Decal("Scorch", start, endpos)
	end
end