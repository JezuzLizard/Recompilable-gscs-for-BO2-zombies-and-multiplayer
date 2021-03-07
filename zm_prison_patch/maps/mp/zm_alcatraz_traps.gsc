//checked includes match cerberus output
#include maps/mp/zombies/_zm_ai_brutus;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/animscripts/zm_death;
#include maps/mp/zombies/_zm_laststand;
#include maps/mp/zombies/_zm_score;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

//#using_animtree( "fxanim_props" ); //uncomment when the compiler supports anim trees

init_fan_trap_trigs() //checked matches cerberus output
{
	trap_trigs = getentarray( "fan_trap_use_trigger", "targetname" );
	array_thread( trap_trigs, ::fan_trap_think );
	init_fan_fxanim( "wardens_office" );
}

init_fan_trap_animtree() //checked matches cerberus output
{
	scriptmodelsuseanimtree( -1 );
}

init_fan_fxanim( str_loc ) //checked matches cerberus output
{
	e_fan = getent( "fxanim_fan_" + str_loc, "targetname" );
	level.fan_trap_fxanims = [];
	level.fan_trap_fxanims[ "fan_trap_start" ] = %fxanim_zom_al_trap_fan_start_anim;
	level.fan_trap_fxanims[ "fan_trap_idle" ] = %fxanim_zom_al_trap_fan_idle_anim;
	level.fan_trap_fxanims[ "fan_trap_end" ] = %fxanim_zom_al_trap_fan_end_anim;
}

fan_trap_think() //checked changed to match cerberus output
{
	triggers = getentarray( self.targetname, "targetname" );
	self.cost = 1000;
	self.in_use = 0;
	self.is_available = 1;
	self.has_been_used = 0;
	self.zombie_dmg_trig = getent( self.target, "targetname" );
	self.zombie_dmg_trig.script_string = self.script_string;
	self.zombie_dmg_trig.in_use = 0;
	self.rumble_trig = getent( "fan_trap_rumble", "targetname" );
	light_name = self get_trap_light_name();
	zapper_light_red( light_name );
	self sethintstring( &"ZM_PRISON_FAN_TRAP_UNAVAILABLE" );
	flag_wait( "activate_warden_office" );
	zapper_light_green( light_name );
	self hint_string( &"ZM_PRISON_FAN_TRAP", self.cost );
	while ( 1 )
	{
		self waittill( "trigger", who );
		if ( who in_revive_trigger() )
		{
			continue;
		}
		if ( !isDefined( self.is_available ) )
		{
			continue;
		}
		if ( is_player_valid( who ) )
		{
			if ( who.score >= self.cost )
			{
				if ( !self.zombie_dmg_trig.in_use )
				{
					if ( !self.has_been_used )
					{
						self.has_been_used = 1;
						level thread maps/mp/zombies/_zm_audio::sndmusicstingerevent( "trap" );
						who do_player_general_vox( "general", "discover_trap" );
					}
					else
					{
						who do_player_general_vox( "general", "start_trap" );
					}
					self.zombie_dmg_trig.in_use = 1;
					self.zombie_dmg_trig.active = 1;
					self playsound( "zmb_trap_activate" );
					self thread fan_trap_move_switch( self );
					self waittill( "switch_activated" );
					who minus_to_player_score( self.cost );
					level.trapped_track[ "fan" ] = 1;
					level notify( "trap_activated" );
					who maps/mp/zombies/_zm_stats::increment_client_stat( "prison_fan_trap_used", 0 );
					array_thread( triggers, ::hint_string, &"ZOMBIE_TRAP_ACTIVE" );
					self.zombie_dmg_trig setvisibletoall();
					self thread activate_fan_trap();
					self.zombie_dmg_trig waittill( "trap_finished_" + self.script_string );
					clientnotify( self.script_string + "off" );
					self.zombie_dmg_trig notify( "fan_trap_finished" );
					self.zombie_dmg_trig.active = 0;
					self.zombie_dmg_trig setinvisibletoall();
					array_thread( triggers, ::hint_string, &"ZOMBIE_TRAP_COOLDOWN" );
					wait 25;
					self playsound( "zmb_trap_available" );
					self notify( "available" );
					self.zombie_dmg_trig.in_use = 0;
					array_thread( triggers, ::hint_string, &"ZM_PRISON_FAN_TRAP", self.cost );
				}
			}
		}
	}
}

activate_fan_trap() //checked changed to match cerberus output
{
	self.zombie_dmg_trig thread fan_trap_damage( self );
	e_fan = getent( "fxanim_fan_" + self.script_string, "targetname" );
	e_fan useanimtree( -1 );
	e_fan playsound( "zmb_trap_fan_start" );
	e_fan playloopsound( "zmb_trap_fan_loop", 2 );
	n_start_time = getanimlength( level.fan_trap_fxanims[ "fan_trap_start" ] );
	n_idle_time = getanimlength( level.fan_trap_fxanims[ "fan_trap_idle" ] );
	n_end_time = getanimlength( level.fan_trap_fxanims[ "fan_trap_end" ] );
	e_fan setanim( level.fan_trap_fxanims[ "fan_trap_start" ], 1, 0.1, 1 );
	wait n_start_time;
	e_fan setanim( level.fan_trap_fxanims[ "fan_trap_idle" ], 1, 0.1, 1 );
	self thread fan_trap_timeout();
	self thread fan_trap_rumble_think();
	self.zombie_dmg_trig waittill( "trap_finished_" + self.script_string );
	e_fan setanim( level.fan_trap_fxanims[ "fan_trap_end" ], 1, 0.1, 1 );
	a_players = getplayers();
	foreach ( player in a_players )
	{
		if ( is_true( player.fan_trap_rumble ) )
		{
			player setclientfieldtoplayer( "rumble_fan_trap", 0 );
			player.fan_trap_rumble = 0;
		}
	}
	e_fan stoploopsound( 0.75 );
	e_fan playsound( "zmb_trap_fan_end" );
	wait n_end_time;
}

fan_trap_timeout() //checked does not match cerberus output did not change
{
	self.zombie_dmg_trig endon( "trap_finished_" + self.script_string );
	n_duration = 0;
	while ( n_duration < 25 )
	{
		wait 0,05;
		n_duration += 0.05;
	}
	self.zombie_dmg_trig notify( "trap_finished_" + self.script_string );
}

fan_trap_rumble_think() //checked matches cerberus output
{
	self.zombie_dmg_trig endon( "trap_finished_" + self.script_string );
	while ( 1 )
	{
		self.rumble_trig waittill( "trigger", ent );
		if ( isplayer( ent ) )
		{
			if ( !is_true( ent.fan_trap_rumble ) )
			{
				self thread fan_trap_rumble( ent );
			}
		}
	}
}

fan_trap_rumble( player ) //checked changed to match cerberus output
{
	player endon( "death" );
	player endon( "disconnect" );
	self.zombie_dmg_trig endon( "trap_finished_" + self.script_string );
	while ( 1 )
	{
		if ( player istouching( self.rumble_trig ) )
		{
			player setclientfieldtoplayer( "rumble_fan_trap", 1 );
			player.fan_trap_rumble = 1;
			wait 0.25;
		}
		else
		{
			player setclientfieldtoplayer( "rumble_fan_trap", 0 );
			player.fan_trap_rumble = 0;
			break;
		}
	}
}

fan_trap_damage( parent ) //checked partially changed to match cerberus output
{
	if ( isDefined( level.custom_fan_trap_damage_func ) )
	{
		self thread [[ level.custom_fan_trap_damage_func ]]( parent );
		return;
	}
	self endon( "fan_trap_finished" );
	while ( 1 )
	{
		self waittill( "trigger", ent );
		if ( isplayer( ent ) )
		{
			ent thread player_fan_trap_damage();
		}
		else
		{
			if ( is_true( ent.is_brutus ) )
			{
				ent maps/mp/zombies/_zm_ai_brutus::trap_damage_callback( self );
				return;
			}
			if ( !isDefined( ent.marked_for_death ) )
			{
				ent.marked_for_death = 1;
				ent thread zombie_fan_trap_death();
			}
		}
	}
}

fan_trap_move_switch( parent ) //checked matches cerberus output
{
	light_name = "";
	tswitch = getent( "trap_handle_" + parent.script_linkto, "targetname" );
	light_name = parent get_trap_light_name();
	zapper_light_red( light_name );
	tswitch rotatepitch( -180, 0.5 );
	tswitch playsound( "amb_sparks_l_b" );
	tswitch waittill( "rotatedone" );
	self notify( "switch_activated" );
	self waittill( "available" );
	tswitch rotatepitch( 180, 0.5 );
	zapper_light_green( light_name );
}

player_fan_trap_damage() //checked matches cerberus output
{
	self endon( "death" );
	self endon( "disconnect" );
	if ( !self hasperk( "specialty_armorvest" ) || ( self.health - 100 ) < 1 )
	{
		radiusdamage( self.origin, 10, self.health + 100, self.health + 100 );
	}
	else
	{
		self dodamage( 50, self.origin );
	}
}

zombie_fan_trap_death() //checked matches cerberus output
{
	self endon( "death" );
	if ( !isDefined( self.is_brutus ) )
	{
		self.a.gib_ref = random( array( "guts", "right_arm", "left_arm", "head" ) );
		self thread maps/mp/animscripts/zm_death::do_gib();
	}
	self setclientfield( "fan_trap_blood_fx", 1 );
	self thread stop_fan_trap_blood_fx();
	self dodamage( self.health + 1000, self.origin );
}

stop_fan_trap_blood_fx() //checked matches cerberus output
{
	wait 2;
	self setclientfield( "fan_trap_blood_fx", 0 );
}

init_acid_trap_trigs() //checked matches cerberus output
{
	trap_trigs = getentarray( "acid_trap_trigger", "targetname" );
	array_thread( trap_trigs, ::acid_trap_think );
	level thread acid_trap_host_migration_listener();
}

acid_trap_think() //checked changed to match cerberus output
{
	triggers = getentarray( self.targetname, "targetname" );
	self.is_available = 1;
	self.has_been_used = 0;
	self.cost = 1000;
	self.in_use = 0;
	self.zombie_dmg_trig = getent( self.target, "targetname" );
	self.zombie_dmg_trig.in_use = 0;
	light_name = self get_trap_light_name();
	zapper_light_red( light_name );
	self sethintstring( &"ZM_PRISON_ACID_TRAP_UNAVAILABLE" );
	flag_wait_any( "activate_cafeteria", "activate_infirmary" );
	zapper_light_green( light_name );
	self hint_string( &"ZM_PRISON_ACID_TRAP", self.cost );
	while ( 1 )
	{
		self waittill( "trigger", who );
		if ( who in_revive_trigger() )
		{
			continue;
		}
		if ( !isDefined( self.is_available ) )
		{
			continue;
		}
		if ( is_player_valid( who ) )
		{
			if ( who.score >= self.cost )
			{
				if ( !self.zombie_dmg_trig.in_use )
				{
					if ( !self.has_been_used )
					{
						self.has_been_used = 1;
						level thread maps/mp/zombies/_zm_audio::sndmusicstingerevent( "trap" );
						who do_player_general_vox( "general", "discover_trap" );
					}
					else
					{
						who do_player_general_vox( "general", "start_trap" );
					}
					self.zombie_dmg_trig.in_use = 1;
					self.zombie_dmg_trig.active = 1;
					self playsound( "zmb_trap_activate" );
					self thread acid_trap_move_switch( self );
					self waittill( "switch_activated" );
					who minus_to_player_score( self.cost );
					level.trapped_track[ "acid" ] = 1;
					level notify( "trap_activated" );
					who maps/mp/zombies/_zm_stats::increment_client_stat( "prison_acid_trap_used", 0 );
					array_thread( triggers, ::hint_string, &"ZOMBIE_TRAP_ACTIVE" );
					self thread activate_acid_trap();
					self.zombie_dmg_trig waittill( "acid_trap_fx_done" );
					clientnotify( self.script_string + "off" );
					if ( isDefined( self.fx_org ) )
					{
						self.fx_org delete();
					}
					if ( isDefined( self.zapper_fx_org ) )
					{
						self.zapper_fx_org delete();
					}
					if ( isDefined( self.zapper_fx_switch_org ) )
					{
						self.zapper_fx_switch_org delete();
					}
					self.zombie_dmg_trig notify( "acid_trap_finished" );
					self.zombie_dmg_trig.active = 0;
					array_thread( triggers, ::hint_string, &"ZOMBIE_TRAP_COOLDOWN" );
					wait 25;
					self playsound( "zmb_trap_available" );
					self notify( "available" );
					self.zombie_dmg_trig.in_use = 0;
					array_thread( triggers, ::hint_string, &"ZM_PRISON_ACID_TRAP", self.cost );
				}
			}
		}
	}
}

acid_trap_move_switch( parent ) //checked matches cerberus output
{
	light_name = "";
	tswitch = getent( "trap_handle_" + parent.script_linkto, "targetname" );
	light_name = parent get_trap_light_name();
	zapper_light_red( light_name );
	tswitch rotatepitch( -180, 0.5 );
	tswitch playsound( "amb_sparks_l_b" );
	tswitch waittill( "rotatedone" );
	self notify( "switch_activated" );
	self waittill( "available" );
	tswitch rotatepitch( 180, 0.5 );
	zapper_light_green( light_name );
}

activate_acid_trap() //checked changed to match cerberus output
{
	clientnotify( self.target );
	fire_points = getstructarray( self.target, "targetname" );
	for ( i = 0; i < fire_points.size; i++ )
	{
		wait_network_frame();
		fire_points[ i ] thread acid_trap_fx( self );
	}
	self.zombie_dmg_trig thread acid_trap_damage();
}

acid_trap_damage() //checked partially changed to match cerberus output
{
	if ( isDefined( level.custom_acid_trap_damage_func ) )
	{
		self thread [[ level.custom_acid_trap_damage_func ]]();
		return;
	}
	self endon( "acid_trap_finished" );
	while ( 1 )
	{
		self waittill( "trigger", ent );
		if ( isplayer( ent ) )
		{
			ent thread player_acid_damage( self );
		}
		else
		{
			if ( is_true( ent.is_brutus ) )
			{
				ent maps/mp/zombies/_zm_ai_brutus::trap_damage_callback( self );
				return;
			}
			if ( !isDefined( ent.marked_for_death ) )
			{
				ent.marked_for_death = 1;
				ent thread zombie_acid_damage();
			}
		}
	}
}

zombie_acid_damage() //checked matches cerberus output
{
	self endon( "death" );
	self setclientfield( "acid_trap_death_fx", 1 );
	wait randomfloatrange( 0.25, 2 );
	if ( !isDefined( self.is_brutus ) )
	{
		self.a.gib_ref = random( array( "right_arm", "left_arm", "head", "right_leg", "left_leg", "no_legs" ) );
		self thread maps/mp/animscripts/zm_death::do_gib();
	}
	self dodamage( self.health + 1000, self.origin );
}

stop_acid_death_fx() //checked matches cerberus output
{
	wait 3;
	self setclientfield( "acid_trap_death_fx", 0 );
}

player_acid_damage( t_damage ) //checked changed to match cerberus output
{
	self endon( "death" );
	self endon( "disconnect" );
	t_damage endon( "acid_trap_finished" );
	if ( !isDefined( self.is_in_acid ) && !self player_is_in_laststand() )
	{
		self.is_in_acid = 1;
		self thread player_acid_damage_cooldown();
		while ( self istouching( t_damage ) && !self player_is_in_laststand() && !self.afterlife )
		{
			self dodamage( self.maxhealth / 2, self.origin );
			wait 1;
		}
	}
}

player_acid_damage_cooldown() //checked matches cerberus output
{
	self endon( "disconnect" );
	wait 1;
	if ( isDefined( self ) )
	{
		self.is_in_acid = undefined;
	}
}

acid_trap_fx( notify_ent ) //checked matches cerberus output
{
	wait 25;
	notify_ent.zombie_dmg_trig notify( "acid_trap_fx_done" );
}

acid_trap_host_migration_listener() //checked changed to match cerberus output
{
	level endon( "end_game" );
	level notify( "acid_trap_hostmigration" );
	level endon( "acid_trap_hostmigration" );
	while ( 1 )
	{
		level waittill( "host_migration_end" );
		trap_trigs = getentarray( "acid_trap_trigger", "targetname" );
		foreach ( trigger in trap_trigs )
		{
			if ( isDefined( trigger.zombie_dmg_trig ) && isDefined( trigger.zombie_dmg_trig.active ) )
			{
				if ( trigger.zombie_dmg_trig.active == 1 )
				{
					clientnotify( trigger.target );
					break;
				}
			}
		}
	}
}

init_tower_trap_trigs() //checked changed to match cerberus output
{
	trap_trigs = getentarray( "tower_trap_activate_trigger", "targetname" );
	foreach ( trigger in trap_trigs )
	{
		trigger thread tower_trap_trigger_think();
	}
}

tower_trap_trigger_think() //checked changed to match cerberus output
{
	self.range_trigger = getent( self.target, "targetname" );
	self.upgrade_trigger = getent( self.script_string, "script_noteworthy" );
	self.cost = 1000;
	light_name = self get_trap_light_name();
	zapper_light_green( light_name );
	self.is_available = 1;
	self.in_use = 0;
	self.has_been_used = 0;
	self.sndtowerent = spawn( "script_origin", ( -21, 5584, 356 ) );
	while ( 1 )
	{
		self hint_string( &"ZM_PRISON_TOWER_TRAP", self.cost );
		self waittill( "trigger", who );
		if ( who in_revive_trigger() )
		{
			continue;
		}
		if ( !isDefined( self.is_available ) )
		{
			continue;
		}
		if ( is_player_valid( who ) )
		{
			if ( who.score >= self.cost )
			{
				if ( !self.in_use )
				{
					if ( !self.has_been_used )
					{
						self.has_been_used = 1;
						who do_player_general_vox( "general", "discover_trap" );
					}
					else
					{
						who do_player_general_vox( "general", "start_trap" );
					}
					self.in_use = 1;
					self.active = 1;
					play_sound_at_pos( "purchase", who.origin );
					self thread tower_trap_move_switch( self );
					self playsound( "zmb_trap_activate" );
					self waittill( "switch_activated" );
					who minus_to_player_score( self.cost );
					level.trapped_track[ "tower" ] = 1;
					level notify( "trap_activated" );
					who maps/mp/zombies/_zm_stats::increment_client_stat( "prison_sniper_tower_used", 0 );
					self hint_string( &"ZOMBIE_TRAP_ACTIVE" );
					self.sndtowerent playsound( "zmb_trap_tower_start" );
					self.sndtowerent playloopsound( "zmb_trap_tower_loop", 1 );
					self thread activate_tower_trap();
					self thread tower_trap_timer();
					self thread tower_upgrade_trigger_think();
					level thread open_tower_trap_upgrade_panel();
					level thread tower_trap_upgrade_panel_closes_early();
					self waittill( "tower_trap_off" );
					self.sndtowerent stoploopsound( 1 );
					self.sndtowerent playsound( "zmb_trap_tower_end" );
					self.upgrade_trigger notify( "afterlife_interact_reset" );
					self.active = 0;
					self sethintstring( &"ZOMBIE_TRAP_COOLDOWN" );
					zapper_light_red( light_name );
					wait 25;
					self playsound( "zmb_trap_available" );
					self notify( "available" );
					self.in_use = 0;
					self.upgrade_trigger notify( "available" );
					self.upgrade_trigger.in_use = 0;
				}
			}
		}
	}
}

tower_upgrade_trigger_think() //checked matches cerberus output
{
	self endon( "tower_trap_off" );
	self.upgrade_trigger.cost = 1000;
	self.upgrade_trigger.in_use = 0;
	self.upgrade_trigger.is_available = 1;
	while ( 1 )
	{
		level waittill( self.upgrade_trigger.script_string );
		level.trapped_track[ "tower_upgrade" ] = 1;
		level notify( "tower_trap_upgraded" );
		level notify( "close_tower_trap_upgrade_panel" );
		self upgrade_tower_trap_weapon();
		self notify( "tower_trap_reset_timer" );
		self thread tower_trap_timer();
		self waittill( "tower_trap_off" );
		wait 25;
	}
}

open_tower_trap_upgrade_panel() //checked matches cerberus output
{
	e_door = getent( "tower_shockbox_door", "targetname" );
	e_door moveto( e_door.origin + vectorScale( ( 0, 1, 0 ), 40 ), 1 );
	level waittill( "close_tower_trap_upgrade_panel" );
	e_door moveto( e_door.origin + vectorScale( ( 0, 1, 0 ), 40 ), 1 );
}

tower_trap_upgrade_panel_closes_early() //checked matches cerberus output
{
	level endon( "tower_trap_upgraded" );
	n_waittime = 24;
	wait n_waittime;
	level notify( "close_tower_trap_upgrade_panel" );
}

tower_trap_move_switch( parent ) //checked matches cerberus output
{
	light_name = "";
	tswitch = getent( "trap_handle_" + parent.script_linkto, "targetname" );
	light_name = parent get_trap_light_name();
	zapper_light_red( light_name );
	tswitch rotatepitch( -180, 0.5 );
	tswitch playsound( "amb_sparks_l_b" );
	tswitch waittill( "rotatedone" );
	self notify( "switch_activated" );
	self waittill( "available" );
	tswitch rotatepitch( 180, 0.5 );
	if ( isDefined( parent.script_noteworthy ) )
	{
		zapper_light_green( light_name );
	}
}

activate_tower_trap() //checked changed to match cerberus output
{
	self endon( "tower_trap_off" );
	self.weapon_name = "tower_trap_zm";
	self.tag_to_target = "J_Head";
	self.trap_reload_time = 0.75;
	while ( 1 )
	{
		zombies = getaiarray( level.zombie_team );
		zombies_sorted = [];
		foreach(zombie in zombies)
		{
			if ( zombie istouching( self.range_trigger ) )
			{
				zombies_sorted[ zombies_sorted.size ] = zombie;
			}
		}
		if ( zombies_sorted.size <= 0 )
		{
			wait_network_frame();
		}
		else 
		{
			wait_network_frame();
			self tower_trap_fires( zombies_sorted );
		}
	}
}

upgrade_tower_trap_weapon() //checked matches cerberus output
{
	self.weapon_name = "tower_trap_upgraded_zm";
	self.tag_to_target = "J_SpineLower";
	self.trap_reload_time = 1.5;
}

tower_trap_timer() //checked matches cerberus output
{
	self endon( "tower_trap_reset_timer" );
	/*
/#
	self thread debug_tower_trap_timer();
#/
	*/
	wait 25;
	self notify( "tower_trap_off" );
}

debug_tower_trap_timer() //checked changed to match cerberus output
{
	self endon( "tower_trap_reset_timer" );
	for ( i = 1; i <= 25; i++ )
	{
		/*
/#
		iprintln( "Tower Trap Timer = " + i );
#/
		*/
		wait 1;
	}
}

tower_trap_fires( a_zombies ) //checked changed to match cerberus output
{
	if ( isDefined( level.custom_tower_trap_fires_func ) )
	{
		self thread [[ level.custom_tower_trap_fires_func ]]( a_zombies );
		return;
	}
	self endon( "tower_trap_off" );
	e_org = getstruct( self.range_trigger.target, "targetname" );
	n_index = randomintrange( 0, a_zombies.size );
	while ( isalive( a_zombies[ n_index ] ) )
	{
		e_target = a_zombies[ n_index ];
		v_zombietarget = e_target gettagorigin( self.tag_to_target );
		if ( sighttracepassed( e_org.origin, v_zombietarget, 1, undefined ) )
		{
			magicbullet( self.weapon_name, e_org.origin, v_zombietarget );
			wait self.trap_reload_time;
		}
		else
		{
			arrayremovevalue( a_zombies, e_target, 0 );
			wait_network_frame();
			if ( a_zombies.size <= 0 )
			{
				break;
			}
			n_index = randomintrange( 0, a_zombies.size );
		}
	}
}

hint_string( string, cost ) //checked matches cerberus output
{
	if ( isDefined( cost ) )
	{
		self sethintstring( string, cost );
	}
	else
	{
		self sethintstring( string );
	}
	self setcursorhint( "HINT_NOICON" );
}

zapper_light_red( lightname ) //checked changed to match cerberus output
{
	zapper_lights = getentarray( lightname, "targetname" );
	for ( i = 0; i < zapper_lights.size; i++ )
	{
		zapper_lights[ i ] setmodel( "p6_zm_al_wall_trap_control_red" );
	}
}

zapper_light_green( lightname ) //checked changed to match cerberus output
{
	zapper_lights = getentarray( lightname, "targetname" );
	for ( i = 0; i < zapper_lights.size; i++ )
	{
		zapper_lights[ i ] setmodel( "p6_zm_al_wall_trap_control" );
	}
}

get_trap_light_name() //checked matches cerberus output
{
	tswitch = getent( "trap_handle_" + self.script_linkto, "targetname" );
	switch( tswitch.script_linkname )
	{
		case "1":
		case "2":
			light_name = "trap_control_wardens_office";
			break;
		case "3":
		case "4":
		case "5":
			light_name = "trap_control_cafeteria";
			break;
		case "99":
			light_name = "trap_control_docks";
			break;
	}
	return light_name;
}
