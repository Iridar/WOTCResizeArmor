class UISL_ResizeArmor extends UIScreenListener;

var private string PathToPanel;

event OnInit(UIScreen Screen)
{
	local UICustomize_Trait		CustomizeScreen;
	local UICustomize_Body		CustomizeBody;
	local UIPanel_ResizeArmor	ResizeArmorPanel;

	CustomizeBody = UICustomize_Body(Screen);
	if (CustomizeBody != none)
	{
		FindAndRemovePanel();
		ResizeArmorPanel = Screen.Spawn(class'UIPanel_ResizePawn', `HQPRES.m_kAvengerHUD);
		ResizeArmorPanel.CustomizeScreen = CustomizeBody;
		ResizeArmorPanel.InitPanel();
		PathToPanel = PathName(ResizeArmorPanel);
		return;
	}
	

	CustomizeScreen = UICustomize_Trait(Screen);
	if (CustomizeScreen == none)
		return;

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

	`AMLOG("Spawned panel on screen:" @ Screen.Class.Name);
	ResizeArmorPanel.CustomizeScreen = CustomizeScreen;
	ResizeArmorPanel.InitPanel();
	PathToPanel = PathName(ResizeArmorPanel);
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