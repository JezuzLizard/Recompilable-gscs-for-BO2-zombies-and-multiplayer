#include maps/mp/zombies/_zm_powerups;
#include maps/mp/zombies/_zm_game_module;
#include maps/mp/zm_transit_bus;
#include maps/mp/zm_transit_utility;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

main()
{
	level.numroundssincelastambushround = 0;
	level.numbusstopssincelastambushround = 0;
	level.numambushrounds = 0;
	level.ambushpercentageperstop = 10;
	level.ambushpercentageperround = 25;
	flag_init( "ambush_round", 0 );
	flag_init( "ambush_safe_area_active", 0 );
	initambusheffects();
	thread ambushroundkeeper();
/#
	adddebugcommand( "devgui_cmd "Zombies:1/Bus:14/Ambush Round:6/Always:1" "zombie_devgui ambush_round always"\n" );
	adddebugcommand( "devgui_cmd "Zombies:1/Bus:14/Ambush Round:6/Never:2" "zombie_devgui ambush_round never"\n" );
#/
}

initambusheffects()
{
	level._effect[ "ambush_bus_fire" ] = loadfx( "env/fire/fx_fire_md" );
}

shouldstartambushround()
{
/#
	if ( level.ambushpercentageperstop == 100 )
	{
		return 1;
	}
	if ( getDvarInt( "zombie_cheat" ) == 2 )
	{
		return 0;
#/
	}
	if ( level.numbusstopssincelastambushround < 2 )
	{
	}
	randint = randomintrange( 0, 100 );
	percentchance = level.numbusstopssincelastambushround * level.ambushpercentageperstop;
	if ( randint < percentchance )
	{
	}
	percentchance = level.numroundssincelastambushround * level.ambushpercentageperround;
	if ( randint < percentchance )
	{
	}
	if ( maps/mp/zm_transit_bus::busgasempty() )
	{
		return 1;
	}
	return 0;
}

isambushroundactive()
{
	if ( flag_exists( "ambush_round" ) )
	{
		return flag( "ambush_round" );
	}
}

is_ambush_round_spawning_active()
{
	if ( flag_exists( "ambush_safe_area_active" ) )
	{
		return flag( "ambush_safe_area_active" );
	}
}

ambushstartround()
{
	flag_set( "ambush_round" );
	ambushroundthink();
}

ambushendround()
{
	level.the_bus.issafe = 1;
	maps/mp/zm_transit_bus::busgasadd( 60 );
	level.numbusstopssincelastambushround = 0;
	level.numroundssincelastambushround = 0;
	flag_clear( "ambush_round" );
}

cancelambushround()
{
	flag_clear( "ambush_round" );
	flag_clear( "ambush_safe_area_active" );
	maps/mp/zm_transit_utility::try_resume_zombie_spawning();
	bbprint( "zombie_events", "category %s type %s round %d", "DOG", "stop", level.round_number );
	level.the_bus notify( "ambush_round_fail_safe" );
}

ambushroundspawning()
{
	level.numambushrounds++;
	wait 6;
	level.the_bus.issafe = 0;
}

limitedambushspawn()
{
	if ( level.numambushrounds < 3 )
	{
		dogcount = level.dog_targets.size * 6;
	}
	else
	{
		dogcount = level.dog_targets.size * 8;
	}
	setupdogspawnlocs();
	level thread ambushroundspawnfailsafe( 20 );
	while ( get_current_zombie_count() > 0 )
	{
		wait 1;
	}
	level notify( "end_ambushWaitFunction" );
}

ambushroundthink()
{
	module = maps/mp/zombies/_zm_game_module::get_game_module( level.game_module_nml_index );
	if ( isDefined( module.hub_start_func ) )
	{
		level thread [[ module.hub_start_func ]]( "nml" );
		level notify( "game_mode_started" );
	}
	level thread ambushroundspawning();
	ambushwaitfunction();
	ambushendround();
}

ambushwaitfunction()
{
}

ambushpointfailsafe()
{
	level.the_bus endon( "ambush_point" );
	level.the_bus waittill( "reached_stop_point" );
	cancelambushround();
}

ambushroundspawnfailsafe( timer )
{
	ambushroundtimelimit = timer;
	currentambushtime = 0;
	while ( currentambushtime < ambushroundtimelimit )
	{
		if ( !flag( "ambush_round" ) )
		{
			return;
		}
		wait 1;
		currentambushtime++;
	}
	level notify( "end_ambushWaitFunction" );
	wait 5;
	dogs = getaispeciesarray( "all", "zombie_dog" );
	i = 0;
	while ( i < dogs.size )
	{
		if ( isDefined( dogs[ i ].marked_for_death ) && dogs[ i ].marked_for_death )
		{
			i++;
			continue;
		}
		else
		{
			if ( is_magic_bullet_shield_enabled( dogs[ i ] ) )
			{
				i++;
				continue;
			}
			else
			{
				dogs[ i ] dodamage( dogs[ i ].health + 666, dogs[ i ].origin );
			}
		}
		i++;
	}
}

ambushdoghealthincrease()
{
	switch( level.numambushrounds )
	{
		case 1:
			level.dog_health = 400;
			break;
		case 2:
			level.dog_health = 900;
			break;
		case 3:
			level.dog_health = 1300;
			break;
		case 4:
			level.dog_health = 1600;
			break;
		default:
			level.dog_health = 1600;
			break;
	}
}

ambushroundaftermath()
{
	power_up_origin = level.the_bus gettagorigin( "tag_body" );
	if ( isDefined( power_up_origin ) )
	{
		level thread maps/mp/zombies/_zm_powerups::specific_powerup_drop( "full_ammo", power_up_origin );
	}
}

ambushroundeffects()
{
	wait 2;
	level thread ambushlightningeffect( "tag_body" );
	wait 0,5;
	level thread ambushlightningeffect( "tag_wheel_back_left" );
	wait 0,5;
	level thread ambushlightningeffect( "tag_wheel_back_right" );
	wait 0,5;
	level thread ambushlightningeffect( "tag_wheel_front_left" );
	wait 0,5;
	level thread ambushlightningeffect( "tag_wheel_front_right" );
	wait 1,5;
	fxent0 = spawnandlinkfxtotag( level._effect[ "ambush_bus_fire" ], level.the_bus, "tag_body" );
	fxent1 = spawnandlinkfxtotag( level._effect[ "ambush_bus_fire" ], level.the_bus, "tag_wheel_back_left" );
	fxent2 = spawnandlinkfxtotag( level._effect[ "ambush_bus_fire" ], level.the_bus, "tag_wheel_back_right" );
	fxent3 = spawnandlinkfxtotag( level._effect[ "ambush_bus_fire" ], level.the_bus, "tag_wheel_front_left" );
	fxent4 = spawnandlinkfxtotag( level._effect[ "ambush_bus_fire" ], level.the_bus, "tag_wheel_front_right" );
	level waittill( "end_ambushWaitFunction" );
	fxent0 delete();
	fxent1 delete();
	fxent2 delete();
	fxent3 delete();
	fxent4 delete();
}

ambushlightningeffect( tag )
{
	fxentlighting = spawnandlinkfxtotag( level._effect[ "lightning_dog_spawn" ], level.the_bus, tag );
	wait 5;
	fxentlighting delete();
}

setupdogspawnlocs()
{
	level.enemy_dog_locations = [];
	currentzone = undefined;
	ambush_zones = getentarray( "ambush_volume", "script_noteworthy" );
	i = 0;
	while ( i < ambush_zones.size )
	{
		touching = 0;
		b = 0;
		while ( b < level.the_bus.bounds_origins.size && !touching )
		{
			bounds = level.the_bus.bounds_origins[ b ];
			touching = bounds istouching( ambush_zones[ i ] );
			b++;
		}
		if ( touching )
		{
			currentzone = ambush_zones[ i ];
			break;
		}
		else
		{
			i++;
		}
	}
/#
	assert( isDefined( currentzone ), "Bus needs to be in an ambush zone for an ambush round: " + level.the_bus.origin );
#/
	level.enemy_dog_locations = getstructarray( currentzone.target, "targetname" );
}

ambushroundkeeper()
{
	while ( 1 )
	{
		level waittill( "between_round_over" );
		level.numroundssincelastambushround++;
	}
}
