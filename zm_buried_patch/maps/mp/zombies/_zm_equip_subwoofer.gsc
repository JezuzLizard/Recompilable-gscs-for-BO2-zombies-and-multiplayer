#include maps/mp/animscripts/zm_shared;
#include maps/mp/animscripts/zm_death;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/zombies/_zm_buildables;
#include maps/mp/zombies/_zm_power;
#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/zombies/_zm;
#include maps/mp/gametypes_zm/_weaponobjects;
#include maps/mp/zombies/_zm_equipment;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init( pickupstring, howtostring )
{
	if ( !maps/mp/zombies/_zm_equipment::is_equipment_included( "equip_subwoofer_zm" ) )
	{
		return;
	}
	level.subwoofer_name = "equip_subwoofer_zm";
	precacherumble( "subwoofer_light" );
	precacherumble( "subwoofer_medium" );
	precacherumble( "subwoofer_heavy" );
	init_animtree();
	maps/mp/zombies/_zm_equipment::register_equipment( level.subwoofer_name, pickupstring, howtostring, "zom_hud_subwoofer_complete", "subwoofer", undefined, ::transfersubwoofer, ::dropsubwoofer, ::pickupsubwoofer, ::placesubwoofer );
	maps/mp/zombies/_zm_equipment::add_placeable_equipment( level.subwoofer_name, "t6_wpn_turret_zmb_subwoofer_view" );
	level thread onplayerconnect();
	maps/mp/gametypes_zm/_weaponobjects::createretrievablehint( "equip_subwoofer", pickupstring );
	level._effect[ "subwoofer_on" ] = loadfx( "maps/zombie_highrise/fx_highrise_trmpl_steam_os" );
	level._effect[ "subwoofer_audio_wave" ] = loadfx( "maps/zombie_buried/fx_buried_subwoofer_blast" );
	level._effect[ "subwoofer_knockdown_ground" ] = loadfx( "weapon/thunder_gun/fx_thundergun_knockback_ground" );
	level._effect[ "subwoofer_disappear" ] = loadfx( "maps/zombie/fx_zmb_tranzit_turbine_explo" );
	level.subwoofer_gib_refs = [];
	level.subwoofer_gib_refs[ level.subwoofer_gib_refs.size ] = "guts";
	level.subwoofer_gib_refs[ level.subwoofer_gib_refs.size ] = "right_arm";
	level.subwoofer_gib_refs[ level.subwoofer_gib_refs.size ] = "left_arm";
	registerclientfield( "actor", "subwoofer_flings_zombie", 12000, 1, "int" );
	thread wait_init_damage();
}

wait_init_damage()
{
	while ( !isDefined( level.zombie_vars ) || !isDefined( level.zombie_vars[ "zombie_health_start" ] ) )
	{
		wait 1;
	}
	level.subwoofer_damage = maps/mp/zombies/_zm::ai_zombie_health( 50 );
}

onplayerconnect()
{
	for ( ;; )
	{
		level waittill( "connecting", player );
		player thread onplayerspawned();
	}
}

onplayerspawned()
{
	self endon( "disconnect" );
	self thread setupwatchers();
	for ( ;; )
	{
		self waittill( "spawned_player" );
		self thread watchsubwooferuse();
	}
}

setupwatchers()
{
	self waittill( "weapon_watchers_created" );
	watcher = maps/mp/gametypes_zm/_weaponobjects::getweaponobjectwatcher( "equip_subwoofer" );
	watcher.onspawnretrievetriggers = ::maps/mp/zombies/_zm_equipment::equipment_onspawnretrievableweaponobject;
}

watchsubwooferuse()
{
	self notify( "watchSubwooferUse" );
	self endon( "watchSubwooferUse" );
	self endon( "death" );
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "equipment_placed", weapon, weapname );
		if ( weapname == level.subwoofer_name )
		{
			self cleanupoldsubwoofer();
			self.buildablesubwoofer = weapon;
			self thread startsubwooferdeploy( weapon );
		}
	}
}

cleanupoldsubwoofer( preserve_state )
{
	if ( isDefined( self.buildablesubwoofer ) )
	{
		if ( isDefined( self.buildablesubwoofer.stub ) )
		{
			thread maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( self.buildablesubwoofer.stub );
			self.buildablesubwoofer.stub = undefined;
		}
		self.buildablesubwoofer delete();
		self.subwoofer_kills = undefined;
		if ( isDefined( preserve_state ) && !preserve_state )
		{
			self.subwoofer_health = undefined;
			self.subwoofer_emped = undefined;
			self.subwoofer_emp_time = undefined;
		}
	}
	if ( isDefined( level.subwoofer_sound_ent ) )
	{
		level.subwoofer_sound_ent delete();
		level.subwoofer_sound_ent = undefined;
	}
}

watchforcleanup()
{
	self notify( "subwoofer_cleanup" );
	self endon( "subwoofer_cleanup" );
	evt = self waittill_any_return( "death_or_disconnect", "equip_subwoofer_zm_taken", "equip_subwoofer_zm_pickup" );
	if ( isDefined( self ) )
	{
		self cleanupoldsubwoofer( evt == "equip_subwoofer_zm_pickup" );
	}
}

placesubwoofer( origin, angles )
{
	item = self maps/mp/zombies/_zm_equipment::placed_equipment_think( "t6_wpn_zmb_subwoofer", level.subwoofer_name, origin, angles, 32, 0 );
	if ( isDefined( item ) )
	{
		item.subwoofer_kills = self.subwoofer_kills;
		item.requires_pickup = 1;
	}
	self.subwoofer_kills = undefined;
	return item;
}

dropsubwoofer()
{
	item = self maps/mp/zombies/_zm_equipment::dropped_equipment_think( "t6_wpn_zmb_subwoofer", level.subwoofer_name, self.origin, self.angles, 32, 0 );
	if ( isDefined( item ) )
	{
		item.subwoofer_kills = self.subwoofer_kills;
		item.requires_pickup = 1;
		item.subwoofer_power_on = self.subwoofer_power_on;
		item.subwoofer_power_level = self.subwoofer_power_level;
		item.subwoofer_round_start = self.subwoofer_round_start;
		item.subwoofer_health = self.subwoofer_health;
		item.subwoofer_emped = self.subwoofer_emped;
		item.subwoofer_emp_time = self.subwoofer_emp_time;
	}
	self.subwoofer_kills = undefined;
	self.subwoofer_is_powering_on = undefined;
	self.subwoofer_power_on = undefined;
	self.subwoofer_power_level = undefined;
	self.subwoofer_round_start = undefined;
	self.subwoofer_health = undefined;
	self.subwoofer_emped = undefined;
	self.subwoofer_emp_time = undefined;
	return item;
}

pickupsubwoofer( item )
{
	self.subwoofer_kills = item.subwoofer_kills;
	item.subwoofer_kills = undefined;
}

transfersubwoofer( fromplayer, toplayer )
{
	buildablesubwoofer = toplayer.buildablesubwoofer;
	toarmed = 0;
	if ( isDefined( buildablesubwoofer ) )
	{
		if ( isDefined( buildablesubwoofer.is_armed ) )
		{
			toarmed = buildablesubwoofer.is_armed;
		}
	}
	subwoofer_kills = toplayer.subwoofer_kills;
	fromarmed = 0;
	if ( isDefined( fromplayer.buildablesubwoofer ) )
	{
		if ( isDefined( fromplayer.buildablesubwoofer.is_armed ) )
		{
			fromarmed = fromplayer.buildablesubwoofer.is_armed;
		}
	}
	toplayer.buildablesubwoofer = fromplayer.buildablesubwoofer;
	subwoofer_power_on = toplayer.subwoofer_power_on;
	subwoofer_power_level = toplayer.subwoofer_power_level;
	subwoofer_round_start = toplayer.subwoofer_round_start;
	subwoofer_health = toplayer.subwoofer_health;
	subwoofer_emped = toplayer.subwoofer_emped;
	subwoofer_emp_time = toplayer.subwoofer_emp_time;
	toplayer.buildablesubwoofer = fromplayer.buildablesubwoofer;
	fromplayer.buildablesubwoofer = buildablesubwoofer;
	toplayer.subwoofer_emped = fromplayer.subwoofer_emped;
	fromplayer.subwoofer_emped = subwoofer_emped;
	toplayer.subwoofer_emp_time = fromplayer.subwoofer_emp_time;
	fromplayer.subwoofer_emp_time = subwoofer_emp_time;
	toplayer.subwoofer_is_powering_on = undefined;
	fromplayer.subwoofer_is_powering_on = undefined;
	toplayer.subwoofer_power_on = fromplayer.subwoofer_power_on;
	fromplayer.subwoofer_power_on = subwoofer_power_on;
	toplayer.subwoofer_power_level = fromplayer.subwoofer_power_level;
	toplayer.subwoofer_round_start = fromplayer.subwoofer_round_start;
	fromplayer.subwoofer_power_level = subwoofer_power_level;
	fromplayer.subwoofer_round_start = subwoofer_round_start;
	toplayer.subwoofer_health = fromplayer.subwoofer_health;
	fromplayer.subwoofer_health = subwoofer_health;
	toplayer.buildablesubwoofer.original_owner = toplayer;
	toplayer.buildablesubwoofer.owner = toplayer;
	toplayer notify( "equip_subwoofer_zm_taken" );
	toplayer.subwoofer_kills = fromplayer.subwoofer_kills;
	toplayer thread startsubwooferdeploy( toplayer.buildablesubwoofer, fromarmed );
	fromplayer.subwoofer_kills = subwoofer_kills;
	fromplayer notify( "equip_subwoofer_zm_taken" );
	if ( isDefined( fromplayer.buildablesubwoofer ) )
	{
		fromplayer thread startsubwooferdeploy( fromplayer.buildablesubwoofer, toarmed );
		fromplayer.buildablesubwoofer.original_owner = fromplayer;
		fromplayer.buildablesubwoofer.owner = fromplayer;
	}
	else
	{
		fromplayer maps/mp/zombies/_zm_equipment::equipment_release( level.subwoofer_name );
	}
}

subwoofer_in_range( delta, origin, radius )
{
	if ( distancesquared( self.target.origin, origin ) < ( radius * radius ) )
	{
		return 1;
	}
	return 0;
}

subwoofer_power_on( origin, radius )
{
/#
	println( "^1ZM POWER: trap on\n" );
#/
	if ( !isDefined( self.target ) )
	{
		return;
	}
	self.target.power_on = 1;
	self.target.power_on_time = getTime();
	self.target.owner thread subwooferthink( self.target );
}

subwoofer_power_off( origin, radius )
{
/#
	println( "^1ZM POWER: trap off\n" );
#/
	if ( !isDefined( self.target ) )
	{
		return;
	}
	self.target.power_on = 0;
}

subwoofer_cost()
{
	return maps/mp/zombies/_zm_power::cost_high() / 2;
}

startsubwooferdeploy( weapon, armed )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "equip_subwoofer_zm_taken" );
	self thread watchforcleanup();
	if ( isDefined( self.subwoofer_kills ) )
	{
		weapon.subwoofer_kills = self.subwoofer_kills;
		self.subwoofer_kills = undefined;
	}
	if ( !isDefined( weapon.subwoofer_kills ) )
	{
		weapon.subwoofer_kills = 0;
	}
	if ( !isDefined( self.subwoofer_health ) )
	{
		self.subwoofer_health = 60;
		self.subwoofer_power_level = 4;
	}
	if ( isDefined( weapon ) )
	{
/#
		self thread debugsubwoofer();
#/
		if ( isDefined( level.equipment_subwoofer_needs_power ) && level.equipment_subwoofer_needs_power )
		{
			weapon.power_on = 0;
			maps/mp/zombies/_zm_power::add_temp_powered_item( ::subwoofer_power_on, ::subwoofer_power_off, ::subwoofer_in_range, ::subwoofer_cost, 1, weapon.power_on, weapon );
		}
		else
		{
			weapon.power_on = 1;
		}
		if ( weapon.power_on )
		{
			self thread subwooferthink( weapon, armed );
		}
		else
		{
			self iprintlnbold( &"ZOMBIE_NEED_LOCAL_POWER" );
		}
		if ( isDefined( level.equipment_subwoofer_needs_power ) && !level.equipment_subwoofer_needs_power )
		{
			self thread startsubwooferdecay( weapon );
		}
		self thread maps/mp/zombies/_zm_buildables::delete_on_disconnect( weapon );
		weapon waittill( "death" );
		if ( isDefined( level.subwoofer_sound_ent ) )
		{
			level.subwoofer_sound_ent playsound( "wpn_zmb_electrap_stop" );
			level.subwoofer_sound_ent delete();
			level.subwoofer_sound_ent = undefined;
		}
		self notify( "subwoofer_cleanup" );
	}
}

startsubwooferdecay( weapon )
{
	self notify( "subwooferDecay" );
	self endon( "subwooferDecay" );
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "equip_subwoofer_zm_taken" );
	weapon endon( "death" );
	roundlives = 4;
	if ( !isDefined( self.subwoofer_power_level ) )
	{
		self.subwoofer_power_level = roundlives;
	}
	while ( weapon.subwoofer_kills < 45 )
	{
		old_power_level = self.subwoofer_power_level;
		if ( isDefined( self.subwoofer_emped ) && self.subwoofer_emped && isDefined( self.subwoofer_is_powering_on ) && !self.subwoofer_is_powering_on )
		{
			emp_time = level.zombie_vars[ "emp_perk_off_time" ];
			now = getTime();
			emp_time_left = emp_time - ( ( now - self.subwoofer_emp_time ) / 1000 );
			if ( emp_time_left <= 0 )
			{
				self.subwoofer_emped = undefined;
				self.subwoofer_emp_time = undefined;
				old_power_level = -1;
			}
		}
		if ( isDefined( self.subwoofer_emped ) && self.subwoofer_emped )
		{
			self.subwoofer_power_level = 0;
		}
		cost = 1;
		if ( weapon.subwoofer_kills > 30 )
		{
			self.subwoofer_power_level = 1;
			if ( isDefined( weapon.low_health_sparks ) && !weapon.low_health_sparks )
			{
				weapon.low_health_sparks = 1;
				playfxontag( level._effect[ "switch_sparks" ], weapon, "tag_origin" );
			}
		}
		else if ( weapon.subwoofer_kills > 15 )
		{
			self.subwoofer_power_level = 2;
		}
		else
		{
			self.subwoofer_power_level = 4;
		}
		if ( old_power_level != self.subwoofer_power_level )
		{
			self notify( "subwoofer_power_change" );
		}
		wait 1;
	}
	if ( isDefined( weapon ) )
	{
		self destroy_placed_subwoofer();
		subwoofer_disappear_fx( weapon );
	}
	self thread wait_and_take_equipment();
	self.subwoofer_health = undefined;
	self.subwoofer_power_level = undefined;
	self.subwoofer_round_start = undefined;
	self.subwoofer_power_on = undefined;
	self.subwoofer_emped = undefined;
	self.subwoofer_emp_time = undefined;
	self cleanupoldsubwoofer();
}

destroy_placed_subwoofer()
{
	if ( isDefined( self.buildablesubwoofer ) )
	{
		if ( isDefined( self.buildablesubwoofer.dying ) && self.buildablesubwoofer.dying )
		{
			while ( isDefined( self.buildablesubwoofer ) )
			{
				wait 0,05;
			}
			return;
		}
		if ( isDefined( self.buildablesubwoofer.stub ) )
		{
			thread maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( self.buildablesubwoofer.stub );
		}
		thread subwoofer_disappear_fx( self.buildablesubwoofer, 0,75 );
		self.buildablesubwoofer.dying = 1;
	}
}

wait_and_take_equipment()
{
	wait 0,05;
	self thread maps/mp/zombies/_zm_equipment::equipment_release( level.subwoofer_name );
}

init_animtree()
{
}

subwoofer_fx( weapon )
{
	weapon endon( "death" );
	self endon( "equip_subwoofer_zm_taken" );
	while ( isDefined( weapon ) )
	{
		wait 1;
	}
}

subwoofer_disappear_fx( weapon, waittime )
{
	if ( isDefined( waittime ) && waittime > 0 )
	{
		wait waittime;
	}
	if ( isDefined( weapon ) )
	{
		playfx( level._effect[ "subwoofer_disappear" ], weapon.origin );
	}
}

subwoofer_choke()
{
	while ( 1 )
	{
		level._subwoofer_choke = 0;
		wait_network_frame();
	}
}

subwooferthink( weapon, armed )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "equip_subwoofer_zm_taken" );
	weapon notify( "subwooferthink" );
	weapon endon( "subwooferthink" );
	weapon endon( "death" );
	direction_forward = anglesToForward( flat_angle( weapon.angles ) + vectorScale( ( 0, 0, 1 ), 30 ) );
	direction_vector = vectorScale( direction_forward, 512 );
	direction_origin = weapon.origin + direction_vector;
	original_angles = weapon.angles;
	original_origin = weapon.origin;
	tag_spin_origin = weapon gettagorigin( "tag_spin" );
	wait 0,05;
	while ( 1 )
	{
		while ( isDefined( weapon.power_on ) && !weapon.power_on )
		{
			wait 1;
		}
		wait 2;
		if ( isDefined( weapon.power_on ) && !weapon.power_on )
		{
			continue;
		}
		if ( !isDefined( level._subwoofer_choke ) )
		{
			level thread subwoofer_choke();
		}
		while ( level._subwoofer_choke )
		{
			wait 0,05;
		}
		level._subwoofer_choke++;
		weapon.subwoofer_network_choke_count = 0;
		weapon thread maps/mp/zombies/_zm_equipment::signal_equipment_activated( 1 );
		vibrateamplitude = 4;
		if ( self.subwoofer_power_level == 3 )
		{
			vibrateamplitude = 8;
		}
		else
		{
			if ( self.subwoofer_power_level == 2 )
			{
				vibrateamplitude = 13;
			}
		}
		if ( self.subwoofer_power_level == 1 )
		{
			vibrateamplitude = 17;
		}
		weapon vibrate( vectorScale( ( 0, 0, 1 ), 100 ), vibrateamplitude, 0,2, 0,3 );
		zombies = get_array_of_closest( weapon.origin, get_round_enemy_array(), undefined, undefined, 1200 );
		players = get_array_of_closest( weapon.origin, get_players(), undefined, undefined, 1200 );
		props = get_array_of_closest( weapon.origin, getentarray( "subwoofer_target", "script_noteworthy" ), undefined, undefined, 1200 );
		entities = arraycombine( zombies, players, 0, 0 );
		entities = arraycombine( entities, props, 0, 0 );
		_a681 = entities;
		_k681 = getFirstArrayKey( _a681 );
		while ( isDefined( _k681 ) )
		{
			ent = _a681[ _k681 ];
			if ( !isDefined( ent ) || !isplayer( ent ) && isai( ent ) && !isalive( ent ) )
			{
			}
			else
			{
				if ( isDefined( ent.ignore_subwoofer ) && ent.ignore_subwoofer )
				{
					break;
				}
				else
				{
					distanceentityandsubwoofer = distance2dsquared( original_origin, ent.origin );
					onlydamage = 0;
					action = undefined;
					if ( distanceentityandsubwoofer <= 32400 )
					{
						action = "burst";
					}
					else if ( distanceentityandsubwoofer <= 230400 )
					{
						action = "fling";
					}
					else if ( distanceentityandsubwoofer <= 1440000 )
					{
						action = "stumble";
					}
					else
					{
					}
					if ( !within_fov( original_origin, original_angles, ent.origin, cos( 45 ) ) )
					{
						if ( isplayer( ent ) )
						{
							ent hit_player( action, 0 );
						}
						break;
					}
					else weapon subwoofer_network_choke();
					ent_trace_origin = ent.origin;
					if ( isai( ent ) || isplayer( ent ) )
					{
						ent_trace_origin = ent geteye();
					}
					if ( isDefined( ent.script_noteworthy ) && ent.script_noteworthy == "subwoofer_target" )
					{
						ent_trace_origin += vectorScale( ( 0, 0, 1 ), 48 );
					}
					if ( !sighttracepassed( tag_spin_origin, ent_trace_origin, 1, weapon ) )
					{
						break;
					}
					else if ( isDefined( ent.script_noteworthy ) && ent.script_noteworthy == "subwoofer_target" )
					{
						ent notify( "damaged_by_subwoofer" );
						break;
					}
					else
					{
						if ( isDefined( ent.in_the_ground ) && !ent.in_the_ground && isDefined( ent.in_the_ceiling ) && !ent.in_the_ceiling && isDefined( ent.ai_state ) || ent.ai_state == "zombie_goto_entrance" && isDefined( ent.completed_emerging_into_playable_area ) && !ent.completed_emerging_into_playable_area )
						{
							onlydamage = 1;
						}
						if ( isplayer( ent ) )
						{
							ent notify( "player_" + action );
							ent hit_player( action, 1 );
							break;
						}
						else if ( isDefined( ent ) )
						{
							ent notify( "zombie_" + action );
/#
							ent thread subwoofer_debug_print( action, ( 0, 0, 1 ) );
#/
							shouldgib = distanceentityandsubwoofer <= 810000;
							if ( action == "fling" )
							{
								ent thread fling_zombie( weapon, direction_vector / 4, self, onlydamage );
								weapon.subwoofer_kills++;
								self thread maps/mp/zombies/_zm_audio::create_and_play_dialog( "kill", "subwoofer" );
								break;
							}
							else if ( action == "burst" )
							{
								ent thread burst_zombie( weapon, self );
								weapon.subwoofer_kills++;
								self thread maps/mp/zombies/_zm_audio::create_and_play_dialog( "kill", "subwoofer" );
								break;
							}
							else
							{
								if ( action == "stumble" )
								{
									ent thread knockdown_zombie( weapon, shouldgib, onlydamage );
								}
							}
						}
					}
				}
			}
			_k681 = getNextArrayKey( _a681, _k681 );
		}
		if ( weapon.subwoofer_kills >= 45 )
		{
			self thread subwoofer_expired( weapon );
		}
	}
}

subwoofer_expired( weapon )
{
	weapon maps/mp/zombies/_zm_equipment::dropped_equipment_destroy( 1 );
	self maps/mp/zombies/_zm_equipment::equipment_release( level.subwoofer_name );
	self.subwoofer_kills = 0;
}

hit_player( action, doshellshock )
{
	if ( action == "burst" )
	{
		self playrumbleonentity( "subwoofer_heavy" );
		if ( isDefined( doshellshock ) && doshellshock )
		{
			self shellshock( "frag_grenade_mp", 1,5 );
		}
	}
	else if ( action == "fling" )
	{
		self playrumbleonentity( "subwoofer_medium" );
		if ( isDefined( doshellshock ) && doshellshock )
		{
			self shellshock( "frag_grenade_mp", 0,5 );
		}
	}
	else
	{
		if ( action == "stumble" )
		{
			if ( isDefined( doshellshock ) && doshellshock )
			{
				self playrumbleonentity( "subwoofer_light" );
				self shellshock( "frag_grenade_mp", 0,13 );
			}
		}
	}
}

burst_zombie( weapon, player )
{
	if ( !isDefined( self ) || !isalive( self ) )
	{
		return;
	}
	if ( isDefined( self.subwoofer_burst_func ) )
	{
		self thread [[ self.subwoofer_burst_func ]]( weapon );
		return;
	}
	self dodamage( self.health + 666, weapon.origin );
	player notify( "zombie_subwoofer_kill" );
	if ( isDefined( self.guts_explosion ) && !self.guts_explosion )
	{
		self.guts_explosion = 1;
		self setclientfield( "zombie_gut_explosion", 1 );
		if ( isDefined( self.isdog ) && !self.isdog )
		{
			wait 0,1;
		}
		self ghost();
	}
}

fling_zombie( weapon, fling_vec, player, onlydamage )
{
	if ( !isDefined( self ) || !isalive( self ) )
	{
		return;
	}
	if ( isDefined( self.subwoofer_fling_func ) )
	{
		self thread [[ self.subwoofer_fling_func ]]( weapon, fling_vec );
		player notify( "zombie_subwoofer_kill" );
		return;
	}
	self dodamage( self.health + 666, weapon.origin );
	player notify( "zombie_subwoofer_kill" );
	if ( self.health <= 0 )
	{
		if ( isDefined( onlydamage ) && !onlydamage )
		{
			self startragdoll();
			self setclientfield( "subwoofer_flings_zombie", 1 );
		}
		self.subwoofer_death = 1;
	}
}

knockdown_zombie( weapon, gib, onlydamage )
{
	self endon( "death" );
	if ( isDefined( self.is_knocked_down ) && self.is_knocked_down )
	{
		return;
	}
	if ( !isDefined( self ) || !isalive( self ) )
	{
		return;
	}
	if ( isDefined( self.subwoofer_knockdown_func ) )
	{
		self thread [[ self.subwoofer_knockdown_func ]]( weapon, gib );
		return;
	}
	if ( isDefined( onlydamage ) && onlydamage )
	{
		self thread knockdown_zombie_damage( weapon );
		return;
	}
	if ( gib && isDefined( self.gibbed ) && !self.gibbed )
	{
		self thread knockdown_zombie_damage( weapon );
		self.a.gib_ref = random( level.subwoofer_gib_refs );
		self thread maps/mp/animscripts/zm_death::do_gib();
	}
	self.subwoofer_handle_pain_notetracks = ::handle_subwoofer_pain_notetracks;
	self thread knockdown_zombie_damage( weapon );
	self animcustom( ::knockdown_zombie_animate );
}

knockdown_zombie_damage( weapon )
{
	if ( self.health <= 15 )
	{
		weapon.subwoofer_kills++;
		self thread maps/mp/zombies/_zm_audio::create_and_play_dialog( "kill", "subwoofer" );
	}
	self dodamage( 15, weapon.origin );
}

handle_subwoofer_pain_notetracks( note )
{
	if ( note == "zombie_knockdown_ground_impact" )
	{
		playfx( level._effect[ "subwoofer_knockdown_ground" ], self.origin, anglesToForward( self.angles ), anglesToUp( self.angles ) );
	}
}

knockdown_zombie_animate()
{
	self notify( "end_play_subwoofer_pain_anim" );
	self endon( "killanimscript" );
	self endon( "death" );
	self endon( "end_play_subwoofer_pain_anim" );
	if ( isDefined( self.marked_for_death ) && self.marked_for_death )
	{
		return;
	}
	if ( isDefined( self.has_legs ) && !self.has_legs )
	{
		return;
	}
	if ( isDefined( self.barricade_enter ) && self.barricade_enter )
	{
		return;
	}
	if ( !issubstr( self.animstatedef, "buried" ) )
	{
		return;
	}
	animation_direction = undefined;
	animation_side = undefined;
	animation_duration = "_default";
	if ( self.damageyaw <= -135 || self.damageyaw >= 135 )
	{
		animation_direction = "back";
		animation_side = "back";
	}
	else
	{
		if ( self.damageyaw > -135 && self.damageyaw < -45 )
		{
			animation_direction = "left";
			animation_side = "back";
		}
		else
		{
			if ( self.damageyaw > 45 && self.damageyaw < 135 )
			{
				animation_direction = "right";
				animation_side = "belly";
			}
			else
			{
				animation_direction = "front";
				animation_side = "belly";
			}
		}
	}
	wait randomfloatrange( 0,05, 0,35 );
	self thread knockdown_zombie_animate_state();
/#
	self thread subwoofer_debug_animation_print( animation_direction, animation_side );
#/
	self setanimstatefromasd( "zm_subwoofer_fall_" + animation_direction );
	self maps/mp/animscripts/zm_shared::donotetracks( "subwoofer_fall_anim", self.subwoofer_handle_pain_notetracks );
	if ( isDefined( self ) && isalive( self ) && isDefined( self.has_legs ) || !self.has_legs && isDefined( self.marked_for_death ) && self.marked_for_death )
	{
		return;
	}
	if ( isDefined( self.a.gib_ref ) )
	{
		if ( self.a.gib_ref != "no_legs" && self.a.gib_ref != "no_arms" && self.a.gib_ref != "left_leg" && self.a.gib_ref == "right_leg" || randomint( 100 ) > 25 && self.a.gib_ref != "left_arm" && self.a.gib_ref == "right_arm" && randomint( 100 ) > 75 )
		{
			animation_duration = "_late";
		}
		else
		{
			if ( randomint( 100 ) > 75 )
			{
				animation_duration = "_early";
			}
		}
	}
	else
	{
		if ( randomint( 100 ) > 25 )
		{
			animation_duration = "_early";
		}
	}
	self setanimstatefromasd( "zm_subwoofer_getup_" + animation_side + animation_duration );
	self maps/mp/animscripts/zm_shared::donotetracks( "subwoofer_getup_anim" );
	self notify( "back_up" );
}

knockdown_zombie_animate_state()
{
	self endon( "death" );
	self.is_knocked_down = 1;
	self waittill_any( "damage", "back_up" );
	self.is_knocked_down = 0;
}

subwoofer_network_choke()
{
	self.subwoofer_network_choke_count++;
	if ( self.subwoofer_network_choke_count % 10 )
	{
		wait_network_frame();
	}
}

enemy_killed_by_subwoofer()
{
	if ( isDefined( self.subwoofer_death ) )
	{
		return self.subwoofer_death;
	}
}

debugsubwoofer()
{
/#
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "equip_subwoofer_zm_taken" );
	self.buildablesubwoofer endon( "death" );
	red = ( 0, 0, 1 );
	green = ( 0, 0, 1 );
	blue = ( 0, 0, 1 );
	yellow = vectorScale( ( 0, 0, 1 ), 0,65 );
	while ( isDefined( self.buildablesubwoofer ) )
	{
		if ( getDvarInt( #"EB512CB7" ) )
		{
			row = 1;
			health_color = green;
			if ( self.subwoofer_power_level <= 1 )
			{
				health_color = red;
			}
			else
			{
				if ( self.subwoofer_power_level <= 3 )
				{
					health_color = yellow;
				}
			}
			if ( isDefined( self.buildablesubwoofer.subwoofer_kills ) )
			{
				row = self debugsubwooferprint3d( row, "Kills: " + self.buildablesubwoofer.subwoofer_kills, health_color );
			}
			if ( isDefined( self.subwoofer_health ) )
			{
				row = self debugsubwooferprint3d( row, "Use Time: " + self.subwoofer_health, health_color );
			}
			if ( isDefined( self.buildablesubwoofer.original_owner ) )
			{
				row = self debugsubwooferprint3d( row, "Original Owner: " + self.buildablesubwoofer.original_owner.name, green );
			}
			if ( isDefined( self.buildablesubwoofer.owner ) )
			{
				row = self debugsubwooferprint3d( row, "Current Owner: " + self.buildablesubwoofer.owner.name, green );
			}
		}
		wait 0,05;
#/
	}
}

debugsubwooferprint3d( row, text, color )
{
/#
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "equip_subwoofer_zm_taken" );
	self.buildablesubwoofer endon( "death" );
	print3dspace = vectorScale( ( 0, 0, 1 ), 10 );
	print3d( self.buildablesubwoofer.origin + vectorScale( ( 0, 0, 1 ), 30 ) + ( print3dspace * row ), text, color, 1, 0,5, 1 );
	row++;
	return row;
#/
}

subwoofer_debug_print( msg, color, offset )
{
/#
	if ( !getDvarInt( #"EB512CB7" ) )
	{
		return;
	}
	if ( !isDefined( color ) )
	{
		color = ( 0, 0, 1 );
	}
	if ( !isDefined( offset ) )
	{
		offset = ( 0, 0, 1 );
	}
	print3d( self.origin + vectorScale( ( 0, 0, 1 ), 60 ) + offset, msg, color, 1, 1, 40 );
#/
}

subwoofer_debug_animation_print( msg1, msg2 )
{
/#
	if ( getDvarInt( #"EB512CB7" ) != 1 )
	{
		return;
	}
	self endon( "death" );
	self endon( "damage" );
	self endon( "back_up" );
	color = ( 0, 0, 1 );
	while ( 1 )
	{
		print3d( self.origin + vectorScale( ( 0, 0, 1 ), 50 ), "FallDown: " + msg1, color, 1, 0,75 );
		print3d( self.origin + vectorScale( ( 0, 0, 1 ), 40 ), "GetUp: " + msg2, color, 1, 0,75 );
		wait 0,05;
#/
	}
}
