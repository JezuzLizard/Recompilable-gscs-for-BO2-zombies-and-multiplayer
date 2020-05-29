#include maps/mp/gametypes/_hostmigration;
#include maps/mp/_scoreevents;
#include maps/mp/_challenges;
#include maps/mp/gametypes/_damagefeedback;
#include maps/mp/gametypes/_globallogic_player;
#include maps/mp/gametypes/_weaponobjects;
#include maps/mp/killstreaks/_dogs;
#include maps/mp/gametypes/_spawning;
#include maps/mp/_heatseekingmissile;
#include maps/mp/gametypes/_tweakables;
#include maps/mp/killstreaks/_killstreaks;
#include maps/mp/killstreaks/_killstreakrules;
#include maps/mp/_treadfx;
#include maps/mp/killstreaks/_airsupport;
#include common_scripts/utility;
#include maps/mp/gametypes/_hud_util;
#include maps/mp/_utility;

#using_animtree( "mp_vehicles" );

precachehelicopter( model, type )
{
	if ( !isDefined( type ) )
	{
		type = "blackhawk";
	}
	precachemodel( model );
	level.vehicle_deathmodel[ model ] = model;
	precacheitem( "cobra_20mm_mp" );
	precacheitem( "cobra_20mm_comlink_mp" );
	precachestring( &"MP_DESTROYED_HELICOPTER" );
	precachestring( &"KILLSTREAK_DESTROYED_HELICOPTER_GUNNER" );
	level.cobra_missile_models = [];
	level.cobra_missile_models[ "cobra_Hellfire" ] = "projectile_hellfire_missile";
	precachemodel( level.cobra_missile_models[ "cobra_Hellfire" ] );
	level.heli_sound[ "hit" ] = "evt_helicopter_hit";
	level.heli_sound[ "hitsecondary" ] = "evt_helicopter_hit";
	level.heli_sound[ "damaged" ] = "null";
	level.heli_sound[ "spinloop" ] = "evt_helicopter_spin_loop";
	level.heli_sound[ "spinstart" ] = "evt_helicopter_spin_start";
	level.heli_sound[ "crash" ] = "evt_helicopter_midair_exp";
	level.heli_sound[ "missilefire" ] = "wpn_hellfire_fire_npc";
	maps/mp/_treadfx::preloadtreadfx( "helicopter_player_mp" );
	maps/mp/_treadfx::preloadtreadfx( "heli_ai_mp" );
	maps/mp/_treadfx::preloadtreadfx( "heli_player_gunner_mp" );
	maps/mp/_treadfx::preloadtreadfx( "heli_guard_mp" );
	maps/mp/_treadfx::preloadtreadfx( "heli_supplydrop_mp" );
}

usekillstreakhelicopter( hardpointtype )
{
	if ( self maps/mp/killstreaks/_killstreakrules::iskillstreakallowed( hardpointtype, self.team ) == 0 )
	{
		return 0;
	}
	if ( !isDefined( level.heli_paths ) || !level.heli_paths.size )
	{
		iprintlnbold( "Need to add helicopter paths to the level" );
		return 0;
	}
	if ( hardpointtype == "helicopter_comlink_mp" )
	{
		result = self selecthelicopterlocation( hardpointtype );
		if ( !isDefined( result ) || result == 0 )
		{
			return 0;
		}
	}
	destination = 0;
	missilesenabled = 0;
	if ( hardpointtype == "helicopter_x2_mp" )
	{
		missilesenabled = 1;
	}
/#
	assert( level.heli_paths.size > 0, "No non-primary helicopter paths found in map" );
#/
	random_path = randomint( level.heli_paths[ destination ].size );
	startnode = level.heli_paths[ destination ][ random_path ];
	protectlocation = undefined;
	armored = 0;
	if ( hardpointtype == "helicopter_comlink_mp" )
	{
		protectlocation = ( level.helilocation[ 0 ], level.helilocation[ 1 ], int( maps/mp/killstreaks/_airsupport::getminimumflyheight() ) );
		armored = 0;
		startnode = getvalidprotectlocationstart( random_path, protectlocation, destination );
	}
	killstreak_id = self maps/mp/killstreaks/_killstreakrules::killstreakstart( hardpointtype, self.team );
	if ( killstreak_id == -1 )
	{
		return 0;
	}
	self thread announcehelicopterinbound( hardpointtype );
	thread heli_think( self, startnode, self.team, missilesenabled, protectlocation, hardpointtype, armored, killstreak_id );
	return 1;
}

announcehelicopterinbound( hardpointtype )
{
	team = self.team;
	self maps/mp/killstreaks/_killstreaks::playkillstreakstartdialog( hardpointtype, team, 1 );
	level.globalkillstreakscalled++;
	self addweaponstat( hardpointtype, "used", 1 );
}

heli_path_graph()
{
	path_start = getentarray( "heli_start", "targetname" );
	path_dest = getentarray( "heli_dest", "targetname" );
	loop_start = getentarray( "heli_loop_start", "targetname" );
	gunner_loop_start = getentarray( "heli_gunner_loop_start", "targetname" );
	leave_nodes = getentarray( "heli_leave", "targetname" );
	crash_start = getentarray( "heli_crash_start", "targetname" );
/#
	if ( isDefined( path_start ) )
	{
		assert( isDefined( path_dest ), "Missing path_start or path_dest" );
	}
#/
	i = 0;
	while ( i < path_dest.size )
	{
		startnode_array = [];
		isprimarydest = 0;
		destnode_pointer = path_dest[ i ];
		destnode = getent( destnode_pointer.target, "targetname" );
		j = 0;
		while ( j < path_start.size )
		{
			todest = 0;
			currentnode = path_start[ j ];
			while ( isDefined( currentnode.target ) )
			{
				nextnode = getent( currentnode.target, "targetname" );
				if ( nextnode.origin == destnode.origin )
				{
					todest = 1;
					break;
				}
				else
				{
					debug_print3d_simple( "+", currentnode, vectorScale( ( 1, 1, 1 ), 10 ) );
					if ( isDefined( nextnode.target ) )
					{
						debug_line( nextnode.origin, getent( nextnode.target, "targetname" ).origin, ( 0,25, 0,5, 0,25 ), 5 );
					}
					if ( isDefined( currentnode.script_delay ) )
					{
						debug_print3d_simple( "Wait: " + currentnode.script_delay, currentnode, vectorScale( ( 1, 1, 1 ), 10 ) );
					}
					currentnode = nextnode;
				}
			}
			if ( todest )
			{
				startnode_array[ startnode_array.size ] = getent( path_start[ j ].target, "targetname" );
				if ( isDefined( path_start[ j ].script_noteworthy ) && path_start[ j ].script_noteworthy == "primary" )
				{
					isprimarydest = 1;
				}
			}
			j++;
		}
/#
		if ( isDefined( startnode_array ) )
		{
			assert( startnode_array.size > 0, "No path(s) to destination" );
		}
#/
		if ( isprimarydest )
		{
			level.heli_primary_path = startnode_array;
			i++;
			continue;
		}
		else
		{
			level.heli_paths[ level.heli_paths.size ] = startnode_array;
		}
		i++;
	}
	i = 0;
	while ( i < loop_start.size )
	{
		startnode = getent( loop_start[ i ].target, "targetname" );
		level.heli_loop_paths[ level.heli_loop_paths.size ] = startnode;
		i++;
	}
/#
	assert( isDefined( level.heli_loop_paths[ 0 ] ), "No helicopter loop paths found in map" );
#/
	i = 0;
	while ( i < gunner_loop_start.size )
	{
		startnode = getent( gunner_loop_start[ i ].target, "targetname" );
		startnode.isgunnerpath = 1;
		level.heli_loop_paths[ level.heli_loop_paths.size ] = startnode;
		i++;
	}
	i = 0;
	while ( i < leave_nodes.size )
	{
		level.heli_leavenodes[ level.heli_leavenodes.size ] = leave_nodes[ i ];
		i++;
	}
/#
	assert( isDefined( level.heli_leavenodes[ 0 ] ), "No helicopter leave nodes found in map" );
#/
	i = 0;
	while ( i < crash_start.size )
	{
		crash_start_node = getent( crash_start[ i ].target, "targetname" );
		level.heli_crash_paths[ level.heli_crash_paths.size ] = crash_start_node;
		i++;
	}
/#
	assert( isDefined( level.heli_crash_paths[ 0 ] ), "No helicopter crash paths found in map" );
#/
}

init()
{
	path_start = getentarray( "heli_start", "targetname" );
	loop_start = getentarray( "heli_loop_start", "targetname" );
	thread heli_update_global_dvars();
	level.chaff_offset[ "attack" ] = ( -130, 0, -140 );
	level.choppercomlinkfriendly = "veh_t6_air_attack_heli_mp_light";
	level.choppercomlinkenemy = "veh_t6_air_attack_heli_mp_dark";
	level.chopperregular = "veh_t6_air_attack_heli_mp_dark";
	precachehelicopter( level.chopperregular );
	precachehelicopter( level.choppercomlinkfriendly );
	precachehelicopter( level.choppercomlinkenemy );
	precachevehicle( "heli_ai_mp" );
	registerclientfield( "helicopter", "heli_comlink_bootup_anim", 1, 1, "int" );
	level.heli_paths = [];
	level.heli_loop_paths = [];
	level.heli_leavenodes = [];
	level.heli_crash_paths = [];
	level.chopper_fx[ "explode" ][ "death" ] = loadfx( "vehicle/vexplosion/fx_vexplode_helicopter_exp_mp" );
	level.chopper_fx[ "explode" ][ "guard" ] = loadfx( "vehicle/vexplosion/fx_vexplode_heli_sm_exp_mp" );
	level.chopper_fx[ "explode" ][ "gunner" ] = loadfx( "vehicle/vexplosion/fx_vexplode_vtol_mp" );
	level.chopper_fx[ "explode" ][ "large" ] = loadfx( "vehicle/vexplosion/fx_vexplode_heli_killstreak_exp_sm" );
	level.chopper_fx[ "damage" ][ "light_smoke" ] = loadfx( "trail/fx_trail_heli_killstreak_engine_smoke_33" );
	level.chopper_fx[ "damage" ][ "heavy_smoke" ] = loadfx( "trail/fx_trail_heli_killstreak_engine_smoke_66" );
	level.chopper_fx[ "smoke" ][ "trail" ] = loadfx( "trail/fx_trail_heli_killstreak_tail_smoke" );
	level.chopper_fx[ "fire" ][ "trail" ][ "large" ] = loadfx( "trail/fx_trail_heli_killstreak_engine_smoke" );
	level._effect[ "heli_comlink_light" ][ "friendly" ] = loadfx( "light/fx_vlight_mp_attack_heli_grn" );
	level._effect[ "heli_comlink_light" ][ "enemy" ] = loadfx( "light/fx_vlight_mp_attack_heli_red" );
	level.helicomlinkbootupanim = %veh_anim_future_heli_gearup_bay_open;
	if ( !path_start.size && !loop_start.size )
	{
		return;
	}
	heli_path_graph();
	precachelocationselector( "compass_objpoint_helicopter" );
	if ( maps/mp/gametypes/_tweakables::gettweakablevalue( "killstreak", "allowhelicopter_comlink" ) )
	{
		maps/mp/killstreaks/_killstreaks::registerkillstreak( "helicopter_comlink_mp", "helicopter_comlink_mp", "killstreak_helicopter_comlink", "helicopter_used", ::usekillstreakhelicopter, 1 );
		maps/mp/killstreaks/_killstreaks::registerkillstreakstrings( "helicopter_comlink_mp", &"KILLSTREAK_EARNED_HELICOPTER_COMLINK", &"KILLSTREAK_HELICOPTER_COMLINK_NOT_AVAILABLE", &"KILLSTREAK_HELICOPTER_COMLINK_INBOUND" );
		maps/mp/killstreaks/_killstreaks::registerkillstreakdialog( "helicopter_comlink_mp", "mpl_killstreak_heli", "kls_cobra_used", "", "kls_cobra_enemy", "", "kls_cobra_ready" );
		maps/mp/killstreaks/_killstreaks::registerkillstreakdevdvar( "helicopter_comlink_mp", "scr_givehelicopter_comlink" );
		maps/mp/killstreaks/_killstreaks::registerkillstreakaltweapon( "helicopter_comlink_mp", "cobra_20mm_comlink_mp" );
		maps/mp/killstreaks/_killstreaks::setkillstreakteamkillpenaltyscale( "helicopter_comlink_mp", 0 );
	}
}

heli_update_global_dvars()
{
	for ( ;; )
	{
		level.heli_loopmax = heli_get_dvar_int( "scr_heli_loopmax", "2" );
		level.heli_missile_rof = heli_get_dvar_int( "scr_heli_missile_rof", "2" );
		level.heli_armor = heli_get_dvar_int( "scr_heli_armor", "500" );
		level.heli_maxhealth = heli_get_dvar_int( "scr_heli_maxhealth", "1000" );
		level.heli_amored_maxhealth = heli_get_dvar_int( "scr_heli_armored_maxhealth", "1500" );
		level.heli_missile_max = heli_get_dvar_int( "scr_heli_missile_max", "20" );
		level.heli_dest_wait = heli_get_dvar_int( "scr_heli_dest_wait", "8" );
		level.heli_debug = heli_get_dvar_int( "scr_heli_debug", "0" );
		level.heli_debug_crash = heli_get_dvar_int( "scr_heli_debug_crash", "0" );
		level.heli_targeting_delay = heli_get_dvar( "scr_heli_targeting_delay", "0.6" );
		level.heli_turretreloadtime = heli_get_dvar( "scr_heli_turretReloadTime", "1.5" );
		level.heli_turretclipsize = heli_get_dvar_int( "scr_heli_turretClipSize", "20" );
		level.heli_visual_range = heli_get_dvar_int( "scr_heli_visual_range", "3500" );
		level.heli_missile_range = heli_get_dvar_int( "scr_heli_missile_range", "100000" );
		level.heli_health_degrade = heli_get_dvar_int( "scr_heli_health_degrade", "0" );
		level.heli_turret_angle_tan = heli_get_dvar_int( "scr_heli_turret_angle_tan", "1" );
		level.heli_turret_target_cone = heli_get_dvar( "scr_heli_turret_target_cone", "0.6" );
		level.heli_target_spawnprotection = heli_get_dvar_int( "scr_heli_target_spawnprotection", "5" );
		level.heli_missile_regen_time = heli_get_dvar( "scr_heli_missile_regen_time", "10" );
		level.heli_turret_spinup_delay = heli_get_dvar( "scr_heli_turret_spinup_delay", "0.7" );
		level.heli_target_recognition = heli_get_dvar( "scr_heli_target_recognition", "0.5" );
		level.heli_missile_friendlycare = heli_get_dvar_int( "scr_heli_missile_friendlycare", "512" );
		level.heli_missile_target_cone = heli_get_dvar( "scr_heli_missile_target_cone", "0.6" );
		level.heli_valid_target_cone = heli_get_dvar( "scr_heli_missile_valid_target_cone", "0.7" );
		level.heli_armor_bulletdamage = heli_get_dvar( "scr_heli_armor_bulletdamage", "0.5" );
		level.heli_attract_strength = heli_get_dvar( "scr_heli_attract_strength", "1000" );
		level.heli_attract_range = heli_get_dvar( "scr_heli_attract_range", "20000" );
		level.helicopterturretmaxangle = heli_get_dvar_int( "scr_helicopterTurretMaxAngle", "35" );
		level.heli_protect_time = heli_get_dvar( "scr_heli_protect_time", "60" );
		level.heli_protect_pos_time = heli_get_dvar( "scr_heli_protect_pos_time", "12" );
		level.heli_protect_radius = heli_get_dvar_int( "scr_heli_protect_radius", "2000" );
		level.heli_missile_reload_time = heli_get_dvar( "scr_heli_missile_reload_time", "5.0" );
		level.heli_warning_distance = heli_get_dvar_int( "scr_heli_warning_distance", "500" );
		wait 1;
	}
}

heli_get_dvar_int( dvar, def )
{
	return int( heli_get_dvar( dvar, def ) );
}

heli_get_dvar( dvar, def )
{
	if ( getDvar( dvar ) != "" )
	{
		return getDvarFloat( dvar );
	}
	else
	{
		setdvar( dvar, def );
		return def;
	}
}

spawn_helicopter( owner, origin, angles, model, targetname, target_offset, hardpointtype, killstreak_id )
{
	chopper = spawnhelicopter( owner, origin, angles, model, targetname );
	chopper.attackers = [];
	chopper.attackerdata = [];
	chopper.attackerdamage = [];
	chopper.flareattackerdamage = [];
	chopper.destroyfunc = ::destroyhelicopter;
	chopper.hardpointtype = hardpointtype;
	chopper.killstreak_id = killstreak_id;
	chopper.pilotistalking = 0;
	chopper setdrawinfrared( 1 );
	if ( !isDefined( target_offset ) )
	{
		target_offset = ( 1, 1, 1 );
	}
	target_set( chopper, target_offset );
	chopper.pilotvoicenumber = self.bcvoicenumber - 1;
	if ( chopper.pilotvoicenumber < 0 )
	{
		chopper.pilotvoicenumber = 3;
	}
	owner.pilottalking = 0;
	if ( hardpointtype == "helicopter_player_gunner_mp" )
	{
		chopper thread playpilotdialog( "a10_used", 2,5 );
	}
	else
	{
		chopper thread playpilotdialog( "attackheli_approach", 2,5 );
	}
	chopper.soundmod = "heli";
	return chopper;
}

explodeoncontact( hardpointtype )
{
	self endon( "death" );
	wait 10;
	for ( ;; )
	{
		self waittill( "touch" );
		self thread heli_explode();
	}
}

getvalidprotectlocationstart( random_path, protectlocation, destination )
{
	startnode = level.heli_paths[ destination ][ random_path ];
	path_index = ( random_path + 1 ) % level.heli_paths[ destination ].size;
	innofly = crossesnoflyzone( protectlocation + ( 1, 1, 1 ), protectlocation );
	if ( isDefined( innofly ) )
	{
		protectlocation = ( protectlocation[ 0 ], protectlocation[ 1 ], level.noflyzones[ innofly ].origin[ 2 ] + level.noflyzones[ innofly ].height );
	}
	noflyzone = crossesnoflyzone( startnode.origin, protectlocation );
	while ( isDefined( noflyzone ) && path_index != random_path )
	{
		startnode = level.heli_paths[ destination ][ path_index ];
		noflyzone = crossesnoflyzone( startnode.origin, protectlocation );
		if ( isDefined( noflyzone ) )
		{
			path_index = ( path_index + 1 ) % level.heli_paths[ destination ].size;
		}
	}
	return level.heli_paths[ destination ][ path_index ];
}

getvalidrandomleavenode( start )
{
	random_leave_node = randomint( level.heli_leavenodes.size );
	leavenode = level.heli_leavenodes[ random_leave_node ];
	path_index = ( random_leave_node + 1 ) % level.heli_leavenodes.size;
	noflyzone = crossesnoflyzone( leavenode.origin, start );
	while ( isDefined( noflyzone ) && path_index != random_leave_node )
	{
		leavenode = level.heli_leavenodes[ path_index ];
		noflyzone = crossesnoflyzone( leavenode.origin, start );
		path_index = ( path_index + 1 ) % level.heli_leavenodes.size;
	}
	return level.heli_leavenodes[ path_index ];
}

getvalidrandomcrashnode( start )
{
	random_leave_node = randomint( level.heli_crash_paths.size );
	leavenode = level.heli_crash_paths[ random_leave_node ];
	path_index = ( random_leave_node + 1 ) % level.heli_crash_paths.size;
	noflyzone = crossesnoflyzone( leavenode.origin, start );
	while ( isDefined( noflyzone ) && path_index != random_leave_node )
	{
		leavenode = level.heli_crash_paths[ path_index ];
		noflyzone = crossesnoflyzone( leavenode.origin, start );
		path_index = ( path_index + 1 ) % level.heli_crash_paths.size;
	}
	return level.heli_crash_paths[ path_index ];
}

heli_think( owner, startnode, heli_team, missilesenabled, protectlocation, hardpointtype, armored, killstreak_id )
{
	heliorigin = startnode.origin;
	heliangles = startnode.angles;
	if ( hardpointtype == "helicopter_comlink_mp" )
	{
		choppermodelfriendly = level.choppercomlinkfriendly;
		choppermodelenemy = level.choppercomlinkenemy;
	}
	else
	{
		choppermodelfriendly = level.chopperregular;
		choppermodelenemy = level.chopperregular;
	}
	chopper = spawn_helicopter( owner, heliorigin, heliangles, "heli_ai_mp", choppermodelfriendly, vectorScale( ( 1, 1, 1 ), 100 ), hardpointtype, killstreak_id );
	chopper setenemymodel( choppermodelenemy );
	chopper thread watchforearlyleave( hardpointtype );
	target_setturretaquire( chopper, 0 );
	chopper thread samturretwatcher();
	if ( hardpointtype == "helicopter_comlink_mp" )
	{
		chopper.defaultweapon = "cobra_20mm_comlink_mp";
	}
	else
	{
		chopper.defaultweapon = "cobra_20mm_mp";
	}
	chopper.requireddeathcount = owner.deathcount;
	chopper.chaff_offset = level.chaff_offset[ "attack" ];
	minigun_snd_ent = spawn( "script_origin", chopper gettagorigin( "tag_flash" ) );
	minigun_snd_ent linkto( chopper, "tag_flash", ( 1, 1, 1 ), ( 1, 1, 1 ) );
	chopper.minigun_snd_ent = minigun_snd_ent;
	minigun_snd_ent thread autostopsound();
	chopper.team = heli_team;
	chopper setteam( heli_team );
	chopper.owner = owner;
	chopper setowner( owner );
	chopper thread heli_existance();
	level.chopper = chopper;
	chopper.reached_dest = 0;
	if ( armored )
	{
		chopper.maxhealth = level.heli_amored_maxhealth;
	}
	else
	{
		chopper.maxhealth = level.heli_maxhealth;
	}
	chopper.rocketdamageoneshot = level.heli_maxhealth + 1;
	chopper.rocketdamagetwoshot = ( level.heli_maxhealth / 2 ) + 1;
	if ( hardpointtype == "helicopter_comlink_mp" || hardpointtype == "helicopter_guard_mp" )
	{
		chopper.numflares = 1;
	}
	else
	{
		chopper.numflares = 2;
	}
	chopper.flareoffset = vectorScale( ( 1, 1, 1 ), 256 );
	chopper.waittime = level.heli_dest_wait;
	chopper.loopcount = 0;
	chopper.evasive = 0;
	chopper.health_bulletdamageble = level.heli_armor;
	chopper.health_evasive = level.heli_armor;
	chopper.health_low = chopper.maxhealth * 0,8;
	chopper.targeting_delay = level.heli_targeting_delay;
	chopper.primarytarget = undefined;
	chopper.secondarytarget = undefined;
	chopper.attacker = undefined;
	chopper.missile_ammo = level.heli_missile_max;
	chopper.currentstate = "ok";
	chopper.lastrocketfiretime = -1;
	if ( isDefined( protectlocation ) )
	{
		chopper thread heli_protect( startnode, protectlocation, hardpointtype, heli_team );
		chopper setclientfield( "heli_comlink_bootup_anim", 1 );
	}
	else
	{
		chopper thread heli_fly( startnode, 2, hardpointtype );
	}
	chopper thread heli_damage_monitor( hardpointtype );
	chopper thread heli_kill_monitor( hardpointtype );
	chopper thread heli_health( hardpointtype, owner );
	chopper thread attack_targets( missilesenabled, hardpointtype );
	chopper thread heli_targeting( missilesenabled, hardpointtype );
	chopper thread heli_missile_regen();
	chopper thread maps/mp/_heatseekingmissile::missiletarget_proximitydetonateincomingmissile( "crashing", "death" );
	chopper thread create_flare_ent( vectorScale( ( 1, 1, 1 ), 100 ) );
	chopper maps/mp/gametypes/_spawning::create_helicopter_influencers( heli_team );
}

autostopsound()
{
	self endon( "death" );
	level waittill( "game_ended" );
	self stoploopsound();
}

heli_existance()
{
	self waittill( "leaving" );
	self maps/mp/gametypes/_spawning::remove_helicopter_influencers();
}

create_flare_ent( offset )
{
	self.flare_ent = spawn( "script_model", self gettagorigin( "tag_origin" ) );
	self.flare_ent setmodel( "tag_origin" );
	self.flare_ent linkto( self, "tag_origin", offset );
}

heli_missile_regen()
{
	self endon( "death" );
	self endon( "crashing" );
	self endon( "leaving" );
	for ( ;; )
	{
		debug_print3d( "Missile Ammo: " + self.missile_ammo, ( 0,5, 0,5, 1 ), self, vectorScale( ( 1, 1, 1 ), 100 ), 0 );
		if ( self.missile_ammo >= level.heli_missile_max )
		{
			self waittill( "missile fired" );
		}
		else if ( self.currentstate == "heavy smoke" )
		{
			wait ( level.heli_missile_regen_time / 4 );
		}
		else if ( self.currentstate == "light smoke" )
		{
			wait ( level.heli_missile_regen_time / 2 );
		}
		else
		{
			wait level.heli_missile_regen_time;
		}
		if ( self.missile_ammo < level.heli_missile_max )
		{
			self.missile_ammo++;
		}
	}
}

heli_targeting( missilesenabled, hardpointtype )
{
	self endon( "death" );
	self endon( "crashing" );
	self endon( "leaving" );
	for ( ;; )
	{
		targets = [];
		targetsmissile = [];
		players = level.players;
		i = 0;
		while ( i < players.size )
		{
			player = players[ i ];
			if ( self cantargetplayer_turret( player, hardpointtype ) )
			{
				if ( isDefined( player ) )
				{
					targets[ targets.size ] = player;
				}
			}
			if ( missilesenabled && self cantargetplayer_missile( player, hardpointtype ) )
			{
				if ( isDefined( player ) )
				{
					targetsmissile[ targetsmissile.size ] = player;
				}
				i++;
				continue;
			}
			else
			{
			}
			i++;
		}
		dogs = maps/mp/killstreaks/_dogs::dog_manager_get_dogs();
		_a656 = dogs;
		_k656 = getFirstArrayKey( _a656 );
		while ( isDefined( _k656 ) )
		{
			dog = _a656[ _k656 ];
			if ( self cantargetdog_turret( dog ) )
			{
				targets[ targets.size ] = dog;
			}
			if ( missilesenabled && self cantargetdog_missile( dog ) )
			{
				targetsmissile[ targetsmissile.size ] = dog;
			}
			_k656 = getNextArrayKey( _a656, _k656 );
		}
		tanks = getentarray( "talon", "targetname" );
		_a670 = tanks;
		_k670 = getFirstArrayKey( _a670 );
		while ( isDefined( _k670 ) )
		{
			tank = _a670[ _k670 ];
			if ( self cantargettank_turret( tank ) )
			{
				targets[ targets.size ] = tank;
			}
			_k670 = getNextArrayKey( _a670, _k670 );
		}
		if ( targets.size == 0 && targetsmissile.size == 0 )
		{
			self.primarytarget = undefined;
			self.secondarytarget = undefined;
			debug_print_target();
			self setgoalyaw( randomint( 360 ) );
			wait self.targeting_delay;
			continue;
		}
		else if ( targets.size == 1 )
		{
			if ( isDefined( targets[ 0 ].type ) || targets[ 0 ].type == "dog" && targets[ 0 ].type == "tank_drone" )
			{
				update_dog_threat( targets[ 0 ] );
			}
			else
			{
				update_player_threat( targets[ 0 ] );
			}
			self.primarytarget = targets[ 0 ];
			self notify( "primary acquired" );
			self.secondarytarget = undefined;
			debug_print_target();
		}
		else
		{
			if ( targets.size > 1 )
			{
				assignprimarytargets( targets );
			}
		}
		if ( targetsmissile.size == 1 )
		{
			if ( isDefined( targetsmissile[ 0 ].type ) || targetsmissile[ 0 ].type != "dog" && targets[ 0 ].type == "tank_drone" )
			{
				self update_missile_player_threat( targetsmissile[ 0 ] );
			}
			else
			{
				if ( targetsmissile[ 0 ].type == "dog" )
				{
					self update_missile_dog_threat( targetsmissile[ 0 ] );
				}
			}
			self.secondarytarget = targetsmissile[ 0 ];
			self notify( "secondary acquired" );
			debug_print_target();
		}
		else
		{
			if ( targetsmissile.size > 1 )
			{
				assignsecondarytargets( targetsmissile );
			}
		}
		wait self.targeting_delay;
		debug_print_target();
	}
}

cantargetplayer_turret( player, hardpointtype )
{
	cantarget = 1;
	if ( !isalive( player ) || player.sessionstate != "playing" )
	{
		return 0;
	}
	if ( player == self.owner )
	{
		self check_owner( hardpointtype );
		return 0;
	}
	if ( player cantargetplayerwithspecialty() == 0 )
	{
		return 0;
	}
	if ( distance( player.origin, self.origin ) > level.heli_visual_range )
	{
		return 0;
	}
	if ( !isDefined( player.team ) )
	{
		return 0;
	}
	if ( level.teambased && player.team == self.team )
	{
		return 0;
	}
	if ( player.team == "spectator" )
	{
		return 0;
	}
	if ( isDefined( player.spawntime ) && ( ( getTime() - player.spawntime ) / 1000 ) <= level.heli_target_spawnprotection )
	{
		return 0;
	}
	heli_centroid = self.origin + vectorScale( ( 1, 1, 1 ), 160 );
	heli_forward_norm = anglesToForward( self.angles );
	heli_turret_point = heli_centroid + ( 144 * heli_forward_norm );
	visible_amount = player sightconetrace( heli_turret_point, self );
	if ( visible_amount < level.heli_target_recognition )
	{
		return 0;
	}
	return cantarget;
}

getverticaltan( startorigin, endorigin )
{
	vector = endorigin - startorigin;
	opposite = startorigin[ 2 ] - endorigin[ 2 ];
	if ( opposite < 0 )
	{
		opposite *= 1;
	}
	adjacent = distance2d( startorigin, endorigin );
	if ( adjacent < 0 )
	{
		adjacent *= 1;
	}
	if ( adjacent < 0,01 )
	{
		adjacent = 0,01;
	}
	tangent = opposite / adjacent;
	return tangent;
}

cantargetplayer_missile( player, hardpointtype )
{
	cantarget = 1;
	if ( !isalive( player ) || player.sessionstate != "playing" )
	{
		return 0;
	}
	if ( player == self.owner )
	{
		self check_owner( hardpointtype );
		return 0;
	}
	if ( player cantargetplayerwithspecialty() == 0 )
	{
		return 0;
	}
	if ( distance( player.origin, self.origin ) > level.heli_missile_range )
	{
		return 0;
	}
	if ( !isDefined( player.team ) )
	{
		return 0;
	}
	if ( level.teambased && player.team == self.team )
	{
		return 0;
	}
	if ( player.team == "spectator" )
	{
		return 0;
	}
	if ( isDefined( player.spawntime ) && ( ( getTime() - player.spawntime ) / 1000 ) <= level.heli_target_spawnprotection )
	{
		return 0;
	}
	if ( self target_cone_check( player, level.heli_missile_target_cone ) == 0 )
	{
		return 0;
	}
	heli_centroid = self.origin + vectorScale( ( 1, 1, 1 ), 160 );
	heli_forward_norm = anglesToForward( self.angles );
	heli_turret_point = heli_centroid + ( 144 * heli_forward_norm );
	if ( !isDefined( player.lasthit ) )
	{
		player.lasthit = 0;
	}
	player.lasthit = self heliturretsighttrace( heli_turret_point, player, player.lasthit );
	if ( player.lasthit != 0 )
	{
		return 0;
	}
	return cantarget;
}

cantargetdog_turret( dog )
{
	cantarget = 1;
	if ( !isDefined( dog ) )
	{
		return 0;
	}
	if ( distance( dog.origin, self.origin ) > level.heli_visual_range )
	{
		return 0;
	}
	if ( !isDefined( dog.aiteam ) )
	{
		return 0;
	}
	if ( level.teambased && dog.aiteam == self.team )
	{
		return 0;
	}
	if ( isDefined( dog.script_owner ) && self.owner == dog.script_owner )
	{
		return 0;
	}
	heli_centroid = self.origin + vectorScale( ( 1, 1, 1 ), 160 );
	heli_forward_norm = anglesToForward( self.angles );
	heli_turret_point = heli_centroid + ( 144 * heli_forward_norm );
	if ( !isDefined( dog.lasthit ) )
	{
		dog.lasthit = 0;
	}
	dog.lasthit = self heliturretdogtrace( heli_turret_point, dog, dog.lasthit );
	if ( dog.lasthit != 0 )
	{
		return 0;
	}
	return cantarget;
}

cantargetdog_missile( dog )
{
	cantarget = 1;
	if ( !isDefined( dog ) )
	{
		return 0;
	}
	if ( distance( dog.origin, self.origin ) > level.heli_missile_range )
	{
		return 0;
	}
	if ( !isDefined( dog.aiteam ) )
	{
		return 0;
	}
	if ( level.teambased && dog.aiteam == self.team )
	{
		return 0;
	}
	if ( isDefined( dog.script_owner ) && self.owner == dog.script_owner )
	{
		return 0;
	}
	heli_centroid = self.origin + vectorScale( ( 1, 1, 1 ), 160 );
	heli_forward_norm = anglesToForward( self.angles );
	heli_turret_point = heli_centroid + ( 144 * heli_forward_norm );
	if ( !isDefined( dog.lasthit ) )
	{
		dog.lasthit = 0;
	}
	dog.lasthit = self heliturretdogtrace( heli_turret_point, dog, dog.lasthit );
	if ( dog.lasthit != 0 )
	{
		return 0;
	}
	return cantarget;
}

cantargettank_turret( tank )
{
	cantarget = 1;
	if ( !isDefined( tank ) )
	{
		return 0;
	}
	if ( distance( tank.origin, self.origin ) > level.heli_visual_range )
	{
		return 0;
	}
	if ( !isDefined( tank.aiteam ) )
	{
		return 0;
	}
	if ( level.teambased && tank.aiteam == self.team )
	{
		return 0;
	}
	if ( isDefined( tank.owner ) && self.owner == tank.owner )
	{
		return 0;
	}
	return cantarget;
}

assignprimarytargets( targets )
{
	idx = 0;
	while ( idx < targets.size )
	{
		if ( isDefined( targets[ idx ].type ) && targets[ idx ].type == "dog" )
		{
			update_dog_threat( targets[ idx ] );
			idx++;
			continue;
		}
		else
		{
			update_player_threat( targets[ idx ] );
		}
		idx++;
	}
/#
	assert( targets.size >= 2, "Not enough targets to assign primary and secondary" );
#/
	highest = 0;
	second_highest = 0;
	primarytarget = undefined;
	idx = 0;
	while ( idx < targets.size )
	{
/#
		assert( isDefined( targets[ idx ].threatlevel ), "Target player does not have threat level" );
#/
		if ( targets[ idx ].threatlevel >= highest )
		{
			highest = targets[ idx ].threatlevel;
			primarytarget = targets[ idx ];
		}
		idx++;
	}
/#
	assert( isDefined( primarytarget ), "Targets exist, but none was assigned as primary" );
#/
	self.primarytarget = primarytarget;
	self notify( "primary acquired" );
}

assignsecondarytargets( targets )
{
	idx = 0;
	while ( idx < targets.size )
	{
		if ( !isDefined( targets[ idx ].type ) || targets[ idx ].type != "dog" )
		{
			self update_missile_player_threat( targets[ idx ] );
			idx++;
			continue;
		}
		else
		{
			if ( targets[ idx ].type == "dog" || targets[ 0 ].type == "tank_drone" )
			{
				update_missile_dog_threat( targets[ idx ] );
			}
		}
		idx++;
	}
/#
	assert( targets.size >= 2, "Not enough targets to assign primary and secondary" );
#/
	highest = 0;
	second_highest = 0;
	primarytarget = undefined;
	secondarytarget = undefined;
	idx = 0;
	while ( idx < targets.size )
	{
/#
		assert( isDefined( targets[ idx ].missilethreatlevel ), "Target player does not have threat level" );
#/
		if ( targets[ idx ].missilethreatlevel >= highest )
		{
			highest = targets[ idx ].missilethreatlevel;
			secondarytarget = targets[ idx ];
		}
		idx++;
	}
/#
	assert( isDefined( secondarytarget ), "1+ targets exist, but none was assigned as secondary" );
#/
	self.secondarytarget = secondarytarget;
	self notify( "secondary acquired" );
}

update_player_threat( player )
{
	player.threatlevel = 0;
	dist = distance( player.origin, self.origin );
	player.threatlevel += ( ( level.heli_visual_range - dist ) / level.heli_visual_range ) * 100;
	if ( isDefined( self.attacker ) && player == self.attacker )
	{
		player.threatlevel += 100;
	}
	if ( isDefined( player.carryobject ) )
	{
		player.threatlevel += 200;
	}
	if ( isDefined( player.score ) )
	{
		player.threatlevel += player.score * 4;
	}
	if ( isDefined( player.antithreat ) )
	{
		player.threatlevel -= player.antithreat;
	}
	if ( player.threatlevel <= 0 )
	{
		player.threatlevel = 1;
	}
}

update_missile_player_threat( player )
{
	player.missilethreatlevel = 0;
	dist = distance( player.origin, self.origin );
	player.missilethreatlevel += ( ( level.heli_missile_range - dist ) / level.heli_missile_range ) * 100;
	if ( self missile_valid_target_check( player ) == 0 )
	{
		player.missilethreatlevel = 1;
		return;
	}
	if ( isDefined( self.attacker ) && player == self.attacker )
	{
		player.missilethreatlevel += 100;
	}
	player.missilethreatlevel += player.score * 4;
	if ( isDefined( player.antithreat ) )
	{
		player.missilethreatlevel -= player.antithreat;
	}
	if ( player.missilethreatlevel <= 0 )
	{
		player.missilethreatlevel = 1;
	}
}

update_dog_threat( dog )
{
	dog.threatlevel = 0;
	dist = distance( dog.origin, self.origin );
	dog.threatlevel += ( ( level.heli_visual_range - dist ) / level.heli_visual_range ) * 100;
}

update_missile_dog_threat( dog )
{
	dog.missilethreatlevel = 1;
}

heli_reset()
{
	self cleartargetyaw();
	self cleargoalyaw();
	self setspeed( 60, 25 );
	self setyawspeed( 75, 45, 45 );
	self setmaxpitchroll( 30, 30 );
	self setneargoalnotifydist( 256 );
	self setturningability( 0,9 );
}

heli_wait( waittime )
{
	self endon( "death" );
	self endon( "crashing" );
	self endon( "evasive" );
	self thread heli_hover();
	wait waittime;
	heli_reset();
	self notify( "stop hover" );
}

heli_hover()
{
	self endon( "death" );
	self endon( "stop hover" );
	self endon( "evasive" );
	self endon( "leaving" );
	self endon( "crashing" );
	randint = randomint( 360 );
	self setgoalyaw( self.angles[ 1 ] + randint );
}

heli_kill_monitor( hardpointtype )
{
	self endon( "death" );
	self endon( "crashing" );
	self endon( "leaving" );
	self.damagetaken = 0;
	self.bda = 0;
	last_kill_vo = 0;
	kill_vo_spacing = 4000;
	for ( ;; )
	{
		self waittill( "killed", victim );
/#
		println( "got killed notify" );
#/
		if ( !isDefined( self.owner ) )
		{
			continue;
		}
		else if ( self.owner == victim )
		{
			continue;
		}
		else if ( level.teambased && self.owner.team == victim.team )
		{
			continue;
		}
		else
		{
			if ( ( last_kill_vo + kill_vo_spacing ) < getTime() )
			{
				self.pilotistalking = 1;
				wait 1,5;
				if ( hardpointtype == "helicopter_player_gunner_mp" )
				{
					type = "kls";
					self thread playpilotdialog( "kls_hit", 1 );
				}
				else
				{
					type = "klsheli";
					self thread playpilotdialog( "klsheli_hit", 1 );
				}
				wait 4;
				if ( self.bda == 0 )
				{
					bdadialog = type + "_killn";
				}
				if ( self.bda == 1 )
				{
					bdadialog = type + "_kill1";
				}
				if ( self.bda == 2 )
				{
					bdadialog = type + "_kill2";
				}
				if ( self.bda == 3 )
				{
					bdadialog = type + "_kill3";
				}
				else
				{
					if ( self.bda > 3 )
					{
						bdadialog = type + "_killm";
					}
				}
				self thread playpilotdialog( bdadialog );
				self.bda = 0;
				last_kill_vo = getTime();
				wait 1,5;
				self.pilotistalking = 0;
			}
		}
	}
}

heli_damage_monitor( hardpointtype )
{
	self endon( "death" );
	self endon( "crashing" );
	self.damagetaken = 0;
	last_hit_vo = 0;
	hit_vo_spacing = 6000;
	if ( !isDefined( self.attackerdata ) )
	{
		self.attackers = [];
		self.attackerdata = [];
		self.attackerdamage = [];
		self.flareattackerdamage = [];
	}
	for ( ;; )
	{
		self waittill( "damage", damage, attacker, direction, point, type, modelname, tagname, partname, weapon );
		if ( !isDefined( attacker ) || !isplayer( attacker ) )
		{
			continue;
		}
		else
		{
			heli_friendlyfire = maps/mp/gametypes/_weaponobjects::friendlyfirecheck( self.owner, attacker );
			if ( !heli_friendlyfire )
			{
				break;
			}
			else if ( !level.hardcoremode )
			{
				if ( isDefined( self.owner ) && attacker == self.owner )
				{
					break;
				}
				else
				{
					if ( level.teambased )
					{
						if ( isDefined( attacker.team ) )
						{
							isvalidattacker = attacker.team != self.team;
						}
					}
					else
					{
						isvalidattacker = 1;
					}
					if ( !isvalidattacker )
					{
						break;
					}
				}
				else if ( isplayer( attacker ) )
				{
					if ( maps/mp/gametypes/_globallogic_player::dodamagefeedback( weapon, attacker ) )
					{
						attacker maps/mp/gametypes/_damagefeedback::updatedamagefeedback();
					}
					if ( type == "MOD_RIFLE_BULLET" || type == "MOD_PISTOL_BULLET" )
					{
						if ( attacker hasperk( "specialty_armorpiercing" ) )
						{
							damage += int( damage * level.cac_armorpiercing_data );
						}
						damage *= level.heli_armor_bulletdamage;
					}
					self trackassists( attacker, damage, 0 );
				}
				self.attacker = attacker;
				if ( type == "MOD_PROJECTILE" )
				{
					switch( weapon )
					{
						case "tow_turret_mp":
							if ( isDefined( self.rocketdamagetwoshot ) )
							{
								self.damagetaken += self.rocketdamagetwoshot;
							}
							else if ( isDefined( self.rocketdamageoneshot ) )
							{
								self.damagetaken += self.rocketdamageoneshot;
							}
							else
							{
								self.damagetaken += damage;
							}
							break;
						case "xm25_mp":
							self.damagetaken += damage;
							break;
						default:
							if ( isDefined( self.rocketdamageoneshot ) )
							{
								self.damagetaken += self.rocketdamageoneshot;
							}
							else self.damagetaken += damage;
							break;
					}
				}
				else
				{
					self.damagetaken += damage;
				}
				playercontrolled = 0;
				if ( self.damagetaken > self.maxhealth && !isDefined( self.xpgiven ) || !isDefined( self.owner ) && attacker != self.owner )
				{
					self.xpgiven = 1;
					switch( hardpointtype )
					{
						case "helicopter_gunner_mp":
							playercontrolled = 1;
							event = "destroyed_helicopter_gunner";
							break;
						case "helicopter_player_gunner_mp":
							playercontrolled = 1;
							event = "destroyed_helicopter_gunner";
							break;
						case "helicopter_guard_mp":
							event = "destroyed_helicopter_guard";
							break;
						case "helicopter_comlink_mp":
							event = "destroyed_helicopter_comlink";
							break;
						case "supply_drop_mp":
							event = "destroyed_helicopter_supply_drop";
							break;
					}
					if ( isDefined( event ) )
					{
						if ( self.owner isenemyplayer( attacker ) )
						{
							maps/mp/_challenges::destroyedhelicopter( attacker, weapon, type, playercontrolled );
							maps/mp/_challenges::destroyedaircraft( attacker, weapon );
							maps/mp/_scoreevents::processscoreevent( event, attacker, self.owner, weapon );
							attacker maps/mp/_challenges::addflyswatterstat( weapon, self );
							if ( playercontrolled == 1 )
							{
								attacker destroyedplayercontrolledaircraft();
							}
							if ( hardpointtype == "helicopter_player_gunner_mp" )
							{
								attacker addweaponstat( weapon, "destroyed_controlled_killstreak", 1 );
							}
							break;
						}
					}
					weaponstatname = "destroyed";
					switch( weapon )
					{
						case "auto_tow_mp":
						case "tow_turret_drop_mp":
						case "tow_turret_mp":
							weaponstatname = "kills";
							break;
					}
					attacker addweaponstat( weapon, weaponstatname, 1 );
					killstreakreference = undefined;
					switch( hardpointtype )
					{
						case "helicopter_gunner_mp":
							killstreakreference = "killstreak_helicopter_gunner";
							break;
						case "helicopter_player_gunner_mp":
							killstreakreference = "killstreak_helicopter_player_gunner";
							break;
						case "helicopter_player_firstperson_mp":
							killstreakreference = "killstreak_helicopter_player_firstperson";
							break;
						case "helicopter_comlink_mp":
						case "helicopter_mp":
						case "helicopter_x2_mp":
							killstreakreference = "killstreak_helicopter_comlink";
							break;
						case "supply_drop_mp":
							killstreakreference = "killstreak_supply_drop";
							break;
						case "helicopter_guard_mp":
							killstreakreference = "killstreak_helicopter_guard";
					}
					if ( isDefined( killstreakreference ) )
					{
						level.globalkillstreaksdestroyed++;
						attacker addweaponstat( hardpointtype, "destroyed", 1 );
					}
					notifystring = &"KILLSTREAK_DESTROYED_HELICOPTER";
					if ( hardpointtype == "helicopter_player_gunner_mp" )
					{
						notifystring = &"KILLSTREAK_DESTROYED_HELICOPTER_GUNNER";
						self.owner sendkillstreakdamageevent( 600 );
					}
					i = 0;
					while ( i < level.players.size )
					{
						level.players[ i ] luinotifyevent( &"player_callout", 2, notifystring, attacker.entnum );
						i++;
					}
					if ( isDefined( self.attackers ) )
					{
						j = 0;
						while ( j < self.attackers.size )
						{
							player = self.attackers[ j ];
							if ( !isDefined( player ) )
							{
								j++;
								continue;
							}
							else if ( player == attacker )
							{
								j++;
								continue;
							}
							else flare_done = self.flareattackerdamage[ player.clientid ];
							if ( isDefined( flare_done ) && flare_done == 1 )
							{
								maps/mp/_scoreevents::processscoreevent( "aircraft_flare_assist", player );
								j++;
								continue;
							}
							else
							{
								damage_done = self.attackerdamage[ player.clientid ];
								player thread processcopterassist( self, damage_done );
							}
							j++;
						}
						self.attackers = [];
					}
					attacker notify( "destroyed_helicopter" );
					target_remove( self );
					break;
				}
				else
				{
					if ( isDefined( self.owner ) && isplayer( self.owner ) )
					{
						if ( ( last_hit_vo + hit_vo_spacing ) < getTime() )
						{
							if ( type == "MOD_PROJECTILE" || randomintrange( 0, 3 ) == 0 )
							{
								self.owner playlocalsound( level.heli_vo[ self.team ][ "hit" ] );
								last_hit_vo = getTime();
							}
						}
					}
				}
			}
		}
	}
}

trackassists( attacker, damage, isflare )
{
	if ( !isDefined( self.attackerdata[ attacker.clientid ] ) )
	{
		self.attackerdamage[ attacker.clientid ] = damage;
		self.attackers[ self.attackers.size ] = attacker;
		self.attackerdata[ attacker.clientid ] = 0;
	}
	else
	{
		self.attackerdamage[ attacker.clientid ] += damage;
	}
	if ( isDefined( isflare ) && isflare == 1 )
	{
		self.flareattackerdamage[ attacker.clientid ] = 1;
	}
	else
	{
		self.flareattackerdamage[ attacker.clientid ] = 0;
	}
}

heli_health( hardpointtype, player, playernotify )
{
	self endon( "death" );
	self endon( "crashing" );
	self.currentstate = "ok";
	self.laststate = "ok";
	self setdamagestage( 3 );
	damagestate = 3;
	for ( ;; )
	{
		self waittill( "damage", damage, attacker, direction, point, type, modelname, tagname, partname, weapon );
		wait 0,05;
		if ( self.damagetaken > self.maxhealth )
		{
			damagestate = 0;
			self setdamagestage( damagestate );
			self thread heli_crash( hardpointtype, player, playernotify );
		}
		else if ( self.damagetaken >= ( self.maxhealth * 0,66 ) && damagestate >= 2 )
		{
			if ( isDefined( self.vehicletype ) && self.vehicletype == "heli_player_gunner_mp" )
			{
				playfxontag( level.chopper_fx[ "damage" ][ "heavy_smoke" ], self, "tag_origin" );
			}
			else
			{
				playfxontag( level.chopper_fx[ "damage" ][ "heavy_smoke" ], self, "tag_main_rotor" );
			}
			damagestate = 1;
			self.currentstate = "heavy smoke";
			self.evasive = 1;
			self notify( "damage state" );
		}
		else
		{
			if ( self.damagetaken >= ( self.maxhealth * 0,33 ) && damagestate == 3 )
			{
				if ( isDefined( self.vehicletype ) && self.vehicletype == "heli_player_gunner_mp" )
				{
					playfxontag( level.chopper_fx[ "damage" ][ "light_smoke" ], self, "tag_origin" );
				}
				else
				{
					playfxontag( level.chopper_fx[ "damage" ][ "light_smoke" ], self, "tag_main_rotor" );
				}
				damagestate = 2;
				self.currentstate = "light smoke";
				self notify( "damage state" );
			}
		}
		if ( self.damagetaken <= level.heli_armor )
		{
			debug_print3d_simple( "Armor: " + ( level.heli_armor - self.damagetaken ), self, vectorScale( ( 1, 1, 1 ), 100 ), 20 );
			continue;
		}
		else
		{
			debug_print3d_simple( "Health: " + ( self.maxhealth - self.damagetaken ), self, vectorScale( ( 1, 1, 1 ), 100 ), 20 );
		}
	}
}

heli_evasive( hardpointtype )
{
	self notify( "evasive" );
	self.evasive = 1;
	loop_startnode = level.heli_loop_paths[ 0 ];
	gunnerpathfound = 1;
	while ( hardpointtype == "helicopter_gunner_mp" )
	{
		gunnerpathfound = 0;
		i = 0;
		while ( i < level.heli_loop_paths.size )
		{
			if ( isDefined( level.heli_loop_paths[ i ].isgunnerpath ) && level.heli_loop_paths[ i ].isgunnerpath )
			{
				loop_startnode = level.heli_loop_paths[ i ];
				gunnerpathfound = 1;
				break;
			}
			else
			{
				i++;
			}
		}
	}
/#
	assert( gunnerpathfound, "No chopper gunner loop paths found in map" );
#/
	startwait = 2;
	if ( isDefined( self.donotstop ) && self.donotstop )
	{
		startwait = 0;
	}
	self thread heli_fly( loop_startnode, startwait, hardpointtype );
}

notify_player( player, playernotify, delay )
{
	if ( !isDefined( player ) )
	{
		return;
	}
	if ( !isDefined( playernotify ) )
	{
		return;
	}
	player endon( "disconnect" );
	player endon( playernotify );
	wait delay;
	player notify( playernotify );
}

play_going_down_vo( delay )
{
	self.owner endon( "disconnect" );
	self endon( "death" );
	wait delay;
	self playpilotdialog( "attackheli_down" );
}

heli_crash( hardpointtype, player, playernotify )
{
	self endon( "death" );
	self notify( "crashing" );
	self maps/mp/gametypes/_spawning::remove_helicopter_influencers();
	self stoploopsound( 0 );
	if ( isDefined( self.minigun_snd_ent ) )
	{
		self.minigun_snd_ent stoploopsound();
	}
	if ( isDefined( self.alarm_snd_ent ) )
	{
		self.alarm_snd_ent stoploopsound();
	}
	crashtypes = [];
	crashtypes[ 0 ] = "crashOnPath";
	crashtypes[ 1 ] = "spinOut";
	crashtype = crashtypes[ randomint( 2 ) ];
	if ( isDefined( self.crashtype ) )
	{
		crashtype = self.crashtype;
	}
/#
	if ( level.heli_debug_crash )
	{
		switch( level.heli_debug_crash )
		{
			case 1:
				crashtype = "explode";
				break;
			case 2:
				crashtype = "crashOnPath";
				break;
			case 3:
				crashtype = "spinOut";
				break;
			default:
			}
#/
		}
		switch( crashtype )
		{
			case "explode":
				thread notify_player( player, playernotify, 0 );
				self thread heli_explode();
				break;
			case "crashOnPath":
				if ( isDefined( player ) )
				{
					self thread play_going_down_vo( 0,5 );
				}
				thread notify_player( player, playernotify, 4 );
				self clear_client_flags();
				self thread crashonnearestcrashpath( hardpointtype );
				break;
			case "spinOut":
				if ( isDefined( player ) )
				{
					self thread play_going_down_vo( 0,5 );
				}
				thread notify_player( player, playernotify, 4 );
				self clear_client_flags();
				heli_reset();
				heli_speed = 30 + randomint( 50 );
				heli_accel = 10 + randomint( 25 );
				leavenode = getvalidrandomcrashnode( self.origin );
				self setspeed( heli_speed, heli_accel );
				self setvehgoalpos( leavenode.origin, 0 );
				rateofspin = 45 + randomint( 90 );
				thread heli_secondary_explosions();
				self thread heli_spin( rateofspin );
				self waittill_any_timeout( randomintrange( 4, 6 ), "near_goal" );
				if ( isDefined( player ) && isDefined( playernotify ) )
				{
					player notify( playernotify );
				}
				self thread heli_explode();
				break;
		}
		self thread explodeoncontact( hardpointtype );
		time = randomintrange( 4, 6 );
		self thread waitthenexplode( time );
	}
}

damagedrotorfx()
{
	self endon( "death" );
	self setrotorspeed( 0,6 );
}

waitthenexplode( time )
{
	self endon( "death" );
	wait time;
	self thread heli_explode();
}

crashonnearestcrashpath( hardpointtype )
{
	crashpathdistance = -1;
	crashpath = level.heli_crash_paths[ 0 ];
	i = 0;
	while ( i < level.heli_crash_paths.size )
	{
		currentdistance = distance( self.origin, level.heli_crash_paths[ i ].origin );
		if ( crashpathdistance == -1 || crashpathdistance > currentdistance )
		{
			crashpathdistance = currentdistance;
			crashpath = level.heli_crash_paths[ i ];
		}
		i++;
	}
	heli_speed = 30 + randomint( 50 );
	heli_accel = 10 + randomint( 25 );
	self setspeed( heli_speed, heli_accel );
	thread heli_secondary_explosions();
	self thread heli_fly( crashpath, 0, hardpointtype );
	rateofspin = 45 + randomint( 90 );
	self thread heli_spin( rateofspin );
	self waittill( "path start" );
	self waittill( "destination reached" );
	self thread heli_explode();
}

heli_secondary_explosions()
{
	self endon( "death" );
	playfxontag( level.chopper_fx[ "explode" ][ "large" ], self, "tag_engine_left" );
	self playsound( level.heli_sound[ "hit" ] );
	if ( isDefined( self.vehicletype ) && self.vehicletype == "heli_player_gunner_mp" )
	{
		self thread trail_fx( level.chopper_fx[ "smoke" ][ "trail" ], "tag_engine_right", "stop tail smoke" );
	}
	else
	{
		self thread trail_fx( level.chopper_fx[ "smoke" ][ "trail" ], "tail_rotor_jnt", "stop tail smoke" );
	}
	self setdamagestage( 0 );
	self thread trail_fx( level.chopper_fx[ "fire" ][ "trail" ][ "large" ], "tag_engine_left", "stop body fire" );
	wait 3;
	if ( !isDefined( self ) )
	{
		return;
	}
	playfxontag( level.chopper_fx[ "explode" ][ "large" ], self, "tag_engine_left" );
	self playsound( level.heli_sound[ "hitsecondary" ] );
}

heli_spin( speed )
{
	self endon( "death" );
	self thread spinsoundshortly();
	self setyawspeed( speed, speed / 3, speed / 3 );
	while ( isDefined( self ) )
	{
		self settargetyaw( self.angles[ 1 ] + ( speed * 0,9 ) );
		wait 1;
	}
}

spinsoundshortly()
{
	self endon( "death" );
	wait 0,25;
	self stoploopsound();
	wait 0,05;
	self playloopsound( level.heli_sound[ "spinloop" ] );
	wait 0,05;
	self playsound( level.heli_sound[ "spinstart" ] );
}

trail_fx( trail_fx, trail_tag, stop_notify )
{
	playfxontag( trail_fx, self, trail_tag );
}

destroyhelicopter()
{
	team = self.team;
	self maps/mp/gametypes/_spawning::remove_helicopter_influencers();
	if ( isDefined( self.interior_model ) )
	{
		self.interior_model delete();
		self.interior_model = undefined;
	}
	if ( isDefined( self.minigun_snd_ent ) )
	{
		self.minigun_snd_ent stoploopsound();
		self.minigun_snd_ent delete();
		self.minigun_snd_ent = undefined;
	}
	if ( isDefined( self.alarm_snd_ent ) )
	{
		self.alarm_snd_ent delete();
		self.alarm_snd_ent = undefined;
	}
	if ( isDefined( self.flare_ent ) )
	{
		self.flare_ent delete();
		self.flare_ent = undefined;
	}
	self delete();
	maps/mp/killstreaks/_killstreakrules::killstreakstop( self.hardpointtype, team, self.killstreak_id );
}

heli_explode()
{
	self death_notify_wrapper();
	forward = ( self.origin + vectorScale( ( 1, 1, 1 ), 100 ) ) - self.origin;
	if ( isDefined( self.helitype ) && self.helitype == "littlebird" )
	{
		playfx( level.chopper_fx[ "explode" ][ "guard" ], self.origin, forward );
	}
	else
	{
		if ( isDefined( self.vehicletype ) && self.vehicletype == "heli_player_gunner_mp" )
		{
			playfx( level.chopper_fx[ "explode" ][ "gunner" ], self.origin, forward );
		}
		else
		{
			playfx( level.chopper_fx[ "explode" ][ "death" ], self.origin, forward );
		}
	}
	self playsound( level.heli_sound[ "crash" ] );
	wait 0,1;
/#
	assert( isDefined( self.destroyfunc ) );
#/
	self [[ self.destroyfunc ]]();
}

clear_client_flags()
{
}

heli_leave( hardpointtype )
{
	self notify( "desintation reached" );
	self notify( "leaving" );
	if ( hardpointtype == "helicopter_player_gunner_mp" )
	{
		self thread playpilotdialog( "a10_leave", 2,5 );
	}
	else
	{
		self thread playpilotdialog( "attackheli_leave", 2,5 );
	}
	self clear_client_flags();
	leavenode = getvalidrandomleavenode( self.origin );
	heli_reset();
	self clearlookatent();
	exitangles = vectorToAngle( leavenode.origin - self.origin );
	self setgoalyaw( exitangles[ 1 ] );
	wait 1,5;
	if ( !isDefined( self ) )
	{
		return;
	}
	self setspeed( 180, 65 );
	self setvehgoalpos( self.origin + ( ( leavenode.origin - self.origin ) / 2 ) + vectorScale( ( 1, 1, 1 ), 1000 ) );
	self waittill( "near_goal" );
	self setvehgoalpos( leavenode.origin, 1 );
	self waittillmatch( "goal" );
	return;
	self stoploopsound( 1 );
	self death_notify_wrapper();
	if ( isDefined( self.alarm_snd_ent ) )
	{
		self.alarm_snd_ent stoploopsound();
		self.alarm_snd_ent delete();
		self.alarm_snd_ent = undefined;
	}
	if ( target_istarget( self ) )
	{
		target_remove( self );
	}
/#
	assert( isDefined( self.destroyfunc ) );
#/
	self [[ self.destroyfunc ]]();
}

heli_fly( currentnode, startwait, hardpointtype )
{
	self endon( "death" );
	self endon( "leaving" );
	self notify( "flying" );
	self endon( "flying" );
	self endon( "abandoned" );
	self.reached_dest = 0;
	heli_reset();
	pos = self.origin;
	wait startwait;
	while ( isDefined( currentnode.target ) )
	{
		nextnode = getent( currentnode.target, "targetname" );
/#
		assert( isDefined( nextnode ), "Next node in path is undefined, but has targetname" );
#/
		pos = nextnode.origin + vectorScale( ( 1, 1, 1 ), 30 );
		if ( isDefined( currentnode.script_airspeed ) && isDefined( currentnode.script_accel ) )
		{
			heli_speed = currentnode.script_airspeed;
			heli_accel = currentnode.script_accel;
		}
		else
		{
			heli_speed = 30 + randomint( 20 );
			heli_accel = 10 + randomint( 5 );
		}
		if ( isDefined( self.pathspeedscale ) )
		{
			heli_speed *= self.pathspeedscale;
			heli_accel *= self.pathspeedscale;
		}
		if ( !isDefined( nextnode.target ) )
		{
			stop = 1;
		}
		else
		{
			stop = 0;
		}
		debug_line( currentnode.origin, nextnode.origin, ( 1, 0,5, 0,5 ), 200 );
		if ( self.currentstate == "heavy smoke" || self.currentstate == "light smoke" )
		{
			self setspeed( heli_speed, heli_accel );
			self setvehgoalpos( pos, stop );
			self waittill( "near_goal" );
			self notify( "path start" );
		}
		else
		{
			if ( isDefined( nextnode.script_delay ) && !isDefined( self.donotstop ) )
			{
				stop = 1;
			}
			self setspeed( heli_speed, heli_accel );
			self setvehgoalpos( pos, stop );
			if ( !isDefined( nextnode.script_delay ) || isDefined( self.donotstop ) )
			{
				self waittill( "near_goal" );
				self notify( "path start" );
				break;
			}
			else
			{
				self setgoalyaw( nextnode.angles[ 1 ] );
				self waittillmatch( "goal" );
				return;
				heli_wait( nextnode.script_delay );
			}
		}
		index = 0;
		while ( index < level.heli_loop_paths.size )
		{
			if ( level.heli_loop_paths[ index ].origin == nextnode.origin )
			{
				self.loopcount++;
			}
			index++;
		}
		if ( self.loopcount >= level.heli_loopmax )
		{
			self thread heli_leave( hardpointtype );
			return;
		}
		currentnode = nextnode;
	}
	self setgoalyaw( currentnode.angles[ 1 ] );
	self.reached_dest = 1;
	self notify( "destination reached" );
	if ( isDefined( self.waittime ) && self.waittime > 0 )
	{
		heli_wait( self.waittime );
	}
	if ( isDefined( self ) )
	{
		self thread heli_evasive( hardpointtype );
	}
}

heli_random_point_in_radius( protectdest, nodeheight )
{
	min_distance = int( level.heli_protect_radius * 0,2 );
	direction = randomintrange( 0, 360 );
	distance = randomintrange( min_distance, level.heli_protect_radius );
	x = cos( direction );
	y = sin( direction );
	x *= distance;
	y *= distance;
	return ( protectdest[ 0 ] + x, protectdest[ 1 ] + y, nodeheight );
}

heli_get_protect_spot( protectdest, nodeheight )
{
	protect_spot = heli_random_point_in_radius( protectdest, nodeheight );
	tries = 10;
	noflyzone = crossesnoflyzone( protectdest, protect_spot );
	while ( tries != 0 && isDefined( noflyzone ) )
	{
		protect_spot = heli_random_point_in_radius( protectdest, nodeheight );
		tries--;

		noflyzone = crossesnoflyzone( protectdest, protect_spot );
	}
	noflyzoneheight = getnoflyzoneheightcrossed( protectdest, protect_spot, nodeheight );
	return ( protect_spot[ 0 ], protect_spot[ 1 ], noflyzoneheight );
}

wait_or_waittill( time, msg1, msg2 )
{
	self endon( msg1 );
	self endon( msg2 );
	wait time;
	return 1;
}

set_heli_speed_normal()
{
	self setmaxpitchroll( 30, 30 );
	heli_speed = 30 + randomint( 20 );
	heli_accel = 10 + randomint( 5 );
	self setspeed( heli_speed, heli_accel );
	self setyawspeed( 75, 45, 45 );
}

set_heli_speed_evasive()
{
	self setmaxpitchroll( 30, 90 );
	heli_speed = 50 + randomint( 20 );
	heli_accel = 30 + randomint( 5 );
	self setspeed( heli_speed, heli_accel );
	self setyawspeed( 100, 75, 75 );
}

set_heli_speed_hover()
{
	self setmaxpitchroll( 0, 90 );
	self setspeed( 20, 10 );
	self setyawspeed( 55, 25, 25 );
}

is_targeted()
{
	if ( isDefined( self.locking_on ) && self.locking_on )
	{
		return 1;
	}
	if ( isDefined( self.locked_on ) && self.locked_on )
	{
		return 1;
	}
	return 0;
}

heli_mobilespawn( protectdest )
{
	self endon( "death" );
	self notify( "flying" );
	self endon( "flying" );
	self endon( "abandoned" );
	iprintlnbold( "PROTECT ORIGIN: (" + protectdest[ 0 ] + "," + protectdest[ 1 ] + "," + protectdest[ 2 ] + ")\n" );
	heli_reset();
	self sethoverparams( 50, 100, 50 );
	wait 2;
	set_heli_speed_normal();
	self setvehgoalpos( protectdest, 1 );
	self waittill( "near_goal" );
	set_heli_speed_hover();
}

heli_protect( startnode, protectdest, hardpointtype, heli_team )
{
	self endon( "death" );
	self notify( "flying" );
	self endon( "flying" );
	self endon( "abandoned" );
	self.reached_dest = 0;
	heli_reset();
	self sethoverparams( 50, 100, 50 );
	wait 2;
	currentdest = protectdest;
	nodeheight = protectdest[ 2 ];
	nextnode = startnode;
	heightoffset = 0;
	if ( heli_team == "axis" )
	{
		heightoffset = 800;
	}
	protectdest = ( protectdest[ 0 ], protectdest[ 1 ], nodeheight );
	noflyzoneheight = getnoflyzoneheight( protectdest );
	protectdest = ( protectdest[ 0 ], protectdest[ 1 ], noflyzoneheight + heightoffset );
	currentdest = protectdest;
	starttime = getTime();
	endtime = starttime + ( level.heli_protect_time * 1000 );
	self setspeed( 150, 80 );
	self setvehgoalpos( self.origin + ( ( currentdest - self.origin ) / 3 ) + vectorScale( ( 1, 1, 1 ), 1000 ) );
	self waittill( "near_goal" );
	heli_speed = 30 + randomint( 20 );
	heli_accel = 10 + randomint( 5 );
	self thread updatetargetyaw();
	mapenter = 1;
	while ( getTime() < endtime )
	{
		stop = 1;
		if ( !mapenter )
		{
			self updatespeed();
		}
		else
		{
			mapenter = 0;
		}
		self setvehgoalpos( currentdest, stop );
		self thread updatespeedonlock();
		self waittill_any( "near_goal", "locking on" );
		maps/mp/gametypes/_hostmigration::waittillhostmigrationdone();
		self notify( "path start" );
		if ( !self is_targeted() )
		{
			waittillframeend;
			time = level.heli_protect_pos_time;
			if ( self.evasive == 1 )
			{
				time = 2;
			}
			set_heli_speed_hover();
			wait_or_waittill( time, "locking on", "damage state" );
		}
		prevdest = currentdest;
		currentdest = heli_get_protect_spot( protectdest, nodeheight );
		noflyzoneheight = getnoflyzoneheight( currentdest );
		currentdest = ( currentdest[ 0 ], currentdest[ 1 ], noflyzoneheight + heightoffset );
		noflyzones = crossesnoflyzones( prevdest, currentdest );
		if ( isDefined( noflyzones ) && noflyzones.size > 0 )
		{
			currentdest = prevdest;
		}
	}
	self thread heli_leave( hardpointtype );
}

updatespeedonlock()
{
	self endon( "death" );
	self endon( "crashing" );
	self endon( "leaving" );
	self waittill_any( "near_goal", "locking on" );
	self updatespeed();
}

updatespeed()
{
	if ( self is_targeted() || isDefined( self.evasive ) && self.evasive )
	{
		set_heli_speed_evasive();
	}
	else
	{
		set_heli_speed_normal();
	}
}

updatetargetyaw()
{
	self notify( "endTargetYawUpdate" );
	self endon( "death" );
	self endon( "crashing" );
	self endon( "leaving" );
	self endon( "endTargetYawUpdate" );
	for ( ;; )
	{
		if ( isDefined( self.primarytarget ) )
		{
			yaw = get2dyaw( self.origin, self.primarytarget.origin );
			self settargetyaw( yaw );
		}
		wait 1;
	}
}

fire_missile( smissiletype, ishots, etarget )
{
	if ( !isDefined( ishots ) )
	{
		ishots = 1;
	}
/#
	assert( self.health > 0 );
#/
	weaponname = undefined;
	weaponshoottime = undefined;
	tags = [];
	switch( smissiletype )
	{
		case "ffar":
			weaponname = "hind_FFAR_mp";
			tags[ 0 ] = "tag_store_r_2";
			break;
		default:
/#
			assertmsg( "Invalid missile type specified. Must be ffar" );
#/
			break;
	}
/#
	assert( isDefined( weaponname ) );
#/
/#
	assert( tags.size > 0 );
#/
	weaponshoottime = weaponfiretime( weaponname );
/#
	assert( isDefined( weaponshoottime ) );
#/
	self setvehweapon( weaponname );
	nextmissiletag = -1;
	i = 0;
	while ( i < ishots )
	{
		nextmissiletag++;
		if ( nextmissiletag >= tags.size )
		{
			nextmissiletag = 0;
		}
		if ( isDefined( etarget ) )
		{
			emissile = self fireweapon( tags[ nextmissiletag ], etarget );
		}
		else
		{
			emissile = self fireweapon( tags[ nextmissiletag ] );
		}
		emissile.killcament = self;
		self.lastrocketfiretime = getTime();
		if ( i < ( ishots - 1 ) )
		{
			wait weaponshoottime;
		}
		i++;
	}
}

check_owner( hardpointtype )
{
	if ( isDefined( self.owner ) || !isDefined( self.owner.team ) && self.owner.team != self.team )
	{
		self notify( "abandoned" );
		self thread heli_leave( hardpointtype );
	}
}

attack_targets( missilesenabled, hardpointtype )
{
	self thread attack_primary( hardpointtype );
	if ( missilesenabled )
	{
		self thread attack_secondary( hardpointtype );
	}
}

attack_secondary( hardpointtype )
{
	self endon( "death" );
	self endon( "crashing" );
	self endon( "leaving" );
	for ( ;; )
	{
		if ( isDefined( self.secondarytarget ) )
		{
			self.secondarytarget.antithreat = undefined;
			self.missiletarget = self.secondarytarget;
			antithreat = 0;
			while ( isDefined( self.missiletarget ) && isalive( self.missiletarget ) )
			{
				if ( self target_cone_check( self.missiletarget, level.heli_missile_target_cone ) )
				{
					self thread missile_support( self.missiletarget, level.heli_missile_rof, 1, undefined );
				}
				else
				{
				}
				antithreat += 100;
				self.missiletarget.antithreat = antithreat;
				wait level.heli_missile_rof;
				if ( !isDefined( self.secondarytarget ) || isDefined( self.secondarytarget ) && self.missiletarget != self.secondarytarget )
				{
					break;
				}
				else }
			if ( isDefined( self.missiletarget ) )
			{
				self.missiletarget.antithreat = undefined;
			}
		}
		self waittill( "secondary acquired" );
		self check_owner( hardpointtype );
	}
}

turret_target_check( turrettarget, attackangle )
{
	targetyaw = get2dyaw( self.origin, turrettarget.origin );
	chopperyaw = self.angles[ 1 ];
	if ( targetyaw < 0 )
	{
		targetyaw *= -1;
	}
	targetyaw = int( targetyaw ) % 360;
	if ( chopperyaw < 0 )
	{
		chopperyaw *= -1;
	}
	chopperyaw = int( chopperyaw ) % 360;
	if ( chopperyaw > targetyaw )
	{
		difference = chopperyaw - targetyaw;
	}
	else
	{
		difference = targetyaw - chopperyaw;
	}
	return difference <= attackangle;
}

target_cone_check( target, conecosine )
{
	heli2target_normal = vectornormalize( target.origin - self.origin );
	heli2forward = anglesToForward( self.angles );
	heli2forward_normal = vectornormalize( heli2forward );
	heli_dot_target = vectordot( heli2target_normal, heli2forward_normal );
	if ( heli_dot_target >= conecosine )
	{
		debug_print3d_simple( "Cone sight: " + heli_dot_target, self, vectorScale( ( 1, 1, 1 ), 40 ), 40 );
		return 1;
	}
	return 0;
}

missile_valid_target_check( missiletarget )
{
	heli2target_normal = vectornormalize( missiletarget.origin - self.origin );
	heli2forward = anglesToForward( self.angles );
	heli2forward_normal = vectornormalize( heli2forward );
	heli_dot_target = vectordot( heli2target_normal, heli2forward_normal );
	if ( heli_dot_target >= level.heli_valid_target_cone )
	{
		return 1;
	}
	return 0;
}

missile_support( target_player, rof, instantfire, endon_notify )
{
	self endon( "death" );
	self endon( "crashing" );
	self endon( "leaving" );
	if ( isDefined( endon_notify ) )
	{
		self endon( endon_notify );
	}
	self.turret_giveup = 0;
	if ( !instantfire )
	{
		wait rof;
		self.turret_giveup = 1;
		self notify( "give up" );
	}
	if ( isDefined( target_player ) )
	{
		if ( level.teambased )
		{
			i = 0;
			while ( i < level.players.size )
			{
				player = level.players[ i ];
				if ( isDefined( player.team ) && player.team == self.team && distance( player.origin, target_player.origin ) <= level.heli_missile_friendlycare )
				{
					debug_print3d_simple( "Missile omitted due to nearby friendly", self, vectorScale( ( 1, 1, 1 ), 80 ), 40 );
					self notify( "missile ready" );
					return;
				}
				i++;
			}
		}
		else player = self.owner;
		if ( isDefined( player ) && isDefined( player.team ) && player.team == self.team && distance( player.origin, target_player.origin ) <= level.heli_missile_friendlycare )
		{
			debug_print3d_simple( "Missile omitted due to nearby friendly", self, vectorScale( ( 1, 1, 1 ), 80 ), 40 );
			self notify( "missile ready" );
			return;
		}
	}
	if ( self.missile_ammo > 0 && isDefined( target_player ) )
	{
		self fire_missile( "ffar", 1, target_player );
		self.missile_ammo--;

		self notify( "missile fired" );
	}
	else
	{
		return;
	}
	if ( instantfire )
	{
		wait rof;
		self notify( "missile ready" );
	}
}

attack_primary( hardpointtype )
{
	self endon( "death" );
	self endon( "crashing" );
	self endon( "leaving" );
	level endon( "game_ended" );
	for ( ;; )
	{
		if ( isDefined( self.primarytarget ) )
		{
			self.primarytarget.antithreat = undefined;
			self.turrettarget = self.primarytarget;
			antithreat = 0;
			last_pos = undefined;
			while ( isDefined( self.turrettarget ) && isalive( self.turrettarget ) )
			{
				if ( hardpointtype == "helicopter_comlink_mp" )
				{
					self setlookatent( self.turrettarget );
				}
				helicopterturretmaxangle = heli_get_dvar_int( "scr_helicopterTurretMaxAngle", level.helicopterturretmaxangle );
				while ( isDefined( self.turrettarget ) && isalive( self.turrettarget ) && self turret_target_check( self.turrettarget, helicopterturretmaxangle ) == 0 )
				{
					wait 0,1;
				}
				if ( !isDefined( self.turrettarget ) || !isalive( self.turrettarget ) )
				{
					break;
				}
				else
				{
					self setturrettargetent( self.turrettarget, vectorScale( ( 1, 1, 1 ), 50 ) );
					self waittill( "turret_on_target" );
					maps/mp/gametypes/_hostmigration::waittillhostmigrationdone();
					self notify( "turret_on_target" );
					if ( !self.pilotistalking )
					{
						self thread playpilotdialog( "attackheli_target" );
					}
					self thread turret_target_flag( self.turrettarget );
					wait level.heli_turret_spinup_delay;
					weaponshoottime = weaponfiretime( self.defaultweapon );
					self setvehweapon( self.defaultweapon );
					i = 0;
					while ( i < level.heli_turretclipsize )
					{
						if ( isDefined( self.turrettarget ) && isDefined( self.primarytarget ) )
						{
							if ( self.primarytarget != self.turrettarget )
							{
								self setturrettargetent( self.primarytarget, vectorScale( ( 1, 1, 1 ), 40 ) );
							}
						}
						else
						{
							if ( isDefined( self.targetlost ) && self.targetlost && isDefined( self.turret_last_pos ) )
							{
								self setturrettargetvec( self.turret_last_pos );
								break;
							}
							else
							{
								self clearturrettarget();
							}
						}
						if ( getTime() != self.lastrocketfiretime )
						{
							self setvehweapon( self.defaultweapon );
							minigun = self fireweapon( "tag_flash" );
						}
						if ( i < ( level.heli_turretclipsize - 1 ) )
						{
							wait weaponshoottime;
						}
						i++;
					}
					self notify( "turret reloading" );
					wait level.heli_turretreloadtime;
					if ( isDefined( self.turrettarget ) && isalive( self.turrettarget ) )
					{
						antithreat += 100;
						self.turrettarget.antithreat = antithreat;
					}
					if ( !isDefined( self.primarytarget ) || isDefined( self.turrettarget ) && isDefined( self.primarytarget ) && self.primarytarget != self.turrettarget )
					{
						break;
					}
					else
					{
					}
				}
			}
			if ( isDefined( self.turrettarget ) )
			{
				self.turrettarget.antithreat = undefined;
			}
		}
		self waittill( "primary acquired" );
		self check_owner( hardpointtype );
	}
}

turret_target_flag( turrettarget )
{
	self notify( "flag check is running" );
	self endon( "flag check is running" );
	self endon( "death" );
	self endon( "crashing" );
	self endon( "leaving" );
	self endon( "turret reloading" );
	turrettarget endon( "death" );
	turrettarget endon( "disconnect" );
	self.targetlost = 0;
	self.turret_last_pos = undefined;
	while ( isDefined( turrettarget ) )
	{
		heli_centroid = self.origin + vectorScale( ( 1, 1, 1 ), 160 );
		heli_forward_norm = anglesToForward( self.angles );
		heli_turret_point = heli_centroid + ( 144 * heli_forward_norm );
		sight_rec = turrettarget sightconetrace( heli_turret_point, self );
		if ( sight_rec < level.heli_target_recognition )
		{
			break;
		}
		else
		{
			wait 0,05;
		}
	}
	if ( isDefined( turrettarget ) && isDefined( turrettarget.origin ) )
	{
/#
		assert( isDefined( turrettarget.origin ), "turrettarget.origin is undefined after isdefined check" );
#/
		self.turret_last_pos = turrettarget.origin + vectorScale( ( 1, 1, 1 ), 40 );
/#
		assert( isDefined( self.turret_last_pos ), "self.turret_last_pos is undefined after setting it #1" );
#/
		self setturrettargetvec( self.turret_last_pos );
/#
		assert( isDefined( self.turret_last_pos ), "self.turret_last_pos is undefined after setting it #2" );
#/
		debug_print3d_simple( "Turret target lost at: " + self.turret_last_pos, self, vectorScale( ( 1, 1, 1 ), 70 ), 60 );
		self.targetlost = 1;
	}
	else
	{
		self.targetlost = undefined;
		self.turret_last_pos = undefined;
	}
}

debug_print_target()
{
	if ( isDefined( level.heli_debug ) && level.heli_debug == 1 )
	{
		if ( isDefined( self.primarytarget ) && isDefined( self.primarytarget.threatlevel ) )
		{
			if ( isDefined( self.primarytarget.type ) && self.primarytarget.type == "dog" )
			{
				name = "dog";
			}
			else
			{
				name = self.primarytarget.name;
			}
			primary_msg = "Primary: " + name + " : " + self.primarytarget.threatlevel;
		}
		else
		{
			primary_msg = "Primary: ";
		}
		if ( isDefined( self.secondarytarget ) && isDefined( self.secondarytarget.threatlevel ) )
		{
			if ( isDefined( self.secondarytarget.type ) && self.secondarytarget.type == "dog" )
			{
				name = "dog";
			}
			else
			{
				name = self.secondarytarget.name;
			}
			secondary_msg = "Secondary: " + name + " : " + self.secondarytarget.threatlevel;
		}
		else
		{
			secondary_msg = "Secondary: ";
		}
		frames = int( self.targeting_delay * 20 ) + 1;
		thread draw_text( primary_msg, ( 1, 0,6, 0,6 ), self, vectorScale( ( 1, 1, 1 ), 40 ), frames );
		thread draw_text( secondary_msg, ( 1, 0,6, 0,6 ), self, ( 1, 1, 1 ), frames );
	}
}

improved_sightconetrace( helicopter )
{
	heli_centroid = helicopter.origin + vectorScale( ( 1, 1, 1 ), 160 );
	heli_forward_norm = anglesToForward( helicopter.angles );
	heli_turret_point = heli_centroid + ( 144 * heli_forward_norm );
	debug_line( heli_turret_point, self.origin, ( 1, 1, 1 ), 5 );
	start = heli_turret_point;
	yes = 0;
	point = [];
	i = 0;
	while ( i < 5 )
	{
		if ( !isDefined( self ) )
		{
			break;
		}
		else
		{
			half_height = self.origin + vectorScale( ( 1, 1, 1 ), 36 );
			tovec = start - half_height;
			tovec_angles = vectorToAngle( tovec );
			forward_norm = anglesToForward( tovec_angles );
			side_norm = anglesToRight( tovec_angles );
			point[ point.size ] = self.origin + vectorScale( ( 1, 1, 1 ), 36 );
			point[ point.size ] = self.origin + ( side_norm * vectorScale( ( 1, 1, 1 ), 15 ) ) + vectorScale( ( 1, 1, 1 ), 10 );
			point[ point.size ] = self.origin + ( side_norm * vectorScale( ( 1, 1, 1 ), 15 ) ) + vectorScale( ( 1, 1, 1 ), 10 );
			point[ point.size ] = point[ 2 ] + vectorScale( ( 1, 1, 1 ), 64 );
			point[ point.size ] = point[ 1 ] + vectorScale( ( 1, 1, 1 ), 64 );
			debug_line( point[ 1 ], point[ 2 ], ( 1, 1, 1 ), 1 );
			debug_line( point[ 2 ], point[ 3 ], ( 1, 1, 1 ), 1 );
			debug_line( point[ 3 ], point[ 4 ], ( 1, 1, 1 ), 1 );
			debug_line( point[ 4 ], point[ 1 ], ( 1, 1, 1 ), 1 );
			if ( bullettracepassed( start, point[ i ], 1, self ) )
			{
				debug_line( start, point[ i ], ( randomint( 10 ) / 10, randomint( 10 ) / 10, randomint( 10 ) / 10 ), 1 );
				yes++;
			}
			waittillframeend;
			i++;
		}
	}
	return yes / 5;
}

waittill_confirm_location()
{
	self endon( "emp_jammed" );
	self endon( "emp_grenaded" );
	self waittill( "confirm_location", location );
	return location;
}

selecthelicopterlocation( hardpointtype )
{
	self beginlocationcomlinkselection( "compass_objpoint_helicopter", 1500 );
	self.selectinglocation = 1;
	self thread endselectionthink();
	location = self waittill_confirm_location();
	if ( !isDefined( location ) )
	{
		return 0;
	}
	if ( self maps/mp/killstreaks/_killstreakrules::iskillstreakallowed( hardpointtype, self.team ) == 0 )
	{
		return 0;
	}
	level.helilocation = location;
	return finishhardpointlocationusage( location, ::nullcallback );
}

nullcallback( arg1, arg2 )
{
	return 1;
}

processcopterassist( destroyedcopter, damagedone )
{
	self endon( "disconnect" );
	destroyedcopter endon( "disconnect" );
	wait 0,05;
	if ( !isDefined( level.teams[ self.team ] ) )
	{
		return;
	}
	if ( self.team == destroyedcopter.team )
	{
		return;
	}
	assist_level = "aircraft_destruction_assist";
	assist_level_value = int( ceil( ( damagedone / destroyedcopter.maxhealth ) * 4 ) );
	if ( assist_level_value > 0 )
	{
		if ( assist_level_value > 3 )
		{
			assist_level_value = 3;
		}
		assist_level = ( assist_level + "_" ) + ( assist_level_value * 25 );
	}
	maps/mp/_scoreevents::processscoreevent( assist_level, self );
}

samturretwatcher()
{
	self endon( "death" );
	self endon( "crashing" );
	self endon( "leaving" );
	level endon( "game_ended" );
	self waittill_any( "turret_on_target", "path start", "near_goal" );
	target_setturretaquire( self, 1 );
}

playpilotdialog( dialog, time, voice, shouldwait )
{
	self endon( "death" );
	level endon( "remote_end" );
	if ( isDefined( time ) )
	{
		wait time;
	}
	if ( !isDefined( self.pilotvoicenumber ) )
	{
		self.pilotvoicenumber = 0;
	}
	if ( isDefined( voice ) )
	{
		voicenumber = voice;
	}
	else
	{
		voicenumber = self.pilotvoicenumber;
	}
	soundalias = level.teamprefix[ self.team ] + voicenumber + "_" + dialog;
	if ( isDefined( self.owner ) )
	{
		self.owner playpilottalking( shouldwait, soundalias );
	}
}

playpilottalking( shouldwait, soundalias )
{
	self endon( "disconnect" );
	self endon( "joined_team" );
	self endon( "joined_spectators" );
	trycounter = 0;
	while ( isDefined( self.pilottalking ) && self.pilottalking && trycounter < 10 )
	{
		if ( isDefined( shouldwait ) && !shouldwait )
		{
			return;
		}
		wait 1;
		trycounter++;
	}
	self.pilottalking = 1;
	self playlocalsound( soundalias );
	wait 3;
	self.pilottalking = 0;
}

watchforearlyleave( hardpointtype )
{
	self endon( "heli_timeup" );
	self waittill_any( "joined_team", "disconnect" );
	self.heli thread heli_leave( hardpointtype );
	self notify( "heli_timeup" );
}
