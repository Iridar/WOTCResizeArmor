class UIPanel_DragAndDrop extends UIPanel;

var private UIImage DragUp;
var private UIImage DragRight;
var private UIImage DragDown;
var private UIImage DragLeft;
var private UIImage Center;

var private int OffsetX;
var private int OffsetY;
var private bool bDrag;

var delegate<OnDragFinished> OnDragFinishedFn;

delegate OnDragFinished();

simulated function UIPanel InitPanel(optional name InitName, optional name InitLibID)
{
	super.InitPanel(InitName, InitLibID);

	Center = ParentPanel.Spawn(class'UIImage', ParentPanel);
	Center.InitImage(, "img:///gfxDifficultyMenu.PC_mouseLeft", OnCenterClicked);
	Center.ProcessMouseEvents(OnCenterMouseEvent);
	
	DragUp = ParentPanel.Spawn(class'UIImage', ParentPanel);
	DragUp.InitImage(, "img:///gfxDifficultyMenu.PC_arrowUP");
	DragUp.ProcessMouseEvents(OnDragUp);

	DragRight = ParentPanel.Spawn(class'UIImage', ParentPanel);
	DragRight.InitImage(, "img:///gfxDifficultyMenu.PC_arrowRIGHT");
	DragRight.ProcessMouseEvents(OnDragRight);

	DragDown = ParentPanel.Spawn(class'UIImage', ParentPanel);
	DragDown.InitImage(, "img:///gfxDifficultyMenu.PC_arrowDOWN");
	DragDown.ProcessMouseEvents(OnDragDown);
	
	DragLeft = ParentPanel.Spawn(class'UIImage', ParentPanel);
	DragLeft.InitImage(, "img:///gfxDifficultyMenu.PC_arrowLEFT");
	DragLeft.ProcessMouseEvents(OnDragLeft);

	SetTimer(0.1f, true, nameof(PerformDrag), self);

	return self;
}

simulated function UIPanel SetPosition(float NewX, float NewY)
{	
	Center.SetPosition(NewX + 32, NewY + 32);
	DragUp.SetPosition(NewX + 32, NewY);
	DragRight.SetPosition(NewX + 64, NewY + 32);
	DragDown.SetPosition(NewX + 32, NewY + 64);
	DragLeft.SetPosition(NewX, NewY + 32);

	return super.SetPosition(NewX, NewY);
}

private function OnCenterClicked(UIImage Image)
{
	ClearTimer(nameof(PerformDrag), self);
	Remove();
}

private function OnCenterMouseEvent(UIPanel Panel, int Cmd)
{
	switch (Cmd)
	{
	case class'UIUtilities_Input'.const.FXS_L_MOUSE_RELEASE_OUTSIDE:
	case class'UIUtilities_Input'.const.FXS_L_MOUSE_UP:
		ClearTimer(nameof(PerformDrag), self);
		Remove();
		break;
	default:
		break;
	}
}


private function OnDragUp(UIPanel Panel, int Cmd)
{
	if (cmd == class'UIUtilities_Input'.const.FXS_L_MOUSE_IN)
	{
		bDrag = true;
		OffsetY = -1;
	}
	else if (cmd == class'UIUtilities_Input'.const.FXS_L_MOUSE_OUT)
	{
		bDrag = false;
		OffsetY = 0;
	}
}
private function OnDragRight(UIPanel Panel, int Cmd)
{
	if (cmd == class'UIUtilities_Input'.const.FXS_L_MOUSE_IN)
	{
		bDrag = true;
		OffsetX = 1;
	}
	else if (cmd == class'UIUtilities_Input'.const.FXS_L_MOUSE_OUT)
	{
		bDrag = false;
		OffsetX = 0;
	}
}
private function OnDragDown(UIPanel Panel, int Cmd)
{
	if (cmd == class'UIUtilities_Input'.const.FXS_L_MOUSE_IN)
	{
		bDrag = true;
		OffsetY = 1;
	}
	else if (cmd == class'UIUtilities_Input'.const.FXS_L_MOUSE_OUT)
	{
		bDrag = false;
		OffsetY = 0;
	}
}
private function OnDragLeft(UIPanel Panel, int Cmd)
{
	if (cmd == class'UIUtilities_Input'.const.FXS_L_MOUSE_IN)
	{
		bDrag = true;
		OffsetX = -1;
	}
	else if (cmd == class'UIUtilities_Input'.const.FXS_L_MOUSE_OUT)
	{
		bDrag = false;
		OffsetX = 0;
	}
}

private function PerformDrag()
{
	if (bDrag)
	{
		ParentPanel.SetPosition(ParentPanel.X + OffsetX, ParentPanel.Y + OffsetY);
	}
}

simulated event Removed()
{
	DragUp.Remove();
	DragRight.Remove();
	DragDown.Remove();
	DragLeft.Remove();
	Center.Remove();

	if (OnDragFinishedFn != none)
		OnDragFinishedFn();

	super.Removed();
}
