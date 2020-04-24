#include maps/mp/_utility;
#include maps/common_scripts/utility;

init()
{
	debug_tracker();
}

debug_tracker()
{
	numberOfScriptsBeingLogged = 0;
	if ( !isDefined( level.debugLogging ) )
	{
		level.debugLogging = getDvarIntDefault( "debugModDebugLoggingActive", 1 );
	}
	if ( isDefined( level.customZgrief_loaded ) && level.customZgrief_loaded )
	{
		level.debugLoggingZgrief = getDvarIntDefault( "debugModDebugLoggingZgrief", 1 );
		numberOfScriptsBeingLogged++;
	}
	if ( isDefined( level.custom_zm_loaded ) && level.custom_zm_loaded )
	{
		level.debugLogging_zm = getDvarIntDefault( "debugModDebugLogging_zm", 1 );
		numberOfScriptsBeingLogged++;
	}
	if ( isDefined( level.custom_zm_ai_dogs_loaded ) && level.custom_zm_ai_dogs_loaded )
	{
		level.debugLogging_zm_ai_dogs = getDvarIntDefault( "debugModDebugLogging_zm_ai_dogs", 1 );
		numberOfScriptsBeingLogged++;
	}
	if ( isDefined( level.custom_zm_audio_loaded ) && level.custom_zm_audio_loaded )
	{
		level.debugLogging_zm_audio = getDvarIntDefault( "debugModDebugLogging_zm_audio", 1 );
		numberOfScriptsBeingLogged++;
	}
	if ( isDefined( level.custom_zm_magicbox_loaded ) && level.custom_zm_magicbox_loaded )
	{
		level.debugLogging_zm_magicbox = getDvarIntDefault( "debugModDebugLogging_zm_magicbox", 1 );
		numberOfScriptsBeingLogged++;
	}
	if ( isDefined( level.custom_zm_perks_loaded ) && level.custom_zm_perks_loaded )
	{
		level.debugLogging_zm_perks = getDvarIntDefault( "debugModDebugLogging_zm_perks", 1 );
		numberOfScriptsBeingLogged++;
	}
	if ( isDefined( level.custom_zm_perk_electric_cherry_loaded ) && level.custom_zm_perk_electric_cherry_loaded )
	{
		level.debugLogging_zm_perk_electric_cherry = getDvarIntDefault( "debugModDebugLogging_zm_perk_electric_cherry", 1 );
		numberOfScriptsBeingLogged++;
	}
	if ( isDefined( level.custom_zm_powerups_loaded ) && level.custom_zm_powerups_loaded )
	{
		level.debugLogging_zm_powerups = getDvarIntDefault( "debugModDebugLogging_zm_powerups", 1 );
		numberOfScriptsBeingLogged++;
	}
	if ( isDefined( level.custom_zm_spawner_loaded ) && level.custom_zm_spawner_loaded )
	{
		level.debugLogging_zm_spawner = getDvarIntDefault( "debugModDebugLogging_zm_spawner", 1 );
		numberOfScriptsBeingLogged++;
	}
	if ( isDefined( level.custom_zm_weapons_loaded ) && level.custom_zm_weapons_loaded )
	{
		level.debugLogging_zm_weapons = getDvarIntDefault( "debugModDebugLogging_zm_weapons", 1 );
		numberOfScriptsBeingLogged++;
	}
	level.player_starting_points = getDvarIntDefault( "debugModStartingPoints", 500 );
	if ( getDvarIntDefault( "debugModTestBotsEnabled", 0 ) == 1 )
	{
		level thread add_bots();
	}
	level.errorDisplayLevel = getDvarIntDefault( "debugModErrorDisplay", 0 ); //Use this to choose what is written to the log
	//Error levels:
	//0 - Display all types of log messages
	//1 - Display only errors
	//2 - Display only warnings
	//3 - Display only info
}

add_bots()
{
	//Wait for the host!
	players = get_players();
	while ( players.size < 1 )
	{
		players = get_players();
		wait 1;
	}
	//Then spawn bots
	botsToSpawn = getDvarIntDefault( "debugModBotsToSpawn", 1 )
	for ( currentBots = 0; currentBots < botsToSpawn; currentBots++ )
	{
		zbot_spawn();
		wait 1;
	}
	SetDvar("bot_AllowMovement", "1");
	SetDvar("bot_PressAttackBtn", "1");
	SetDvar("bot_PressMeleeBtn", "1");
}

zbot_spawn()
{
	bot = AddTestClient();
	if ( !IsDefined( bot ) )
	{
		return;
	}
			
	bot.pers["isBot"] = true;
	bot.equipment_enabled = false;
	return bot;
}








