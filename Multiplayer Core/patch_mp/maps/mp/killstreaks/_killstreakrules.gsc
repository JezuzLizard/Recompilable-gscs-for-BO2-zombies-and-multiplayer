#include maps/mp/killstreaks/_emp;
#include maps/mp/_popups;
#include common_scripts/utility;
#include maps/mp/gametypes/_hud_util;
#include maps/mp/_utility;

init()
{
	level.killstreakrules = [];
	level.killstreaktype = [];
	level.killstreaks_triggered = [];
	level.killstreak_counter = 0;
	createrule( "vehicle", 7, 7 );
	createrule( "firesupport", 1, 1 );
	createrule( "airsupport", 1, 1 );
	createrule( "playercontrolledchopper", 1, 1 );
	createrule( "chopperInTheAir", 1, 1 );
	createrule( "chopper", 2, 1 );
	createrule( "qrdrone", 3, 2 );
	createrule( "dogs", 1, 1 );
	createrule( "turret", 8, 4 );
	createrule( "weapon", 12, 6 );
	createrule( "satellite", 20, 10 );
	createrule( "supplydrop", 4, 4 );
	createrule( "rcxd", 3, 2 );
	createrule( "targetableent", 32, 32 );
	createrule( "missileswarm", 1, 1 );
	createrule( "radar", 20, 10 );
	createrule( "counteruav", 20, 10 );
	createrule( "emp", 2, 1 );
	createrule( "ai_tank", 4, 2 );
	createrule( "straferun", 1, 1 );
	createrule( "planemortar", 1, 1 );
	createrule( "remotemortar", 1, 1 );
	createrule( "missiledrone", 3, 3 );
	addkillstreaktorule( "helicopter_mp", "vehicle", 1, 1 );
	addkillstreaktorule( "helicopter_mp", "chopper", 1, 1 );
	addkillstreaktorule( "helicopter_mp", "playercontrolledchopper", 0, 1 );
	addkillstreaktorule( "helicopter_mp", "chopperInTheAir", 1, 0 );
	addkillstreaktorule( "helicopter_mp", "targetableent", 1, 1 );
	addkillstreaktorule( "helicopter_x2_mp", "vehicle", 1, 1 );
	addkillstreaktorule( "helicopter_x2_mp", "chopper", 1, 1 );
	addkillstreaktorule( "helicopter_x2_mp", "playercontrolledchopper", 0, 1 );
	addkillstreaktorule( "helicopter_x2_mp", "chopperInTheAir", 1, 0 );
	addkillstreaktorule( "helicopter_x2_mp", "targetableent", 1, 1 );
	addkillstreaktorule( "helicopter_comlink_mp", "vehicle", 1, 1 );
	addkillstreaktorule( "helicopter_comlink_mp", "chopper", 1, 1 );
	addkillstreaktorule( "helicopter_comlink_mp", "playercontrolledchopper", 0, 1 );
	addkillstreaktorule( "helicopter_comlink_mp", "chopperInTheAir", 1, 0 );
	addkillstreaktorule( "helicopter_comlink_mp", "targetableent", 1, 1 );
	addkillstreaktorule( "helicopter_player_firstperson_mp", "vehicle", 1, 1 );
	addkillstreaktorule( "helicopter_player_firstperson_mp", "playercontrolledchopper", 1, 1 );
	addkillstreaktorule( "helicopter_player_firstperson_mp", "chopperInTheAir", 1, 1 );
	addkillstreaktorule( "helicopter_player_firstperson_mp", "targetableent", 1, 1 );
	addkillstreaktorule( "helicopter_guard_mp", "airsupport", 1, 1 );
	addkillstreaktorule( "helicopter_gunner_mp", "vehicle", 1, 1 );
	addkillstreaktorule( "helicopter_gunner_mp", "playercontrolledchopper", 1, 1 );
	addkillstreaktorule( "helicopter_gunner_mp", "chopperInTheAir", 1, 1 );
	addkillstreaktorule( "helicopter_gunner_mp", "targetableent", 1, 1 );
	addkillstreaktorule( "helicopter_player_gunner_mp", "vehicle", 1, 1 );
	addkillstreaktorule( "helicopter_player_gunner_mp", "playercontrolledchopper", 1, 1 );
	addkillstreaktorule( "helicopter_player_gunner_mp", "chopperInTheAir", 1, 1 );
	addkillstreaktorule( "helicopter_player_gunner_mp", "targetableent", 1, 1 );
	addkillstreaktorule( "rcbomb_mp", "rcxd", 1, 1 );
	addkillstreaktorule( "supply_drop_mp", "vehicle", 1, 1 );
	addkillstreaktorule( "supply_drop_mp", "supplydrop", 1, 1 );
	addkillstreaktorule( "supply_drop_mp", "targetableent", 1, 1 );
	addkillstreaktorule( "supply_station_mp", "vehicle", 1, 1 );
	addkillstreaktorule( "inventory_supply_drop_mp", "vehicle", 1, 1 );
	addkillstreaktorule( "inventory_supply_drop_mp", "supplydrop", 1, 1 );
	addkillstreaktorule( "inventory_supply_drop_mp", "targetableent", 1, 1 );
	addkillstreaktorule( "supply_station_mp", "supplydrop", 1, 1 );
	addkillstreaktorule( "supply_station_mp", "targetableent", 1, 1 );
	addkillstreaktorule( "tow_turret_drop_mp", "vehicle", 1, 1 );
	addkillstreaktorule( "turret_drop_mp", "vehicle", 1, 1 );
	addkillstreaktorule( "m220_tow_drop_mp", "vehicle", 1, 1 );
	addkillstreaktorule( "tow_turret_drop_mp", "supplydrop", 1, 1 );
	addkillstreaktorule( "turret_drop_mp", "supplydrop", 1, 1 );
	addkillstreaktorule( "m220_tow_drop_mp", "supplydrop", 1, 1 );
	addkillstreaktorule( "m220_tow_killstreak_mp", "weapon", 1, 1 );
	addkillstreaktorule( "autoturret_mp", "turret", 1, 1 );
	addkillstreaktorule( "auto_tow_mp", "turret", 1, 1 );
	addkillstreaktorule( "microwaveturret_mp", "turret", 1, 1 );
	addkillstreaktorule( "minigun_mp", "weapon", 1, 1 );
	addkillstreaktorule( "minigun_drop_mp", "weapon", 1, 1 );
	addkillstreaktorule( "inventory_minigun_mp", "weapon", 1, 1 );
	addkillstreaktorule( "m32_mp", "weapon", 1, 1 );
	addkillstreaktorule( "m32_drop_mp", "weapon", 1, 1 );
	addkillstreaktorule( "inventory_m32_mp", "weapon", 1, 1 );
	addkillstreaktorule( "m202_flash_mp", "weapon", 1, 1 );
	addkillstreaktorule( "m220_tow_mp", "weapon", 1, 1 );
	addkillstreaktorule( "mp40_drop_mp", "weapon", 1, 1 );
	addkillstreaktorule( "dogs_mp", "dogs", 1, 1 );
	addkillstreaktorule( "dogs_lvl2_mp", "dogs", 1, 1 );
	addkillstreaktorule( "dogs_lvl3_mp", "dogs", 1, 1 );
	addkillstreaktorule( "artillery_mp", "firesupport", 1, 1 );
	addkillstreaktorule( "mortar_mp", "firesupport", 1, 1 );
	addkillstreaktorule( "napalm_mp", "vehicle", 1, 1 );
	addkillstreaktorule( "napalm_mp", "airsupport", 1, 1 );
	addkillstreaktorule( "airstrike_mp", "vehicle", 1, 1 );
	addkillstreaktorule( "airstrike_mp", "airsupport", 1, 1 );
	addkillstreaktorule( "radardirection_mp", "satellite", 1, 1 );
	addkillstreaktorule( "radar_mp", "radar", 1, 1 );
	addkillstreaktorule( "radar_mp", "targetableent", 1, 1 );
	addkillstreaktorule( "counteruav_mp", "counteruav", 1, 1 );
	addkillstreaktorule( "counteruav_mp", "targetableent", 1, 1 );
	addkillstreaktorule( "emp_mp", "emp", 1, 1 );
	addkillstreaktorule( "remote_mortar_mp", "targetableent", 1, 1 );
	addkillstreaktorule( "remote_mortar_mp", "remotemortar", 1, 1 );
	addkillstreaktorule( "remote_missile_mp", "targetableent", 1, 1 );
	addkillstreaktorule( "qrdrone_mp", "vehicle", 1, 1 );
	addkillstreaktorule( "qrdrone_mp", "qrdrone", 1, 1 );
	addkillstreaktorule( "missile_swarm_mp", "missileswarm", 1, 1 );
	addkillstreaktorule( "missile_drone_mp", "missiledrone", 1, 1 );
	addkillstreaktorule( "inventory_missile_drone_mp", "missiledrone", 1, 1 );
	addkillstreaktorule( "straferun_mp", "straferun", 1, 1 );
	addkillstreaktorule( "ai_tank_drop_mp", "ai_tank", 1, 1 );
	addkillstreaktorule( "inventory_ai_tank_drop_mp", "ai_tank", 1, 1 );
	addkillstreaktorule( "planemortar_mp", "planemortar", 1, 1 );
}

createrule( rule, maxallowable, maxallowableperteam )
{
	if ( !level.teambased )
	{
		if ( maxallowable > maxallowableperteam )
		{
			maxallowable = maxallowableperteam;
		}
	}
	level.killstreakrules[ rule ] = spawnstruct();
	level.killstreakrules[ rule ].cur = 0;
	level.killstreakrules[ rule ].curteam = [];
	level.killstreakrules[ rule ].max = maxallowable;
	level.killstreakrules[ rule ].maxperteam = maxallowableperteam;
}

addkillstreaktorule( hardpointtype, rule, counttowards, checkagainst )
{
	if ( !isDefined( level.killstreaktype[ hardpointtype ] ) )
	{
		level.killstreaktype[ hardpointtype ] = [];
	}
	keys = getarraykeys( level.killstreaktype[ hardpointtype ] );
/#
	assert( isDefined( level.killstreakrules[ rule ] ) );
#/
	if ( !isDefined( level.killstreaktype[ hardpointtype ][ rule ] ) )
	{
		level.killstreaktype[ hardpointtype ][ rule ] = spawnstruct();
	}
	level.killstreaktype[ hardpointtype ][ rule ].counts = counttowards;
	level.killstreaktype[ hardpointtype ][ rule ].checks = checkagainst;
}

killstreakstart( hardpointtype, team, hacked, displayteammessage )
{
/#
	assert( isDefined( team ), "team needs to be defined" );
#/
	if ( self iskillstreakallowed( hardpointtype, team ) == 0 )
	{
		return -1;
	}
/#
	assert( isDefined( hardpointtype ) );
#/
	if ( !isDefined( hacked ) )
	{
		hacked = 0;
	}
	if ( !isDefined( displayteammessage ) )
	{
		displayteammessage = 1;
	}
	if ( displayteammessage == 1 )
	{
		if ( isDefined( level.killstreaks[ hardpointtype ] ) && isDefined( level.killstreaks[ hardpointtype ].inboundtext ) && !hacked )
		{
			level thread maps/mp/_popups::displaykillstreakteammessagetoall( hardpointtype, self );
		}
	}
	keys = getarraykeys( level.killstreaktype[ hardpointtype ] );
	_a187 = keys;
	_k187 = getFirstArrayKey( _a187 );
	while ( isDefined( _k187 ) )
	{
		key = _a187[ _k187 ];
		if ( !level.killstreaktype[ hardpointtype ][ key ].counts )
		{
		}
		else
		{
/#
			assert( isDefined( level.killstreakrules[ key ] ) );
#/
			level.killstreakrules[ key ].cur++;
			if ( level.teambased )
			{
				if ( !isDefined( level.killstreakrules[ key ].curteam[ team ] ) )
				{
					level.killstreakrules[ key ].curteam[ team ] = 0;
				}
				level.killstreakrules[ key ].curteam[ team ]++;
			}
		}
		_k187 = getNextArrayKey( _a187, _k187 );
	}
	level notify( "killstreak_started" );
	killstreak_id = level.killstreak_counter;
	level.killstreak_counter++;
	killstreak_data = [];
	killstreak_data[ "caller" ] = self getxuid();
	killstreak_data[ "spawnid" ] = getplayerspawnid( self );
	killstreak_data[ "starttime" ] = getTime();
	killstreak_data[ "type" ] = hardpointtype;
	killstreak_data[ "endtime" ] = 0;
	level.killstreaks_triggered[ killstreak_id ] = killstreak_data;
/#
	killstreak_debug_text( "Started killstreak: " + hardpointtype + " for team: " + team + " id: " + killstreak_id );
#/
	return killstreak_id;
}

killstreakstop( hardpointtype, team, id )
{
/#
	assert( isDefined( team ), "team needs to be defined" );
#/
/#
	assert( isDefined( hardpointtype ) );
#/
/#
	killstreak_debug_text( "Stopped killstreak: " + hardpointtype + " for team: " + team + " id: " + id );
#/
	keys = getarraykeys( level.killstreaktype[ hardpointtype ] );
	_a238 = keys;
	_k238 = getFirstArrayKey( _a238 );
	while ( isDefined( _k238 ) )
	{
		key = _a238[ _k238 ];
		if ( !level.killstreaktype[ hardpointtype ][ key ].counts )
		{
		}
		else
		{
/#
			assert( isDefined( level.killstreakrules[ key ] ) );
#/
			level.killstreakrules[ key ].cur--;

/#
			assert( level.killstreakrules[ key ].cur >= 0 );
#/
			if ( level.teambased )
			{
/#
				assert( isDefined( team ) );
#/
/#
				assert( isDefined( level.killstreakrules[ key ].curteam[ team ] ) );
#/
				level.killstreakrules[ key ].curteam[ team ]--;

/#
				assert( level.killstreakrules[ key ].curteam[ team ] >= 0 );
#/
			}
		}
		_k238 = getNextArrayKey( _a238, _k238 );
	}
	if ( !isDefined( id ) || id == -1 )
	{
		killstreak_debug_text( "WARNING! Invalid killstreak id detected for " + hardpointtype );
		bbprint( "mpkillstreakuses", "starttime %d endtime %d name %s team %s", 0, getTime(), hardpointtype, team );
		return;
	}
	level.killstreaks_triggered[ id ][ "endtime" ] = getTime();
	bbprint( "mpkillstreakuses", "starttime %d endtime %d spawnid %d name %s team %s", level.killstreaks_triggered[ id ][ "starttime" ], level.killstreaks_triggered[ id ][ "endtime" ], level.killstreaks_triggered[ id ][ "spawnid" ], hardpointtype, team );
	if ( isDefined( level.killstreaks[ hardpointtype ].menuname ) )
	{
		recordstreakindex = level.killstreakindices[ level.killstreaks[ hardpointtype ].menuname ];
		if ( isDefined( recordstreakindex ) )
		{
			if ( isDefined( self.owner ) )
			{
				self.owner recordkillstreakendevent( recordstreakindex );
				return;
			}
			else
			{
				if ( isplayer( self ) )
				{
					self recordkillstreakendevent( recordstreakindex );
				}
			}
		}
	}
}

iskillstreakallowed( hardpointtype, team )
{
/#
	assert( isDefined( team ), "team needs to be defined" );
#/
/#
	assert( isDefined( hardpointtype ) );
#/
	isallowed = 1;
	keys = getarraykeys( level.killstreaktype[ hardpointtype ] );
	_a308 = keys;
	_k308 = getFirstArrayKey( _a308 );
	while ( isDefined( _k308 ) )
	{
		key = _a308[ _k308 ];
		if ( !level.killstreaktype[ hardpointtype ][ key ].checks )
		{
		}
		else
		{
			if ( level.killstreakrules[ key ].max != 0 )
			{
				if ( level.killstreakrules[ key ].cur >= level.killstreakrules[ key ].max )
				{
/#
					killstreak_debug_text( "Exceeded " + key + " overall" );
#/
					isallowed = 0;
					break;
				}
			}
			else if ( level.teambased && level.killstreakrules[ key ].maxperteam != 0 )
			{
				if ( !isDefined( level.killstreakrules[ key ].curteam[ team ] ) )
				{
					level.killstreakrules[ key ].curteam[ team ] = 0;
				}
				if ( level.killstreakrules[ key ].curteam[ team ] >= level.killstreakrules[ key ].maxperteam )
				{
					isallowed = 0;
/#
					killstreak_debug_text( "Exceeded " + key + " team" );
#/
					break;
				}
			}
		}
		else
		{
			_k308 = getNextArrayKey( _a308, _k308 );
		}
	}
	if ( isDefined( self.laststand ) && self.laststand )
	{
/#
		killstreak_debug_text( "In LastStand" );
#/
		isallowed = 0;
	}
	if ( self isempjammed() )
	{
/#
		killstreak_debug_text( "EMP active" );
#/
		isallowed = 0;
		if ( self maps/mp/killstreaks/_emp::isenemyempkillstreakactive() )
		{
			if ( isDefined( level.empendtime ) )
			{
				secondsleft = int( ( level.empendtime - getTime() ) / 1000 );
				if ( secondsleft > 0 )
				{
					self iprintlnbold( &"KILLSTREAK_NOT_AVAILABLE_EMP_ACTIVE", secondsleft );
					return 0;
				}
			}
		}
	}
	if ( isallowed == 0 )
	{
		if ( isDefined( level.killstreaks[ hardpointtype ] ) && isDefined( level.killstreaks[ hardpointtype ].notavailabletext ) )
		{
			self iprintlnbold( level.killstreaks[ hardpointtype ].notavailabletext );
			if ( hardpointtype != "helicopter_comlink_mp" && hardpointtype != "helicopter_guard_mp" && hardpointtype != "helicopter_player_gunner_mp" && hardpointtype != "remote_mortar_mp" && hardpointtype != "inventory_supply_drop_mp" || hardpointtype == "supply_drop_mp" && hardpointtype == "straferun_mp" )
			{
				pilotvoicenumber = randomintrange( 0, 3 );
				soundalias = level.teamprefix[ self.team ] + pilotvoicenumber + "_" + "kls_full";
				self playlocalsound( soundalias );
			}
		}
	}
	return isallowed;
}

killstreak_debug_text( text )
{
/#
	level.killstreak_rule_debug = getdvarintdefault( "scr_killstreak_rule_debug", 0 );
	if ( isDefined( level.killstreak_rule_debug ) )
	{
		if ( level.killstreak_rule_debug == 1 )
		{
			iprintln( "KSR: " + text + "\n" );
			return;
		}
		else
		{
			if ( level.killstreak_rule_debug == 2 )
			{
				iprintlnbold( "KSR: " + text );
#/
			}
		}
	}
}
