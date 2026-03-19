//=============================================================================
// OTD_PlayerSpawnMutator.
//=============================================================================
class OTD_PlayerSpawnMutator expands Mutator;

function PreBeginPlay()
{
	Super.PreBeginPlay();
	AddGameRules();
}

function AddGameRules()
{
	local OTD_PlayerSpawnRules GR;

	GR = Spawn(class'OTD_PlayerSpawnRules');

	if ( Level.Game.GameRules == None )
		Level.Game.GameRules = GR;
	else
		Level.Game.GameRules.AddRules(GR);
}
