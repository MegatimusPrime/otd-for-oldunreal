//=============================================================================
// OTD_ConfigWindow.
//=============================================================================
class OTD_ConfigWindow expands UMenuFramedWindow;

var localized int WindowWidth;

function Created()
{
	bStatusBar = False;
	bSizable = True;

	Super.Created();

	MinWinWidth = 200;
	MinWinHeight = 100;

	SetSizePos();
}

function SetSizePos()
{
	local float W, H;

	GetDesiredDimensions(W, H);

	if ( Root.WinHeight < 400 )
		SetSize(WindowWidth, Min(Root.WinHeight - 32, H + (LookAndFeel.FrameT.H + LookAndFeel.FrameB.H)));
	else
		SetSize(WindowWidth, Min(Root.WinHeight - 50, H + (LookAndFeel.FrameT.H + LookAndFeel.FrameB.H)));

	WinLeft = int(Root.WinWidth / 2 - WinWidth / 2);
	WinTop = int(Root.WinHeight / 2 - WinHeight / 2);
}

function ResolutionChanged(float W, float H)
{
	SetSizePos();
	Super.ResolutionChanged(W, H);
}

function Resized()
{
	if ( WinWidth != WindowWidth )
		WinWidth = WindowWidth;

	Super.Resized();
}

defaultproperties
{
	WindowWidth=300
	ClientClass=Class'OTD_Config.OTD_ConfigClientWindow'
	WindowTitle="One Tap Dodge"
}