//=============================================================================
// OTD_UPakMaleThree.
//=============================================================================
class OTD_UPakMaleThree expands UPakMaleThree config(User);

var() bool bDodgeLeft, bDodgeRight, bDodgeForward, bDodgeBack;
var float WallDodgeDistance, WallDodgeUpBoost, WallDodgeUpBoostMultiplier;

function vector GetHorizontalMoveIntent()
{
	local vector X, Y, Z;
	local vector Dir;

	GetAxes(ViewRotation, X, Y, Z);

	Dir = aForward * X + aStrafe * Y;
	Dir.Z = 0;
	if ( VSize(Dir) > 0.001 )
		Dir = Normal(Dir);
	return Dir;
}

function bool IsWallDodging()
{
	local Actor HitActor;
	local vector HitLoc, HitNorm, Dir;

	if ( !class'OTD_Config.PlayerPrefs'.Default.bWallDodge || Physics != PHYS_Falling )
		return False;

	Dir = GetHorizontalMoveIntent();
	HitActor = Trace(HitLoc, HitNorm, Location, Location + -Dir * WallDodgeDistance, True);
	return (HitActor != None && !HitActor.IsA('Pawn'));
}

state PlayerWalking
{
	exec function OmnidirectionalDodge()
	{
		if (DodgeDir >= DODGE_Active)
			return;
		if ( bIsCrouching || !class'OTD_Config.PlayerPrefs'.Default.bOneTapDodge || ( Physics != PHYS_Walking && Physics != PHYS_Falling ) )
			return;
		else
		{
			if (bWasForward)
				bDodgeForward = True;
			if (bWasBack)
				bDodgeBack = True;
			if (bWasLeft)
				bDodgeLeft = True;
			if (bWasRight)
				bDodgeRight = True;
		}
	}
	
	function PlayerMove( float DeltaTime )
	{
		local vector X,Y,Z, NewAccel;
		local EDodgeDir OldDodge;
		local eDodgeDir DodgeMove;
		local rotator OldRotation;
		local float Speed2D;
		local bool    bSaveJump;
		local name AnimGroupName;
		
		if ( Physics==PHYS_Spider )
			GetAxes(ViewRotation,X,Y,Z);
		else GetAxes(Rotation,X,Y,Z);

		aForward *= 0.4;
		aStrafe  *= 0.4;
		aLookup  *= 0.24;
		aTurn    *= 0.24;

		// Update acceleration.
		NewAccel = aForward*X + aStrafe*Y;
		if ( Physics!=PHYS_Spider )
			NewAccel.Z = 0;
		// Check for Dodge move
		if ( DodgeDir == DODGE_Active )
			DodgeMove = DODGE_Active;
		else DodgeMove = DODGE_None;
		if (DodgeClickTime > 0.0 || class'OTD_Config.PlayerPrefs'.Default.bOneTapDodge)
		{
			if ( DodgeDir < DODGE_Active )
			{
				OldDodge = DodgeDir;
				DodgeDir = DODGE_None;
				if ((bEdgeForward && bWasForward) || bDodgeForward)
					DodgeDir = DODGE_Forward;
				if ((bEdgeBack && bWasBack) || bDodgeBack)
					DodgeDir = DODGE_Back;
				if ((bEdgeLeft && bWasLeft) || bDodgeLeft)
					DodgeDir = DODGE_Left;
				if ((bEdgeRight && bWasRight) || bDodgeRight)
					DodgeDir = DODGE_Right;
				if ( DodgeDir == DODGE_None)
					DodgeDir = OldDodge;
				else if ((DodgeDir != OldDodge) && !(bDodgeForward || bDodgeBack || bDodgeLeft || bDodgeRight))
					DodgeClickTimer = DodgeClickTime + 0.5 * DeltaTime;
				else
					DodgeMove = DodgeDir;

				if ( IsWallDodging() && DodgeDir > DODGE_None && DodgeDir < DODGE_Active )
				{
					// adds a bit of upward boost to dodge when peforming a wall dodge.
					WallDodgeUpBoost = Default.WallDodgeUpBoost * Default.WallDodgeUpBoostMultiplier;
					SetPhysics(PHYS_Walking);
				}
				bDodgeForward = false;
				bDodgeBack = false;
				bDodgeLeft = false;
				bDodgeRight = false;
			}

			if (DodgeDir == DODGE_Active && Physics == PHYS_Walking)
			{
				// force dodge completion in case if PHYS_Walking was set without calling Landed
				DodgeDir = DODGE_Done;
				DodgeClickTimer = 0;
			}

			if (DodgeDir == DODGE_Done)
			{
				DodgeClickTimer -= DeltaTime;
				if (DodgeClickTimer < -0.35)
				{
					DodgeDir = DODGE_None;
					DodgeClickTimer = DodgeClickTime;
				}
			}
			else if ((DodgeDir != DODGE_None) && (DodgeDir != DODGE_Active))
			{
				DodgeClickTimer -= DeltaTime;
				if (DodgeClickTimer < 0)
				{
					DodgeDir = DODGE_None;
					DodgeClickTimer = DodgeClickTime;
				}
			}
		}

		AnimGroupName = GetAnimGroup(AnimSequence);
		if ( (Physics == PHYS_Walking) && (AnimGroupName != 'Dodge') )
		{
			//if walking, look up/down stairs - unless player is rotating view
			if ( !bKeyboardLook && (bLook == 0) )
			{
				if ( bLookUpStairs )
					ViewRotation.Pitch = FindStairRotation(deltaTime);
				else if ( bCenterView )
				{
					ViewRotation.Pitch = ViewRotation.Pitch & 65535;
					if (ViewRotation.Pitch > 32768)
						ViewRotation.Pitch -= 65536;
					ViewRotation.Pitch = ViewRotation.Pitch * (1 - 12 * FMin(0.0833, deltaTime));
					if ( Abs(ViewRotation.Pitch) < 1000 )
						ViewRotation.Pitch = 0;
				}
			}

			Speed2D = FMin(VSize2D(Velocity), GroundSpeed*1.5f);
			//add bobbing when walking
			if ( !bShowMenu )
			{
				if ( Speed2D < 10 || GroundSpeed == 0 )
					BobTime += 0.2 * DeltaTime * FClamp(Region.Zone.ZoneTimeDilation,0.1,10.f);
				else
					BobTime += DeltaTime * FClamp(Region.Zone.ZoneTimeDilation,0.1,10.f) * (0.3 + 0.7 * Speed2D/GroundSpeed);
				WalkBob = Y * 0.65 * Bob * Speed2D * sin(6.0 * BobTime);
				if ( Speed2D < 10 )
					WalkBob.Z = Bob * 30 * sin(12 * BobTime);
				else WalkBob.Z = Bob * Speed2D * sin(12 * BobTime);
			}
		}
		else if ( !bShowMenu )
		{
			BobTime = 0;
			WalkBob = WalkBob * (1 - FMin(1, 8 * deltatime));
		}

		// Update rotation.
		OldRotation = Rotation;
		UpdateRotation(DeltaTime, 1);

		if ( bPressedJump && (AnimGroupName == 'Dodge') )
		{
			bSaveJump = true;
			bPressedJump = false;
		}
		else
			bSaveJump = false;

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, NewAccel, DodgeMove, OldRotation - Rotation);
		else
			ProcessMove(DeltaTime, NewAccel, DodgeMove, OldRotation - Rotation);
		bPressedJump = bSaveJump;
	}

	function Dodge(eDodgeDir DodgeMove)
	{
		local vector X,Y,Z;
		local float OldBaseEyeHeight;

		if ( bIsCrouching || (Physics != PHYS_Walking) )
			return;

		GetAxes(Rotation,X,Y,Z);
		if (DodgeMove == DODGE_Forward)
			Velocity = 1.5*GroundSpeed*X + (Velocity Dot Y)*Y;
		else if (DodgeMove == DODGE_Back)
			Velocity = -1.5*GroundSpeed*X + (Velocity Dot Y)*Y;
		else if (DodgeMove == DODGE_Left)
			Velocity = 1.5*GroundSpeed*Y + (Velocity Dot X)*X;
		else if (DodgeMove == DODGE_Right)
			Velocity = -1.5*GroundSpeed*Y + (Velocity Dot X)*X;

		Velocity.Z = WallDodgeUpBoost;
		// make sure to reset the dodge boost to default after using it, so that it doesn't affect non-wall dodges.
		WallDodgeUpBoost = Default.WallDodgeUpBoost;
		if ( Role == ROLE_Authority )
		{
			if( IsUnrealTournamentClient() )
				PlayOwnedSound(JumpSound, SLOT_Talk, 1.0, true, 800, 1.0 );
			else PlaySound(JumpSound, SLOT_Talk, 1.0, true, 800, 1.0 );
		}
		if (bUpdatePosition)
		{
			OldBaseEyeHeight = BaseEyeHeight;
			PlayDodge(DodgeMove);
			BaseEyeHeight = OldBaseEyeHeight;
		}
		else
			PlayDodge(DodgeMove);
		DodgeDir = DODGE_Active;
		SetPhysics(PHYS_Falling);
	}
}

defaultproperties
{
	WallDodgeDistance=50.0 // how close you need to be to a wall to perform a wall dodge
	WallDodgeUpBoost=160.0 // how much upward velocity is applied when performing a wall dodge
	WallDodgeUpBoostMultiplier=1.4 // multiplier applied to the upward boost when performing a wall dodge
}
