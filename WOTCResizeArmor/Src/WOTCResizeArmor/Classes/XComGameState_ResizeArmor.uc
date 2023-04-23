class XComGameState_ResizeArmor extends XComGameState_BaseObject;

var array<ArmorSizeStruct> ArmorSizes;

// ------------------------------------------------------------
// 							GETTERS

static final function XComGameState_ResizeArmor Get(optional XComGameState UseGameState, optional bool bIgnoreHistory)
{
	local XComGameState_ResizeArmor StateObject;
	
	if (UseGameState != none)
	{
		foreach UseGameState.IterateByClassType(class'XComGameState_ResizeArmor', StateObject)
		{
			return StateObject;
		}
	}
	if (bIgnoreHistory)
		return none;
	
	return XComGameState_ResizeArmor(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_ResizeArmor', true));
}

static final function XComGameState_ResizeArmor GetOrCreate(optional XComGameState UseGameState)
{
	local XComGameState NewGameState;
	local XComGameState_ResizeArmor StateObject;
	
	if (UseGameState != none)
	{
		foreach UseGameState.IterateByClassType(class'XComGameState_ResizeArmor', StateObject)
		{
			return StateObject;
		}
	}
	StateObject = XComGameState_ResizeArmor(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_ResizeArmor', true));
	if (StateObject != none)
	{
		return StateObject;
	}
	
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Creating XComGameState_ResizeArmor");
	StateObject = XComGameState_ResizeArmor(NewGameState.CreateNewStateObject(class'XComGameState_ResizeArmor'));
	`XCOMHISTORY.AddGameStateToHistory(NewGameState);
	
	return StateObject;
}

static final function XComGameState_ResizeArmor GetOrCreateAndPrep(XComGameState NewGameState)
{
	local XComGameState_ResizeArmor StateObject;
	
	foreach NewGameState.IterateByClassType(class'XComGameState_ResizeArmor', StateObject)
	{
		return StateObject;
	}
	
	StateObject = XComGameState_ResizeArmor(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_ResizeArmor', true));
	if (StateObject != none)
	{
		return XComGameState_ResizeArmor(NewGameState.ModifyStateObject(StateObject.Class, StateObject.ObjectID));
	}
	
	return XComGameState_ResizeArmor(NewGameState.CreateNewStateObject(class'XComGameState_ResizeArmor'));
}

static final function XComGameState_ResizeArmor GetAndPrep(XComGameState NewGameState)
{
	local XComGameState_ResizeArmor StateObject;
	
	foreach NewGameState.IterateByClassType(class'XComGameState_ResizeArmor', StateObject)
	{
		return StateObject;
	}
	
	StateObject = XComGameState_ResizeArmor(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_ResizeArmor', true));
	if (StateObject != none)
	{
		return XComGameState_ResizeArmor(NewGameState.ModifyStateObject(StateObject.Class, StateObject.ObjectID));
	}
	
	return none;
}


