class X2EventListener_ResizeArmor extends X2EventListener;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(Create_ListenerTemplate());

	return Templates;
}

static function CHEventListenerTemplate Create_ListenerTemplate()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'X2EventListener_ResizeArmor');

	Template.RegisterInTactical = true;
	Template.RegisterInStrategy = true;

	Template.AddCHEvent('OnCreateCinematicPawn', OnCreateCinematicPawn, ELD_Immediate, 50);

	return Template;
}

static private function EventListenerReturn OnCreateCinematicPawn(Object EventData, Object EventSource, XComGameState NewGameState, Name Event, Object CallbackData)
{
	local XComGameState_Unit UnitState;
	local XComUnitPawn UnitPawn;

	UnitPawn = XComUnitPawn(EventData);
	if (UnitPawn == none)
		return ELR_NoInterrupt;

	UnitState = XComGameState_Unit(EventSource);
	if (UnitState == none)
		return ELR_NoInterrupt;

	class'Help'.static.ResizeArmor(UnitState, UnitPawn);

	return ELR_NoInterrupt;
}