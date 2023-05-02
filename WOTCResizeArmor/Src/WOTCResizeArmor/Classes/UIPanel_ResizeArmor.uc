class UIPanel_ResizeArmor extends UIPanel config(UI);

var UICustomize CustomizeScreen;

var private UICustomize_Body					CustomizeBody;
var private UICustomize_SparkBody				CustomizeSparkBody;					
var private XComGameState_Unit					UnitState;
var private delegate<OnItemSelectedCallback>	OnSelectionChangedOrig;

var protectedwrite EUICustomizeCategory			CustomizeCategory;
var protectedwrite XComHumanPawn				UnitPawn;

var private UIList		List;
var private UIBGBox		ListBG;
var private UIButton	ResetButton;
var private int			ResetButtonWidth;
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
var private localized string strToggleButtonText;
var private localized string strResetButtonText;
var private localized string strToggleButtonTooltip;
var private localized string strResetButtonTooltip;
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
		`AMLOG("WARNING :: Failed to get parent Customize Screen, exiting.");
		self.Remove(); // Commit sudoku 
		return;
	}

	`AMLOG("Running Delayed Init:" @ GetCustomizeCategory());

	CustomizeCategory = GetCustomizeCategory();
	if (CustomizeCategory == eUICustomizeCat_FirstName)
	{
		`AMLOG("Customize Category" @ CustomizeCategory @ "is not supported, exiting.");
		self.Remove();
		return;
	}
	UnitState = CustomizeScreen.GetUnit();
	if (UnitState == none)
	{
		`AMLOG("WARNING :: Failed to get Unit State from Customize Screen, exiting.");
		self.Remove();
		return;
	}

	UnitPawn = XComHumanPawn(CustomizeScreen.CustomizeManager.ActorPawn);
	if (UnitPawn == none)
	{
		`AMLOG("WARNING :: Failed to get Unit Pawn from Customize Screen, exiting.");
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
	ToggleButton.ProcessMouseEvents(OnToggleButtonMouseEvent);
	ToggleButton.SetText(default.strToggleButtonText);
	ToggleButton.OnSizeRealized = OnButtonSizeRealized;
	ToggleButton.fButtonHoldMaxTime = 0.5f;
	ToggleButton.OnHoldDelegate = OnToggleButtonHold;
	
	ResetButton = Spawn(class'UIButton', self);
	ResetButton.bIsNavigable = false;
	ResetButton.InitButton();
	ResetButton.ProcessMouseEvents(OnResetButtonMouseEvent);
	ResetButton.SetText(default.strResetButtonText);
	ResetButton.OnSizeRealized = OnButtonSizeRealized;
	ResetButton.fButtonHoldMaxTime = 0.5f;
	ResetButton.OnHoldDelegate = OnResetButtonHold;

	UpdateButtonTooltips();
	
	`AMLOG("Inited panel for unit:" @ UnitState.GetFullName());

	Show();
}

private function UpdateButtonTooltips()
{
	// Shift tooltips upwards if the panel is in the lower half of the screen
	if (Y > 1080 / 2)
	{
		ToggleButton.SetTooltipText(strToggleButtonTooltip,, -defaultWidth / 2, -250, true /*bRelativeLocation*/,, false /*bFollowMouse*/, 0.25f);
		ResetButton.SetTooltipText(strResetButtonTooltip,, -defaultWidth / 2, -250, true /*bRelativeLocation*/,, false /*bFollowMouse*/, 0.25f);
	}
	else
	{
		ToggleButton.SetTooltipText(strToggleButtonTooltip,, -defaultWidth / 2,, true /*bRelativeLocation*/,, false /*bFollowMouse*/, 0.25f);
		ResetButton.SetTooltipText(strResetButtonTooltip,, -defaultWidth / 2,, true /*bRelativeLocation*/,, false /*bFollowMouse*/, 0.25f);
	}
}

private function OnButtonSizeRealized()
{
	ToggleButtonWidth = ToggleButton.Width;
	ResetButtonWidth = ResetButton.Width;

	if (List.bIsVisible)
	{
		ToggleButton.SetPosition(defaultWidth - ToggleButtonWidth, defaultHeight + 10);
		ResetButton.SetPosition(defaultWidth - ResetButtonWidth - ToggleButtonWidth - 10, defaultHeight + 10);
	}
	else
	{
		ToggleButton.SetPosition(defaultWidth - ToggleButtonWidth, 0);
		ResetButton.SetPosition(defaultWidth - ResetButtonWidth - ToggleButtonWidth - 10, 0);
	}
}


private function OnResetButtonHold(UIButton Button)
{
	Button.bMouseDown = false;
	class'Help'.static.RemoveAllPartSizesForUnit(UnitState);
	ResetSlidersAndUpdatePawn();
}

private function ResetSlidersAndUpdatePawn()
{
	local UIMechaListItem ListItem;

	ListItem = UIMechaListItem(List.GetItem(0));
	ListItem.UpdateDataSlider(strSize, "100", (1.0f - MinSize) * 100.0f / (MaxSize - MinSize),, OnSizeSliderChanged);

	if (bShowHorizontalTranslationSliders)
	{
	ListItem = UIMechaListItem(List.GetItem(1));
	ListItem.UpdateDataSlider("X", "0.0", GetSliderPercentFromTranslation(0),, OnTranslationSliderChanged_X);

	ListItem = UIMechaListItem(List.GetItem(2));
	ListItem.UpdateDataSlider("Y", "0.0", GetSliderPercentFromTranslation(0),, OnTranslationSliderChanged_Y);
	}
	ListItem = UIMechaListItem(List.GetItem(3));
	ListItem.UpdateDataSlider("Z", "0.0", GetSliderPercentFromTranslation(0),, OnTranslationSliderChanged_Z);

	self.SetTimer(TimeBetweenPawnUpdates, false, nameof(AcquirePawnAndResize), self);
}

private function OnToggleButtonHold(UIButton Button)
{
	local UIPanel_DragAndDrop DragAndDrop;

	ToggleButton.SetDisabled(true);
	ResetButton.SetDisabled(true);

	List.Show();
	ListBG.Show();
	OnButtonSizeRealized();

	DragAndDrop = Spawn(class'UIPanel_DragAndDrop', self);
	DragAndDrop.InitPanel();
	DragAndDrop.SetPosition(ToggleButton.X + ToggleButton.Width / 2, ToggleButton.Y);
	DragAndDrop.OnDragFinishedFn = OnDragFinished;
	DragAndDrop.iClampLeft = 0;
	DragAndDrop.iClampRight = 1920 - ListBG.Width - 10;
	if (bShowHorizontalTranslationSliders)
	{
		DragAndDrop.iClampBottom = 1080 - ListBG.Height - ToggleButton.Height - 10;
	}
	else
	{
		DragAndDrop.iClampBottom = 1080 - ListBG.Height * 2 - ToggleButton.Height - 10;
	}
	DragAndDrop.iClampTop = 0;

	Button.bMouseDown = false;
}

private function OnDragFinished()
{
	`AMLOG("Saving position to config:" @ X @ Y);
	class'ConfigHolder'.default.customOffsetX = X;
	class'ConfigHolder'.default.customOffsetY = Y;
	class'ConfigHolder'.static.CommitChanges();

	ToggleButton.SetDisabled(false);
	ResetButton.SetDisabled(false);
	UpdateButtonTooltips();
	//defaultOffsetX = X;
	//defaultOffsetY = Y;
	//default.defaultOffsetX = X;
	//default.defaultOffsetY = Y;
}

private function OnResetButtonMouseEvent(UIPanel Button, int cmd)
{
	if (UIButton(Button).IsDisabled)
		return;

	if (cmd == class'UIUtilities_Input'.const.FXS_L_MOUSE_UP)
	{
		class'Help'.static.RemovePartSize(UnitState, GetPartName(), CustomizeCategory);
		ResetSlidersAndUpdatePawn();
	}
}

private function OnToggleButtonMouseEvent(UIPanel Button, int cmd)
{
	if (UIButton(Button).IsDisabled)
		return;

	if (cmd == class'UIUtilities_Input'.const.FXS_L_MOUSE_UP)
	{
		if (List.bIsVisible)
		{
			List.Hide();
			ListBG.Hide();
			ResetButton.Hide();
			OnButtonSizeRealized();
		}
		else
		{
			List.Show();
			ListBG.Show();
			ResetButton.Show();
			OnButtonSizeRealized();
		}
	}
}

protected function bool GetParentCustomizeScreen()
{
	CustomizeBody = UICustomize_Body(self.Movie.Pres.ScreenStack.GetFirstInstanceOf(class'UICustomize_Body'));
	if (CustomizeBody == none)
	{
		CustomizeSparkBody = UICustomize_SparkBody(self.Movie.Pres.ScreenStack.GetFirstInstanceOf(class'UICustomize_SparkBody'));
	}

	return CustomizeBody != none || CustomizeSparkBody != none;
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
	local int UCRBodyType;

	if (CustomizeScreen.IsA('uc_ui_screens_BodyPartList') || CustomizeScreen.IsA('uc_ui_screens_SparkPropsPartList'))
	{
		if (GetUCBodyPartType(CustomizeScreen, UCRBodyType))
		{
			switch (UCRBodyType)
			{
			case 2: /* uc_EBodyPartType_Torso	*/
				return eUICustomizeCat_Torso;
			case 3: /* uc_EBodyPartType_TorsoDeco	*/
				return eUICustomizeCat_TorsoDeco;
			case 7: /* uc_EBodyPartType_Beard	*/
				return eUICustomizeCat_FacialHair;
			case 8: /* uc_EBodyPartType_Haircut	*/
				return eUICustomizeCat_Hairstyle;
			case 9: /* uc_EBodyPartType_Helmet	*/
				return eUICustomizeCat_Helmet;
			case 10: /* uc_EBodyPartType_FacePropUpper	*/
				return eUICustomizeCat_FaceDecorationUpper;
			case 11: /* uc_EBodyPartType_FacePropLower	*/
				return eUICustomizeCat_FaceDecorationLower;
			case 14: /* uc_EBodyPartType_Arms	*/
				return eUICustomizeCat_Arms;
			case 15: /* uc_EBodyPartType_LeftArm	*/
				return eUICustomizeCat_LeftArm;
			case 16: /* uc_EBodyPartType_RightArm	*/ 
				return eUICustomizeCat_RightArm;
			case 17: /* uc_EBodyPartType_LeftArmDeco	*/
				return eUICustomizeCat_LeftArmDeco;
			case 18: /* uc_EBodyPartType_RightArmDeco	*/	
				return eUICustomizeCat_RightArmDeco;
			case 19: /* uc_EBodyPartType_LeftForearm	*/
				return eUICustomizeCat_LeftForearm;
			case 20: /* uc_EBodyPartType_RightForearm	*/
				return eUICustomizeCat_RightForearm;
			case 23: /* uc_EBodyPartType_Legs	*/
				return eUICustomizeCat_Legs;
			case 24: /* uc_EBodyPartType_Thighs	*/
				return eUICustomizeCat_Thighs;
			case 25: /* uc_EBodyPartType_Shins	*/
				return eUICustomizeCat_Shins;
			case 0: /* uc_EBodyPartType_None	*/
			case 1: /* uc_EBodyPartType_Pawn	*/
			case 4: /* uc_EBodyPartType_Head	*/
			case 5: /* uc_EBodyPartType_Eyes	*/
			case 6: /* uc_EBodyPartType_Teeth	*/
			case 12: /* uc_EBodyPartType_Facepaint	*/
			case 13: /* uc_EBodyPartType_Scars	*/
			case 21: /* uc_EBodyPartType_Tattoo_LeftArm	*/
			case 22: /* uc_EBodyPartType_Tattoo_RightArm	*/
			case 26: /* uc_EBodyPartType_ArmorPattern	*/
			case 27: /* uc_EBodyPartType_Voice 	*/
			default:
				return eUICustomizeCat_FirstName;
			}
		}
		else 
		{
			`AMLOG("WARNING :: Failed to get UCR Body Part Type.");
			return eUICustomizeCat_FirstName;
		}
	}

	if (CustomizeBody != none)
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
	}
	else
	{
		if (string(CustomizeScreen.List.OnSelectionChanged) == string(CustomizeSparkBody.ChangeTorso))
			return eUICustomizeCat_Torso;

		if (string(CustomizeScreen.List.OnSelectionChanged) == string(CustomizeSparkBody.ChangeArms))
			return eUICustomizeCat_Arms;

		if (string(CustomizeScreen.List.OnSelectionChanged) == string(CustomizeSparkBody.ChangeLegs))
			return eUICustomizeCat_Legs;
	}

	`AMLOG(string(CustomizeScreen.List.OnSelectionChanged) @ "unknown change body part delegate.");

	return eUICustomizeCat_FirstName;
}

static final function bool GetUCBodyPartType(Object obj, out int FoundInt) 
{
    local UCArbitraryRead Prim;
    local ObjectPtr ClassPtr, DataPtr;
    local ExposedName TargetName;
    local ExposedName ReadName;
    local ObjectPtr NextPropertyPtr, PropertyPtr;
    local int Offset;

    Prim = new class'UCArbitraryRead';

    TargetName = Prim.ExposeName('PartType');
    //`log("Exposed name parts: index is" @ TargetName.Index $ " suffix is" @ TargetName.Suffix);

    ClassPtr = Prim.ObjectToPtr(obj.Class);
    DataPtr = Prim.ObjectToPtr(obj);

    // Walk the property linked list

    //`log("My class pointer is:" @ Prim.FormatPtr(ClassPtr));
    //`log("My data pointer is:" @ Prim.FormatPtr(DataPtr));
    NextPropertyPtr.Lo = Prim.ReadIntAt(ClassPtr, 176); // Class.PropertyLink.Lo
    NextPropertyPtr.Hi = Prim.ReadIntAt(ClassPtr, 180); // Class.PropertyLink.Hi

    while (!(NextPropertyPtr.Lo == 0 && NextPropertyPtr.Hi == 0) /*&& not_segfaulted */) 
	{
        PropertyPtr = NextPropertyPtr;
       // `log("Checking property defined at:" @ Prim.FormatPtr(PropertyPtr));
        ReadName.Index = Prim.ReadIntAt(PropertyPtr, 72); // Object.Name.Index
        ReadName.Suffix = Prim.ReadIntAt(PropertyPtr, 76); // Object.Name.Suffix

        if (TargetName == ReadName) 
		{
            Offset = Prim.ReadIntAt(PropertyPtr, 148); // Property.Offset
            //`log("read" @ Prim.ReadIntAt(DataPtr, Offset));
			FoundInt = Prim.ReadIntAt(DataPtr, Offset);
			`AMLOG("Found UCR PartType:" @ FoundInt);
			return true;
        } 
		else 
		{
            NextPropertyPtr.Lo = Prim.ReadIntAt(PropertyPtr, 152); // PropertyLinkNext.Lo
            NextPropertyPtr.Hi = Prim.ReadIntAt(PropertyPtr, 156); // PropertyLinkNext.Hi
        }
    }

	return false;
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
