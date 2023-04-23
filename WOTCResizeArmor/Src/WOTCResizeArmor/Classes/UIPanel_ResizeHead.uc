class UIPanel_ResizeHead extends UIPanel_ResizeArmor;

var private UICustomize_Head CustomizeHead;

protected function bool GetParentCustomizeScreen()
{
	CustomizeHead = UICustomize_Head(self.Movie.Pres.ScreenStack.GetFirstInstanceOf(class'UICustomize_Head'));
	return CustomizeHead != none;
}

protected function EUICustomizeCategory GetCustomizeCategory()
{
	// Cannot resize or translate the head, because every other part is attached to it.
	if (string(CustomizeScreen.List.OnSelectionChanged) == string(CustomizeHead.ChangeFace))
		return eUICustomizeCat_Face;

	if (string(CustomizeScreen.List.OnSelectionChanged) == string(CustomizeHead.ChangeHair))
		return eUICustomizeCat_Hairstyle;

	if (string(CustomizeScreen.List.OnSelectionChanged) == string(CustomizeHead.ChangeFacialHair))
		return eUICustomizeCat_FacialHair;

	if (string(CustomizeScreen.List.OnSelectionChanged) == string(CustomizeHead.ChangeHelmet))
		return eUICustomizeCat_Helmet;

	if (string(CustomizeScreen.List.OnSelectionChanged) == string(CustomizeHead.ChangeFaceUpperProps))
		return eUICustomizeCat_FaceDecorationUpper;

	if (string(CustomizeScreen.List.OnSelectionChanged) == string(CustomizeHead.ChangeFaceLowerProps))
		return eUICustomizeCat_FaceDecorationLower;

	return eUICustomizeCat_FirstName;
}

protected function name GetPartName()
{
	switch(CustomizeCategory)
	{
	case eUICustomizeCat_Face:
		return UnitPawn.m_kAppearance.nmHead;
	case eUICustomizeCat_Hairstyle:
		return UnitPawn.m_kAppearance.nmHaircut;
	case eUICustomizeCat_FacialHair:
		return UnitPawn.m_kAppearance.nmBeard;
	case eUICustomizeCat_Helmet:
		return UnitPawn.m_kAppearance.nmHelmet;
	case eUICustomizeCat_FaceDecorationUpper:
		return UnitPawn.m_kAppearance.nmFacePropUpper;
	case eUICustomizeCat_FaceDecorationLower:
		return UnitPawn.m_kAppearance.nmFacePropLower;
	default:
		return '';
	}
	return '';
}
