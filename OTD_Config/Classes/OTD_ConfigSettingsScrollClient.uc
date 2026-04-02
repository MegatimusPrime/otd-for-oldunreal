//=============================================================================
// OTD_ConfigSettingsScrollClient.
//=============================================================================
class OTD_ConfigSettingsScrollClient extends UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'OTD_Config.OTD_ConfigSettingsClientWindow';
	FixedAreaClass = None;
	Super.Created();
}

function bool AllowsMouseWheelScrolling()
{
	return
		UMenuCustomizeClientWindow(ClientArea) != None &&
		AppSeconds() - UMenuCustomizeClientWindow(ClientArea).MouseWheelBindingTimestamp > 0.4;
}

defaultproperties
{
}