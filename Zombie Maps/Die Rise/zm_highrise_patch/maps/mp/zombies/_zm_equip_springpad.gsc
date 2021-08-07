#include maps/mp/zombies/_zm_buildables;
#include maps/mp/zombies/_zm_power;
#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/zombies/_zm;
#include maps/mp/gametypes_zm/_weaponobjects;
#include maps/mp/zombies/_zm_equipment;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

#using_animtree( "zombie_springpad" );

init( pickupstring, howtostring )
{
	if ( !maps/mp/zombies/_zm_equipment::is_equipment_included( "equip_springpad_zm" ) )
	{
		return;
	}
	level.springpad_name = "equip_springpad_zm";
	init_animtree();
	maps/mp/zombies/_zm_equipment::register_equipment( "equip_springpad_zm", pickupstring, howtostring, "zom_hud_trample_steam_complete", "springpad", undefined, ::transferspringpad, ::dropspringpad, ::pickupspringpad, ::placespringpad );
	maps/mp/zombies/_zm_equipment::add_placeable_equipment( "equip_springpad_zm", "p6_anim_zm_buildable_view_tramplesteam" );
	level thread onplayerconnect();
	maps/mp/gametypes_zm/_weaponobjects::createretrievablehint( "equip_springpad", pickupstring );
	level._effect[ "springpade_on" ] = loadfx( "maps/zombie_highrise/fx_highrise_trmpl_steam_os" );
	if ( -1 )
	{
		setdvar( "player_useRadius_zm", 96 );
	}
	thread wait_init_damage();
}

wait_init_damage()
{
	while ( !isDefined( level.zombie_vars ) || !isDefined( level.zombie_vars[ "zombie_health_start" ] ) )
	{
		wait 1;
	}
	level.springpad_damage = maps/mp/zombies/_zm::ai_zombie_health( 50 );
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
		self thread watchspringpaduse();
	}
}

setupwatchers()
{
	self waittill( "weapon_watchers_created" );
	watcher = maps/mp/gametypes_zm/_weaponobjects::getweaponobjectwatcher( "equip_springpad" );
	watcher.onspawnretrievetriggers = ::maps/mp/zombies/_zm_equipment::equipment_onspawnretrievableweaponobject;
}

watchspringpaduse()
{
	self notify( "watchSpringPadUse" );
	self endon( "watchSpringPadUse" );
	self endon( "death" );
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "equipment_placed", weapon, weapname );
		if ( weapname == level.springpad_name )
		{
			self cleanupoldspringpad();
			self.buildablespringpad = weapon;
			self thread startspringpaddeploy( weapon );
		}
	}
}

cleanupoldspringpad()
{
	if ( isDefined( self.buildablespringpad ) )
	{
		if ( isDefined( self.buildablespringpad.stub ) )
		{
			thread maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( self.buildablespringpad.stub );
			self.buildablespringpad.stub = undefined;
		}
		self.buildablespringpad delete();
		self.springpad_kills = undefined;
	}
	if ( isDefined( level.springpad_sound_ent ) )
	{
		level.springpad_sound_ent delete();
		level.springpad_sound_ent = undefined;
	}
}

watchforcleanup()
{
	self notify( "springpad_cleanup" );
	self endon( "springpad_cleanup" );
	self waittill_any( "death", "disconnect", "equip_springpad_zm_taken", "equip_springpad_zm_pickup" );
	cleanupoldspringpad();
}

placespringpad( origin, angles )
{
	item = self maps/mp/zombies/_zm_equipment::placed_equipment_think( "p6_anim_zm_buildable_tramplesteam", "equip_springpad_zm", origin, angles, 96, -32 );
	if ( isDefined( item ) )
	{
		item.springpad_kills = self.springpad_kills;
		item.requires_pickup = 1;
		item.zombie_attack_callback = ::springpad_add_fling_ent;
	}
	self.springpad_kills = undefined;
	return item;
}

dropspringpad()
{
	item = self maps/mp/zombies/_zm_equipment::dropped_equipment_think( "p6_anim_zm_buildable_tramplesteam", "equip_springpad_zm", self.origin, self.angles, 96, -32 );
	if ( isDefined( item ) )
	{
		item.springpad_kills = self.springpad_kills;
		item.requires_pickup = 1;
	}
	self.springpad_kills = undefined;
	return item;
}

pickupspringpad( item )
{
	self.springpad_kills = item.springpad_kills;
	item.springpad_kills = undefined;
}

transferspringpad( fromplayer, toplayer )
{
	buildablespringpad = toplayer.buildablespringpad;
	toarmed = 0;
	if ( isDefined( buildablespringpad ) )
	{
		if ( isDefined( buildablespringpad.is_armed ) )
		{
			toarmed = buildablespringpad.is_armed;
		}
	}
	springpad_kills = toplayer.springpad_kills;
	fromarmed = 0;
	if ( isDefined( fromplayer.buildablespringpad ) )
	{
		if ( isDefined( fromplayer.buildablespringpad.is_armed ) )
		{
			fromarmed = fromplayer.buildablespringpad.is_armed;
		}
	}
	toplayer.buildablespringpad = fromplayer.buildablespringpad;
	toplayer.buildablespringpad.original_owner = toplayer;
	toplayer.buildablespringpad.owner = toplayer;
	toplayer notify( "equip_springpad_zm_taken" );
	toplayer.springpad_kills = fromplayer.springpad_kills;
	toplayer thread startspringpaddeploy( toplayer.buildablespringpad, fromarmed );
	fromplayer.buildablespringpad = buildablespringpad;
	fromplayer.springpad_kills = springpad_kills;
	fromplayer notify( "equip_springpad_zm_taken" );
	if ( isDefined( fromplayer.buildablespringpad ) )
	{
		fromplayer thread startspringpaddeploy( fromplayer.buildablespringpad, toarmed );
		fromplayer.buildablespringpad.original_owner = fromplayer;
		fromplayer.buildablespringpad.owner = fromplayer;
	}
	else
	{
		fromplayer maps/mp/zombies/_zm_equipment::equipment_release( "equip_springpad_zm" );
	}
}

springpad_in_range( delta, origin, radius )
{
	if ( distancesquared( self.target.origin, origin ) < ( radius * radius ) )
	{
		return 1;
	}
	return 0;
}

springpad_power_on( origin, radius )
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

springpad_power_off( origin, radius )
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

startspringpaddeploy( weapon, armed )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "equip_springpad_zm_taken" );
	self thread watchforcleanup();
	electricradius = 45;
	if ( isDefined( self.springpad_kills ) )
	{
		weapon.springpad_kills = self.springpad_kills;
		self.springpad_kills = undefined;
	}
	if ( !isDefined( weapon.springpad_kills ) )
	{
		weapon.springpad_kills = 0;
	}
	if ( isDefined( weapon ) )
	{
/#
		weapon thread debugspringpad( electricradius );
#/
		if ( isDefined( level.equipment_springpad_needs_power ) && level.equipment_springpad_needs_power )
		{
			weapon.power_on = 0;
			maps/mp/zombies/_zm_power::add_temp_powered_item( ::springpad_power_on, ::springpad_power_off, ::springpad_in_range, ::maps/mp/zombies/_zm_power::cost_high, 1, weapon.power_on, weapon );
		}
		else
		{
			weapon.power_on = 1;
		}
		if ( !weapon.power_on )
		{
			self iprintlnbold( &"ZOMBIE_NEED_LOCAL_POWER" );
		}
		self thread springpadthink( weapon, electricradius, armed );
		if ( isDefined( level.equipment_springpad_needs_power ) && !level.equipment_springpad_needs_power )
		{
		}
		self thread maps/mp/zombies/_zm_buildables::delete_on_disconnect( weapon );
		weapon waittill( "death" );
		if ( isDefined( level.springpad_sound_ent ) )
		{
			level.springpad_sound_ent playsound( "wpn_zmb_electrap_stop" );
			level.springpad_sound_ent delete();
			level.springpad_sound_ent = undefined;
		}
		self notify( "springpad_cleanup" );
	}
}

init_animtree()
{
	scriptmodelsuseanimtree( -1 );
}

springpad_animate( weapon, armed )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "equip_springpad_zm_taken" );
	weapon endon( "death" );
	weapon useanimtree( -1 );
	f_animlength = getanimlength( %o_zombie_buildable_tramplesteam_reset_zombie );
	r_animlength = getanimlength( %o_zombie_buildable_tramplesteam_reset );
	l_animlength = getanimlength( %o_zombie_buildable_tramplesteam_launch );
	weapon thread springpad_audio();
	prearmed = 0;
	if ( isDefined( armed ) && armed )
	{
		prearmed = 1;
	}
	fast_reset = 0;
	while ( isDefined( weapon ) )
	{
		if ( !prearmed )
		{
			if ( fast_reset )
			{
				weapon setanim( %o_zombie_buildable_tramplesteam_reset_zombie );
				weapon thread playspringpadresetaudio( f_animlength );
				wait f_animlength;
			}
			else
			{
				weapon setanim( %o_zombie_buildable_tramplesteam_reset );
				weapon thread playspringpadresetaudio( r_animlength );
				wait r_animlength;
			}
		}
		else
		{
			wait 0,05;
		}
		prearmed = 0;
		weapon notify( "armed" );
		fast_reset = 0;
		if ( isDefined( weapon ) )
		{
			weapon setanim( %o_zombie_buildable_tramplesteam_compressed_idle );
			weapon waittill( "fling", fast );
			fast_reset = fast;
		}
		if ( isDefined( weapon ) )
		{
			weapon setanim( %o_zombie_buildable_tramplesteam_launch );
			wait l_animlength;
		}
	}
}

playspringpadresetaudio( time )
{
	self endon( "springpadAudioCleanup" );
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
	self notify( "springpadAudioCleanup" );
	ent delete();
}

springpad_audio()
{
	loop_ent = spawn( "script_origin", self.origin );
	loop_ent playloopsound( "zmb_highrise_launcher_loop" );
	self waittill( "death" );
	loop_ent delete();
}

springpad_fx( weapon )
{
	weapon endon( "death" );
	self endon( "equip_springpad_zm_taken" );
	while ( isDefined( weapon ) )
	{
		playfxontag( level._effect[ "springpade_on" ], weapon, "tag_origin" );
		wait 1;
	}
}

springpadthink( weapon, electricradius, armed )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "equip_springpad_zm_taken" );
	weapon endon( "death" );
	radiussquared = electricradius * electricradius;
	trigger = spawn( "trigger_box", weapon getcentroid(), 1, 48, 48, 32 );
	trigger.origin += anglesToForward( flat_angle( weapon.angles ) ) * -15;
	trigger.angles = weapon.angles;
	trigger enablelinkto();
	trigger linkto( weapon );
	weapon.trigger = trigger;
/#
	trigger.extent = ( 24, 24, 16 );
#/
	weapon thread springpadthinkcleanup( trigger );
	direction_forward = anglesToForward( flat_angle( weapon.angles ) + vectorScale( ( 0, 0, 1 ), 60 ) );
	direction_vector = vectorScale( direction_forward, 1024 );
	direction_origin = weapon.origin + direction_vector;
	home_angles = weapon.angles;
	weapon.is_armed = 0;
	self thread springpad_fx( weapon );
	self thread springpad_animate( weapon, armed );
	weapon waittill( "armed" );
	weapon.is_armed = 1;
	weapon.fling_targets = [];
	self thread targeting_thread( weapon, trigger );
	while ( isDefined( weapon ) )
	{
		wait_for_targets( weapon );
		if ( isDefined( weapon.fling_targets ) && weapon.fling_targets.size > 0 )
		{
			weapon notify( "fling" );
			weapon.is_armed = 0;
			weapon.zombies_only = 1;
			_a520 = weapon.fling_targets;
			_k520 = getFirstArrayKey( _a520 );
			while ( isDefined( _k520 ) )
			{
				ent = _a520[ _k520 ];
				if ( isplayer( ent ) )
				{
					ent thread player_fling( weapon.origin + vectorScale( ( 0, 0, 1 ), 30 ), weapon.angles, direction_vector );
				}
				else
				{
					if ( isDefined( ent ) )
					{
						if ( !isDefined( self.num_zombies_flung ) )
						{
							self.num_zombies_flung = 0;
						}
						self.num_zombies_flung++;
						self notify( "zombie_flung" );
						if ( !isDefined( weapon.fling_scaler ) )
						{
							weapon.fling_scaler = 1;
						}
						if ( isDefined( weapon.direction_vec_override ) )
						{
							direction_vector = weapon.direction_vec_override;
						}
						ent dodamage( ent.health + 666, ent.origin );
						ent startragdoll();
						ent launchragdoll( ( direction_vector / 4 ) * weapon.fling_scaler );
						weapon.springpad_kills++;
					}
				}
				_k520 = getNextArrayKey( _a520, _k520 );
			}
			if ( weapon.springpad_kills >= 28 )
			{
				self thread springpad_expired( weapon );
			}
			weapon.fling_targets = [];
			weapon waittill( "armed" );
			weapon.is_armed = 1;
			continue;
		}
		else
		{
			wait 0,1;
		}
	}
}

wait_for_targets( weapon )
{
	weapon endon( "hi_priority_target" );
	while ( isDefined( weapon ) )
	{
		if ( isDefined( weapon.fling_targets ) && weapon.fling_targets.size > 0 )
		{
			wait 0,15;
			return;
		}
		wait 0,05;
	}
}

targeting_thread( weapon, trigger )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "equip_springpad_zm_taken" );
	weapon endon( "death" );
	weapon.zombies_only = 1;
	while ( isDefined( weapon ) )
	{
		if ( weapon.is_armed )
		{
			zombies = getaiarray( level.zombie_team );
			_a594 = zombies;
			_k594 = getFirstArrayKey( _a594 );
			while ( isDefined( _k594 ) )
			{
				zombie = _a594[ _k594 ];
				if ( !isDefined( zombie ) || !isalive( zombie ) )
				{
				}
				else
				{
					if ( isDefined( zombie.ignore_spring_pad ) && zombie.ignore_spring_pad )
					{
						break;
					}
					else
					{
						if ( zombie istouching( trigger ) )
						{
							weapon springpad_add_fling_ent( zombie );
						}
					}
				}
				_k594 = getNextArrayKey( _a594, _k594 );
			}
			players = get_players();
			_a622 = players;
			_k622 = getFirstArrayKey( _a622 );
			while ( isDefined( _k622 ) )
			{
				player = _a622[ _k622 ];
				if ( is_player_valid( player ) && player istouching( trigger ) )
				{
					weapon springpad_add_fling_ent( player );
					weapon.zombies_only = 0;
				}
				_k622 = getNextArrayKey( _a622, _k622 );
			}
			if ( !weapon.zombies_only )
			{
				weapon notify( "hi_priority_target" );
			}
		}
		wait 0,05;
	}
}

springpad_add_fling_ent( ent )
{
	self.fling_targets = add_to_array( self.fling_targets, ent, 0 );
}

springpad_expired( weapon )
{
	weapon maps/mp/zombies/_zm_equipment::dropped_equipment_destroy( 1 );
	self maps/mp/zombies/_zm_equipment::equipment_release( "equip_springpad_zm" );
	self.springpad_kills = 0;
}

player_fling( origin, angles, velocity )
{
	torigin = ( self.origin[ 0 ], self.origin[ 1 ], origin[ 2 ] );
	self setorigin( ( origin + torigin ) * 0,5 );
	wait_network_frame();
	self setvelocity( velocity );
}

springpadthinkcleanup( trigger )
{
	self waittill( "death" );
	if ( isDefined( trigger ) )
	{
		trigger delete();
	}
}

debugspringpad( radius )
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
			if ( isDefined( self.springpad_kills ) )
			{
				text = "" + self.springpad_kills + "";
			}
			else
			{
				if ( isDefined( self.owner.springpad_kills ) )
				{
					text = "[" + self.owner.springpad_kills + "]";
				}
			}
			print3d( self.origin + vectorScale( ( 0, 0, 1 ), 30 ), text, color, 1, 0,5, 1 );
		}
		wait 0,05;
#/
	}
}
