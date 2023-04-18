class UIPanel_ResizeArmor extends UIPanel config(UI);

var UICustomize CustomizeScreen;

var private UICustomize_Body					CustomizeBody;
var private XComGameState_Unit					UnitState;
var private delegate<OnItemSelectedCallback>	OnSelectionChangedOrig;

var protectedwrite EUICustomizeCategory			CustomizeCategory;
var protectedwrite XComHumanPawn				UnitPawn;

var private UIList		List;
var private UIBGBox		ListBG;
var private UIButton	ToggleButton;
var private int			ToggleButtonWidth;

var config int defaultWidth;
var config int defaultHeight;
var config int defaultOffsetX;
var config int defaultOffsetY;

var private config float TimeBetweenPawnUpdates;
var private config float MinSize;
var private config float MaxSize;
var private config float MaxTranslation;

var private localized string strSize;
var private localized string strButtonText;
var bool bShowHorizontalTranslationSliders;

delegate OnItemSelectedCallback(UIList _list, int itemIndex);

simulated function UIPanel InitPanel(optional name InitName, optional name InitLibID)
{
	super.InitPanel(InitName, InitLibID);

	if (class'ConfigHolder'.default.customOffsetX != 0)
	{
		defaultOffsetX = class'ConfigHolder'.default.customOffsetX;
	}
	if (class'ConfigHolder'.default.customOffsetY != 0)
	{
		defaultOffsetY = class'ConfigHolder'.default.customOffsetY;
	}

	if (!bShowHorizontalTranslationSliders)
	{
		defaultHeight /= 2;
	}

	Hide();
	self.SetTimer(0.25f, false, nameof(DelayedInit), self);

	return self;
}
private function DelayedInit()
{
	local UIMechaListItem ListItem;
	local ArmorSizeStruct ArmorSize;
	local float PartSize;
	local vector Translation;

	if (!GetParentCustomizeScreen())
	{
		self.Remove(); // Commit sudoku 
		return;
	}

	`AMLOG("Running Delayed Init:" @ GetCustomizeCategory());

	CustomizeCategory = GetCustomizeCategory();
	if (CustomizeCategory == eUICustomizeCat_FirstName)
	{
		self.Remove();
		return;
	}
	UnitState = CustomizeScreen.GetUnit();
	if (UnitState == none)
	{
		self.Remove();
		return;
	}

	UnitPawn = XComHumanPawn(CustomizeScreen.CustomizeManager.ActorPawn);
	if (UnitPawn == none)
	{
		self.Remove();
		return;
	}

	`AMLOG("Unit:" @ UnitState.GetFullName() @ "Has Pawn:" @ UnitPawn != none @ "Part:" @ GetPartName());

	OnSelectionChangedOrig = CustomizeScreen.List.OnSelectionChanged;
	CustomizeScreen.List.OnSelectionChanged = OnBodyPartSelected;

	SetPosition(defaultOffsetX, defaultOffsetY);

	ListBG = Spawn(class'UIBGBox', self);
	ListBG.LibID = class'UIUtilities_Controls'.const.MC_X2Background;
	ListBG.InitBG();
	ListBG.SetAlpha(80);
	ListBG.SetWidth(defaultWidth + 10);
	ListBG.SetHeight(defaultHeight + 10);
	
	//ListBG.ProcessMouseEvents(List.OnChildMouseEvent);

	List = Spawn(class'UIList', self);
	List.bAnimateOnInit = false;
	List.bStickyHighlight = false;
	List.InitList();
	List.Navigator.LoopSelection = false;
	List.ItemPadding = 5;
	List.SetPosition(5, 5);
	List.SetWidth(defaultWidth);
	List.SetHeight(defaultHeight);

	class'Help'.static.FindArmorSize(UnitState, GetPartName(), CustomizeCategory, ArmorSize);
	PartSize = ArmorSize.PartSize;
	Translation = ArmorSize.Translation;

	// Size
	ListItem = Spawn(class'UIMechaListItem', List.itemContainer);
	ListItem.bAnimateOnInit = false;
	ListItem.InitListItem();
	//ListItem.SetWidth(562);
	class'Help'.static.GetPartSize(UnitState, GetPartName(), CustomizeCategory, PartSize);
	ListItem.UpdateDataSlider(strSize, string(int(PartSize * 100)), (PartSize - MinSize) * 100.0f / (MaxSize - MinSize),, OnSizeSliderChanged);

	if (bShowHorizontalTranslationSliders)
	{
	// X
	ListItem = Spawn(class'UIMechaListItem', List.itemContainer);
	ListItem.bAnimateOnInit = false;
	ListItem.InitListItem();
	ListItem.UpdateDataSlider("X", TruncateFloat(Translation.X), GetSliderPercentFromTranslation(Translation.X),, OnTranslationSliderChanged_X);

	// Y
	ListItem = Spawn(class'UIMechaListItem', List.itemContainer);
	ListItem.bAnimateOnInit = false;
	ListItem.InitListItem();
	ListItem.UpdateDataSlider("Y", TruncateFloat(Translation.Y), GetSliderPercentFromTranslation(Translation.Y),, OnTranslationSliderChanged_Y);
	}
	// Z
	ListItem = Spawn(class'UIMechaListItem', List.itemContainer);
	ListItem.bAnimateOnInit = false;
	ListItem.InitListItem();
	ListItem.UpdateDataSlider("Z", TruncateFloat(Translation.Z), GetSliderPercentFromTranslation(Translation.Z),, OnTranslationSliderChanged_Z);

	List.RealizeItems();
	List.RealizeList();

	ToggleButton = Spawn(class'UIButton', self);
	ToggleButton.bIsNavigable = false;
	ToggleButton.InitButton();
	ToggleButton.ProcessMouseEvents(OnButtonMouseEvent);
	ToggleButton.SetText(default.strButtonText);
	ToggleButton.OnSizeRealized = OnButtonSizeRealized;
	ToggleButton.fButtonHoldMaxTime = 0.5f;
	ToggleButton.OnHoldDelegate = OnToggleButtonHold;

	`AMLOG("Inited panel for unit:" @ UnitState.GetFullName());

	Show();
}

private function OnButtonSizeRealized()
{
	ToggleButtonWidth = ToggleButton.Width;
	if (List.bIsVisible)
	{
		ToggleButton.SetPosition(defaultWidth - ToggleButtonWidth, defaultHeight + 10);
	}
	else
	{
		ToggleButton.SetPosition(defaultWidth - ToggleButtonWidth, 0);
	}
}

private function OnToggleButtonHold(UIButton Button)
{
	local UIPanel_DragAndDrop DragAndDrop;

	DragAndDrop = Spawn(class'UIPanel_DragAndDrop', self);
	DragAndDrop.InitPanel();
	DragAndDrop.SetPosition(ToggleButton.X, ToggleButton.Y);
	DragAndDrop.OnDragFinishedFn = OnDragFinished;

	Button.bMouseDown = false;
}

private function OnDragFinished()
{
	`AMLOG("Saving position to config:" @ X @ Y);
	class'ConfigHolder'.default.customOffsetX = X;
	class'ConfigHolder'.default.customOffsetY = Y;
	class'ConfigHolder'.static.CommitChanges();
	//defaultOffsetX = X;
	//defaultOffsetY = Y;
	//default.defaultOffsetX = X;
	//default.defaultOffsetY = Y;
}


private function OnButtonMouseEvent(UIPanel Button, int cmd)
{
	if (cmd == class'UIUtilities_Input'.const.FXS_L_MOUSE_UP)
	{
		if (List.bIsVisible)
		{
			List.Hide();
			ListBG.Hide();
			Button.SetPosition(defaultWidth - ToggleButtonWidth, 0);
		}
		else
		{
			List.Show();
			ListBG.Show();
			Button.SetPosition(defaultWidth - ToggleButtonWidth, defaultHeight + 10);
		}
	}
}

protected function bool GetParentCustomizeScreen()
{
	CustomizeBody = UICustomize_Body(self.Movie.Pres.ScreenStack.GetFirstInstanceOf(class'UICustomize_Body'));
	return CustomizeBody != none;
}

private function int GetSliderPercentFromTranslation(const float Translation)
{	
	// Tranlsation = -MaxTranslation, Percent = 0
	// Translation = 0, Percent = 50
	// Translation = MaxTranslation, Percent = 100
	return Round(50.0f * (Translation / MaxTranslation + 1.0f));
}

private function OnSizeSliderChanged(UISlider sliderControl)
{
	local name PartName;
	local float Scale;

	Scale = MinSize + (MaxSize - MinSize) * sliderControl.percent / 100.0f;

	sliderControl.SetText(string(int(Scale * 100)));

	PartName = GetPartName();
	if (PartName == '')
		return;

	class'Help'.static.SetPartSize(UnitState, PartName, CustomizeCategory, Scale);

	class'Help'.static.ResizeArmor(UnitState, UnitPawn);
}

private function OnTranslationSliderChanged_X(UISlider sliderControl)
{
	local name PartName;
	local vector Translation;
	local ArmorSizeStruct ArmorSize;

	PartName = GetPartName();
	if (PartName == '')
		return;

	class'Help'.static.FindArmorSize(UnitState, PartName, CustomizeCategory, ArmorSize);
	Translation = ArmorSize.Translation;

	`AMLOG("Slider percent:" @ sliderControl.percent);

	Translation.X = GetTranslationFromSliderPercent(sliderControl.percent);

	sliderControl.SetText(TruncateFloat(Translation.X));

	class'Help'.static.SetPartTranslation(UnitState, PartName, CustomizeCategory, Translation);

	class'Help'.static.ResizeArmor(UnitState, UnitPawn);
}
private function OnTranslationSliderChanged_Y(UISlider sliderControl)
{
	local name PartName;
	local vector Translation;
	local ArmorSizeStruct ArmorSize;

	PartName = GetPartName();
	if (PartName == '')
		return;

	class'Help'.static.FindArmorSize(UnitState, PartName, CustomizeCategory, ArmorSize);
	Translation = ArmorSize.Translation;

	Translation.Y = GetTranslationFromSliderPercent(sliderControl.percent);

	sliderControl.SetText(TruncateFloat(Translation.Y));

	class'Help'.static.SetPartTranslation(UnitState, PartName, CustomizeCategory, Translation);

	class'Help'.static.ResizeArmor(UnitState, UnitPawn);
}
private function OnTranslationSliderChanged_Z(UISlider sliderControl)
{
	local name PartName;
	local vector Translation;
	local ArmorSizeStruct ArmorSize;

	PartName = GetPartName();
	if (PartName == '')
		return;

	class'Help'.static.FindArmorSize(UnitState, PartName, CustomizeCategory, ArmorSize);
	Translation = ArmorSize.Translation;

	Translation.Z = GetTranslationFromSliderPercent(sliderControl.percent);

	sliderControl.SetText(TruncateFloat(Translation.Z));

	class'Help'.static.SetPartTranslation(UnitState, PartName, CustomizeCategory, Translation);

	class'Help'.static.ResizeArmor(UnitState, UnitPawn);
}

private function float GetTranslationFromSliderPercent(int SliderPercent)
{
	local float ActualSlider;

	if (SliderPercent == 50)
		return 0.0f; // Hardcoded middle to avoid dealing with fractions

	// Slider percent goes between 1 and 100, but we need scaling between 0 and 100.
	ActualSlider = (SliderPercent - 1.0f) * 100.0f / 99.0f;
	
	return MaxTranslation * (ActualSlider / 50.0f - 1.0f);
}

private function OnBodyPartSelected(UIList ContainerList, int ItemIndex)
{
	local ArmorSizeStruct ArmorSize;
	local UIMechaListItem ListItem;
	local float PartSize;
	local vector Translation;

	OnSelectionChangedOrig(ContainerList, ItemIndex);

	if (ItemIndex == INDEX_NONE)
		return;

	class'Help'.static.FindArmorSize(UnitState, GetPartName(), CustomizeCategory, ArmorSize);
	PartSize = ArmorSize.PartSize;
	Translation = ArmorSize.Translation;

	ListItem = UIMechaListItem(List.GetItem(0));
	ListItem.UpdateDataSlider(strSize, string(int(PartSize * 100)), (PartSize - MinSize) * 100.0f / (MaxSize - MinSize),, OnSizeSliderChanged);

	if (bShowHorizontalTranslationSliders)
	{
	ListItem = UIMechaListItem(List.GetItem(1));
	ListItem.UpdateDataSlider("X", TruncateFloat(Translation.X), GetSliderPercentFromTranslation(Translation.X),, OnTranslationSliderChanged_X);

	ListItem = UIMechaListItem(List.GetItem(2));
	ListItem.UpdateDataSlider("Y", TruncateFloat(Translation.Y), GetSliderPercentFromTranslation(Translation.Y),, OnTranslationSliderChanged_Y);
	}
	ListItem = UIMechaListItem(List.GetItem(3));
	ListItem.UpdateDataSlider("Z", TruncateFloat(Translation.Z), GetSliderPercentFromTranslation(Translation.Z),, OnTranslationSliderChanged_Z);

	`AMLOG("Item Selected:" @ ItemIndex @ GetPartName() @ PartSize);

	//Hide();
	self.SetTimer(TimeBetweenPawnUpdates, false, nameof(AcquirePawnAndResize), self);
}

private function AcquirePawnAndResize()
{
	UnitPawn = XComHumanPawn(CustomizeScreen.CustomizeManager.ActorPawn);
	if (UnitPawn == none)
	{
		self.SetTimer(TimeBetweenPawnUpdates, false, nameof(AcquirePawnAndResize), self);
	}
	else
	{
		//Show();
		class'Help'.static.ResizeArmor(UnitState, UnitPawn);
	}
}

protected function EUICustomizeCategory GetCustomizeCategory()
{
	if (string(CustomizeScreen.List.OnSelectionChanged) == string(CustomizeBody.ChangeTorso))
		return eUICustomizeCat_Torso;

	if (string(CustomizeScreen.List.OnSelectionChanged) == string(CustomizeBody.ChangeArms))
		return eUICustomizeCat_Arms;

	if (string(CustomizeScreen.List.OnSelectionChanged) == string(CustomizeBody.ChangeLegs))
		return eUICustomizeCat_Legs;

	if (string(CustomizeScreen.List.OnSelectionChanged) == string(CustomizeBody.ChangeLeftArm))
		return eUICustomizeCat_LeftArm;

	if (string(CustomizeScreen.List.OnSelectionChanged) == string(CustomizeBody.ChangeRightArm))
		return eUICustomizeCat_RightArm;

	if (string(CustomizeScreen.List.OnSelectionChanged) == string(CustomizeBody.ChangeLeftArmDeco))
		return eUICustomizeCat_LeftArmDeco;

	if (string(CustomizeScreen.List.OnSelectionChanged) == string(CustomizeBody.ChangeRightArmDeco))
		return eUICustomizeCat_RightArmDeco;

	if (string(CustomizeScreen.List.OnSelectionChanged) == string(CustomizeBody.ChangeLeftForearm))
		return eUICustomizeCat_LeftForearm;

	if (string(CustomizeScreen.List.OnSelectionChanged) == string(CustomizeBody.ChangeRightForearm))
		return eUICustomizeCat_RightForearm;

	if (string(CustomizeScreen.List.OnSelectionChanged) == string(CustomizeBody.ChangeThighs))
		return eUICustomizeCat_Thighs;

	if (string(CustomizeScreen.List.OnSelectionChanged) == string(CustomizeBody.ChangeShins))
		return eUICustomizeCat_Shins;

	if (string(CustomizeScreen.List.OnSelectionChanged) == string(CustomizeBody.ChangeTorsoDeco))
		return eUICustomizeCat_TorsoDeco;

	return eUICustomizeCat_FirstName;
}

protected function name GetPartName()
{
	switch(CustomizeCategory)
	{
	case eUICustomizeCat_Arms:
		return UnitPawn.m_kAppearance.nmArms;
	case eUICustomizeCat_Torso:
		return UnitPawn.m_kAppearance.nmTorso;
	case eUICustomizeCat_Legs:
		return UnitPawn.m_kAppearance.nmLegs;
	case eUICustomizeCat_LeftArm:
		return UnitPawn.m_kAppearance.nmLeftArm;
	case eUICustomizeCat_RightArm:
		return UnitPawn.m_kAppearance.nmRightArm;
	case eUICustomizeCat_LeftArmDeco:
		return UnitPawn.m_kAppearance.nmLeftArmDeco;
	case eUICustomizeCat_RightArmDeco:
		return UnitPawn.m_kAppearance.nmRightArmDeco;
	case eUICustomizeCat_LeftForearm:
		return UnitPawn.m_kAppearance.nmLeftForearm;
	case eUICustomizeCat_RightForearm:
		return UnitPawn.m_kAppearance.nmRightForearm;
	case eUICustomizeCat_Thighs:
		return UnitPawn.m_kAppearance.nmThighs;
	case eUICustomizeCat_Shins:
		return UnitPawn.m_kAppearance.nmShins;
	case eUICustomizeCat_TorsoDeco:
		return UnitPawn.m_kAppearance.nmTorsoDeco;
	default:
		return '';
	}
	return '';
}

static function string TruncateFloat(float value)
{
	local string FloatString, TempString;
	local int i;
	local float TempFloat, TestFloat;

	TempFloat = value;
	for (i=0; i < 1; i++)
	{
		TempFloat *= 10.0;
	}
	TempFloat = Round(TempFloat);
	for (i=0; i < 1; i++)
	{
		TempFloat /= 10.0;
	}

	TempString = string(TempFloat);
	for (i = InStr(TempString, ".") + 1; i < Len(TempString) ; i++)
	{
		FloatString = Left(TempString, i);
		TestFloat = float(FloatString);
		if (TempFloat ~= TestFloat)
		{
			break;
		}
	}

	if (Right(FloatString, 1) == ".")
	{
		FloatString $= "0";
	}

	return FloatString;
}

defaultproperties
{
	bShowHorizontalTranslationSliders = true
}
