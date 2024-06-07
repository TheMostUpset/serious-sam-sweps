
if CLIENT then

	SWEP.PrintName			= "P-Lah Chainsaw"
	SWEP.Author				= "Upset"
	SWEP.Slot				= 0
	SWEP.SlotPos			= 1
	SWEP.ViewModelFOV		= 75
	SWEP.WepIcon			= "icons/serioussam/Chainsaw"
	killicon.Add("weapon_ss_chainsaw", SWEP.WepIcon, Color(255, 255, 255, 255))
	
end

function SWEP:SpecialDataTables()
	self:NetworkVar("Float", 4, "AnimDelay")
end

function SWEP:SpecialDeploy()
	self:EmitSound(self.Sound1)
	self.IdleSound = CurTime() +.5
end

function SWEP:PrimaryAttack()
	if !self:GetAttack() then
		self:SetAttack(true)
		self:SetNextPrimaryFire(CurTime() + .2)
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK_1)
		self:EmitSound(self.Sound2, 100, 100)
		self:SetAnimDelay(CurTime())
	else
		if self.idle then self.idle:Stop() end
		self:Melee()
		self:HolsterDelay(CurTime() +.2)
	end
end

function SWEP:SpecialThink()
	if self.Owner:KeyReleased(IN_ATTACK) then
		if self:GetAttack() then
			self:IdleStuff()
			self:SetNextPrimaryFire(CurTime() + .2)
			self.IdleSound = CurTime() +.4
			self:EmitSound(self.Sound3, 100, 100)
		end
		self:OnRemove()
	end
	
	if self.IdleSound and CurTime() > self.IdleSound then
		self.IdleSound = nil
		self.idle = CreateSound(self.Owner, self.Sound4)
		self.idle:SetSoundLevel(80)
		self.idle:Play()
	end
end

function SWEP:OnRemove()
	self:SetAttack(nil)
	if self.idle then self.idle:Stop() end
	if self.fire then self.fire:Stop() end
end

function SWEP:SpecialHolster()
	self:EmitSound(self.Sound5)
	if self.idle then self.idle:Stop() end
end

function SWEP:Melee()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self.Owner:SetAnimation(PLAYER_ATTACK1)	
	
	if !self.fire or (self.fire and !self.fire:IsPlaying()) then
		self.fire = CreateSound(self.Owner, self.Sound6)
		self.fire:SetSoundLevel(100)
		self.fire:Play()
	end
		
	if self:GetAnimDelay() <= CurTime() then
		local delay = .07
		if !game.SinglePlayer() then
			delay = .06
		end
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		self:SetAnimDelay(CurTime() +delay)
	end
	
	if SERVER then self.Owner:LagCompensation(true) end
	local tr = util.TraceLine({
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.HitDist,
		filter = self.Owner
	})

	if !IsValid(tr.Entity) then
		tr = util.TraceHull({
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.HitDist,
		filter = self.Owner,
		mins = Vector(-2, -2, -1),
		maxs = Vector(2, 2, 1)
		})
	end
	
	if tr.Hit then
		self:ImpactEffect(tr)
		if game.SinglePlayer() and SERVER or CLIENT and IsFirstTimePredicted() then util.ScreenShake(tr.HitPos, .5, 5, .15, 80) end
		local hitsnd = self.HitSound1
		if tr.HitWorld then
			if game.SinglePlayer() and SERVER or CLIENT and IsFirstTimePredicted() then
				local effectdata = EffectData()
				effectdata:SetOrigin(tr.HitPos)
				effectdata:SetMagnitude(1)
				effectdata:SetScale(1)
				effectdata:SetRadius(1)
				util.Effect("Sparks", effectdata, true, true)
			end
		elseif tr.Entity:IsNPC() or tr.Entity:IsPlayer() then
			hitsnd = self.HitSound2
		end
		if SERVER then
			sound.Play(hitsnd, tr.HitPos, 80, 100)
			local dmginfo = DamageInfo()
			local attacker = self.Owner
			if (!IsValid(attacker)) then attacker = self end
			dmginfo:SetAttacker(attacker)
			dmginfo:SetInflictor(self)
			dmginfo:SetDamage(self.Primary.Damage)
			dmginfo:SetDamageForce(self.Owner:GetUp() *1000 +self.Owner:GetForward() *8000 +self.Owner:GetRight() *-1000)
			tr.Entity:TakeDamageInfo(dmginfo)
		end
	end

	if SERVER then self.Owner:LagCompensation(false) end
end

function SWEP:ImpactEffect(tr)
	if !IsFirstTimePredicted() then return end
	local e = EffectData()
	e:SetOrigin(tr.HitPos)
	e:SetStart(tr.StartPos)
	e:SetSurfaceProp(tr.SurfaceProps)
	e:SetDamageType(DMG_BULLET)
	e:SetHitBox(tr.HitBox)
	if CLIENT then
		e:SetEntity(tr.Entity)
	else
		e:SetEntIndex(tr.Entity:EntIndex())
	end
	util.Effect("Impact", e)
end

SWEP.HoldType			= "crossbow"
SWEP.Base				= "weapon_ss_base"
SWEP.Category			= "Serious Sam"
SWEP.Spawnable			= true

SWEP.ViewModel			= "models/weapons/serioussam/v_chainsaw.mdl"
SWEP.WorldModel			= "models/weapons/serioussam/w_chainsaw.mdl"

SWEP.Primary.Damage		= 25
SWEP.Primary.Delay		= .05
SWEP.HitDist			= 75

SWEP.Sound1 			= Sound("weapons/serioussam/chainsaw/BringUp.wav")
SWEP.Sound2 			= Sound("weapons/serioussam/chainsaw/BeginFire.wav")
SWEP.Sound3 			= Sound("weapons/serioussam/chainsaw/EndFire.wav")
SWEP.Sound4 			= Sound("weapons/serioussam/chainsaw/Idle.wav")
SWEP.Sound5 			= Sound("weapons/serioussam/chainsaw/BringDown.wav")
SWEP.Sound6 			= Sound("weapons/serioussam/chainsaw/Fire.wav")
SWEP.HitSound1			= Sound("weapons/serioussam/chainsaw/Saw_01.wav")
SWEP.HitSound2 			= Sound("weapons/serioussam/chainsaw/Saw_Flesh01.wav")