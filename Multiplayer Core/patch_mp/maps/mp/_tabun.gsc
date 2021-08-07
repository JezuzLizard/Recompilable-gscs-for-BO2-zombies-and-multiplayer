#include maps/mp/gametypes/_battlechatter_mp;
#include maps/mp/killstreaks/_dogs;
#include maps/mp/killstreaks/_airsupport;
#include common_scripts/utility;
#include maps/mp/_utility;

init()
{
	level.tabuninitialgasshockduration = weapons_get_dvar_int( "scr_tabunInitialGasShockDuration", "7" );
	level.tabunwalkingasshockduration = weapons_get_dvar_int( "scr_tabunWalkInGasShockDuration", "4" );
	level.tabungasshockradius = weapons_get_dvar_int( "scr_tabun_shock_radius", "185" );
	level.tabungasshockheight = weapons_get_dvar_int( "scr_tabun_shock_height", "20" );
	level.tabungaspoisonradius = weapons_get_dvar_int( "scr_tabun_effect_radius", "185" );
	level.tabungaspoisonheight = weapons_get_dvar_int( "scr_tabun_shock_height", "20" );
	level.tabungasduration = weapons_get_dvar_int( "scr_tabunGasDuration", "8" );
	level.poisonduration = weapons_get_dvar_int( "scr_poisonDuration", "8" );
	level.poisondamage = weapons_get_dvar_int( "scr_poisonDamage", "13" );
	level.poisondamagehardcore = weapons_get_dvar_int( "scr_poisonDamageHardcore", "5" );
	level.fx_tabun_0 = "tabun_tiny_mp";
	level.fx_tabun_1 = "tabun_small_mp";
	level.fx_tabun_2 = "tabun_medium_mp";
	level.fx_tabun_3 = "tabun_large_mp";
	level.fx_tabun_single = "tabun_center_mp";
	precacheitem( level.fx_tabun_0 );
	precacheitem( level.fx_tabun_1 );
	precacheitem( level.fx_tabun_2 );
	precacheitem( level.fx_tabun_3 );
	precacheitem( level.fx_tabun_single );
	level.fx_tabun_radius0 = weapons_get_dvar_int( "scr_fx_tabun_radius0", 55 );
	level.fx_tabun_radius1 = weapons_get_dvar_int( "scr_fx_tabun_radius1", 55 );
	level.fx_tabun_radius2 = weapons_get_dvar_int( "scr_fx_tabun_radius2", 50 );
	level.fx_tabun_radius3 = weapons_get_dvar_int( "scr_fx_tabun_radius3", 25 );
	level.sound_tabun_start = "wpn_gas_hiss_start";
	level.sound_tabun_loop = "wpn_gas_hiss_lp";
	level.sound_tabun_stop = "wpn_gas_hiss_end";
	level.sound_shock_tabun_start = "";
	level.sound_shock_tabun_loop = "";
	level.sound_shock_tabun_stop = "";
/#
	level thread checkdvarupdates();
#/
}

checkdvarupdates()
{
	while ( 1 )
	{
		level.tabungaspoisonradius = weapons_get_dvar_int( "scr_tabun_effect_radius", level.tabungaspoisonradius );
		level.tabungaspoisonheight = weapons_get_dvar_int( "scr_tabun_shock_height", level.tabungaspoisonheight );
		level.tabungasshockradius = weapons_get_dvar_int( "scr_tabun_shock_radius", level.tabungasshockradius );
		level.tabungasshockheight = weapons_get_dvar_int( "scr_tabun_shock_height", level.tabungasshockheight );
		level.tabuninitialgasshockduration = weapons_get_dvar_int( "scr_tabunInitialGasShockDuration", level.tabuninitialgasshockduration );
		level.tabunwalkingasshockduration = weapons_get_dvar_int( "scr_tabunWalkInGasShockDuration", level.tabunwalkingasshockduration );
		level.tabungasduration = weapons_get_dvar_int( "scr_tabunGasDuration", level.tabungasduration );
		level.poisonduration = weapons_get_dvar_int( "scr_poisonDuration", level.poisonduration );
		level.poisondamage = weapons_get_dvar_int( "scr_poisonDamage", level.poisondamage );
		level.poisondamagehardcore = weapons_get_dvar_int( "scr_poisonDamageHardcore", level.poisondamagehardcore );
		level.fx_tabun_radius0 = weapons_get_dvar_int( "scr_fx_tabun_radius0", level.fx_tabun_radius0 );
		level.fx_tabun_radius1 = weapons_get_dvar_int( "scr_fx_tabun_radius1", level.fx_tabun_radius1 );
		level.fx_tabun_radius2 = weapons_get_dvar_int( "scr_fx_tabun_radius2", level.fx_tabun_radius2 );
		level.fx_tabun_radius3 = weapons_get_dvar_int( "scr_fx_tabun_radius3", level.fx_tabun_radius3 );
		wait 1;
	}
}

watchtabungrenadedetonation( owner )
{
	self waittill( "explode", position, surface );
	if ( !isDefined( level.water_duds ) || level.water_duds == 1 )
	{
		if ( isDefined( surface ) && surface == "water" )
		{
			return;
		}
	}
	if ( weapons_get_dvar_int( "scr_enable_new_tabun", 1 ) )
	{
		generatelocations( position, owner );
	}
	else
	{
		singlelocation( position, owner );
	}
}

damageeffectarea( owner, position, radius, height, killcament )
{
	shockeffectarea = spawn( "trigger_radius", position, 0, radius, height );
	gaseffectarea = spawn( "trigger_radius", position, 0, radius, height );
/#
	if ( getDvarInt( "scr_draw_triggers" ) )
	{
		level thread drawcylinder( position, radius, height, undefined, "tabun_draw_cylinder_stop" );
#/
	}
	owner thread maps/mp/killstreaks/_dogs::flash_dogs( shockeffectarea );
	owner thread maps/mp/killstreaks/_dogs::flash_dogs( gaseffectarea );
	loopwaittime = 0,5;
	durationoftabun = level.tabungasduration;
	while ( durationoftabun > 0 )
	{
		players = get_players();
		i = 0;
		while ( i < players.size )
		{
			if ( level.friendlyfire == 0 )
			{
				if ( players[ i ] != owner )
				{
					if ( !isDefined( owner ) || !isDefined( owner.team ) )
					{
						i++;
						continue;
					}
					else
					{
						if ( level.teambased && players[ i ].team == owner.team )
						{
							i++;
							continue;
						}
					}
				}
				else
				{
					if ( !isDefined( players[ i ].inpoisonarea ) || players[ i ].inpoisonarea == 0 )
					{
						if ( players[ i ] istouching( gaseffectarea ) && players[ i ].sessionstate == "playing" )
						{
							if ( !players[ i ] hasperk( "specialty_proximityprotection" ) )
							{
								trace = bullettrace( position, players[ i ].origin + vectorScale( ( 0, 0, 0 ), 12 ), 0, players[ i ] );
								if ( trace[ "fraction" ] == 1 )
								{
									players[ i ].lastpoisonedby = owner;
									players[ i ] thread damageinpoisonarea( shockeffectarea, killcament, trace, position );
								}
							}
							players[ i ] thread maps/mp/gametypes/_battlechatter_mp::incomingspecialgrenadetracking( "gas" );
						}
					}
				}
			}
			i++;
		}
		wait loopwaittime;
		durationoftabun -= loopwaittime;
	}
	if ( level.tabungasduration < level.poisonduration )
	{
		wait ( level.poisonduration - level.tabungasduration );
	}
	shockeffectarea delete();
	gaseffectarea delete();
/#
	if ( getDvarInt( "scr_draw_triggers" ) )
	{
		level notify( "tabun_draw_cylinder_stop" );
#/
	}
}

damageinpoisonarea( gaseffectarea, killcament, trace, position )
{
	self endon( "disconnect" );
	self endon( "death" );
	self thread watch_death();
	self.inpoisonarea = 1;
	self startpoisoning();
	tabunshocksound = spawn( "script_origin", ( 0, 0, 0 ) );
	tabunshocksound thread deleteentonownerdeath( self );
	tabunshocksound.origin = position;
	tabunshocksound playsound( level.sound_shock_tabun_start );
	tabunshocksound playloopsound( level.sound_shock_tabun_loop );
	timer = 0;
	while ( trace[ "fraction" ] == 1 && isDefined( gaseffectarea ) && self istouching( gaseffectarea ) && self.sessionstate == "playing" && isDefined( self.lastpoisonedby ) )
	{
		damage = level.poisondamage;
		if ( level.hardcoremode )
		{
			damage = level.poisondamagehardcore;
		}
		self dodamage( damage, gaseffectarea.origin, self.lastpoisonedby, killcament, "none", "MOD_GAS", 0, "tabun_gas_mp" );
		if ( self mayapplyscreeneffect() )
		{
			switch( timer )
			{
				case 0:
					self shellshock( "tabun_gas_mp", 1 );
					break;
				timer++;
				continue;
				case 1:
					self shellshock( "tabun_gas_nokick_mp", 1 );
					break;
				timer++;
				continue;
				default:
				}
				timer++;
				if ( timer >= 2 )
				{
					timer = 0;
				}
				self hide_hud();
			}
			wait 1;
			trace = bullettrace( position, self.origin + vectorScale( ( 0, 0, 0 ), 12 ), 0, self );
		}
		tabunshocksound stoploopsound( 0,5 );
		wait 0,5;
		thread playsoundinspace( level.sound_shock_tabun_stop, position );
		wait 0,5;
		tabunshocksound notify( "delete" );
		tabunshocksound delete();
		self show_hud();
		self stoppoisoning();
		self.inpoisonarea = 0;
	}
}

deleteentonownerdeath( owner )
{
	self endon( "delete" );
	owner waittill( "death" );
	self delete();
}

watch_death()
{
	self waittill( "death" );
	self show_hud();
}

hide_hud()
{
	self setclientuivisibilityflag( "hud_visible", 0 );
}

show_hud()
{
	self setclientuivisibilityflag( "hud_visible", 1 );
}

weapons_get_dvar_int( dvar, def )
{
	return int( weapons_get_dvar( dvar, def ) );
}

weapons_get_dvar( dvar, def )
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

generatelocations( position, owner )
{
	onefoot = vectorScale( ( 0, 0, 0 ), 12 );
	startpos = position + onefoot;
/#
	level.tabun_debug = getdvarintdefault( "scr_tabun_debug", 0 );
	if ( level.tabun_debug )
	{
		black = vectorScale( ( 0, 0, 0 ), 0,2 );
		debugstar( startpos, 2000, black );
#/
	}
	spawnalllocs( owner, startpos );
}

singlelocation( position, owner )
{
	spawntimedfx( level.fx_tabun_single, position );
	killcament = spawn( "script_model", position + vectorScale( ( 0, 0, 0 ), 60 ) );
	killcament deleteaftertime( 15 );
	killcament.starttime = getTime();
	damageeffectarea( owner, position, level.tabungaspoisonradius, level.tabungaspoisonheight, killcament );
}

hitpos( start, end, color )
{
	trace = bullettrace( start, end, 0, undefined );
/#
	level.tabun_debug = getdvarintdefault( "scr_tabun_debug", 0 );
	if ( level.tabun_debug )
	{
		debugstar( trace[ "position" ], 2000, color );
	}
	thread debug_line( start, trace[ "position" ], color, 80 );
#/
	return trace[ "position" ];
}

spawnalllocs( owner, startpos )
{
	defaultdistance = weapons_get_dvar_int( "scr_defaultDistanceTabun", 220 );
	cos45 = 0,707;
	negcos45 = -0,707;
	red = ( 0,9, 0,2, 0,2 );
	blue = ( 0,2, 0,2, 0,9 );
	green = ( 0,2, 0,9, 0,2 );
	white = vectorScale( ( 0, 0, 0 ), 0,9 );
	north = startpos + ( defaultdistance, 0, 0 );
	south = startpos - ( defaultdistance, 0, 0 );
	east = startpos + ( 0, defaultdistance, 0 );
	west = startpos - ( 0, defaultdistance, 0 );
	nw = startpos + ( cos45 * defaultdistance, negcos45 * defaultdistance, 0 );
	ne = startpos + ( cos45 * defaultdistance, cos45 * defaultdistance, 0 );
	sw = startpos + ( negcos45 * defaultdistance, negcos45 * defaultdistance, 0 );
	se = startpos + ( negcos45 * defaultdistance, cos45 * defaultdistance, 0 );
	locations = [];
	locations[ "color" ] = [];
	locations[ "loc" ] = [];
	locations[ "tracePos" ] = [];
	locations[ "distSqrd" ] = [];
	locations[ "fxtoplay" ] = [];
	locations[ "radius" ] = [];
	locations[ "color" ][ 0 ] = red;
	locations[ "color" ][ 1 ] = red;
	locations[ "color" ][ 2 ] = blue;
	locations[ "color" ][ 3 ] = blue;
	locations[ "color" ][ 4 ] = green;
	locations[ "color" ][ 5 ] = green;
	locations[ "color" ][ 6 ] = white;
	locations[ "color" ][ 7 ] = white;
	locations[ "point" ][ 0 ] = north;
	locations[ "point" ][ 1 ] = ne;
	locations[ "point" ][ 2 ] = east;
	locations[ "point" ][ 3 ] = se;
	locations[ "point" ][ 4 ] = south;
	locations[ "point" ][ 5 ] = sw;
	locations[ "point" ][ 6 ] = west;
	locations[ "point" ][ 7 ] = nw;
	count = 0;
	while ( count < 8 )
	{
		trace = hitpos( startpos, locations[ "point" ][ count ], locations[ "color" ][ count ] );
		locations[ "tracePos" ][ count ] = trace;
		locations[ "loc" ][ count ] = ( startpos / 2 ) + ( trace / 2 );
		locations[ "loc" ][ count ] -= vectorScale( ( 0, 0, 0 ), 12 );
		locations[ "distSqrd" ][ count ] = distancesquared( startpos, trace );
		count++;
	}
	centroid = getcentroid( locations );
	killcament = spawn( "script_model", centroid + vectorScale( ( 0, 0, 0 ), 60 ) );
	killcament deleteaftertime( 15 );
	killcament.starttime = getTime();
	center = getcenter( locations );
	i = 0;
	while ( i < 8 )
	{
		fxtoplay = setuptabunfx( owner, locations, i );
		switch( fxtoplay )
		{
			case 0:
				locations[ "fxtoplay" ][ i ] = level.fx_tabun_0;
				locations[ "radius" ][ i ] = level.fx_tabun_radius0;
				break;
			i++;
			continue;
			case 1:
				locations[ "fxtoplay" ][ i ] = level.fx_tabun_1;
				locations[ "radius" ][ i ] = level.fx_tabun_radius1;
				break;
			i++;
			continue;
			case 2:
				locations[ "fxtoplay" ][ i ] = level.fx_tabun_2;
				locations[ "radius" ][ i ] = level.fx_tabun_radius2;
				break;
			i++;
			continue;
			case 3:
				locations[ "fxtoplay" ][ i ] = level.fx_tabun_3;
				locations[ "radius" ][ i ] = level.fx_tabun_radius3;
				break;
			i++;
			continue;
			default:
				locations[ "radius" ][ i ] = 0;
		}
		i++;
	}
	singleeffect = 1;
	freepassused = 0;
	i = 0;
	while ( i < 8 )
	{
		if ( locations[ "radius" ][ i ] != level.fx_tabun_radius0 )
		{
			if ( freepassused == 0 && locations[ "radius" ][ i ] == level.fx_tabun_radius1 )
			{
				freepassused = 1;
				i++;
				continue;
			}
			else
			{
				singleeffect = 0;
			}
		}
		i++;
	}
	onefoot = vectorScale( ( 0, 0, 0 ), 12 );
	startpos -= onefoot;
	thread playtabunsound( startpos );
	if ( singleeffect == 1 )
	{
		singlelocation( startpos, owner );
	}
	else
	{
		spawntimedfx( level.fx_tabun_3, startpos );
		count = 0;
		while ( count < 8 )
		{
			if ( isDefined( locations[ "fxtoplay" ][ count ] ) )
			{
				spawntimedfx( locations[ "fxtoplay" ][ count ], locations[ "loc" ][ count ] );
				thread damageeffectarea( owner, locations[ "loc" ][ count ], locations[ "radius" ][ count ], locations[ "radius" ][ count ], killcament );
			}
			count++;
		}
	}
}

playtabunsound( position )
{
	tabunsound = spawn( "script_origin", ( 0, 0, 0 ) );
	tabunsound.origin = position;
	tabunsound playsound( level.sound_tabun_start );
	tabunsound playloopsound( level.sound_tabun_loop );
	wait level.tabungasduration;
	thread playsoundinspace( level.sound_tabun_stop, position );
	tabunsound stoploopsound( 0,5 );
	wait 0,5;
	tabunsound delete();
}

setuptabunfx( owner, locations, count )
{
	fxtoplay = undefined;
	previous = count - 1;
	if ( previous < 0 )
	{
		previous += locations[ "loc" ].size;
	}
	next = count + 1;
	if ( next >= locations[ "loc" ].size )
	{
		next -= locations[ "loc" ].size;
	}
	effect0dist = level.fx_tabun_radius0 * level.fx_tabun_radius0;
	effect1dist = level.fx_tabun_radius1 * level.fx_tabun_radius1;
	effect2dist = level.fx_tabun_radius2 * level.fx_tabun_radius2;
	effect3dist = level.fx_tabun_radius3 * level.fx_tabun_radius3;
	effect4dist = level.fx_tabun_radius3;
	fxtoplay = -1;
	if ( locations[ "distSqrd" ][ count ] > effect0dist && locations[ "distSqrd" ][ previous ] > effect1dist && locations[ "distSqrd" ][ next ] > effect1dist )
	{
		fxtoplay = 0;
	}
	else
	{
		if ( locations[ "distSqrd" ][ count ] > effect1dist && locations[ "distSqrd" ][ previous ] > effect2dist && locations[ "distSqrd" ][ next ] > effect2dist )
		{
			fxtoplay = 1;
		}
		else
		{
			if ( locations[ "distSqrd" ][ count ] > effect2dist && locations[ "distSqrd" ][ previous ] > effect3dist && locations[ "distSqrd" ][ next ] > effect3dist )
			{
				fxtoplay = 2;
			}
			else
			{
				if ( locations[ "distSqrd" ][ count ] > effect3dist && locations[ "distSqrd" ][ previous ] > effect4dist && locations[ "distSqrd" ][ next ] > effect4dist )
				{
					fxtoplay = 3;
				}
			}
		}
	}
	return fxtoplay;
}

getcentroid( locations )
{
	centroid = ( 0, 0, 0 );
	i = 0;
	while ( i < locations[ "loc" ].size )
	{
		centroid += locations[ "loc" ][ i ] / locations[ "loc" ].size;
		i++;
	}
/#
	level.tabun_debug = getdvarintdefault( "scr_tabun_debug", 0 );
	if ( level.tabun_debug )
	{
		purple = ( 0,9, 0,2, 0,9 );
		debugstar( centroid, 2000, purple );
#/
	}
	return centroid;
}

getcenter( locations )
{
	center = ( 0, 0, 0 );
	curx = locations[ "tracePos" ][ 0 ][ 0 ];
	cury = locations[ "tracePos" ][ 0 ][ 1 ];
	minx = curx;
	maxx = curx;
	miny = cury;
	maxy = cury;
	i = 1;
	while ( i < locations[ "tracePos" ].size )
	{
		curx = locations[ "tracePos" ][ i ][ 0 ];
		cury = locations[ "tracePos" ][ i ][ 1 ];
		if ( curx > maxx )
		{
			maxx = curx;
		}
		else
		{
			if ( curx < minx )
			{
				minx = curx;
			}
		}
		if ( cury > maxy )
		{
			maxy = cury;
			i++;
			continue;
		}
		else
		{
			if ( cury < miny )
			{
				miny = cury;
			}
		}
		i++;
	}
	avgx = ( maxx + minx ) / 2;
	avgy = ( maxy + miny ) / 2;
	center = ( avgx, avgy, locations[ "tracePos" ][ 0 ][ 2 ] );
/#
	level.tabun_debug = getdvarintdefault( "scr_tabun_debug", 0 );
	if ( level.tabun_debug )
	{
		cyan = ( 0,2, 0,9, 0,9 );
		debugstar( center, 2000, cyan );
#/
	}
	return center;
}
