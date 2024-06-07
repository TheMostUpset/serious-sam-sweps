
function EFFECT:Init(data)	
	if !cvars.Bool("ss_firelight") then return end
	local dynlight = DynamicLight(self:EntIndex())
		dynlight.Pos = data:GetOrigin()
		dynlight.Size = 200
		dynlight.Decay = 2000
		dynlight.R = 80
		dynlight.G = 140
		dynlight.B = 255
		dynlight.Brightness = 8
		dynlight.DieTime = CurTime()+.05
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end