include('shared.lua')

function ENT:Initialize()
	self.OriginPos = self:GetPos()
	self.RotateTime = RealTime()
end

local flare = Material("sprites/glow04_noz")

function ENT:Draw()
	if !self:GetDropped() then
		self:SetRenderOrigin(self.OriginPos + Vector(0,0,math.sin(RealTime() * 6) *3.5))
	end
	self:SetupBones()
	self:DrawModel()
	local Rotate = (RealTime() - self.RotateTime)*180 %360
	self:SetAngles(Angle(0,Rotate,0))
	
	if game.SinglePlayer() then
		local dist = LocalPlayer():GetPos():Distance(self.OriginPos) / 8
		local size = math.Clamp(dist, 32, 128)
		local alpha = math.Clamp((dist - 80), 0, 50)
		if alpha > 0 then
			render.SetMaterial(flare)
			render.DrawSprite(self:GetPos() - EyeVector() * 20, size, size, Color(255, 255, 255, alpha))
		end
	end
end