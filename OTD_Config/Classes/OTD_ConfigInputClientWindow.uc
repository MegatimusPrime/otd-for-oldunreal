//=============================================================================
// OTD_ConfigInputClientWindow.
//=============================================================================
class OTD_ConfigInputClientWindow extends UMenuPageWindow;

var localized int EditAreaWidth; 
var localized string LocalizedKeyName[255];
var string RealKeyName[255];

var array<string> KeyAlias;
var UMenuRaisedButton SelectedButton;
var int Selection;
var bool bPolling, bErasing;
var localized string OrString;
var localized string CustomizeHelp;

var UWindowSmallButton DefaultsButton;
var localized string DefaultsText;
var localized string DefaultsHelp;

struct FKeyEntry
{
	var UMenuLabelControl KeyName;
	var UMenuRaisedButton KeyButton;
	var string AliasString, Desc;
	var int BoundKey1, BoundKey2;
};
var array<FKeyEntry> CustomKeys;

var bool bLoadedExisting;

var int LastKeyDown;
var float MouseWheelBindingTimestamp;

function Created()
{
	local int ButtonWidth, ButtonLeft, ButtonTop, i;
	local int LabelWidth, LabelLeft;
	local UMenuLabelControl NewLabel;
	local UMenuRaisedButton NewButton;

	bIgnoreLDoubleClick = True;
	bIgnoreMDoubleClick = True;
	bIgnoreRDoubleClick = True;

	Super.Created();

	SetAcceptsFocus();

	LabelWidth = 10;
	LabelLeft = (WinWidth - LabelWidth - EditAreaWidth) / 2;

	ButtonWidth = EditAreaWidth;
	ButtonLeft = LabelLeft + LabelWidth;

	// Defaults Button
	DefaultsButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 30, 10, 48, 16));
	DefaultsButton.SetText(DefaultsText);
	DefaultsButton.SetFont(F_Normal);
	DefaultsButton.SetHelpText(DefaultsHelp);

	ButtonTop = 35;

	for ( i = 0; i < CustomKeys.Size(); i++ )
	{
		NewLabel = UMenuLabelControl(CreateControl(class'UMenuLabelControl', LabelLeft, ButtonTop + 3, LabelWidth, 1));
		NewLabel.SetText(CustomKeys[i].Desc);
		NewLabel.SetHelpText(CustomizeHelp);
		NewLabel.SetFont(F_Normal);
		NewLabel.bNotifyMouseClicks = True;
		NewButton = UMenuRaisedButton(CreateControl(class'UMenuRaisedButton', ButtonLeft, ButtonTop, ButtonWidth, 1));
		NewButton.SetHelpText(CustomizeHelp);
		NewButton.bAcceptsFocus = False;
		NewButton.bIgnoreLDoubleClick = True;
		NewButton.bIgnoreMDoubleClick = True;
		NewButton.bIgnoreRDoubleClick = True;
		CustomKeys[i].KeyName = NewLabel;
		CustomKeys[i].KeyButton = NewButton;
		ButtonTop += 19;
	}

	DesiredWidth = 220;
	DesiredHeight = ButtonTop + 10;
}

function WindowShown()
{
	Super.WindowShown();
	LoadExistingKeys();
}

function LoadExistingKeys()
{
	local int i, j, pos;
	local string KeyName;
	local string Alias;

	for ( i = 0; i < CustomKeys.Size(); i++ )
	{
		CustomKeys[i].BoundKey1 = 0;
		CustomKeys[i].BoundKey2 = 0;
	}

	for ( i = 0; i < 255; i++ )
	{
		KeyName = GetPlayerOwner().ConsoleCommand( "KEYNAME "$i );
		RealKeyName[i] = KeyName;
		if ( KeyName != "" )
		{
			Alias = GetPlayerOwner().ConsoleCommand( "KEYBINDING "$KeyName );
			if ( Alias != "" )
			{
				pos = InStr(Alias, " ");
				if ( pos != -1 )
				{
					if ( !(Left(Alias, pos) ~= "taunt") &&
							!(Left(Alias, pos) ~= "getweapon") &&
							!(Left(Alias, pos) ~= "viewplayernum") &&
							!(Left(Alias, pos) ~= "button") &&
							!(Left(Alias, pos) ~= "mutate"))
						Alias = Left(Alias, pos);
				}
				for ( j = 0; j < CustomKeys.Size(); j++ )
				{
					if ( CustomKeys[j].AliasString ~= Alias )
					{
						if ( CustomKeys[j].BoundKey1 == 0 )
							CustomKeys[j].BoundKey1 = i;
						else if ( CustomKeys[j].BoundKey2 == 0)
							CustomKeys[j].BoundKey2 = i;
					}
				}
			}
		}
	}
	bLoadedExisting = False;
	bLoadedExisting = True;
}

function CalcLabelTextAreaWidth(Canvas C, out float LabelTextAreaWidth)
{
	local int i;
	for ( i = 0; i < CustomKeys.Size(); ++i )
		CustomKeys[i].KeyName.GetMinTextAreaWidth(C, LabelTextAreaWidth);
}

function BeforePaint(Canvas C, float X, float Y)
{
	local int ButtonWidth, ButtonLeft, i;
	local int LabelWidth, LabelHSpacing, RightSpacing;
	local float LabelTextAreaWidth;
	local string KeyStr;

	LabelTextAreaWidth = 0;
	CalcLabelTextAreaWidth(C, LabelTextAreaWidth);

	LabelHSpacing = (WinWidth - LabelTextAreaWidth - EditAreaWidth) / 3;
	RightSpacing = VScrollbarWidth() + 3;
	if ( LabelHSpacing < RightSpacing )
		LabelHSpacing = (WinWidth - LabelTextAreaWidth - EditAreaWidth - RightSpacing) / 2;
	LabelWidth = LabelTextAreaWidth + LabelHSpacing;

	ButtonWidth = EditAreaWidth;
	ButtonLeft = LabelHSpacing + LabelWidth;

	DefaultsButton.AutoWidth(C);
	DefaultsButton.WinLeft = ButtonLeft + ButtonWidth - DefaultsButton.WinWidth;

	DesiredHeight = 0;

	for( i = 0; i < CustomKeys.Size(); i++ )
	{
		CustomKeys[i].KeyButton.SetSize(ButtonWidth, 1);
		CustomKeys[i].KeyButton.WinLeft = ButtonLeft;
		KeyStr = "";

		if ( !bPolling || !bErasing || Selection != i )
		{
			if ( CustomKeys[i].BoundKey1 > 0 )
				KeyStr = LocalizedKeyName[CustomKeys[i].BoundKey1];
			else if ( CustomKeys[i].BoundKey1 < 0 )
				KeyStr = Chr(-CustomKeys[i].BoundKey1) @ "(" $ -CustomKeys[i].BoundKey1 $ ")";

			if ( CustomKeys[i].BoundKey1 != 0 && CustomKeys[i].BoundKey2 != 0 )
				KeyStr $= OrString;

			if ( CustomKeys[i].BoundKey2 > 0 )
				KeyStr $= LocalizedKeyName[CustomKeys[i].BoundKey2];
			else if ( CustomKeys[i].BoundKey2 < 0 )
				KeyStr $= Chr(-CustomKeys[i].BoundKey2) @ "(" $ -CustomKeys[i].BoundKey2 $ ")";
		}

		CustomKeys[i].KeyButton.SetText(KeyStr);

		CustomKeys[i].KeyName.SetSize(LabelWidth, 1);
		CustomKeys[i].KeyName.WinLeft = LabelHSpacing;
	}
}

function KeyDown( int Key, float X, float Y )
{
	if ( bPolling )
	{
		LastKeyDown = Key;
		ProcessMenuKey(Key, RealKeyName[Key]);
	}
}

function KeyType(int Key, float X, float Y)
{
	if ( !bPolling )
		return;
}

function KeyUp(int Key, float X, float Y)
{
	CancelKeySelection();
}

final function RemoveExistingKey(int KeyNo, string KeyName)
{
	local int i;

	if ( bErasing )
		UnbindSelectedItem();

	for ( i = 0; i < CustomKeys.Size(); i++ )
	{
		if ( CustomKeys[i].BoundKey2 == KeyNo )
			CustomKeys[i].BoundKey2 = 0;

		if ( CustomKeys[i].BoundKey1 == KeyNo )
		{
			CustomKeys[i].BoundKey1 = CustomKeys[i].BoundKey2;
			CustomKeys[i].BoundKey2 = 0;
		}
	}
}

function SetKey(int KeyNo, string KeyName)
{
	if ( CustomKeys[Selection].BoundKey1 != 0 )
	{
		// if this key is already chosen, just clear out other slot
		if ( KeyNo == CustomKeys[Selection].BoundKey1 )
		{
			// if 2 exists, remove it it.
			if ( CustomKeys[Selection].BoundKey2 != 0 )
			{
				GetPlayerOwner().ConsoleCommand("SET Input "$RealKeyName[CustomKeys[Selection].BoundKey2]);
				CustomKeys[Selection].BoundKey2 = 0;
			}
		}
		else if (KeyNo == CustomKeys[Selection].BoundKey2)
		{
			// Remove slot 1
			GetPlayerOwner().ConsoleCommand("SET Input "$RealKeyName[CustomKeys[Selection].BoundKey1]);
			CustomKeys[Selection].BoundKey1 = CustomKeys[Selection].BoundKey2;
			CustomKeys[Selection].BoundKey2 = 0;
		}
		else
		{
			// Clear out old slot 2 if it exists
			if ( CustomKeys[Selection].BoundKey2 != 0 )
			{
				GetPlayerOwner().ConsoleCommand("SET Input "$RealKeyName[CustomKeys[Selection].BoundKey2]);
				CustomKeys[Selection].BoundKey2 = 0;
			}
			// move key 1 to key 2, and set ourselves in 1.
			CustomKeys[Selection].BoundKey2 = CustomKeys[Selection].BoundKey1;
			CustomKeys[Selection].BoundKey1 = KeyNo;
			GetPlayerOwner().ConsoleCommand("SET Input"@KeyName@CustomKeys[Selection].AliasString);
		}
	}
	else
	{
		CustomKeys[Selection].BoundKey1 = KeyNo;
		GetPlayerOwner().ConsoleCommand("SET Input"@KeyName@CustomKeys[Selection].AliasString);
	}
}

function ProcessMenuKey(int KeyNo, string KeyName)
{
	if ( Len(KeyName) == 0 || KeyName ~= "Escape" )
		return;

	if ( KeyNo == IK_MouseWheelUp || KeyNo == IK_MouseWheelDown )
		MouseWheelBindingTimestamp = AppSeconds();

	if ( Root == None || Root.Console == None || KeyNo != Root.Console.GlobalConsoleKey )
	{
		RemoveExistingKey(KeyNo, KeyName);
		SetKey(KeyNo, KeyName);
	}
	CancelKeySelection();
}

function Notify(UWindowDialogControl C, byte E)
{
	local int i;

	Super.Notify(C, E);

	if ( C == DefaultsButton && E == DE_Click )
	{
		for ( i = 0; i < CustomKeys.Size(); i++ )
		{
			if ( CustomKeys[i].BoundKey1 != 0 )
				GetPlayerOwner().ConsoleCommand("SET Input "$RealKeyName[CustomKeys[i].BoundKey1]);
			if ( CustomKeys[i].BoundKey2 != 0 )
				GetPlayerOwner().ConsoleCommand("SET Input "$RealKeyName[CustomKeys[i].BoundKey2]);
			CustomKeys[i].BoundKey1 = 0;
			CustomKeys[i].BoundKey2 = 0;
		}
		LoadExistingKeys();
		return;
	}

	switch (E)
	{
		case DE_Click:
			if ( bPolling ) 
			{
				CancelKeySelection();
				if ( C == SelectedButton )
				{
					ProcessMenuKey(1, RealKeyName[1]);
					return;
				}
			}
			if ( UMenuRaisedButton(C) != None )
			{
				SelectedButton = UMenuRaisedButton(C);
				Selection = -1;
				for ( i = 0; i < CustomKeys.Size(); i++ )
				{
					if ( CustomKeys[i].KeyButton == C )
					{
						Selection = i;
						break;
					}
				}
				bPolling = True;
				bErasing = False;
				SelectedButton.bDisabled = True;
				if ( Root != None )
					Root.bAllowConsole = False;
			}
			else if (bPolling)
				CancelKeySelection();
			break;

		case DE_RClick:
			if ( bPolling )
			{
				CancelKeySelection();
				if ( C == SelectedButton )
				{
					ProcessMenuKey(2, RealKeyName[2]);
					return;
				}
			}
			if ( UMenuRaisedButton(C) != None )
			{
				SelectedButton = UMenuRaisedButton(C);
				Selection = -1;
				for ( i = 0; i < CustomKeys.Size(); i++ )
				{
					if ( CustomKeys[i].KeyButton == C )
					{
						Selection = i;
						break;
					}
				}
				bPolling = True;
				bErasing = True;
				SelectedButton.bDisabled = True;
				if ( Root != None )
					Root.bAllowConsole = False;
			}
			break;

		case DE_MClick:
			if ( bPolling )
			{
				CancelKeySelection();
				if ( C == SelectedButton )
				{
					ProcessMenuKey(4, RealKeyName[4]);
					return;
				}
			}
			break;
	}
}

function Click(float X, float Y)
{
	Super.Click(X, Y);
	if ( bPolling )
		CancelKeySelection();
}

function CancelKeySelection(optional bool bEscape)
{
	bPolling = False;
	if ( bEscape )
		bErasing = False;
	else if (bErasing)
		UnbindSelectedItem();
	if ( SelectedButton != None )
		SelectedButton.bDisabled = False;
	if ( Root != None )
		Root.bAllowConsole = True;
}

function UnbindSelectedItem()
{
	local int i, pos;
	local string KeyName, Alias;

	bErasing = False;

	if ( Selection < 0 )
		return;

	for ( i = 1; i < 255; ++i )
	{
		KeyName = GetPlayerOwner().ConsoleCommand("KEYNAME" @ i);
		if ( Len(KeyName) > 0 )
		{
			Alias = GetPlayerOwner().ConsoleCommand("KEYBINDING" @ KeyName);
			if ( Len(Alias) > 0 )
			{
				pos = InStr(Alias, " ");
				if ( pos >= 0 )
				{
					if ( !(Left(Alias, pos) ~= "taunt") &&
						!(Left(Alias, pos) ~= "getweapon") &&
						!(Left(Alias, pos) ~= "viewplayernum") &&
						!(Left(Alias, pos) ~= "button") &&
						!(Left(Alias, pos) ~= "mutate"))
					{
						Alias = Left(Alias, pos);
					}
				}
				if ( CustomKeys[Selection].AliasString ~= Alias )
					GetPlayerOwner().ConsoleCommand("SET Input" @ KeyName);
			}
		}
	}
	CustomKeys[Selection].BoundKey1 = 0;
	CustomKeys[Selection].BoundKey2 = 0;
}

function GetDesiredDimensions(out float W, out float H)
{
	Super.GetDesiredDimensions(W, H);
	H = 100;
}

function Close(optional bool bByParent)
{
	CancelKeySelection();
	Super.Close(bByParent);
}

function EscClosing()
{
	if ( bPolling )
	{
		CancelKeySelection(True);
		if ( Root != None )
			Root.bHandledWindowEvent = True;
	}
	else
		Super.EscClosing();
}

defaultproperties
{
	EditAreaWidth=155
	LocalizedKeyName(1)="LeftMouse"
	LocalizedKeyName(2)="RightMouse"
	LocalizedKeyName(3)="Cancel"
	LocalizedKeyName(4)="MiddleMouse"
	LocalizedKeyName(5)="Unknown05"
	LocalizedKeyName(6)="Unknown06"
	LocalizedKeyName(7)="Unknown07"
	LocalizedKeyName(8)="Backspace"
	LocalizedKeyName(9)="Tab"
	LocalizedKeyName(10)="Unknown0A"
	LocalizedKeyName(11)="Unknown0B"
	LocalizedKeyName(12)="Unknown0C"
	LocalizedKeyName(13)="Enter"
	LocalizedKeyName(14)="Unknown0E"
	LocalizedKeyName(15)="Unknown0F"
	LocalizedKeyName(16)="Shift"
	LocalizedKeyName(17)="Ctrl"
	LocalizedKeyName(18)="Alt"
	LocalizedKeyName(19)="Pause"
	LocalizedKeyName(20)="CapsLock"
	LocalizedKeyName(21)="Mouse 4"
	LocalizedKeyName(22)="Mouse 5"
	LocalizedKeyName(23)="Mouse 6"
	LocalizedKeyName(24)="Mouse 7"
	LocalizedKeyName(25)="Mouse 8"
	LocalizedKeyName(26)="Unknown1A"
	LocalizedKeyName(27)="Escape"
	LocalizedKeyName(28)="Unknown1C"
	LocalizedKeyName(29)="Unknown1D"
	LocalizedKeyName(30)="Unknown1E"
	LocalizedKeyName(31)="Unknown1F"
	LocalizedKeyName(32)="Space"
	LocalizedKeyName(33)="PageUp"
	LocalizedKeyName(34)="PageDown"
	LocalizedKeyName(35)="End"
	LocalizedKeyName(36)="Home"
	LocalizedKeyName(37)="Left"
	LocalizedKeyName(38)="Up"
	LocalizedKeyName(39)="Right"
	LocalizedKeyName(40)="Down"
	LocalizedKeyName(41)="Select"
	LocalizedKeyName(42)="Print"
	LocalizedKeyName(43)="Execute"
	LocalizedKeyName(44)="PrintScrn"
	LocalizedKeyName(45)="Insert"
	LocalizedKeyName(46)="Delete"
	LocalizedKeyName(47)="Help"
	LocalizedKeyName(48)="0"
	LocalizedKeyName(49)="1"
	LocalizedKeyName(50)="2"
	LocalizedKeyName(51)="3"
	LocalizedKeyName(52)="4"
	LocalizedKeyName(53)="5"
	LocalizedKeyName(54)="6"
	LocalizedKeyName(55)="7"
	LocalizedKeyName(56)="8"
	LocalizedKeyName(57)="9"
	LocalizedKeyName(58)="Unknown3A"
	LocalizedKeyName(59)="Unknown3B"
	LocalizedKeyName(60)="Unknown3C"
	LocalizedKeyName(61)="Unknown3D"
	LocalizedKeyName(62)="Unknown3E"
	LocalizedKeyName(63)="Unknown3F"
	LocalizedKeyName(64)="Unknown40"
	LocalizedKeyName(65)="A"
	LocalizedKeyName(66)="B"
	LocalizedKeyName(67)="C"
	LocalizedKeyName(68)="D"
	LocalizedKeyName(69)="E"
	LocalizedKeyName(70)="F"
	LocalizedKeyName(71)="G"
	LocalizedKeyName(72)="H"
	LocalizedKeyName(73)="I"
	LocalizedKeyName(74)="J"
	LocalizedKeyName(75)="K"
	LocalizedKeyName(76)="L"
	LocalizedKeyName(77)="M"
	LocalizedKeyName(78)="N"
	LocalizedKeyName(79)="O"
	LocalizedKeyName(80)="P"
	LocalizedKeyName(81)="Q"
	LocalizedKeyName(82)="R"
	LocalizedKeyName(83)="S"
	LocalizedKeyName(84)="T"
	LocalizedKeyName(85)="U"
	LocalizedKeyName(86)="V"
	LocalizedKeyName(87)="W"
	LocalizedKeyName(88)="X"
	LocalizedKeyName(89)="Y"
	LocalizedKeyName(90)="Z"
	LocalizedKeyName(91)="Unknown5B"
	LocalizedKeyName(92)="Unknown5C"
	LocalizedKeyName(93)="Unknown5D"
	LocalizedKeyName(94)="Unknown5E"
	LocalizedKeyName(95)="Unknown5F"
	LocalizedKeyName(96)="NumPad0"
	LocalizedKeyName(97)="NumPad1"
	LocalizedKeyName(98)="NumPad2"
	LocalizedKeyName(99)="NumPad3"
	LocalizedKeyName(100)="NumPad4"
	LocalizedKeyName(101)="NumPad5"
	LocalizedKeyName(102)="NumPad6"
	LocalizedKeyName(103)="NumPad7"
	LocalizedKeyName(104)="NumPad8"
	LocalizedKeyName(105)="NumPad9"
	LocalizedKeyName(106)="GreyStar"
	LocalizedKeyName(107)="GreyPlus"
	LocalizedKeyName(108)="Separator"
	LocalizedKeyName(109)="GreyMinus"
	LocalizedKeyName(110)="NumPadPeriod"
	LocalizedKeyName(111)="GreySlash"
	LocalizedKeyName(112)="F1"
	LocalizedKeyName(113)="F2"
	LocalizedKeyName(114)="F3"
	LocalizedKeyName(115)="F4"
	LocalizedKeyName(116)="F5"
	LocalizedKeyName(117)="F6"
	LocalizedKeyName(118)="F7"
	LocalizedKeyName(119)="F8"
	LocalizedKeyName(120)="F9"
	LocalizedKeyName(121)="F10"
	LocalizedKeyName(122)="F11"
	LocalizedKeyName(123)="F12"
	LocalizedKeyName(124)="F13"
	LocalizedKeyName(125)="F14"
	LocalizedKeyName(126)="F15"
	LocalizedKeyName(127)="F16"
	LocalizedKeyName(128)="F17"
	LocalizedKeyName(129)="F18"
	LocalizedKeyName(130)="F19"
	LocalizedKeyName(131)="F20"
	LocalizedKeyName(132)="F21"
	LocalizedKeyName(133)="F22"
	LocalizedKeyName(134)="F23"
	LocalizedKeyName(135)="F24"
	LocalizedKeyName(136)="Unknown88"
	LocalizedKeyName(137)="Unknown89"
	LocalizedKeyName(138)="Unknown8A"
	LocalizedKeyName(139)="Unknown8B"
	LocalizedKeyName(140)="Unknown8C"
	LocalizedKeyName(141)="Unknown8D"
	LocalizedKeyName(142)="Unknown8E"
	LocalizedKeyName(143)="Unknown8F"
	LocalizedKeyName(144)="NumLock"
	LocalizedKeyName(145)="ScrollLock"
	LocalizedKeyName(146)="Unknown92"
	LocalizedKeyName(147)="Unknown93"
	LocalizedKeyName(148)="Unknown94"
	LocalizedKeyName(149)="Unknown95"
	LocalizedKeyName(150)="Unknown96"
	LocalizedKeyName(151)="Unknown97"
	LocalizedKeyName(152)="Unknown98"
	LocalizedKeyName(153)="Unknown99"
	LocalizedKeyName(154)="Unknown9A"
	LocalizedKeyName(155)="Unknown9B"
	LocalizedKeyName(156)="Unknown9C"
	LocalizedKeyName(157)="Unknown9D"
	LocalizedKeyName(158)="Unknown9E"
	LocalizedKeyName(159)="Unknown9F"
	LocalizedKeyName(160)="LShift"
	LocalizedKeyName(161)="RShift"
	LocalizedKeyName(162)="LControl"
	LocalizedKeyName(163)="RControl"
	LocalizedKeyName(164)="UnknownA4"
	LocalizedKeyName(165)="UnknownA5"
	LocalizedKeyName(166)="UnknownA6"
	LocalizedKeyName(167)="UnknownA7"
	LocalizedKeyName(168)="UnknownA8"
	LocalizedKeyName(169)="UnknownA9"
	LocalizedKeyName(170)="UnknownAA"
	LocalizedKeyName(171)="UnknownAB"
	LocalizedKeyName(172)="UnknownAC"
	LocalizedKeyName(173)="UnknownAD"
	LocalizedKeyName(174)="UnknownAE"
	LocalizedKeyName(175)="UnknownAF"
	LocalizedKeyName(176)="UnknownB0"
	LocalizedKeyName(177)="UnknownB1"
	LocalizedKeyName(178)="UnknownB2"
	LocalizedKeyName(179)="UnknownB3"
	LocalizedKeyName(180)="UnknownB4"
	LocalizedKeyName(181)="UnknownB5"
	LocalizedKeyName(182)="UnknownB6"
	LocalizedKeyName(183)="UnknownB7"
	LocalizedKeyName(184)="UnknownB8"
	LocalizedKeyName(185)="UnknownB9"
	LocalizedKeyName(186)="Semicolon"
	LocalizedKeyName(187)="Equals"
	LocalizedKeyName(188)="Comma"
	LocalizedKeyName(189)="Minus"
	LocalizedKeyName(190)="Period"
	LocalizedKeyName(191)="Slash"
	LocalizedKeyName(192)="Tilde"
	LocalizedKeyName(193)="UnknownC1"
	LocalizedKeyName(194)="UnknownC2"
	LocalizedKeyName(195)="UnknownC3"
	LocalizedKeyName(196)="UnknownC4"
	LocalizedKeyName(197)="UnknownC5"
	LocalizedKeyName(198)="UnknownC6"
	LocalizedKeyName(199)="UnknownC7"
	LocalizedKeyName(200)="Joy1"
	LocalizedKeyName(201)="Joy2"
	LocalizedKeyName(202)="Joy3"
	LocalizedKeyName(203)="Joy4"
	LocalizedKeyName(204)="Joy5"
	LocalizedKeyName(205)="Joy6"
	LocalizedKeyName(206)="Joy7"
	LocalizedKeyName(207)="Joy8"
	LocalizedKeyName(208)="Joy9"
	LocalizedKeyName(209)="Joy10"
	LocalizedKeyName(210)="Joy11"
	LocalizedKeyName(211)="Joy12"
	LocalizedKeyName(212)="Joy13"
	LocalizedKeyName(213)="Joy14"
	LocalizedKeyName(214)="Joy15"
	LocalizedKeyName(215)="Joy16"
	LocalizedKeyName(216)="UnknownD8"
	LocalizedKeyName(217)="UnknownD9"
	LocalizedKeyName(218)="UnknownDA"
	LocalizedKeyName(219)="LeftBracket"
	LocalizedKeyName(220)="Backslash"
	LocalizedKeyName(221)="RightBracket"
	LocalizedKeyName(222)="SingleQuote"
	LocalizedKeyName(223)="UnknownDF"
	LocalizedKeyName(224)="JoyX"
	LocalizedKeyName(225)="JoyY"
	LocalizedKeyName(226)="JoyZ"
	LocalizedKeyName(227)="JoyR"
	LocalizedKeyName(228)="MouseX"
	LocalizedKeyName(229)="MouseY"
	LocalizedKeyName(230)="MouseZ"
	LocalizedKeyName(231)="MouseW"
	LocalizedKeyName(232)="JoyU"
	LocalizedKeyName(233)="JoyV"
	LocalizedKeyName(234)="UnknownEA"
	LocalizedKeyName(235)="UnknownEB"
	LocalizedKeyName(236)="MouseWheelUp"
	LocalizedKeyName(237)="MouseWheelDown"
	LocalizedKeyName(238)="Unknown10E"
	LocalizedKeyName(239)="Unknown10F"
	LocalizedKeyName(240)="JoyPovUp"
	LocalizedKeyName(241)="JoyPovDown"
	LocalizedKeyName(242)="JoyPovLeft"
	LocalizedKeyName(243)="JoyPovRight"
	LocalizedKeyName(244)="UnknownF4"
	LocalizedKeyName(245)="UnknownF5"
	LocalizedKeyName(246)="Attn"
	LocalizedKeyName(247)="CrSel"
	LocalizedKeyName(248)="ExSel"
	LocalizedKeyName(249)="ErEof"
	LocalizedKeyName(250)="Play"
	LocalizedKeyName(251)="Zoom"
	LocalizedKeyName(252)="NoName"
	LocalizedKeyName(253)="PA1"
	LocalizedKeyName(254)="OEMClear"
	OrString=" or "
	CustomizeHelp="Click the blue rectangle and then press the key to bind to this control."
	DefaultsText="Clear All"
	DefaultsHelp="Clear all key bindings."
	CustomKeys(0)=(AliasString="OmnidirectionalDodge",Desc="Dodge")
	CustomKeys(1)=(AliasString="ReloadAutoMag",Desc="Reload AutoMag")
}