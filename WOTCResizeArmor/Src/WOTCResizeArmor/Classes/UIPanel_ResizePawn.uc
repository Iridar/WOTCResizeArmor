class UIPanel_ResizePawn extends UIPanel_ResizeArmor;

protected function bool GetParentCustomizeScreen()
{
	return true;
}

protected function EUICustomizeCategory GetCustomizeCategory()
{
	return eUICustomizeCat_Face;
}

protected function name GetPartName()
{
	return class'Help'.default.PawnPartName;
}
defaultproperties
{
	bShowHorizontalTranslationSliders = false
}
