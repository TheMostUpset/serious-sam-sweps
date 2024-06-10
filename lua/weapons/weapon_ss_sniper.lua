
if CLIENT then

	SWEP.PrintName			= "RAPTOR Sniper Rifle"
	SWEP.Author				= "Upset"
	SWEP.Slot				= 4
	SWEP.SlotPos			= 1
	SWEP.ViewModelFOV		= 24
	SWEP.WepIcon			= "icons/serioussam/Sniper"
	killicon.Add("weapon_ss_sniper", SWEP.WepIcon, Color(255, 255, 255, 255))
	
	surface.CreateFont("SSsniperfont", {
		font = "default",
		size = ScrH()/43,
		weight = 0,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = true,
		additive = false,
		outline = false
	})
	
local SniperMask = surface.GetTextureID("vgui/serioussam/SniperMask")
local SniperWheel = surface.GetTextureID("vgui/serioussam/SniperWheel")
local SniperLed = surface.GetTextureID("vgui/serioussam/SniperLed")
local SniperArrow = surface.GetTextureID("vgui/serioussam/SniperArrow")
local SniperEye = surface.GetTextureID("vgui/serioussam/SniperEye")

function SWEP:DrawHUD()
	if !self:GetZoom() then self:Crosshair() end
end

function SWEP:DrawHUDBackground()
	local x, y = ScrW() / 2, ScrH() / 2
	
	if self:GetZoom() then
		surface.SetTexture(SniperMask)
		surface.SetDrawColor(255, 255, 255, 255)		
		surface.DrawTexturedRectUV(x-y, 0, y, y, 0, 0, -1.006, 1)
		surface.DrawTexturedRectUV(x, 0, y, y, 0, 0, 1, 1)
		surface.DrawTexturedRectUV(x-y, y, y, y, 0, 0, -1.006, -1)
		surface.DrawTexturedRectUV(x, y, y, y, 0, 0, 1, -1)
		
		surface.SetTexture(SniperWheel)
		surface.SetDrawColor(190, 230, 255, 70)
		surface.DrawTexturedRectRotated(x, y, y/3, y/3, -self:GetZoomTime() *360)
		
		surface.SetTexture(SniperLed)
		local r, g = 0, 255		
		if self:GetNextPrimaryFire() - .1 > CurTime() and self:Ammo1() > 0 then
			r, g = 255, 180
		end
		surface.SetDrawColor(r, g, 0, 255)
		surface.DrawTexturedRect(x-y/5.5, y*1.12, y/17, y/17)
		
		local arrowx = x-y/1.435
		local eyex = x+y/1.6
		surface.SetTexture(SniperArrow)
		surface.SetDrawColor(255, 220, 0, 180)
		surface.DrawTexturedRect(arrowx, y/1.075, y/13, y/13)
		surface.SetTexture(SniperEye)
		surface.DrawTexturedRect(eyex, y/1.085, y/13, y/13)
		
		draw.SimpleText(math.Round(self.Owner:GetPos():Distance(self.Owner:GetEyeTraceNoCursor().HitPos) /12, 1), "SSsniperfont", arrowx, y*1.02, Color(150,180,255,200), TEXT_ALIGN_LEFT)
		//draw.SimpleText(math.Round(-self.Owner:GetFOV() / self.Owner:GetInfoNum("fov_desired", 90) *7.75 +8.75, 1).."x", "SSsniperfont", eyex, y*1.02, Color(150,180,255,200), TEXT_ALIGN_LEFT)
		draw.SimpleText(math.Round((-self:GetZoomTime()+1.25)*8, 1).."x", "SSsniperfont", eyex, y*1.02, Color(150,180,255,200), TEXT_ALIGN_LEFT)

		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(0, 0, x-y/1.1, ScrH())
		surface.DrawRect(ScrW()-(x-y), 0, x-y, ScrH())
	end
end

end

function SWEP:SpecialDataTables()
	self:NetworkVar("Float", 4, "ZoomTime")
	self:NetworkVar("Float", 5, "ZoomStart")
end

function SWEP:PrimaryAttack()	
	if !self:CanPrimaryAttack() then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self:WeaponSound(self.Primary.Sound)
	
	local dmg = self:IsDeathmatchRules() and self.Primary.DamageDM or self.Primary.Damage
	if self:GetZoom() then
		dmg = self:IsDeathmatchRules() and self.Primary.DamageZoomDM or self.Primary.DamageZoom
	end
	
	self:ShootBullet(dmg, self.Primary.NumShots, self.Primary.Cone)
	self:SeriousFlash()
	self:TakeAmmo(self.AmmoToTake)
	self:IdleStuff()
	self:HolsterDelay()
end

function SWEP:SpecialHolster()
	self:OnRemove()
end

function SWEP:OnRemove()
	self:SetZoom(false)
	self:SetZoomStart(0)
	if self.ZoomSound then self.ZoomSound:Stop() end
	self:SetHoldType(self.HoldType)
end

function SWEP:SecondaryAttack()
	if !self:GetZoom() then
		self:SetZoom(true)
		self:SetZoomTime(1)
		self:SetHoldType("ar2")
		self.ZoomSound = CreateSound(self.Owner, self.Primary.Special1)
		self.ZoomSound:Play()
		self:SetZoomStart(CurTime()*self.ZoomSpeed)
	else 
		self:SetZoom(false)
		self:SetZoomTime(0)
		self:SetHoldType(self.HoldType)
	end	
end

function SWEP:SpecialThink()
	if self:GetZoomStart() > 0 then
		local ct = CurTime()*self.ZoomSpeed
		self:SetZoomTime(math.max(1-(ct - self:GetZoomStart()), 0))
		if self.Owner:KeyReleased(IN_ATTACK2) or ct-self.MaxZoom >= self:GetZoomStart() then
			self:SetZoomStart(0)
			if self.ZoomSound then self.ZoomSound:Stop() end
		end
	end
end

function SWEP:TranslateFOV(fov)
	if self:GetZoom() and self:GetZoomTime() > 0 then
		return fov * self:GetZoomTime()
	else
		return fov
	end
end

function SWEP:AdjustMouseSensitivity()
	if self:GetZoom() then
		return self.Owner:GetFOV() / self.Owner:GetInfoNum("fov_desired", 90)
	end
end

if SERVER then

	function SWEP:GetNPCBulletSpread()
		return 2
	end

	function SWEP:GetNPCBurstSettings()
		return 1, 1, self.Primary.Delay * 1.5
	end

	function SWEP:GetNPCRestTimes()
		return self.Primary.Delay * 3, self.Primary.Delay * 6
	end
	
end

SWEP.HoldType			= "shotgun"
SWEP.Base				= "weapon_ss_base"
SWEP.Category			= "Serious Sam"
SWEP.Spawnable			= true

SWEP.ViewModel			= "models/weapons/serioussam/v_sniper.mdl"
SWEP.WorldModel			= "models/weapons/serioussam/w_sniper.mdl"

SWEP.Primary.Sound			= Sound("weapons/serioussam/sniper/Fire.wav")
SWEP.Primary.Special1		= Sound("weapons/serioussam/sniper/Zoom.wav")
SWEP.Primary.Damage			= 70
SWEP.Primary.DamageDM		= 50
SWEP.Primary.DamageZoom		= 300
SWEP.Primary.DamageZoomDM	= 100
SWEP.Primary.Cone			= .001
SWEP.Primary.Delay			= 1.4
SWEP.Primary.DefaultClip	= 15
SWEP.Primary.Ammo			= "sniperround"

SWEP.Secondary.Automatic	= false

SWEP.ZoomSpeed				= .75
SWEP.MaxZoom				= .75

SWEP.MuzzleScale			= 26
SWEP.EnableSmoke			= true

SWEP.SBobScale				= .6