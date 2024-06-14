
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
local cvar_dmrules = CreateConVar("ss_sv_dmrules", 0, {FCVAR_NOTIFY, FCVAR_REPLICATED}, "Deathmatch rules for Serious Sam weapons (damage values, fire rate, etc)", 0, 1)

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

function SWEP:IsDeathmatchRules()
	return cvar_dmrules:GetBool()
end

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
	self:SetDeploySpeed(self.DeployDelay)
end

function SWEP:OnRestore()
	self.DisableHolster = nil
end

function SWEP:Equip(ply)
	if self:IsDeathmatchRules() or !IsValid(ply) or !ply:IsPlayer() then return end
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
	local delay, cone = self.Primary.Delay, self.Primary.Cone
	if self:IsDeathmatchRules() then
		if self.Primary.DelayDM then delay = self.Primary.DelayDM end
		if self.Primary.ConeDM then cone = self.Primary.ConeDM end
	end
	self:SetNextPrimaryFire(CurTime() + delay)
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	if self.Primary.AnimSpeed then self.Owner:GetViewModel():SetPlaybackRate(1 * self.Primary.AnimSpeed) end
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self:WeaponSound(self.Primary.Sound)
	self:ShootBullet(self.Primary.Damage, self.Primary.NumShots, cone)
	self:SeriousFlash()
	self:TakeAmmo(self.AmmoToTake)
	self:IdleStuff()
	self:HolsterDelay()
	if self.EnableEndSmoke then
		self.SmokeAmount = self.SmokeAmount + 1
	end
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

function SWEP:OnRemove()
	if self.EnableEndSmoke then
		self.SmokeAmount = 0
	end
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
	
	if self.EnableEndSmoke then
		self:EndSmokeThink()
	end
	
	if !game.SinglePlayer() and self:GetHolster() then
		self:ResetBones()
	end
end

function SWEP:SpecialThink()
end

function SWEP:EndSmokeThink()
	if self.Owner:KeyReleased(IN_ATTACK) or self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0 then
		if self.SmokeAmount > 0 then
			local num = game.SinglePlayer() and 90 or 200
			self.SmokeTime = CurTime() + math.min(self.SmokeAmount/num, 1.5)
			self.SmokeAmount = 0
		end
	end
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

function SWEP:SetupWeaponHoldTypeForAI(t)
	self.ActivityTranslateAI[ACT_IDLE] 							= ACT_IDLE_PISTOL
	self.ActivityTranslateAI[ACT_IDLE_ANGRY] 					= ACT_IDLE_ANGRY_PISTOL
	self.ActivityTranslateAI[ACT_RANGE_ATTACK1] 				= ACT_RANGE_ATTACK_PISTOL
	self.ActivityTranslateAI[ACT_RELOAD] 						= ACT_RELOAD_PISTOL
	self.ActivityTranslateAI[ACT_WALK_AIM] 						= ACT_WALK_AIM_PISTOL
	self.ActivityTranslateAI[ACT_RUN_AIM] 						= ACT_RUN_AIM_PISTOL
	self.ActivityTranslateAI[ACT_GESTURE_RANGE_ATTACK1] 		= ACT_GESTURE_RANGE_ATTACK_PISTOL
	self.ActivityTranslateAI[ACT_RELOAD_LOW] 					= ACT_RELOAD_PISTOL_LOW
	self.ActivityTranslateAI[ACT_RANGE_ATTACK1_LOW] 			= ACT_RANGE_ATTACK_PISTOL_LOW
	self.ActivityTranslateAI[ACT_COVER_LOW] 					= ACT_COVER_PISTOL_LOW
	self.ActivityTranslateAI[ACT_RANGE_AIM_LOW] 				= ACT_RANGE_AIM_PISTOL_LOW
	self.ActivityTranslateAI[ACT_GESTURE_RELOAD] 				= ACT_GESTURE_RELOAD_PISTOL
	if t == "smg" or t == "ar2" or t == "crossbow" or self:GetClass() == "weapon_ss_flamer" then
		self.ActivityTranslateAI[ACT_RANGE_ATTACK1] 				= ACT_RANGE_ATTACK_SMG1
		self.ActivityTranslateAI[ACT_RELOAD] 						= ACT_RELOAD_SMG1
		self.ActivityTranslateAI[ACT_IDLE] 							= ACT_IDLE_SMG1
		self.ActivityTranslateAI[ACT_IDLE_ANGRY] 					= ACT_IDLE_ANGRY_SMG1
		self.ActivityTranslateAI[ACT_WALK] 							= ACT_WALK_RIFLE
		
		self.ActivityTranslateAI[ACT_IDLE_RELAXED] 					= ACT_IDLE_SMG1_RELAXED
		self.ActivityTranslateAI[ACT_IDLE_STIMULATED] 				= ACT_IDLE_SMG1_STIMULATED
		self.ActivityTranslateAI[ACT_IDLE_AGITATED] 				= ACT_IDLE_ANGRY_SMG1
		
		self.ActivityTranslateAI[ACT_WALK_RELAXED] 					= ACT_WALK_RIFLE_RELAXED
		self.ActivityTranslateAI[ACT_WALK_STIMULATED] 				= ACT_WALK_RIFLE_STIMULATED
		self.ActivityTranslateAI[ACT_WALK_AGITATED] 				= ACT_WALK_AIM_RIFLE
		
		self.ActivityTranslateAI[ACT_RUN_RELAXED] 					= ACT_RUN_RIFLE_RELAXED
		self.ActivityTranslateAI[ACT_RUN_STIMULATED] 				= ACT_RUN_RIFLE_STIMULATED
		self.ActivityTranslateAI[ACT_RUN_AGITATED] 					= ACT_RUN_AIM_RIFLE
		
		self.ActivityTranslateAI[ACT_IDLE_AIM_RELAXED] 				= ACT_IDLE_SMG1_RELAXED
		self.ActivityTranslateAI[ACT_IDLE_AIM_STIMULATED] 			= ACT_IDLE_AIM_RIFLE_STIMULATED
		self.ActivityTranslateAI[ACT_IDLE_AIM_AGITATED] 			= ACT_IDLE_ANGRY_SMG1
		
		self.ActivityTranslateAI[ACT_WALK_AIM_RELAXED] 				= ACT_WALK_RIFLE_RELAXED
		self.ActivityTranslateAI[ACT_WALK_AIM_STIMULATED] 			= ACT_WALK_AIM_RIFLE_STIMULATED
		self.ActivityTranslateAI[ACT_WALK_AIM_AGITATED] 			= ACT_WALK_AIM_RIFLE
		
		self.ActivityTranslateAI[ACT_RUN_AIM_RELAXED] 				= ACT_RUN_RIFLE_RELAXED
		self.ActivityTranslateAI[ACT_RUN_AIM_STIMULATED] 			= ACT_RUN_AIM_RIFLE_STIMULATED
		self.ActivityTranslateAI[ACT_RUN_AIM_AGITATED] 				= ACT_RUN_AIM_RIFLE
		
		self.ActivityTranslateAI[ACT_WALK_AIM] 						= ACT_WALK_AIM_RIFLE
		self.ActivityTranslateAI[ACT_WALK_CROUCH] 					= ACT_WALK_CROUCH_RIFLE
		self.ActivityTranslateAI[ACT_WALK_CROUCH_AIM] 				= ACT_WALK_CROUCH_AIM_RIFLE
		self.ActivityTranslateAI[ACT_RUN] 							= ACT_RUN_RIFLE
		self.ActivityTranslateAI[ACT_RUN_AIM] 						= ACT_RUN_AIM_RIFLE
		self.ActivityTranslateAI[ACT_RUN_CROUCH] 					= ACT_RUN_CROUCH_RIFLE
		self.ActivityTranslateAI[ACT_RUN_CROUCH_AIM] 				= ACT_RUN_CROUCH_AIM_RIFLE
		self.ActivityTranslateAI[ACT_GESTURE_RANGE_ATTACK1] 		= ACT_GESTURE_RANGE_ATTACK_SMG1
		self.ActivityTranslateAI[ACT_COVER_LOW] 					= ACT_COVER_SMG1_LOW
		self.ActivityTranslateAI[ACT_RANGE_AIM_LOW] 				= ACT_RANGE_AIM_SMG1_LOW
		self.ActivityTranslateAI[ACT_RANGE_ATTACK1_LOW] 			= ACT_RANGE_ATTACK_SMG1_LOW
		self.ActivityTranslateAI[ACT_RELOAD_LOW] 					= ACT_RELOAD_SMG1_LOW
		self.ActivityTranslateAI[ACT_GESTURE_RELOAD] 				= ACT_GESTURE_RELOAD_SMG1		
	elseif t == "shotgun" then
		self.ActivityTranslateAI[ACT_RANGE_ATTACK1] 				= ACT_RANGE_ATTACK_SHOTGUN
		self.ActivityTranslateAI[ACT_RELOAD] 						= ACT_RELOAD_SHOTGUN
		self.ActivityTranslateAI[ACT_IDLE] 							= ACT_SHOTGUN_IDLE4
		self.ActivityTranslateAI[ACT_IDLE_ANGRY] 					= ACT_IDLE_ANGRY_SHOTGUN
		self.ActivityTranslateAI[ACT_WALK] 							= ACT_WALK_AIM_SHOTGUN
		
		self.ActivityTranslateAI[ACT_IDLE_RELAXED] 					= ACT_IDLE_SHOTGUN_RELAXED
		self.ActivityTranslateAI[ACT_IDLE_STIMULATED] 				= ACT_IDLE_SHOTGUN_STIMULATED
		self.ActivityTranslateAI[ACT_IDLE_AGITATED] 				= ACT_IDLE_SHOTGUN_AGITATED
		
		self.ActivityTranslateAI[ACT_WALK_RELAXED] 					= ACT_WALK_AIM_SHOTGUN
		self.ActivityTranslateAI[ACT_WALK_STIMULATED] 				= ACT_WALK_AIM_SHOTGUN
		self.ActivityTranslateAI[ACT_WALK_AGITATED] 				= ACT_WALK_AIM_SHOTGUN
		
		self.ActivityTranslateAI[ACT_RUN_RELAXED] 					= ACT_RUN_AIM_SHOTGUN
		self.ActivityTranslateAI[ACT_RUN_STIMULATED] 				= ACT_RUN_AIM_SHOTGUN
		self.ActivityTranslateAI[ACT_RUN_AGITATED] 					= ACT_RUN_AIM_SHOTGUN
		
		self.ActivityTranslateAI[ACT_IDLE_AIM_RELAXED] 				= ACT_SHOTGUN_IDLE_DEEP
		self.ActivityTranslateAI[ACT_IDLE_AIM_STIMULATED] 			= ACT_SHOTGUN_IDLE_DEEP
		self.ActivityTranslateAI[ACT_IDLE_AIM_AGITATED] 			= ACT_SHOTGUN_IDLE_DEEP
		
		self.ActivityTranslateAI[ACT_WALK_AIM_RELAXED] 				= ACT_WALK_AIM_SHOTGUN
		self.ActivityTranslateAI[ACT_WALK_AIM_STIMULATED] 			= ACT_WALK_AIM_SHOTGUN
		self.ActivityTranslateAI[ACT_WALK_AIM_AGITATED] 			= ACT_WALK_AIM_SHOTGUN
		
		self.ActivityTranslateAI[ACT_RUN_AIM_RELAXED] 				= ACT_RUN_AIM_SHOTGUN
		self.ActivityTranslateAI[ACT_RUN_AIM_STIMULATED] 			= ACT_RUN_AIM_SHOTGUN
		self.ActivityTranslateAI[ACT_RUN_AIM_AGITATED] 				= ACT_RUN_AIM_SHOTGUN
		
		self.ActivityTranslateAI[ACT_WALK_AIM] 						= ACT_WALK_AIM_SHOTGUN
		self.ActivityTranslateAI[ACT_WALK_CROUCH] 					= ACT_WALK_CROUCH_RIFLE
		self.ActivityTranslateAI[ACT_WALK_CROUCH_AIM] 				= ACT_WALK_CROUCH_AIM_RIFLE
		self.ActivityTranslateAI[ACT_RUN] 							= ACT_RUN_AIM_SHOTGUN
		self.ActivityTranslateAI[ACT_RUN_AIM] 						= ACT_RUN_AIM_SHOTGUN
		self.ActivityTranslateAI[ACT_RUN_CROUCH] 					= ACT_RUN_CROUCH_RIFLE
		self.ActivityTranslateAI[ACT_RUN_CROUCH_AIM] 				= ACT_RUN_CROUCH_AIM_RIFLE
		self.ActivityTranslateAI[ACT_GESTURE_RANGE_ATTACK1] 		= ACT_GESTURE_RANGE_ATTACK_SHOTGUN
		self.ActivityTranslateAI[ACT_COVER_LOW] 					= ACT_COVER_SMG1_LOW
		self.ActivityTranslateAI[ACT_RANGE_AIM_LOW] 				= ACT_RANGE_AIM_AR2_LOW
		self.ActivityTranslateAI[ACT_RANGE_ATTACK1_LOW] 			= ACT_RANGE_ATTACK_SHOTGUN_LOW
		self.ActivityTranslateAI[ACT_RELOAD_LOW] 					= ACT_RELOAD_SHOTGUN_LOW
		self.ActivityTranslateAI[ACT_GESTURE_RELOAD] 				= ACT_GESTURE_RELOAD_SHOTGUN
	elseif t == "rpg" then
		self.ActivityTranslateAI[ACT_RANGE_ATTACK1] 				= ACT_CROUCHIDLE
		self.ActivityTranslateAI[ACT_RELOAD] 						= ACT_RELOAD_SMG1
		self.ActivityTranslateAI[ACT_IDLE] 							= ACT_IDLE_RPG
		self.ActivityTranslateAI[ACT_IDLE_ANGRY] 					= ACT_IDLE_ANGRY_RPG
		self.ActivityTranslateAI[ACT_WALK] 							= ACT_WALK_RPG
		
		self.ActivityTranslateAI[ACT_IDLE_RELAXED] 					= ACT_IDLE_RPG_RELAXED
		self.ActivityTranslateAI[ACT_IDLE_STIMULATED] 				= ACT_IDLE_SMG1_STIMULATED
		self.ActivityTranslateAI[ACT_IDLE_AGITATED] 				= ACT_IDLE_ANGRY_RPG
		
		self.ActivityTranslateAI[ACT_WALK_RELAXED] 					= ACT_WALK_RPG_RELAXED
		self.ActivityTranslateAI[ACT_WALK_STIMULATED] 				= ACT_WALK_RIFLE_STIMULATED
		self.ActivityTranslateAI[ACT_WALK_AGITATED] 				= ACT_WALK_AIM_RIFLE
		
		self.ActivityTranslateAI[ACT_RUN_RELAXED] 					= ACT_RUN_RPG_RELAXED
		self.ActivityTranslateAI[ACT_RUN_STIMULATED] 				= ACT_RUN_RIFLE_STIMULATED
		self.ActivityTranslateAI[ACT_RUN_AGITATED] 					= ACT_RUN_AIM_RIFLE
		
		self.ActivityTranslateAI[ACT_IDLE_AIM_RELAXED] 				= ACT_IDLE_RPG_RELAXED
		self.ActivityTranslateAI[ACT_IDLE_AIM_STIMULATED] 			= ACT_IDLE_AIM_RIFLE_STIMULATED
		self.ActivityTranslateAI[ACT_IDLE_AIM_AGITATED] 			= ACT_IDLE_ANGRY_RPG
		
		self.ActivityTranslateAI[ACT_WALK_AIM_RELAXED] 				= ACT_WALK_RPG_RELAXED
		self.ActivityTranslateAI[ACT_WALK_AIM_STIMULATED] 			= ACT_WALK_AIM_RIFLE_STIMULATED
		self.ActivityTranslateAI[ACT_WALK_AIM_AGITATED] 			= ACT_WALK_AIM_RIFLE
		
		self.ActivityTranslateAI[ACT_RUN_AIM_RELAXED] 				= ACT_RUN_RPG_RELAXED
		self.ActivityTranslateAI[ACT_RUN_AIM_STIMULATED] 			= ACT_RUN_AIM_RIFLE_STIMULATED
		self.ActivityTranslateAI[ACT_RUN_AIM_AGITATED]				= ACT_RUN_AIM_RIFLE
		
		self.ActivityTranslateAI[ACT_WALK_AIM] 						= ACT_WALK_AIM_RIFLE
		self.ActivityTranslateAI[ACT_WALK_CROUCH] 					= ACT_WALK_CROUCH_RPG
		self.ActivityTranslateAI[ACT_WALK_CROUCH_AIM] 				= ACT_WALK_CROUCH_RPG
		self.ActivityTranslateAI[ACT_RUN] 							= ACT_RUN_RPG
		self.ActivityTranslateAI[ACT_RUN_AIM] 						= ACT_RUN_AIM_RIFLE
		self.ActivityTranslateAI[ACT_RUN_CROUCH] 					= ACT_RUN_CROUCH_RPG
		self.ActivityTranslateAI[ACT_RUN_CROUCH_AIM] 				= ACT_RUN_CROUCH_RPG
		self.ActivityTranslateAI[ACT_GESTURE_RANGE_ATTACK1] 		= ACT_GESTURE_RANGE_ATTACK_SMG1
		self.ActivityTranslateAI[ACT_COVER_LOW] 					= ACT_COVER_LOW_RPG
		self.ActivityTranslateAI[ACT_RANGE_AIM_LOW] 				= ACT_RANGE_AIM_SMG1_LOW
		self.ActivityTranslateAI[ACT_RANGE_ATTACK1_LOW] 			= ACT_RANGE_ATTACK_SMG1_LOW
		self.ActivityTranslateAI[ACT_RELOAD_LOW] 					= ACT_RELOAD_SMG1_LOW
		self.ActivityTranslateAI[ACT_GESTURE_RELOAD] 				= ACT_GESTURE_RELOAD_SMG1
	end
end

if SERVER then return end

SWEP.SBobScale				= 1
SWEP.SBobSpeed				= 10.5
SWEP.SBobFadeSpeedInAir		= 5

local t = 1
local laseranim = 0
local vertOffset = 0
local vertOffsetSinMul = 0
local vertOffsetSinTime = 0
local cvar_bob = CreateClientConVar("ss_bob", 1)

function SWEP:CalcViewModelView(vm, oldpos, oldang, pos, ang)
	if !IsValid(vm) or !IsValid(self.Owner) then return end
	
	local modelindex = vm:ViewModelIndex()
	
	local reg = debug.getregistry()
	local GetVelocity = reg.Entity.GetVelocity
	local ownerVelocity = GetVelocity(self.Owner)
	
	if cvar_bob:GetBool() then
		local Length = reg.Vector.Length2D
		local speed = Length(ownerVelocity)
		speed = math.Clamp(speed/256, 0, .4)
		local bobspeed = self.SBobSpeed
		local sine = math.sin(CurTime() * bobspeed)
		local bobright = sine * speed
		local bobup = sine * bobright / 2
		local bobscale = self.SBobScale * math.Clamp(-vertOffset + 1, 0, 1)
		
		if !self.SBobInAir then
			if game.SinglePlayer() or IsFirstTimePredicted() then
				local FT = FrameTime()
				if self.Owner:IsOnGround() then
					t = Lerp(FT*16, t, 1)
				else
					t = math.max(Lerp(FT*self.SBobFadeSpeedInAir, t, 0.01), 0)
				end
			end
		end

		if modelindex == 0 then
			pos = pos + bobright * bobscale * ang:Right() *t
		else
			pos = pos - bobright * bobscale * ang:Right() *t
		end	
		pos = pos + bobup * bobscale * ang:Up() *t
	end
	
	if self.Owner:GetMoveType() == MOVETYPE_WALK then
		if modelindex == 0 and (game.SinglePlayer() or IsFirstTimePredicted()) then -- don't call calculations more than once
			local vertVel = ownerVelocity[3]
			if vertVel < 0 then
				vertOffset = math.max(vertVel * .005, -.3)
				vertOffsetSinTime = 0
				vertOffsetSinMul = math.min(vertVel * -.00075, .4) -- TODO: change value based on correct jump height
			elseif vertOffsetSinMul > .0001 then
				local FT = FrameTime()
				if FT > 0 then
					vertOffsetSinTime = vertOffsetSinTime + FT * 10
					vertOffsetSinMul = Lerp(FT*5, vertOffsetSinMul, 0)
					vertOffset = Lerp(FT*16, vertOffset, 0) + math.sin(vertOffsetSinTime) * vertOffsetSinMul * FT*100
				end
			end
		end
		pos = pos - ang:Up() * vertOffset
	end
	
	if self.EnableIdle then
		local breathSpeed, breathWeakness = 1.3, 26
		pos = pos + math.sin(CurTime() * breathSpeed) * ang:Up() / breathWeakness
	end
	
	if self.LaserPos then
		local firetime = CurTime() - self:GetNextPrimaryFire()
		local seq = self:GetSequence()
		if game.SinglePlayer() or IsFirstTimePredicted() then
			local FT = FrameTime()
			if firetime <= FT - .09 and self:Ammo1() > 0 and (seq == 0 or seq == 1 or seq == 2 or seq == 3) then
				laseranim = math.Approach(laseranim, .75, FT * 60)
			end
			laseranim = Lerp(FT * 20, laseranim, .0001)
		end
		pos = pos - laseranim * ang:Forward()
		ang:RotateAroundAxis(ang:Right(), 4.5)
	end
	
	if self:GetZoom() then
		pos = pos + ang:Up() * 20 -- hiding the viewmodel
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
local crosshair_table = {
	surface.GetTextureID("vgui/serioussam/Crosshair1"),
	surface.GetTextureID("vgui/serioussam/Crosshair2"),
	surface.GetTextureID("vgui/serioussam/Crosshair3"),
	surface.GetTextureID("vgui/serioussam/Crosshair4"),
	surface.GetTextureID("vgui/serioussam/Crosshair5"),
	surface.GetTextureID("vgui/serioussam/Crosshair6"),
	surface.GetTextureID("vgui/serioussam/Crosshair7")
}
function SWEP:Crosshair()
	local x, y = ScrW() / 2, ScrH() / 2
	local tr = self.Owner:GetEyeTraceNoCursor()
	
	if self.Owner == LocalPlayer() && self.Owner:ShouldDrawLocalPlayer() then
		local coords = tr.HitPos:ToScreen()
		x, y = coords.x, coords.y
	end

	local dist = math.Round(-self.Owner:GetPos():Distance(tr.HitPos) /12) +64
	dist = math.Clamp(dist, 32, 128)

	local getcvar = cvar_crosshair:GetInt()
	if getcvar <= 0 or getcvar > #crosshair_table then return end
	
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
	
	surface.SetTexture(crosshair_table[getcvar])
	surface.SetDrawColor(colr, colg, colb, 255)
	surface.DrawTexturedRect(x - dist /2 -1, y - dist /2 +1, dist, dist)
end