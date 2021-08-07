#include maps/mp/gametypes/_deathicons;
#include maps/mp/mp_vertigo_doors;
#include maps/mp/_compass;
#include maps/mp/_utility;

main()
{
	level.levelspawndvars = ::levelspawndvars;
	level.ragdoll_override = ::ragdoll_override;
	maps/mp/mp_vertigo_fx::main();
	maps/mp/_load::main();
	maps/mp/mp_vertigo_amb::main();
	maps/mp/_compass::setupminimap( "compass_map_mp_vertigo" );
	setdvar( "compassmaxrange", "2100" );
	game[ "strings" ][ "war_callsign_a" ] = &"MPUI_CALLSIGN_MAPNAME_A";
	game[ "strings" ][ "war_callsign_b" ] = &"MPUI_CALLSIGN_MAPNAME_B";
	game[ "strings" ][ "war_callsign_c" ] = &"MPUI_CALLSIGN_MAPNAME_C";
	game[ "strings" ][ "war_callsign_d" ] = &"MPUI_CALLSIGN_MAPNAME_D";
	game[ "strings" ][ "war_callsign_e" ] = &"MPUI_CALLSIGN_MAPNAME_E";
	game[ "strings_menu" ][ "war_callsign_a" ] = "@MPUI_CALLSIGN_MAPNAME_A";
	game[ "strings_menu" ][ "war_callsign_b" ] = "@MPUI_CALLSIGN_MAPNAME_B";
	game[ "strings_menu" ][ "war_callsign_c" ] = "@MPUI_CALLSIGN_MAPNAME_C";
	game[ "strings_menu" ][ "war_callsign_d" ] = "@MPUI_CALLSIGN_MAPNAME_D";
	game[ "strings_menu" ][ "war_callsign_e" ] = "@MPUI_CALLSIGN_MAPNAME_E";
	level thread waitforglassbreak();
	if ( getgametypesetting( "allowMapScripting" ) )
	{
		level maps/mp/mp_vertigo_doors::init();
	}
}

levelspawndvars( reset_dvars )
{
	ss = level.spawnsystem;
	ss.enemy_influencer_radius = set_dvar_float_if_unset( "scr_spawn_enemy_influencer_radius", "2400", reset_dvars );
	ss.hq_objective_influencer_inner_radius = set_dvar_float_if_unset( "scr_spawn_hq_objective_influencer_inner_radius", "1400", reset_dvars );
}

waitforglassbreak()
{
	if ( glassexploderssetupcorrectly( 1000, 3 ) == 0 )
	{
		return;
	}
	if ( glassexploderssetupcorrectly( 1004, 3 ) == 0 )
	{
		return;
	}
	if ( glassexploderssetupcorrectly( 1007, 3 ) == 0 )
	{
		return;
	}
	for ( ;; )
	{
		level waittill( "glass_smash", origin );
		playglassexploder( origin, 1000, 3 );
		playglassexploder( origin, 1004, 3 );
		playglassexploder( origin, 1007, 3 );
	}
}

playglassexploder( origin, exploderbase, explodercount )
{
	distancesq = distancesquared( origin, level.createfxexploders[ exploderbase ][ 0 ].v[ "origin" ] );
	if ( distancesq > 21000 )
	{
		return;
	}
	nearestpane = exploderbase;
	if ( distancesq > 5000 )
	{
		nearestpane = -1;
		distancesq = 5000;
	}
	nearestpanedistsq = distancesq;
	glassexploderindex = 1;
	while ( glassexploderindex < explodercount )
	{
		glassexploder = glassexploderindex + exploderbase;
		currentdistsq = distancesquared( origin, level.createfxexploders[ glassexploder ][ 0 ].v[ "origin" ] );
		if ( currentdistsq < nearestpanedistsq )
		{
			nearestpane = glassexploder;
			nearestpanedistsq = currentdistsq;
		}
		glassexploderindex++;
	}
	if ( nearestpane != -1 )
	{
		exploder( nearestpane );
		level thread window_smash_wind_sound( origin );
	}
}

window_smash_wind_sound( origin )
{
	wind_ent = spawn( "script_origin", origin );
	wind_ent playloopsound( "evt_window_wind", 1 );
	level waittill( "game_ended" );
	wind_ent stoploopsound( 0,5 );
	wind_ent delete();
}

glassexploderssetupcorrectly( exploderbase, explodercount )
{
	glassexploderindex = 0;
	while ( glassexploderindex < explodercount )
	{
		glassexploder = glassexploderindex + exploderbase;
		if ( !isDefined( level.createfxexploders[ glassexploder ] ) )
		{
/#
			assertmsg( "Glass exploder " + glassexploder + " is undefined" );
#/
			return 0;
		}
		if ( isDefined( level.createfxexploders[ glassexploder ][ 0 ] ) || !isDefined( level.createfxexploders[ glassexploder ][ 0 ].v ) && !isDefined( level.createfxexploders[ glassexploder ][ 0 ].v[ "origin" ] ) )
		{
/#
			assertmsg( "Glass exploder " + glassexploder + " is undefined" );
#/
			return 0;
		}
		glassexploderindex++;
	}
	return 1;
}

ragdoll_override( idamage, smeansofdeath, sweapon, shitloc, vdir, vattackerorigin, deathanimduration, einflictor, ragdoll_jib, body )
{
	if ( smeansofdeath == "MOD_FALLING" )
	{
		deathanim = body getcorpseanim();
		startfrac = deathanimduration / 1000;
		if ( animhasnotetrack( deathanim, "start_ragdoll" ) )
		{
			times = getnotetracktimes( deathanim, "start_ragdoll" );
			if ( isDefined( times ) )
			{
				startfrac = times[ 0 ];
			}
		}
		self.body = body;
		if ( !isDefined( self.switching_teams ) )
		{
			thread maps/mp/gametypes/_deathicons::adddeathicon( body, self, self.team, 5 );
		}
		thread startragdollonground( startfrac );
		return 1;
	}
	return 0;
}

startragdollonground( deathanimduration )
{
	timer = 0;
	while ( timer < deathanimduration )
	{
		if ( !isDefined( self ) || !isDefined( self.body ) )
		{
			return;
		}
		if ( self isonground() )
		{
			break;
		}
		else
		{
			wait 0,05;
			timer += 0,05;
		}
	}
	if ( !isDefined( self ) || !isDefined( self.body ) )
	{
		return;
	}
	self.body startragdoll();
}
