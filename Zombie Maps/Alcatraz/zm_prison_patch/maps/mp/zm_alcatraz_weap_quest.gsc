//checked includes match cerberus output
#include maps/mp/zombies/_zm_powerups;
#include maps/mp/zombies/_zm_score;
#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/animscripts/shared;
#include maps/mp/zombies/_zm_spawner;
#include maps/mp/zombies/_zm_net;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

//#using_animtree( "fxanim_props" ); //leave commented for now for compiling

init() //checked changed to match cerberus output
{
	flag_init( "soul_catchers_charged" );
	level.soul_catchers = [];
	level.soul_catchers_vol = [];
	level.no_gib_in_wolf_area = ::check_for_zombie_in_wolf_area;
	level.soul_catcher_clip[ "rune_2" ] = getent( "wolf_clip_docks", "targetname" );
	level.soul_catcher_clip[ "rune_3" ] = getent( "wolf_clip_infirmary", "targetname" );
	foreach ( e_clip in level.soul_catcher_clip )
	{
		e_clip setinvisibletoall();
	}
	level thread create_anim_references_on_server();
	registerclientfield( "actor", "make_client_clone", 9000, 4, "int" );
	onplayerconnect_callback( ::toggle_redeemer_trigger );
	onplayerconnect_callback( ::hellhole_projectile_watch );
	onplayerconnect_callback( ::hellhole_tomahawk_watch );
	level.a_wolf_structs = getstructarray( "wolf_position", "targetname" );
	for ( i = 0; i < level.a_wolf_structs.size; i++ )
	{
		registerclientfield( "world", level.a_wolf_structs[ i ].script_parameters, 9000, 3, "int" );
		level.soul_catchers[ i ] = level.a_wolf_structs[ i ];
		level.soul_catchers_vol[ i ] = getent( level.a_wolf_structs[ i ].target, "targetname" );
	}
	for ( i = 0; i < level.soul_catchers.size; i++ )
	{
		level.soul_catchers[ i ].souls_received = 0;
		level.soul_catchers[ i ].is_eating = 0;
		level.soul_catchers[ i ] thread soul_catcher_check();
		if ( is_classic() )
		{
			level.soul_catchers[ i ] thread soul_catcher_state_manager();
		}
		else
		{
			level.soul_catchers[ i ] thread grief_soul_catcher_state_manager();
		}
		level.soul_catchers[ i ] thread wolf_head_removal( "tomahawk_door_sign_" + ( i + 1 ) );
		level.soul_catchers_vol[ i ] = getent( level.soul_catchers[ i ].target, "targetname" );
	}
	level.soul_catchers_charged = 0;
	level thread soul_catchers_charged();
	array_thread( level.zombie_spawners, ::add_spawn_function, ::zombie_spawn_func );
}

create_anim_references_on_server() //checked matches cerberus output
{
	root = %root;
	wolfhead_intro_anim = %o_zombie_dreamcatcher_intro;
	wolfhead_outtro_anim = %o_zombie_dreamcatcher_outtro;
	woflhead_idle_anims = [];
	wolfhead_idle_anim[ 0 ] = %o_zombie_dreamcatcher_idle;
	wolfhead_idle_anim[ 1 ] = %o_zombie_dreamcatcher_idle_twitch_scan;
	wolfhead_idle_anim[ 2 ] = %o_zombie_dreamcatcher_idle_twitch_shake;
	wolfhead_idle_anim[ 3 ] = %o_zombie_dreamcatcher_idle_twitch_yawn;
	wolfhead_body_death = %ai_zombie_dreamcatch_impact;
	wolfhead_body_float = %ai_zombie_dreamcatch_rise;
	wolfhead_body_shrink = %ai_zombie_dreamcatch_shrink_a;
	wolfhead_pre_eat_anims = [];
	wolfhead_pre_eat_anims[ "right" ] = %o_zombie_dreamcatcher_wallconsume_pre_eat_r;
	wolfhead_pre_eat_anims[ "left" ] = %o_zombie_dreamcatcher_wallconsume_pre_eat_l;
	wolfhead_pre_eat_anims[ "front" ] = %o_zombie_dreamcatcher_wallconsume_pre_eat_f;
	wolfhead_eat_anims[ "right" ] = %o_zombie_dreamcatcher_wallconsume_align_r;
	wolfhead_eat_anims[ "left" ] = %o_zombie_dreamcatcher_wallconsume_align_l;
	wolfhead_eat_anims[ "front" ] = %o_zombie_dreamcatcher_wallconsume_align_f;
	wolfhead_body_anims[ "right" ] = %ai_zombie_dreamcatcher_wallconsume_align_r;
	wolfhead_body_anims[ "left" ] = %ai_zombie_dreamcatcher_wallconsume_align_l;
	wolfhead_body_anims[ "front" ] = %ai_zombie_dreamcatcher_wallconsume_align_f;
}

soul_catcher_state_manager() //checked changed to match cerberus output
{
	wait 1;
	if ( self.script_noteworthy == "rune_3" )
	{
		trigger = getent( "wolf_hurt_trigger", "targetname" );
		trigger hide();
	}
	else if ( self.script_noteworthy == "rune_2" )
	{
		trigger = getent( "wolf_hurt_trigger_docks", "targetname" );
		trigger hide();
	}
	level setclientfield( self.script_parameters, 0 );
	self waittill( "first_zombie_killed_in_zone" );
	if ( self.script_noteworthy == "rune_3" )
	{
		trigger = getent( "wolf_hurt_trigger", "targetname" );
		trigger show();
	}
	else if ( self.script_noteworthy == "rune_2" )
	{
		trigger = getent( "wolf_hurt_trigger_docks", "targetname" );
		trigger show();
	}
	if ( isDefined( level.soul_catcher_clip[ self.script_noteworthy ] ) )
	{
		level.soul_catcher_clip[ self.script_noteworthy ] setvisibletoall();
	}
	level setclientfield( self.script_parameters, 1 );
	anim_length = getanimlength( %o_zombie_dreamcatcher_intro );
	wait anim_length;
	while ( !self.is_charged )
	{
		level setclientfield( self.script_parameters, 2 );
		self waittill_either( "fully_charged", "finished_eating" );
	}
	level setclientfield( self.script_parameters, 6 );
	anim_length = getanimlength( %o_zombie_dreamcatcher_outtro );
	wait anim_length;
	if ( isDefined( level.soul_catcher_clip[ self.script_noteworthy ] ) )
	{
		level.soul_catcher_clip[ self.script_noteworthy ] delete();
	}
	if ( self.script_noteworthy == "rune_3" )
	{
		trigger = getent( "wolf_hurt_trigger", "targetname" );
		trigger delete();
	}
	else if ( self.script_noteworthy == "rune_2" )
	{
		trigger = getent( "wolf_hurt_trigger_docks", "targetname" );
		trigger delete();
	}
	level setclientfield( self.script_parameters, 7 );
}

grief_soul_catcher_state_manager() //checked matches cerberus output
{
	wait 1;
	while ( 1 )
	{
		level setclientfield( self.script_parameters, 0 );
		self waittill( "first_zombie_killed_in_zone" );
		if ( isDefined( level.soul_catcher_clip[ self.script_noteworthy ] ) )
		{
			level.soul_catcher_clip[ self.script_noteworthy ] setvisibletoall();
		}
		level setclientfield( self.script_parameters, 1 );
		anim_length = getanimlength( %o_zombie_dreamcatcher_intro );
		wait anim_length;
		while ( !self.is_charged )
		{
			level setclientfield( self.script_parameters, 2 );
			self waittill_either( "fully_charged", "finished_eating" );
		}
		level setclientfield( self.script_parameters, 6 );
		anim_length = getanimlength( %o_zombie_dreamcatcher_outtro );
		wait anim_length;
		if ( isDefined( level.soul_catcher_clip[ self.script_noteworthy ] ) )
		{
			level.soul_catcher_clip[ self.script_noteworthy ] delete();
		}
		self.souls_received = 0;
		level thread wolf_spit_out_powerup();
		wait 20;
		self thread soul_catcher_check();
	}
}

wolf_spit_out_powerup() //checked changed to match cerberus output
{
	if ( isDefined( level.enable_magic ) && !level.enable_magic )
	{
		return;
	}
	power_origin_struct = getstruct( "wolf_puke_powerup_origin", "targetname" );
	if ( randomint( 100 ) < 20 )
	{
		for ( i = 0; i < level.zombie_powerup_array.size; i++ )
		{
			if ( level.zombie_powerup_array[ i ] == "meat_stink" )
			{
				level.zombie_powerup_index = i;
				found = 1;
				break;
			}
		}
	}
	while ( 1 )
	{
		level.zombie_powerup_index = randomint( level.zombie_powerup_array.size );
		if ( level.zombie_powerup_array[ level.zombie_powerup_index ] == "nuke" )
		{
			wait 0.05;
			continue;
		}
		break;
	}
	spawn_infinite_powerup_drop( power_origin_struct.origin, level.zombie_powerup_array[ level.zombie_powerup_index ] );
	power_ups = get_array_of_closest( power_origin_struct.origin, level.active_powerups, undefined, undefined, 100 );
	if ( isDefined( power_ups[ 0 ] ) )
	{
		power_ups[ 0 ] movez( 120, 4 );
	}
}

zombie_spawn_func() //checked matches cerberus output
{
	self.actor_killed_override = ::zombie_killed_override;
}

zombie_killed_override( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime ) //checked changed to match cerberus output
{
	if ( !is_true( self.has_legs ) )
	{
		return;
	}
	if ( isplayer( attacker ) )
	{
		for ( i = 0; i < level.soul_catchers.size; i++ )
		{
			if ( self istouching( level.soul_catchers_vol[ i ] ) )
			{
				if ( !level.soul_catchers[ i ].is_charged )
				{
					self.deathfunction = ::zombie_soul_catcher_death;
					self.my_soul_catcher = level.soul_catchers[ i ];
				}
			}
		}
	}
}

check_for_zombie_in_wolf_area() //checked changed to match cerberus output
{
	for ( i = 0; i < level.soul_catchers.size; i++ )
	{
		if ( self istouching( level.soul_catchers_vol[ i ] ) )
		{
			if ( !level.soul_catchers[ i ].is_charged && !level.soul_catchers[ i ].is_eating )
			{
				return 1;
			}
		}
	}
	return 0;
}

zombie_soul_catcher_death() //checked matches cerberus output
{
	self thread maps/mp/zombies/_zm_spawner::zombie_death_animscript();
	if ( isDefined( self._race_team ) )
	{
		team = self._race_team;
	}
	level maps/mp/zombies/_zm_spawner::zombie_death_points( self.origin, self.damagemod, self.damagelocation, self.attacker, self, team );
	if ( self.my_soul_catcher.is_eating )
	{
		return 0;
	}
	if ( self.my_soul_catcher.souls_received >= 6 )
	{
		return 0;
	}
	self.my_soul_catcher.is_eating = 1;
	if ( self.my_soul_catcher.souls_received == 0 )
	{
		self.my_soul_catcher notify( "first_zombie_killed_in_zone" );
		self thread notify_wolf_intro_anim_complete();
	}
	client_notify_value = self get_correct_model_array();
	self setclientfield( "make_client_clone", client_notify_value );
	self setanimstatefromasd( "zm_portal_death" );
	self maps/mp/animscripts/shared::donotetracks( "portal_death" );
	if ( self.my_soul_catcher.souls_received == 0 )
	{
		self waittill( "wolf_intro_anim_complete" );
	}
	n_eating_anim = self which_eating_anim();
	self ghost();
	level setclientfield( self.my_soul_catcher.script_parameters, n_eating_anim );
	if ( n_eating_anim == 3 )
	{
		total_wait_time = 3 + getanimlength( %ai_zombie_dreamcatcher_wallconsume_align_f );
	}
	else if ( n_eating_anim == 4 )
	{
		total_wait_time = 3 + getanimlength( %ai_zombie_dreamcatcher_wallconsume_align_r );
	}
	else
	{
		total_wait_time = 3 + getanimlength( %ai_zombie_dreamcatcher_wallconsume_align_l );
	}
	wait ( total_wait_time - 0.5 );
	self.my_soul_catcher.souls_received++;
	wait 0.5;
	self.my_soul_catcher notify( "finished_eating" );
	self.my_soul_catcher.is_eating = 0;
	self delete();
	return 1;
}

get_correct_model_array() //checked matches cerberus output
{
	mod = 0;
	if ( self.model == "c_zom_guard_body" && isDefined( self.hatmodel ) && self.hatmodel == "c_zom_guard_hat" )
	{
		mod = 4;
	}
	if ( self.headmodel == "c_zom_zombie_barbwire_head" )
	{
		return 1 + mod;
	}
	if ( self.headmodel == "c_zom_zombie_hellcatraz_head" )
	{
		return 2 + mod;
	}
	if ( self.headmodel == "c_zom_zombie_mask_head" )
	{
		return 3 + mod;
	}
	if ( self.headmodel == "c_zom_zombie_slackjaw_head" )
	{
		return 4 + mod;
	}
	return 5;
}

notify_wolf_intro_anim_complete() //checked matches cerberus output
{
	anim_length = getanimlength( %o_zombie_dreamcatcher_intro );
	wait anim_length;
	self notify( "wolf_intro_anim_complete" );
}

which_eating_anim() //checked matches cerberus output
{
	soul_catcher = self.my_soul_catcher;
	forward_dot = vectordot( anglesToForward( soul_catcher.angles ), vectornormalize( self.origin - soul_catcher.origin ) );
	if ( forward_dot > 0.85 )
	{
		return 3;
	}
	else
	{
		right_dot = vectordot( anglesToRight( soul_catcher.angles ), self.origin - soul_catcher.origin );
		if ( right_dot > 0 )
		{
			return 4;
		}
		else
		{
			return 5;
		}
	}
}

soul_catcher_check() //checked changed to match cerberus output
{
	self.is_charged = 0;
	while ( 1 )
	{
		if ( self.souls_received >= 6 )
		{
			level.soul_catchers_charged++;
			level thread maps/mp/zombies/_zm_audio::sndmusicstingerevent( "tomahawk_" + level.soul_catchers_charged );
			self.is_charged = 1;
			self notify( "fully_charged" );
			break;
		}
		wait 0.05;
	}
	if ( level.soul_catchers_charged == 1 )
	{
		self thread first_wolf_complete_vo();
	}
	else if ( level.soul_catchers_charged >= level.soul_catchers.size )
	{
		self thread final_wolf_complete_vo();
	}
}

wolf_head_removal( wolf_head_model_string ) //checked matches cerberus output
{
	wolf_head_model = getent( wolf_head_model_string, "targetname" );
	wolf_head_model setmodel( "p6_zm_al_dream_catcher_off" );
	self waittill( "fully_charged" );
	wolf_head_model setmodel( "p6_zm_al_dream_catcher" );
}

soul_catchers_charged() //checked changed to match cerberus output
{
	while ( 1 )
	{
		if ( level.soul_catchers_charged >= level.soul_catchers.size )
		{
			flag_set( "soul_catchers_charged" );
			level notify( "soul_catchers_charged" );
			break;
		}
		wait 1;
	}
}

first_wolf_encounter_vo() //checked changed to match cerberus output
{
	if ( !is_classic() )
	{
		return;
	}
	wait 2;
	a_players = getplayers();
	a_closest = get_array_of_closest( self.origin, a_players );
	for ( i = 0; i < a_closest.size; i++ )
	{
		if ( isDefined( a_closest[ i ].dontspeak ) && !a_closest[ i ].dontspeak )
		{
			a_closest[ i ] thread do_player_general_vox( "general", "wolf_encounter" );
			level.wolf_encounter_vo_played = 1;
			break;
		}
	}
}

first_wolf_complete_vo() //checked changed to match cerberus output
{
	if ( !is_classic() )
	{
		return;
	}
	wait 3.5;
	a_players = getplayers();
	a_closest = get_array_of_closest( self.origin, a_players );
	for ( i = 0; i < a_closest.size; i++ )
	{
		if ( isDefined( a_closest[ i ].dontspeak ) && !a_closest[ i ].dontspeak )
		{
			a_closest[ i ] thread do_player_general_vox( "general", "wolf_complete" );
			break;
		}
	}
}

final_wolf_complete_vo() //checked changed to match cerberus output
{
	if ( !is_classic() )
	{
		return;
	}
	wait 3.5;
	a_players = getplayers();
	a_closest = get_array_of_closest( self.origin, a_players );
	for ( i = 0; i < a_closest.size; i++ )
	{
		if ( isDefined( a_closest[ i ].dontspeak ) && !a_closest[ i ].dontspeak )
		{
			a_closest[ i ] thread do_player_general_vox( "general", "wolf_final" );
			break;
		}
	}
}

tomahawk_upgrade_quest() //checked changed to match cerberus output
{
	if ( isDefined( level.gamedifficulty ) && level.gamedifficulty == 0 )
	{
		return;
	}
	self endon( "disconnect" );
	for ( self.tomahawk_upgrade_kills = 0; self.tomahawk_upgrade_kills < 15; self.tomahawk_upgrade_kills++ )
	{
		self waittill( "got_a_tomahawk_kill" );
	}
	wait 1;
	level thread maps/mp/zombies/_zm_audio::sndmusicstingerevent( "quest_generic" );
	e_org = spawn( "script_origin", self.origin + vectorScale( ( 0, 0, 1 ), 64 ) );
	e_org playsoundwithnotify( "zmb_easteregg_scream", "easteregg_scream_complete" );
	e_org waittill( "easteregg_scream_complete" );
	e_org delete();
	while ( level.round_number < 10 )
	{
		wait 0.5;
	}
	self ent_flag_init( "gg_round_done" );
	while ( !self ent_flag( "gg_round_done" ) )
	{
		level waittill( "between_round_over" );
		self.killed_with_only_tomahawk = 1;
		self.killed_something_thq = 0;
		if ( !self maps/mp/zombies/_zm_zonemgr::is_player_in_zone( "zone_golden_gate_bridge" ) )
		{
			continue;
		}
		level waittill( "end_of_round" );
		if ( !self.killed_with_only_tomahawk || !self.killed_something_thq )
		{
			continue;
		}
		if ( !self maps/mp/zombies/_zm_zonemgr::is_player_in_zone( "zone_golden_gate_bridge" ) )
		{
			continue;
		}
		self ent_flag_set( "gg_round_done" );
	}
	level thread maps/mp/zombies/_zm_audio::sndmusicstingerevent( "quest_generic" );
	e_org = spawn( "script_origin", self.origin + vectorScale( ( 0, 0, 1 ), 64 ) );
	e_org playsoundwithnotify( "zmb_easteregg_scream", "easteregg_scream_complete" );
	e_org waittill( "easteregg_scream_complete" );
	e_org delete();
	self notify( "hellhole_time" );
	self waittill( "tomahawk_in_hellhole" );
	if ( isDefined( self.retriever_trigger ) )
	{
		self.retriever_trigger setinvisibletoplayer( self );
	}
	else
	{
		trigger = getent( "retriever_pickup_trigger", "script_noteworthy" );
		self.retriever_trigger = trigger;
		self.retriever_trigger setinvisibletoplayer( self );
	}
	self takeweapon( "bouncing_tomahawk_zm" );
	self set_player_tactical_grenade( "none" );
	self notify( "tomahawk_upgraded_swap" );
	level thread maps/mp/zombies/_zm_audio::sndmusicstingerevent( "quest_generic" );
	e_org = spawn( "script_origin", self.origin + vectorScale( ( 0, 0, 1 ), 64 ) );
	e_org playsoundwithnotify( "zmb_easteregg_scream", "easteregg_scream_complete" );
	e_org waittill( "easteregg_scream_complete" );
	e_org delete();
	level waittill( "end_of_round" );
	tomahawk_pick = getent( "spinning_tomahawk_pickup", "targetname" );
	tomahawk_pick setclientfield( "play_tomahawk_fx", 2 );
	self.current_tomahawk_weapon = "upgraded_tomahawk_zm";
}

toggle_redeemer_trigger() //checked changed to match cerberus output
{
	self endon( "disconnect" );
	flag_wait( "tomahawk_pickup_complete" );
	upgraded_tomahawk_trigger = getent( "redeemer_pickup_trigger", "script_noteworthy" );
	upgraded_tomahawk_trigger setinvisibletoplayer( self );
	tomahawk_model = getent( "spinning_tomahawk_pickup", "targetname" );
	while ( 1 )
	{
		if ( isDefined( self.current_tomahawk_weapon ) && self.current_tomahawk_weapon == "upgraded_tomahawk_zm" )
		{
			break;
		}
		else 
		{
			wait 1;
		}
	}
	while ( 1 )
	{
		if ( isDefined( self.afterlife ) && self.afterlife )
		{
			upgraded_tomahawk_trigger setvisibletoplayer( self );
			tomahawk_model setvisibletoplayer( self );
		}
		else
		{
			upgraded_tomahawk_trigger setinvisibletoplayer( self );
			tomahawk_model setinvisibletoplayer( self );
		}
		wait 1;
	}
}

hellhole_projectile_watch() //checked matches cerberus output
{
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "grenade_fire", grenade, weapname );
		if ( weapname == "frag_grenade_zm" )
		{
			self thread hellhole_grenades( grenade );
		}
	}
}

hellhole_tomahawk_watch() //checked matches cerberus output
{
	self endon( "disconnect" );
	self waittill( "hellhole_time" );
	while ( 1 )
	{
		self waittill( "grenade_fire", grenade, weapname );
		if ( weapname == "bouncing_tomahawk_zm" )
		{
			self thread hellhole_tomahawk( grenade );
		}
	}
}

hellhole_grenades( grenade ) //checked matches cerberus output
{
	grenade endon( "death" );
	trig_hellhole = getent( "trig_cellblock_hellhole", "targetname" );
	while ( !grenade istouching( trig_hellhole ) )
	{
		wait 0.05;
	}
	self maps/mp/zombies/_zm_score::add_to_player_score( 20 );
	playfx( level._effect[ "tomahawk_hellhole" ], grenade.origin );
	playsoundatposition( "wpn_grenade_poof", grenade.origin );
	grenade delete();
}

hellhole_tomahawk( grenade ) //checked matches cerberus output
{
	grenade endon( "death" );
	trig_hellhole = getent( "trig_cellblock_hellhole", "targetname" );
	while ( !grenade istouching( trig_hellhole ) )
	{
		wait 0.05;
	}
	self notify( "tomahawk_in_hellhole" );
	grenade notify( "in_hellhole" );
	playfx( level._effect[ "tomahawk_hellhole" ], grenade.origin );
	playsoundatposition( "wpn_grenade_poof", grenade.origin );
	grenade delete();
}

spawn_infinite_powerup_drop( v_origin, str_type ) //checked matches cerberus output
{
	if ( isDefined( str_type ) )
	{
		intro_powerup = maps/mp/zombies/_zm_powerups::specific_powerup_drop( str_type, v_origin );
	}
	else
	{
		intro_powerup = maps/mp/zombies/_zm_powerups::powerup_drop( v_origin );
	}
}

