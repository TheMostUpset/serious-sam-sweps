EFFECT.mat = Material("sprites/serioussam/explosionparticles")
local exists = file.Exists("materials/sprites/serioussam/explosionparticles.vmt", "GAME")

function EFFECT:Init(data)
	self.Pos = data:GetOrigin()
	self.Normal = data:GetNormal()
	self.time = CurTime()+1
	self.DieTime = 1.05
	self.Size = 512
	self.Rotate = math.random(0, 180)
end

function EFFECT:Think()
	self.DieTime = self.DieTime - FrameTime()
	if self.DieTime <= 0 then return false end	
	return true
end

function EFFECT:Render()
	render.SetMaterial(self.mat)
	if exists then
		self.mat:SetInt("$frame", math.Clamp(math.floor(22-(self.time-CurTime())*22),0,22))
	end
	render.DrawQuadEasy(self.Pos, -self.Normal, self.Size, self.Size, Color(255,255,255,255), self.Rotate)
end