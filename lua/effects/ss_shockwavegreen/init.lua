function EFFECT:Init(data)
	self:SetAngles(data:GetAngles() + Angle(90,0,0))
	self:SetModel("models/effects/serioussam/shockwavegreen.mdl")
	self.DieTime = 1
	self.Size = 0
	self.Scale = data:GetScale()
end

function EFFECT:Think()
	self.DieTime = self.DieTime + FrameTime()
	self.Size = self.Scale * self.DieTime^(2.5)
	if self.DieTime >= 1.4 then return false end
	
	return true
end

function EFFECT:Render()
	local col = 255 * -self.DieTime *2 +714
	self:SetModelScale(self.Size, 0)
	self:SetColor(Color(col,col,col))
	self:DrawModel()
end