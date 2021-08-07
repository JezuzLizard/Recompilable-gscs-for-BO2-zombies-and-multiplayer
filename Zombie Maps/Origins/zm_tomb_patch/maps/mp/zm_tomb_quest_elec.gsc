#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/zm_tomb_chamber;
#include maps/mp/zm_tomb_vo;
#include maps/mp/zombies/_zm_net;
#include maps/mp/zm_tomb_utility;
#include maps/mp/zombies/_zm_sidequests;
#include maps/mp/zombies/_zm_craftables;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

main()
{
	onplayerconnect_callback( ::onplayerconnect );
	flag_init( "electric_puzzle_1_complete" );
	flag_init( "electric_puzzle_2_complete" );
	flag_init( "electric_upgrade_available" );
	maps/mp/zm_tomb_vo::add_puzzle_completion_line( 3, "vox_sam_lightning_puz_solve_0" );
	maps/mp/zm_tomb_vo::add_puzzle_completion_line( 3, "vox_sam_lightning_puz_solve_1" );
	maps/mp/zm_tomb_vo::add_puzzle_completion_line( 3, "vox_sam_lightning_puz_solve_2" );
	level thread maps/mp/zm_tomb_vo::watch_one_shot_line( "puzzle", "try_puzzle", "vo_try_puzzle_lightning1" );
	level thread maps/mp/zm_tomb_vo::watch_one_shot_line( "puzzle", "try_puzzle", "vo_try_puzzle_lightning2" );
	electric_puzzle_1_init();
	electric_puzzle_2_init();
	level thread electric_puzzle_1_run();
	flag_wait( "electric_puzzle_1_complete" );
	playsoundatposition( "zmb_squest_step1_finished", ( 0, 0, -1 ) );
	level thread rumble_players_in_chamber( 5, 3 );
	level thread electric_puzzle_2_run();
	flag_wait( "electric_puzzle_2_complete" );
	level thread electric_puzzle_2_cleanup();
}

onplayerconnect()
{
	self thread electric_puzzle_watch_staff();
}

electric_puzzle_watch_staff()
{
	self endon( "disconnect" );
	a_piano_keys = getstructarray( "piano_key", "script_noteworthy" );
	while ( 1 )
	{
		self waittill( "projectile_impact", str_weap_name, v_explode_point, n_radius, e_projectile, n_impact );
		while ( str_weap_name == "staff_lightning_zm" )
		{
			while ( !flag( "electric_puzzle_1_complete" ) && maps/mp/zm_tomb_chamber::is_chamber_occupied() )
			{
				n_index = get_closest_index( v_explode_point, a_piano_keys, 20 );
				while ( isDefined( n_index ) )
				{
					a_piano_keys[ n_index ] notify( "piano_key_shot" );
					a_players = getplayers();
					_a77 = a_players;
					_k77 = getFirstArrayKey( _a77 );
					while ( isDefined( _k77 ) )
					{
						e_player = _a77[ _k77 ];
						if ( e_player hasweapon( "staff_lightning_zm" ) )
						{
							level notify( "vo_try_puzzle_lightning1" );
						}
						_k77 = getNextArrayKey( _a77, _k77 );
					}
				}
			}
		}
	}
}

electric_puzzle_1_init()
{
	flag_init( "piano_chord_ringing" );
}

electric_puzzle_1_run()
{
	a_piano_keys = getstructarray( "piano_key", "script_noteworthy" );
	level.a_piano_keys_playing = [];
	array_thread( a_piano_keys, ::piano_key_run );
	level thread piano_run_chords();
}

piano_keys_stop()
{
	level notify( "piano_keys_stop" );
	level.a_piano_keys_playing = [];
}

show_chord_debug( a_chord_notes )
{
/#
	if ( !isDefined( a_chord_notes ) )
	{
		a_chord_notes = [];
	}
	a_piano_keys = getstructarray( "piano_key", "script_noteworthy" );
	_a129 = a_piano_keys;
	_k129 = getFirstArrayKey( _a129 );
	while ( isDefined( _k129 ) )
	{
		e_key = _a129[ _k129 ];
		e_key notify( "stop_debug_position" );
		_a132 = a_chord_notes;
		_k132 = getFirstArrayKey( _a132 );
		while ( isDefined( _k132 ) )
		{
			note = _a132[ _k132 ];
			if ( note == e_key.script_string )
			{
				e_key thread puzzle_debug_position();
				break;
			}
			else
			{
				_k132 = getNextArrayKey( _a132, _k132 );
			}
		}
		_k129 = getNextArrayKey( _a129, _k129 );
#/
	}
}

piano_run_chords()
{
	a_chords = getstructarray( "piano_chord", "targetname" );
	_a147 = a_chords;
	_k147 = getFirstArrayKey( _a147 );
	while ( isDefined( _k147 ) )
	{
		s_chord = _a147[ _k147 ];
		s_chord.notes = strtok( s_chord.script_string, " " );
/#
		assert( s_chord.notes.size == 3 );
#/
		_k147 = getNextArrayKey( _a147, _k147 );
	}
	a_chord_order = array( "a_minor", "e_minor", "d_minor" );
	_a154 = a_chord_order;
	_k154 = getFirstArrayKey( _a154 );
	while ( isDefined( _k154 ) )
	{
		chord_name = _a154[ _k154 ];
		s_chord = getstruct( "piano_chord_" + chord_name, "script_noteworthy" );
/#
		show_chord_debug( s_chord.notes );
#/
		chord_solved = 0;
		while ( !chord_solved )
		{
			level waittill( "piano_key_played" );
			while ( level.a_piano_keys_playing.size == 3 )
			{
				correct_notes_playing = 0;
				_a169 = level.a_piano_keys_playing;
				_k169 = getFirstArrayKey( _a169 );
				while ( isDefined( _k169 ) )
				{
					played_note = _a169[ _k169 ];
					_a171 = s_chord.notes;
					_k171 = getFirstArrayKey( _a171 );
					while ( isDefined( _k171 ) )
					{
						requested_note = _a171[ _k171 ];
						if ( requested_note == played_note )
						{
							correct_notes_playing++;
						}
						_k171 = getNextArrayKey( _a171, _k171 );
					}
					_k169 = getNextArrayKey( _a169, _k169 );
				}
				if ( correct_notes_playing == 3 )
				{
					chord_solved = 1;
					break;
				}
				else
				{
					a_players = getplayers();
					_a185 = a_players;
					_k185 = getFirstArrayKey( _a185 );
					while ( isDefined( _k185 ) )
					{
						e_player = _a185[ _k185 ];
						if ( e_player hasweapon( "staff_lightning_zm" ) )
						{
							level notify( "vo_puzzle_bad" );
						}
						_k185 = getNextArrayKey( _a185, _k185 );
					}
				}
			}
		}
		a_players = getplayers();
		_a197 = a_players;
		_k197 = getFirstArrayKey( _a197 );
		while ( isDefined( _k197 ) )
		{
			e_player = _a197[ _k197 ];
			if ( e_player hasweapon( "staff_lightning_zm" ) )
			{
				level notify( "vo_puzzle_good" );
			}
			_k197 = getNextArrayKey( _a197, _k197 );
		}
		flag_set( "piano_chord_ringing" );
		rumble_nearby_players( a_chords[ 0 ].origin, 1500, 2 );
		wait 4;
		flag_clear( "piano_chord_ringing" );
		piano_keys_stop();
/#
		show_chord_debug();
#/
		_k154 = getNextArrayKey( _a154, _k154 );
	}
	e_player = get_closest_player( a_chords[ 0 ].origin );
	e_player thread maps/mp/zm_tomb_vo::say_puzzle_completion_line( 3 );
	flag_set( "electric_puzzle_1_complete" );
}

piano_key_run()
{
	piano_key_note = self.script_string;
	while ( 1 )
	{
		self waittill( "piano_key_shot" );
		if ( !flag( "piano_chord_ringing" ) )
		{
			if ( level.a_piano_keys_playing.size >= 3 )
			{
				piano_keys_stop();
			}
			self.e_fx = spawn( "script_model", self.origin );
			self.e_fx playloopsound( "zmb_kbd_" + piano_key_note );
			self.e_fx.angles = self.angles;
			self.e_fx setmodel( "tag_origin" );
			playfxontag( level._effect[ "elec_piano_glow" ], self.e_fx, "tag_origin" );
			level.a_piano_keys_playing[ level.a_piano_keys_playing.size ] = piano_key_note;
			level notify( "piano_key_played" );
			level waittill( "piano_keys_stop" );
			self.e_fx delete();
		}
	}
}

electric_puzzle_2_init()
{
	level.electric_relays = [];
	level.electric_relays[ "bunker" ] = spawnstruct();
	level.electric_relays[ "tank_platform" ] = spawnstruct();
	level.electric_relays[ "start" ] = spawnstruct();
	level.electric_relays[ "elec" ] = spawnstruct();
	level.electric_relays[ "ruins" ] = spawnstruct();
	level.electric_relays[ "air" ] = spawnstruct();
	level.electric_relays[ "ice" ] = spawnstruct();
	level.electric_relays[ "village" ] = spawnstruct();
	_a273 = level.electric_relays;
	_k273 = getFirstArrayKey( _a273 );
	while ( isDefined( _k273 ) )
	{
		s_relay = _a273[ _k273 ];
		s_relay.connections = [];
		_k273 = getNextArrayKey( _a273, _k273 );
	}
	level.electric_relays[ "tank_platform" ].connections[ 0 ] = "ruins";
	level.electric_relays[ "start" ].connections[ 1 ] = "tank_platform";
	level.electric_relays[ "elec" ].connections[ 0 ] = "ice";
	level.electric_relays[ "ruins" ].connections[ 2 ] = "chamber";
	level.electric_relays[ "air" ].connections[ 2 ] = "start";
	level.electric_relays[ "ice" ].connections[ 3 ] = "village";
	level.electric_relays[ "village" ].connections[ 2 ] = "air";
	level.electric_relays[ "bunker" ].position = 2;
	level.electric_relays[ "tank_platform" ].position = 1;
	level.electric_relays[ "start" ].position = 3;
	level.electric_relays[ "elec" ].position = 1;
	level.electric_relays[ "ruins" ].position = 3;
	level.electric_relays[ "air" ].position = 0;
	level.electric_relays[ "ice" ].position = 1;
	level.electric_relays[ "village" ].position = 1;
	a_switches = getentarray( "puzzle_relay_switch", "script_noteworthy" );
	_a303 = a_switches;
	_k303 = getFirstArrayKey( _a303 );
	while ( isDefined( _k303 ) )
	{
		e_switch = _a303[ _k303 ];
		level.electric_relays[ e_switch.script_string ].e_switch = e_switch;
		_k303 = getNextArrayKey( _a303, _k303 );
	}
	array_thread( level.electric_relays, ::relay_switch_run );
}

electric_puzzle_2_run()
{
	update_relays();
}

electric_puzzle_2_cleanup()
{
	_a320 = level.electric_relays;
	_k320 = getFirstArrayKey( _a320 );
	while ( isDefined( _k320 ) )
	{
		s_relay = _a320[ _k320 ];
		if ( isDefined( s_relay.trigger_stub ) )
		{
			maps/mp/zombies/_zm_unitrigger::register_unitrigger( s_relay.trigger_stub );
		}
		if ( isDefined( s_relay.e_switch ) )
		{
			s_relay.e_switch stoploopsound( 0,5 );
		}
		if ( isDefined( s_relay.e_fx ) )
		{
			s_relay.e_fx delete();
		}
		_k320 = getNextArrayKey( _a320, _k320 );
	}
}

kill_all_relay_power()
{
	_a341 = level.electric_relays;
	_k341 = getFirstArrayKey( _a341 );
	while ( isDefined( _k341 ) )
	{
		s_relay = _a341[ _k341 ];
		s_relay.receiving_power = 0;
		s_relay.sending_power = 0;
		_k341 = getNextArrayKey( _a341, _k341 );
	}
}

relay_give_power( s_relay )
{
	if ( !flag( "electric_puzzle_1_complete" ) )
	{
		return;
	}
	if ( !isDefined( s_relay ) )
	{
		kill_all_relay_power();
		s_relay = level.electric_relays[ "elec" ];
	}
	s_relay.receiving_power = 1;
	str_target_relay = s_relay.connections[ s_relay.position ];
	if ( isDefined( str_target_relay ) )
	{
		if ( str_target_relay == "chamber" )
		{
			s_relay.e_switch thread maps/mp/zm_tomb_vo::say_puzzle_completion_line( 3 );
			level thread play_puzzle_stinger_on_all_players();
			flag_set( "electric_puzzle_2_complete" );
			return;
		}
		else
		{
			s_relay.sending_power = 1;
			s_target_relay = level.electric_relays[ str_target_relay ];
			relay_give_power( s_target_relay );
		}
	}
}

update_relay_fx_and_sound()
{
	if ( !flag( "electric_puzzle_1_complete" ) )
	{
		return;
	}
	_a398 = level.electric_relays;
	_k398 = getFirstArrayKey( _a398 );
	while ( isDefined( _k398 ) )
	{
		s_relay = _a398[ _k398 ];
		if ( s_relay.sending_power )
		{
			if ( isDefined( s_relay.e_fx ) )
			{
				s_relay.e_fx delete();
			}
			s_relay.e_switch playloopsound( "zmb_squest_elec_switch_hum", 1 );
		}
		else if ( s_relay.receiving_power )
		{
			if ( !isDefined( s_relay.e_fx ) )
			{
				v_offset = anglesToRight( s_relay.e_switch.angles ) * 1;
				s_relay.e_fx = spawn( "script_model", s_relay.e_switch.origin + v_offset );
				s_relay.e_fx.angles = s_relay.e_switch.angles + vectorScale( ( 0, 0, -1 ), 90 );
				s_relay.e_fx setmodel( "tag_origin" );
				playfxontag( level._effect[ "fx_tomb_sparks" ], s_relay.e_fx, "tag_origin" );
			}
			s_relay.e_switch playloopsound( "zmb_squest_elec_switch_spark", 1 );
		}
		else
		{
			if ( isDefined( s_relay.e_fx ) )
			{
				s_relay.e_fx delete();
			}
			s_relay.e_switch stoploopsound( 1 );
		}
		_k398 = getNextArrayKey( _a398, _k398 );
	}
}

update_relay_rotation()
{
	self.e_switch rotateto( ( self.position * 90, self.e_switch.angles[ 1 ], self.e_switch.angles[ 2 ] ), 0,1, 0, 0 );
	self.e_switch playsound( "zmb_squest_elec_switch" );
	self.e_switch waittill( "rotatedone" );
}

update_relays()
{
	relay_give_power();
	update_relay_fx_and_sound();
}

relay_switch_run()
{
/#
	assert( isDefined( self.e_switch ) );
#/
	self.trigger_stub = spawnstruct();
	self.trigger_stub.origin = self.e_switch.origin;
	self.trigger_stub.radius = 50;
	self.trigger_stub.cursor_hint = "HINT_NOICON";
	self.trigger_stub.hint_string = "";
	self.trigger_stub.script_unitrigger_type = "unitrigger_radius_use";
	self.trigger_stub.require_look_at = 1;
	maps/mp/zombies/_zm_unitrigger::register_unitrigger( self.trigger_stub, ::relay_unitrigger_think );
	level endon( "electric_puzzle_2_complete" );
	self thread update_relay_rotation();
	n_tries = 0;
	while ( 1 )
	{
		self.trigger_stub waittill( "trigger", e_user );
		n_tries++;
		level notify( "vo_try_puzzle_lightning2" );
		self.position = ( self.position + 1 ) % 4;
		str_target_relay = self.connections[ self.position ];
		if ( isDefined( str_target_relay ) )
		{
			if ( str_target_relay == "village" || str_target_relay == "ruins" )
			{
				level notify( "vo_puzzle_good" );
			}
		}
		else if ( ( n_tries % 8 ) == 0 )
		{
			level notify( "vo_puzzle_confused" );
		}
		else
		{
			if ( ( n_tries % 4 ) == 0 )
			{
				level notify( "vo_puzzle_bad" );
			}
		}
		self update_relay_rotation();
		update_relays();
	}
}

relay_unitrigger_think()
{
	self endon( "kill_trigger" );
	while ( 1 )
	{
		self waittill( "trigger", player );
		self.stub notify( "trigger" );
	}
}
