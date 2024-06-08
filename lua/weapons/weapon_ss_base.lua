
if SERVER then

	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
	CreateConVar("ss_ammomultiplier", 3, FCVAR_ARCHIVE, "Multiplier for additional ammo on weapon pickup\n Any positive number, 0 - disabled")
	CreateConVar("ss_enableholsterdelay", 1, FCVAR_ARCHIVE)

else

	SWEP.DrawAmmo			= true
	SWEP.DrawCrosshair		= false
	SWEP.ViewModelFlip		= false
	SWEP.ViewModelFOV		= 60
	SWEP.BobScale			= 0
	SWEP.SwayScale			= .1
	CreateClientConVar("ss_firelight", 1)

end

local cvar_unlimitedammo = CreateConVar("ss_unlimitedammo", 0, {FCVAR_NOTIFY, FCVAR_REPLICATED}, "Unlimited ammo for Serious Sam weapons", 0, 1)

game.AddAmmoType({
	name = "cannonball"
})
game.AddAmmoType({
	name = "napalm"
})

SWEP.Author					= "Upset"
SWEP.Contact				= ""
SWEP.Purpose				= ""
SWEP.Instructions			= ""
SWEP.Category				= "Serious Sam"
SWEP.Spawnable				= false

SWEP.Primary.Damage			= 10
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"
SWEP.Secondary.Ammo			= "none"

SWEP.AmmoToTake				= 1

SWEP.MuzzleScale			= 14
SWEP.EnableSmoke			= false

SWEP.DeployDelay			= 1.6

SWEP.EnableIdle				= false -- lua-based idle anim imitation (bad variable name actually)
SWEP.UseHolsterAnim			= true

SWEP.LaserPos				= false

SWEP.SBobScale				= 1

local SSAM_STATE_DEPLOY = 0
local SSAM_STATE_HOLSTER = 1
local SSAM_STATE_IDLE = 2

function SWEP:SetupDataTables()
	self:NetworkVar("Int", 0, "State")
	self:NetworkVar("Bool", 0, "Holster")
	self:NetworkVar("Bool", 1, "Attack")
	self:NetworkVar("Float", 0, "IdleDelay")
	self:NetworkVar("Float", 1, "FidgetDelay")
	self:NetworkVar("Float", 2, "AttackDelay")
	self:NetworkVar("Float", 3, "HolsterTime")
	
	self:NetworkVar("Bool", 2, "Zoom")
	
	self:SpecialDataTables()
end

function SWEP:SpecialDataTables()
end

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
	self:SetDeploySpeed(self.DeployDelay)
end

function SWEP:OnRestore()
	self.DisableHolster = nil
end

function SWEP:Equip(ply)
	if !IsValid(ply) or !ply:IsPlayer() then return end
	local cvar = "ss_ammomultiplier"
	if cvars.Bool(cvar) then
		local multiplier = math.Clamp(cvars.Number(cvar, 1), 0, 9999)
		ply:GiveAmmo(self.Primary.DefaultClip * multiplier, self.Primary.Ammo)
	end
end

function SWEP:Deploy()
	self:SetState(SSAM_STATE_DEPLOY)
	self:SendWeaponAnim(ACT_VM_DRAW)
	self:IdleStuff()
	self:HolsterDelay(CurTime())
	self:SpecialDeploy()
	self:SetHolster(nil)
	return true
end

function SWEP:SpecialDeploy()
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self:WeaponSound(self.Primary.Sound)
	self:ShootBullet(self.Primary.Damage, self.Primary.NumShots, self.Primary.Cone)
	self:SeriousFlash()
	self:TakeAmmo(self.AmmoToTake)
	self:IdleStuff()
	self:HolsterDelay()
end

function SWEP:SecondaryAttack()
end

function SWEP:WeaponSound(snd, lvl)
	snd = snd or self.Primary.Sound
	lvl = lvl or 100
	self:EmitSound(snd, lvl, 100, 1, CHAN_AUTO)
end

function SWEP:HolsterDelay(time)
	time = time or self:GetNextPrimaryFire() -.1
	self.DisableHolster = time
end

function SWEP:ResetBones()
end

function SWEP:Holster(wep)
	self:ResetBones()
	
	local disableHolster = self.DisableHolster and self.DisableHolster > CurTime()

	if !self.UseHolsterAnim or !cvars.Bool("ss_enableholsterdelay") then
		if disableHolster then
			return false
		else
			self:SetState(SSAM_STATE_HOLSTER)
			self:OnRemove()
			return true
		end
		return
	end

	if self == wep then
		return
	end
	
	if self:GetState() == SSAM_STATE_HOLSTER or !IsValid(wep) then
		self:SetState(SSAM_STATE_HOLSTER)
		self:OnRemove()
		return true
	end
	
	if self:GetHolster() then return false end
	
	if (self:GetClass() == "weapon_ss_colt" and wep:GetClass() == "weapon_ss_colt_dual") or (self:GetClass() == "weapon_ss_colt_dual" and wep:GetClass() == "weapon_ss_colt") then
		if disableHolster then return false end
		self:OnRemove()
		return true
	end
	
	if disableHolster then
		if IsValid(wep) then
			self.NewWeapon = wep:GetClass()
			timer.Simple(.05, function()
				if IsValid(self) and IsValid(self.Owner) and self.Owner:Alive() then
					if SERVER then self.Owner:SelectWeapon(self.NewWeapon) end
				end
			end)
		end
		return false
	end

	if IsValid(wep) then
		self:SetIdleDelay(0)
		self:SetHolster(true)
		self:SetNextPrimaryFire(CurTime() + .4)
		self:SendWeaponAnim(ACT_VM_HOLSTER)
		self:SpecialHolster()
		self.NewWeapon = wep:GetClass()
		self:SetHolsterTime(CurTime() + .4)
	end

	return false
end

function SWEP:SpecialHolster()
end

function SWEP:Think()
	self:SpecialThink()
	
	if self.SmokeTime and CurTime() < self.SmokeTime then
		if !self.SmokeDelay or (self.SmokeDelay and self.SmokeDelay < CurTime()) then
			self.SmokeDelay = CurTime() + .07
			self:Smoke()
		end
	end
	
	if game.SinglePlayer() and CLIENT then return end
	
	local holsterTime = self:GetHolsterTime()
	if holsterTime > 0 and holsterTime <= CurTime() then
		if IsValid(self) and IsValid(self.Owner) and self.Owner:Alive() then
			self:SetState(SSAM_STATE_HOLSTER)
			if SERVER then self.Owner:SelectWeapon(self.NewWeapon) end
		end
		self:SetHolsterTime(0)
	end
	
	if !self.EnableIdle then
		local idle = self:GetIdleDelay()
		local fidget = self:GetFidgetDelay()
		if idle > 0 and CurTime() > idle then
			self:SetIdleDelay(0)
			self:SetFidgetDelay(CurTime() + self:SequenceDuration() + math.random(10,12))
			self:SendWeaponAnim(ACT_VM_IDLE)
			self:SetState(SSAM_STATE_IDLE)
		end		
		if fidget > 0 and CurTime() > fidget then
			self:SetFidgetDelay(0)
			if self:LookupSequence("idle2") != -1 then
				self:SendWeaponAnim(ACT_VM_FIDGET)
				self:SetIdleDelay(CurTime() + self:SequenceDuration())
			end
		end
	end
	
	if !game.SinglePlayer() and self:GetHolster() then
		self:ResetBones()
	end
end

function SWEP:SpecialThink()
end

function SWEP:ShootBullet(dmg, numbul, cone)
	local bullet = {}
	bullet.Num 		= numbul
	bullet.Src 		= self.Owner:GetShootPos()
	bullet.Dir 		= self.Owner:GetAimVector()
	bullet.Spread 	= Vector(cone, cone, 0)
	bullet.Tracer	= 3
	bullet.Force	= 4
	bullet.Damage	= dmg
	self.Owner:FireBullets(bullet)
end

function SWEP:CanPrimaryAttack()
	if self:GetHolster() then return false end

	if !self.Owner:IsNPC() then
		if self.Owner:GetAmmoCount(self.Primary.Ammo) < self.AmmoToTake then
			self:SetNextPrimaryFire(CurTime() + .2)
			return false
		end
	end
	return true
end

function SWEP:SeriousFlash(modelindex)
	modelindex = modelindex or 0
	if !IsFirstTimePredicted() or !IsValid(self.Owner) then return end
	local fx = EffectData()
	fx:SetEntity(self)
	fx:SetSurfaceProp(modelindex)
	fx:SetOrigin(self.Owner:GetShootPos())
	fx:SetNormal(self.Owner:GetAimVector())
	fx:SetAttachment(1)
	fx:SetScale(self.MuzzleScale)
	util.Effect("ss_mflash", fx)
	if self.EnableSmoke then
		util.Effect("ss_mflashsmoke", fx)
	end
end

function SWEP:Smoke()
	if !IsFirstTimePredicted() then return end
	local fx = EffectData()
	fx:SetEntity(self)
	fx:SetOrigin(self.Owner:GetShootPos())
	fx:SetNormal(self.Owner:GetAimVector())
	fx:SetAttachment(1)
	util.Effect("ss_mflashsmoke", fx)
end

function SWEP:Reload()
end

function SWEP:TakeAmmo(num)
	num = num or 1
	if !cvar_unlimitedammo:GetBool() and !self.Owner:IsNPC() then
		self:TakePrimaryAmmo(num)
	end	
end

function SWEP:IdleStuff(div)
	div = div or 1
	if self.EnableIdle then return end
	self:SetFidgetDelay(0)
	self:SetIdleDelay(CurTime() + self:SequenceDuration() / div)
end

function SWEP:IsCreature(ent)
	return ent:IsNPC() or ent:IsPlayer() or ent:IsNextBot()
end

if SERVER then return end

local t = 1
local laseranim = 0

function SWEP:CalcViewModelView(vm, oldpos, oldang, pos, ang)
	if !IsValid(vm) or !IsValid(self.Owner) then return end
	local reg = debug.getregistry()
	local GetVelocity = reg.Entity.GetVelocity
	local Length = reg.Vector.Length2D
	local vel = Length(GetVelocity(self.Owner))
	local hz = math.Clamp(vel/256, 0, .4)
	local move = math.sin(CurTime() * 10.5)
	local moveright = move *hz
	local moveup = move *moveright /2
	local bobscale = self.SBobScale
	
	if (!game.SinglePlayer() and IsFirstTimePredicted()) or game.SinglePlayer() then
		if self.Owner:IsOnGround() then
			t = Lerp(FrameTime()*16, t, 1)
		else
			t = math.max(Lerp(FrameTime()*7, t, 0.01), 0)
		end
	end

	local modelindex = vm:ViewModelIndex()
	if modelindex == 0 then
		pos = pos + moveright *bobscale * ang:Right() *t
	else
		pos = pos - moveright *bobscale * ang:Right() *t
	end	
	pos = pos + moveup *bobscale * ang:Up() *t
	
	if self.EnableIdle then
		pos = pos + math.sin(CurTime() * 1.3) * ang:Up() /26
	end
	
	if self.LaserPos then
		local firetime = CurTime() - self:GetNextPrimaryFire()
		local seq = self:GetSequence()
		if !game.SinglePlayer() and IsFirstTimePredicted() or game.SinglePlayer() then
			if firetime <= FrameTime() - .09 and self:Ammo1() > 0 and (seq == 0 or seq == 1 or seq == 2 or seq == 3) then
				laseranim = math.Approach(laseranim, .75, FrameTime() * 60)
			end
			laseranim = Lerp(FrameTime() * 20, laseranim, .0001)
		end
		pos = pos - laseranim * ang:Forward()
		ang:RotateAroundAxis(ang:Right(), 4.5)
	end
	
	if self:GetZoom() then
		pos = pos + ang:Up() * 20
	end

	return pos, ang
end

function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
	surface.SetDrawColor(255, 255, 255, 245)
	surface.SetTexture(surface.GetTextureID(self.WepIcon))

	y = y - 20
	x = x + 15
	wide = wide - 32

	surface.DrawTexturedRect(x, y, wide, wide)
end

function SWEP:DrawHUD()
	self:Crosshair()
end

local cvar_crosshair = CreateClientConVar("ss_crosshair", 1)
function SWEP:Crosshair()
	local x, y = ScrW() / 2, ScrH() / 2
	local tr = self.Owner:GetEyeTraceNoCursor()
	
	if (self.Owner == LocalPlayer() && self.Owner:ShouldDrawLocalPlayer()) then
		local coords = tr.HitPos:ToScreen()
		x, y = coords.x, coords.y
	end

	local dist = math.Round(-self.Owner:GetPos():Distance(self.Owner:GetEyeTraceNoCursor().HitPos) /12) +64
	dist = math.Clamp(dist, 32, 128)

	local getcvar = cvar_crosshair:GetInt()
	if getcvar <= 0 or getcvar > 7 then return end
	
	local colr, colg, colb = 255, 255, 255
	-- NPC health won't update in singleplayer if ai_disabled is 1
	if tr.Hit and self:IsCreature(tr.Entity) and tr.Entity:Health() > 0 then
		local maxhealth, health = tr.Entity:GetMaxHealth(), tr.Entity:Health()
		if health <= maxhealth / 4 then
			colr, colg, colb = 255, 0, 0
		elseif health <= maxhealth / 2 then
			colr, colg, colb = 255, 255, 0
		else
			colr, colg, colb = 0, 255, 0
		end
	end
	
	surface.SetTexture(surface.GetTextureID("vgui/serioussam/Crosshair"..getcvar))
	surface.SetDrawColor(colr, colg, colb, 255)
	surface.DrawTexturedRect(x - dist /2 -1, y - dist /2 +1, dist, dist)
end