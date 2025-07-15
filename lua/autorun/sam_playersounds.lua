SeriousPlayerSounds = {}

local cvar_plysounds = CreateConVar("ss_playersounds", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED})

SeriousPlayerSounds.ModelTable = {
	["models/pechenko_121/samclassic.mdl"] = true,
	["models/pechenko_121/beheadedben.mdl"] = true,
	["models/pechenko_121/redrick.mdl"] = true,
	["models/pechenko_121/steelsteve.mdl"] = true,
	["models/pechenko_121/dancingden.mdl"] = true,
	["models/pechenko_121/hillyharry.mdl"] = true,
	["models/pechenko_121/kleerkurt.mdl"] = true,
	["models/pechenko_121/samclassic_mental.mdl"] = true,
	["models/pechenko_121/samclassic_pirate.mdl"] = true,
	["models/pechenko_121/samclassic_santa.mdl"] = true,
	["models/pechenko_121/samclassic_tfe.mdl"] = true,
	["models/pechenko_121/skinlessstan.mdl"] = true,
	["models/pechenko_121/boxerbarry.mdl"] = true,
	["models/pechenko_121/mightymarvin.mdl"] = true,
	["models/pechenko_121/fastfingerfreddy.mdl"] = true,
	["models/pechenko_121/rockingryan.mdl"] = true
}

function SeriousPlayerSounds:IsEnabled()
	return cvar_plysounds:GetBool()
end

function SeriousPlayerSounds:PlayerUsesModel(ply)
	return SeriousPlayerSounds.ModelTable[ply:GetModel()]
end

hook.Add("OnPlayerJump", "SeriousPlayerSounds_Jump", function(ply)
	if !SeriousPlayerSounds:IsEnabled() then return end
	if SeriousPlayerSounds:PlayerUsesModel(ply) then
		local filter = nil
		if SERVER and !game.SinglePlayer() then
			filter = RecipientFilter()
			filter:AddAllPlayers()
			filter:RemovePlayer(ply)
		end
		if !ply.SSJumpSoundDelay or ply.SSJumpSoundDelay <= CurTime() then
			ply:EmitSound("player/serioussam/Jump.wav", 80, 100, nil, nil, nil, nil, filter)
			ply.SSJumpSoundDelay = CurTime() + .2
		end
	end
end)

if CLIENT then return end

hook.Add("PlayerHurt", "SeriousPlayerSounds_Hurt", function(ply, at, h, dmg)	
	if !SeriousPlayerSounds:IsEnabled() then return end
	if SeriousPlayerSounds:PlayerUsesModel(ply) and ply:Health() > 0 then
		if !ply.SSHurtSoundDelay or ply.SSHurtSoundDelay <= CurTime() then
			local pitch = math.random(92,112)
			if ply:WaterLevel() == 3 then
				ply:EmitSound("player/serioussam/WoundWater.wav", 80, pitch)
			elseif dmg > 30 then
				ply:EmitSound("player/serioussam/WoundStrong.wav", 80, pitch)
			elseif dmg >= 15 then
				ply:EmitSound("player/serioussam/WoundMedium.wav", 80, pitch)
			elseif dmg < 15 then
				ply:EmitSound("player/serioussam/WoundWeak.wav", 80, pitch)
			end
			ply.SSHurtSoundDelay = CurTime() + 0.45
		end
	end
end)

hook.Add("PlayerDeath", "SeriousPlayerSounds_Death", function(ply)
	if !SeriousPlayerSounds:IsEnabled() then return end
	if SeriousPlayerSounds:PlayerUsesModel(ply) then
		if ply:WaterLevel() == 3 then
			ply:EmitSound("player/serioussam/DeathWater.wav", 70, 100)
		elseif ply:WaterLevel() < 3 then
			ply:EmitSound("player/serioussam/Death.wav", 80, 100)
		end
	end
end)