EFFECT.mat = Material("sprites/serioussam/FlameThrower02")
local exists = file.Exists("materials/sprites/serioussam/FlameThrower02.vmt", "GAME")

function EFFECT:Init(data)
	self.Time = 0
	self.Position = data:GetOrigin()
	self.Normal = data:GetNormal()
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()
	self.HitPos = data:GetStart()
	self.Size = 16
	self.Alpha = 80
	self.Angles = data:GetAngles()
	self.Pos = self:GetTracerShootPos(self.Position, self.WeaponEnt, self.Attachment)
	self:SetRenderBoundsWS(self.Pos, self.HitPos)
end

function EFFECT:Think()
	local frametime = FrameTime()
	self.Time = self.Time + frametime
	self.Size = self.Size + frametime*200
	local up = self.Normal:Angle():Up()*frametime*self.Size/1.85
	self.Pos = self.Pos + self.Normal*frametime*600 +up
	self.Alpha = self.Alpha - frametime*80

	return self.Time < 1
end

function EFFECT:Render()
	if self.HitPos and self.Pos:DistToSqr(self.HitPos) <= 1000 then
		local frametime = FrameTime()
		self.Pos = self.HitPos + self.Normal + self.Normal:Angle():Up() * frametime * self.Size / 1.85
	end

	local col = math.Clamp(self.Alpha, 0, 80)
	render.SetMaterial(self.mat)
	if exists then
		self.mat:SetInt("$frame", math.Clamp(math.floor(self.Time*17.5),0,15))
	end
	local eyevec = -EyeVector()
	render.DrawQuadEasy(self.Pos, eyevec, self.Size, self.Size, Color(255, 255, 255, col), self.Angles[1])
	render.DrawQuadEasy(self.Pos, eyevec, self.Size, self.Size, Color(255, 255, 255, col), self.Angles[2] + ( CurTime() * 50 ) % 360)
	render.DrawQuadEasy(self.Pos, eyevec, self.Size, self.Size, Color(255, 255, 255, col), self.Angles[3] + ( CurTime() * -50 ) % 360)
	
	if !cvars.Bool("ss_firelight") then return end
	local dynlight = DynamicLight(self:EntIndex())
		dynlight.Pos = self.Pos
		dynlight.Size = 64
		dynlight.Decay = 128
		dynlight.R = 255
		dynlight.G = 80
		dynlight.B = 0
		dynlight.Brightness = 5
		dynlight.DieTime = CurTime()+.05
end