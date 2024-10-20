class X2DLCInfo_WOTCResizeArmor extends X2DownloadableContentInfo;

// Principles of morphing:
// 1. Proportions are adjusted by playing an additive animation that alters the skeleton structure by making some of the bones longer or shorter or just moving them. This can be used to e.g. make shoulders wider.
// 2. At the same time, the mesh of cosmetics is adjusted by applying a morph to it.

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
	if (XComHumanPawn(Pawn) == none || UnitState == none)
		return;

	class'Help'.static.ResizeArmor(UnitState, Pawn);
}

// ======================================================

static function UnitPawnPostInitAnimTree(XComGameState_Unit UnitState, XComUnitPawnNativeBase Pawn, SkeletalMeshComponent SkelComp)
{
	local AnimTree AnimTreeTemplate;

	if (XComHumanPawn(Pawn) == none)
	{
		if (XComHumanPawn(Pawn) == none) `AMLOG("ERRPR Pawn is none!");
		else `AMLOG("Have pawn");

		if (UnitState == none) `AMLOG("ERROR Unit State is none!");
		else `AMLOG("Have Unit State:" @ UnitState.GetFullName());

		return;
	}

	AnimTreeTemplate = Pawn.Mesh.AnimTreeTemplate;
	if (AnimTreeTemplate.GetPackageName() == 'Soldier_ANIMTREE' && AnimTreeTemplate.Name == 'AT_Soldier')
	{
		`AMLOG("Patching Resizable Armor AnimTree for:" @ Pawn.Class.Name);

		AnimTreeTemplate = AnimTree(`CONTENT.RequestGameArchetype("IRIResizableArmor.AT_Soldier_ResizableArmor", class'AnimTree'));
		//AnimTreeTemplate = AnimTree(`CONTENT.RequestGameArchetype("IRIResizableArmor.AT_Soldier_Original", class'AnimTree'));
		//AnimTreeTemplate = AnimTree(`CONTENT.RequestGameArchetype("IRIResizableArmor.AT_Soldier_XSoldier", class'AnimTree'));
		if (AnimTreeTemplate == none)
		{
			`AMLOG("Failed to acquire AnimTree");
			return;
		}
		SkelComp.SetAnimTreeTemplate(AnimTreeTemplate);
	}
}

// ------------------------------------------------------

// AnimTree''

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