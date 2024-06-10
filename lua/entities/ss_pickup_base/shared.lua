ENT.Type = "anim"
ENT.PrintName = "Pickup Base"
ENT.Category = "Serious Sam"
ENT.Author = "Upset"
ENT.Spawnable = false

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Dropped")
end