
init()
{
	level.bookmark[ "kill" ] = 0;
	level.bookmark[ "event" ] = 1;
	level.bookmark[ "zm_round_end" ] = 2;
	level.bookmark[ "zm_player_downed" ] = 3;
	level.bookmark[ "zm_player_revived" ] = 4;
	level.bookmark[ "zm_player_bledout" ] = 5;
	level.bookmark[ "zm_player_use_magicbox" ] = 6;
	level.bookmark[ "score_event" ] = 7;
	level.bookmark[ "medal" ] = 8;
	level.bookmark[ "round_result" ] = 9;
	level.bookmark[ "game_result" ] = 10;
	level.bookmark[ "zm_powerup_dropped" ] = 11;
	level.bookmark[ "zm_player_powerup_grabbed" ] = 12;
	level.bookmark[ "zm_player_perk" ] = 13;
	level.bookmark[ "zm_power" ] = 14;
	level.bookmark[ "zm_player_door" ] = 15;
	level.bookmark[ "zm_player_buildable_placed" ] = 16;
	level.bookmark[ "zm_player_use_packapunch" ] = 17;
	level.bookmark[ "zm_player_rampage" ] = 18;
	level.bookmark[ "zm_player_grenade_special" ] = 19;
	level.bookmark[ "zm_player_grenade_multiattack" ] = 20;
	level.bookmark[ "zm_player_meat_stink" ] = 21;
	level.bookmark[ "zm_player_grabbed_magicbox" ] = 22;
	level.bookmark[ "zm_player_grabbed_packapunch" ] = 23;
	level.bookmark[ "zm_player_grenade_special_long" ] = 24;
}

bookmark( type, time, clientent1, clientent2, eventpriority, inflictorent, overrideentitycamera, actorent )
{
/#
	assert( isDefined( level.bookmark[ type ] ), "Unable to find a bookmark type for type - " + type );
#/
	client1 = 255;
	client2 = 255;
	inflictorentnum = -1;
	inflictorenttype = 0;
	inflictorbirthtime = 0;
	actorentnum = undefined;
	scoreeventpriority = 0;
	if ( isDefined( clientent1 ) )
	{
		client1 = clientent1 getentitynumber();
	}
	if ( isDefined( clientent2 ) )
	{
		client2 = clientent2 getentitynumber();
	}
	if ( isDefined( eventpriority ) )
	{
		scoreeventpriority = eventpriority;
	}
	if ( isDefined( inflictorent ) )
	{
		inflictorentnum = inflictorent getentitynumber();
		inflictorenttype = inflictorent getentitytype();
		if ( isDefined( inflictorent.birthtime ) )
		{
			inflictorbirthtime = inflictorent.birthtime;
		}
	}
	if ( !isDefined( overrideentitycamera ) )
	{
		overrideentitycamera = 0;
	}
	if ( isDefined( actorent ) )
	{
		actorentnum = actorent getentitynumber();
	}
	adddemobookmark( level.bookmark[ type ], time, client1, client2, scoreeventpriority, inflictorentnum, inflictorenttype, inflictorbirthtime, overrideentitycamera, actorentnum );
}

gameresultbookmark( type, winningteamindex, losingteamindex )
{
/#
	assert( isDefined( level.bookmark[ type ] ), "Unable to find a bookmark type for type - " + type );
#/
	client1 = 255;
	client2 = 255;
	scoreeventpriority = 0;
	inflictorentnum = -1;
	inflictorenttype = 0;
	inflictorbirthtime = 0;
	overrideentitycamera = 0;
	actorentnum = undefined;
	if ( isDefined( winningteamindex ) )
	{
		client1 = winningteamindex;
	}
	if ( isDefined( losingteamindex ) )
	{
		client2 = losingteamindex;
	}
	adddemobookmark( level.bookmark[ type ], getTime(), client1, client2, scoreeventpriority, inflictorentnum, inflictorenttype, inflictorbirthtime, overrideentitycamera, actorentnum );
}
