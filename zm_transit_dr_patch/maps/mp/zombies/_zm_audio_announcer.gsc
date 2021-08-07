#include maps/mp/zombies/_zm_spawner;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init()
{
	game[ "zmbdialog" ] = [];
	game[ "zmbdialog" ][ "prefix" ] = "vox_zmba";
	createvox( "carpenter", "powerup_carpenter" );
	createvox( "insta_kill", "powerup_instakill" );
	createvox( "double_points", "powerup_doublepoints" );
	createvox( "nuke", "powerup_nuke" );
	createvox( "full_ammo", "powerup_maxammo" );
	createvox( "fire_sale", "powerup_firesale" );
	createvox( "minigun", "powerup_death_machine" );
	createvox( "boxmove", "event_magicbox" );
	createvox( "dogstart", "event_dogstart" );
	thread init_gamemodespecificvox( getDvar( "ui_gametype" ), getDvar( "ui_zm_mapstartlocation" ) );
	level.allowzmbannouncer = 1;
}

init_gamemodespecificvox( mode, location )
{
	switch( mode )
	{
		case "zmeat":
			init_meatvox( "meat" );
			break;
		case "zrace":
			init_racevox( "race", location );
			break;
		case "zgrief":
			init_griefvox( "grief" );
			break;
		case "zcleansed":
			init_cleansed( location );
			break;
		default:
			init_gamemodecommonvox();
			break;
	}
}

init_gamemodecommonvox( prefix )
{
	createvox( "rules", "rules", prefix );
	createvox( "countdown", "intro", prefix );
	createvox( "side_switch", "side_switch", prefix );
	createvox( "round_win", "win_rd", prefix );
	createvox( "round_lose", "lose_rd", prefix );
	createvox( "round_tied", "tied_rd", prefix );
	createvox( "match_win", "win", prefix );
	createvox( "match_lose", "lose", prefix );
	createvox( "match_tied", "tied", prefix );
}

init_griefvox( prefix )
{
	init_gamemodecommonvox( prefix );
	createvox( "1_player_down", "1rivdown", prefix );
	createvox( "2_player_down", "2rivdown", prefix );
	createvox( "3_player_down", "3rivdown", prefix );
	createvox( "4_player_down", "4rivdown", prefix );
	createvox( "grief_restarted", "restart", prefix );
	createvox( "grief_lost", "lose", prefix );
	createvox( "grief_won", "win", prefix );
	createvox( "1_player_left", "1rivup", prefix );
	createvox( "2_player_left", "2rivup", prefix );
	createvox( "3_player_left", "3rivup", prefix );
	createvox( "last_player", "solo", prefix );
}

init_cleansed( prefix )
{
	init_gamemodecommonvox( prefix );
	createvox( "dr_start_single_0", "dr_start_0" );
	createvox( "dr_start_2", "dr_start_1" );
	createvox( "dr_start_3", "dr_start_2" );
	createvox( "dr_cure_found_line", "dr_cure_found" );
	createvox( "dr_monkey_killer", "dr_monkey_0" );
	createvox( "dr_monkey_killee", "dr_monkey_1" );
	createvox( "dr_human_killed", "dr_kill_plr" );
	createvox( "dr_human_killer", "dr_kill_plr_2" );
	createvox( "dr_survival", "dr_plr_survive_0" );
	createvox( "dr_zurvival", "dr_zmb_survive_2" );
	createvox( "dr_countdown0", "dr_plr_survive_1" );
	createvox( "dr_countdown1", "dr_plr_survive_2" );
	createvox( "dr_countdown2", "dr_plr_survive_3" );
	createvox( "dr_ending", "dr_time_0" );
}

init_meatvox( prefix )
{
	init_gamemodecommonvox( prefix );
	createvox( "meat_drop", "drop", prefix );
	createvox( "meat_grab", "grab", prefix );
	createvox( "meat_grab_A", "team_cdc", prefix );
	createvox( "meat_grab_B", "team_cia", prefix );
	createvox( "meat_land", "land", prefix );
	createvox( "meat_hold", "hold", prefix );
	createvox( "meat_revive_1", "revive1", prefix );
	createvox( "meat_revive_2", "revive2", prefix );
	createvox( "meat_revive_3", "revive3", prefix );
	createvox( "meat_ring_splitter", "ring_tripple", prefix );
	createvox( "meat_ring_minigun", "ring_death", prefix );
	createvox( "meat_ring_ammo", "ring_ammo", prefix );
}

init_racevox( prefix, location )
{
	init_gamemodecommonvox( prefix );
	switch( location )
	{
		case "tunnel":
			createvox( "rules", "rules_" + location, prefix );
			createvox( "countdown", "intro_" + location, prefix );
			break;
		case "power":
			createvox( "rules", "rules_" + location, prefix );
			createvox( "countdown", "intro_" + location, prefix );
			createvox( "lap1", "lap1", prefix );
			createvox( "lap2", "lap2", prefix );
			createvox( "lap_final", "lap_final", prefix );
			break;
		case "farm":
			createvox( "rules", "rules_" + location, prefix );
			createvox( "countdown", "intro_" + location, prefix );
			createvox( "hoop_area", "hoop_area", prefix );
			createvox( "hoop_miss", "hoop_miss", prefix );
			break;
		default:
		}
		createvox( "race_room_2_ally", "room2_ally", prefix );
		createvox( "race_room_3_ally", "room3_ally", prefix );
		createvox( "race_room_4_ally", "room4_ally", prefix );
		createvox( "race_room_5_ally", "room5_ally", prefix );
		createvox( "race_room_2_axis", "room2_axis", prefix );
		createvox( "race_room_3_axis", "room3_axis", prefix );
		createvox( "race_room_4_axis", "room4_axis", prefix );
		createvox( "race_room_5_axis", "room5_axis", prefix );
		createvox( "race_ahead_1_ally", "ahead1_ally", prefix );
		createvox( "race_ahead_2_ally", "ahead2_ally", prefix );
		createvox( "race_ahead_3_ally", "ahead3_ally", prefix );
		createvox( "race_ahead_4_ally", "ahead4_ally", prefix );
		createvox( "race_ahead_1_axis", "ahead1_axis", prefix );
		createvox( "race_ahead_2_axis", "ahead2_axis", prefix );
		createvox( "race_ahead_3_axis", "ahead3_axis", prefix );
		createvox( "race_ahead_4_axis", "ahead4_axis", prefix );
		createvox( "race_kill_15", "door15", prefix );
		createvox( "race_kill_10", "door10", prefix );
		createvox( "race_kill_5", "door5", prefix );
		createvox( "race_kill_3", "door3", prefix );
		createvox( "race_kill_1", "door1", prefix );
		createvox( "race_door_open", "door_open", prefix );
		createvox( "race_door_nag", "door_nag", prefix );
		createvox( "race_grief_incoming", "grief_income_ammo", prefix );
		createvox( "race_grief_land", "grief_land", prefix );
		createvox( "race_laststand", "last_stand", prefix );
	}
}

createvox( type, alias, gametype )
{
	if ( !isDefined( gametype ) )
	{
		gametype = "";
	}
	else
	{
		gametype += "_";
	}
	game[ "zmbdialog" ][ type ] = gametype + alias;
}

announceroundwinner( winner, delay )
{
	if ( isDefined( delay ) && delay > 0 )
	{
		wait delay;
	}
	if ( !isDefined( winner ) || isplayer( winner ) )
	{
		return;
	}
	if ( winner != "tied" )
	{
		players = get_players();
		_a235 = players;
		_k235 = getFirstArrayKey( _a235 );
		while ( isDefined( _k235 ) )
		{
			player = _a235[ _k235 ];
			if ( isDefined( player._encounters_team ) && player._encounters_team == winner )
			{
				winning_team = player.pers[ "team" ];
				break;
			}
			else
			{
				_k235 = getNextArrayKey( _a235, _k235 );
			}
		}
		losing_team = getotherteam( winning_team );
		leaderdialog( "round_win", winning_team, undefined, 1 );
		leaderdialog( "round_lose", losing_team, undefined, 1 );
	}
	else
	{
		leaderdialog( "round_tied", undefined, undefined, 1 );
	}
}

announcematchwinner( winner, delay )
{
	if ( isDefined( delay ) && delay > 0 )
	{
		wait delay;
	}
	if ( !isDefined( winner ) || isplayer( winner ) )
	{
		return;
	}
	if ( winner != "tied" )
	{
		players = get_players();
		_a266 = players;
		_k266 = getFirstArrayKey( _a266 );
		while ( isDefined( _k266 ) )
		{
			player = _a266[ _k266 ];
			if ( isDefined( player._encounters_team ) && player._encounters_team == winner )
			{
				winning_team = player.pers[ "team" ];
				break;
			}
			else
			{
				_k266 = getNextArrayKey( _a266, _k266 );
			}
		}
		losing_team = getotherteam( winning_team );
		leaderdialog( "match_win", winning_team, undefined, 1 );
		leaderdialog( "match_lose", losing_team, undefined, 1 );
	}
	else
	{
		leaderdialog( "match_tied", undefined, undefined, 1 );
	}
}

announcegamemoderules()
{
	if ( getDvar( "ui_zm_mapstartlocation" ) == "town" )
	{
		leaderdialog( "rules", undefined, undefined, undefined, 20 );
	}
}

leaderdialog( dialog, team, group, queue, waittime )
{
/#
	assert( isDefined( level.players ) );
#/
	if ( !isDefined( team ) )
	{
		leaderdialogbothteams( dialog, "allies", dialog, "axis", group, queue, waittime );
		return;
	}
	if ( level.splitscreen )
	{
		if ( level.players.size )
		{
			level.players[ 0 ] leaderdialogonplayer( dialog, group, queue, waittime );
		}
		return;
	}
	i = 0;
	while ( i < level.players.size )
	{
		player = level.players[ i ];
		if ( isDefined( player.pers[ "team" ] ) && player.pers[ "team" ] == team )
		{
			player leaderdialogonplayer( dialog, group, queue, waittime );
		}
		i++;
	}
}

leaderdialogbothteams( dialog1, team1, dialog2, team2, group, queue, waittime )
{
/#
	assert( isDefined( level.players ) );
#/
	if ( level.splitscreen )
	{
		if ( level.players.size )
		{
			level.players[ 0 ] leaderdialogonplayer( dialog1, group, queue, waittime );
		}
		return;
	}
	i = 0;
	while ( i < level.players.size )
	{
		player = level.players[ i ];
		team = player.pers[ "team" ];
		if ( !isDefined( team ) )
		{
			i++;
			continue;
		}
		else if ( team == team1 )
		{
			player leaderdialogonplayer( dialog1, group, queue, waittime );
			i++;
			continue;
		}
		else
		{
			if ( team == team2 )
			{
				player leaderdialogonplayer( dialog2, group, queue, waittime );
			}
		}
		i++;
	}
}

leaderdialogonplayer( dialog, group, queue, waittime )
{
	team = self.pers[ "team" ];
	if ( !isDefined( team ) )
	{
		return;
	}
	if ( team != "allies" && team != "axis" )
	{
		return;
	}
	if ( isDefined( group ) )
	{
		if ( self.zmbdialoggroup == group )
		{
			return;
		}
		hadgroupdialog = isDefined( self.zmbdialoggroups[ group ] );
		self.zmbdialoggroups[ group ] = dialog;
		dialog = group;
		if ( hadgroupdialog )
		{
			return;
		}
	}
	if ( !self.zmbdialogactive )
	{
		self thread playleaderdialogonplayer( dialog, team, waittime );
	}
	else
	{
		if ( isDefined( queue ) && queue )
		{
			self.zmbdialogqueue[ self.zmbdialogqueue.size ] = dialog;
		}
	}
}

playleaderdialogonplayer( dialog, team, waittime )
{
	self endon( "disconnect" );
	if ( level.allowzmbannouncer )
	{
		if ( !isDefined( game[ "zmbdialog" ][ dialog ] ) )
		{
/#
			if ( getDvarInt( #"0AEB127D" ) > 0 )
			{
				println( "DIALOG DEBUGGER: No VOX created for - " + dialog );
#/
			}
			return;
		}
	}
	self.zmbdialogactive = 1;
	if ( isDefined( self.zmbdialoggroups[ dialog ] ) )
	{
		group = dialog;
		dialog = self.zmbdialoggroups[ group ];
		self.zmbdialoggroup = group;
	}
	if ( level.allowzmbannouncer )
	{
		alias = game[ "zmbdialog" ][ "prefix" ] + "_" + game[ "zmbdialog" ][ dialog ];
		variant = self getleaderdialogvariant( alias );
		if ( !isDefined( variant ) )
		{
			full_alias = alias;
		}
		else
		{
			full_alias = ( alias + "_" ) + variant;
		}
		self playlocalsound( full_alias );
	}
	if ( isDefined( waittime ) )
	{
		wait waittime;
	}
	else
	{
		wait 4;
	}
	self.zmbdialogactive = 0;
	self.zmbdialoggroup = "";
	if ( self.zmbdialogqueue.size > 0 && level.allowzmbannouncer )
	{
		nextdialog = self.zmbdialogqueue[ 0 ];
		i = 1;
		while ( i < self.zmbdialogqueue.size )
		{
			self.zmbdialogqueue[ i - 1 ] = self.zmbdialogqueue[ i ];
			i++;
		}
		self thread playleaderdialogonplayer( nextdialog, team );
	}
}

getleaderdialogvariant( alias )
{
	if ( !isDefined( alias ) )
	{
		return;
	}
	if ( !isDefined( level.announcer_dialog ) )
	{
		level.announcer_dialog = [];
		level.announcer_dialog_available = [];
	}
	num_variants = maps/mp/zombies/_zm_spawner::get_number_variants( alias );
	if ( num_variants <= 0 )
	{
/#
		if ( getDvarInt( #"0AEB127D" ) > 0 )
		{
			println( "DIALOG DEBUGGER: No variants found for - " + alias );
#/
		}
		return undefined;
	}
	i = 0;
	while ( i < num_variants )
	{
		level.announcer_dialog[ alias ][ i ] = i;
		i++;
	}
	level.announcer_dialog_available[ alias ] = [];
	if ( level.announcer_dialog_available[ alias ].size <= 0 )
	{
		level.announcer_dialog_available[ alias ] = level.announcer_dialog[ alias ];
	}
	variation = random( level.announcer_dialog_available[ alias ] );
	level.announcer_dialog_available[ alias ] = arrayremovevalue( level.announcer_dialog_available[ alias ], variation );
	return variation;
}

getroundswitchdialog( switchtype )
{
	switch( switchtype )
	{
		case "halftime":
			return "halftime";
		case "overtime":
			return "overtime";
		default:
			return "side_switch";
	}
}

getotherteam( team )
{
	if ( team == "allies" )
	{
		return "axis";
	}
	else
	{
		return "allies";
	}
}
