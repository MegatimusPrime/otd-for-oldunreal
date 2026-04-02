//=============================================================================
// PlayerPrefs.
//=============================================================================
class PlayerPrefs expands Pawn config(User);

var() config bool bOneTapDodge, bWallDodge, bAutoMagReload;

defaultproperties
{
	bOneTapDodge=False
	bWallDodge=False
	bAutoMagReload=False
}
