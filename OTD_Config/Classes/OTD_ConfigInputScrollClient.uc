//=============================================================================
// OTD_ConfigInputScrollClient.
//=============================================================================
class OTD_ConfigInputScrollClient extends UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'OTD_Config.OTD_ConfigInputClientWindow';
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