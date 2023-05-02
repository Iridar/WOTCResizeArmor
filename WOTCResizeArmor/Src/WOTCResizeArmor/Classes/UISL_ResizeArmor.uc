class UISL_ResizeArmor extends UIScreenListener config(UI);

var private string PathToPanel;

var private config bool bAddResizeBodyPanelToCustomizeMainMenu;

event OnInit(UIScreen Screen)
{
	local UICustomize			CustomizeScreen;
	local UIPanel_ResizeArmor	ResizeArmorPanel;
	local XComGameState_Unit	UnitState;
	local X2CharacterTemplate	CharTemplate;
	local bool					bAddResizePawnPanel;

	CustomizeScreen = UICustomize(Screen);
	if (CustomizeScreen == none)
		return;

	CharTemplate.UICustomizationMenuClass = class'UICustomize_SparkMenu';
	if (bAddResizeBodyPanelToCustomizeMainMenu)
	{
		UnitState = CustomizeScreen.GetUnit();
		if (UnitState != none)
		{
			CharTemplate = UnitState.GetMyTemplate();
			if (CharTemplate != none)
			{
				bAddResizePawnPanel = CharTemplate.UICustomizationMenuClass == CustomizeScreen.Class;
			}
		}
	}

	//`LOG(Screen.Class.Name,, 'IRITEST');
	// Spawn the panel for resizing the entire pawn.
	if (bAddResizePawnPanel || Screen.IsA('UICustomize_Body') || Screen.IsA('UICustomize_SparkBody'))
	{
		FindAndRemovePanel();
		ResizeArmorPanel = Screen.Spawn(class'UIPanel_ResizePawn', `HQPRES.m_kAvengerHUD);
		ResizeArmorPanel.CustomizeScreen = CustomizeScreen;
		ResizeArmorPanel.InitPanel();
		PathToPanel = PathName(ResizeArmorPanel);
		return;
	}
	
	// For individual body parts.
	if (Screen.IsA('UICustomize_Trait') || Screen.IsA('uc_ui_screens_BodyPartList') || Screen.IsA('uc_ui_screens_SparkPropsPartList'))
	{
		if (Screen.Movie.Pres.ScreenStack.HasInstanceOf(class'UICustomize_Body'))
		{
			FindAndRemovePanel();
			ResizeArmorPanel = Screen.Spawn(class'UIPanel_ResizeArmor', `HQPRES.m_kAvengerHUD);
		}
		else if (Screen.Movie.Pres.ScreenStack.HasInstanceOf(class'UICustomize_Head'))
		{
			FindAndRemovePanel();
			ResizeArmorPanel = Screen.Spawn(class'UIPanel_ResizeHead', `HQPRES.m_kAvengerHUD);
		}
		else if (Screen.Movie.Pres.ScreenStack.HasInstanceOf(class'UICustomize_SparkBody'))
		{
			FindAndRemovePanel();
			ResizeArmorPanel = Screen.Spawn(class'UIPanel_ResizeArmor', `HQPRES.m_kAvengerHUD);
		}

		`AMLOG("Spawned panel on screen:" @ Screen.Class.Name);
		ResizeArmorPanel.CustomizeScreen = CustomizeScreen;
		ResizeArmorPanel.InitPanel();
		PathToPanel = PathName(ResizeArmorPanel);
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

private function SpawnPanel(UIScreen Screen)
{
	FindAndRemovePanel();
}

private function FindAndRemovePanel()
{
	local UIPanel_ResizeArmor ResizeArmorPanel;

	ResizeArmorPanel = UIPanel_ResizeArmor(FindObject(PathToPanel, class'UIPanel_ResizeArmor'));
	if (ResizeArmorPanel != none)
	{
		ResizeArmorPanel.Remove();
	}
}