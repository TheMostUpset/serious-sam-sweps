EFFECT.mat = Material("sprites/serioussam/explosionrocket")
local exists = file.Exists("materials/sprites/serioussam/explosionrocket.vmt", "GAME")

function EFFECT:Init(data)
	self.Pos = data:GetOrigin()
	self.Normal = data:GetNormal()
	self.time = CurTime()+1
	self.DieTime = .9
	self.Size = 256
	self.Rotate = math.random(0, 180)
end

function EFFECT:Think()
	self.DieTime = self.DieTime - FrameTime()
	return self.DieTime > 0
end

function EFFECT:Render()
	render.SetMaterial(self.mat)
	if exists then
		self.mat:SetInt("$frame", math.Clamp(math.floor(14-(self.time-CurTime())*14),0,11))
	end
	render.DrawQuadEasy(self.Pos, -self.Normal, self.Size, self.Size, Color(255,255,255,255), self.Rotate)
end