AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.WeapName = "weapon_ss_colt"
ENT.model = "models/weapons/serioussam/w_colt.mdl"

function ENT:Special(ent)
	if ent:HasWeapon(self.WeapName) then
		local dual = "weapon_ss_colt_dual"
		ent:Give(dual)
		local actwep = ent:GetActiveWeapon()
		if IsValid(actwep) and actwep:GetClass() == self.WeapName then
			ent:SelectWeapon(dual)
		end
	end
end