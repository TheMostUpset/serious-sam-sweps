
if CLIENT then

	SWEP.PrintName			= "Military Knife"
	SWEP.Author				= "Upset"
	SWEP.Slot				= 0
	SWEP.SlotPos			= 0
	SWEP.ViewModelFOV		= 70
	SWEP.WepIcon			= "icons/serioussam/Knife"
	killicon.Add("weapon_ss_knife", SWEP.WepIcon, Color(255, 255, 255, 255))
	
end

function SWEP:PrimaryAttack()
	if !self:CanUseWeapon() then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:Melee()
	self:SendWeaponAnim(ACT_VM_HITCENTER)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self:WeaponSound(self.Primary.Sound, 80)
	self:IdleStuff()
	self:HolsterDelay()
end

function SWEP:Melee()
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
			mins = Vector(-3, -3, -1),
			maxs = Vector(3, 3, 1)
		})
	end
	
	if tr.Hit then
		self:OnHit(tr)
	end

	if SERVER then self.Owner:LagCompensation(false) end
end

function SWEP:OnHit(tr)
	self:ImpactEffect(tr)
	self:DoDamage(tr)
end

function SWEP:DoDamage(tr)
	local dmg = self.Primary.Damage
	local attacker = self.Owner
	if !IsValid(attacker) then attacker = self end
	local victim = tr.Entity
	
	-- backstab
	if self:IsDeathmatchRules() and IsValid(victim) and victim:IsPlayer() then
		local dir = (attacker:GetPos() - victim:GetPos()):GetNormalized()
		local dot = victim:GetForward():Dot(dir)
		if dot < -0.45 then
			dmg = dmg * 10
		end
	end
	
	local dmginfo = DamageInfo()
	dmginfo:SetAttacker(attacker)
	dmginfo:SetInflictor(self)
	dmginfo:SetDamage(dmg)
	dmginfo:SetDamageForce(self.Owner:GetUp() *3000 +self.Owner:GetForward() *12000 +self.Owner:GetRight() *-1500)
	victim:DispatchTraceAttack(dmginfo, tr)
end

function SWEP:ImpactEffect(tr)
	if !IsFirstTimePredicted() then return end
	local dmgtype = DMG_SLASH
	if tr.Entity:IsPlayer() then
		dmgtype = DMG_CLUB -- fixes decals on players
	end
	local e = EffectData()
	e:SetOrigin(tr.HitPos)
	e:SetStart(tr.StartPos)
	e:SetSurfaceProp(tr.SurfaceProps)
	e:SetDamageType(dmgtype)
	e:SetHitBox(tr.HitBox)
	if CLIENT then
		e:SetEntity(tr.Entity)
	else
		e:SetEntIndex(tr.Entity:EntIndex())
	end
	util.Effect("Impact", e)
end

SWEP.HoldType			= "knife"
SWEP.Base				= "weapon_ss_base"
SWEP.Category			= "Serious Sam"
SWEP.Spawnable			= true

SWEP.ViewModel			= "models/weapons/serioussam/v_knife.mdl"
SWEP.WorldModel			= "models/weapons/serioussam/w_knife.mdl"

SWEP.Primary.Sound			= Sound("weapons/serioussam/knife/Back.wav")
SWEP.Primary.Damage			= 100
SWEP.Primary.Delay			= .83
SWEP.HitDist				= 65

SWEP.DeployDelay			= 1.9