class X2DLCInfo_WOTCResizeArmor extends X2DownloadableContentInfo;

exec function ResizeArmorWipe()
{
	local XComGameState_ResizeArmor ResizeArmor;
	local XComGameState				NewGameState;

	ResizeArmor = class'XComGameState_ResizeArmor'.static.Get();
	if (ResizeArmor != none)
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Removing XComGameState_ResizeArmor");
		NewGameState.RemoveStateObject(ResizeArmor.ObjectID);
		`GAMERULES.SubmitGameState(NewGameState);
	}
}

//exec function SetOffset(int X, int Y)
//{	
//	class'UIPanel_ResizeArmor'.default.defaultOffsetX = X;
//	class'UIPanel_ResizeArmor'.default.defaultOffsetY = Y;
//}
//
//exec function SetWidth(int X)
//{	
//	class'UIPanel_ResizeArmor'.default.defaultWidth = X;
//}
//exec function SetHeight(int X)
//{	
//	class'UIPanel_ResizeArmor'.default.defaultHeight = X;
//}

static function string DLCAppendSockets(XComUnitPawn Pawn)
{
	local XComGameState_Unit UnitState;

	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(Pawn.ObjectID));
	if (UnitState == none)
		return "";

	class'Help'.static.ResizeArmor(UnitState, Pawn);

	return "";
}
static function UpdateAnimations(out array<AnimSet> CustomAnimSets, XComGameState_Unit UnitState, XComUnitPawn Pawn)
{
	class'Help'.static.ResizeArmor(UnitState, Pawn);
}


/*
static function UpdateAnimations(out array<AnimSet> CustomAnimSets, XComGameState_Unit UnitState, XComUnitPawn Pawn)
{	
	local Attachment			MeshAttach;
	local MeshComponent			MeshComp;
	local vector Translation;
	local float Scale;
	local int i;
	
	`AMLOG("========================================================:" @ UnitState.GetFullName() @ Pawn.m_kTorsoComponent.Translation.X @ Pawn.m_kTorsoComponent.Translation.Y @ Pawn.m_kTorsoComponent.Translation.Z);

	Translation.Z = 500;
	Pawn.m_kDecoKitMC.SetScale(FRand());
	
	Pawn.m_kTorsoComponent.SetTranslation(Translation);
	Pawn.m_kArmsMC.SetScale(FRand()); 
	

	//foreach Pawn.Mesh.Attachments(MeshAttach, i)
	//{	
	//	MeshComp = MeshComponent(MeshAttach.Component);
	//
	//	Scale = FRand();
	//	
	//	`AMLOG(i @ MeshAttach.BoneName @ MeshAttach.SocketName @ "MeshComp:" @ PathName(MeshComp) @ Scale);
	//
	//	MeshComp.SetScale(Scale);
	//	MeshAttach.RelativeScale.X = Scale;
	//	MeshAttach.RelativeScale.Y = Scale;
	//	MeshAttach.RelativeScale.Z = Scale;
	//}
	`AMLOG("--------------------------------------------------------");
}*/