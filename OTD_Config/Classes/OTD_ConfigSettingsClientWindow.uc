//=============================================================================
// OTD_ConfigSettingsClientWindow.
//=============================================================================
class OTD_ConfigSettingsClientWindow extends UMenuPageWindow config(User);

var UWindowCheckBox OTDCheckBox;
var UWindowCheckBox WallDodgeCheckBox;
var UWindowCheckBox AutoMagReloadCheckBox;

var float ControlOffset;

function Created()
{
	local int ControlWidth, ControlLeft, ControlRight;

	Super.Created();

	ControlWidth = WinWidth / 2.5;
	ControlLeft = (WinWidth / 2 - ControlWidth) / 2;
	ControlRight = WinWidth / 2 + ControlLeft;

	OTDCheckBox = UWindowCheckBox(CreateControl(class'UWindowCheckBox', ControlLeft, ControlOffset, ControlWidth, 1));
	OTDCheckBox.bChecked = class'OTD_Config.PlayerPrefs'.Default.bOneTapDodge;
	OTDCheckBox.SetText("One Tap Dodge");
	OTDCheckBox.SetHelpText("If enabled, you can perform a dodge with pressing the dodge key while moving in a desired direction.");
	OTDCheckBox.SetFont(F_Normal);
	OTDCheckBox.Align = TA_Right;

	WallDodgeCheckBox = UWindowCheckBox(CreateControl(class'UWindowCheckBox', ControlRight, ControlOffset, ControlWidth, 1));
	WallDodgeCheckBox.bChecked = class'OTD_Config.PlayerPrefs'.Default.bWallDodge;
	WallDodgeCheckBox.SetText("Wall Dodge");
	WallDodgeCheckBox.SetHelpText("Enable or disable wall dodging. Works with both one tap and normal dodge.");
	WallDodgeCheckBox.SetFont(F_Normal);
	WallDodgeCheckBox.Align = TA_Right;
	ControlOffset += 25;

	AutoMagReloadCheckBox = UWindowCheckBox(CreateControl(class'UWindowCheckBox', ControlLeft, ControlOffset, ControlWidth, 1));
	AutoMagReloadCheckBox.bChecked = class'OTD_Config.PlayerPrefs'.Default.bAutoMagReload;
	AutoMagReloadCheckBox.SetText("Manual AutoMag Reload");
	AutoMagReloadCheckBox.SetHelpText("Enabling this will allow you to reload AutoMag manually by pressing the reload key.");
	AutoMagReloadCheckBox.SetFont(F_Normal);
	AutoMagReloadCheckBox.Align = TA_Right;
}

function AfterCreate()
{
	DesiredWidth = 220;
	DesiredHeight = ControlOffset;
}

function BeforePaint(Canvas C, float X, float Y)
{
	local int CheckboxWidth, CheckboxLeft, CheckboxRight;

	CheckboxWidth = WinWidth / 2.5;
	CheckboxLeft = (WinWidth / 2 - CheckboxWidth) / 2;
	CheckboxRight = WinWidth / 2 + CheckboxLeft;

	OTDCheckBox.AutoWidth(C);
	OTDCheckBox.WinLeft = CheckboxLeft;

	WallDodgeCheckBox.AutoWidth(C);
	WallDodgeCheckBox.WinLeft = CheckboxRight;

	AutoMagReloadCheckBox.AutoWidth(C);
	AutoMagReloadCheckBox.WinLeft = CheckboxLeft;
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);
	switch (E)
	{
		case DE_Change:
			switch(C)
			{
				case OTDCheckBox:
					class'OTD_Config.PlayerPrefs'.Default.bOneTapDodge = OTDCheckBox.bChecked;
					class'OTD_Config.PlayerPrefs'.Static.StaticSaveConfig();
					break;
				case WallDodgeCheckBox:
					class'OTD_Config.PlayerPrefs'.Default.bWallDodge = WallDodgeCheckBox.bChecked;
					class'OTD_Config.PlayerPrefs'.Static.StaticSaveConfig();
					break;
				case AutoMagReloadCheckBox:
					class'OTD_Config.PlayerPrefs'.Default.bAutoMagReload = AutoMagReloadCheckBox.bChecked;
					class'OTD_Config.PlayerPrefs'.Static.StaticSaveConfig();
					break;

			}
	}
}

defaultproperties
{
	ControlOffset=20.0
}