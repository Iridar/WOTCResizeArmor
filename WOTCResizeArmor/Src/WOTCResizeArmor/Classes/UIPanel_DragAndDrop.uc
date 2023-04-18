class UIPanel_DragAndDrop extends UIPanel;

var private UIImage DragUp;
var private UIImage DragRight;
var private UIImage DragDown;
var private UIImage DragLeft;
var private UIImage Center;

var private UIImage DragUpStrong;
var private UIImage DragRightStrong;
var private UIImage DragDownStrong;
var private UIImage DragLeftStrong;

var private int OffsetX;
var private int OffsetY;
var private bool bDrag;

var int Jump;
var int DragWeak;
var int DragStrong;

var bool bClampToScreen;
var int	iClampLeft;
var int iClampRight;
var int iClampTop;
var int iClampBottom;

var delegate<OnDragFinished> OnDragFinishedFn;

delegate OnDragFinished();

simulated function UIPanel InitPanel(optional name InitName, optional name InitLibID)
{
	super.InitPanel(InitName, InitLibID);

	// Spawning on parent panel for easier use of coordinates.
	Center = ParentPanel.Spawn(class'UIImage', ParentPanel);
	Center.InitImage(, "img:///gfxDifficultyMenu.PC_mouseLeft", OnCenterClicked);
	Center.ProcessMouseEvents(OnCenterMouseEvent);
	
	DragUp = ParentPanel.Spawn(class'UIImage', ParentPanel);
	DragUp.InitImage(, "img:///gfxDifficultyMenu.PC_arrowUP", OnUpClicked);
	DragUp.ProcessMouseEvents(OnDragUp);

	DragRight = ParentPanel.Spawn(class'UIImage', ParentPanel);
	DragRight.InitImage(, "img:///gfxDifficultyMenu.PC_arrowRIGHT", OnRightClicked);
	DragRight.ProcessMouseEvents(OnDragRight);

	DragDown = ParentPanel.Spawn(class'UIImage', ParentPanel);
	DragDown.InitImage(, "img:///gfxDifficultyMenu.PC_arrowDOWN", OnDownClicked);
	DragDown.ProcessMouseEvents(OnDragDown);
	
	DragLeft = ParentPanel.Spawn(class'UIImage', ParentPanel);
	DragLeft.InitImage(, "img:///gfxDifficultyMenu.PC_arrowLEFT", OnLeftClicked);
	DragLeft.ProcessMouseEvents(OnDragLeft);

	DragUpStrong = ParentPanel.Spawn(class'UIImage', ParentPanel);
	DragUpStrong.InitImage(, "img:///gfxDifficultyMenu.PC_arrowUP", OnUpClicked);
	DragUpStrong.ProcessMouseEvents(OnDragUpStrong);
	
	DragRightStrong = ParentPanel.Spawn(class'UIImage', ParentPanel);
	DragRightStrong.InitImage(, "img:///gfxDifficultyMenu.PC_arrowRIGHT", OnRightClicked);
	DragRightStrong.ProcessMouseEvents(OnDragRightStrong);
	
	DragDownStrong = ParentPanel.Spawn(class'UIImage', ParentPanel);
	DragDownStrong.InitImage(, "img:///gfxDifficultyMenu.PC_arrowDOWN", OnDownClicked);
	DragDownStrong.ProcessMouseEvents(OnDragDownStrong);
	
	DragLeftStrong = ParentPanel.Spawn(class'UIImage', ParentPanel);
	DragLeftStrong.InitImage(, "img:///gfxDifficultyMenu.PC_arrowLEFT", OnLeftClicked);
	DragLeftStrong.ProcessMouseEvents(OnDragLeftStrong);

	SetTimer(0.1f, true, nameof(PerformDrag), self);

	return self;
}

simulated function UIPanel SetPosition(float NewX, float NewY)
{	
	Center.SetPosition(NewX, NewY);
	DragUp.SetPosition(NewX, NewY - 32);
	DragRight.SetPosition(NewX + 32, NewY);
	DragDown.SetPosition(NewX, NewY + 32);
	DragLeft.SetPosition(NewX - 32, NewY);

	DragUpStrong.SetPosition(NewX, NewY - 64);
	DragRightStrong.SetPosition(NewX + 64, NewY);
	DragDownStrong.SetPosition(NewX, NewY + 64);
	DragLeftStrong.SetPosition(NewX - 64, NewY);

	return super.SetPosition(NewX, NewY);
}

private function OnUpClicked(UIImage Image)
{
	OffsetY = -Jump;
}
private function OnRightClicked(UIImage Image)
{
	OffsetX = Jump;
}
private function OnDownClicked(UIImage Image)
{
	OffsetY = Jump;
}
private function OnLeftClicked(UIImage Image)
{
	OffsetX = -Jump;
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
		OffsetY = -DragWeak;
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
		OffsetX = DragWeak;
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
		OffsetY = DragWeak;
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
		OffsetX = -DragWeak;
	}
	else if (cmd == class'UIUtilities_Input'.const.FXS_L_MOUSE_OUT)
	{
		bDrag = false;
		OffsetX = 0;
	}
}

private function OnDragUpStrong(UIPanel Panel, int Cmd)
{
	if (cmd == class'UIUtilities_Input'.const.FXS_L_MOUSE_IN)
	{
		bDrag = true;
		OffsetY = -DragStrong;
	}
	else if (cmd == class'UIUtilities_Input'.const.FXS_L_MOUSE_OUT)
	{
		bDrag = false;
		OffsetY = 0;
	}
}
private function OnDragRightStrong(UIPanel Panel, int Cmd)
{
	if (cmd == class'UIUtilities_Input'.const.FXS_L_MOUSE_IN)
	{
		bDrag = true;
		OffsetX = DragStrong;
	}
	else if (cmd == class'UIUtilities_Input'.const.FXS_L_MOUSE_OUT)
	{
		bDrag = false;
		OffsetX = 0;
	}
}
private function OnDragDownStrong(UIPanel Panel, int Cmd)
{
	if (cmd == class'UIUtilities_Input'.const.FXS_L_MOUSE_IN)
	{
		bDrag = true;
		OffsetY = DragStrong;
	}
	else if (cmd == class'UIUtilities_Input'.const.FXS_L_MOUSE_OUT)
	{
		bDrag = false;
		OffsetY = 0;
	}
}
private function OnDragLeftStrong(UIPanel Panel, int Cmd)
{
	if (cmd == class'UIUtilities_Input'.const.FXS_L_MOUSE_IN)
	{
		bDrag = true;
		OffsetX = -DragStrong;
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

		if (!bClampToScreen)
			return;

		if (ParentPanel.X < iClampLeft)
		{
			ParentPanel.SetX(iClampLeft);
		}
		else if (ParentPanel.X > iClampRight )
		{
			ParentPanel.SetX(iClampRight);
		}
		if (ParentPanel.Y > iClampBottom )
		{
			ParentPanel.SetY(iClampBottom);
		}
		else if (ParentPanel.Y < iClampTop )
		{
			ParentPanel.SetY(iClampTop);
		}
	}
}

simulated event Removed()
{
	DragUp.Remove();
	DragRight.Remove();
	DragDown.Remove();
	DragLeft.Remove();
	Center.Remove();

	DragUpStrong.Remove();
	DragRightStrong.Remove();
	DragDownStrong.Remove();
	DragLeftStrong.Remove();

	if (OnDragFinishedFn != none)
		OnDragFinishedFn();

	super.Removed();
}

defaultproperties
{
	DragWeak = 1
	DragStrong = 5
	Jump = 100
	bClampToScreen = true
}
