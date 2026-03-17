//=============================================================================
// OTD_ConfigClient.
//=============================================================================
class OTD_ConfigClient expands UWindowDialogClientWindow config(User);

//Variable Declarations
var localized string LocalizedKeyName[255]; 
var string RealKeyName[255]; 
var UMenuLabelControl BindLabel; 
var UMenuRaisedButton BindButton;
var UMenuRaisedButton SelectedButton;
var UWindowSmallCloseButton CloseButton;
var bool bPolling; 
var int binding1,binding2;
var string label;//used to set bindings
var string CustomizeHelp;
var UWindowCheckBox OTDCheckBox;//used to determine dodge method
var UWindowCheckBox WallDodgeCheckBox;
var bool bLoadedExisting;

function DisallowDialogFocus()
{
	OTDCheckBox.CancelAcceptsFocus();
	WallDodgeCheckBox.CancelAcceptsFocus();
}

function AllowDialogFocus()
{
	OTDCheckBox.SetAcceptsFocus();
	WallDodgeCheckBox.SetAcceptsFocus();
}

function Created()
{
	local int ControlOffset, checkboxoffset;
	local int ButtonWidth, ButtonLeft;
	local int LabelWidth, LabelLeft;

	SetDefaultProperties();

	Super.Created();

	SetAcceptsFocus(); /* This tells us that we respond to Keys being pressed */
	
	ButtonWidth = 160;
	ButtonLeft = 100;

	LabelWidth = 200;
	LabelLeft = 5;

	ControlOffset = 10;

	BindLabel = UMenuLabelControl(CreateControl( class'UMenuLabelControl', LabelLeft, ControlOffset + 3, LabelWidth, 1));
	/* This creates a text box to describe what key this box binds */
	BindLabel.SetText("One Tap Dodge");
	//BindLabel.SetHelpText(CustomizeHelp);
	BindLabel.SetFont(F_Normal);
	BindButton = UMenuRaisedButton(CreateControl(class'UMenuRaisedButton', ButtonLeft, ControlOffset, ButtonWidth, 1));
	/* This is the button that will display what keys have been bound */
	//BindButton.SetHelpText(CustomizeHelp);
	BindButton.bAcceptsFocus = False;
	/* This tells the button that it will not respond to keyboard commands */
	BindButton.bIgnoreLDoubleClick = True;
	BindButton.bIgnoreMDoubleClick = True;
	BindButton.bIgnoreRDoubleClick = True;
	ControlOffset+=21;

	/* This just makes sure that it doesn't steal our focus from the keyboard */
	LoadExistingKeys();

	checkboxoffset = ControlOffset + 0;
	DesiredWidth = 220;

	OTDCheckBox = UWindowCheckBox(CreateControl(class'UWindowCheckBox', 20, CheckBoxOffset, 200, 1));
	OTDCheckBox.bChecked = class'OTD_Config.PlayerPrefs'.Default.bOneTapDodge;
	OTDCheckBox.SetText("Enable One Tap Dodge");
	OTDCheckBox.SetFont(F_Normal);
	OTDCheckBox.Align = TA_Left;
	ControlOffset += 20;

	checkboxoffset = ControlOffset + 0;

	WallDodgeCheckBox = UWindowCheckBox(CreateControl(class'UWindowCheckBox', 20, CheckBoxOffset, 200, 1));
	WallDodgeCheckBox.bChecked = class'OTD_Config.PlayerPrefs'.Default.bWallDodge;
	WallDodgeCheckBox.SetText("Enable Wall Dodge");
	WallDodgeCheckBox.SetFont(F_Normal);
	WallDodgeCheckBox.Align = TA_Left;
	ControlOffset += 20;

	CloseButton = UWindowSmallCloseButton(CreateControl(class'UWindowSmallCloseButton', WinWidth - 56, WinHeight - 24, 48, 16));
}

function LoadExistingKeys() //This function loads up all key previously bound
{

	local int I;
	local string KeyName;

	binding1 = 0; //Reset the binding window
	binding2 = 0; //

	for ( I = 0; I < 255; I++ )
	{
		KeyName = GetPlayerOwner().ConsoleCommand( "KEYNAME "$i ); //Check the name of the key
		RealKeyName[i] = KeyName; //Store the name
		if ( KeyName != "" ) //If its not null
		{
			if ( GetPlayerOwner().ConsoleCommand( "KEYBINDING "$KeyName ) == Label )
			{ 
				//If the key is bound to a dodge key
				if ( binding1 == 0 ) //If binding 1 is null
					binding1 = I; //This key is now the first binding
				else if ( binding2 == 0 ) //Otherwise, if binding 2 is null
					binding2 = I; //Then this is the second binding
			}
		}
	}

	bLoadedExisting = True; //Notify the game that we've loaded all the keys
}

function BeforePaint(Canvas C, float X, float Y)
{
	local int ButtonWidth, ButtonLeft;
	local int LabelWidth, LabelLeft;

	ButtonWidth = WinWidth - 155;
	ButtonLeft = WinWidth - ButtonWidth - 20;

	LabelWidth = WinWidth - 100;
	LabelLeft = 20;

	BindButton.SetSize(ButtonWidth, 1);
	BindButton.WinLeft = ButtonLeft;

	BindLabel.SetSize(LabelWidth, 1);
	BindLabel.WinLeft = LabelLeft;

	CloseButton.WinLeft = WinWidth - 56;

	if ( binding1 == 0 ) //If binding 1 is null
		BindButton.SetText(""); //Set the button's text to nothing
	else
		if ( binding2 == 0 ) //if binding 2 is null, but binding one isn't
			BindButton.SetText(LocalizedKeyName[Binding1]); //Set the button's text to binding 1's name
		else //Otherwise, they must both be used so,
			BindButton.SetText(LocalizedKeyName[Binding1]$" or "$LocalizedKeyName[Binding2]); //Set the button's text to both
}

function KeyDown( int Key, float X, float Y ) //Called when keys are pressed only if the keyboard focus is on this particular window
{
	if ( bPolling ) //If we're checking for input
	{
		ProcessMenuKey(Key, RealKeyName[Key]); //Process this key
		bPolling = False; //We are no longer waiting for input
		SelectedButton.bDisabled = False; //Tell the button to pop up again
	}
}

function SetKey(int KeyNo, string KeyName) //A special internal function used specifically by this script, to assign keys
{

	if ( Binding1 != 0 ) //If binding 1 is not null
	{

		if ( KeyNo == Binding1 ) //If the new key is the same as binding 1
		{
			if ( Binding2 != 0 ) //if binding 2 is not null
			{
				GetPlayerOwner().ConsoleCommand("SET Input "$RealKeyName[Binding2]);//unbind
				Binding2 = 0; //Set binding 2 to its null state
			}
		} 
		else if ( KeyNo == Binding2 ) 
		{
			//if the key is the same as binding 2
			GetPlayerOwner().ConsoleCommand("SET Input "$RealKeyName[Binding1]); //unbind
			binding1 = Binding2; //binding 1 is now binding 2
			binding2 = 0; //binding 2 is now null
		} 	
		else 
		{
			//Otherwise
			if ( Binding2 != 0 ) //if binding 2 is not null
			{
				GetPlayerOwner().ConsoleCommand("SET Input "$RealKeyName[Binding2]);//unbind
				Binding2 = 0; //Make binding 2 null
			}
			Binding2 = Binding1; //Binding 2 is now Binding 1
			Binding1 = KeyNo; //Binding 1 is now the key pressed
			GetPlayerOwner().ConsoleCommand("SET Input "@KeyName@Label); //bind
		}
	}
	else 
	{
		//Otherwise
		Binding1 = KeyNo; //Binding 1 is now the key pressed
		GetPlayerOwner().ConsoleCommand("SET Input "@KeyName@Label); //bind
	}
}

function ProcessMenuKey( int KeyNo, string KeyName)
{
	if ( (KeyName == "") || (KeyName == "Escape") 
			|| ((KeyNo >= 0x70 ) && (KeyNo <= 0x79)) // function keys
			|| ((KeyNo >= 0x30 ) && (KeyNo <= 0x39)) ) // number keys
	/* This checks to make sure the key is a valid selection */
		return;

	RemoveExistingKey(KeyNo, KeyName); //Remove the old keys
	SetKey(KeyNo, KeyName); //Bind the new ones
}

function Notify(UWindowDialogControl C, byte E) //Called when something happens to one of the controls
{
	Super.Notify(C, E); //Do the stuff in our parent Class's script

	switch(E) //Check all options for E
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
			}
		case DE_Click: //If it was clicked on
			if ( bPolling ) //And we're polling
			{
				bPolling = False; //Leave polling mode
				SelectedButton.bDisabled = False; //Make the button pop back up
				ProcessMenuKey(1, RealKeyName[1]); //Process the menu key
				return; //Return
				AllowDialogFocus();
			}

			if ( UMenuRaisedButton(C) != None )
			{
				SelectedButton = UMenuRaisedButton(C);
				bPolling = True;
				SelectedButton.bDisabled = True;
				DisallowDialogFocus();
			}
			break;
		case DE_RClick: //If it was a right click
			if ( bPolling ) //And we're polling
			{
				bPolling = False; //Leave polling mode
				selectedbutton.bDisabled = False; //Make the button pop back up
				ProcessMenuKey(2, RealKeyName[2]);//Bind rightmouse to dodgekey
				return; //leave
				AllowDialogFocus();
			}
			break; //leave the switch block
		case DE_MClick:
			if ( bPolling ) //If we're polling
			{

				bPolling = False; //leave polling mode
				SelectedButton.bDisabled = False; //pop the button back up
				ProcessMenuKey(4, RealKeyName[4]); //bind it to the middle mouse
				return;
				AllowDialogFocus();
			}
			break; //leave notify block
	}
	if ( E == DE_MouseMove )
	{
		if ( UMenuRootWindow(Root) != None )
			if ( UMenuRootWindow(Root).StatusBar != None )
				UMenuRootWindow(Root).StatusBar.SetHelp(C.HelpText);		
	}

	if ( E == DE_HelpChanged && C.MouseIsOver() )
	{
		if ( UMenuRootWindow(Root) != None )
			if ( UMenuRootWindow(Root).StatusBar != None )
				UMenuRootWindow(Root).StatusBar.SetHelp(C.HelpText);		
	}

	if ( E == DE_MouseLeave )
	{
		if ( UMenuRootWindow(Root) != None )
			if ( UMenuRootWindow(Root).StatusBar != None )
				UMenuRootWindow(Root).StatusBar.SetHelp("");		
	}
}

function RemoveExistingKey(int KeyNo, string KeyName) //Removes a key
{
	if ( Binding2 == KeyNo ) //If binding 2 is the same as the key pressed
		Binding2 = 0; //remove it

	if ( Binding1 == KeyNo ) 
	{
		//if binding 1 is the same as the key pressed
		Binding1 = Binding2; //cycle binding 1 is now binding 2
		Binding2 = 0; //binding 2 is now null
	}
}

//These are the names for all the keys
function SetDefaultProperties()
{
	LocalizedKeyName[1] = "LeftMouse";
	LocalizedKeyName[2] = "RightMouse";
	LocalizedKeyName[3] = "Cancel";
	LocalizedKeyName[4] = "MiddleMouse";
	LocalizedKeyName[5] = "Unknown05";
	LocalizedKeyName[6] = "Unknown06";
	LocalizedKeyName[7] = "Unknown07";
	LocalizedKeyName[8] = "Backspace";
	LocalizedKeyName[9] = "Tab";
	LocalizedKeyName[10] = "Unknown0A";
	LocalizedKeyName[11] = "Unknown0B";
	LocalizedKeyName[12] = "Unknown0C";
	LocalizedKeyName[13] = "Enter";
	LocalizedKeyName[14] = "Unknown0E";
	LocalizedKeyName[15] = "Unknown0F";
	LocalizedKeyName[16] = "Shift";
	LocalizedKeyName[17] = "Ctrl";
	LocalizedKeyName[18] = "Alt";
	LocalizedKeyName[19] = "Pause";
	LocalizedKeyName[20] = "CapsLock";
	LocalizedKeyName[21] = "Unknown15";
	LocalizedKeyName[22] = "Unknown16";
	LocalizedKeyName[23] = "Unknown17";
	LocalizedKeyName[24] = "Unknown18";
	LocalizedKeyName[25] = "Unknown19";
	LocalizedKeyName[26] = "Unknown1A";
	LocalizedKeyName[27] = "Escape";
	LocalizedKeyName[28] = "Unknown1C";
	LocalizedKeyName[29] = "Unknown1D";
	LocalizedKeyName[30] = "Unknown1E";
	LocalizedKeyName[31] = "Unknown1F";
	LocalizedKeyName[32] = "Space";
	LocalizedKeyName[33] = "PageUp";
	LocalizedKeyName[34] = "PageDown";
	LocalizedKeyName[35] = "End";
	LocalizedKeyName[36] = "Home";
	LocalizedKeyName[37] = "Left";
	LocalizedKeyName[38] = "Up";
	LocalizedKeyName[39] = "Right";
	LocalizedKeyName[40] = "Down";
	LocalizedKeyName[41] = "Select";
	LocalizedKeyName[42] = "Print";
	LocalizedKeyName[43] = "Execute";
	LocalizedKeyName[44] = "PrintScrn";
	LocalizedKeyName[45] = "Insert";
	LocalizedKeyName[46] = "Delete";
	LocalizedKeyName[47] = "Help";
	LocalizedKeyName[48] = "0";
	LocalizedKeyName[49] = "1";
	LocalizedKeyName[50] = "2";
	LocalizedKeyName[51] = "3";
	LocalizedKeyName[52] = "4";
	LocalizedKeyName[53] = "5";
	LocalizedKeyName[54] = "6";
	LocalizedKeyName[55] = "7";
	LocalizedKeyName[56] = "8";
	LocalizedKeyName[57] = "9";
	LocalizedKeyName[58] = "Unknown3A";
	LocalizedKeyName[59] = "Unknown3B";
	LocalizedKeyName[60] = "Unknown3C";
	LocalizedKeyName[61] = "Unknown3D";
	LocalizedKeyName[62] = "Unknown3E";
	LocalizedKeyName[63] = "Unknown3F";
	LocalizedKeyName[64] = "Unknown40";
	LocalizedKeyName[65] = "A";
	LocalizedKeyName[66] = "B";
	LocalizedKeyName[67] = "C";
	LocalizedKeyName[68] = "D";
	LocalizedKeyName[69] = "E";
	LocalizedKeyName[70] = "F";
	LocalizedKeyName[71] = "G";
	LocalizedKeyName[72] = "H";
	LocalizedKeyName[73] = "I";
	LocalizedKeyName[74] = "J";
	LocalizedKeyName[75] = "K";
	LocalizedKeyName[76] = "L";
	LocalizedKeyName[77] = "M";
	LocalizedKeyName[78] = "N";
	LocalizedKeyName[79] = "O";
	LocalizedKeyName[80] = "P";
	LocalizedKeyName[81] = "Q";
	LocalizedKeyName[82] = "R";
	LocalizedKeyName[83] = "S";
	LocalizedKeyName[84] = "T";
	LocalizedKeyName[85] = "U";
	LocalizedKeyName[86] = "V";
	LocalizedKeyName[87] = "W";
	LocalizedKeyName[88] = "X";
	LocalizedKeyName[89] = "Y";
	LocalizedKeyName[90] = "Z";
	LocalizedKeyName[91] = "Unknown5B";
	LocalizedKeyName[92] = "Unknown5C";
	LocalizedKeyName[93] = "Unknown5D";
	LocalizedKeyName[94] = "Unknown5E";
	LocalizedKeyName[95] = "Unknown5F";
	LocalizedKeyName[96] = "NumPad0";
	LocalizedKeyName[97] = "NumPad1";
	LocalizedKeyName[98] = "NumPad2";
	LocalizedKeyName[99] = "NumPad3";
	LocalizedKeyName[100] = "NumPad4";
	LocalizedKeyName[101] = "NumPad5";
	LocalizedKeyName[102] = "NumPad6";
	LocalizedKeyName[103] = "NumPad7";
	LocalizedKeyName[104] = "NumPad8";
	LocalizedKeyName[105] = "NumPad9";
	LocalizedKeyName[106] = "GreyStar";
	LocalizedKeyName[107] = "GreyPlus";
	LocalizedKeyName[108] = "Separator";
	LocalizedKeyName[109] = "GreyMinus";
	LocalizedKeyName[110] = "NumPadPeriod";
	LocalizedKeyName[111] = "GreySlash";
	LocalizedKeyName[112] = "F1";
	LocalizedKeyName[113] = "F2";
	LocalizedKeyName[114] = "F3";
	LocalizedKeyName[115] = "F4";
	LocalizedKeyName[116] = "F5";
	LocalizedKeyName[117] = "F6";
	LocalizedKeyName[118] = "F7";
	LocalizedKeyName[119] = "F8";
	LocalizedKeyName[120] = "F9";
	LocalizedKeyName[121] = "F10";
	LocalizedKeyName[122] = "F11";
	LocalizedKeyName[123] = "F12";
	LocalizedKeyName[124] = "F13";
	LocalizedKeyName[125] = "F14";
	LocalizedKeyName[126] = "F15";
	LocalizedKeyName[127] = "F16";
	LocalizedKeyName[128] = "F17";
	LocalizedKeyName[129] = "F18";
	LocalizedKeyName[130] = "F19";
	LocalizedKeyName[131] = "F20";
	LocalizedKeyName[132] = "F21";
	LocalizedKeyName[133] = "F22";
	LocalizedKeyName[134] = "F23";
	LocalizedKeyName[135] = "F24";
	LocalizedKeyName[136] = "Unknown88";
	LocalizedKeyName[137] = "Unknown89";
	LocalizedKeyName[138] = "Unknown8A";
	LocalizedKeyName[139] = "Unknown8B";
	LocalizedKeyName[140] = "Unknown8C";
	LocalizedKeyName[141] = "Unknown8D";
	LocalizedKeyName[142] = "Unknown8E";
	LocalizedKeyName[143] = "Unknown8F";
	LocalizedKeyName[144] = "NumLock";
	LocalizedKeyName[145] = "ScrollLock";
	LocalizedKeyName[146] = "Unknown92";
	LocalizedKeyName[147] = "Unknown93";
	LocalizedKeyName[148] = "Unknown94";
	LocalizedKeyName[149] = "Unknown95";
	LocalizedKeyName[150] = "Unknown96";
	LocalizedKeyName[151] = "Unknown97";
	LocalizedKeyName[152] = "Unknown98";
	LocalizedKeyName[153] = "Unknown99";
	LocalizedKeyName[154] = "Unknown9A";
	LocalizedKeyName[155] = "Unknown9B";
	LocalizedKeyName[156] = "Unknown9C";
	LocalizedKeyName[157] = "Unknown9D";
	LocalizedKeyName[158] = "Unknown9E";
	LocalizedKeyName[159] = "Unknown9F";
	LocalizedKeyName[160] = "LShift";
	LocalizedKeyName[161] = "RShift";
	LocalizedKeyName[162] = "LControl";
	LocalizedKeyName[163] = "RControl";
	LocalizedKeyName[164] = "UnknownA4";
	LocalizedKeyName[165] = "UnknownA5";
	LocalizedKeyName[166] = "UnknownA6";
	LocalizedKeyName[167] = "UnknownA7";
	LocalizedKeyName[168] = "UnknownA8";
	LocalizedKeyName[169] = "UnknownA9";
	LocalizedKeyName[170] = "UnknownAA";
	LocalizedKeyName[171] = "UnknownAB";
	LocalizedKeyName[172] = "UnknownAC";
	LocalizedKeyName[173] = "UnknownAD";
	LocalizedKeyName[174] = "UnknownAE";
	LocalizedKeyName[175] = "UnknownAF";
	LocalizedKeyName[176] = "UnknownB0";
	LocalizedKeyName[177] = "UnknownB1";
	LocalizedKeyName[178] = "UnknownB2";
	LocalizedKeyName[179] = "UnknownB3";
	LocalizedKeyName[180] = "UnknownB4";
	LocalizedKeyName[181] = "UnknownB5";
	LocalizedKeyName[182] = "UnknownB6";
	LocalizedKeyName[183] = "UnknownB7";
	LocalizedKeyName[184] = "UnknownB8";
	LocalizedKeyName[185] = "UnknownB9";
	LocalizedKeyName[186] = "Semicolon";
	LocalizedKeyName[187] = "Equals";
	LocalizedKeyName[188] = "Comma";
	LocalizedKeyName[189] = "Minus";
	LocalizedKeyName[190] = "Period";
	LocalizedKeyName[191] = "Slash";
	LocalizedKeyName[192] = "Tilde";
	LocalizedKeyName[193] = "UnknownC1";
	LocalizedKeyName[194] = "UnknownC2";
	LocalizedKeyName[195] = "UnknownC3";
	LocalizedKeyName[196] = "UnknownC4";
	LocalizedKeyName[197] = "UnknownC5";
	LocalizedKeyName[198] = "UnknownC6";
	LocalizedKeyName[199] = "UnknownC7";
	LocalizedKeyName[200] = "Joy1";
	LocalizedKeyName[201] = "Joy2";
	LocalizedKeyName[202] = "Joy3";
	LocalizedKeyName[203] = "Joy4";
	LocalizedKeyName[204] = "Joy5";
	LocalizedKeyName[205] = "Joy6";
	LocalizedKeyName[206] = "Joy7";
	LocalizedKeyName[207] = "Joy8";
	LocalizedKeyName[208] = "Joy9";
	LocalizedKeyName[209] = "Joy10";
	LocalizedKeyName[210] = "Joy11";
	LocalizedKeyName[211] = "Joy12";
	LocalizedKeyName[212] = "Joy13";
	LocalizedKeyName[213] = "Joy14";
	LocalizedKeyName[214] = "Joy15";
	LocalizedKeyName[215] = "Joy16";
	LocalizedKeyName[216] = "UnknownD8";
	LocalizedKeyName[217] = "UnknownD9";
	LocalizedKeyName[218] = "UnknownDA";
	LocalizedKeyName[219] = "LeftBracket";
	LocalizedKeyName[220] = "Backslash";
	LocalizedKeyName[221] = "RightBracket";
	LocalizedKeyName[222] = "SingleQuote";
	LocalizedKeyName[223] = "UnknownDF";
	LocalizedKeyName[224] = "JoyX";
	LocalizedKeyName[225] = "JoyY";
	LocalizedKeyName[226] = "JoyZ";
	LocalizedKeyName[227] = "JoyR";
	LocalizedKeyName[228] = "MouseX";
	LocalizedKeyName[229] = "MouseY";
	LocalizedKeyName[230] = "MouseZ";
	LocalizedKeyName[231] = "MouseW";
	LocalizedKeyName[232] = "JoyU";
	LocalizedKeyName[233] = "JoyV";
	LocalizedKeyName[234] = "UnknownEA";
	LocalizedKeyName[235] = "UnknownEB";
	LocalizedKeyName[236] = "MouseWheelUp";
	LocalizedKeyName[237] = "MouseWheelDown";
	LocalizedKeyName[238] = "Unknown10E";
	LocalizedKeyName[239] = "Unknown10F";
	LocalizedKeyName[240] = "JoyPovUp";
	LocalizedKeyName[241] = "JoyPovDown";
	LocalizedKeyName[242] = "JoyPovLeft";
	LocalizedKeyName[243] = "JoyPovRight";
	LocalizedKeyName[244] = "UnknownF4";
	LocalizedKeyName[245] = "UnknownF5";
	LocalizedKeyName[246] = "Attn";
	LocalizedKeyName[247] = "CrSel";
	LocalizedKeyName[248] = "ExSel";
	LocalizedKeyName[249] = "ErEof";
	LocalizedKeyName[250] = "Play";
	LocalizedKeyName[251] = "Zoom";
	LocalizedKeyName[252] = "NoName";
	LocalizedKeyName[253] = "PA1";
	LocalizedKeyName[254] = "OEMClear";
	label = "OmnidirectionalDodge";
	CustomizeHelp = "Click the blue rectangle and then press the key to bind to this control.";
}
