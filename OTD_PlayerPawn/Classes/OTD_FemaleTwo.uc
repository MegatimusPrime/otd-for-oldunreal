//=============================================================================
// OTD_FemaleTwo.
//=============================================================================
class OTD_FemaleTwo expands FemaleTwo config(User);

var EDodgeDir OTD_DodgeDir;
var OTD_PawnLogic PawnLogic;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	PawnLogic = new class'OTD_PawnLogic';
	PawnLogic.P = Self;
}

function Landed(vector HitNormal)
{
	PawnLogic.bCanDoubleJump = True;
	PawnLogic.bDodging = False;
	Super.Landed(HitNormal);
}

exec function ReloadAutoMag()
{
	PawnLogic.DoReloadAutoMag();
}

state PlayerWalking
{
	exec function OmnidirectionalDodge()
	{
		OTD_DodgeDir = PawnLogic.DoOmnidirectionalDodge();
	}

	function ProcessMove(float DeltaTime, vector NewAccel, EDodgeDir DodgeMove, rotator DeltaRot)
	{
		if ( PawnLogic.CanDoubleJump() && bPressedJump )
		{
			// Double Jump
			DoubleJump();
		}
		else if ( PawnLogic.CanDodgeJump() && bPressedJump )
		{
			// Dogde Jump
			DoubleJump();
		}

		// Process One Tap Dodge
		if( DodgeDir < DODGE_Active && OTD_DodgeDir != DODGE_None && !PawnLogic.bDodging)
		{
			if ( class'OTD_Config.PlayerPrefs'.Default.bOneTapDodge )
				DodgeMove = OTD_DodgeDir;
			OTD_DodgeDir = DODGE_None;
		}

		// Wall Dodge
		if ( PawnLogic.CanWallDodge() && DodgeMove > DODGE_None && DodgeMove < DODGE_Active )
		{
			SetPhysics(PHYS_Walking);
			Dodge(DodgeMove);
			// adds a bit of upward boost to dodge when peforming a wall dodge.
			Velocity.Z *= PawnLogic.WallDodgeUpBoostMultiplier;
		}

		// If double tap dodge is disabled (i.e. DodgeClickTime <= 0.0), DODGE_Done won't be processed at PlayerMove().
		// So we do the dodge timer management here.
		PawnLogic.ProcessDodgeTimer(DeltaTime);
		Super.ProcessMove(DeltaTime, NewAccel, DodgeMove, DeltaRot);
	}

	function Dodge(eDodgeDir DodgeMove)
	{
		PawnLogic.bDodging = True;
		Super.Dodge(DodgeMove);
	}

	function DoubleJump()
	{
		if ( PawnLogic.bCanDoubleJump )
		{
			Velocity.Z = JumpZ + PawnLogic.MultiJumpBoost;
			PlaySound(JumpSound, SLOT_Talk, 1.5, True, 1200, 1.0 );
			PlayInAir();
			SetPhysics(PHYS_Falling);
			PawnLogic.bCanDoubleJump = False;
		}
	}
}
