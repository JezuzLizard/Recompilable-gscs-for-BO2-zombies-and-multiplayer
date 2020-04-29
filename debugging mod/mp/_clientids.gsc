#include maps/mp/_utility;
#include maps/common_scripts/utility;

init()
{
	debug_tracker();
}

debug_tracker()
{
	numberOfScriptsBeingLogged = 0;
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
		bot_spawn();
		wait 1;
	}
	SetDvar("bot_AllowMovement", "1");
	SetDvar("bot_PressAttackBtn", "1");
	SetDvar("bot_PressMeleeBtn", "1");
}

bot_spawn()
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








