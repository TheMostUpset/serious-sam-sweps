function EFFECT:Init(data)
	self:SetAngles(data:GetAngles() + Angle(90,0,0))
	self:SetModel("models/effects/serioussam/shockwavegreen.mdl")
	self.DieTime = 1
	self.Size = 0
	self.Scale = data:GetScale()
	
	-- if !cvars.Bool("ss_firelight") then return end
	-- local dynlight = DynamicLight(self:EntIndex())
		-- dynlight.Pos = data:GetOrigin()
		-- dynlight.Size = 32
		-- dynlight.Decay = 100
		-- dynlight.R = 40
		-- dynlight.G = 255
		-- dynlight.B = 50
		-- dynlight.Brightness = 1
		-- dynlight.DieTime = CurTime() + .5
end

function EFFECT:Think()
	self.DieTime = self.DieTime + FrameTime()
	self.Size = self.Scale * self.DieTime^(2.5)
	
	return self.DieTime < 1.4
end

function EFFECT:Render()
	local col = 255 * -self.DieTime *2 +714
	local scale = math.max(self.Size, .000001)
	self:SetModelScale(scale, 0)
	self:SetColor(Color(col,col,col))
	self:DrawModel()
end