//=============================================================================
// OTD_ConfigWindow.
//=============================================================================
class OTD_ConfigWindow expands UWindowFramedWindow;

function BeginPlay()
{
	Super.BeginPlay();
	WindowTitle = "OTD_ConfigClient";
	ClientClass = class'OTD_Config.OTD_ConfigClient';
	bSizable = True;
}


function Created()
{
	Super.Created();
	SetSize(260, 120);
	WinLeft = (Root.WinWidth - WinWidth) / 2;
	WinTop = (Root.WinHeight - WinHeight) / 2;
}
