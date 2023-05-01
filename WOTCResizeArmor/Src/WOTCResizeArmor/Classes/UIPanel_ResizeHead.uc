class UIPanel_ResizeHead extends UIPanel_ResizeArmor;

var private UICustomize_Head CustomizeHead;

protected function bool GetParentCustomizeScreen()
{
	CustomizeHead = UICustomize_Head(self.Movie.Pres.ScreenStack.GetFirstInstanceOf(class'UICustomize_Head'));
	return CustomizeHead != none;
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

	// Cannot resize or translate the head, because every other part is attached to it.
	//if (string(CustomizeScreen.List.OnSelectionChanged) == string(CustomizeHead.ChangeFace))
	//	return eUICustomizeCat_Face;

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
