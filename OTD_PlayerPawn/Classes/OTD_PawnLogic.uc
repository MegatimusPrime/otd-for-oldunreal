//=============================================================================
// OTD_PawnLogic.
//=============================================================================
class OTD_PawnLogic extends Object;

var PlayerPawn P;

function DoReloadAutoMag()
{
	if ( !class'OTD_Config.PlayerPrefs'.Default.bAutoMagReload )
		return;
	if ( P.bShowMenu || Len(P.Level.Pauser) > 0 || (P.Role < ROLE_Authority) || !P.CanInteractWithWorld() || (P.CarriedDecoration != None && P.CarriedDecoration.CarrierFired(P, False)) )
		return;
	if ( P.Weapon != None && ClassIsChildOf(P.Weapon.Class, class'AutoMag') && !P.Weapon.IsInState('NewClip') && !P.Weapon.IsInState('Active') )
	{
		if ( AutoMag(P.Weapon).ClipCount >= 1 && P.Weapon.AmmoType.AmmoAmount + AutoMag(P.Weapon).ClipCount > 20 )
			P.Weapon.GotoState('NewClip');
	}
}

function Actor.EDodgeDir DoOmnidirectionalDodge()
{
	local Actor.EDodgeDir OTD_DodgeDir;
	OTD_DodgeDir = DODGE_None;
	if ( P.DodgeDir >= DODGE_Active )
		return OTD_DodgeDir;
	if ( P.bIsCrouching || !class'OTD_Config.PlayerPrefs'.Default.bOneTapDodge || ( P.Physics != PHYS_Walking && P.Physics != PHYS_Falling ) )
		return OTD_DodgeDir;
	else
	{
		if ( P.bWasForward )
			OTD_DodgeDir = DODGE_Forward;
		if ( P.bWasBack )
			OTD_DodgeDir = DODGE_Back;
		if ( P.bWasLeft )
			OTD_DodgeDir = DODGE_Left;
		if ( P.bWasRight )
			OTD_DodgeDir = DODGE_Right;
		return OTD_DodgeDir;
	}
}

function vector GetHorizontalMoveIntent()
{
	local vector X, Y, Z;
	local vector Dir;

	GetAxes(P.ViewRotation, X, Y, Z);

	Dir = P.aForward * X + P.aStrafe * Y;
	Dir.Z = 0;
	if ( VSize(Dir) > 0.001 )
		Dir = Normal(Dir);
	return Dir;
}

function bool CanWallDodge(float WallDodgeDistance)
{
	local Actor HitActor;
	local vector HitLoc, HitNorm, Dir, TraceStart, TraceEnd;

	if ( !class'OTD_Config.PlayerPrefs'.Default.bWallDodge || P.Physics != PHYS_Falling )
		return False;

	Dir = GetHorizontalMoveIntent();
	TraceStart = P.Location - P.CollisionHeight * vect(0,0,1) + -Dir * P.CollisionRadius;
	TraceEnd = TraceStart + -Dir * WallDodgeDistance;
	HitActor = P.Trace(HitLoc, HitNorm, TraceEnd, TraceStart, False, vect(1,1,1));
	if ( (HitActor == None) || (!HitActor.bWorldGeometry && (Mover(HitActor) == None)) )
		return False;

	return True;
}

function ProcessDodgeTimer(float DeltaTime)
{
	if ( P.DodgeClickTime <= 0.0 )
	{
		if ( P.DodgeDir == DODGE_Active && P.Physics == PHYS_Walking )
		{
			// force dodge completion in case if PHYS_Walking was set without calling Landed
			P.DodgeDir = DODGE_Done;
			P.DodgeClickTimer = 0;
		}

		if ( P.DodgeDir == DODGE_Done )
		{
			P.DodgeClickTimer -= DeltaTime;
			if ( P.DodgeClickTimer < -0.35 )
			{
				P.DodgeDir = DODGE_None;
				P.DodgeClickTimer = P.DodgeClickTime;
			}
		}
		else if ( (P.DodgeDir != DODGE_None) && (P.DodgeDir != DODGE_Active) )
		{
			P.DodgeClickTimer -= DeltaTime;
			if ( P.DodgeClickTimer < 0 )
			{
				P.DodgeDir = DODGE_None;
				P.DodgeClickTimer = P.DodgeClickTime;
			}
		}
	}
}