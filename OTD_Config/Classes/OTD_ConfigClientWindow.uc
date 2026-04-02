//=============================================================================
// OTD_ConfigClientWindow.
//=============================================================================
class OTD_ConfigClientWindow expands UWindowDialogClientWindow;

var bool bInitialized;
var UMenuPageControl Pages;
var UWindowSmallCloseButton CloseButton;

var localized string SettingsTab, InputTab;

function Created()
{
	Super.Created();
	Pages = UMenuPageControl(CreateWindow(class'UMenuPageControl', 0, 0, WinWidth, WinHeight - 48));
	Pages.SetMultiLine(True);
	Pages.AddPage(SettingsTab, class'OTD_Config.OTD_ConfigSettingsScrollClient');
	Pages.AddPage(InputTab, class'OTD_Config.OTD_ConfigInputScrollClient');
	CloseButton = UWindowSmallCloseButton(CreateControl(class'UWindowSmallCloseButton', WinWidth - 56, WinHeight - 24, 48, 16));
	bInitialized = True;
}

function Resized()
{
	Pages.WinWidth = WinWidth;
	Pages.WinHeight = WinHeight - 24;
	CloseButton.WinTop = WinHeight - 20;
}

function AlignButtons(Canvas C)
{
	CloseButton.AutoWidth(C);
	CloseButton.WinLeft = WinWidth - CloseButton.WinWidth - 2;
}

function Paint(Canvas C, float X, float Y)
{
	local Texture T;
	T = GetLookAndFeelTexture();
	DrawUpBevel( C, 0, LookAndFeel.TabUnselectedM.H, WinWidth, WinHeight - LookAndFeel.TabUnselectedM.H, T);
	AlignButtons(C);
}

function GetDesiredDimensions(out float W, out float H)
{
	Super(UWindowWindow).GetDesiredDimensions(W, H);
	H += 30;
}

defaultproperties
{
	SettingsTab="Preferences"
	InputTab="Key Bindings"
}
