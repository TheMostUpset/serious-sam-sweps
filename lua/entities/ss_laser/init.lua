AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Model = Model("models/projectiles/serioussam/laserproj.mdl")

function ENT:Initialize()
	self:SetModel(self.Model)
	self:SetMoveType(MOVETYPE_FLY)
	self:SetSolid(SOLID_BBOX)
	self:SetCollisionBounds(Vector(), Vector())
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
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
end

function ENT:SetDamage(dmg)
	self.Damage = dmg
end

function ENT:SetInflictor(ent)
	self.Inflictor = ent
end

function ENT:ExplosionEffects(pos, ang)
	local effectdata = EffectData()
	effectdata:SetAngles(ang)
	effectdata:SetOrigin(pos)
	effectdata:SetScale(.65)
	util.Effect("ss_shockwavegreen", effectdata)
end

function ENT:Touch(ent)
	if !ent:IsSolid() or self.didHit then return end
	self.didHit = true
	
	local tr = self:GetTouchTrace()

	local start = tr.HitPos - tr.HitNormal
    local endpos = tr.HitPos + tr.HitNormal
	if tr.HitWorld then
		util.Decal("fadingscorch", start, endpos)
	end
	self:ExplosionEffects(endpos, tr.HitNormal:Angle())
	self:DoDamage(ent, tr)
	self:Remove()
end

function ENT:DoDamage(ent, tr)
	local dmginfo = DamageInfo()
	local attacker = self:GetOwner()
	if !IsValid(attacker) then attacker = self end
	local inflictor = self.Inflictor
	if !IsValid(inflictor) then inflictor = self end
	dmginfo:SetAttacker(attacker)
	dmginfo:SetInflictor(inflictor)
	dmginfo:SetDamage(self.Damage)
	dmginfo:SetDamagePosition(tr.HitPos)
	dmginfo:SetDamageType(bit.bor(DMG_ENERGYBEAM, DMG_AIRBOAT))
	dmginfo:SetDamageForce(self:GetVelocity() * 3)
	ent:DispatchTraceAttack(dmginfo, tr)
end