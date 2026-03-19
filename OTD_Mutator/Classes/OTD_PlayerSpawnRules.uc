//=============================================================================
// OTD_PlayerSpawnRules.
//=============================================================================
class OTD_PlayerSpawnRules expands GameRules;

function ModifyPlayerSpawnClass(string Options, out Class<PlayerPawn> AClass)
{
	if( ClassIsChildOf( AClass, class'UPakPlayer' ) )
	{
		AClass = SwitchUPakPlayer( AClass );
	}
	else if ( ClassIsChildOf( AClass, class'Human' ) )
	{
		AClass = SwitchHumanPlayer( AClass );
	}
	else if ( AClass == Class'NaliPlayer' )
	{
		AClass = Class'OTD_PlayerPawn.OTD_NaliPlayer';
	}
	else if ( AClass == Class'SkaarjPlayer' )
	{
		AClass = Class'OTD_PlayerPawn.OTD_SkaarjPlayer';
	}
}

function class< PlayerPawn > SwitchHumanPlayer( class< PlayerPawn > SpawnClass )
{
	if( ClassIsChildOf( SpawnClass, class'Male' ) )
	{
		if( ClassIsChildOf( SpawnClass, class'MaleOne' ) )
			return class'OTD_MaleOne';
		else if( ClassIsChildOf( SpawnClass, class'MaleTwo' ) )
			return class'OTD_MaleTwo';
		else if( ClassIsChildOf( SpawnClass, class'MaleThree' ) )
			return class'OTD_MaleThree';
	}
	else if( ClassIsChildOf( SpawnClass, class'Female' ) )
	{
		if( ClassIsChildOf( SpawnClass, class'FemaleOne' ) )
			return class'OTD_FemaleOne';
		else if( ClassIsChildOf( SpawnClass, class'FemaleTwo' ) )
			return class'OTD_FemaleTwo';
	}
	else return class'OTD_MaleOne';
}

function class< PlayerPawn > SwitchUPakPlayer( class< PlayerPawn > SpawnClass )
{
	if( ClassIsChildOf( SpawnClass, class'UPakMale' ) )
	{
		if( ClassIsChildOf( SpawnClass, class'UPakMaleOne' ) )
			return class'OTD_UPakMaleOne';
		else if( ClassIsChildOf( SpawnClass, class'UPakMaleTwo' ) )
			return class'OTD_UPakMaleTwo';
		else if( ClassIsChildOf( SpawnClass, class'UPakMaleThree' ) )
			return class'OTD_UPakMaleThree';
	}
	else if( ClassIsChildOf( SpawnClass, class'UPakFemale' ) )
	{
		if( ClassIsChildOf( SpawnClass, class'UPakFemaleOne' ) )
			return class'OTD_UPakFemaleOne';
		else if( ClassIsChildOf( SpawnClass, class'UPakFemaleTwo' ) )
			return class'OTD_UPakFemaleTwo';
	}
	else return class'OTD_UPakMaleOne';
}

defaultproperties
{
	bNotifyLogin=True
}
