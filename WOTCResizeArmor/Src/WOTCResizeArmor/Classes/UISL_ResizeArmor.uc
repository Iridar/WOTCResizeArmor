class UISL_ResizeArmor extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	local UICustomize_Trait		CustomizeScreen;
	local UIPanel_ResizeArmor	ResizeArmorPanel;

	CustomizeScreen = UICustomize_Trait(Screen);
	if (CustomizeScreen == none)
		return;
	ScreenClass = Screen.Class;

	`AMLOG("Spawning panel");

	ResizeArmorPanel = Screen.Spawn(class'UIPanel_ResizeArmor', Screen);
	ResizeArmorPanel.CustomizeScreen = CustomizeScreen;
	ResizeArmorPanel.InitPanel();
}
