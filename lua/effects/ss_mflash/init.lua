EFFECT.mat = Material("sprites/serioussam/flare")

function EFFECT:GetMuzzleFlashPos(Position, Ent, Attachment, modelindex)

	modelindex = modelindex or 0
	
	if !IsValid(Ent) then return Position end
	if !Ent:IsWeapon() then return Position end

	-- Shoot from the viewmodel
	if Ent:IsCarriedByLocalPlayer() && !LocalPlayer():ShouldDrawLocalPlayer() && !Ent:GetZoom() then
	
		local ViewModel = LocalPlayer():GetViewModel(modelindex)
		
		if IsValid(ViewModel) then
			
			local att = ViewModel:GetAttachment(Attachment)
			if att then
				Position = att.Pos
			end
			
		end
	
	-- Shoot from the world model
	else
	
		if modelindex == 1 and IsValid(Ent.LeftModel) then
			Ent = Ent.LeftModel
		end
		local att = Ent:GetAttachment(Attachment)
		if att then
			Position = att.Pos
		end
	
	end

	return Position

end

function EFFECT:Init(data)
	self.Position = data:GetOrigin()
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()
	self.ModelIndex = data:GetSurfaceProp()
	
	self.DieTime = FrameTime() + math.Rand(.01, .02)
	self.Size = data:GetScale()
	self.Rotate = math.Rand(0, 180)
	
	local lightpos = self:GetMuzzleFlashPos(self.Position, self.WeaponEnt, self.Attachment, self.ModelIndex)
	if !cvars.Bool("ss_firelight") then return end
	local dynlight = DynamicLight(self:EntIndex())
		dynlight.Pos = lightpos
		dynlight.Size = 64
		dynlight.Decay = 768
		dynlight.R = 80
		dynlight.G = 80
		dynlight.B = 60
		dynlight.Brightness = 8
		dynlight.DieTime = CurTime()+.05
end

function EFFECT:Think()
	self.DieTime = self.DieTime - FrameTime()
	self.Size = self.Size + self.DieTime * 40
	return self.DieTime > 0	
end

function EFFECT:Render()
	local Muzzle = self:GetMuzzleFlashPos(self.Position, self.WeaponEnt, self.Attachment, self.ModelIndex)
	if !self.WeaponEnt or !IsValid(self.WeaponEnt) or !Muzzle then return end
	render.SetMaterial(self.mat)
	render.DrawQuadEasy(Muzzle, -EyeVector(), self.Size, self.Size, Color(255, 255, 255, 255), self.Rotate)
	self:SetRenderBoundsWS(Muzzle, self.Position)
end