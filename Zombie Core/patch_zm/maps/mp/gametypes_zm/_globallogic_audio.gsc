#include maps/mp/_music;
#include maps/mp/gametypes_zm/_globallogic_audio;
#include maps/mp/gametypes_zm/_globallogic_utils;
#include maps/mp/_utility;

init()
{
	game[ "music" ][ "defeat" ] = "mus_defeat";
	game[ "music" ][ "victory_spectator" ] = "mus_defeat";
	game[ "music" ][ "winning" ] = "mus_time_running_out_winning";
	game[ "music" ][ "losing" ] = "mus_time_running_out_losing";
	game[ "music" ][ "match_end" ] = "mus_match_end";
	game[ "music" ][ "victory_tie" ] = "mus_defeat";
	game[ "music" ][ "suspense" ] = [];
	game[ "music" ][ "suspense" ][ game[ "music" ][ "suspense" ].size ] = "mus_suspense_01";
	game[ "music" ][ "suspense" ][ game[ "music" ][ "suspense" ].size ] = "mus_suspense_02";
	game[ "music" ][ "suspense" ][ game[ "music" ][ "suspense" ].size ] = "mus_suspense_03";
	game[ "music" ][ "suspense" ][ game[ "music" ][ "suspense" ].size ] = "mus_suspense_04";
	game[ "music" ][ "suspense" ][ game[ "music" ][ "suspense" ].size ] = "mus_suspense_05";
	game[ "music" ][ "suspense" ][ game[ "music" ][ "suspense" ].size ] = "mus_suspense_06";
	game[ "dialog" ][ "mission_success" ] = "mission_success";
	game[ "dialog" ][ "mission_failure" ] = "mission_fail";
	game[ "dialog" ][ "mission_draw" ] = "draw";
	game[ "dialog" ][ "round_success" ] = "encourage_win";
	game[ "dialog" ][ "round_failure" ] = "encourage_lost";
	game[ "dialog" ][ "round_draw" ] = "draw";
	game[ "dialog" ][ "timesup" ] = "timesup";
	game[ "dialog" ][ "winning" ] = "winning";
	game[ "dialog" ][ "losing" ] = "losing";
	game[ "dialog" ][ "min_draw" ] = "min_draw";
	game[ "dialog" ][ "lead_lost" ] = "lead_lost";
	game[ "dialog" ][ "lead_tied" ] = "tied";
	game[ "dialog" ][ "lead_taken" ] = "lead_taken";
	game[ "dialog" ][ "last_alive" ] = "lastalive";
	game[ "dialog" ][ "boost" ] = "generic_boost";
	if ( !isDefined( game[ "dialog" ][ "offense_obj" ] ) )
	{
		game[ "dialog" ][ "offense_obj" ] = "generic_boost";
	}
	if ( !isDefined( game[ "dialog" ][ "defense_obj" ] ) )
	{
		game[ "dialog" ][ "defense_obj" ] = "generic_boost";
	}
	game[ "dialog" ][ "hardcore" ] = "hardcore";
	game[ "dialog" ][ "oldschool" ] = "oldschool";
	game[ "dialog" ][ "highspeed" ] = "highspeed";
	game[ "dialog" ][ "tactical" ] = "tactical";
	game[ "dialog" ][ "challenge" ] = "challengecomplete";
	game[ "dialog" ][ "promotion" ] = "promotion";
	game[ "dialog" ][ "bomb_acquired" ] = "sd_bomb_taken";
	game[ "dialog" ][ "bomb_taken" ] = "sd_bomb_taken_taken";
	game[ "dialog" ][ "bomb_lost" ] = "sd_bomb_drop";
	game[ "dialog" ][ "bomb_defused" ] = "sd_bomb_defused";
	game[ "dialog" ][ "bomb_planted" ] = "sd_bomb_planted";
	game[ "dialog" ][ "obj_taken" ] = "securedobj";
	game[ "dialog" ][ "obj_lost" ] = "lostobj";
	game[ "dialog" ][ "obj_defend" ] = "defend_start";
	game[ "dialog" ][ "obj_destroy" ] = "destroy_start";
	game[ "dialog" ][ "obj_capture" ] = "capture_obj";
	game[ "dialog" ][ "objs_capture" ] = "capture_objs";
	game[ "dialog" ][ "hq_located" ] = "hq_located";
	game[ "dialog" ][ "hq_enemy_captured" ] = "hq_capture";
	game[ "dialog" ][ "hq_enemy_destroyed" ] = "hq_defend";
	game[ "dialog" ][ "hq_secured" ] = "hq_secured";
	game[ "dialog" ][ "hq_offline" ] = "hq_offline";
	game[ "dialog" ][ "hq_online" ] = "hq_online";
	game[ "dialog" ][ "koth_located" ] = "koth_located";
	game[ "dialog" ][ "koth_captured" ] = "koth_captured";
	game[ "dialog" ][ "koth_lost" ] = "koth_lost";
	game[ "dialog" ][ "koth_secured" ] = "koth_secured";
	game[ "dialog" ][ "koth_contested" ] = "koth_contest";
	game[ "dialog" ][ "koth_offline" ] = "koth_offline";
	game[ "dialog" ][ "koth_online" ] = "koth_online";
	game[ "dialog" ][ "move_to_new" ] = "new_positions";
	game[ "dialog" ][ "attack" ] = "attack";
	game[ "dialog" ][ "defend" ] = "defend";
	game[ "dialog" ][ "offense" ] = "offense";
	game[ "dialog" ][ "defense" ] = "defense";
	game[ "dialog" ][ "halftime" ] = "halftime";
	game[ "dialog" ][ "overtime" ] = "overtime";
	game[ "dialog" ][ "side_switch" ] = "switchingsides";
	game[ "dialog" ][ "flag_taken" ] = "ourflag";
	game[ "dialog" ][ "flag_dropped" ] = "ourflag_drop";
	game[ "dialog" ][ "flag_returned" ] = "ourflag_return";
	game[ "dialog" ][ "flag_captured" ] = "ourflag_capt";
	game[ "dialog" ][ "enemy_flag_taken" ] = "enemyflag";
	game[ "dialog" ][ "enemy_flag_dropped" ] = "enemyflag_drop";
	game[ "dialog" ][ "enemy_flag_returned" ] = "enemyflag_return";
	game[ "dialog" ][ "enemy_flag_captured" ] = "enemyflag_capt";
	game[ "dialog" ][ "securing_a" ] = "dom_securing_a";
	game[ "dialog" ][ "securing_b" ] = "dom_securing_b";
	game[ "dialog" ][ "securing_c" ] = "dom_securing_c";
	game[ "dialog" ][ "securing_d" ] = "dom_securing_d";
	game[ "dialog" ][ "securing_e" ] = "dom_securing_e";
	game[ "dialog" ][ "securing_f" ] = "dom_securing_f";
	game[ "dialog" ][ "secured_a" ] = "dom_secured_a";
	game[ "dialog" ][ "secured_b" ] = "dom_secured_b";
	game[ "dialog" ][ "secured_c" ] = "dom_secured_c";
	game[ "dialog" ][ "secured_d" ] = "dom_secured_d";
	game[ "dialog" ][ "secured_e" ] = "dom_secured_e";
	game[ "dialog" ][ "secured_f" ] = "dom_secured_f";
	game[ "dialog" ][ "losing_a" ] = "dom_losing_a";
	game[ "dialog" ][ "losing_b" ] = "dom_losing_b";
	game[ "dialog" ][ "losing_c" ] = "dom_losing_c";
	game[ "dialog" ][ "losing_d" ] = "dom_losing_d";
	game[ "dialog" ][ "losing_e" ] = "dom_losing_e";
	game[ "dialog" ][ "losing_f" ] = "dom_losing_f";
	game[ "dialog" ][ "lost_a" ] = "dom_lost_a";
	game[ "dialog" ][ "lost_b" ] = "dom_lost_b";
	game[ "dialog" ][ "lost_c" ] = "dom_lost_c";
	game[ "dialog" ][ "lost_d" ] = "dom_lost_d";
	game[ "dialog" ][ "lost_e" ] = "dom_lost_e";
	game[ "dialog" ][ "lost_f" ] = "dom_lost_f";
	game[ "dialog" ][ "secure_flag" ] = "secure_flag";
	game[ "dialog" ][ "securing_flag" ] = "securing_flag";
	game[ "dialog" ][ "losing_flag" ] = "losing_flag";
	game[ "dialog" ][ "lost_flag" ] = "lost_flag";
	game[ "dialog" ][ "oneflag_enemy" ] = "oneflag_enemy";
	game[ "dialog" ][ "oneflag_friendly" ] = "oneflag_friendly";
	game[ "dialog" ][ "lost_all" ] = "dom_lock_theytake";
	game[ "dialog" ][ "secure_all" ] = "dom_lock_wetake";
	game[ "dialog" ][ "squad_move" ] = "squad_move";
	game[ "dialog" ][ "squad_30sec" ] = "squad_30sec";
	game[ "dialog" ][ "squad_winning" ] = "squad_onemin_vic";
	game[ "dialog" ][ "squad_losing" ] = "squad_onemin_loss";
	game[ "dialog" ][ "squad_down" ] = "squad_down";
	game[ "dialog" ][ "squad_bomb" ] = "squad_bomb";
	game[ "dialog" ][ "squad_plant" ] = "squad_plant";
	game[ "dialog" ][ "squad_take" ] = "squad_takeobj";
	game[ "dialog" ][ "kicked" ] = "player_kicked";
	game[ "dialog" ][ "sentry_destroyed" ] = "dest_sentry";
	game[ "dialog" ][ "sentry_hacked" ] = "kls_turret_hacked";
	game[ "dialog" ][ "microwave_destroyed" ] = "dest_microwave";
	game[ "dialog" ][ "microwave_hacked" ] = "kls_microwave_hacked";
	game[ "dialog" ][ "sam_destroyed" ] = "dest_sam";
	game[ "dialog" ][ "tact_destroyed" ] = "dest_tact";
	game[ "dialog" ][ "equipment_destroyed" ] = "dest_equip";
	game[ "dialog" ][ "hacked_equip" ] = "hacked_equip";
	game[ "dialog" ][ "uav_destroyed" ] = "kls_u2_destroyed";
	game[ "dialog" ][ "cuav_destroyed" ] = "kls_cu2_destroyed";
	level.dialoggroups = [];
	level thread post_match_snapshot_watcher();
}

registerdialoggroup( group, skipifcurrentlyplayinggroup )
{
	if ( !isDefined( level.dialoggroups ) )
	{
		level.dialoggroups = [];
	}
	else
	{
		if ( isDefined( level.dialoggroup[ group ] ) )
		{
			error( "registerDialogGroup:  Dialog group " + group + " already registered." );
			return;
		}
	}
	level.dialoggroup[ group ] = spawnstruct();
	level.dialoggroup[ group ].group = group;
	level.dialoggroup[ group ].skipifcurrentlyplayinggroup = skipifcurrentlyplayinggroup;
	level.dialoggroup[ group ].currentcount = 0;
}

sndstartmusicsystem()
{
	self endon( "disconnect" );
	if ( game[ "state" ] == "postgame" )
	{
		return;
	}
	if ( game[ "state" ] == "pregame" )
	{
/#
		if ( getDvarInt( #"0BC4784C" ) > 0 )
		{
			println( "Music System - music state is undefined Waiting 15 seconds to set music state" );
#/
		}
		wait 30;
		if ( !isDefined( level.nextmusicstate ) )
		{
			self.pers[ "music" ].currentstate = "UNDERSCORE";
			self thread suspensemusic();
		}
	}
	if ( !isDefined( level.nextmusicstate ) )
	{
/#
		if ( getDvarInt( #"0BC4784C" ) > 0 )
		{
			println( "Music System - music state is undefined Waiting 15 seconds to set music state" );
#/
		}
		self.pers[ "music" ].currentstate = "UNDERSCORE";
		self thread suspensemusic();
	}
}

suspensemusicforplayer()
{
	self endon( "disconnect" );
	self thread set_music_on_player( "UNDERSCORE", 0 );
/#
	if ( getDvarInt( #"0BC4784C" ) > 0 )
	{
		println( "Music System - Setting Music State Random Underscore " + self.pers[ "music" ].returnstate + " On player " + self getentitynumber() );
#/
	}
}

suspensemusic( random )
{
	level endon( "game_ended" );
	level endon( "match_ending_soon" );
	self endon( "disconnect" );
/#
	if ( getDvarInt( #"0BC4784C" ) > 0 )
	{
		println( "Music System - Starting random underscore" );
#/
	}
	while ( 1 )
	{
		wait randomintrange( 25, 60 );
/#
		if ( getDvarInt( #"0BC4784C" ) > 0 )
		{
			println( "Music System - Checking for random underscore" );
#/
		}
		if ( !isDefined( self.pers[ "music" ].inque ) )
		{
			self.pers[ "music" ].inque = 0;
		}
		while ( self.pers[ "music" ].inque )
		{
/#
			if ( getDvarInt( #"0BC4784C" ) > 0 )
			{
				println( "Music System - Inque no random underscore" );
#/
			}
		}
		if ( !isDefined( self.pers[ "music" ].currentstate ) )
		{
			self.pers[ "music" ].currentstate = "SILENT";
		}
		if ( randomint( 100 ) < self.underscorechance && self.pers[ "music" ].currentstate != "ACTION" && self.pers[ "music" ].currentstate != "TIME_OUT" )
		{
			self thread suspensemusicforplayer();
			self.underscorechance -= 20;
/#
			if ( getDvarInt( #"0BC4784C" ) > 0 )
			{
				println( "Music System - Starting random underscore" );
#/
			}
		}
	}
}

leaderdialogforotherteams( dialog, skip_team, squad_dialog )
{
	_a339 = level.teams;
	_k339 = getFirstArrayKey( _a339 );
	while ( isDefined( _k339 ) )
	{
		team = _a339[ _k339 ];
		if ( team != skip_team )
		{
			leaderdialog( dialog, team, undefined, undefined, squad_dialog );
		}
		_k339 = getNextArrayKey( _a339, _k339 );
	}
}

announceroundwinner( winner, delay )
{
	if ( delay > 0 )
	{
		wait delay;
	}
	if ( !isDefined( winner ) || isplayer( winner ) )
	{
		return;
	}
	if ( isDefined( level.teams[ winner ] ) )
	{
		leaderdialog( "round_success", winner );
		leaderdialogforotherteams( "round_failure", winner );
	}
	else
	{
		_a365 = level.teams;
		_k365 = getFirstArrayKey( _a365 );
		while ( isDefined( _k365 ) )
		{
			team = _a365[ _k365 ];
			thread playsoundonplayers( "mus_round_draw" + "_" + level.teampostfix[ team ] );
			_k365 = getNextArrayKey( _a365, _k365 );
		}
		leaderdialog( "round_draw" );
	}
}

announcegamewinner( winner, delay )
{
	if ( delay > 0 )
	{
		wait delay;
	}
	if ( !isDefined( winner ) || isplayer( winner ) )
	{
		return;
	}
	if ( isDefined( level.teams[ winner ] ) )
	{
		leaderdialog( "mission_success", winner );
		leaderdialogforotherteams( "mission_failure", winner );
	}
	else
	{
		leaderdialog( "mission_draw" );
	}
}

doflameaudio()
{
	self endon( "disconnect" );
	waittillframeend;
	if ( !isDefined( self.lastflamehurtaudio ) )
	{
		self.lastflamehurtaudio = 0;
	}
	currenttime = getTime();
	if ( ( self.lastflamehurtaudio + level.fire_audio_repeat_duration + randomint( level.fire_audio_random_max_duration ) ) < currenttime )
	{
		self playlocalsound( "vox_pain_small" );
		self.lastflamehurtaudio = currenttime;
	}
}

leaderdialog( dialog, team, group, excludelist, squaddialog )
{
/#
	assert( isDefined( level.players ) );
#/
	if ( level.splitscreen )
	{
		return;
	}
	if ( level.wagermatch )
	{
		return;
	}
	if ( !isDefined( team ) )
	{
		dialogs = [];
		_a425 = level.teams;
		_k425 = getFirstArrayKey( _a425 );
		while ( isDefined( _k425 ) )
		{
			team = _a425[ _k425 ];
			dialogs[ team ] = dialog;
			_k425 = getNextArrayKey( _a425, _k425 );
		}
		leaderdialogallteams( dialogs, group, excludelist );
		return;
	}
	if ( level.splitscreen )
	{
		if ( level.players.size )
		{
			level.players[ 0 ] leaderdialogonplayer( dialog, group );
		}
		return;
	}
	if ( isDefined( excludelist ) )
	{
		i = 0;
		while ( i < level.players.size )
		{
			player = level.players[ i ];
			if ( isDefined( player.pers[ "team" ] ) && player.pers[ "team" ] == team && !maps/mp/gametypes_zm/_globallogic_utils::isexcluded( player, excludelist ) )
			{
				player leaderdialogonplayer( dialog, group );
			}
			i++;
		}
	}
	else i = 0;
	while ( i < level.players.size )
	{
		player = level.players[ i ];
		if ( isDefined( player.pers[ "team" ] ) && player.pers[ "team" ] == team )
		{
			player leaderdialogonplayer( dialog, group );
		}
		i++;
	}
}

leaderdialogallteams( dialogs, group, excludelist )
{
/#
	assert( isDefined( level.players ) );
#/
	if ( level.splitscreen )
	{
		return;
	}
	if ( level.splitscreen )
	{
		if ( level.players.size )
		{
			level.players[ 0 ] leaderdialogonplayer( dialogs[ level.players[ 0 ].team ], group );
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
		else if ( !isDefined( dialogs[ team ] ) )
		{
			i++;
			continue;
		}
		else if ( isDefined( excludelist ) && maps/mp/gametypes_zm/_globallogic_utils::isexcluded( player, excludelist ) )
		{
			i++;
			continue;
		}
		else
		{
			player leaderdialogonplayer( dialogs[ team ], group );
		}
		i++;
	}
}

flushdialog()
{
	_a495 = level.players;
	_k495 = getFirstArrayKey( _a495 );
	while ( isDefined( _k495 ) )
	{
		player = _a495[ _k495 ];
		player flushdialogonplayer();
		_k495 = getNextArrayKey( _a495, _k495 );
	}
}

flushdialogonplayer()
{
	self.leaderdialoggroups = [];
	self.leaderdialogqueue = [];
	self.leaderdialogactive = 0;
	self.currentleaderdialoggroup = "";
}

flushgroupdialog( group )
{
	_a512 = level.players;
	_k512 = getFirstArrayKey( _a512 );
	while ( isDefined( _k512 ) )
	{
		player = _a512[ _k512 ];
		player flushgroupdialogonplayer( group );
		_k512 = getNextArrayKey( _a512, _k512 );
	}
}

flushgroupdialogonplayer( group )
{
	_a522 = self.leaderdialogqueue;
	key = getFirstArrayKey( _a522 );
	while ( isDefined( key ) )
	{
		dialog = _a522[ key ];
		if ( dialog == group )
		{
		}
		key = getNextArrayKey( _a522, key );
	}
}

addgroupdialogtoplayer( dialog, group )
{
	if ( !isDefined( level.dialoggroup[ group ] ) )
	{
		error( "leaderDialogOnPlayer:  Dialog group " + group + " is not registered" );
		return 0;
	}
	addtoqueue = 0;
	if ( !isDefined( self.leaderdialoggroups[ group ] ) )
	{
		addtoqueue = 1;
	}
	if ( !level.dialoggroup[ group ].skipifcurrentlyplayinggroup )
	{
		if ( self.currentleaderdialog == dialog && ( self.currentleaderdialogtime + 2000 ) > getTime() )
		{
			_a552 = self.leaderdialogqueue;
			key = getFirstArrayKey( _a552 );
			while ( isDefined( key ) )
			{
				leader_dialog = _a552[ key ];
				if ( leader_dialog == group )
				{
					i = key + 1;
					while ( i < self.leaderdialogqueue.size )
					{
						self.leaderdialogqueue[ i - 1 ] = self.leaderdialogqueue[ i ];
						i++;
					}
					break;
				}
				else
				{
					key = getNextArrayKey( _a552, key );
				}
			}
			return 0;
		}
	}
	else
	{
		if ( self.currentleaderdialoggroup == group )
		{
			return 0;
		}
	}
	self.leaderdialoggroups[ group ] = dialog;
	return addtoqueue;
}

testdialogqueue( group )
{
/#
	count = 0;
	_a585 = self.leaderdialogqueue;
	_k585 = getFirstArrayKey( _a585 );
	while ( isDefined( _k585 ) )
	{
		temp = _a585[ _k585 ];
		if ( temp == group )
		{
			count++;
		}
		_k585 = getNextArrayKey( _a585, _k585 );
	}
	if ( count > 1 )
	{
		shit = 0;
#/
	}
}

leaderdialogonplayer( dialog, group )
{
	team = self.pers[ "team" ];
	if ( level.splitscreen )
	{
		return;
	}
	if ( !isDefined( team ) )
	{
		return;
	}
	if ( !isDefined( level.teams[ team ] ) )
	{
		return;
	}
	if ( isDefined( group ) )
	{
		if ( !addgroupdialogtoplayer( dialog, group ) )
		{
			self testdialogqueue( group );
			return;
		}
		dialog = group;
	}
	if ( !self.leaderdialogactive )
	{
		self thread playleaderdialogonplayer( dialog );
	}
	else
	{
		self.leaderdialogqueue[ self.leaderdialogqueue.size ] = dialog;
	}
}

waitforsound( sound, extratime )
{
	if ( !isDefined( extratime ) )
	{
		extratime = 0,1;
	}
	time = soundgetplaybacktime( sound );
	if ( time < 0 )
	{
		wait ( 3 + extratime );
	}
	else
	{
		wait ( ( time * 0,001 ) + extratime );
	}
}

playleaderdialogonplayer( dialog )
{
	if ( isDefined( level.allowannouncer ) && !level.allowannouncer )
	{
		return;
	}
	team = self.pers[ "team" ];
	self endon( "disconnect" );
	self.leaderdialogactive = 1;
	if ( isDefined( self.leaderdialoggroups[ dialog ] ) )
	{
		group = dialog;
		dialog = self.leaderdialoggroups[ group ];
		self.currentleaderdialoggroup = group;
		self testdialogqueue( group );
	}
	if ( level.wagermatch || !isDefined( game[ "voice" ] ) )
	{
		faction = "vox_wm_";
	}
	else
	{
		faction = game[ "voice" ][ team ];
	}
	sound_name = faction + game[ "dialog" ][ dialog ];
	if ( level.allowannouncer )
	{
		self playlocalsound( sound_name );
		self.currentleaderdialog = dialog;
		self.currentleaderdialogtime = getTime();
	}
	waitforsound( sound_name );
	self.leaderdialogactive = 0;
	self.currentleaderdialoggroup = "";
	self.currentleaderdialog = "";
	if ( self.leaderdialogqueue.size > 0 )
	{
		nextdialog = self.leaderdialogqueue[ 0 ];
		i = 1;
		while ( i < self.leaderdialogqueue.size )
		{
			self.leaderdialogqueue[ i - 1 ] = self.leaderdialogqueue[ i ];
			i++;
		}
		if ( isDefined( self.leaderdialoggroups[ dialog ] ) )
		{
			self testdialogqueue( dialog );
		}
		self thread playleaderdialogonplayer( nextdialog );
	}
}

isteamwinning( checkteam )
{
	score = game[ "teamScores" ][ checkteam ];
	_a702 = level.teams;
	_k702 = getFirstArrayKey( _a702 );
	while ( isDefined( _k702 ) )
	{
		team = _a702[ _k702 ];
		if ( team != checkteam )
		{
			if ( game[ "teamScores" ][ team ] >= score )
			{
				return 0;
			}
		}
		_k702 = getNextArrayKey( _a702, _k702 );
	}
	return 1;
}

announceteamiswinning()
{
	_a716 = level.teams;
	_k716 = getFirstArrayKey( _a716 );
	while ( isDefined( _k716 ) )
	{
		team = _a716[ _k716 ];
		if ( isteamwinning( team ) )
		{
			leaderdialog( "winning", team, undefined, undefined, "squad_winning" );
			leaderdialogforotherteams( "losing", team, "squad_losing" );
			return 1;
		}
		_k716 = getNextArrayKey( _a716, _k716 );
	}
	return 0;
}

musiccontroller()
{
	level endon( "game_ended" );
	level thread musictimesout();
	level waittill( "match_ending_soon" );
	if ( islastround() || isoneround() )
	{
		while ( !level.splitscreen )
		{
			if ( level.teambased )
			{
				if ( !announceteamiswinning() )
				{
					leaderdialog( "min_draw" );
				}
			}
			level waittill( "match_ending_very_soon" );
			_a751 = level.teams;
			_k751 = getFirstArrayKey( _a751 );
			while ( isDefined( _k751 ) )
			{
				team = _a751[ _k751 ];
				leaderdialog( "timesup", team, undefined, undefined, "squad_30sec" );
				_k751 = getNextArrayKey( _a751, _k751 );
			}
		}
	}
	else level waittill( "match_ending_vox" );
	leaderdialog( "timesup" );
}

musictimesout()
{
	level endon( "game_ended" );
	level waittill( "match_ending_very_soon" );
	thread maps/mp/gametypes_zm/_globallogic_audio::set_music_on_team( "TIME_OUT", "both", 1, 0 );
}

actionmusicset()
{
	level endon( "game_ended" );
	level.playingactionmusic = 1;
	wait 45;
	level.playingactionmusic = 0;
}

play_2d_on_team( alias, team )
{
/#
	assert( isDefined( level.players ) );
#/
	i = 0;
	while ( i < level.players.size )
	{
		player = level.players[ i ];
		if ( isDefined( player.pers[ "team" ] ) && player.pers[ "team" ] == team )
		{
			player playlocalsound( alias );
		}
		i++;
	}
}

set_music_on_team( state, team, save_state, return_state, wait_time )
{
	if ( sessionmodeiszombiesgame() )
	{
		return;
	}
/#
	assert( isDefined( level.players ) );
#/
	if ( !isDefined( team ) )
	{
		team = "both";
/#
		if ( getDvarInt( #"0BC4784C" ) > 0 )
		{
			println( "Music System - team undefined: Setting to both" );
#/
		}
	}
	if ( !isDefined( save_state ) )
	{
		save_sate = 0;
/#
		if ( getDvarInt( #"0BC4784C" ) > 0 )
		{
			println( "Music System - save_sate undefined: Setting to false" );
#/
		}
	}
	if ( !isDefined( return_state ) )
	{
		return_state = 0;
/#
		if ( getDvarInt( #"0BC4784C" ) > 0 )
		{
			println( "Music System - Music System - return_state undefined: Setting to false" );
#/
		}
	}
	if ( !isDefined( wait_time ) )
	{
		wait_time = 0;
/#
		if ( getDvarInt( #"0BC4784C" ) > 0 )
		{
			println( "Music System - wait_time undefined: Setting to 0" );
#/
		}
	}
	i = 0;
	while ( i < level.players.size )
	{
		player = level.players[ i ];
		if ( team == "both" )
		{
			player thread set_music_on_player( state, save_state, return_state, wait_time );
			i++;
			continue;
		}
		else
		{
			if ( isDefined( player.pers[ "team" ] ) && player.pers[ "team" ] == team )
			{
				player thread set_music_on_player( state, save_state, return_state, wait_time );
/#
				if ( getDvarInt( #"0BC4784C" ) > 0 )
				{
					println( "Music System - Setting Music State " + state + " On player " + player getentitynumber() );
#/
				}
			}
		}
		i++;
	}
}

set_music_on_player( state, save_state, return_state, wait_time )
{
	self endon( "disconnect" );
	if ( sessionmodeiszombiesgame() )
	{
		return;
	}
/#
	assert( isplayer( self ) );
#/
	if ( !isDefined( save_state ) )
	{
		save_state = 0;
/#
		if ( getDvarInt( #"0BC4784C" ) > 0 )
		{
			println( "Music System - Music System - save_sate undefined: Setting to false" );
#/
		}
	}
	if ( !isDefined( return_state ) )
	{
		return_state = 0;
/#
		if ( getDvarInt( #"0BC4784C" ) > 0 )
		{
			println( "Music System - Music System - return_state undefined: Setting to false" );
#/
		}
	}
	if ( !isDefined( wait_time ) )
	{
		wait_time = 0;
/#
		if ( getDvarInt( #"0BC4784C" ) > 0 )
		{
			println( "Music System - wait_time undefined: Setting to 0" );
#/
		}
	}
	if ( !isDefined( state ) )
	{
		state = "UNDERSCORE";
/#
		if ( getDvarInt( #"0BC4784C" ) > 0 )
		{
			println( "Music System - state undefined: Setting to UNDERSCORE" );
#/
		}
	}
	maps/mp/_music::setmusicstate( state, self );
	if ( isDefined( self.pers[ "music" ].currentstate ) && save_state )
	{
		self.pers[ "music" ].returnstate = state;
/#
		if ( getDvarInt( #"0BC4784C" ) > 0 )
		{
			println( "Music System - Saving Music State " + self.pers[ "music" ].returnstate + " On " + self getentitynumber() );
#/
		}
	}
	self.pers[ "music" ].previousstate = self.pers[ "music" ].currentstate;
	self.pers[ "music" ].currentstate = state;
/#
	if ( getDvarInt( #"0BC4784C" ) > 0 )
	{
		println( "Music System - Setting Music State " + state + " On player " + self getentitynumber() );
#/
	}
	if ( isDefined( self.pers[ "music" ].returnstate ) && return_state )
	{
/#
		if ( getDvarInt( #"0BC4784C" ) > 0 )
		{
			println( "Music System - Starting Return State " + self.pers[ "music" ].returnstate + " On " + self getentitynumber() );
#/
		}
		self set_next_music_state( self.pers[ "music" ].returnstate, wait_time );
	}
}

return_music_state_player( wait_time )
{
	if ( !isDefined( wait_time ) )
	{
		wait_time = 0;
/#
		if ( getDvarInt( #"0BC4784C" ) > 0 )
		{
			println( "Music System - wait_time undefined: Setting to 0" );
#/
		}
	}
	self set_next_music_state( self.pers[ "music" ].returnstate, wait_time );
}

return_music_state_team( team, wait_time )
{
	if ( !isDefined( wait_time ) )
	{
		wait_time = 0;
/#
		if ( getDvarInt( #"0BC4784C" ) > 0 )
		{
			println( "Music System - wait_time undefined: Setting to 0" );
#/
		}
	}
	i = 0;
	while ( i < level.players.size )
	{
		player = level.players[ i ];
		if ( team == "both" )
		{
			player thread set_next_music_state( self.pers[ "music" ].returnstate, wait_time );
			i++;
			continue;
		}
		else
		{
			if ( isDefined( player.pers[ "team" ] ) && player.pers[ "team" ] == team )
			{
				player thread set_next_music_state( self.pers[ "music" ].returnstate, wait_time );
/#
				if ( getDvarInt( #"0BC4784C" ) > 0 )
				{
					println( "Music System - Setting Music State " + self.pers[ "music" ].returnstate + " On player " + player getentitynumber() );
#/
				}
			}
		}
		i++;
	}
}

set_next_music_state( nextstate, wait_time )
{
	self endon( "disconnect" );
	self.pers[ "music" ].nextstate = nextstate;
/#
	if ( getDvarInt( #"0BC4784C" ) > 0 )
	{
		println( "Music System - Setting next Music State " + self.pers[ "music" ].nextstate + " On " + self getentitynumber() );
#/
	}
	if ( !isDefined( self.pers[ "music" ].inque ) )
	{
		self.pers[ "music" ].inque = 0;
	}
	if ( self.pers[ "music" ].inque )
	{
		return;
/#
		println( "Music System - Music state in que" );
#/
	}
	else
	{
		self.pers[ "music" ].inque = 1;
		if ( wait_time )
		{
			wait wait_time;
		}
		self set_music_on_player( self.pers[ "music" ].nextstate, 0 );
		self.pers[ "music" ].inque = 0;
	}
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

post_match_snapshot_watcher()
{
	level waittill( "game_ended" );
	level clientnotify( "pm" );
	level waittill( "sfade" );
	level clientnotify( "pmf" );
}
