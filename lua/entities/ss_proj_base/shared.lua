ENT.Type			= "anim"
ENT.PrintName		= "Serious Sam Projectile Base"
ENT.Author			= "Upset"
ENT.Spawnable		= false

function ENT:IsCreature(ent)
	return ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot()
end