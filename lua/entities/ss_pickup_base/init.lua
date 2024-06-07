AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

util.AddNetworkString("SSPickupText")

ENT.SpawnHeight = 35
ENT.RespawnTime = 10
ENT.ResizeModel = true
ENT.TriggerBounds = 32

function ENT:SpawnFunction(ply, tr)
	if (!tr.Hit) then return end
	local ent = ents.Create(self.ClassName)
	local SpawnPos = tr.HitPos + tr.HitNormal * ent.SpawnHeight
	ent:SetPos(SpawnPos)
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Initialize()
	self:SetModel(self.model)
	if self.ResizeModel then
		self:SetModelScale(2, 0)
	end
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)
	self:SetAngles(Angle(0,90,0))
	self:DrawShadow(true)
	self.Available = true
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:SetTrigger(true)
	self:UseTriggerBounds(true, self.TriggerBounds)
	self:EmitSound("misc/serioussam/teleport.wav")
end

function ENT:Think()
	if self.ReEnabled and CurTime() >= self.ReEnabled then
		self.ReEnabled = nil
		self.Available = true
		self:SetNoDraw(false)
	end
end

function ENT:Touch(ent)
	if IsValid(ent) and ent:IsPlayer() and ent:Alive() and self.Available then
		if game.SinglePlayer() then
			self:Remove()
		else
			self.Available = false
			self:SetNoDraw(true)
			self.ReEnabled = CurTime() + self.RespawnTime
		end
		ent:EmitSound("items/serioussam/Weapon.wav", 85)
		if ent:HasWeapon(self.WeapName) then
			local wep = ent:GetWeapon(self.WeapName) 
			local ammoType = wep.Primary.Ammo
			if ammoType != "none" then
				local ammoGive = wep.Primary.DefaultClip
				local ammoCount = ent:GetAmmoCount(ammoType)
				if ammoCount < self.MaxAmmo then
					ent:SetAmmo(math.min(ammoCount + ammoGive, self.MaxAmmo), ammoType)
				end
			end
		end
		self:Special(ent)
		ent:Give(self.WeapName)
		self:SendPickupMsg(ent)
	end
end

function ENT:Special(ent)
end

function ENT:SendPickupMsg(ply, msg, amount)
	msg = msg or self.PrintName
	amount = amount or 0
	net.Start("SSPickupText")
	net.WriteString(msg)
	net.WriteUInt(amount, 8)
	net.Send(ply)
end