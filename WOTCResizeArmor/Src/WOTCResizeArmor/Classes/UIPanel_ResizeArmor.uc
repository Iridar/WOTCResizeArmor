class UIPanel_ResizeArmor extends UIPanel config(UI);

var UICustomize_Trait CustomizeScreen;

var private UICustomize_Body					CustomizeBody;
var private EUICustomizeCategory				CustomizeCategory;
var private XComGameState_Unit					UnitState;
var private XComHumanPawn						UnitPawn;
var private delegate<OnItemSelectedCallback>	OnSelectionChangedOrig;

var private UIList List;
var private UIBGBox ListBG;

var config int DefaultWidth;
var config int DefaultHeight;
var config int DefaultOffsetX;
var config int DefaultOffsetY;
var private config float TimeBetweenPawnUpdates;
var private config float MinSize;
var private config float MaxSize;
var private config int MaxTranslation;

var private localized string strSize;

delegate OnItemSelectedCallback(UIList _list, int itemIndex);

simulated function UIPanel InitPanel(optional name InitName, optional name InitLibID)
{
	super.InitPanel(InitName, InitLibID);

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

	CustomizeBody = UICustomize_Body(self.Movie.Pres.ScreenStack.GetFirstInstanceOf(class'UICustomize_Body'));
	if (CustomizeBody == none)
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

	SetPosition(DefaultOffsetX, DefaultOffsetY);

	ListBG = Spawn(class'UIBGBox', self);
	ListBG.LibID = class'UIUtilities_Controls'.const.MC_X2Background;
	ListBG.InitBG();
	ListBG.SetAlpha(80);
	ListBG.SetWidth(DefaultWidth + 10);
	ListBG.SetHeight(DefaultHeight + 10);
	
	//ListBG.ProcessMouseEvents(List.OnChildMouseEvent);

	List = Spawn(class'UIList', self);
	List.bAnimateOnInit = false;
	List.bStickyHighlight = false;
	List.InitList();
	List.Navigator.LoopSelection = false;
	List.ItemPadding = 5;
	List.SetPosition(5, 5);
	List.SetWidth(DefaultWidth);
	List.SetHeight(DefaultHeight);

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

	// X
	ListItem = Spawn(class'UIMechaListItem', List.itemContainer);
	ListItem.bAnimateOnInit = false;
	ListItem.InitListItem();
	ListItem.UpdateDataSlider("X", string(int(Translation.X)), Translation.X / MaxTranslation,, OnTranslationSliderChanged_X);

	// Y
	ListItem = Spawn(class'UIMechaListItem', List.itemContainer);
	ListItem.bAnimateOnInit = false;
	ListItem.InitListItem();
	ListItem.UpdateDataSlider("Y", string(int(Translation.Y)), Translation.Y / MaxTranslation,, OnTranslationSliderChanged_Y);

	// Z
	ListItem = Spawn(class'UIMechaListItem', List.itemContainer);
	ListItem.bAnimateOnInit = false;
	ListItem.InitListItem();
	ListItem.UpdateDataSlider("Z", string(int(Translation.Z)), Translation.Z / MaxTranslation,, OnTranslationSliderChanged_Z);

	List.RealizeItems();
	List.RealizeList();

	`AMLOG("Inited panel for unit:" @ UnitState.GetFullName());

	Show();
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

	//CustomizeScreen.CustomizeManager.Refresh(CustomizeScreen.CustomizeManager.UpdatedUnitState, UnitState);

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

	Translation.X = MaxTranslation * sliderControl.percent / 100.0f;

	sliderControl.SetText(string(int(Translation.X)));

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

	Translation.Y = MaxTranslation * sliderControl.percent / 100.0f;

	sliderControl.SetText(string(int(Translation.Y)));

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

	Translation.Z = MaxTranslation * sliderControl.percent / 100.0f;

	sliderControl.SetText(string(int(Translation.Z)));

	class'Help'.static.SetPartTranslation(UnitState, PartName, CustomizeCategory, Translation);

	class'Help'.static.ResizeArmor(UnitState, UnitPawn);
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

	ListItem = UIMechaListItem(List.GetItem(1));
	ListItem.UpdateDataSlider("X", string(int(Translation.X)), Translation.X / MaxTranslation,, OnTranslationSliderChanged_X);

	ListItem = UIMechaListItem(List.GetItem(2));
	ListItem.UpdateDataSlider("Y", string(int(Translation.Y)), Translation.Y / MaxTranslation,, OnTranslationSliderChanged_Y);

	ListItem = UIMechaListItem(List.GetItem(3));
	ListItem.UpdateDataSlider("Z", string(int(Translation.Z)), Translation.Z / MaxTranslation,, OnTranslationSliderChanged_Z);

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




private function EUICustomizeCategory GetCustomizeCategory()
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

private function name GetPartName()
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
