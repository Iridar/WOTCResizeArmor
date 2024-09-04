class UISL_ResizeArmor extends UIScreenListener config(UI);

var private string PathToPanel;

var private config bool bAddResizeBodyPanelToCustomizeMainMenu;

event OnInit(UIScreen Screen)
{
	local UICustomize			CustomizeScreen;
	local UIPanel_ResizeArmor	ResizeArmorPanel;
	local XComGameState_Unit	UnitState;
	local X2CharacterTemplate	CharTemplate;
	local bool					bCustomizeSparkBody;
	local bool					bCustomizeBody;
	local bool					bCustomizeRoot;
	local bool					bPDCustomizeHead;
	local bool					bPDCustomizeBody;

	`AMLOG("Init Screen class:" @ Screen.Class.Name @ "MC Name:" @ Screen.MCName);

	CustomizeScreen = UICustomize(Screen);
	if (CustomizeScreen == none)
		return;

	if (bAddResizeBodyPanelToCustomizeMainMenu)
	{
		UnitState = CustomizeScreen.GetUnit();
		if (UnitState != none)
		{
			CharTemplate = UnitState.GetMyTemplate();
			if (CharTemplate != none)
			{
				bCustomizeRoot = CharTemplate.UICustomizationMenuClass == CustomizeScreen.Class;
			}
		}
	}
	 
	bCustomizeRoot = bCustomizeRoot || Screen.IsA('PD_UICustomize_Menu');
	bCustomizeBody = Screen.IsA('UICustomize_Body') || Screen.MCName == 'PD_UICustomize_Body';
	bCustomizeSparkBody = Screen.IsA('UICustomize_SparkBody') || Screen.IsA('PD_UICustomize_Menu_Spark') || Screen.MCName == 'PD_UICustomize_Body_Spark';
	bCustomizeBody = bCustomizeBody || bCustomizeSparkBody;
	
	// Spawn the panel for resizing the entire pawn.
	if (bCustomizeRoot || bCustomizeBody)
	{
		FindAndRemovePanel();
		ResizeArmorPanel = Screen.Spawn(class'UIPanel_ResizePawn', `HQPRES.m_kAvengerHUD);
		ResizeArmorPanel.CustomizeScreen = CustomizeScreen;
		ResizeArmorPanel.InitPanel();
		PathToPanel = PathName(ResizeArmorPanel);
		return;
	}

	switch (Screen.MCName)
	{
		case 'Face':
		case 'Helmet':
		case 'Hair':
		case 'UpperFace':
		case 'LowerFace':
		case 'FacialHair':
			bPDCustomizeHead = true;
			break;
		case 'Torso':
		case 'Arms':
		case 'Legs':
		case 'TorsoDeco':
		case 'LeftArm':
		case 'LeftForearm':
		case 'RightArm':
		case 'RightForearm':
		case 'Thighs':
		case 'Shins':
		case 'LeftArmDeco':
		case 'RightArmDeco':
			bPDCustomizeBody = true;
			break;
		default:
			break;

	}

	`AMLOG("bPDCustomizeHead:" @ bPDCustomizeHead @ "bPDCustomizeBody:" @ bPDCustomizeBody @ "is a PD Trait screen:" @ Screen.IsA('PD_UICustomize_Trait'));

	// For individual body parts.
	if (Screen.IsA('UICustomize_Trait') || Screen.IsA('uc_ui_screens_BodyPartList') || Screen.IsA('uc_ui_screens_SparkPropsPartList') || Screen.IsA('PD_UICustomize_Trait'))
	{
		`AMLOG("First set of conditions done" @ Screen.Movie.Pres.ScreenStack.HasInstanceOf(class'UICustomize_Body') @ bPDCustomizeBody);
		if (Screen.Movie.Pres.ScreenStack.HasInstanceOf(class'UICustomize_Body') || bPDCustomizeBody)
		{
			`AMLOG("Spawning customize body panel");
			FindAndRemovePanel();
			ResizeArmorPanel = Screen.Spawn(class'UIPanel_ResizeArmor', `HQPRES.m_kAvengerHUD);
		}
		else if (Screen.Movie.Pres.ScreenStack.HasInstanceOf(class'UICustomize_Head') || bPDCustomizeHead)
		{
			`AMLOG("Spawning customize head panel");
			FindAndRemovePanel();
			ResizeArmorPanel = Screen.Spawn(class'UIPanel_ResizeHead', `HQPRES.m_kAvengerHUD);
		}
		else if (Screen.Movie.Pres.ScreenStack.HasInstanceOf(class'UICustomize_SparkBody'))
		{
			`AMLOG("Spawning customize body panel for SPARK");
			FindAndRemovePanel();
			ResizeArmorPanel = Screen.Spawn(class'UIPanel_ResizeArmor', `HQPRES.m_kAvengerHUD);
		}

		if (ResizeArmorPanel != none)
		{
			`AMLOG("Spawned panel on screen:" @ Screen.Class.Name);
			ResizeArmorPanel.CustomizeScreen = CustomizeScreen;
			ResizeArmorPanel.InitPanel();
			PathToPanel = PathName(ResizeArmorPanel);
		}
	}
}
event OnReceiveFocus(UIScreen Screen)
{	
	OnInit(Screen);
}


event OnRemoved(UIScreen Screen)
{
	local UIPanel_ResizeArmor ResizeArmorPanel;

	`AMLOG(Screen.Class.Name @ string(Screen));

	ResizeArmorPanel = UIPanel_ResizeArmor(FindObject(PathToPanel, class'UIPanel_ResizeArmor'));
	if (ResizeArmorPanel != none)
	{
		`AMLOG("Found panel:" @ string(ResizeArmorPanel.ParentPanel));
		if (string(ResizeArmorPanel.CustomizeScreen) == string(Screen))
		{
			`AMLOG("Match, removing panel");
			ResizeArmorPanel.Remove();
		}
	}
}
event OnLoseFocus(UIScreen Screen)
{	
	`AMLOG(Screen.Class.Name @ string(Screen));
	OnRemoved(Screen);
}
/*
private function SpawnPanel(UIScreen Screen)
{
	FindAndRemovePanel();
}
*/
private function FindAndRemovePanel()
{
	local UIPanel_ResizeArmor ResizeArmorPanel;

	ResizeArmorPanel = UIPanel_ResizeArmor(FindObject(PathToPanel, class'UIPanel_ResizeArmor'));
	if (ResizeArmorPanel != none)
	{
		`AMLOG("Removing Panel");
		ResizeArmorPanel.Remove();
	}
	else
	{
		`AMLOG("No panel to remove.");
	}
}
