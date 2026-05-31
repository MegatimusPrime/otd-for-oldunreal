//=============================================================================
// PlayerPrefs.
//=============================================================================
class PlayerPrefs expands Pawn config(User);

var() config bool bOneTapDodge, bWallDodge, bDoubleJump, bAutoMagReload;

defaultproperties
{
	bOneTapDodge=False
	bWallDodge=False
	bDoubleJump=False
	bAutoMagReload=False
}
