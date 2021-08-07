#include maps/mp/zombies/_zm_audio;
#include maps/mp/zombies/_zm_perks;
#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/_visionset_mgr;
#include maps/mp/zm_transit_utility;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

initializepower()
{
	level thread electricswitch();
	level thread powerevent();
	registerclientfield( "toplayer", "power_rumble", 1, 1, "int" );
	if ( !isDefined( level.vsmgr_prio_visionset_zm_transit_power_high_low ) )
	{
		level.vsmgr_prio_visionset_zm_transit_power_high_low = 20;
	}
	maps/mp/_visionset_mgr::vsmgr_register_info( "visionset", "zm_power_high_low", 1, level.vsmgr_prio_visionset_zm_transit_power_high_low, 7, 1, ::vsmgr_lerp_power_up_down, 0 );
}

precache_models()
{
}

elecswitchbuildable()
{
	lever = getent( "powerswitch_p6_zm_buildable_pswitch_lever", "targetname" );
	hand = getent( "powerswitch_p6_zm_buildable_pswitch_hand", "targetname" );
	hand linkto( lever );
	hand hide();
	getent( "powerswitch_p6_zm_buildable_pswitch_body", "targetname" ) hide();
	lever hide();
	wait_for_buildable( "powerswitch" );
}

electricswitch()
{
	flag_init( "switches_on" );
	level thread wait_for_power();
	trig = getent( "powerswitch_buildable_trigger_power", "targetname" );
	trig setinvisibletoall();
	elecswitchbuildable();
	master_switch = getent( "powerswitch_p6_zm_buildable_pswitch_lever", "targetname" );
	while ( 1 )
	{
		trig sethintstring( &"ZOMBIE_ELECTRIC_SWITCH" );
		trig setvisibletoall();
		trig waittill( "trigger", user );
		trig setinvisibletoall();
		master_switch rotateroll( -90, 0,3 );
		master_switch playsound( "zmb_switch_flip" );
		master_switch waittill( "rotatedone" );
		playfx( level._effect[ "switch_sparks" ], getstruct( "elec_switch_fx", "targetname" ).origin );
		master_switch playsound( "zmb_turn_on" );
		level.power_event_in_progress = 1;
		level thread power_event_rumble_and_quake();
		flag_set( "switches_on" );
		clientnotify( "pwr" );
		level thread avogadro_show_vox( user );
		level waittill( "power_event_complete" );
		clientnotify( "pwr" );
		flag_set( "power_on" );
		level.power_event_in_progress = 0;
		level thread bus_station_pa_vox();
		if ( isDefined( user ) )
		{
			user maps/mp/zombies/_zm_stats::increment_client_stat( "power_turnedon", 0 );
			user maps/mp/zombies/_zm_stats::increment_player_stat( "power_turnedon" );
		}
		trig sethintstring( &"ZOMBIE_ELECTRIC_SWITCH_OFF" );
		trig setvisibletoall();
		trig waittill( "trigger", user );
		trig setinvisibletoall();
		master_switch rotateroll( 90, 0,3 );
		master_switch playsound( "zmb_switch_flip" );
		master_switch waittill( "rotatedone" );
		level.power_event_in_progress = 1;
		level thread power_event_rumble_and_quake();
		flag_clear( "switches_on" );
		level waittill( "power_event_complete" );
		clientnotify( "pwo" );
		flag_clear( "power_on" );
		level.power_event_in_progress = 0;
		level.power_cycled = 1;
		if ( isDefined( user ) )
		{
			user maps/mp/zombies/_zm_stats::increment_client_stat( "power_turnedoff", 0 );
			user maps/mp/zombies/_zm_stats::increment_player_stat( "power_turnedoff" );
		}
	}
}

vsmgr_lerp_power_up_down( player, opt_param_1, opt_param_2 )
{
	self vsmgr_set_state_active( player, opt_param_1 );
}

power_event_vision_set_post_event()
{
	self endon( "end_vision_set_power" );
	level endon( "end_game" );
	self endon( "disconnect" );
	if ( flag( "power_on" ) )
	{
		return;
	}
	level waittill( "power_event_complete" );
	maps/mp/_visionset_mgr::vsmgr_activate( "visionset", "zm_power_high_low", self, 0 );
}

power_event_vision_set()
{
	self endon( "end_vision_set_power" );
	level endon( "end_game" );
	level endon( "power_event_complete" );
	self endon( "disconnect" );
	if ( flag( "power_on" ) )
	{
		return;
	}
	duration = 2;
	startgoal = 1;
	endgoal = 0;
	self power_event_vision_set_lerp( duration, startgoal, endgoal );
	while ( 1 )
	{
		if ( randomint( 100 ) > 50 )
		{
			duration = randomintrange( 2, 6 ) / 5;
			startgoal = endgoal;
			if ( startgoal > 0,6 )
			{
				endgoal = randomfloatrange( 0, 0,5 );
			}
			else
			{
				endgoal = 1;
			}
			self power_event_vision_set_lerp( duration, startgoal, endgoal );
		}
		else if ( randomint( 100 ) > 75 )
		{
			x = 2;
			while ( x > 0 )
			{
				duration = 0,2;
				startgoal = endgoal;
				if ( startgoal > 0,6 )
				{
					endgoal = 0;
				}
				else
				{
					endgoal = 1;
				}
				self power_event_vision_set_lerp( duration, startgoal, endgoal );
				x--;

			}
		}
		else duration = 0,4;
		startgoal = endgoal;
		if ( startgoal > 0,6 )
		{
			endgoal = randomfloatrange( 0, 0,5 );
		}
		else
		{
			endgoal = randomfloatrange( 0,5, 1 );
		}
		self power_event_vision_set_lerp( duration, startgoal, endgoal );
		wait 0,05;
	}
}

power_event_vision_set_lerp( duration, startgoal, endgoal )
{
	self endon( "end_vision_set_power" );
	level endon( "end_game" );
	level endon( "power_event_complete" );
	self endon( "disconnect" );
	incs = int( duration / 0,05 );
	if ( incs == 0 )
	{
		incs = 1;
	}
	incsgoal = ( endgoal - startgoal ) / incs;
	currentgoal = startgoal;
	i = 0;
	while ( i < incs )
	{
		currentgoal += incsgoal;
		maps/mp/_visionset_mgr::vsmgr_activate( "visionset", "zm_power_high_low", self, currentgoal );
		wait 0,05;
		i++;
	}
	maps/mp/_visionset_mgr::vsmgr_activate( "visionset", "zm_power_high_low", self, endgoal );
}

power_event_rumble_and_quake( power_on )
{
	level endon( "end_game" );
	while ( isDefined( level.power_event_in_progress ) && level.power_event_in_progress )
	{
		players = get_players();
		_a284 = players;
		_k284 = getFirstArrayKey( _a284 );
		while ( isDefined( _k284 ) )
		{
			player = _a284[ _k284 ];
			if ( !is_player_valid( player ) )
			{
			}
			else if ( player maps/mp/zombies/_zm_zonemgr::entity_in_zone( "zone_prr", 1 ) || player maps/mp/zombies/_zm_zonemgr::entity_in_zone( "zone_pcr", 1 ) )
			{
				if ( isDefined( player.power_rumble_active ) && !player.power_rumble_active )
				{
					player thread power_event_rumble_and_quake_player();
				}
			}
			else
			{
				if ( isDefined( player.power_rumble_active ) && player.power_rumble_active )
				{
					player setclientfieldtoplayer( "power_rumble", 0 );
					player.power_rumble_active = 0;
				}
			}
			_k284 = getNextArrayKey( _a284, _k284 );
		}
		wait 1;
	}
	players = get_players();
	_a311 = players;
	_k311 = getFirstArrayKey( _a311 );
	while ( isDefined( _k311 ) )
	{
		player = _a311[ _k311 ];
		player setclientfieldtoplayer( "power_rumble", 0 );
		player notify( "end_vision_set_power" );
		maps/mp/_visionset_mgr::vsmgr_deactivate( "visionset", "zm_power_high_low", player );
		_k311 = getNextArrayKey( _a311, _k311 );
	}
}

power_event_rumble_and_quake_player()
{
	self endon( "disconnect" );
	self.power_rumble_active = 1;
	self setclientfieldtoplayer( "power_rumble", 1 );
	self thread power_event_vision_set();
	self thread power_event_vision_set_post_event();
	while ( !self maps/mp/zombies/_zm_zonemgr::entity_in_zone( "zone_prr", 1 ) && self maps/mp/zombies/_zm_zonemgr::entity_in_zone( "zone_pcr", 1 ) && isDefined( level.power_event_in_progress ) && level.power_event_in_progress )
	{
		wait 1;
	}
	self.power_rumble_active = 0;
	self notify( "end_vision_set_power" );
	self setclientfieldtoplayer( "power_rumble", 0 );
}

avogadroreleasefromchamberevent()
{
	exploder( 500 );
	level.zones[ "zone_prr" ].is_spawning_allowed = 0;
	level.zones[ "zone_pcr" ].is_spawning_allowed = 0;
	level thread killzombiesinpowerstation();
	while ( !flag( "power_on" ) )
	{
		waittime = randomfloatrange( 1,5, 4,5 );
		players = get_players();
		_a354 = players;
		_k354 = getFirstArrayKey( _a354 );
		while ( isDefined( _k354 ) )
		{
			player = _a354[ _k354 ];
			if ( player maps/mp/zombies/_zm_zonemgr::entity_in_zone( "zone_prr", 1 ) )
			{
				player setelectrified( waittime - 1 );
				player shellshock( "electrocution", waittime );
				wait 0,05;
			}
			_k354 = getNextArrayKey( _a354, _k354 );
		}
		waittime += 1,5;
		level waittill_notify_or_timeout( "power_on", waittime );
	}
	players = get_players();
	_a372 = players;
	_k372 = getFirstArrayKey( _a372 );
	while ( isDefined( _k372 ) )
	{
		player = _a372[ _k372 ];
		if ( player maps/mp/zombies/_zm_zonemgr::entity_in_zone( "zone_prr", 1 ) )
		{
			player setelectrified( 0,25 );
			player shellshock( "electrocution", 1,5 );
			wait 0,05;
		}
		_k372 = getNextArrayKey( _a372, _k372 );
	}
	level.zones[ "zone_prr" ].is_spawning_allowed = 1;
	level.zones[ "zone_pcr" ].is_spawning_allowed = 1;
	stop_exploder( 500 );
}

killzombiesinpowerstation()
{
	level endon( "power_on" );
	radiussq = 122500;
	while ( 1 )
	{
		zombies = getaiarray( level.zombie_team );
		_a401 = zombies;
		_k401 = getFirstArrayKey( _a401 );
		while ( isDefined( _k401 ) )
		{
			zombie = _a401[ _k401 ];
			if ( !isDefined( zombie ) )
			{
			}
			else if ( isDefined( zombie.is_avogadro ) && zombie.is_avogadro )
			{
			}
			else
			{
				if ( distancesquared( ( 11344, 7590, -729 ), zombie.origin ) < radiussq )
				{
					break;
				}
				else
				{
					if ( isDefined( zombie ) || zombie maps/mp/zombies/_zm_zonemgr::entity_in_zone( "zone_prr", 1 ) && isDefined( zombie.zone_name ) && zombie.zone_name == "zone_prr" )
					{
						if ( isDefined( zombie.has_been_damaged_by_player ) && !zombie.has_been_damaged_by_player )
						{
							level.zombie_total++;
						}
						zombie dodamage( zombie.health + 100, zombie.origin );
						wait randomfloatrange( 0,05, 0,15 );
					}
				}
			}
			_k401 = getNextArrayKey( _a401, _k401 );
		}
		wait 1;
	}
}

wait_for_power()
{
	while ( 1 )
	{
		flag_wait( "power_on" );
		maps/mp/zombies/_zm_perks::perk_unpause_all_perks();
		wait_network_frame();
		level setclientfield( "zombie_power_on", 1 );
		enable_morse_code();
		raisepowerplantgates();
		flag_waitopen( "power_on" );
		level setclientfield( "zombie_power_on", 0 );
		disable_morse_code();
	}
}

raisepowerplantgates()
{
	gate1 = [];
	gate2 = [];
	gate1 = getentarray( "security_booth_gate", "targetname" );
	gate2 = getentarray( "security_booth_gate_2", "targetname" );
	while ( isDefined( gate1 ) )
	{
		i = 0;
		while ( i < gate1.size )
		{
			gate1[ i ] thread raisegate( -90 );
			i++;
		}
	}
	while ( isDefined( gate2 ) )
	{
		i = 0;
		while ( i < gate2.size )
		{
			gate2[ i ] thread raisegate( 90 );
			i++;
		}
	}
	level.the_bus notify( "OnPowerOn" );
}

raisegate( degrees )
{
	self rotatepitch( degrees, 4 );
}

powerevent()
{
	reactor_core_mover = getent( "core_mover", "targetname" );
	reactor_core_audio = spawn( "script_origin", reactor_core_mover.origin );
	if ( !isDefined( reactor_core_mover ) )
	{
		return;
	}
	thread blockstairs();
	thread linkentitiestocoremover( reactor_core_mover );
	while ( 1 )
	{
		flag_wait( "switches_on" );
		thread dropreactordoors();
		thread raisereactordoors();
		power_event_time = 30;
		reactor_core_mover playsound( "zmb_power_rise_start" );
		reactor_core_mover playloopsound( "zmb_power_rise_loop", 0,75 );
		reactor_core_mover thread coremove( power_event_time );
		if ( isDefined( level.avogadro ) && isDefined( level.avogadro.state ) && level.avogadro.state == "chamber" )
		{
			level thread avogadroreleasefromchamberevent();
		}
		wait power_event_time;
		reactor_core_mover stoploopsound( 0,5 );
		reactor_core_audio playloopsound( "zmb_power_on_loop", 2 );
		reactor_core_mover playsound( "zmb_power_rise_stop" );
		level notify( "power_event_complete" );
		flag_waitopen( "switches_on" );
		thread dropreactordoors();
		thread raisereactordoors();
		playsoundatposition( "zmb_power_off_quad", ( 0, 0, 0 ) );
		reactor_core_mover playsound( "zmb_power_rise_start" );
		reactor_core_mover playloopsound( "zmb_power_rise_loop", 0,75 );
		reactor_core_mover thread coremove( power_event_time, 1 );
		wait power_event_time;
		reactor_core_mover stoploopsound( 0,5 );
		reactor_core_audio stoploopsound( 0,5 );
		reactor_core_mover playsound( "zmb_power_rise_stop" );
		level notify( "power_event_complete" );
	}
}

corerotate( time )
{
	self rotateyaw( 180, time );
}

coremove( time, down )
{
	if ( isDefined( down ) && down )
	{
		self movez( -160, time );
	}
	else
	{
		self movez( 160, time );
	}
}

blockstairs()
{
	stairs_blocker = getent( "reactor_core_stairs_blocker", "targetname" );
	if ( !isDefined( stairs_blocker ) )
	{
		return;
	}
	stairs_blocker movez( -128, 1 );
}

linkentitiestocoremover( reactor_core_mover )
{
	core_entities = getentarray( "core_entity", "script_noteworthy" );
	i = 0;
	while ( i < core_entities.size )
	{
		next_ent = core_entities[ i ];
		if ( next_ent.classname == "trigger_use_touch" )
		{
			next_ent enablelinkto();
		}
		next_ent linkto( reactor_core_mover, "tag_origin" );
		i++;
	}
}

dropreactordoors()
{
	doors = getentarray( "reactor_core_door", "targetname" );
	if ( doors.size == 0 )
	{
		return;
	}
	i = 0;
	while ( i < doors.size )
	{
		next_door = doors[ i ];
		next_door movez( -128, 1 );
		next_door disconnectpaths();
		i++;
	}
}

raisereactordoors()
{
	level waittill( "power_event_complete" );
	doors = getentarray( "reactor_core_door", "targetname" );
	if ( doors.size == 0 )
	{
		return;
	}
	i = 0;
	while ( i < doors.size )
	{
		next_door = doors[ i ];
		next_door movez( 128, 1 );
		next_door connectpaths();
		i++;
	}
}

avogadro_show_vox( user )
{
	wait 1;
	if ( isDefined( user ) )
	{
		user thread maps/mp/zombies/_zm_audio::create_and_play_dialog( "power", "power_on" );
	}
	wait 8;
	players = get_players();
	players = array_randomize( players );
	_a655 = players;
	_k655 = getFirstArrayKey( _a655 );
	while ( isDefined( _k655 ) )
	{
		player = _a655[ _k655 ];
		if ( player maps/mp/zombies/_zm_zonemgr::entity_in_zone( "zone_prr", 1 ) || player maps/mp/zombies/_zm_zonemgr::entity_in_zone( "zone_pcr", 1 ) )
		{
			player thread maps/mp/zombies/_zm_audio::create_and_play_dialog( "power", "power_core" );
			break;
		}
		else
		{
			_k655 = getNextArrayKey( _a655, _k655 );
		}
	}
	wait 15;
	players = get_players();
	players = array_randomize( players );
	_a668 = players;
	_k668 = getFirstArrayKey( _a668 );
	while ( isDefined( _k668 ) )
	{
		player = _a668[ _k668 ];
		if ( player maps/mp/zombies/_zm_zonemgr::entity_in_zone( "zone_prr", 1 ) || player maps/mp/zombies/_zm_zonemgr::entity_in_zone( "zone_pcr", 1 ) )
		{
			player thread maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "avogadro_reveal" );
			return;
		}
		else
		{
			_k668 = getNextArrayKey( _a668, _k668 );
		}
	}
}

bus_station_pa_vox()
{
	level endon( "power_off" );
	while ( 1 )
	{
		level.station_pa_vox = array_randomize( level.station_pa_vox );
		_a686 = level.station_pa_vox;
		_k686 = getFirstArrayKey( _a686 );
		while ( isDefined( _k686 ) )
		{
			line = _a686[ _k686 ];
			playsoundatposition( line, ( -6848, 5056, 56 ) );
			wait randomintrange( 12, 15 );
			_k686 = getNextArrayKey( _a686, _k686 );
		}
		wait 1;
	}
}
