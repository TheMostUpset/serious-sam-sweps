
if CLIENT then

	SWEP.PrintName			= "Schofield .45 (Dual)"
	SWEP.Author				= "Upset"
	SWEP.Slot				= 1
	SWEP.SlotPos			= 1
	SWEP.ViewModelFlip		= false
	SWEP.ViewModelFlip1		= true
	SWEP.WepIcon 			= "icons/serioussam/DoubleColt"
	killicon.Add("weapon_ss_colt_dual", SWEP.WepIcon, Color(255, 255, 255, 255))
	
end

function SWEP:Initialize()
	if CLIENT then
		self.LeftModel = ClientsideModel(self.WorldModel, RENDERGROUP_BOTH)
		self.LeftModel:SetNoDraw(true)
	end
	self:SetHoldType(self.HoldType)
	self:SetDeploySpeed(self.DeployDelay)
end

function SWEP:Equip(ply)
	ply:Give(self.Base)
end

function SWEP:SpecialDeploy()
	self.DeployAnim = ACT_VM_DRAW
	local vm = self.Owner:GetViewModel(1)
	vm:SetWeaponModel(self.ViewModel, self)
	self:SendSecondWeaponAnim(ACT_VM_DRAW)
	self:SetDeploySpeed(self.DeployDelay)
	
	self:SetFidgetDelay(0)
	local seq = vm:SelectWeightedSequence(ACT_VM_DRAW)
	self:SetIdleDelay(CurTime() + self:SequenceDuration(seq))
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:WeaponSound(self.Primary.Sound)
	self:SetAttackDelay(CurTime() +.2)
	self:Attack()
	self:SeriousFlash()
	self:SetIdleDelay(0)
	self:HolsterDelay(CurTime() +.2)
end

function SWEP:SpecialThink()	
	if game.SinglePlayer() and CLIENT then return end

	local att = self:GetAttackDelay()
	if att > 0 and CurTime() > att then
		self:SetAttackDelay(0)
		if self:CanPrimaryAttack() then
			self:Attack()
			self:EmitSound(self.Primary.Sound, 100, 100)
			self:SendSecondWeaponAnim(ACT_VM_PRIMARYATTACK)
			self:SeriousFlash(1)
			self:IdleStuff()
		end
	end
	
	local secReload = self:GetSecondReload()
	if secReload > 0 and secReload <= CurTime() then
		self:SetSecondReload(0)
		self:SendSecondWeaponAnim(ACT_VM_RELOAD)
		self:EmitSound(self.ReloadSound, 100, 100, 1, CHAN_AUTO)
		self:IdleStuff()
	end
end

function SWEP:IdleThink()	
	local idle = self:GetIdleDelay()
	local fidget = self:GetFidgetDelay()
	if idle > 0 and CurTime() > idle then
		self:SetIdleDelay(0)
		self:SetFidgetDelay(CurTime() + self:SequenceDuration() + math.random(10,12))
		self:SendWeaponAnim(ACT_VM_IDLE)
		self:SendSecondWeaponAnim(ACT_VM_IDLE)
	end
	
	if fidget > 0 and CurTime() > fidget then
		self:SetFidgetDelay(0)
		if self:LookupSequence("idle2") == -1 then return end
		self:SendWeaponAnim(ACT_VM_FIDGET)
		self:SendSecondWeaponAnim(ACT_VM_FIDGET, 1, 1.0)
		self:SetIdleDelay(CurTime() + self:SequenceDuration())
	end
end

function SWEP:GetTracerOrigin()
	local ply = self:GetOwner()
	if IsValid(ply) then
		local vm = ply:GetViewModel(1)
		if IsValid(vm) then
			local att = vm:GetAttachment(1)
			if self:GetAttackDelay() == 0 then
				return att.Pos
			end
		end
	end
end

function SWEP:Reload()
	if self:Clip1() > 0 and CurTime() < self:GetNextReload() then return end
	if self:Clip1() >= self.Primary.ClipSize or self:GetBeingHolster() or self:GetHolsterTime() > CurTime() then return end
	self:SetIdleDelay(0)
	self:HolsterDelay(CurTime() +1.4)
	self:SendWeaponAnim(ACT_VM_RELOAD)
	self.Owner:SetAnimation(PLAYER_RELOAD)
	self:SetClip1(self.Primary.ClipSize)
	self:EmitSound(self.ReloadSound)
	self:SetNextPrimaryFire(CurTime() +1.4)
	
	self:SetSecondReload(CurTime() + .6)
end

function SWEP:DelayedHolster(wep)
	local hTime = self.HolsterTime
	self:SetNewWeapon(wep)
	self:SetIdleDelay(0)
	if wep:GetClass() == self.Base then
		hTime = .2
		wep:SetClip1(self:Clip1() / 2)
		wep.DeployAnim = ACT_VM_IDLE
		wep:SetDeploySpeed(self.DeployDelayToSingle)
	else
		self:SendWeaponAnim(ACT_VM_HOLSTER)
	end
	self:SetNextPrimaryFire(CurTime() + hTime + .05)
	self:SetNextReload(CurTime() + hTime + .05)
	self:SendSecondWeaponAnim(ACT_VM_HOLSTER)
	self:SetBeingHolster(true)
	self:SetHolsterTime(CurTime() + hTime)
end

function SWEP:OnRemove()
	self:SetAttackDelay(0)
	if SERVER then
		local owner = self:GetOwner()
		if owner and IsValid(owner) and owner:IsPlayer() then
			local vm = owner:GetViewModel(1)
			if IsValid(vm) then
				vm:SetWeaponModel(self.ViewModel, nil)
			end
		end
	end
end

function SWEP:SendSecondWeaponAnim(anim)
	local owner = self:GetOwner()
		
	if (owner && owner:IsValid() && owner:IsPlayer()) then
	
		local vm = owner:GetViewModel(1)
	
		local idealSequence = self:SelectWeightedSequence(anim)
		local nextSequence = self:FindTransitionSequence(self:GetSequence(), idealSequence)
		
		vm:RemoveEffects(EF_NODRAW)

		if (nextSequence > 0) then
			vm:SendViewModelMatchingSequence(nextSequence)
		else
			vm:SendViewModelMatchingSequence(idealSequence)
		end

		return vm:SequenceDuration(vm:GetSequence())
	end
end

function SWEP:DrawWorldModel()
	local lhand, LHandAT
	
	if !IsValid(self.Owner) then
		self:DrawModel()
		return
	end
	
	if !LHandAT then
		LHandAT = self.Owner:LookupAttachment("anim_attachment_lh")
	end

	lhand = self.Owner:GetAttachment(LHandAT)
	
	if !lhand then
		self:DrawModel()
		return
	end

	loffset = lhand.Ang:Forward() * 7.6 + lhand.Ang:Up() * 2
	
	lhand.Ang:RotateAroundAxis(lhand.Ang:Right(), 0)
	lhand.Ang:RotateAroundAxis(lhand.Ang:Forward(), 0)
	lhand.Ang:RotateAroundAxis(lhand.Ang:Up(), 175)
	
	self.LeftModel:SetRenderOrigin(lhand.Pos + loffset)
	self.LeftModel:SetRenderAngles(lhand.Ang)	
	self.LeftModel:DrawModel()
	
	self:DrawModel()
end

SWEP.HoldType			= "duel"
SWEP.Base				= "weapon_ss_colt"
SWEP.Category			= "Serious Sam"
SWEP.Spawnable			= true

SWEP.Primary.Delay			= .23
SWEP.Primary.ClipSize		= 12
SWEP.Primary.DefaultClip	= 12