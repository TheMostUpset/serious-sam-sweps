
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/projectiles/serioussam/laserproj.mdl")
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	local mins, maxs = Vector(-8, -1, -1), Vector(8, 1, 1)
	self:PhysicsInitBox(mins, maxs)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_CUSTOM)
	self:DrawShadow(false)

	local glow = ents.Create("env_sprite")
	glow:SetKeyValue("rendercolor","60 255 60")
	glow:SetKeyValue("GlowProxySize","2")
	glow:SetKeyValue("HDRColorScale","1")
	glow:SetKeyValue("renderfx","14")
	glow:SetKeyValue("rendermode","3")
	glow:SetKeyValue("renderamt","100")
	glow:SetKeyValue("model","sprites/flare1.spr")
	glow:SetKeyValue("scale","1.2")
	glow:Spawn()
	glow:SetParent(self)
	glow:SetPos(self:GetPos())
	
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetMaterial("default_silent")
		phys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)
		phys:Wake()
		phys:SetMass(1)
		phys:EnableDrag(false)
		phys:EnableGravity(false)
		phys:SetBuoyancyRatio(0)
	end
end

function ENT:SetDamage(dmg)
	self.Damage = dmg
end

function ENT:ExplosionEffects(pos, ang)
	local effectdata = EffectData()
	effectdata:SetAngles(ang)
	effectdata:SetOrigin(pos)
	effectdata:SetScale(.65)
	util.Effect("ss_shockwavegreen", effectdata)
end

function ENT:PhysicsCollide(data, physobj)
	if self.didHit then return end
	self.didHit = true

	local start = data.HitPos + data.HitNormal
    local endpos = data.HitPos - data.HitNormal
	util.Decal("fadingscorch", start, endpos)	
	self:ExplosionEffects(endpos, data.HitNormal:Angle())
	data.HitEntity:TakeDamage(self.Damage, self.Entity:GetOwner())
	self:Remove()
end