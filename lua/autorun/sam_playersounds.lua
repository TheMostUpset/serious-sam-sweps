local cvar_plysounds = CreateConVar("ss_playersounds", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED})

local sam_models = {
	["models/pechenko_121/samclassic.mdl"] = true,
	["models/pechenko_121/beheadedben.mdl"] = true,
	["models/pechenko_121/redrick.mdl"] = true,
	["models/pechenko_121/steelsteve.mdl"] = true
}

local function IsPlayerSoundsEnabled()
	return cvar_plysounds:GetBool()
end

local function PlayerHasSeriousSamModel(ply)
	return sam_models[ply:GetModel()]
end

hook.Add("OnPlayerJump", "SeriousSamJumpSound", function(ply)
	if !IsPlayerSoundsEnabled() then return end
	if PlayerHasSeriousSamModel(ply) then
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

hook.Add("PlayerHurt", "samplayerhurt", function(ply, at, h, dmg)	
	if !IsPlayerSoundsEnabled() then return end
	if PlayerHasSeriousSamModel(ply) and ply:Health() > 0 then
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

hook.Add("PlayerDeath", "samdeath", function(ply)
	if !IsPlayerSoundsEnabled() then return end
	if PlayerHasSeriousSamModel(ply) then
		if ply:WaterLevel() == 3 then
			ply:EmitSound("player/serioussam/DeathWater.wav", 70, 100)
		elseif ply:WaterLevel() < 3 then
			ply:EmitSound("player/serioussam/Death.wav", 80, 100)
		end
	end
end)