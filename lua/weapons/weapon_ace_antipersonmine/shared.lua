AddCSLuaFile("shared.lua")
SWEP.Base = "weapon_ace_base"

if CLIENT then
	SWEP.PrintName		= "Mine-Anti Personel"
	SWEP.Slot			= 4
	SWEP.SlotPos		= 3
end

SWEP.Spawnable		= true

SWEP.Category = "ACE Weapons"
SWEP.SubCategory = "Grenades/Mines"

--Visual
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/v_slam.mdl"
SWEP.WorldModel		= "models/weapons/w_slam.mdl"
SWEP.ReloadSound	= "Weapon_Pistol.Reload"
SWEP.HoldType		= "rpg"
SWEP.CSMuzzleFlashes	= true


-- Other settings
SWEP.Weight			= 10

-- Weapon info
SWEP.Purpose		= "Achtung Minen!"
SWEP.Instructions	= "Left mouse to drop mine"

-- Primary fire settings
SWEP.Primary.Sound			= "weapons/slam/mine_mode.wav"
SWEP.Primary.NumShots		= 1
SWEP.Primary.Recoil			= 10
SWEP.Primary.RecoilAngle	= 15
SWEP.Primary.Cone			= 0.025
SWEP.Primary.Delay			= 1
SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 8
SWEP.Primary.Automatic		= 0
SWEP.Primary.Ammo		= "Grenade"

SWEP.Secondary.Ammo		= "none"
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1

SWEP.ReloadSoundEnabled = 1

SWEP.AimOffset = Vector(0, 0, 0)
SWEP.InaccuracyAccumulation = 0
SWEP.lastFire = CurTime()

SWEP.MaxInaccuracyMult = 5
SWEP.InaccuracyAccumulationRate = 0.3
SWEP.InaccuracyDecayRate = 1

SWEP.IronSights = true
SWEP.IronSightsPos = Vector(-2, -15, 2.98)
SWEP.ZoomPos = Vector(2, -2, 2)
SWEP.IronSightsAng = Angle(0.45, 0, 0)
SWEP.CarrySpeedMul = 0.6 --WalkSpeedMult when carrying the weapon

SWEP.ZoomAccuracyImprovement = 0.5 -- 0.3 means 0.7 the inaccuracy
SWEP.ZoomRecoilImprovement = 0.2 -- 0.3 means 0.7 the recoil movement

SWEP.CrouchAccuracyImprovement = 0.4 -- 0.3 means 0.7 the inaccuracy
SWEP.CrouchRecoilImprovement = 0.2 -- 0.3 means 0.7 the recoil movement

--

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	if (self:Ammo1() == 0) and (self:Clip1() == 0) then return end
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self:EmitSound(Sound(self.Primary.Sound), 100, 100, 1, CHAN_WEAPON )

	if CLIENT then
		return
	end

	local owner = self:GetOwner()

	self.BulletData.Owner = owner
	self.BulletData.Gun = self
	self.InaccuracyAccumulation = math.Clamp(self.InaccuracyAccumulation + self.InaccuracyAccumulationRate - self.InaccuracyDecayRate * (CurTime() - self.lastFire), 1, self.MaxInaccuracyMult)

	if not owner:HasGodMode() then

		local ent = ents.Create( "ace_antipersonelmine" )

		if ( IsValid( ent ) ) then

			local Forward = owner:EyeAngles():Forward()

			ent:SetPos( owner:GetShootPos() + Forward * 32 )
			ent:SetAngles( owner:EyeAngles() )
			ent:Spawn()
			ent:SetVelocity( Forward * 10 )
			owner:AddCleanup( "aceexplosives", ent )

			if CPPI then
				ent:CPPISetOwner(Entity(0))
			end
			ent.DamageOwner = owner -- Done to avoid owners from manipulating the entity, but allowing the damage to be credited by him.
		end
	end

	self.lastFire = CurTime()
--	print("Inaccuracy: " .. self.InaccuracyAccumulation)


	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	owner:SetAnimation( PLAYER_ATTACK1 )

	if self:Ammo1() > 0 then
		owner:RemoveAmmo( 1, "Grenade")
	else
		self:TakePrimaryAmmo(1)
	end
--	self:TakePrimaryAmmo(1)

end

function SWEP:SecondaryAttack()
end

function SWEP:Think()
end

function SWEP:Reload()

	--if self:Clip1() < self.Primary.ClipSize and self:Ammo1() > 0 and self.ReloadSoundEnabled == 1 then
--	self:EmitSound(Sound(self.ReloadSound))
	--end
	self:DefaultReload(ACT_VM_RELOAD)

--player.GetByID( 1 ):GiveAmmo( 30-self:Clip1(), "AR2", true )
	self:Think()
	return true
end



