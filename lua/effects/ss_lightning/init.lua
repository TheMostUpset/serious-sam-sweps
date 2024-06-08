EFFECT.mat = Material("sprites/serioussam/ray")

function EFFECT:Init(data)
	self.Position = data:GetOrigin()
	self.WeaponEnt = data:GetEntity()
	self.WeaponOwner = IsValid(self.WeaponEnt) and self.WeaponEnt:GetOwner() or NULL
	self.Attachment = data:GetAttachment()
	
	self.DieTime = .4
	self.Segments = 8
	self.BeamSize = math.Rand(7, 10)
	
	self.randTable = {}
	for i = 1, self.Segments do
		table.insert(self.randTable, VectorRand()*6)
	end	
	
	self:SetRenderBoundsWS(self.Position, data:GetStart())
end

function EFFECT:Think()
	self.DieTime = self.DieTime - FrameTime()
	return self.DieTime > 0 and IsValid(self.WeaponEnt) and self.WeaponEnt:GetAttack()
end

function EFFECT:Render()
	local pos = self:GetTracerShootPos(self.Position, self.WeaponEnt, self.Attachment)
	if !IsValid(self.WeaponEnt) or !IsValid(self.WeaponOwner) or !pos then return end
	local Normal = self.WeaponOwner:GetAimVector()
	local tr = util.TraceLine({
		start = pos,
		endpos = pos + Normal,
		filter = self.WeaponOwner
	})
	local col = math.Clamp(self.DieTime * 2.5 * 255, 0, 255)
	render.SetMaterial(self.mat)
	for i = 1, self.Segments do
		tr = util.TraceLine({
			start = tr.HitPos,
			endpos = tr.StartPos + Normal * i * 73 + self.randTable[i],
			filter = self.WeaponOwner
		})
		render.DrawBeam(tr.StartPos, tr.HitPos, self.BeamSize, 0, 1, Color(255, 255, 255, col))
	end
end