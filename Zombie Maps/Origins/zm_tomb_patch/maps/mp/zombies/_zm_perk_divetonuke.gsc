#include maps/mp/_visionset_mgr;
#include maps/mp/zombies/_zm_perks;
#include maps/mp/zombies/_zm_net;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;

enable_divetonuke_perk_for_level()
{
	maps/mp/zombies/_zm_perks::register_perk_basic_info( "specialty_flakjacket", "divetonuke", 2000, &"ZOMBIE_PERK_DIVETONUKE", "zombie_perk_bottle_nuke" );
	maps/mp/zombies/_zm_perks::register_perk_precache_func( "specialty_flakjacket", ::divetonuke_precache );
	maps/mp/zombies/_zm_perks::register_perk_clientfields( "specialty_flakjacket", ::divetonuke_register_clientfield, ::divetonuke_set_clientfield );
	maps/mp/zombies/_zm_perks::register_perk_machine( "specialty_flakjacket", ::divetonuke_perk_machine_setup, ::divetonuke_perk_machine_think );
	maps/mp/zombies/_zm_perks::register_perk_host_migration_func( "specialty_flakjacket", ::divetonuke_host_migration_func );
}

init_divetonuke()
{
	level.zombiemode_divetonuke_perk_func = ::divetonuke_explode;
	maps/mp/_visionset_mgr::vsmgr_register_info( "visionset", "zm_perk_divetonuke", 9000, 400, 5, 1 );
	level._effect[ "divetonuke_groundhit" ] = loadfx( "maps/zombie/fx_zmb_phdflopper_exp" );
	set_zombie_var( "zombie_perk_divetonuke_radius", 300 );
	set_zombie_var( "zombie_perk_divetonuke_min_damage", 1000 );
	set_zombie_var( "zombie_perk_divetonuke_max_damage", 5000 );
}

divetonuke_precache()
{
	if ( isDefined( level.divetonuke_precache_override_func ) )
	{
		[[ level.divetonuke_precache_override_func ]]();
		return;
	}
	precacheitem( "zombie_perk_bottle_nuke" );
	precacheshader( "specialty_divetonuke_zombies" );
	precachemodel( "zombie_vending_nuke" );
	precachemodel( "zombie_vending_nuke_on" );
	precachestring( &"ZOMBIE_PERK_DIVETONUKE" );
	level._effect[ "divetonuke_light" ] = loadfx( "misc/fx_zombie_cola_dtap_on" );
	level.machine_assets[ "divetonuke" ] = spawnstruct();
	level.machine_assets[ "divetonuke" ].weapon = "zombie_perk_bottle_nuke";
	level.machine_assets[ "divetonuke" ].off_model = "zombie_vending_nuke";
	level.machine_assets[ "divetonuke" ].on_model = "zombie_vending_nuke_on";
}

divetonuke_register_clientfield()
{
	registerclientfield( "toplayer", "perk_dive_to_nuke", 9000, 1, "int" );
}

divetonuke_set_clientfield( state )
{
	self setclientfieldtoplayer( "perk_dive_to_nuke", state );
}

divetonuke_perk_machine_setup( use_trigger, perk_machine, bump_trigger, collision )
{
	use_trigger.script_sound = "mus_perks_phd_jingle";
	use_trigger.script_string = "divetonuke_perk";
	use_trigger.script_label = "mus_perks_phd_sting";
	use_trigger.target = "vending_divetonuke";
	perk_machine.script_string = "divetonuke_perk";
	perk_machine.targetname = "vending_divetonuke";
	if ( isDefined( bump_trigger ) )
	{
		bump_trigger.script_string = "divetonuke_perk";
	}
}

divetonuke_perk_machine_think()
{
	init_divetonuke();
	while ( 1 )
	{
		machine = getentarray( "vending_divetonuke", "targetname" );
		machine_triggers = getentarray( "vending_divetonuke", "target" );
		i = 0;
		while ( i < machine.size )
		{
			machine[ i ] setmodel( level.machine_assets[ "divetonuke" ].off_model );
			i++;
		}
		array_thread( machine_triggers, ::set_power_on, 0 );
		level thread do_initial_power_off_callback( machine, "divetonuke" );
		level waittill( "divetonuke_on" );
		i = 0;
		while ( i < machine.size )
		{
			machine[ i ] setmodel( level.machine_assets[ "divetonuke" ].on_model );
			machine[ i ] vibrate( vectorScale( ( 0, -1, 0 ), 100 ), 0,3, 0,4, 3 );
			machine[ i ] playsound( "zmb_perks_power_on" );
			machine[ i ] thread perk_fx( "divetonuke_light" );
			machine[ i ] thread play_loop_on_machine();
			i++;
		}
		level notify( "specialty_flakjacket_power_on" );
		array_thread( machine_triggers, ::set_power_on, 1 );
		if ( isDefined( level.machine_assets[ "divetonuke" ].power_on_callback ) )
		{
			array_thread( machine, level.machine_assets[ "divetonuke" ].power_on_callback );
		}
		level waittill( "divetonuke_off" );
		if ( isDefined( level.machine_assets[ "divetonuke" ].power_off_callback ) )
		{
			array_thread( machine, level.machine_assets[ "divetonuke" ].power_off_callback );
		}
		array_thread( machine, ::turn_perk_off );
	}
}

divetonuke_host_migration_func()
{
	flop = getentarray( "vending_divetonuke", "targetname" );
	_a138 = flop;
	_k138 = getFirstArrayKey( _a138 );
	while ( isDefined( _k138 ) )
	{
		perk = _a138[ _k138 ];
		if ( isDefined( perk.model ) && perk.model == level.machine_assets[ "divetonuke" ].on_model )
		{
			perk perk_fx( undefined, 1 );
			perk thread perk_fx( "divetonuke_light" );
		}
		_k138 = getNextArrayKey( _a138, _k138 );
	}
}

divetonuke_explode( attacker, origin )
{
	radius = level.zombie_vars[ "zombie_perk_divetonuke_radius" ];
	min_damage = level.zombie_vars[ "zombie_perk_divetonuke_min_damage" ];
	max_damage = level.zombie_vars[ "zombie_perk_divetonuke_max_damage" ];
	if ( isDefined( level.flopper_network_optimized ) && level.flopper_network_optimized )
	{
		attacker thread divetonuke_explode_network_optimized( origin, radius, max_damage, min_damage, "MOD_GRENADE_SPLASH" );
	}
	else
	{
		radiusdamage( origin, radius, max_damage, min_damage, attacker, "MOD_GRENADE_SPLASH" );
	}
	playfx( level._effect[ "divetonuke_groundhit" ], origin );
	attacker playsound( "zmb_phdflop_explo" );
	maps/mp/_visionset_mgr::vsmgr_activate( "visionset", "zm_perk_divetonuke", attacker );
	wait 1;
	maps/mp/_visionset_mgr::vsmgr_deactivate( "visionset", "zm_perk_divetonuke", attacker );
}

divetonuke_explode_network_optimized( origin, radius, max_damage, min_damage, damage_mod )
{
	self endon( "disconnect" );
	a_zombies = get_array_of_closest( origin, get_round_enemy_array(), undefined, undefined, radius );
	network_stall_counter = 0;
	while ( isDefined( a_zombies ) )
	{
		i = 0;
		while ( i < a_zombies.size )
		{
			e_zombie = a_zombies[ i ];
			if ( !isDefined( e_zombie ) || !isalive( e_zombie ) )
			{
				i++;
				continue;
			}
			else
			{
				dist = distance( e_zombie.origin, origin );
				damage = min_damage + ( ( max_damage - min_damage ) * ( 1 - ( dist / radius ) ) );
				e_zombie dodamage( damage, e_zombie.origin, self, self, 0, damage_mod );
				network_stall_counter--;

				if ( network_stall_counter <= 0 )
				{
					wait_network_frame();
					network_stall_counter = randomintrange( 1, 3 );
				}
			}
			i++;
		}
	}
}
