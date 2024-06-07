function EFFECT:Init(data)
	self.Position = data:GetOrigin()
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()

	local smokepos = self:GetTracerShootPos(self.Position, self.WeaponEnt, self.Attachment)
	local emitter = ParticleEmitter(smokepos)
		
	local particle = emitter:Add("particle/particle_smokegrenade", smokepos)
		particle:SetVelocity(512 * data:GetNormal())
		particle:SetAirResistance(256)
		particle:SetGravity(Vector(0, 0, math.Rand(300, 500)))
		particle:SetDieTime(math.Rand(0.8, 1.0))
		particle:SetStartAlpha(math.Rand(120, 150))
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(2, 5))
		particle:SetEndSize(math.Rand(30, 40))
		particle:SetRoll(math.Rand(-25, 25))
		particle:SetRollDelta(math.Rand(-1, 1))
		particle:SetColor(255, 255, 255)

	emitter:Finish()
	
	self:SetRenderBoundsWS(smokepos, self.Position)
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end