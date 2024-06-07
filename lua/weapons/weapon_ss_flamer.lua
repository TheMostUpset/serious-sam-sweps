
if CLIENT then

	SWEP.PrintName			= "XOP Flamethrower"
	SWEP.Author				= "Upset"
	SWEP.Slot				= 4
	SWEP.SlotPos			= 0
	SWEP.ViewModelFOV		= 54
	SWEP.WepIcon			= "icons/serioussam/Flamer"
	killicon.Add("weapon_ss_flamer", SWEP.WepIcon, Color(255, 255, 255, 255))
	
end

function SWEP:SpecialDataTables()
	self:NetworkVar("Float", 4, "AmmoDelay")
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() or self.Owner:WaterLevel() >= 3 then return end
	if self:GetAttackDelay() <= 0 then
		self:SetAttackDelay(CurTime() + .25)
	end
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:HolsterDelay(self:GetAttackDelay() +.2)
end

function SWEP:SpecialThink()
	local attdelay = self:GetAttackDelay()
	if attdelay > 0 and attdelay <= CurTime() and self.Owner:WaterLevel() < 3 then
		if self:GetAmmoDelay() <= 0 then
			self:SetAmmoDelay(CurTime())
		end
		local ammoDelay = self:GetAmmoDelay()
		if ammoDelay > 0 and ammoDelay <= CurTime() then
			self:TakeAmmo()
			self:SetAmmoDelay(CurTime() + .07)
		end
		
		if !self.fire or (self.fire and !self.fire:IsPlaying()) then
			self.fire = CreateSound(self.Owner, self.Primary.Sound)
			self.fire:SetSoundLevel(100)
			self.fire:PlayEx(1, 30)
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
			mins = Vector(-16, -16, -10),
			maxs = Vector(16, 16, 10)
			})
		end
		
		if SERVER then
			if tr.Hit and (IsValid(tr.Entity) or tr.HitWorld) then
				local hitTime = tr.StartPos:Distance(tr.HitPos)/768
				timer.Simple(hitTime, function()
					if !IsValid(self) or !IsValid(self.Owner) then return end
					local dmginfo = DamageInfo()
					local attacker = self.Owner
					if (!IsValid(attacker)) then attacker = self end
					dmginfo:SetAttacker(attacker)
					dmginfo:SetInflictor(self)
					dmginfo:SetDamageType(DMG_SLOWBURN)
					dmginfo:SetDamage(self.Primary.Damage)
					dmginfo:SetDamageForce(self.Owner:GetUp() *1000 +self.Owner:GetForward() *4000)
					if IsValid(tr.Entity) then
						tr.Entity:TakeDamageInfo(dmginfo)
						tr.Entity:Ignite(7)
					end
					local ents = ents.FindInSphere(tr.HitPos, 32)
					for k,v in pairs(ents) do
						local trace = util.TraceHull({
							start = tr.HitPos,
							endpos = v:GetPos(),
							filter = {self.Owner, tr.Entity}
						})
						if IsValid(trace.Entity) and trace.Entity == v and (trace.Entity:IsNPC() or trace.Entity:IsPlayer()) then
							trace.Entity:Ignite(7)
							trace.Entity:TakeDamageInfo(dmginfo)
						end
					end
				end)
			end
			self.Owner:LagCompensation(false)
		end
		
		if IsFirstTimePredicted() then
			local fx = EffectData()
			fx:SetEntity(self)
			fx:SetOrigin(self.Owner:GetShootPos())
			fx:SetNormal(self.Owner:GetAimVector())
			fx:SetStart(tr.HitPos)
			fx:SetAngles(Angle(math.Rand(0,360), math.Rand(0,360), math.Rand(0,360)))
			fx:SetAttachment(1)
			util.Effect("ss_flamethrower", fx)
		end

		self:SetAttackDelay(CurTime() + self.Primary.Delay)
	end
	if attdelay > 0 and attdelay <= CurTime() and (!self.Owner:KeyDown(IN_ATTACK) or self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0 or self.Owner:WaterLevel() >= 3) then
		self:IdleStuff()
		self:SetNextPrimaryFire(CurTime() + .3)
		self:EmitSound(self.Sound, 100, 30)
		self:OnRemove()
	end
end

function SWEP:OnRemove()
	self:SetAttackDelay(0)
	if self.fire then self.fire:Stop() end
end

SWEP.HoldType			= "shotgun"
SWEP.Base				= "weapon_ss_base"
SWEP.Category			= "Serious Sam"
SWEP.Spawnable			= true

SWEP.ViewModel			= "models/weapons/serioussam/v_flamer.mdl"
SWEP.WorldModel			= "models/weapons/serioussam/w_flamer.mdl"

SWEP.Primary.Sound			= Sound("weapons/serioussam/flamer/Fire.wav")
SWEP.Primary.Delay			= .03
SWEP.Primary.DefaultClip	= 100
SWEP.Primary.Ammo			= "napalm"

SWEP.Sound					= Sound("weapons/serioussam/flamer/Stop.wav")

SWEP.HitDist				= 512

SWEP.DeployDelay			= 1