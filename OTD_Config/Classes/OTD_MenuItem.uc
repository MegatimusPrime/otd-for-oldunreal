//=============================================================================
// OTD_MenuItem.
//=============================================================================
class OTD_MenuItem expands UMenuModMenuItem;

function Execute()
{ 
	MenuItem.Owner.Root.CreateWindow(class'OTD_Config.OTD_ConfigWindow',10,10,150,120);
}
