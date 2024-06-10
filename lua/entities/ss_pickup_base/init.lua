AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

util.AddNetworkString("SSPickupText")

ENT.SpawnHeight = 35
ENT.RespawnTime = 10
ENT.ResizeModel = true
ENT.TriggerBounds = 32

function ENT:SpawnFunction(ply, tr)
	if !tr.Hit then return end
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
	if self:GetDropped() then
		SafeRemoveEntityDelayed(self, 30)
	else
		self:EmitSound("misc/serioussam/teleport.wav")
	end
end

function ENT:Think()
	if self.ReEnabled and CurTime() >= self.ReEnabled then
		self.ReEnabled = nil
		self.Available = true
		self:SetNoDraw(false)
	end
	
	if self:GetDropped() then
		local tr = util.TraceHull({
			start = self:GetPos(),
			endpos = self:GetPos() - Vector(0,0,50),
			filter = self,
			mins = Vector(-16, -16, -32),
			maxs = Vector(16, 16, 16)
		})
		if self:GetPos() != tr.HitPos then
			self:SetPos(tr.HitPos)
			self:NextThink(CurTime() + .1)
			return true
		end
	end
end

function ENT:Touch(ent)
	if IsValid(ent) and ent:IsPlayer() and ent:Alive() and self.Available then
		if game.SinglePlayer() or self:GetDropped() then
			self:Remove()
		else
			self.Available = false
			self:SetNoDraw(true)
			self.ReEnabled = CurTime() + self.RespawnTime
		end
		ent:EmitSound("items/serioussam/Weapon.wav", 85)
		self:Special(ent)
		if ent:HasWeapon(self.WeapName) then
			local wep = ent:GetWeapon(self.WeapName)
			local ammoGive = self.AmmoToGive or wep.Primary.DefaultClip
			self:GiveAmmo(ent, wep.Primary.Ammo, ammoGive)
		else
			if self.AmmoToGive then
				local wep = ent:Give(self.WeapName, true) -- giving without ammo
				if IsValid(wep) then
					self:GiveAmmo(ent, wep.Primary.Ammo, self.AmmoToGive) -- giving our own ammo value
				end
			else
				ent:Give(self.WeapName) -- giving with default ammo
			end
		end
		self:SendPickupMsg(ent)
	end
end

function ENT:GiveAmmo(ply, ammoType, ammoGive)
	if ammoType != "none" then
		local ammoCount = ply:GetAmmoCount(ammoType)
		if ammoCount < self.MaxAmmo then
			ply:SetAmmo(math.min(ammoCount + ammoGive, self.MaxAmmo), ammoType)
		end
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