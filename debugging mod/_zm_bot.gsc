init()
{
	debug_tracker();
}

debug_tracker()
{
	numberOfScriptsBeingLogged = 0;
	if ( !isDefined( level.debugLogging ) )
	{
		level.debugLogging = 1;
	}
	if ( isDefined( level.custom_zm_ai_dogs_loaded ) && level.custom_zm_ai_dogs_loaded )
	{
		level.debugLogging_zm_ai_dogs = 1;
		numberOfScriptsBeingLogged++;
	}
	level.player_starting_points = 1000000;
}

