#include maps/mp/killstreaks/_emp;
#include maps/mp/_tacticalinsertion;
#include maps/mp/gametypes/_weaponobjects;
#include maps/mp/gametypes/_hostmigration;
#include maps/mp/killstreaks/_killstreakrules;
#include maps/mp/killstreaks/_killstreaks;
#include common_scripts/utility;
#include maps/mp/_utility;

init()
{
	level._effect[ "emp_flash" ] = loadfx( "weapon/emp/fx_emp_explosion" );
	_a9 = level.teams;
	_k9 = getFirstArrayKey( _a9 );
	while ( isDefined( _k9 ) )
	{
		team = _a9[ _k9 ];
		level.teamemping[ team ] = 0;
		_k9 = getNextArrayKey( _a9, _k9 );
	}
	level.empplayer = undefined;
	level.emptimeout = 40;
	level.empowners = [];
	if ( level.teambased )
	{
		level thread emp_teamtracker();
	}
	else
	{
		level thread emp_playertracker();
	}
	level thread onplayerconnect();
	registerkillstreak( "emp_mp", "emp_mp", "killstreak_emp", "emp_used", ::emp_use );
	registerkillstreakstrings( "emp_mp", &"KILLSTREAK_EARNED_EMP", &"KILLSTREAK_EMP_NOT_AVAILABLE", &"KILLSTREAK_EMP_INBOUND" );
	registerkillstreakdialog( "emp_mp", "mpl_killstreak_emp_activate", "kls_emp_used", "", "kls_emp_enemy", "", "kls_emp_ready" );
	registerkillstreakdevdvar( "emp_mp", "scr_giveemp" );
	maps/mp/killstreaks/_killstreaks::createkillstreaktimer( "emp_mp" );
/#
	set_dvar_float_if_unset( "scr_emp_timeout", 40 );
	set_dvar_int_if_unset( "scr_emp_damage_debug", 0 );
#/
}

onplayerconnect()
{
	for ( ;; )
	{
		level waittill( "connected", player );
		player thread onplayerspawned();
	}
}

onplayerspawned()
{
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "spawned_player" );
		if ( level.teambased || emp_isteamemped( self.team ) && !level.teambased && isDefined( level.empplayer ) && level.empplayer != self )
		{
			self setempjammed( 1 );
		}
	}
}

emp_isteamemped( check_team )
{
	_a64 = level.teams;
	_k64 = getFirstArrayKey( _a64 );
	while ( isDefined( _k64 ) )
	{
		team = _a64[ _k64 ];
		if ( team == check_team )
		{
		}
		else
		{
			if ( level.teamemping[ team ] )
			{
				return 1;
			}
		}
		_k64 = getNextArrayKey( _a64, _k64 );
	}
	return 0;
}

emp_use( lifeid )
{
/#
	assert( isDefined( self ) );
#/
	killstreak_id = self maps/mp/killstreaks/_killstreakrules::killstreakstart( "emp_mp", self.team, 0, 1 );
	if ( killstreak_id == -1 )
	{
		return 0;
	}
	myteam = self.pers[ "team" ];
	if ( level.teambased )
	{
		self thread emp_jamotherteams( myteam, killstreak_id );
	}
	else
	{
		self thread emp_jamplayers( self, killstreak_id );
	}
	self.emptime = getTime();
	self notify( "used_emp" );
	self playlocalsound( "mpl_killstreak_emp_activate" );
	self maps/mp/killstreaks/_killstreaks::playkillstreakstartdialog( "emp_mp", self.pers[ "team" ] );
	level.globalkillstreakscalled++;
	self addweaponstat( "emp_mp", "used", 1 );
	return 1;
}

emp_jamotherteams( teamname, killstreak_id )
{
	level endon( "game_ended" );
	overlays = [];
/#
	assert( isDefined( level.teams[ teamname ] ) );
#/
	level notify( "EMP_JamOtherTeams" + teamname );
	level endon( "EMP_JamOtherTeams" + teamname );
	level.empowners[ teamname ] = self;
	_a121 = level.players;
	_k121 = getFirstArrayKey( _a121 );
	while ( isDefined( _k121 ) )
	{
		player = _a121[ _k121 ];
		if ( player.team == teamname )
		{
		}
		else
		{
			player playlocalsound( "mpl_killstreak_emp_blast_front" );
		}
		_k121 = getNextArrayKey( _a121, _k121 );
	}
	visionsetnaked( "flash_grenade", 1,5 );
	thread empeffects();
	wait 0,1;
	visionsetnaked( "flash_grenade", 0 );
	if ( isDefined( level.nukedetonated ) )
	{
		visionsetnaked( level.nukevisionset, 5 );
	}
	else
	{
		visionsetnaked( getDvar( "mapname" ), 5 );
	}
	level.teamemping[ teamname ] = 1;
	level notify( "emp_update" );
	level destroyotherteamsactivevehicles( self, teamname );
	level destroyotherteamsequipment( self, teamname );
/#
	level.emptimeout = getDvarFloat( #"35E553D4" );
#/
	maps/mp/gametypes/_hostmigration::waitlongdurationwithhostmigrationpauseemp( level.emptimeout );
	level.teamemping[ teamname ] = 0;
	maps/mp/killstreaks/_killstreakrules::killstreakstop( "emp_mp", teamname, killstreak_id );
	level notify( "emp_update" );
	level notify( "emp_end" + teamname );
}

emp_jamplayers( owner, killstreak_id )
{
	level notify( "EMP_JamPlayers" );
	level endon( "EMP_JamPlayers" );
	overlays = [];
/#
	assert( isDefined( owner ) );
#/
	_a180 = level.players;
	_k180 = getFirstArrayKey( _a180 );
	while ( isDefined( _k180 ) )
	{
		player = _a180[ _k180 ];
		if ( player == owner )
		{
		}
		else
		{
			player playlocalsound( "mpl_killstreak_emp_blast_front" );
		}
		_k180 = getNextArrayKey( _a180, _k180 );
	}
	visionsetnaked( "flash_grenade", 1,5 );
	thread empeffects();
	wait 0,1;
	visionsetnaked( "flash_grenade", 0 );
	if ( isDefined( level.nukedetonated ) )
	{
		visionsetnaked( level.nukevisionset, 5 );
	}
	else
	{
		visionsetnaked( getDvar( "mapname" ), 5 );
	}
	level notify( "emp_update" );
	level.empplayer = owner;
	level.empplayer thread empplayerffadisconnect();
	level destroyactivevehicles( owner );
	level destroyequipment( owner );
	level notify( "emp_update" );
/#
	level.emptimeout = getDvarFloat( #"35E553D4" );
#/
	maps/mp/gametypes/_hostmigration::waitlongdurationwithhostmigrationpause( level.emptimeout );
	maps/mp/killstreaks/_killstreakrules::killstreakstop( "emp_mp", level.empplayer.team, killstreak_id );
	level.empplayer = undefined;
	level notify( "emp_update" );
	level notify( "emp_ended" );
}

empplayerffadisconnect()
{
	level endon( "EMP_JamPlayers" );
	level endon( "emp_ended" );
	self waittill( "disconnect" );
	level notify( "emp_update" );
}

empeffects()
{
	_a241 = level.players;
	_k241 = getFirstArrayKey( _a241 );
	while ( isDefined( _k241 ) )
	{
		player = _a241[ _k241 ];
		playerforward = anglesToForward( player.angles );
		playerforward = ( playerforward[ 0 ], playerforward[ 1 ], 0 );
		playerforward = vectornormalize( playerforward );
		empdistance = 20000;
		empent = spawn( "script_model", ( player.origin + vectorScale( ( 0, 0, 1 ), 8000 ) ) + ( playerforward * empdistance ) );
		empent setmodel( "tag_origin" );
		empent.angles += vectorScale( ( 0, 0, 1 ), 270 );
		empent thread empeffect( player );
		_k241 = getNextArrayKey( _a241, _k241 );
	}
}

empeffect( player )
{
	player endon( "disconnect" );
	self setinvisibletoall();
	self setvisibletoplayer( player );
	wait 0,5;
	playfxontag( level._effect[ "emp_flash" ], self, "tag_origin" );
	self playsound( "wpn_emp_bomb" );
	self deleteaftertime( 11 );
}

emp_teamtracker()
{
	level endon( "game_ended" );
	for ( ;; )
	{
		level waittill_either( "joined_team", "emp_update" );
		_a279 = level.players;
		_k279 = getFirstArrayKey( _a279 );
		while ( isDefined( _k279 ) )
		{
			player = _a279[ _k279 ];
			if ( player.team == "spectator" )
			{
			}
			else
			{
				emped = emp_isteamemped( player.team );
				player setempjammed( emped );
				if ( emped )
				{
					player notify( "emp_jammed" );
				}
			}
			_k279 = getNextArrayKey( _a279, _k279 );
		}
	}
}

emp_playertracker()
{
	level endon( "game_ended" );
	for ( ;; )
	{
		level waittill_either( "joined_team", "emp_update" );
		_a306 = level.players;
		_k306 = getFirstArrayKey( _a306 );
		while ( isDefined( _k306 ) )
		{
			player = _a306[ _k306 ];
			if ( player.team == "spectator" )
			{
			}
			else if ( isDefined( level.empplayer ) && level.empplayer != player )
			{
				player setempjammed( 1 );
				player notify( "emp_jammed" );
			}
			else
			{
				player setempjammed( 0 );
			}
			_k306 = getNextArrayKey( _a306, _k306 );
		}
	}
}

destroyotherteamsequipment( attacker, teamemping )
{
	_a328 = level.teams;
	_k328 = getFirstArrayKey( _a328 );
	while ( isDefined( _k328 ) )
	{
		team = _a328[ _k328 ];
		if ( team == teamemping )
		{
		}
		else
		{
			destroyequipment( attacker, team );
			destroytacticalinsertions( attacker, team );
		}
		_k328 = getNextArrayKey( _a328, _k328 );
	}
}

destroyequipment( attacker, teamemped )
{
	i = 0;
	while ( i < level.missileentities.size )
	{
		item = level.missileentities[ i ];
		if ( !isDefined( item.name ) )
		{
			i++;
			continue;
		}
		else if ( !isDefined( item.owner ) )
		{
			i++;
			continue;
		}
		else if ( isDefined( teamemped ) && item.owner.team != teamemped )
		{
			i++;
			continue;
		}
		else if ( item.owner == attacker )
		{
			i++;
			continue;
		}
		else if ( !isweaponequipment( item.name ) && item.name != "proximity_grenade_mp" )
		{
			i++;
			continue;
		}
		else
		{
			watcher = item.owner getwatcherforweapon( item.name );
			if ( !isDefined( watcher ) )
			{
				i++;
				continue;
			}
			else
			{
				watcher thread maps/mp/gametypes/_weaponobjects::waitanddetonate( item, 0, attacker, "emp_mp" );
			}
		}
		i++;
	}
}

destroytacticalinsertions( attacker, victimteam )
{
	i = 0;
	while ( i < level.players.size )
	{
		player = level.players[ i ];
		if ( !isDefined( player.tacticalinsertion ) )
		{
			i++;
			continue;
		}
		else if ( level.teambased && player.team != victimteam )
		{
			i++;
			continue;
		}
		else
		{
			if ( attacker == player )
			{
				i++;
				continue;
			}
			else
			{
				player.tacticalinsertion thread maps/mp/_tacticalinsertion::fizzle();
			}
		}
		i++;
	}
}

getwatcherforweapon( weapname )
{
	if ( !isDefined( self ) )
	{
		return undefined;
	}
	if ( !isplayer( self ) )
	{
		return undefined;
	}
	i = 0;
	while ( i < self.weaponobjectwatcherarray.size )
	{
		if ( self.weaponobjectwatcherarray[ i ].weapon != weapname )
		{
			i++;
			continue;
		}
		else
		{
			return self.weaponobjectwatcherarray[ i ];
		}
		i++;
	}
	return undefined;
}

destroyotherteamsactivevehicles( attacker, teamemping )
{
	_a431 = level.teams;
	_k431 = getFirstArrayKey( _a431 );
	while ( isDefined( _k431 ) )
	{
		team = _a431[ _k431 ];
		if ( team == teamemping )
		{
		}
		else
		{
			destroyactivevehicles( attacker, team );
		}
		_k431 = getNextArrayKey( _a431, _k431 );
	}
}

destroyactivevehicles( attacker, teamemped )
{
	turrets = getentarray( "auto_turret", "classname" );
	destroyentities( turrets, attacker, teamemped );
	targets = target_getarray();
	destroyentities( targets, attacker, teamemped );
	rcbombs = getentarray( "rcbomb", "targetname" );
	destroyentities( rcbombs, attacker, teamemped );
	remotemissiles = getentarray( "remote_missile", "targetname" );
	destroyentities( remotemissiles, attacker, teamemped );
	remotedrone = getentarray( "remote_drone", "targetname" );
	destroyentities( remotedrone, attacker, teamemped );
	planemortars = getentarray( "plane_mortar", "targetname" );
	_a458 = planemortars;
	_k458 = getFirstArrayKey( _a458 );
	while ( isDefined( _k458 ) )
	{
		planemortar = _a458[ _k458 ];
		if ( isDefined( teamemped ) && isDefined( planemortar.team ) )
		{
			if ( planemortar.team != teamemped )
			{
			}
			else }
		else if ( planemortar.owner == attacker )
		{
		}
		else
		{
			planemortar notify( "emp_deployed" );
		}
		_k458 = getNextArrayKey( _a458, _k458 );
	}
	satellites = getentarray( "satellite", "targetname" );
	_a477 = satellites;
	_k477 = getFirstArrayKey( _a477 );
	while ( isDefined( _k477 ) )
	{
		satellite = _a477[ _k477 ];
		if ( isDefined( teamemped ) && isDefined( satellite.team ) )
		{
			if ( satellite.team != teamemped )
			{
			}
			else }
		else if ( satellite.owner == attacker )
		{
		}
		else
		{
			satellite notify( "emp_deployed" );
		}
		_k477 = getNextArrayKey( _a477, _k477 );
	}
	if ( isDefined( level.missile_swarm_owner ) )
	{
		if ( level.missile_swarm_owner isenemyplayer( attacker ) )
		{
			level.missile_swarm_owner notify( "emp_destroyed_missile_swarm" );
		}
	}
}

destroyentities( entities, attacker, team )
{
	meansofdeath = "MOD_EXPLOSIVE";
	weapon = "killstreak_emp_mp";
	damage = 5000;
	direction_vec = ( 0, 0, 1 );
	point = ( 0, 0, 1 );
	modelname = "";
	tagname = "";
	partname = "";
	_a515 = entities;
	_k515 = getFirstArrayKey( _a515 );
	while ( isDefined( _k515 ) )
	{
		entity = _a515[ _k515 ];
		if ( isDefined( team ) && isDefined( entity.team ) )
		{
			if ( entity.team != team )
			{
			}
			else }
		else if ( entity.owner == attacker )
		{
		}
		else
		{
			entity notify( "damage" );
		}
		_k515 = getNextArrayKey( _a515, _k515 );
	}
}

drawempdamageorigin( pos, ang, radius )
{
/#
	while ( getDvarInt( #"D04570F2" ) )
	{
		line( pos, pos + ( anglesToForward( ang ) * radius ), ( 0, 0, 1 ) );
		line( pos, pos + ( anglesToRight( ang ) * radius ), ( 0, 0, 1 ) );
		line( pos, pos + ( anglesToUp( ang ) * radius ), ( 0, 0, 1 ) );
		line( pos, pos - ( anglesToForward( ang ) * radius ), ( 0, 0, 1 ) );
		line( pos, pos - ( anglesToRight( ang ) * radius ), ( 0, 0, 1 ) );
		line( pos, pos - ( anglesToUp( ang ) * radius ), ( 0, 0, 1 ) );
		wait 0,05;
#/
	}
}

isenemyempkillstreakactive()
{
	if ( level.teambased || maps/mp/killstreaks/_emp::emp_isteamemped( self.team ) && !level.teambased && isDefined( level.empplayer ) && level.empplayer != self )
	{
		return 1;
	}
	return 0;
}

isempweapon( weaponname )
{
	if ( isDefined( weaponname ) && weaponname != "emp_mp" || weaponname == "emp_grenade_mp" && weaponname == "emp_grenade_zm" )
	{
		return 1;
	}
	return 0;
}

isempkillstreakweapon( weaponname )
{
	if ( isDefined( weaponname ) && weaponname == "emp_mp" )
	{
		return 1;
	}
	return 0;
}
