
if CLIENT then

	SWEP.PrintName			= "XM-214-A Minigun"
	SWEP.Author				= "Upset"
	SWEP.Slot				= 2
	SWEP.SlotPos			= 3
	SWEP.ViewModelFOV		= 68
	SWEP.WepIcon			= "icons/serioussam/MiniGun"
	killicon.Add("weapon_ss_minigun", SWEP.WepIcon, Color(255, 255, 255, 255))
	
	net.Receive("SS_Minigun_ResetBones", function()
		local vm = LocalPlayer():GetViewModel()
		if IsValid(vm) then
			for i = 1, 2 do
				vm:ManipulateBoneAngles(i, Angle(0, 0, 0))
			end
		end
	end)
	
else
	util.AddNetworkString("SS_Minigun_ResetBones")
end

function SWEP:SpecialDeploy()
	self:SetAttackDelay(2)
end

function SWEP:PrimarySoundStart()
	if !self.LoopSound then
		self.LoopSound = CreateSound(self.Owner, self.Primary.Special1)
	end
	if self.LoopSound and !self.LoopSound:IsPlaying() then
		self.LoopSound:Play()
	end
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	
	if !self:GetAttack() then
		self:EmitSound("Weapon_Sam_MiniGun.RotateUp")
		self:EmitSound(self.Primary.Special)
		self:SetAttack(true)
	end

	if self:GetAttackDelay() >= self.BarrelAccelTime then
		self:MinigunFire()
	end
end

function SWEP:MinigunFire()
	local delay, dmg, cone = self.Primary.Delay, self.Primary.Damage, self.Primary.Cone
	if self:IsDeathmatchRules() then
		delay, dmg, cone = self.Primary.DelayDM, self.Primary.DamageDM, self.Primary.ConeDM
	end
	self:SetNextPrimaryFire(CurTime() + delay)
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self:PrimarySoundStart()
	self:WeaponSound(self.Primary.Sound)
	self:ShootBullet(dmg, self.Primary.NumShots, cone)
	self:SeriousFlash()
	self:TakeAmmo(self.AmmoToTake)
	self:IdleStuff()
	self:HolsterDelay(self:GetNextPrimaryFire())
	if self.EnableEndSmoke then
		self.SmokeAmount = self.SmokeAmount + 1
	end
end

function SWEP:EndSmokeThink() -- overriding because we have a bit different code here
end

function SWEP:SpecialThink()
	if game.SinglePlayer() and CLIENT then return end
	if self.Owner:KeyReleased(IN_ATTACK) or self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0 then
		if self:GetAttack() then
			if self.SmokeAmount > 0 then
				local num = game.SinglePlayer() and 90 or 200
				self.SmokeTime = CurTime() + math.min(self.SmokeAmount/num, 1.5)
			end
			self:EmitSound("Weapon_Sam_MiniGun.RotateDown")
			self:EmitSound(self.Primary.Special)
		end
		if self.LoopSound then self.LoopSound:Stop() end
		self:SetAttack(nil)
		self.SmokeAmount = 0
	end
	
	local attdelay = self:GetAttackDelay()
	if self.Owner:KeyDown(IN_ATTACK) and self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 then
		self:SetAttackDelay(math.Clamp(attdelay^1.025, 2, self.BarrelAccelTime))
	else
		self:SetAttackDelay(math.Clamp(attdelay^.994, 2, self.BarrelAccelTime))
	end
end

function SWEP:ResetBones(sendToClient)
	local owner = self.Owner
	if !IsValid(owner) then
		owner = self.LastOwner
	end
	if IsValid(owner) and owner:IsPlayer() then
		if CLIENT then
			local vm = owner:GetViewModel()
			if IsValid(vm) then
				for i = 1, 2 do
					vm:ManipulateBoneAngles(i, Angle(0, 0, 0))
				end
			end
		elseif sendToClient then
			if game.SinglePlayer() then
				timer.Simple(.1, function()
					net.Start("SS_Minigun_ResetBones")
					net.Send(owner)
				end)
			else
				net.Start("SS_Minigun_ResetBones")
				net.Send(owner)
			end
		end
	end
end

function SWEP:SpecialHolster()
	self:OnRemove()
end

function SWEP:OnRemove()
	if self.LoopSound then self.LoopSound:Stop() end
	self:SetAttack(nil)
	self:ResetBones()
	self.SmokeAmount = 0
end

function SWEP:OnDrop()
	self:OnRemove()
	self:ResetBones(true)
end

function SWEP:OwnerChanged()
	if IsValid(self.Owner) and self.Owner:IsPlayer() then
		self.LastOwner = self.Owner
	end
end

local lastpos = 0

function SWEP:ViewModelDrawn(vm)
	local bone = vm:LookupBone("barrels")
	if !bone then return end
	local speed = 4
	local attack = lastpos+self:GetAttackDelay()-2
	lastpos = Lerp(FrameTime()*40, lastpos, attack)
	local rotate = (attack*speed) %360
	vm:ManipulateBoneAngles(bone, Angle(-rotate,0,0))
end

function SWEP:DrawWorldModel()
	self:DrawModel()
	if !IsValid(self:GetOwner()) then return end
	local bone = self:LookupBone("barrels")
	if !bone then return end
	local speed = 4
	local lastpos_w = self:GetVar("lastpos_w"..self:EntIndex(), 0)
	local attack = lastpos_w + self:GetAttackDelay() - 2
	self:SetVar("lastpos_w"..self:EntIndex(), Lerp(FrameTime()*40, lastpos_w, attack))
	local rotate = (attack*speed) %360
	self:ManipulateBoneAngles(bone, Angle(-rotate,0,0))
end

SWEP.HoldType			= "shotgun"
SWEP.Base				= "weapon_ss_base"
SWEP.Category			= "Serious Sam"
SWEP.Spawnable			= true

SWEP.EntityPickup		= "ss_pickup_minigun"
SWEP.EntityAmmo			= "ss_ammo_bullets"

SWEP.ViewModel			= "models/weapons/serioussam/v_minigun.mdl"
SWEP.WorldModel			= "models/weapons/serioussam/w_minigun.mdl"

SWEP.Primary.Sound			= Sound("weapons/serioussam/minigun/Fire.wav")
SWEP.Primary.Special		= Sound("Weapon_Sam_MiniGun.Click")
SWEP.Primary.Special1		= Sound("weapons/serioussam/minigun/Rotate.wav")
SWEP.Primary.Cone			= .015
SWEP.Primary.ConeDM			= .03
SWEP.Primary.DamageDM		= 20
SWEP.Primary.Delay			= .05
SWEP.Primary.DelayDM		= .05
SWEP.Primary.DefaultClip	= 100
SWEP.Primary.Ammo			= "smg1"

SWEP.BarrelAccelTime		= 5

SWEP.MuzzleScale			= 20

SWEP.EnableIdle				= true
SWEP.EnableEndSmoke			= true
SWEP.SmokeAmount			= 0