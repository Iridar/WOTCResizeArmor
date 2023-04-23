//  FILE:    Help.uc
//  AUTHOR:  Iridar  --  20/04/2022
//  PURPOSE: Helper class for static functions and script snippet repository.     
//---------------------------------------------------------------------------------------

/*
TODO: 
3. MCM Support?
4. When resizing arms, resize weapons as well. Might not be possible? Unless we resize the entire pawn mesh, and then all other parts individually in the opposite direction to compensate.
5. Progressive resizing: when resizing a body part, also resize all other parts attached to it.
*/

// Resizing legs moves all parts except the head

class Help extends Object abstract config(UI);

var privatewrite name PawnPartName;
var config bool bLog;

struct ArmorSizeStruct
{
	var int		UnitID;
	var name	PartName;
	var EUICustomizeCategory Category;
	var float	PartSize;
	var vector	Translation;

	structdefaultproperties
	{
		PartSize = 1.0f
	}
};

static final function SetPartSize(XComGameState_Unit UnitState, const name PartName, const EUICustomizeCategory Category, const float PartSize)
{
	local XComGameState				NewGameState;
	local XComGameState_ResizeArmor StateObject;
	local ArmorSizeStruct			ArmorSize;
	local int i;

	`AMLOG("Setting scale:" @ PartSize @ PartName);

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Set Part Size:" @ PartName @ PartSize);
	StateObject = class'XComGameState_ResizeArmor'.static.GetOrCreateAndPrep(NewGameState);

	for (i = 0; i < StateObject.ArmorSizes.Length; i++)
	{
		if (StateObject.ArmorSizes[i].UnitID == UnitState.ObjectID &&
			StateObject.ArmorSizes[i].PartName == PartName &&
			StateObject.ArmorSizes[i].Category == Category)
		{
			StateObject.ArmorSizes[i].PartSize = PartSize;
			`GAMERULES.SubmitGameState(NewGameState);
			return;
		}
	}

	ArmorSize.UnitID = UnitState.ObjectID;
	ArmorSize.PartName = PartName;
	ArmorSize.Category = Category;
	ArmorSize.PartSize = PartSize;

	StateObject.ArmorSizes.AddItem(ArmorSize);

	`GAMERULES.SubmitGameState(NewGameState);
}

static final function bool GetPartSize(XComGameState_Unit UnitState, const name PartName, const EUICustomizeCategory Category, out float PartSize)
{	
	local XComGameState_ResizeArmor StateObject;
	local ArmorSizeStruct ArmorSize;

	StateObject = class'XComGameState_ResizeArmor'.static.Get();
	if (StateObject == none)
	{
		PartSize = 1.0f;
		return false;
	}

	foreach StateObject.ArmorSizes(ArmorSize)
	{
		if (ArmorSize.UnitID == UnitState.ObjectID &&
			ArmorSize.PartName == PartName &&
			ArmorSize.Category == Category)
		{
			PartSize = ArmorSize.PartSize;
			return true;
		}
	}
	
	PartSize = 1.0f;
	return false;
}

static final function ResizeArmor(XComGameState_Unit UnitState, XComUnitPawn Pawn)
{
	
	ResizeComponent(UnitState, default.PawnPartName,					eUICustomizeCat_Face,					Pawn.Mesh);
	// Cannot resize or translate the head, because every other part is attached to it.
	//ResizeComponent(UnitState, UnitState.kAppearance.nmHead,			eUICustomizeCat_Face,					Pawn.m_kHeadMeshComponent);
	//ResizeComponent(UnitState, UnitState.kAppearance.nmHead,			eUICustomizeCat_Face,					Pawn.m_kEyeMC);
	//ResizeComponent(UnitState, UnitState.kAppearance.nmHead,			eUICustomizeCat_Face,					Pawn.m_kTeethMC);
	ResizeComponent(UnitState, UnitState.kAppearance.nmHelmet,			eUICustomizeCat_Helmet,					Pawn.m_kHelmetMC);
	ResizeComponent(UnitState, UnitState.kAppearance.nmHaircut,			eUICustomizeCat_Hairstyle,				Pawn.m_kHairMC);
	ResizeComponent(UnitState, UnitState.kAppearance.nmBeard,			eUICustomizeCat_FacialHair,				Pawn.m_kBeardMC);
	ResizeComponent(UnitState, UnitState.kAppearance.nmFacePropUpper,	eUICustomizeCat_FaceDecorationUpper,	Pawn.m_kUpperFacialMC);
	ResizeComponent(UnitState, UnitState.kAppearance.nmFacePropLower,	eUICustomizeCat_FaceDecorationLower,	Pawn.m_kLowerFacialMC);
	//ResizeComponent(UnitState, UnitState.kAppearance.nmTorso,			eUICustomizeCat_Hairstyle,			Pawn.HairComponent);

	ResizeComponent(UnitState, UnitState.kAppearance.nmTorso,			eUICustomizeCat_Torso,			Pawn.m_kTorsoComponent);
	ResizeComponent(UnitState, UnitState.kAppearance.nmArms,			eUICustomizeCat_Arms,			Pawn.m_kArmsMC);
	ResizeComponent(UnitState, UnitState.kAppearance.nmLegs,			eUICustomizeCat_Legs,			Pawn.m_kLegsMC);
	ResizeComponent(UnitState, UnitState.kAppearance.nmLeftArm,			eUICustomizeCat_LeftArm,		Pawn.m_kLeftArm);
	ResizeComponent(UnitState, UnitState.kAppearance.nmRightArm,		eUICustomizeCat_RightArm,		Pawn.m_kRightArm);
	ResizeComponent(UnitState, UnitState.kAppearance.nmLeftArmDeco,		eUICustomizeCat_LeftArmDeco,	Pawn.m_kLeftArmDeco);
	ResizeComponent(UnitState, UnitState.kAppearance.nmRightArmDeco,	eUICustomizeCat_RightArmDeco,	Pawn.m_kRightArmDeco);
	ResizeComponent(UnitState, UnitState.kAppearance.nmLeftForearm,		eUICustomizeCat_LeftForearm,	Pawn.m_kLeftForearmMC);
	ResizeComponent(UnitState, UnitState.kAppearance.nmRightForearm,	eUICustomizeCat_RightForearm,	Pawn.m_kRightForearmMC);
	ResizeComponent(UnitState, UnitState.kAppearance.nmThighs,			eUICustomizeCat_Thighs,			Pawn.m_kThighsMC);
	ResizeComponent(UnitState, UnitState.kAppearance.nmShins,			eUICustomizeCat_Shins,			Pawn.m_kShinsMC);
	ResizeComponent(UnitState, UnitState.kAppearance.nmTorsoDeco,		eUICustomizeCat_TorsoDeco,		Pawn.m_kTorsoDecoMC);
}

static private function ResizeComponent(XComGameState_Unit UnitState, const name PartName, const EUICustomizeCategory Category, SkeletalMeshComponent MeshComp)
{
	local ArmorSizeStruct ArmorSize;
	local float	PartSize;
	local vector Translation;

	if (PartName == '' || MeshComp == none)
		return;

	FindArmorSize(UnitState, PartName, Category, ArmorSize);
	PartSize = ArmorSize.PartSize;
	Translation = ArmorSize.Translation;

	if (MeshComp.Scale != PartSize)
	{
		`AMLOG(UnitState.GetFullName() @ PartName @ MeshComp.Scale @ "->" @ PartSize);
	}

	MeshComp.SetScale(PartSize);

	if (Category != eUICustomizeCat_Legs && Category != eUICustomizeCat_Face)
	{
		// If this part isn't legs, then adjust its position based on its scale
		Translation.Z += (1 - PartSize) * 100;
		// And adjust poistion based on scale of legs, if they are scaled.
		if (FindArmorSize(UnitState, UnitState.kAppearance.nmLegs, eUICustomizeCat_Legs, ArmorSize))
		{
			PartSize = ArmorSize.PartSize;
			Translation.Z -= (1 - PartSize) * 50;
		}
	}

	if (Category == eUICustomizeCat_Face)
	{
		Translation.Z -= 64;
	}
	if (MeshComp.Translation != Translation)
	{
		`AMLOG(UnitState.GetFullName() @ PartName @ MeshComp.Translation.X @ MeshComp.Translation.Y @ MeshComp.Translation.Z @ "->" @ Translation.X @ Translation.Y @ Translation.Z);
	}
	MeshComp.SetTranslation(Translation);
}



static final function bool FindArmorSize(XComGameState_Unit UnitState, const name PartName, const EUICustomizeCategory Category, out ArmorSizeStruct _ArmorSize)
{
	local XComGameState_ResizeArmor StateObject;
	local ArmorSizeStruct ArmorSize;

	StateObject = class'XComGameState_ResizeArmor'.static.Get();
	if (StateObject == none)
		return false;

	foreach StateObject.ArmorSizes(ArmorSize)
	{
		if (ArmorSize.UnitID == UnitState.ObjectID &&
			ArmorSize.PartName == PartName &&
			ArmorSize.Category == Category)
		{
			_ArmorSize = ArmorSize;
			return true;
		}
	}
	return false;
} 

static final function SetPartTranslation(XComGameState_Unit UnitState, const name PartName, const EUICustomizeCategory Category, const vector Translation)
{
	local XComGameState				NewGameState;
	local XComGameState_ResizeArmor StateObject;
	local ArmorSizeStruct			ArmorSize;
	local int i;

	`AMLOG("Setting translation:" @ Translation.X @ Translation.Y @ Translation.Z @ PartName);

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Setting translation:" @ Translation.X @ Translation.Y @ Translation.Z @ PartName);
	StateObject = class'XComGameState_ResizeArmor'.static.GetOrCreateAndPrep(NewGameState);

	for (i = 0; i < StateObject.ArmorSizes.Length; i++)
	{
		if (StateObject.ArmorSizes[i].UnitID == UnitState.ObjectID &&
			StateObject.ArmorSizes[i].PartName == PartName &&
			StateObject.ArmorSizes[i].Category == Category)
		{
			StateObject.ArmorSizes[i].Translation = Translation;
			`GAMERULES.SubmitGameState(NewGameState);
			return;
		}
	}

	ArmorSize.UnitID = UnitState.ObjectID;
	ArmorSize.PartName = PartName;
	ArmorSize.Category = Category;
	ArmorSize.Translation = Translation;

	StateObject.ArmorSizes.AddItem(ArmorSize);

	`GAMERULES.SubmitGameState(NewGameState);
}


/*

static final function bool GetPartPosition(XComGameState_Unit UnitState, const name PartName, out vector PartPosition)
{	
	local UnitValue UV;
	local name ValueName;

	ValueName = name(PartName @ default.PositionSuffix); 

	if (UnitState.GetUnitValue(ValueName, UV))
	{
		PartPosition.Z = -UV.fValue;
		return true;
	}

	return false;
}*/

	

/*

### Creating and Submitting a Game State

local XComGameState NewGameState;

NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Optional Debug Comment");

`GAMERULES.SubmitGameState(NewGameState);

### Random Number Generation

FRand() returns a random `float` value from the [0; 1] range. 
int(x * FRand()) - returns a random `int` value from [0; x] range.

FRand() can only return 32 768 distinct results. (c) robojumper

`SYNC_FRAND() - returns a random `flaot` value from [0; 1) range
`SYNC_FRAND_STATIC()

`SYNC_RAND(x) - returns a random `int` value from [0; x) range.
`SYNC_RAND_STATIC(x)

`SYNC_VRAND() - returns a random `vector`, each component of the vector will have value from (-1; 1) range.
`SYNC_VRAND_STATIC()

`SYNC_VRAND() * x - return a random `vector` where each component is from the (-x; x) range.

### Action Points

class'X2CharacterTemplateManager'.default.StandardActionPoint
class'X2CharacterTemplateManager'.default.MoveActionPoint
class'X2CharacterTemplateManager'.default.OverwatchReserveActionPoint
class'X2CharacterTemplateManager'.default.PistolOverwatchReserveActionPoint
class'X2CharacterTemplateManager'.default.GremlinActionPoint
class'X2CharacterTemplateManager'.default.RunAndGunActionPoint
class'X2CharacterTemplateManager'.default.EndBindActionPoint
class'X2CharacterTemplateManager'.default.GOHBindActionPoint
class'X2CharacterTemplateManager'.default.CounterattackActionPoint
class'X2CharacterTemplateManager'.default.UnburrowActionPoint
class'X2CharacterTemplateManager'.default.ReturnFireActionPoint
class'X2CharacterTemplateManager'.default.DeepCoverActionPoint
class'X2CharacterTemplateManager'.default.MomentumActionPoint
class'X2CharacterTemplateManager'.default.SkirmisherInterruptActionPoint


### Ability Icon Colors

'eAbilitySource_Perk': yellow
'eAbilitySource_Debuff': red
'eAbilitySource_Psionic': purple
'eAbilitySource_Commander': green 
'eAbilitySource_Item': blue 
'eAbilitySource_Standard': blue

### Persistent Effects applied to Units

if (UnitState.IsUnitAffectedByEffectName('NameOfTheEffect'))
{
    // Do stuff
}

# Get an effect's Effect State from unit

local XComGameState_Effect EffectState;

EffectState = UnitState.GetUnitAffectedByEffectState('NameOfTheEffect');

if (EffectState != none)
{
    // Do stuff
}

# Iterate over all effects on unit

local StateObjectReference EffectRef;
local XComGameStateHistory History;
local XComGameState_Effect EffectState;

History = `XCOMHISTORY;

foreach UnitState.AffectedByEffects(EffectRef)
{
    EffectState = XComGameState_Effect(History.GetGameStateForObjectID(EffectRef.ObjectID));

    // Do stuff with EffectState
}


### Working with ClassDefaultObjects

class'XComEngine'.static.GetClassDefaultObject(class SeachClass);
class'XComEngine'.static.GetClassDefaultObjectByName(name ClassName);

// This method will give you an array of CDOs for the specified class and all of its subclasses, in case you need to handle them as well.
class'XComEngine'.static.GetClassDefaultObjects(class SeachClass);

class'Engine'.static.FindClassDefaultObject(string ClassName)

### Check if a Unit can see a Location

local XComGameState_Unit UnitState;
local TTile TileLocation;

if (class'X2TacticalVisibilityHelpers'.static.CanUnitSeeLocation(UnitState.ObjectID, TileLocation))
{
    // Do stuff
}

### Modnames of commonly required mods

PrototypeArmoury
CovertInfiltration
LongWarOfTheChosen
XCOM2RPGOverhaul
X2WOTCCommunityPromotionScreen
WOTCIridarTemplateMaster
PrimarySecondaries
TruePrimarySecondaries
DualWieldedPistols
WOTC_LW2SecondaryWeapons

*/

static final function XComGameState_HeadquartersXCom GetAndPrepXComHQ(XComGameState NewGameState)
{
    local XComGameState_HeadquartersXCom XComHQ;

    foreach NewGameState.IterateByClassType(class'XComGameState_HeadquartersXCom', XComHQ)
    {
        break;
    }

    if (XComHQ == none)
    {
        XComHQ = XComGameState_HeadquartersXCom(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
        XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
    }

    return XComHQ;
}

static final function bool IsModActive(name ModName)
{
    local XComOnlineEventMgr    EventManager;
    local int                   Index;

    EventManager = `ONLINEEVENTMGR;

    for (Index = EventManager.GetNumDLC() - 1; Index >= 0; Index--) 
    {
        if (EventManager.GetDLCNames(Index) == ModName) 
        {
            return true;
        }
    }
    return false;
}

static final function bool AreModsActive(const array<name> ModNames)
{
	local name ModName;

	foreach ModNames(ModName)
	{
		if (!IsModActive(ModName))
		{
			return false;
		}
	}
	return true;
}

static final function bool IsInStrategy()
{
    return `HQPRES != none;
}

static final function bool ReallyIsInStrategy()
{
	return `HQGAME  != none && `HQPC != None && `HQPRES != none;
}

// Sound managers don't exist in Shell, have to do it by hand.
static final function PlayStrategySoundEvent(string strKey, Actor InActor)
{
	local string	SoundEventPath;
	local AkEvent	SoundEvent;

	foreach class'XComStrategySoundManager'.default.SoundEventPaths(SoundEventPath)
	{
		if (InStr(SoundEventPath, strKey) != INDEX_NONE)
		{
			SoundEvent = AkEvent(`CONTENT.RequestGameArchetype(SoundEventPath));
			if (SoundEvent != none)
			{
				InActor.WorldInfo.PlayAkEvent(SoundEvent);
				return;
			}
		}
	}
}

// For using hex color.
static function string ColourText(string strValue, string strColour)
{
	return "<font color='#" $ strColour $ "'>" $ strValue $ "</font>";
}



static final function int GetForceLevel()
{
	local XComGameStateHistory		History;
	local XComGameState_BattleData	BattleData;

	History = `XCOMHISTORY;
	BattleData = XComGameState_BattleData(History.GetSingleGameStateObjectForClass(class'XComGameState_BattleData', true));
	if (BattleData == none)
	{
		`AMLOG("WARNING :: No Battle Data!" @ GetScriptTrace());
		return -1;
	}

	return BattleData.GetForceLevel();
}

static final function AddItemToHQInventory(const name TemplateName)
{
    local XComGameState						NewGameState;
    local XComGameState_HeadquartersXCom    XComHQ;
    local XComGameState_Item                ItemState;
    local X2ItemTemplate                    ItemTemplate;
    local X2ItemTemplateManager				ItemMgr;

    ItemMgr = class'X2ItemTemplateManager'.static.GetItemTemplateManager();    

    ItemTemplate = ItemMgr.FindItemTemplate(TemplateName);

    if (ItemTemplate != none)
    {
        NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Adding item to HQ Inventory");
        XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', `XCOMHQ.ObjectID));

        ItemState = ItemTemplate.CreateInstanceFromTemplate(NewGameState);     

		// XComHQ.PutItemInInventory() is unable to work with infinite items. Use XComHQ.AddItemToHQInventory(ItemState) for those.		
        XComHQ.PutItemInInventory(NewGameState, ItemState);
        `GAMERULES.SubmitGameState(NewGameState);
    }
}


// Get Bond Level between two soldiers
static final function int GetBondLevel(const XComGameState_Unit SourceUnit, const XComGameState_Unit TargetUnit)
{
    local SoldierBond BondInfo;

    if (SourceUnit.GetBondData(SourceUnit.GetReference(), BondInfo))
    {
        if (BondInfo.Bondmate.ObjectID == TargetUnit.ObjectID)
        {
            return BondInfo.BondLevel;
        }
    }
    return 0;
}

// Check if a Unit has a Weapon of specified WeaponCategory equipped
static final function bool HasWeaponOfCategory(const XComGameState_Unit UnitState, const name WeaponCat, optional XComGameState CheckGameState)
{
    local XComGameState_Item Item;
    local StateObjectReference ItemRef;

    foreach UnitState.InventoryItems(ItemRef)
    {
        Item = UnitState.GetItemGameState(ItemRef, CheckGameState);

        if (Item != none && Item.GetWeaponCategory() == WeaponCat)
        {
            return true;
        }
    }

    return false;
}

// Similar check, but also for a specific slot:
static final function bool HasWeaponOfCategoryInSlot(const XComGameState_Unit UnitState, const name WeaponCat, const EInventorySlot Slot, optional XComGameState CheckGameState)
{
    local XComGameState_Item Item;
    local StateObjectReference ItemRef;

    foreach UnitState.InventoryItems(ItemRef)
    {
        Item = UnitState.GetItemGameState(ItemRef, CheckGameState);

        if (Item != none && Item.GetWeaponCategory() == WeaponCat && Item.InventorySlot == Slot)
        {
            return true;
        }
    }
    return false;
}

// Check if a Unit has one of the specified items equipped
static final function bool UnitHasItemEquipped(const XComGameState_Unit UnitState, const array<name> ItemNames, optional XComGameState CheckGameState)
{
    local XComGameState_Item Item;
    local StateObjectReference ItemRef;

    foreach UnitState.InventoryItems(ItemRef)
    {
        Item = UnitState.GetItemGameState(ItemRef, CheckGameState);

        if (Item != none && ItemNames.Find(Item.GetMyTemplateName()) != INDEX_NONE)
        {
            return true;
        }
    }

    return false;
}

static final function int TileDistanceBetweenUnitAndTile(const XComGameState_Unit UnitState, const TTile TileLocation)
{
	local XComWorldData WorldData;
	local vector UnitLoc, TargetLoc;
	local float Dist;
	local int Tiles;

	if (UnitState.TileLocation == TileLocation)
		return 0;

	WorldData = `XWORLD;
	UnitLoc = WorldData.GetPositionFromTileCoordinates(UnitState.TileLocation);
	TargetLoc = WorldData.GetPositionFromTileCoordinates(TileLocation);
	Dist = VSize(UnitLoc - TargetLoc);
	Tiles = Dist / WorldData.WORLD_StepSize;

	return Tiles;
}

// Calculate Tile Distance Between Tiles
static final function int GetTileDistanceBetweenTiles(const TTile TileA, const TTile TileB) 
{
	local XComWorldData WorldData;
	local vector LocA;
	local vector LocB;
	local float Dist;
	local int TileDistance;

	WorldData = `XWORLD;
	LocA = WorldData.GetPositionFromTileCoordinates(TileA);
	LocB = WorldData.GetPositionFromTileCoordinates(TileB);

	Dist = VSize(LocA - LocB);
	TileDistance = Dist / WorldData.WORLD_StepSize;
	
	return TileDistance;
}

// Rank = 0 for Squaddie
// Note: ModifyEarnedSoldierAbilities DLC hook is usually better for non-temporary ability granting.
static function GiveSoldierAbilityToUnit(const name AbilityName, const int Rank, XComGameState_Unit UnitState, XComGameState NewGameState)
{	
	local SoldierClassAbilityType AbilityStruct;
	local int Index;

	AbilityStruct.AbilityName = AbilityName;
	UnitState.AbilityTree[Rank].Abilities.AddItem(AbilityStruct);

	Index = UnitState.AbilityTree[Rank].Abilities.Length - 1;

	UnitState.BuySoldierProgressionAbility(NewGameState, Rank, Index, 0); // 0 = ability points cost
}

/*
The GetLocalizedString() function is a helper with the purpose similar to that of the Config Engine:
make using localized strings more convenient without having to explicitly declare localized them as variables.

It relies on using Localize() function, which probably is far from optimal in terms of performance,
so you probably shouldn't use it *too much*, especially in performance-sensitive code.

Set localized value:

# Setting: 

WOTCResizeArmor.int
[Help]
StringName = "Wow fancy localized string!"

# Getting: 

YourString = class'Help'.static.GetLocalizedString('StringName');

Or with global macro for brevity:

YourString = `GetLocalizedString('StringName');

*/
static final function string GetLocalizedString(const coerce string StringName)
{
	return Localize("Help", StringName, "WOTCResizeArmor");
}

// Create a single big string out of an array of smaller strings, separated by an optional delimiter.
static final function string JoinStrings(array<string> Arr, optional string Delim = "")
{
	local string ReturnString;
	local int i;

	// Handle it this way so there's no delim after the final member.
	for (i = 0; i < Arr.Length - 1; i++)
	{
		ReturnString $= Arr[i] $ Delim;
	}
	if (Arr.Length > 0)
	{
		ReturnString $= Arr[Arr.Length - 1];
	}
	return ReturnString;
}

static final function array<XComGameState_Unit> GetSquadUnitStates()
{
	local XComGameState_HeadquartersXCom	XComHQ;
	local StateObjectReference				SquadUnitRef;
	local array<XComGameState_Unit>			UnitStates;
	local XComGameState_Unit				UnitState;
	local XComGameStateHistory				History;

	XComHQ = `XCOMHQ;
	History = `XCOMHISTORY;
	foreach XComHQ.Squad(SquadUnitRef)
	{
		UnitState = XComGameState_Unit(History.GetGameStateForObjectID(SquadUnitRef.ObjectID));
		if (UnitState != none)
		{
			UnitStates.AddItem(UnitState);
		}
	}
	return UnitStates;
}

static final function bool AreItemTemplatesMutuallyExclusive(const X2ItemTemplate TemplateA, const X2ItemTemplate TemplateB)
{
	return TemplateA.ItemCat == TemplateB.ItemCat || 
			X2WeaponTemplate(TemplateA) != none && X2WeaponTemplate(TemplateB) != none && 
			X2WeaponTemplate(TemplateA).WeaponCat == X2WeaponTemplate(TemplateB).WeaponCat;
}


static final function bool IsItemUniqueEquipInSlot(X2ItemTemplateManager ItemMgr, const X2ItemTemplate ItemTemplate, const EInventorySlot Slot)
{
	local X2WeaponTemplate WeaponTemplate;

	if (class'X2TacticalGameRulesetDataStructures'.static.InventorySlotBypassesUniqueRule(Slot))
		return false;

	WeaponTemplate = X2WeaponTemplate(ItemTemplate);

	return ItemMgr.ItemCategoryIsUniqueEquip(ItemTemplate.ItemCat) || WeaponTemplate != none && ItemMgr.ItemCategoryIsUniqueEquip(WeaponTemplate.WeaponCat);
}


defaultproperties
{
	PawnPartName = "IRI_EntirePawn"
}
