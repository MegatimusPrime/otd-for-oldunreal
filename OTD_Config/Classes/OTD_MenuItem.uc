//=============================================================================
// OTD_MenuItem.
//=============================================================================
class OTD_MenuItem expands UMenuModMenuItem;

function Execute()
{ 
	MenuItem.Owner.Root.CreateWindow(class'OTD_Config.OTD_ConfigWindow',100,100,200,200);
}
