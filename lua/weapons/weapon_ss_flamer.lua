
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
	self:NetworkVar("Float", 5, "AmmoDelay")
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() or self.Owner:WaterLevel() >= 3 then return end
	if self.Owner:IsNPC() then
		self:DoFire(3, 1)
		local pitch = math.random(28, 35)
		self:EmitSound(self.Primary.Sound, 90, pitch)
		timer.Create("SS_Flamer_NPC_StopSound", .25, 1, function()
			if IsValid(self) then
				self:EmitSound(self.Sound, 90, pitch)
			end
		end)
	else
		if self:GetAttackDelay() <= 0 then
			self:SetAttackDelay(CurTime() + .25)
		end
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		self:HolsterDelay(self:GetAttackDelay() +.2)
	end
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
		
		self:DoFire()

		self:SetAttackDelay(CurTime() + self.Primary.Delay)
	end
	if attdelay > 0 and attdelay <= CurTime() and (!self.Owner:KeyDown(IN_ATTACK) or self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0 or self.Owner:WaterLevel() >= 3) then
		self:IdleStuff()
		self:SetNextPrimaryFire(CurTime() + .3)
		self:EmitSound(self.Sound, 100, 30)
		self:OnRemove()
	end
end

function SWEP:DoFire(damage, igniteTime)
	damage = damage or self.Primary.Damage
	igniteTime = igniteTime or 5.9
	
	if SERVER and self.Owner:IsPlayer() then self.Owner:LagCompensation(true) end
	
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
		if (!self.DamageDelay or self.DamageDelay <= CurTime()) and tr.Hit and (IsValid(tr.Entity) or tr.HitWorld) then
			self.DamageDelay = CurTime() + .075
			local hitTime = tr.StartPos:Distance(tr.HitPos)/768
			timer.Simple(hitTime, function()
				if !IsValid(self) or !IsValid(self.Owner) then return end
				local dmginfo = DamageInfo()
				local attacker = self.Owner
				if !IsValid(attacker) then attacker = self end
				dmginfo:SetAttacker(attacker)
				dmginfo:SetInflictor(self)
				dmginfo:SetDamageType(DMG_SLOWBURN)
				dmginfo:SetDamage(damage)
				dmginfo:SetDamageForce(self.Owner:GetUp() *1000 +self.Owner:GetForward() *4000)
				if IsValid(tr.Entity) and tr.Entity:WaterLevel() < 3 then
					tr.Entity:TakeDamageInfo(dmginfo)
					tr.Entity:Ignite(igniteTime)
					tr.Entity.SS_Flamer_ignite = {attacker, self, CurTime() + igniteTime}
				end
				local ents = ents.FindInSphere(tr.HitPos, 32)
				for k,v in pairs(ents) do
					local trace = util.TraceHull({
						start = tr.HitPos,
						endpos = v:GetPos(),
						filter = {self.Owner, tr.Entity}
					})
					if IsValid(trace.Entity) and trace.Entity == v and trace.Entity:WaterLevel() < 3 and self:IsCreature(trace.Entity) then
						trace.Entity:Ignite(igniteTime)
						trace.Entity:TakeDamageInfo(dmginfo)
						trace.Entity.SS_Flamer_ignite = {attacker, self, CurTime() + igniteTime}
					end
				end
			end)
		end
		if self.Owner:IsPlayer() then self.Owner:LagCompensation(false) end
	end
	self:FireEffect(tr.HitPos)
end

function SWEP:FireEffect(hitpos)	
	if IsFirstTimePredicted() then
		local fx = EffectData()
		fx:SetEntity(self)
		fx:SetOrigin(self.Owner:GetShootPos())
		fx:SetNormal(self.Owner:GetAimVector())
		fx:SetStart(hitpos)
		fx:SetAngles(Angle(math.Rand(0,360), math.Rand(0,360), math.Rand(0,360)))
		fx:SetAttachment(1)
		util.Effect("ss_flamethrower", fx)
	end
end

function SWEP:OnRemove()
	self:SetAttackDelay(0)
	if self.fire then self.fire:Stop() end
	self:StopSound(self.Primary.Sound)
end

if SERVER then

	function SWEP:GetNPCBulletSpread()
		return 10
	end

	function SWEP:GetNPCBurstSettings()
		return 20, 40, .1
	end

	function SWEP:GetNPCRestTimes()
		return 2, 5
	end
	
	-- hook.Add("EntityTakeDamage", "SS_Flamer_SetFireOwner", function(ent, dmginfo)
		-- if ent.SS_Flamer_ignite and dmginfo:GetAttacker():GetClass() == "entityflame" then
			-- local data = ent.SS_Flamer_ignite
			-- if data[3] > CurTime() then
				-- local attacker = data[1]
				-- local inflictor = data[2]
				-- if IsValid(attacker) then
					-- dmginfo:SetAttacker(attacker)
				-- end
				-- if IsValid(inflictor) then
					-- dmginfo:SetInflictor(inflictor)
				-- end
			-- end
		-- end
	-- end)
	
end

SWEP.HoldType			= "shotgun"
SWEP.Base				= "weapon_ss_base"
SWEP.Category			= "Serious Sam"
SWEP.Spawnable			= true

SWEP.EntityPickup		= "ss_pickup_flamer"
SWEP.EntityAmmo			= "ss_ammo_napalm"

SWEP.ViewModel			= "models/weapons/serioussam/v_flamer.mdl"
SWEP.WorldModel			= "models/weapons/serioussam/w_flamer.mdl"

SWEP.Primary.Sound			= Sound("weapons/serioussam/flamer/Fire.wav")
SWEP.Primary.Damage			= 8
SWEP.Primary.Delay			= .03
SWEP.Primary.DefaultClip	= 100
SWEP.Primary.Ammo			= "napalm"

SWEP.Sound					= Sound("weapons/serioussam/flamer/Stop.wav")

SWEP.HitDist				= 512

SWEP.DeployDelay			= 1