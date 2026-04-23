//=============================================================================
// OTD_UPakMaleOne.
//=============================================================================
class OTD_UPakMaleOne expands UPakMaleOne config(User);

var EDodgeDir OTD_DodgeDir;
var float WallDodgeDistance, WallDodgeUpBoostMultiplier;
var OTD_PawnLogic PawnLogic;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	PawnLogic = new class'OTD_PawnLogic';
	PawnLogic.P = Self;
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
		// Normal Dodge
		if( DodgeDir < DODGE_Active && OTD_DodgeDir != DODGE_None )
		{
			if ( class'OTD_Config.PlayerPrefs'.Default.bOneTapDodge )
				DodgeMove = OTD_DodgeDir;
			OTD_DodgeDir = DODGE_None;
		}

		// Wall Dodge
		if ( PawnLogic.CanWallDodge(WallDodgeDistance) && DodgeMove > DODGE_None && DodgeMove < DODGE_Active )
		{
			SetPhysics(PHYS_Walking);
			Dodge(DodgeMove);
			// adds a bit of upward boost to dodge when peforming a wall dodge.
			Velocity.Z *= WallDodgeUpBoostMultiplier;
		}

		// If double tap dodge is disabled (i.e. DodgeClickTime <= 0.0), DODGE_Done won't be processed at PlayerMove().
		// So we do the dodge timer management here.
		PawnLogic.ProcessDodgeTimer(DeltaTime);
		Super.ProcessMove(DeltaTime, NewAccel, DodgeMove, DeltaRot);
	}
}

defaultproperties
{
	WallDodgeDistance=32.0 // how close you need to be to a wall to perform a wall dodge
	WallDodgeUpBoostMultiplier=1.5 // multiplier applied to the upward boost when performing a wall dodge
}
