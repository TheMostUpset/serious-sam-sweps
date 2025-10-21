AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:SetExplodeDelay(flDelay)
	self.delayExplode = CurTime() + flDelay
end

function ENT:SetDamage(dmgDirect, dmgSplash)
	self.DamageDirect, self.DamageSplash = dmgDirect, dmgSplash
end

function ENT:DoDirectDamage(ent, dmg, owner)
	if !IsValid(ent) or ent:IsWorld() or !IsValid(owner) then return end
	local dmginfo = DamageInfo()
	dmginfo:SetInflictor(self)
	dmginfo:SetAttacker(owner)
	dmginfo:SetDamage(dmg)
	dmginfo:SetDamageForce(self:GetForward())
	dmginfo:SetDamagePosition(self:GetPos())
	dmginfo:SetDamageType(bit.bor(DMG_BLAST, DMG_AIRBOAT))
	ent:TakeDamageInfo(dmginfo)
end

function ENT:DoSplashDamage(pos, dmg, owner)
	if !IsValid(owner) then return end
	local dmginfo = DamageInfo()
	dmginfo:SetInflictor(self)
	dmginfo:SetAttacker(owner)
	dmginfo:SetDamage(dmg)
	dmginfo:SetDamageType(bit.bor(DMG_BLAST, DMG_AIRBOAT))
	util.BlastDamageInfo(dmginfo, pos, 256)
end

function ENT:ExplosionEffects(pos, ang)
	local effectdata = EffectData()
	effectdata:SetAngles(ang)
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