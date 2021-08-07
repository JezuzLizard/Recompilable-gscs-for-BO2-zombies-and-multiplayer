#include maps/mp/zombies/_zm_audio;
#include maps/mp/animscripts/zm_run;
#include maps/mp/animscripts/zm_death;
#include maps/mp/zombies/_zm_buildables;
#include maps/mp/zombies/_zm_power;
#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/zombies/_zm;
#include maps/mp/gametypes_zm/_weaponobjects;
#include maps/mp/zombies/_zm_spawner;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

#using_animtree( "zombie_headchopper" );

init( pickupstring, howtostring )
{
	if ( !maps/mp/zombies/_zm_equipment::is_equipment_included( "equip_headchopper_zm" ) )
	{
		return;
	}
	level.headchopper_name = "equip_headchopper_zm";
	init_animtree();
	maps/mp/zombies/_zm_equipment::register_equipment( level.headchopper_name, pickupstring, howtostring, "t6_wpn_zmb_chopper", "headchopper", undefined, ::transferheadchopper, ::dropheadchopper, ::pickupheadchopper, ::placeheadchopper );
	maps/mp/zombies/_zm_equipment::add_placeable_equipment( level.headchopper_name, "t6_wpn_zmb_chopper", undefined, "wallmount" );
	maps/mp/zombies/_zm_spawner::register_zombie_damage_callback( ::headchopper_zombie_damage_response );
	maps/mp/zombies/_zm_spawner::register_zombie_death_animscript_callback( ::headchopper_zombie_death_response );
	level thread onplayerconnect();
	maps/mp/gametypes_zm/_weaponobjects::createretrievablehint( "equip_headchopper", pickupstring );
	level._effect[ "headchoppere_on" ] = loadfx( "maps/zombie_buried/fx_buried_headchopper_os" );
	thread init_anim_slice_times();
	thread wait_init_damage();
}

wait_init_damage()
{
	while ( !isDefined( level.zombie_vars ) || !isDefined( level.zombie_vars[ "zombie_health_start" ] ) )
	{
		wait 1;
	}
	level.headchopper_damage = maps/mp/zombies/_zm::ai_zombie_health( 50 );
}

onplayerconnect()
{
	for ( ;; )
	{
		level waittill( "connecting", player );
		player thread onplayerspawned();
		player thread player_hide_turrets_from_other_players();
	}
}

onplayerspawned()
{
	self endon( "disconnect" );
	self thread setupwatchers();
	for ( ;; )
	{
		self waittill( "spawned_player" );
		self thread watchheadchopperuse();
	}
}

setupwatchers()
{
	self waittill( "weapon_watchers_created" );
	watcher = maps/mp/gametypes_zm/_weaponobjects::getweaponobjectwatcher( "equip_headchopper" );
	watcher.onspawnretrievetriggers = ::maps/mp/zombies/_zm_equipment::equipment_onspawnretrievableweaponobject;
}

watchheadchopperuse()
{
	self notify( "watchHeadChopperUse" );
	self endon( "watchHeadChopperUse" );
	self endon( "death" );
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "equipment_placed", weapon, weapname );
		if ( weapname == level.headchopper_name )
		{
			self cleanupoldheadchopper();
			self.buildableheadchopper = weapon;
			self thread startheadchopperdeploy( weapon );
		}
	}
}

cleanupoldheadchopper()
{
	if ( isDefined( self.buildableheadchopper ) )
	{
		if ( isDefined( self.buildableheadchopper.stub ) )
		{
			thread maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( self.buildableheadchopper.stub );
			self.buildableheadchopper.stub = undefined;
		}
		self.buildableheadchopper delete();
		self.headchopper_kills = undefined;
	}
	if ( isDefined( level.headchopper_sound_ent ) )
	{
		level.headchopper_sound_ent delete();
		level.headchopper_sound_ent = undefined;
	}
}

watchforcleanup()
{
	self notify( "headchopper_cleanup" );
	self endon( "headchopper_cleanup" );
	self waittill_any( "death_or_disconnect", "equip_headchopper_zm_taken", "equip_headchopper_zm_pickup" );
	cleanupoldheadchopper();
}

player_hide_turrets_from_other_players()
{
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "create_equipment_turret", equipment, turret );
		if ( equipment == level.headchopper_name )
		{
			turret setinvisibletoall();
			turret setvisibletoplayer( self );
		}
	}
}

placeheadchopper( origin, angles )
{
	item = self maps/mp/zombies/_zm_equipment::placed_equipment_think( "t6_wpn_zmb_chopper", level.headchopper_name, origin, angles, 100, 0 );
	if ( isDefined( item ) )
	{
		item.headchopper_kills = self.headchopper_kills;
		item.requires_pickup = 1;
		item.zombie_attack_callback = ::headchopper_add_chop_ent;
	}
	self.headchopper_kills = undefined;
	return item;
}

dropheadchopper()
{
	item = self maps/mp/zombies/_zm_equipment::dropped_equipment_think( "t6_wpn_zmb_chopper", level.headchopper_name, self.origin, self.angles, 100, 0 );
	if ( isDefined( item ) )
	{
		item.headchopper_kills = self.headchopper_kills;
		item.requires_pickup = 1;
	}
	self.headchopper_kills = undefined;
	return item;
}

pickupheadchopper( item )
{
	self.headchopper_kills = item.headchopper_kills;
	item.headchopper_kills = undefined;
}

transferheadchopper( fromplayer, toplayer )
{
	buildableheadchopper = toplayer.buildableheadchopper;
	toarmed = 0;
	if ( isDefined( buildableheadchopper ) )
	{
		if ( isDefined( buildableheadchopper.is_armed ) )
		{
			toarmed = buildableheadchopper.is_armed;
		}
	}
	headchopper_kills = toplayer.headchopper_kills;
	fromarmed = 0;
	if ( isDefined( fromplayer.buildableheadchopper ) )
	{
		if ( isDefined( fromplayer.buildableheadchopper.is_armed ) )
		{
			fromarmed = fromplayer.buildableheadchopper.is_armed;
		}
	}
	toplayer.buildableheadchopper = fromplayer.buildableheadchopper;
	toplayer.buildableheadchopper.original_owner = toplayer;
	toplayer.buildableheadchopper.owner = toplayer;
	toplayer notify( "equip_headchopper_zm_taken" );
	toplayer.headchopper_kills = fromplayer.headchopper_kills;
	toplayer thread startheadchopperdeploy( toplayer.buildableheadchopper, fromarmed );
	fromplayer.buildableheadchopper = buildableheadchopper;
	fromplayer.headchopper_kills = headchopper_kills;
	fromplayer notify( "equip_headchopper_zm_taken" );
	if ( isDefined( fromplayer.buildableheadchopper ) )
	{
		fromplayer thread startheadchopperdeploy( fromplayer.buildableheadchopper, toarmed );
		fromplayer.buildableheadchopper.original_owner = fromplayer;
		fromplayer.buildableheadchopper.owner = fromplayer;
	}
	else
	{
		fromplayer maps/mp/zombies/_zm_equipment::equipment_release( level.headchopper_name );
	}
}

headchopper_in_range( delta, origin, radius )
{
	if ( distancesquared( self.target.origin, origin ) < ( radius * radius ) )
	{
		return 1;
	}
	return 0;
}

headchopper_power_on( origin, radius )
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
}

headchopper_power_off( origin, radius )
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

startheadchopperdeploy( weapon, armed )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "equip_headchopper_zm_taken" );
	self thread watchforcleanup();
	electricradius = 45;
	if ( isDefined( self.headchopper_kills ) )
	{
		weapon.headchopper_kills = self.headchopper_kills;
		self.headchopper_kills = undefined;
	}
	if ( !isDefined( weapon.headchopper_kills ) )
	{
		weapon.headchopper_kills = 0;
	}
	if ( isDefined( weapon ) )
	{
/#
		weapon thread debugheadchopper( electricradius );
#/
		fwdangles = anglesToUp( weapon.angles );
		traceback = groundtrace( weapon.origin + ( fwdangles * 5 ), weapon.origin - ( fwdangles * 999999 ), 0, weapon );
		if ( isDefined( traceback ) && isDefined( traceback[ "entity" ] ) )
		{
			weapon.planted_on_ent = traceback[ "entity" ];
			if ( isDefined( traceback[ "entity" ].targetname ) )
			{
				parententities = getentarray( traceback[ "entity" ].targetname, "target" );
				if ( isDefined( parententities ) && parententities.size > 0 )
				{
					parententity = parententities[ 0 ];
					if ( isDefined( parententity.targetname ) )
					{
						if ( parententity.targetname == "zombie_debris" || parententity.targetname == "zombie_door" )
						{
							weapon thread destroyheadchopperonplantedblockeropen();
						}
					}
				}
			}
			weapon thread destroyheadchopperonplantedentitydeath();
		}
		weapon.deployed_time = getTime();
		if ( isDefined( level.equipment_headchopper_needs_power ) && level.equipment_headchopper_needs_power )
		{
			weapon.power_on = 0;
			maps/mp/zombies/_zm_power::add_temp_powered_item( ::headchopper_power_on, ::headchopper_power_off, ::headchopper_in_range, ::maps/mp/zombies/_zm_power::cost_high, 1, weapon.power_on, weapon );
		}
		else
		{
			weapon.power_on = 1;
		}
		if ( !weapon.power_on )
		{
			self iprintlnbold( &"ZOMBIE_NEED_LOCAL_POWER" );
		}
		self thread headchopperthink( weapon, electricradius, armed );
		if ( isDefined( level.equipment_headchopper_needs_power ) && !level.equipment_headchopper_needs_power )
		{
		}
		self thread maps/mp/zombies/_zm_buildables::delete_on_disconnect( weapon );
		weapon waittill( "death" );
		if ( isDefined( level.headchopper_sound_ent ) )
		{
			level.headchopper_sound_ent playsound( "wpn_zmb_electrap_stop" );
			level.headchopper_sound_ent delete();
			level.headchopper_sound_ent = undefined;
		}
		self notify( "headchopper_cleanup" );
	}
}

headchopper_zombie_damage_response( mod, hit_location, hit_origin, player, amount )
{
	if ( isDefined( self.damageweapon ) || self.damageweapon == level.headchopper_name && isDefined( self.damageweapon_name ) && self.damageweapon_name == level.headchopper_name )
	{
		player.planted_wallmount_on_a_zombie = 1;
	}
	return 0;
}

headchopper_zombie_death_response( mod, hit_location, hit_origin, player, amount )
{
	if ( isDefined( self.damageweapon ) && self.damageweapon == level.headchopper_name && isDefined( self.damagemod ) && self.damagemod == "MOD_IMPACT" )
	{
		origin = self.origin;
		if ( isDefined( self.damagehit_origin ) )
		{
			origin = self.damagehit_origin;
		}
		players = get_players();
		choppers = [];
		_a412 = players;
		_k412 = getFirstArrayKey( _a412 );
		while ( isDefined( _k412 ) )
		{
			player = _a412[ _k412 ];
			if ( isDefined( player.buildableheadchopper ) )
			{
				choppers[ choppers.size ] = player.buildableheadchopper;
			}
			_k412 = getNextArrayKey( _a412, _k412 );
		}
		chopper = getclosest( origin, choppers );
		level thread headchopper_zombie_death_remove_chopper( chopper );
	}
	return 0;
}

headchopper_zombie_death_remove_chopper( chopper )
{
	player = chopper.owner;
	thread maps/mp/zombies/_zm_equipment::equipment_disappear_fx( chopper.origin, undefined, chopper.angles );
	chopper dropped_equipment_destroy( 0 );
	if ( !player hasweapon( level.headchopper_name ) )
	{
		player giveweapon( level.headchopper_name );
		player setweaponammoclip( level.headchopper_name, 1 );
		player setactionslot( 1, "weapon", level.headchopper_name );
	}
}

init_animtree()
{
	scriptmodelsuseanimtree( -1 );
}

init_anim_slice_times()
{
	level.headchopper_slice_times = [];
	slice_times = getnotetracktimes( %o_zmb_chopper_slice_slow, "slice" );
	retract_times = getnotetracktimes( %o_zmb_chopper_slice_slow, "retract" );
	animlength = getanimlength( %o_zmb_chopper_slice_slow );
	_a462 = slice_times;
	_k462 = getFirstArrayKey( _a462 );
	while ( isDefined( _k462 ) )
	{
		frac = _a462[ _k462 ];
		level.headchopper_slice_times[ level.headchopper_slice_times.size ] = animlength * frac;
		_k462 = getNextArrayKey( _a462, _k462 );
	}
	_a467 = retract_times;
	_k467 = getFirstArrayKey( _a467 );
	while ( isDefined( _k467 ) )
	{
		frac = _a467[ _k467 ];
		level.headchopper_slice_times[ level.headchopper_slice_times.size ] = animlength * frac;
		_k467 = getNextArrayKey( _a467, _k467 );
	}
}

headchopper_animate( weapon, armed )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "equip_headchopper_zm_taken" );
	weapon endon( "death" );
	weapon useanimtree( -1 );
	f_animlength = getanimlength( %o_zmb_chopper_slice_fast );
	s_animlength = getanimlength( %o_zmb_chopper_slice_slow );
	weapon thread headchopper_audio();
	prearmed = 0;
	if ( isDefined( armed ) && armed )
	{
		prearmed = 1;
	}
	zombies_only = 0;
	while ( isDefined( weapon ) )
	{
		if ( !prearmed )
		{
			wait 0,1;
		}
		else
		{
			wait 0,05;
		}
		prearmed = 0;
		weapon.is_armed = 1;
		weapon waittill( "chop", zombies_only );
		if ( isDefined( weapon ) )
		{
			weapon.is_slicing = 1;
			if ( isDefined( zombies_only ) && zombies_only )
			{
				weapon thread watch_notetracks_slicing();
				weapon playsound( "zmb_headchopper_swing" );
				weapon setanim( %o_zmb_chopper_slice_slow );
				wait s_animlength;
				weapon clearanim( %o_zmb_chopper_slice_slow, 0,2 );
			}
			else
			{
				weapon setanim( %o_zmb_chopper_slice_fast );
				wait f_animlength;
				weapon clearanim( %o_zmb_chopper_slice_fast, 0,2 );
			}
			weapon notify( "end" );
			weapon.is_slicing = 0;
		}
	}
}

watch_notetracks_slicing()
{
	self endon( "death" );
	_a546 = level.headchopper_slice_times;
	_k546 = getFirstArrayKey( _a546 );
	while ( isDefined( _k546 ) )
	{
		time = _a546[ _k546 ];
		self thread watch_notetracks_slicing_times( time );
		_k546 = getNextArrayKey( _a546, _k546 );
	}
}

watch_notetracks_slicing_times( time )
{
	self endon( "death" );
	wait time;
	self notify( "slicing" );
}

playheadchopperresetaudio( time )
{
	self endon( "headchopperAudioCleanup" );
	ent = spawn( "script_origin", self.origin );
	ent playloopsound( "zmb_highrise_launcher_reset_loop" );
	self thread deleteentwhensounddone( time, ent );
	self waittill( "death" );
	ent delete();
}

deleteentwhensounddone( time, ent )
{
	self endon( "death" );
	wait time;
	self notify( "headchopperAudioCleanup" );
	ent delete();
}

headchopper_audio()
{
	loop_ent = spawn( "script_origin", self.origin );
	loop_ent playloopsound( "zmb_highrise_launcher_loop" );
	self waittill( "death" );
	loop_ent delete();
}

headchopper_fx( weapon )
{
	weapon endon( "death" );
	self endon( "equip_headchopper_zm_taken" );
	while ( isDefined( weapon ) )
	{
		playfxontag( level._effect[ "headchoppere_on" ], weapon, "tag_origin" );
		wait 1;
	}
}

headchopperthink( weapon, electricradius, armed )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "equip_headchopper_zm_taken" );
	weapon endon( "death" );
	radiussquared = electricradius * electricradius;
	traceposition = weapon getcentroid() + ( anglesToForward( flat_angle( weapon.angles ) ) * -15 );
	trace = bullettrace( traceposition, traceposition + vectorScale( ( 0, 0, 1 ), 48 ), 1, weapon );
	trigger_origin = weapon gettagorigin( "TAG_SAW" );
	trigger = spawn( "trigger_box", trigger_origin, 1, 8, 128, 64 );
	trigger.origin += anglesToUp( weapon.angles ) * 32;
	trigger.angles = weapon.angles;
	trigger enablelinkto();
	trigger linkto( weapon );
	weapon.trigger = trigger;
/#
	trigger.extent = ( 4, 64, 32 );
#/
	weapon thread headchopperthinkcleanup( trigger );
	direction_forward = anglesToForward( flat_angle( weapon.angles ) + vectorScale( ( 0, 0, 1 ), 60 ) );
	direction_vector = vectorScale( direction_forward, 1024 );
	direction_origin = weapon.origin + direction_vector;
	home_angles = weapon.angles;
	weapon.is_armed = 0;
	self thread headchopper_fx( weapon );
	self thread headchopper_animate( weapon, armed );
	while ( isDefined( weapon.is_armed ) && !weapon.is_armed )
	{
		wait 0,5;
	}
	weapon.chop_targets = [];
	self thread targeting_thread( weapon, trigger );
	while ( isDefined( weapon ) )
	{
		wait_for_targets( weapon );
		if ( isDefined( weapon.chop_targets ) && weapon.chop_targets.size > 0 )
		{
			is_slicing = 1;
			slice_count = 0;
			while ( isDefined( is_slicing ) && is_slicing )
			{
				weapon notify( "chop" );
				weapon.is_armed = 0;
				weapon.zombies_only = 1;
				_a680 = weapon.chop_targets;
				_k680 = getFirstArrayKey( _a680 );
				while ( isDefined( _k680 ) )
				{
					ent = _a680[ _k680 ];
					self thread headchopperattack( weapon, ent );
					_k680 = getNextArrayKey( _a680, _k680 );
				}
				if ( weapon.headchopper_kills >= 42 )
				{
					self thread headchopper_expired( weapon );
				}
				weapon.chop_targets = [];
				weapon waittill_any( "slicing", "end" );
				weapon notify( "slice_done" );
				slice_count++;
				is_slicing = weapon.is_slicing;
			}
			while ( isDefined( weapon.is_armed ) && !weapon.is_armed )
			{
				wait 0,5;
			}
		}
		else wait 0,1;
	}
}

headchopperattack( weapon, ent )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "equip_headchopper_zm_taken" );
	weapon endon( "death" );
	if ( !isDefined( ent ) || !isalive( ent ) )
	{
		return;
	}
	eye_position = ent geteye();
	head_position = eye_position[ 2 ] + 13;
	foot_position = ent.origin[ 2 ];
	length_head_to_toe = abs( head_position - foot_position );
	length_head_to_toe_25_percent = length_head_to_toe * 0,25;
	if ( weapon.origin[ 2 ] <= head_position )
	{
		is_headchop = weapon.origin[ 2 ] >= ( head_position - length_head_to_toe_25_percent );
	}
	if ( weapon.origin[ 2 ] <= ( head_position - length_head_to_toe_25_percent ) )
	{
		is_torsochop = weapon.origin[ 2 ] >= ( foot_position + length_head_to_toe_25_percent );
	}
	is_footchop = abs( foot_position - weapon.origin[ 2 ] ) <= length_head_to_toe_25_percent;
	trace_point = undefined;
	if ( isDefined( is_headchop ) && is_headchop )
	{
		trace_point = eye_position;
	}
	else
	{
		if ( isDefined( is_torsochop ) && is_torsochop )
		{
			trace_point = ent.origin + ( 0, 0, length_head_to_toe_25_percent * 2 );
		}
		else
		{
			trace_point = ent.origin + ( 0, 0, length_head_to_toe_25_percent );
		}
	}
	fwdangles = anglesToUp( weapon.angles );
	tracefwd = bullettrace( weapon.origin + ( fwdangles * 5 ), trace_point, 0, weapon, 1, 1 );
	if ( isDefined( tracefwd ) || !isDefined( tracefwd[ "position" ] ) && tracefwd[ "position" ] != trace_point )
	{
		return;
	}
	if ( isplayer( ent ) )
	{
		if ( isDefined( weapon.deployed_time ) && ( getTime() - weapon.deployed_time ) <= 2000 )
		{
			return;
		}
		if ( isDefined( is_headchop ) && is_headchop && !ent hasperk( "specialty_armorvest" ) )
		{
			ent dodamage( ent.health, weapon.origin );
		}
		else
		{
			if ( isDefined( is_torsochop ) && is_torsochop )
			{
				ent dodamage( 50, weapon.origin );
			}
			else
			{
				if ( isDefined( is_footchop ) && is_footchop )
				{
					ent dodamage( 25, weapon.origin );
				}
				else
				{
					ent dodamage( 10, weapon.origin );
				}
			}
		}
	}
	else if ( isDefined( is_headchop ) || !is_headchop && isDefined( is_headchop ) && !is_headchop && isDefined( ent.has_legs ) && !ent.has_legs )
	{
		headchop_height = 25;
		if ( isDefined( ent.has_legs ) && !ent.has_legs )
		{
			headchop_height = 35;
		}
		is_headchop = abs( eye_position[ 2 ] - weapon.origin[ 2 ] ) <= headchop_height;
	}
	if ( isDefined( is_headchop ) && is_headchop )
	{
		if ( isDefined( ent.no_gib ) && !ent.no_gib )
		{
			ent maps/mp/zombies/_zm_spawner::zombie_head_gib();
		}
		ent dodamage( ent.health + 666, weapon.origin );
		ent.headchopper_last_damage_time = getTime();
		ent playsound( "zmb_exp_jib_headchopper_zombie" );
		weapon.headchopper_kills++;
		self thread headchopper_kill_vo( ent );
	}
	else
	{
		if ( isDefined( is_torsochop ) && is_torsochop )
		{
			if ( ent.health <= 20 )
			{
				ent playsound( "zmb_exp_jib_headchopper_zombie" );
				weapon.headchopper_kills++;
				self thread headchopper_kill_vo( ent );
			}
			ent dodamage( 20, weapon.origin );
			ent.headchopper_last_damage_time = getTime();
			return;
		}
		else
		{
			if ( isDefined( is_footchop ) && is_footchop )
			{
				if ( isDefined( ent.no_gib ) && !ent.no_gib )
				{
					ent.a.gib_ref = "no_legs";
					ent thread maps/mp/animscripts/zm_death::do_gib();
					ent.has_legs = 0;
					ent allowedstances( "crouch" );
					ent setphysparams( 15, 0, 24 );
					ent allowpitchangle( 1 );
					ent setpitchorient();
					ent thread maps/mp/animscripts/zm_run::needsdelayedupdate();
					if ( isDefined( ent.crawl_anim_override ) )
					{
						ent [[ ent.crawl_anim_override ]]();
					}
				}
				if ( ent.health <= 10 )
				{
					ent playsound( "zmb_exp_jib_headchopper_zombie" );
					weapon.headchopper_kills++;
					self thread headchopper_kill_vo( ent );
				}
				ent dodamage( 10, weapon.origin );
				ent.headchopper_last_damage_time = getTime();
			}
		}
	}
}

headchopper_kill_vo( zombie )
{
	self endon( "disconnect" );
	if ( !isDefined( zombie ) )
	{
		return;
	}
	if ( distance2dsquared( self.origin, zombie.origin ) < 1000000 )
	{
		if ( self is_player_looking_at( zombie.origin, 0,25 ) )
		{
			self thread maps/mp/zombies/_zm_audio::create_and_play_dialog( "kill", "headchopper" );
		}
	}
}

wait_for_targets( weapon )
{
	weapon endon( "hi_priority_target" );
	while ( isDefined( weapon ) )
	{
		if ( isDefined( weapon.chop_targets ) && weapon.chop_targets.size > 0 )
		{
			wait 0,075;
			return;
		}
		wait 0,05;
	}
}

targeting_thread( weapon, trigger )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "equip_headchopper_zm_taken" );
	weapon endon( "death" );
	weapon.zombies_only = 1;
	while ( isDefined( weapon ) )
	{
		if ( weapon.is_armed || isDefined( weapon.is_slicing ) && weapon.is_slicing )
		{
			if ( isDefined( weapon.is_slicing ) && weapon.is_slicing )
			{
				weapon waittill( "slice_done" );
			}
			zombies = getaiarray( level.zombie_team );
			_a922 = zombies;
			_k922 = getFirstArrayKey( _a922 );
			while ( isDefined( _k922 ) )
			{
				zombie = _a922[ _k922 ];
				if ( !isDefined( zombie ) || !isalive( zombie ) )
				{
				}
				else
				{
					if ( isDefined( zombie.ignore_headchopper ) && zombie.ignore_headchopper )
					{
						break;
					}
					else
					{
						if ( zombie istouching( trigger ) )
						{
							weapon headchopper_add_chop_ent( zombie );
						}
					}
				}
				_k922 = getNextArrayKey( _a922, _k922 );
			}
			players = get_players();
			_a950 = players;
			_k950 = getFirstArrayKey( _a950 );
			while ( isDefined( _k950 ) )
			{
				player = _a950[ _k950 ];
				if ( is_player_valid( player ) && player istouching( trigger ) )
				{
					weapon headchopper_add_chop_ent( player );
					weapon.zombies_only = 0;
				}
				_k950 = getNextArrayKey( _a950, _k950 );
			}
			if ( !weapon.zombies_only )
			{
				weapon notify( "hi_priority_target" );
			}
		}
		wait 0,05;
	}
}

headchopper_add_chop_ent( ent )
{
	self.chop_targets = add_to_array( self.chop_targets, ent, 0 );
}

headchopper_expired( weapon, usedestroyfx )
{
	if ( !isDefined( usedestroyfx ) )
	{
		usedestroyfx = 1;
	}
	weapon maps/mp/zombies/_zm_equipment::dropped_equipment_destroy( usedestroyfx );
	self maps/mp/zombies/_zm_equipment::equipment_release( level.headchopper_name );
	self.headchopper_kills = 0;
}

headchopperthinkcleanup( trigger )
{
	self waittill( "death" );
	if ( isDefined( trigger ) )
	{
		trigger delete();
	}
}

destroyheadchopperonplantedblockeropen( trigger )
{
	self endon( "death" );
	home_origin = self.planted_on_ent.origin;
	home_angles = self.planted_on_ent.angles;
	while ( isDefined( self.planted_on_ent ) )
	{
		if ( self.planted_on_ent.origin != home_origin || self.planted_on_ent.angles != home_angles )
		{
			break;
		}
		else
		{
			wait 0,5;
		}
	}
	self.owner thread headchopper_expired( self, 0 );
}

destroyheadchopperonplantedentitydeath()
{
	self endon( "death" );
	self.planted_on_ent waittill( "death" );
	self.owner thread headchopper_expired( self, 0 );
}

destroyheadchopperstouching( usedestroyfx )
{
	headchoppers = self getheadchopperstouching();
	_a1031 = headchoppers;
	_k1031 = getFirstArrayKey( _a1031 );
	while ( isDefined( _k1031 ) )
	{
		headchopper = _a1031[ _k1031 ];
		headchopper.owner thread headchopper_expired( headchopper, usedestroyfx );
		_k1031 = getNextArrayKey( _a1031, _k1031 );
	}
}

getheadchopperstouching()
{
	headchoppers = [];
	players = get_players();
	_a1043 = players;
	_k1043 = getFirstArrayKey( _a1043 );
	while ( isDefined( _k1043 ) )
	{
		player = _a1043[ _k1043 ];
		if ( isDefined( player.buildableheadchopper ) )
		{
			chopper = player.buildableheadchopper;
			if ( isDefined( chopper.planted_on_ent ) && chopper.planted_on_ent == self )
			{
				headchoppers[ headchoppers.size ] = chopper;
				break;
			}
			else
			{
				if ( chopper istouching( self ) )
				{
					headchoppers[ headchoppers.size ] = chopper;
					break;
				}
				else if ( distance2dsquared( chopper.origin, self.origin ) > 16384 )
				{
					break;
				}
				else
				{
					fwdangles = anglesToUp( chopper.angles );
					traceback = groundtrace( chopper.origin + ( fwdangles * 5 ), chopper.origin - ( fwdangles * 999999 ), 0, chopper );
					if ( isDefined( traceback ) && isDefined( traceback[ "entity" ] ) && traceback[ "entity" ] == self )
					{
						headchoppers[ headchoppers.size ] = chopper;
					}
				}
			}
		}
		_k1043 = getNextArrayKey( _a1043, _k1043 );
	}
	return headchoppers;
}

getheadchoppersnear( source_origin, max_distance )
{
	if ( !isDefined( max_distance ) )
	{
		max_distance = 128;
	}
	headchoppers = [];
	players = get_players();
	_a1096 = players;
	_k1096 = getFirstArrayKey( _a1096 );
	while ( isDefined( _k1096 ) )
	{
		player = _a1096[ _k1096 ];
		if ( isDefined( player.buildableheadchopper ) )
		{
			chopper = player.buildableheadchopper;
			if ( distancesquared( chopper.origin, source_origin ) < ( max_distance * max_distance ) )
			{
				headchoppers[ headchoppers.size ] = chopper;
			}
		}
		_k1096 = getNextArrayKey( _a1096, _k1096 );
	}
	return headchoppers;
}

check_headchopper_in_bad_area( origin )
{
	if ( !isDefined( level.headchopper_bad_areas ) )
	{
		level.headchopper_bad_areas = getentarray( "headchopper_bad_area", "targetname" );
	}
	scr_org = spawn( "script_origin", origin );
	in_bad_area = 0;
	_a1122 = level.headchopper_bad_areas;
	_k1122 = getFirstArrayKey( _a1122 );
	while ( isDefined( _k1122 ) )
	{
		area = _a1122[ _k1122 ];
		if ( scr_org istouching( area ) )
		{
			in_bad_area = 1;
			break;
		}
		else
		{
			_k1122 = getNextArrayKey( _a1122, _k1122 );
		}
	}
	scr_org delete();
	return in_bad_area;
}

debugheadchopper( radius )
{
/#
	color_armed = ( 0, 0, 1 );
	color_unarmed = vectorScale( ( 0, 0, 1 ), 0,65 );
	while ( isDefined( self ) )
	{
		if ( getDvarInt( #"EB512CB7" ) )
		{
			if ( isDefined( self.trigger ) )
			{
				color = color_unarmed;
				if ( isDefined( self.is_armed ) && self.is_armed )
				{
					color = color_armed;
				}
				vec = self.trigger.extent;
				box( self.trigger.origin, vec * -1, vec, self.trigger.angles[ 1 ], color, 1, 0, 1 );
			}
			color = ( 0, 0, 1 );
			text = "";
			if ( isDefined( self.headchopper_kills ) )
			{
				text = "" + self.headchopper_kills + "";
			}
			else
			{
				if ( isDefined( self.owner.headchopper_kills ) )
				{
					text = "[ " + self.owner.headchopper_kills + " ]";
				}
			}
			print3d( self.origin + vectorScale( ( 0, 0, 1 ), 30 ), text, color, 1, 0,5, 1 );
		}
		wait 0,05;
#/
	}
}
