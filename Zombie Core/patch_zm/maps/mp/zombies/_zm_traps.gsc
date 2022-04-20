#include maps/mp/zombies/_zm_weapons;
#include maps/mp/animscripts/zm_death;
#include maps/mp/zombies/_zm_laststand;
#include maps/mp/_visionset_mgr;
#include maps/mp/zombies/_zm_net;
#include maps/mp/zombies/_zm_score;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init() //checked matches cerberus output
{
	level.trap_kills = 0;
	traps = getentarray( "zombie_trap", "targetname" );
	array_thread( traps, ::trap_init );
	level thread register_visionsets( traps );
	level.burning_zombies = [];
	level.elec_trap_time = 40;
	level.elec_trap_cooldown_time = 60;
}

trap_init() //checked partially changed to match cerberus output //did not change for loop to while loop to prevent infinite loop bug caused by continue in a for loop
{
	self ent_flag_init( "flag_active" );
	self ent_flag_init( "flag_cooldown" );
	self._trap_type = "";
	if ( isDefined( self.script_noteworthy ) )
	{
		self._trap_type = self.script_noteworthy;
		if ( isDefined( level._zombiemode_trap_activate_funcs ) && isDefined( level._zombiemode_trap_activate_funcs[ self._trap_type ] ) )
		{
			self._trap_activate_func = level._zombiemode_trap_activate_funcs[ self._trap_type ];
		}
		switch( self.script_noteworthy )
		{
			case "rotating":
				self._trap_activate_func = ::trap_activate_rotating;
				break;
			case "electric":
				self._trap_activate_func = ::trap_activate_electric;
				break;
			case "flipper":
				self._trap_activate_func = ::trap_activate_flipper;
				break;
			case "fire":
			default:
				self._trap_activate_func = ::trap_activate_fire;
		}
		if ( isDefined( level._zombiemode_trap_use_funcs ) && isDefined( level._zombiemode_trap_use_funcs[ self._trap_type ] ) )
		{
			self._trap_use_func = level._zombiemode_trap_use_funcs[ self._trap_type ];
		}
		else
		{
			self._trap_use_func = ::trap_use_think;
		}
	}
	self trap_model_type_init();
	self._trap_use_trigs = [];
	self._trap_lights = [];
	self._trap_movers = [];
	self._trap_switches = [];
	components = getentarray( self.target, "targetname" );
	for ( i = 0; i < components.size; i++ )
	{
		if ( isDefined( components[ i ].script_noteworthy ) )
		{
			switch( components[ i ].script_noteworthy )
			{
				case "counter_1s":
					self.counter_1s = components[ i ];
					break;
				case "counter_10s":
					self.counter_10s = components[ i ];
					break;
				case "counter_100s":
					self.counter_100s = components[ i ];
					break;
				case "mover":
					self._trap_movers[ self._trap_movers.size ] = components[ i ];
					break;
				case "switch":
					self._trap_switches[ self._trap_switches.size ] = components[ i ];
					break;
				case "light":
					self._trap_lightes[ self._trap_lightes.size ] = components[ i ];
					break;
			}
		}
		if ( isDefined( components[ i ].script_string ) )
		{
			switch( components[ i ].script_string )
			{
				case "flipper1":
					self.flipper1 = components[ i ];
					break;
				case "flipper2":
					self.flipper2 = components[ i ];
					break;
				case "flipper1_radius_check":
					self.flipper1_radius_check = components[ i ];
					break;
				case "flipper2_radius_check":
					self.flipper2_radius_check = components[ i ];
					break;
				case "target1":
					self.target1 = components[ i ];
					break;
				case "target2":
					self.target2 = components[ i ];
					break;
				case "target3":
					self.target3 = components[ i ];
					break;
			}
		}
		switch( components[ i ].classname )
		{
			case "trigger_use":
				self._trap_use_trigs[ self._trap_use_trigs.size ] = components[ i ];
				break;
			case "script_model":
				if ( components[ i ].model == self._trap_light_model_off )
				{
					self._trap_lights[ self._trap_lights.size ] = components[ i ];
				}
				else if ( components[ i ].model == self._trap_switch_model )
				{
					self._trap_switches[ self._trap_switches.size ] = components[ i ];
				}
		}
	}
	self._trap_fx_structs = [];
	components = getstructarray( self.target, "targetname" );
	i = 0;
	while ( i < components.size )
	{
		if ( isDefined( components[ i ].script_string ) && components[ i ].script_string == "use_this_angle" )
		{
			self.use_this_angle = components[ i ];
			i++;
			continue;
		}
		self._trap_fx_structs[ self._trap_fx_structs.size ] = components[ i ];
		i++;
	}
	/*
	/#
	assert( self._trap_use_trigs.size > 0, "_zm_traps::init no use triggers found for " + self.target );
	#/
	*/
	if ( !isDefined( self.zombie_cost ) )
	{
		self.zombie_cost = 1000;
	}
	self._trap_in_use = 0;
	self._trap_cooling_down = 0;
	self thread trap_dialog();
	flag_wait( "start_zombie_round_logic" );
	self trap_lights_red();
	for ( i = 0; i < self._trap_use_trigs.size; i++ )
	{
		self._trap_use_trigs[ i ] setcursorhint( "HINT_NOICON" );
	}
	if ( !isDefined( self.script_flag_wait ) )
	{
		self trap_set_string( &"ZOMBIE_NEED_POWER" );
		flag_wait( "power_on" );
	}
	else if ( !isDefined( level.flag[ self.script_flag_wait ] ) )
	{
		flag_init( self.script_flag_wait );
	}
	flag_wait( self.script_flag_wait );
	self trap_set_string( &"ZOMBIE_BUTTON_BUY_TRAP", self.zombie_cost );
	self trap_lights_green();
	for ( i = 0; i < self._trap_use_trigs.size; i++ )
	{
		self._trap_use_trigs[ i ] thread [[ self._trap_use_func ]]( self );
	}
}

trap_use_think( trap ) //checked changed to match cerberus output
{
	while ( 1 )
	{
		self waittill( "trigger", who );
		if ( who in_revive_trigger() )
		{
			continue;
		}
		if ( is_player_valid( who ) && !trap._trap_in_use )
		{
			if ( who.score >= trap.zombie_cost )
			{
				who maps/mp/zombies/_zm_score::minus_to_player_score( trap.zombie_cost );
			}
			else
			{
				continue;
			}
			trap._trap_in_use = 1;
			trap trap_set_string( &"ZOMBIE_TRAP_ACTIVE" );
			play_sound_at_pos( "purchase", who.origin );
			if ( trap._trap_switches.size )
			{
				trap thread trap_move_switches();
				trap waittill( "switch_activated" );
			}
			trap trigger_on();
			trap thread [[ trap._trap_activate_func ]]();
			trap waittill( "trap_done" );
			trap trigger_off();
			trap._trap_cooling_down = 1;
			trap trap_set_string( &"ZOMBIE_TRAP_COOLDOWN" );
			/*
	/#
			if ( getDvarInt( "zombie_cheat" ) >= 1 )
			{
				trap._trap_cooldown_time = 5;
	#/
			}
			*/
			wait trap._trap_cooldown_time;
			trap._trap_cooling_down = 0;
			trap notify( "available" );
			trap._trap_in_use = 0;
			trap trap_set_string( &"ZOMBIE_BUTTON_BUY_TRAP", trap.zombie_cost );
		}
	}
}

trap_lights_red() //checked changed to match cerberus output
{
	for ( i = 0; i < self._trap_lights.size; i++ )
	{
		light = self._trap_lights[ i ];
		light setmodel( self._trap_light_model_red );
		if ( isDefined( light.fx ) )
		{
			light.fx delete();
		}
		light.fx = maps/mp/zombies/_zm_net::network_safe_spawn( "trap_lights_red", 2, "script_model", light.origin );
		light.fx setmodel( "tag_origin" );
		light.fx.angles = light.angles;
		playfxontag( level._effect[ "zapper_light_notready" ], light.fx, "tag_origin" );
	}
}

trap_lights_green() //checked partially changed to match cerberus output //did not change while loop to for loop to prevent infinite loop bug
{
	i = 0;
	while ( i < self._trap_lights.size )
	{
		light = self._trap_lights[ i ];
		if ( isDefined( light._switch_disabled ) )
		{
			i++;
			continue;
		}
		light setmodel( self._trap_light_model_green );
		if ( isDefined( light.fx ) )
		{
			light.fx delete();
		}
		light.fx = maps/mp/zombies/_zm_net::network_safe_spawn( "trap_lights_green", 2, "script_model", light.origin );
		light.fx setmodel( "tag_origin" );
		light.fx.angles = light.angles;
		playfxontag( level._effect[ "zapper_light_ready" ], light.fx, "tag_origin" );
		i++;
	}
}

trap_set_string( string, param1, param2 ) //checked partially changed to match cerberus output //did not change while loop to for loop to prevent infinite loop bug with continues
{
	i = 0;
	while ( i < self._trap_use_trigs.size )
	{
		if ( !isDefined( param1 ) )
		{
			self._trap_use_trigs[ i ] sethintstring( string );
			i++;
			continue;
		}
		if ( !isDefined( param2 ) )
		{
			self._trap_use_trigs[ i ] sethintstring( string, param1 );
			i++;
			continue;
		}
		self._trap_use_trigs[ i ] sethintstring( string, param1, param2 );
		i++;
	}
}

trap_move_switches() //checked checked changed to match cerberus output
{
	self trap_lights_red();
	for ( i = 0; i < self._trap_switches.size; i++ )
	{
		self._trap_switches[ i ] rotatepitch( 180, 0,5 );
		self._trap_switches[ i ] playsound( "amb_sparks_l_b" );
	}
	self._trap_switches[ 0 ] waittill( "rotatedone" );
	self notify( "switch_activated" );
	self waittill( "available" );
	for ( i = 0; i < self._trap_switches.size; i++ )
	{
		self._trap_switches[ i ] rotatepitch( -180, 0,5 );
	}
	self._trap_switches[ 0 ] waittill( "rotatedone" );
	self trap_lights_green();
}

trap_activate_electric() //checked changed to match cerberus output
{
	self._trap_duration = 40;
	self._trap_cooldown_time = 60;
	self notify( "trap_activate" );
	if ( isDefined( self.script_string ) )
	{
		number = int( self.script_string );
		if ( number != 0 )
		{
			exploder( number );
		}
		else
		{
			clientnotify( self.script_string + "1" );
		}
	}
	fx_points = getstructarray( self.target, "targetname" );
	for ( i = 0; i < fx_points.size; i++ )
	{
		wait_network_frame();
		fx_points[ i ] thread trap_audio_fx( self );
	}
	self thread trap_damage();
	wait self._trap_duration;
	self notify( "trap_done" );
	if ( isDefined( self.script_string ) )
	{
		clientnotify( self.script_string + "0" );
	}
}

trap_activate_fire() //checked changed to match cerberus output
{
	self._trap_duration = 40;
	self._trap_cooldown_time = 60;
	clientnotify( self.script_string + "1" );
	clientnotify( self.script_parameters );
	fx_points = getstructarray( self.target, "targetname" );
	for ( i = 0; i < fx_points.size; i++ )
	{
		wait_network_frame();
		fx_points[ i ] thread trap_audio_fx( self );
	}
	self thread trap_damage();
	wait self._trap_duration;
	self notify( "trap_done" );
	clientnotify( self.script_string + "0" );
	clientnotify( self.script_parameters );
}

trap_activate_rotating() //checked partially changed to match cerberus output 
{
	self endon( "trap_done" );
	self._trap_duration = 30;
	self._trap_cooldown_time = 60;
	self thread trap_damage();
	self thread trig_update( self._trap_movers[ 0 ] );
	old_angles = self._trap_movers[ 0 ].angles;
	for ( i = 0; i < self._trap_movers.size; i++ )
	{
		self._trap_movers[ i ] rotateyaw( 360, 5, 4.5 );
	}
	wait 5;
	step = 1.5;
	t = 0;
	while ( t < self._trap_duration ) //this would not make sense as a for loop leaving as a while loop
	{
		for ( i = 0; i < self._trap_movers.size; i++ )
		{
			self._trap_movers[ i ] rotateyaw( 360, step );
		}
		wait step;
		t += step;
	}
	for ( i = 0; i < self._trap_movers.size; i++ )
	{
		self._trap_movers[ i ] rotateyaw( 360, 5, 0, 4.5 );
	}
	wait 5;
	for ( i = 0; i < self._trap_movers.size; i++ )
	{
		self._trap_movers[ i ].angles = old_angles;
	}
	self notify( "trap_done" );
}

trap_activate_flipper() //checked matches cerberus output
{
}

trap_audio_fx( trap ) //checked matches cerberus output
{
	sound_origin = undefined;
	if ( trap.script_noteworthy == "electric" )
	{
		sound_origin = spawn( "script_origin", self.origin );
		sound_origin playsound( "zmb_elec_start" );
		sound_origin playloopsound( "zmb_elec_loop" );
		self thread play_electrical_sound( trap );
	}
	else
	{
		if ( trap.script_noteworthy == "fire" )
		{
			sound_origin = spawn( "script_origin", self.origin );
			sound_origin playsound( "zmb_firetrap_start" );
			sound_origin playloopsound( "zmb_firetrap_loop" );
		}
	}
	trap waittill_any_or_timeout( trap._trap_duration, "trap_done" );
	if ( isDefined( sound_origin ) )
	{
		if ( trap.script_noteworthy == "fire" )
		{
			playsoundatposition( "zmb_firetrap_end", sound_origin.origin );
		}
		sound_origin stoploopsound();
		wait 0.05;
		sound_origin delete();
	}
}

play_electrical_sound( trap ) //checked matches cerberus output
{
	trap endon( "trap_done" );
	while ( 1 )
	{
		wait randomfloatrange( 0.1, 0.5 );
		playsoundatposition( "zmb_elec_arc", self.origin );
	}
}

trap_damage() //checked partially changed to match cerberus output
{
	self endon( "trap_done" );
	while ( 1 )
	{
		self waittill( "trigger", ent );
		if ( isplayer( ent ) )
		{
			switch( self._trap_type )
			{
				case "electric":
					ent thread player_elec_damage();
					break;
				case "fire":
				case "rocket":
					ent thread player_fire_damage();
					break;
				case "rotating":
					if ( ent getstance() == "stand" )
					{
						ent dodamage( 50, ent.origin + vectorScale( ( 0, 0, 1 ), 20 ) );
						ent setstance( "crouch" );
					}
					break;
			}
			//break; //this doesn't make much sense commenting out
		}
		else if ( !isDefined( ent.marked_for_death ) )
		{
			switch( self._trap_type )
			{
				case "rocket":
					ent thread zombie_trap_death( self, 100 );
					break;
				break;
				case "rotating":
					ent thread zombie_trap_death( self, 200 );
					break;
				break;
				case "electric":
				case "fire":
				default:
					ent thread zombie_trap_death( self, randomint( 100 ) );
					break;
			}
		}
	}
}

trig_update( parent ) //checked matches cerberus output
{
	self endon( "trap_done" );
	start_angles = self.angles;
	while ( 1 )
	{
		self.angles = parent.angles;
		wait 0.05;
	}
}

player_elec_damage() //checked changed to match cerberus output
{
	self endon( "death" );
	self endon( "disconnect" );
	if ( !isDefined( level.elec_loop ) )
	{
		level.elec_loop = 0;
	}
	if ( !isDefined( self.is_burning ) && is_player_valid( self ) )
	{
		self.is_burning = 1;
		if ( is_true( level.trap_electric_visionset_registered ) )
		{
			maps/mp/_visionset_mgr::vsmgr_activate( "overlay", "zm_trap_electric", self, 1.25, 1.25 );
		}
		else
		{
			self setelectrified( 1.25 );
		}
		shocktime = 2.5;
		self shellshock( "electrocution", shocktime );
		if ( level.elec_loop == 0 )
		{
			elec_loop = 1;
			self playsound( "zmb_zombie_arc" );
		}
		if ( !self hasperk( "specialty_armorvest" ) || self.health - 100 < 1 )
		{
			radiusdamage( self.origin, 10, self.health + 100, self.health + 100 );
			self.is_burning = undefined;
		}
		else
		{
			self dodamage( 50, self.origin );
			wait 0.1;
			self.is_burning = undefined;
		}
	}
}

player_fire_damage() //checked changed to match cerberus output
{
	self endon( "death" );
	self endon( "disconnect" );
	if ( !isDefined( self.is_burning ) && !self maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
	{
		self.is_burning = 1;
		if ( is_true( level.trap_fire_visionset_registered ) )
		{
			maps/mp/_visionset_mgr::vsmgr_activate( "overlay", "zm_trap_burn", self, 1.25, 1.25 );
		}
		else
		{
			self setburn( 1.25 );
		}
		self notify( "burned" );
		if ( !self hasperk( "specialty_armorvest" ) || self.health - 100 < 1 )
		{
			radiusdamage( self.origin, 10, self.health + 100, self.health + 100 );
			self.is_burning = undefined;
		}
		else
		{
			self dodamage( 50, self.origin );
			wait 0.1;
			self.is_burning = undefined;
		}
	}
}

zombie_trap_death( trap, param ) //checked matches cerberus output
{
	self endon( "death" );
	self.marked_for_death = 1;
	switch( trap._trap_type )
	{
		case "electric":
		case "fire":
		case "rocket":
			if ( isDefined( self.animname ) && self.animname != "zombie_dog" )
			{
				if ( param > 90 && level.burning_zombies.size < 6 )
				{
					level.burning_zombies[ level.burning_zombies.size ] = self;
					self thread zombie_flame_watch();
					self playsound( "ignite" );
					self thread maps/mp/animscripts/zm_death::flame_death_fx();
					playfxontag( level._effect[ "character_fire_death_torso" ], self, "J_SpineLower" );
					wait randomfloat( 1.25 );
				}
				else
				{
					refs[ 0 ] = "guts";
					refs[ 1 ] = "right_arm";
					refs[ 2 ] = "left_arm";
					refs[ 3 ] = "right_leg";
					refs[ 4 ] = "left_leg";
					refs[ 5 ] = "no_legs";
					refs[ 6 ] = "head";
					self.a.gib_ref = refs[ randomint( refs.size ) ];
					playsoundatposition( "zmb_zombie_arc", self.origin );
					if ( trap._trap_type == "electric" )
					{
						if ( randomint( 100 ) > 50 )
						{
							self thread electroctute_death_fx();
							self thread play_elec_vocals();
						}
					}
					wait randomfloat( 1.25 );
					self playsound( "zmb_zombie_arc" );
				}
			}
			if ( isDefined( self.fire_damage_func ) )
			{
				self [[ self.fire_damage_func ]]( trap );
			}
			else
			{
				level notify( "trap_kill" );
				self dodamage( self.health + 666, self.origin, trap );
			}
			break;
		case "centrifuge":
		case "rotating":
			ang = vectorToAngle( trap.origin - self.origin );
			direction_vec = vectorScale( anglesToRight( ang ), param );
			if ( isDefined( self.trap_reaction_func ) )
			{
				self [[ self.trap_reaction_func ]]( trap );
			}
			level notify( "trap_kill" );
			self startragdoll();
			self launchragdoll( direction_vec );
			wait_network_frame();
			self.a.gib_ref = "head";
			self dodamage( self.health, self.origin, trap );
			break;
	}
}

zombie_flame_watch() //checked matches cerberus output
{
	self waittill( "death" );
	self stoploopsound();
	arrayremovevalue( level.burning_zombies, self );
}

play_elec_vocals() //checked matches cerberus output
{
	if ( isDefined( self ) )
	{
		org = self.origin;
		wait 0.15;
		playsoundatposition( "zmb_elec_vocals", org );
		playsoundatposition( "zmb_zombie_arc", org );
		playsoundatposition( "zmb_exp_jib_zombie", org );
	}
}

electroctute_death_fx() //checked matches cerberus output
{
	self endon( "death" );
	if ( is_true( self.is_electrocuted ) )
	{
		return;
	}
	self.is_electrocuted = 1;
	self thread electrocute_timeout();
	if ( self.team == level.zombie_team )
	{
		level.bconfiretime = getTime();
		level.bconfireorg = self.origin;
	}
	if ( isDefined( level._effect[ "elec_torso" ] ) )
	{
		playfxontag( level._effect[ "elec_torso" ], self, "J_SpineLower" );
	}
	self playsound( "zmb_elec_jib_zombie" );
	wait 1;
	tagarray = [];
	tagarray[ 0 ] = "J_Elbow_LE";
	tagarray[ 1 ] = "J_Elbow_RI";
	tagarray[ 2 ] = "J_Knee_RI";
	tagarray[ 3 ] = "J_Knee_LE";
	tagarray = array_randomize( tagarray );
	if ( isDefined( level._effect[ "elec_md" ] ) )
	{
		playfxontag( level._effect[ "elec_md" ], self, tagarray[ 0 ] );
	}
	self playsound( "zmb_elec_jib_zombie" );
	wait 1;
	self playsound( "zmb_elec_jib_zombie" );
	tagarray[ 0 ] = "J_Wrist_RI";
	tagarray[ 1 ] = "J_Wrist_LE";
	if ( !isDefined( self.a.gib_ref ) || self.a.gib_ref != "no_legs" )
	{
		tagarray[ 2 ] = "J_Ankle_RI";
		tagarray[ 3 ] = "J_Ankle_LE";
	}
	tagarray = array_randomize( tagarray );
	if ( isDefined( level._effect[ "elec_sm" ] ) )
	{
		playfxontag( level._effect[ "elec_sm" ], self, tagarray[ 0 ] );
		playfxontag( level._effect[ "elec_sm" ], self, tagarray[ 1 ] );
	}
}

electrocute_timeout() //checked matches cerberus output
{
	self endon( "death" );
	self playloopsound( "fire_manager_0" );
	wait 12;
	self stoploopsound();
	if ( isDefined( self ) && isalive( self ) )
	{
		self.is_electrocuted = 0;
		self notify( "stop_flame_damage" );
	}
}

trap_dialog() //checked partially changed to match cerberus output //did not change while loop to for loop to prevent in the infinite for loop bug caused by continues
{
	self endon( "warning_dialog" );
	level endon( "switch_flipped" );
	timer = 0;
	while ( 1 )
	{
		wait 0.5;
		players = get_players();
		i = 0;
		while ( i < players.size )
		{
			dist = distancesquared( players[ i ].origin, self.origin );
			if ( dist > 4900 )
			{
				timer = 0;
				i++;
				continue;
			}
			if ( dist < 4900 && timer < 3 )
			{
				wait 0.5;
				timer++;
			}
			if ( dist < 4900 && timer == 3 )
			{
				index = maps/mp/zombies/_zm_weapons::get_player_index( players[ i ] );
				plr = "plr_" + index + "_";
				wait 3;
				self notify( "warning_dialog" );
			}
			i++;
		}
	}
}

get_trap_array( trap_type ) //checked changed to match cerberus output
{
	ents = getentarray( "zombie_trap", "targetname" );
	traps = [];
	for ( i = 0; i < ents.size; i++ )
	{
		if ( ents[ i ].script_noteworthy == trap_type )
		{
			traps[ traps.size ] = ents[ i ];
		}
	}
	return traps;
}

trap_disable() //checked matches cerberus output
{
	cooldown = self._trap_cooldown_time;
	if ( self._trap_in_use )
	{
		self notify( "trap_done" );
		self._trap_cooldown_time = 0.05;
		self waittill( "available" );
	}
	array_thread( self._trap_use_trigs, ::trigger_off );
	self trap_lights_red();
	self._trap_cooldown_time = cooldown;
}

trap_enable() //checked matches cerberus output
{
	array_thread( self._trap_use_trigs, ::trigger_on );
	self trap_lights_green();
}

trap_model_type_init() //checked matches cerberus output
{
	if ( !isDefined( self.script_parameters ) )
	{
		self.script_parameters = "default";
	}
	switch( self.script_parameters )
	{
		case "pentagon_electric":
			self._trap_light_model_off = "zombie_trap_switch_light";
			self._trap_light_model_green = "zombie_trap_switch_light_on_green";
			self._trap_light_model_red = "zombie_trap_switch_light_on_red";
			self._trap_switch_model = "zombie_trap_switch_handle";
			break;
		case "default":
		default:
			self._trap_light_model_off = "zombie_zapper_cagelight";
			self._trap_light_model_green = "zombie_zapper_cagelight_green";
			self._trap_light_model_red = "zombie_zapper_cagelight_red";
			self._trap_switch_model = "zombie_zapper_handle";
			break;
	}
}

register_visionsets( a_traps ) //checked changed to match cerberus output
{
	a_registered_traps = [];
	foreach ( trap in a_traps )
	{
		if ( isDefined( trap.script_noteworthy ) )
		{
			if ( !trap is_trap_registered( a_registered_traps ) )
			{
				a_registered_traps[ trap.script_noteworthy ] = 1;
			}
		}
	}
	keys = getarraykeys( a_registered_traps );
	foreach ( key in keys )
	{
		switch( key )
		{
			case "electric":
				if ( !isDefined( level.vsmgr_prio_overlay_zm_trap_electrified ) )
				{
					level.vsmgr_prio_overlay_zm_trap_electrified = 60;
				}
				maps/mp/_visionset_mgr::vsmgr_register_info( "overlay", "zm_trap_electric", 16000, level.vsmgr_prio_overlay_zm_trap_electrified, 15, 1, ::maps/mp/_visionset_mgr::vsmgr_duration_lerp_thread_per_player, 0 );
				level.trap_electric_visionset_registered = 1;
				break;
			case "fire":
				if ( !isDefined( level.vsmgr_prio_overlay_zm_trap_burn ) )
				{
					level.vsmgr_prio_overlay_zm_trap_burn = 61;
				}
				maps/mp/_visionset_mgr::vsmgr_register_info( "overlay", "zm_trap_burn", 16000, level.vsmgr_prio_overlay_zm_trap_burn, 15, 1, ::maps/mp/_visionset_mgr::vsmgr_duration_lerp_thread_per_player, 0 );
				level.trap_fire_visionset_registered = 1;
				break;
		}
	}
}

is_trap_registered( a_registered_traps ) //checked matches cerberus output
{
	return isDefined( a_registered_traps[ self.script_noteworthy ] );
}


