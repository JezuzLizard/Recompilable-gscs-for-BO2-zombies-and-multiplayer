#include maps/mp/_utility;
#include maps/mp/_createfx;
#include maps/mp/gametypes/_hud_util;
#include common_scripts/utility;

addcallback( event, func )
{
/#
	assert( isDefined( event ), "Trying to set a callback on an undefined event." );
#/
	if ( !isDefined( level._callbacks ) || !isDefined( level._callbacks[ event ] ) )
	{
		level._callbacks[ event ] = [];
	}
	level._callbacks[ event ] = add_to_array( level._callbacks[ event ], func, 0 );
}

callback( event )
{
	while ( isDefined( level._callbacks ) && isDefined( level._callbacks[ event ] ) )
	{
		i = 0;
		while ( i < level._callbacks[ event ].size )
		{
			callback = level._callbacks[ event ][ i ];
			if ( isDefined( callback ) )
			{
				self thread [[ callback ]]();
			}
			i++;
		}
	}
}

onfinalizeinitialization_callback( func )
{
	addcallback( "on_finalize_initialization", func );
}

triggeroff()
{
	if ( !isDefined( self.realorigin ) )
	{
		self.realorigin = self.origin;
	}
	if ( self.origin == self.realorigin )
	{
		self.origin += vectorScale( ( 0, 0, 1 ), 10000 );
	}
}

triggeron()
{
	if ( isDefined( self.realorigin ) )
	{
		self.origin = self.realorigin;
	}
}

error( msg )
{
/#
	println( "^c*ERROR* ", msg );
	wait 0,05;
	if ( getDvar( "debug" ) != "1" )
	{
		assertmsg( "This is a forced error - attach the log file" );
#/
	}
}

warning( msg )
{
/#
	println( "^1WARNING: " + msg );
#/
}

spawn_array_struct()
{
	s = spawnstruct();
	s.a = [];
	return s;
}

within_fov( start_origin, start_angles, end_origin, fov )
{
	normal = vectornormalize( end_origin - start_origin );
	forward = anglesToForward( start_angles );
	dot = vectordot( forward, normal );
	return dot >= fov;
}

append_array_struct( dst_s, src_s )
{
	i = 0;
	while ( i < src_s.a.size )
	{
		dst_s.a[ dst_s.a.size ] = src_s.a[ i ];
		i++;
	}
}

exploder( num )
{
	[[ level.exploderfunction ]]( num );
}

exploder_stop( num )
{
	stop_exploder( num );
}

exploder_sound()
{
	if ( isDefined( self.script_delay ) )
	{
		wait self.script_delay;
	}
	self playsound( level.scr_sound[ self.script_sound ] );
}

cannon_effect()
{
	if ( isDefined( self.v[ "repeat" ] ) )
	{
		i = 0;
		while ( i < self.v[ "repeat" ] )
		{
			playfx( level._effect[ self.v[ "fxid" ] ], self.v[ "origin" ], self.v[ "forward" ], self.v[ "up" ] );
			self exploder_delay();
			i++;
		}
		return;
	}
	self exploder_delay();
	if ( isDefined( self.looper ) )
	{
		self.looper delete();
	}
	self.looper = spawnfx( getfx( self.v[ "fxid" ] ), self.v[ "origin" ], self.v[ "forward" ], self.v[ "up" ] );
	triggerfx( self.looper );
	exploder_playsound();
}

exploder_delay()
{
	if ( !isDefined( self.v[ "delay" ] ) )
	{
		self.v[ "delay" ] = 0;
	}
	min_delay = self.v[ "delay" ];
	max_delay = self.v[ "delay" ] + 0,001;
	if ( isDefined( self.v[ "delay_min" ] ) )
	{
		min_delay = self.v[ "delay_min" ];
	}
	if ( isDefined( self.v[ "delay_max" ] ) )
	{
		max_delay = self.v[ "delay_max" ];
	}
	if ( min_delay > 0 )
	{
		wait randomfloatrange( min_delay, max_delay );
	}
}

exploder_playsound()
{
	if ( !isDefined( self.v[ "soundalias" ] ) || self.v[ "soundalias" ] == "nil" )
	{
		return;
	}
	play_sound_in_space( self.v[ "soundalias" ], self.v[ "origin" ] );
}

brush_delete()
{
	num = self.v[ "exploder" ];
	if ( isDefined( self.v[ "delay" ] ) )
	{
		wait self.v[ "delay" ];
	}
	else
	{
		wait 0,05;
	}
	if ( !isDefined( self.model ) )
	{
		return;
	}
/#
	assert( isDefined( self.model ) );
#/
	if ( level.createfx_enabled )
	{
		if ( isDefined( self.exploded ) )
		{
			return;
		}
		self.exploded = 1;
		self.model hide();
		self.model notsolid();
		wait 3;
		self.exploded = undefined;
		self.model show();
		self.model solid();
		return;
	}
	if ( !isDefined( self.v[ "fxid" ] ) || self.v[ "fxid" ] == "No FX" )
	{
	}
	waittillframeend;
	self.model delete();
}

brush_show()
{
	if ( isDefined( self.v[ "delay" ] ) )
	{
		wait self.v[ "delay" ];
	}
/#
	assert( isDefined( self.model ) );
#/
	self.model show();
	self.model solid();
	if ( level.createfx_enabled )
	{
		if ( isDefined( self.exploded ) )
		{
			return;
		}
		self.exploded = 1;
		wait 3;
		self.exploded = undefined;
		self.model hide();
		self.model notsolid();
	}
}

brush_throw()
{
	if ( isDefined( self.v[ "delay" ] ) )
	{
		wait self.v[ "delay" ];
	}
	ent = undefined;
	if ( isDefined( self.v[ "target" ] ) )
	{
		ent = getent( self.v[ "target" ], "targetname" );
	}
	if ( !isDefined( ent ) )
	{
		self.model delete();
		return;
	}
	self.model show();
	startorg = self.v[ "origin" ];
	startang = self.v[ "angles" ];
	org = ent.origin;
	temp_vec = org - self.v[ "origin" ];
	x = temp_vec[ 0 ];
	y = temp_vec[ 1 ];
	z = temp_vec[ 2 ];
	self.model rotatevelocity( ( x, y, z ), 12 );
	self.model movegravity( ( x, y, z ), 12 );
	if ( level.createfx_enabled )
	{
		if ( isDefined( self.exploded ) )
		{
			return;
		}
		self.exploded = 1;
		wait 3;
		self.exploded = undefined;
		self.v[ "origin" ] = startorg;
		self.v[ "angles" ] = startang;
		self.model hide();
		return;
	}
	wait 6;
	self.model delete();
}

getplant()
{
	start = self.origin + vectorScale( ( 0, 0, 1 ), 10 );
	range = 11;
	forward = anglesToForward( self.angles );
	forward = vectorScale( forward, range );
	traceorigins[ 0 ] = start + forward;
	traceorigins[ 1 ] = start;
	trace = bullettrace( traceorigins[ 0 ], traceorigins[ 0 ] + vectorScale( ( 0, 0, 1 ), 18 ), 0, undefined );
	if ( trace[ "fraction" ] < 1 )
	{
		temp = spawnstruct();
		temp.origin = trace[ "position" ];
		temp.angles = orienttonormal( trace[ "normal" ] );
		return temp;
	}
	trace = bullettrace( traceorigins[ 1 ], traceorigins[ 1 ] + vectorScale( ( 0, 0, 1 ), 18 ), 0, undefined );
	if ( trace[ "fraction" ] < 1 )
	{
		temp = spawnstruct();
		temp.origin = trace[ "position" ];
		temp.angles = orienttonormal( trace[ "normal" ] );
		return temp;
	}
	traceorigins[ 2 ] = start + vectorScale( ( 0, 0, 1 ), 16 );
	traceorigins[ 3 ] = start + vectorScale( ( 0, 0, 1 ), 16 );
	traceorigins[ 4 ] = start + vectorScale( ( 0, 0, 1 ), 16 );
	traceorigins[ 5 ] = start + vectorScale( ( 0, 0, 1 ), 16 );
	besttracefraction = undefined;
	besttraceposition = undefined;
	i = 0;
	while ( i < traceorigins.size )
	{
		trace = bullettrace( traceorigins[ i ], traceorigins[ i ] + vectorScale( ( 0, 0, 1 ), 1000 ), 0, undefined );
		if ( !isDefined( besttracefraction ) || trace[ "fraction" ] < besttracefraction )
		{
			besttracefraction = trace[ "fraction" ];
			besttraceposition = trace[ "position" ];
		}
		i++;
	}
	if ( besttracefraction == 1 )
	{
		besttraceposition = self.origin;
	}
	temp = spawnstruct();
	temp.origin = besttraceposition;
	temp.angles = orienttonormal( trace[ "normal" ] );
	return temp;
}

orienttonormal( normal )
{
	hor_normal = ( normal[ 0 ], normal[ 1 ], 0 );
	hor_length = length( hor_normal );
	if ( !hor_length )
	{
		return ( 0, 0, 1 );
	}
	hor_dir = vectornormalize( hor_normal );
	neg_height = normal[ 2 ] * -1;
	tangent = ( hor_dir[ 0 ] * neg_height, hor_dir[ 1 ] * neg_height, hor_length );
	plant_angle = vectorToAngle( tangent );
	return plant_angle;
}

array_levelthread( ents, process, var, excluders )
{
	exclude = [];
	i = 0;
	while ( i < ents.size )
	{
		exclude[ i ] = 0;
		i++;
	}
	while ( isDefined( excluders ) )
	{
		i = 0;
		while ( i < ents.size )
		{
			p = 0;
			while ( p < excluders.size )
			{
				if ( ents[ i ] == excluders[ p ] )
				{
					exclude[ i ] = 1;
				}
				p++;
			}
			i++;
		}
	}
	i = 0;
	while ( i < ents.size )
	{
		if ( !exclude[ i ] )
		{
			if ( isDefined( var ) )
			{
				level thread [[ process ]]( ents[ i ], var );
				i++;
				continue;
			}
			else
			{
				level thread [[ process ]]( ents[ i ] );
			}
		}
		i++;
	}
}

deleteplacedentity( entity )
{
	entities = getentarray( entity, "classname" );
	i = 0;
	while ( i < entities.size )
	{
		entities[ i ] delete();
		i++;
	}
}

playsoundonplayers( sound, team )
{
/#
	assert( isDefined( level.players ) );
#/
	if ( level.splitscreen )
	{
		if ( isDefined( level.players[ 0 ] ) )
		{
			level.players[ 0 ] playlocalsound( sound );
		}
	}
	else if ( isDefined( team ) )
	{
		i = 0;
		while ( i < level.players.size )
		{
			player = level.players[ i ];
			if ( isDefined( player.pers[ "team" ] ) && player.pers[ "team" ] == team )
			{
				player playlocalsound( sound );
			}
			i++;
		}
	}
	else i = 0;
	while ( i < level.players.size )
	{
		level.players[ i ] playlocalsound( sound );
		i++;
	}
}

get_player_height()
{
	return 70;
}

isbulletimpactmod( smeansofdeath )
{
	if ( !issubstr( smeansofdeath, "BULLET" ) )
	{
		return smeansofdeath == "MOD_HEAD_SHOT";
	}
}

get_team_alive_players_s( teamname )
{
	teamplayers_s = spawn_array_struct();
	while ( isDefined( teamname ) && isDefined( level.aliveplayers ) && isDefined( level.aliveplayers[ teamname ] ) )
	{
		i = 0;
		while ( i < level.aliveplayers[ teamname ].size )
		{
			teamplayers_s.a[ teamplayers_s.a.size ] = level.aliveplayers[ teamname ][ i ];
			i++;
		}
	}
	return teamplayers_s;
}

get_all_alive_players_s()
{
	allplayers_s = spawn_array_struct();
	while ( isDefined( level.aliveplayers ) )
	{
		keys = getarraykeys( level.aliveplayers );
		i = 0;
		while ( i < keys.size )
		{
			team = keys[ i ];
			j = 0;
			while ( j < level.aliveplayers[ team ].size )
			{
				allplayers_s.a[ allplayers_s.a.size ] = level.aliveplayers[ team ][ j ];
				j++;
			}
			i++;
		}
	}
	return allplayers_s;
}

waitrespawnbutton()
{
	self endon( "disconnect" );
	self endon( "end_respawn" );
	while ( self usebuttonpressed() != 1 )
	{
		wait 0,05;
	}
}

setlowermessage( text, time, combinemessageandtimer )
{
	if ( !isDefined( self.lowermessage ) )
	{
		return;
	}
	if ( isDefined( self.lowermessageoverride ) && text != &"" )
	{
		text = self.lowermessageoverride;
		time = undefined;
	}
	self notify( "lower_message_set" );
	self.lowermessage settext( text );
	if ( isDefined( time ) && time > 0 )
	{
		if ( !isDefined( combinemessageandtimer ) || !combinemessageandtimer )
		{
			self.lowertimer.label = &"";
		}
		else
		{
			self.lowermessage settext( "" );
			self.lowertimer.label = text;
		}
		self.lowertimer settimer( time );
	}
	else
	{
		self.lowertimer settext( "" );
		self.lowertimer.label = &"";
	}
	if ( self issplitscreen() )
	{
		self.lowermessage.fontscale = 1,4;
	}
	self.lowermessage fadeovertime( 0,05 );
	self.lowermessage.alpha = 1;
	self.lowertimer fadeovertime( 0,05 );
	self.lowertimer.alpha = 1;
}

setlowermessagevalue( text, value, combinemessage )
{
	if ( !isDefined( self.lowermessage ) )
	{
		return;
	}
	if ( isDefined( self.lowermessageoverride ) && text != &"" )
	{
		text = self.lowermessageoverride;
		time = undefined;
	}
	self notify( "lower_message_set" );
	if ( !isDefined( combinemessage ) || !combinemessage )
	{
		self.lowermessage settext( text );
	}
	else
	{
		self.lowermessage settext( "" );
	}
	if ( isDefined( value ) && value > 0 )
	{
		if ( !isDefined( combinemessage ) || !combinemessage )
		{
			self.lowertimer.label = &"";
		}
		else
		{
			self.lowertimer.label = text;
		}
		self.lowertimer setvalue( value );
	}
	else
	{
		self.lowertimer settext( "" );
		self.lowertimer.label = &"";
	}
	if ( self issplitscreen() )
	{
		self.lowermessage.fontscale = 1,4;
	}
	self.lowermessage fadeovertime( 0,05 );
	self.lowermessage.alpha = 1;
	self.lowertimer fadeovertime( 0,05 );
	self.lowertimer.alpha = 1;
}

clearlowermessage( fadetime )
{
	if ( !isDefined( self.lowermessage ) )
	{
		return;
	}
	self notify( "lower_message_set" );
	if ( !isDefined( fadetime ) || fadetime == 0 )
	{
		setlowermessage( &"" );
	}
	else
	{
		self endon( "disconnect" );
		self endon( "lower_message_set" );
		self.lowermessage fadeovertime( fadetime );
		self.lowermessage.alpha = 0;
		self.lowertimer fadeovertime( fadetime );
		self.lowertimer.alpha = 0;
		wait fadetime;
		self setlowermessage( "" );
	}
}

printonteam( text, team )
{
/#
	assert( isDefined( level.players ) );
#/
	i = 0;
	while ( i < level.players.size )
	{
		player = level.players[ i ];
		if ( isDefined( player.pers[ "team" ] ) && player.pers[ "team" ] == team )
		{
			player iprintln( text );
		}
		i++;
	}
}

printboldonteam( text, team )
{
/#
	assert( isDefined( level.players ) );
#/
	i = 0;
	while ( i < level.players.size )
	{
		player = level.players[ i ];
		if ( isDefined( player.pers[ "team" ] ) && player.pers[ "team" ] == team )
		{
			player iprintlnbold( text );
		}
		i++;
	}
}

printboldonteamarg( text, team, arg )
{
/#
	assert( isDefined( level.players ) );
#/
	i = 0;
	while ( i < level.players.size )
	{
		player = level.players[ i ];
		if ( isDefined( player.pers[ "team" ] ) && player.pers[ "team" ] == team )
		{
			player iprintlnbold( text, arg );
		}
		i++;
	}
}

printonteamarg( text, team, arg )
{
}

printonplayers( text, team )
{
	players = level.players;
	i = 0;
	while ( i < players.size )
	{
		if ( isDefined( team ) )
		{
			if ( isDefined( players[ i ].pers[ "team" ] ) && players[ i ].pers[ "team" ] == team )
			{
				players[ i ] iprintln( text );
			}
			i++;
			continue;
		}
		else
		{
			players[ i ] iprintln( text );
		}
		i++;
	}
}

printandsoundoneveryone( team, enemyteam, printfriendly, printenemy, soundfriendly, soundenemy, printarg )
{
	shoulddosounds = isDefined( soundfriendly );
	shoulddoenemysounds = 0;
	if ( isDefined( soundenemy ) )
	{
/#
		assert( shoulddosounds );
#/
		shoulddoenemysounds = 1;
	}
	if ( !isDefined( printarg ) )
	{
		printarg = "";
	}
	if ( level.splitscreen || !shoulddosounds )
	{
		i = 0;
		while ( i < level.players.size )
		{
			player = level.players[ i ];
			playerteam = player.pers[ "team" ];
			if ( isDefined( playerteam ) )
			{
				if ( playerteam == team && isDefined( printfriendly ) && printfriendly != &"" )
				{
					player iprintln( printfriendly, printarg );
					i++;
					continue;
				}
				else
				{
					if ( isDefined( printenemy ) && printenemy != &"" )
					{
						if ( isDefined( enemyteam ) && playerteam == enemyteam )
						{
							player iprintln( printenemy, printarg );
							i++;
							continue;
						}
						else
						{
							if ( !isDefined( enemyteam ) && playerteam != team )
							{
								player iprintln( printenemy, printarg );
							}
						}
					}
				}
			}
			i++;
		}
		if ( shoulddosounds )
		{
/#
			assert( level.splitscreen );
#/
			level.players[ 0 ] playlocalsound( soundfriendly );
		}
	}
	else
	{
/#
		assert( shoulddosounds );
#/
		if ( shoulddoenemysounds )
		{
			i = 0;
			while ( i < level.players.size )
			{
				player = level.players[ i ];
				playerteam = player.pers[ "team" ];
				if ( isDefined( playerteam ) )
				{
					if ( playerteam == team )
					{
						if ( isDefined( printfriendly ) && printfriendly != &"" )
						{
							player iprintln( printfriendly, printarg );
						}
						player playlocalsound( soundfriendly );
						i++;
						continue;
					}
					else
					{
						if ( isDefined( enemyteam ) || playerteam == enemyteam && !isDefined( enemyteam ) && playerteam != team )
						{
							if ( isDefined( printenemy ) && printenemy != &"" )
							{
								player iprintln( printenemy, printarg );
							}
							player playlocalsound( soundenemy );
						}
					}
				}
				i++;
			}
		}
		else i = 0;
		while ( i < level.players.size )
		{
			player = level.players[ i ];
			playerteam = player.pers[ "team" ];
			if ( isDefined( playerteam ) )
			{
				if ( playerteam == team )
				{
					if ( isDefined( printfriendly ) && printfriendly != &"" )
					{
						player iprintln( printfriendly, printarg );
					}
					player playlocalsound( soundfriendly );
					i++;
					continue;
				}
				else if ( isDefined( printenemy ) && printenemy != &"" )
				{
					if ( isDefined( enemyteam ) && playerteam == enemyteam )
					{
						player iprintln( printenemy, printarg );
						i++;
						continue;
					}
					else
					{
						if ( !isDefined( enemyteam ) && playerteam != team )
						{
							player iprintln( printenemy, printarg );
						}
					}
				}
			}
			i++;
		}
	}
}

_playlocalsound( soundalias )
{
	if ( level.splitscreen && !self ishost() )
	{
		return;
	}
	self playlocalsound( soundalias );
}

dvarintvalue( dvar, defval, minval, maxval )
{
	dvar = "scr_" + level.gametype + "_" + dvar;
	if ( getDvar( dvar ) == "" )
	{
		setdvar( dvar, defval );
		return defval;
	}
	value = getDvarInt( dvar );
	if ( value > maxval )
	{
		value = maxval;
	}
	else if ( value < minval )
	{
		value = minval;
	}
	else
	{
		return value;
	}
	setdvar( dvar, value );
	return value;
}

dvarfloatvalue( dvar, defval, minval, maxval )
{
	dvar = "scr_" + level.gametype + "_" + dvar;
	if ( getDvar( dvar ) == "" )
	{
		setdvar( dvar, defval );
		return defval;
	}
	value = getDvarFloat( dvar );
	if ( value > maxval )
	{
		value = maxval;
	}
	else if ( value < minval )
	{
		value = minval;
	}
	else
	{
		return value;
	}
	setdvar( dvar, value );
	return value;
}

play_sound_on_tag( alias, tag )
{
	if ( isDefined( tag ) )
	{
		org = spawn( "script_origin", self gettagorigin( tag ) );
		org linkto( self, tag, ( 0, 0, 1 ), ( 0, 0, 1 ) );
	}
	else
	{
		org = spawn( "script_origin", ( 0, 0, 1 ) );
		org.origin = self.origin;
		org.angles = self.angles;
		org linkto( self );
	}
	org playsound( alias );
	wait 5;
	org delete();
}

createloopeffect( fxid )
{
	ent = maps/mp/_createfx::createeffect( "loopfx", fxid );
	ent.v[ "delay" ] = 0,5;
	return ent;
}

createoneshoteffect( fxid )
{
	ent = maps/mp/_createfx::createeffect( "oneshotfx", fxid );
	ent.v[ "delay" ] = -15;
	return ent;
}

loop_fx_sound( alias, origin, ender, timeout )
{
	org = spawn( "script_origin", ( 0, 0, 1 ) );
	if ( isDefined( ender ) )
	{
		thread loop_sound_delete( ender, org );
		self endon( ender );
	}
	org.origin = origin;
	org playloopsound( alias );
	if ( !isDefined( timeout ) )
	{
		return;
	}
	wait timeout;
}

exploder_damage()
{
	if ( isDefined( self.v[ "delay" ] ) )
	{
		delay = self.v[ "delay" ];
	}
	else
	{
		delay = 0;
	}
	if ( isDefined( self.v[ "damage_radius" ] ) )
	{
		radius = self.v[ "damage_radius" ];
	}
	else
	{
		radius = 128;
	}
	damage = self.v[ "damage" ];
	origin = self.v[ "origin" ];
	wait delay;
	radiusdamage( origin, radius, damage, damage );
}

exploder_before_load( num )
{
	waittillframeend;
	waittillframeend;
	activate_exploder( num );
}

exploder_after_load( num )
{
	activate_exploder( num );
}

getexploderid( ent )
{
	if ( !isDefined( level._exploder_ids ) )
	{
		level._exploder_ids = [];
		level._exploder_id = 1;
	}
	if ( !isDefined( level._exploder_ids[ ent.v[ "exploder" ] ] ) )
	{
		level._exploder_ids[ ent.v[ "exploder" ] ] = level._exploder_id;
		level._exploder_id++;
	}
	return level._exploder_ids[ ent.v[ "exploder" ] ];
}

activate_exploder_on_clients( num )
{
	if ( !isDefined( level._exploder_ids[ num ] ) )
	{
		return;
	}
	if ( !isDefined( level._client_exploders[ num ] ) )
	{
		level._client_exploders[ num ] = 1;
	}
	if ( !isDefined( level._client_exploder_ids[ num ] ) )
	{
		level._client_exploder_ids[ num ] = 1;
	}
	activateclientexploder( level._exploder_ids[ num ] );
}

delete_exploder_on_clients( num )
{
	if ( !isDefined( level._exploder_ids[ num ] ) )
	{
		return;
	}
	if ( !isDefined( level._client_exploders[ num ] ) )
	{
		return;
	}
	deactivateclientexploder( level._exploder_ids[ num ] );
}

activate_individual_exploder()
{
	level notify( "exploder" + self.v[ "exploder" ] );
	if ( !level.createfx_enabled && level.clientscripts || !isDefined( level._exploder_ids[ int( self.v[ "exploder" ] ) ] ) && isDefined( self.v[ "exploder_server" ] ) )
	{
/#
		println( "Exploder " + self.v[ "exploder" ] + " created on server." );
#/
		if ( isDefined( self.v[ "firefx" ] ) )
		{
			self thread fire_effect();
		}
		if ( isDefined( self.v[ "fxid" ] ) && self.v[ "fxid" ] != "No FX" )
		{
			self thread cannon_effect();
		}
		else
		{
			if ( isDefined( self.v[ "soundalias" ] ) )
			{
				self thread sound_effect();
			}
		}
	}
	if ( isDefined( self.v[ "trailfx" ] ) )
	{
		self thread trail_effect();
	}
	if ( isDefined( self.v[ "damage" ] ) )
	{
		self thread exploder_damage();
	}
	if ( self.v[ "exploder_type" ] == "exploder" )
	{
		self thread brush_show();
	}
	else if ( self.v[ "exploder_type" ] == "exploderchunk" || self.v[ "exploder_type" ] == "exploderchunk visible" )
	{
		self thread brush_throw();
	}
	else
	{
		self thread brush_delete();
	}
}

trail_effect()
{
	self exploder_delay();
	if ( !isDefined( self.v[ "trailfxtag" ] ) )
	{
		self.v[ "trailfxtag" ] = "tag_origin";
	}
	temp_ent = undefined;
	if ( self.v[ "trailfxtag" ] == "tag_origin" )
	{
		playfxontag( level._effect[ self.v[ "trailfx" ] ], self.model, self.v[ "trailfxtag" ] );
	}
	else
	{
		temp_ent = spawn( "script_model", self.model.origin );
		temp_ent setmodel( "tag_origin" );
		temp_ent linkto( self.model, self.v[ "trailfxtag" ] );
		playfxontag( level._effect[ self.v[ "trailfx" ] ], temp_ent, "tag_origin" );
	}
	if ( isDefined( self.v[ "trailfxsound" ] ) )
	{
		if ( !isDefined( temp_ent ) )
		{
			self.model playloopsound( self.v[ "trailfxsound" ] );
		}
		else
		{
			temp_ent playloopsound( self.v[ "trailfxsound" ] );
		}
	}
	if ( isDefined( self.v[ "ender" ] ) && isDefined( temp_ent ) )
	{
		level thread trail_effect_ender( temp_ent, self.v[ "ender" ] );
	}
	if ( !isDefined( self.v[ "trailfxtimeout" ] ) )
	{
		return;
	}
	wait self.v[ "trailfxtimeout" ];
	if ( isDefined( temp_ent ) )
	{
		temp_ent delete();
	}
}

trail_effect_ender( ent, ender )
{
	ent endon( "death" );
	self waittill( ender );
	ent delete();
}

activate_exploder( num )
{
	num = int( num );
/#
	if ( level.createfx_enabled )
	{
		i = 0;
		while ( i < level.createfxent.size )
		{
			ent = level.createfxent[ i ];
			if ( !isDefined( ent ) )
			{
				i++;
				continue;
			}
			else if ( ent.v[ "type" ] != "exploder" )
			{
				i++;
				continue;
			}
			else if ( !isDefined( ent.v[ "exploder" ] ) )
			{
				i++;
				continue;
			}
			else if ( ent.v[ "exploder" ] != num )
			{
				i++;
				continue;
			}
			else
			{
				if ( isDefined( ent.v[ "exploder_server" ] ) )
				{
					client_send = 0;
				}
				ent activate_individual_exploder();
			}
			i++;
		}
		return;
#/
	}
	client_send = 1;
	while ( isDefined( level.createfxexploders[ num ] ) )
	{
		i = 0;
		while ( i < level.createfxexploders[ num ].size )
		{
			if ( client_send && isDefined( level.createfxexploders[ num ][ i ].v[ "exploder_server" ] ) )
			{
				client_send = 0;
			}
			level.createfxexploders[ num ][ i ] activate_individual_exploder();
			i++;
		}
	}
	if ( level.clientscripts )
	{
		if ( !level.createfx_enabled && client_send == 1 )
		{
			activate_exploder_on_clients( num );
		}
	}
}

stop_exploder( num )
{
	num = int( num );
	if ( level.clientscripts )
	{
		if ( !level.createfx_enabled )
		{
			delete_exploder_on_clients( num );
		}
	}
	while ( isDefined( level.createfxexploders[ num ] ) )
	{
		i = 0;
		while ( i < level.createfxexploders[ num ].size )
		{
			if ( !isDefined( level.createfxexploders[ num ][ i ].looper ) )
			{
				i++;
				continue;
			}
			else
			{
				level.createfxexploders[ num ][ i ].looper delete();
			}
			i++;
		}
	}
}

sound_effect()
{
	self effect_soundalias();
}

effect_soundalias()
{
	if ( !isDefined( self.v[ "delay" ] ) )
	{
		self.v[ "delay" ] = 0;
	}
	origin = self.v[ "origin" ];
	alias = self.v[ "soundalias" ];
	wait self.v[ "delay" ];
	play_sound_in_space( alias, origin );
}

play_sound_in_space( alias, origin, master )
{
	org = spawn( "script_origin", ( 0, 0, 1 ) );
	if ( !isDefined( origin ) )
	{
		origin = self.origin;
	}
	org.origin = origin;
	if ( isDefined( master ) && master )
	{
		org playsoundasmaster( alias );
	}
	else
	{
		org playsound( alias );
	}
	wait 10;
	org delete();
}

loop_sound_in_space( alias, origin, ender )
{
	org = spawn( "script_origin", ( 0, 0, 1 ) );
	if ( !isDefined( origin ) )
	{
		origin = self.origin;
	}
	org.origin = origin;
	org playloopsound( alias );
	level waittill( ender );
	org stoploopsound();
	wait 0,1;
	org delete();
}

fire_effect()
{
	if ( !isDefined( self.v[ "delay" ] ) )
	{
		self.v[ "delay" ] = 0;
	}
	delay = self.v[ "delay" ];
	if ( isDefined( self.v[ "delay_min" ] ) && isDefined( self.v[ "delay_max" ] ) )
	{
		delay = self.v[ "delay_min" ] + randomfloat( self.v[ "delay_max" ] - self.v[ "delay_min" ] );
	}
	forward = self.v[ "forward" ];
	up = self.v[ "up" ];
	org = undefined;
	firefxsound = self.v[ "firefxsound" ];
	origin = self.v[ "origin" ];
	firefx = self.v[ "firefx" ];
	ender = self.v[ "ender" ];
	if ( !isDefined( ender ) )
	{
		ender = "createfx_effectStopper";
	}
	timeout = self.v[ "firefxtimeout" ];
	firefxdelay = 0,5;
	if ( isDefined( self.v[ "firefxdelay" ] ) )
	{
		firefxdelay = self.v[ "firefxdelay" ];
	}
	wait delay;
	if ( isDefined( firefxsound ) )
	{
		level thread loop_fx_sound( firefxsound, origin, ender, timeout );
	}
	playfx( level._effect[ firefx ], self.v[ "origin" ], forward, up );
}

loop_sound_delete( ender, ent )
{
	ent endon( "death" );
	self waittill( ender );
	ent delete();
}

createexploder( fxid )
{
	ent = maps/mp/_createfx::createeffect( "exploder", fxid );
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = 1;
	ent.v[ "exploder_type" ] = "normal";
	return ent;
}

getotherteam( team )
{
	if ( team == "allies" )
	{
		return "axis";
	}
	else
	{
		if ( team == "axis" )
		{
			return "allies";
		}
		else
		{
			return "allies";
		}
	}
/#
	assertmsg( "getOtherTeam: invalid team " + team );
#/
}

getteammask( team )
{
	if ( level.teambased || !isDefined( team ) && !isDefined( level.spawnsystem.ispawn_teammask[ team ] ) )
	{
		return level.spawnsystem.ispawn_teammask_free;
	}
	return level.spawnsystem.ispawn_teammask[ team ];
}

getotherteamsmask( skip_team )
{
	mask = 0;
	_a1408 = level.teams;
	_k1408 = getFirstArrayKey( _a1408 );
	while ( isDefined( _k1408 ) )
	{
		team = _a1408[ _k1408 ];
		if ( team == skip_team )
		{
		}
		else
		{
			mask |= getteammask( team );
		}
		_k1408 = getNextArrayKey( _a1408, _k1408 );
	}
	return mask;
}

wait_endon( waittime, endonstring, endonstring2, endonstring3, endonstring4 )
{
	self endon( endonstring );
	if ( isDefined( endonstring2 ) )
	{
		self endon( endonstring2 );
	}
	if ( isDefined( endonstring3 ) )
	{
		self endon( endonstring3 );
	}
	if ( isDefined( endonstring4 ) )
	{
		self endon( endonstring4 );
	}
	wait waittime;
	return 1;
}

ismg( weapon )
{
	return issubstr( weapon, "_bipod_" );
}

plot_points( plotpoints, r, g, b, timer )
{
/#
	lastpoint = plotpoints[ 0 ];
	if ( !isDefined( r ) )
	{
		r = 1;
	}
	if ( !isDefined( g ) )
	{
		g = 1;
	}
	if ( !isDefined( b ) )
	{
		b = 1;
	}
	if ( !isDefined( timer ) )
	{
		timer = 0,05;
	}
	i = 1;
	while ( i < plotpoints.size )
	{
		line( lastpoint, plotpoints[ i ], ( r, g, b ), 1, timer );
		lastpoint = plotpoints[ i ];
		i++;
#/
	}
}

player_flag_wait( msg )
{
	while ( !self.flag[ msg ] )
	{
		self waittill( msg );
	}
}

player_flag_wait_either( flag1, flag2 )
{
	for ( ;; )
	{
		if ( flag( flag1 ) )
		{
			return;
		}
		if ( flag( flag2 ) )
		{
			return;
		}
		self waittill_either( flag1, flag2 );
	}
}

player_flag_waitopen( msg )
{
	while ( self.flag[ msg ] )
	{
		self waittill( msg );
	}
}

player_flag_init( message, trigger )
{
	if ( !isDefined( self.flag ) )
	{
		self.flag = [];
		self.flags_lock = [];
	}
/#
	assert( !isDefined( self.flag[ message ] ), "Attempt to reinitialize existing message: " + message );
#/
	self.flag[ message ] = 0;
/#
	self.flags_lock[ message ] = 0;
#/
}

player_flag_set_delayed( message, delay )
{
	wait delay;
	player_flag_set( message );
}

player_flag_set( message )
{
/#
	assert( isDefined( self.flag[ message ] ), "Attempt to set a flag before calling flag_init: " + message );
	assert( self.flag[ message ] == self.flags_lock[ message ] );
	self.flags_lock[ message ] = 1;
#/
	self.flag[ message ] = 1;
	self notify( message );
}

player_flag_clear( message )
{
/#
	assert( isDefined( self.flag[ message ] ), "Attempt to set a flag before calling flag_init: " + message );
	assert( self.flag[ message ] == self.flags_lock[ message ] );
	self.flags_lock[ message ] = 0;
#/
	self.flag[ message ] = 0;
	self notify( message );
}

player_flag( message )
{
/#
	assert( isDefined( message ), "Tried to check flag but the flag was not defined." );
#/
	if ( !self.flag[ message ] )
	{
		return 0;
	}
	return 1;
}

registerclientsys( ssysname )
{
	if ( !isDefined( level._clientsys ) )
	{
		level._clientsys = [];
	}
	if ( level._clientsys.size >= 32 )
	{
/#
		error( "Max num client systems exceeded." );
#/
		return;
	}
	if ( isDefined( level._clientsys[ ssysname ] ) )
	{
/#
		error( "Attempt to re-register client system : " + ssysname );
#/
		return;
	}
	else
	{
		level._clientsys[ ssysname ] = spawnstruct();
		level._clientsys[ ssysname ].sysid = clientsysregister( ssysname );
	}
}

setclientsysstate( ssysname, ssysstate, player )
{
	if ( !isDefined( level._clientsys ) )
	{
/#
		error( "setClientSysState called before registration of any systems." );
#/
		return;
	}
	if ( !isDefined( level._clientsys[ ssysname ] ) )
	{
/#
		error( "setClientSysState called on unregistered system " + ssysname );
#/
		return;
	}
	if ( isDefined( player ) )
	{
		player clientsyssetstate( level._clientsys[ ssysname ].sysid, ssysstate );
	}
	else
	{
		clientsyssetstate( level._clientsys[ ssysname ].sysid, ssysstate );
		level._clientsys[ ssysname ].sysstate = ssysstate;
	}
}

getclientsysstate( ssysname )
{
	if ( !isDefined( level._clientsys ) )
	{
/#
		error( "Cannot getClientSysState before registering any client systems." );
#/
		return "";
	}
	if ( !isDefined( level._clientsys[ ssysname ] ) )
	{
/#
		error( "Client system " + ssysname + " cannot return state, as it is unregistered." );
#/
		return "";
	}
	if ( isDefined( level._clientsys[ ssysname ].sysstate ) )
	{
		return level._clientsys[ ssysname ].sysstate;
	}
	return "";
}

clientnotify( event )
{
	if ( level.clientscripts )
	{
		if ( isplayer( self ) )
		{
			maps/mp/_utility::setclientsysstate( "levelNotify", event, self );
			return;
		}
		else
		{
			maps/mp/_utility::setclientsysstate( "levelNotify", event );
		}
	}
}

alphabet_compare( a, b )
{
	list = [];
	val = 1;
	list[ "0" ] = val;
	val++;
	list[ "1" ] = val;
	val++;
	list[ "2" ] = val;
	val++;
	list[ "3" ] = val;
	val++;
	list[ "4" ] = val;
	val++;
	list[ "5" ] = val;
	val++;
	list[ "6" ] = val;
	val++;
	list[ "7" ] = val;
	val++;
	list[ "8" ] = val;
	val++;
	list[ "9" ] = val;
	val++;
	list[ "_" ] = val;
	val++;
	list[ "a" ] = val;
	val++;
	list[ "b" ] = val;
	val++;
	list[ "c" ] = val;
	val++;
	list[ "d" ] = val;
	val++;
	list[ "e" ] = val;
	val++;
	list[ "f" ] = val;
	val++;
	list[ "g" ] = val;
	val++;
	list[ "h" ] = val;
	val++;
	list[ "i" ] = val;
	val++;
	list[ "j" ] = val;
	val++;
	list[ "k" ] = val;
	val++;
	list[ "l" ] = val;
	val++;
	list[ "m" ] = val;
	val++;
	list[ "n" ] = val;
	val++;
	list[ "o" ] = val;
	val++;
	list[ "p" ] = val;
	val++;
	list[ "q" ] = val;
	val++;
	list[ "r" ] = val;
	val++;
	list[ "s" ] = val;
	val++;
	list[ "t" ] = val;
	val++;
	list[ "u" ] = val;
	val++;
	list[ "v" ] = val;
	val++;
	list[ "w" ] = val;
	val++;
	list[ "x" ] = val;
	val++;
	list[ "y" ] = val;
	val++;
	list[ "z" ] = val;
	val++;
	a = tolower( a );
	b = tolower( b );
	val1 = 0;
	if ( isDefined( list[ a ] ) )
	{
		val1 = list[ a ];
	}
	val2 = 0;
	if ( isDefined( list[ b ] ) )
	{
		val2 = list[ b ];
	}
	if ( val1 > val2 )
	{
		return "1st";
	}
	if ( val1 < val2 )
	{
		return "2nd";
	}
	return "same";
}

is_later_in_alphabet( string1, string2 )
{
	count = string1.size;
	if ( count >= string2.size )
	{
		count = string2.size;
	}
	i = 0;
	while ( i < count )
	{
		val = alphabet_compare( string1[ i ], string2[ i ] );
		if ( val == "1st" )
		{
			return 1;
		}
		if ( val == "2nd" )
		{
			return 0;
		}
		i++;
	}
	return string1.size > string2.size;
}

alphabetize( array )
{
	if ( array.size <= 1 )
	{
		return array;
	}
	count = 0;
	for ( ;; )
	{
		changed = 0;
		i = 0;
		while ( i < ( array.size - 1 ) )
		{
			if ( is_later_in_alphabet( array[ i ], array[ i + 1 ] ) )
			{
				val = array[ i ];
				array[ i ] = array[ i + 1 ];
				array[ i + 1 ] = val;
				changed = 1;
				count++;
				if ( count >= 9 )
				{
					count = 0;
					wait 0,05;
				}
			}
			i++;
		}
		if ( !changed )
		{
			return array;
		}
	}
	return array;
}

get_players()
{
	players = getplayers();
	return players;
}

getfx( fx )
{
/#
	assert( isDefined( level._effect[ fx ] ), "Fx " + fx + " is not defined in level._effect." );
#/
	return level._effect[ fx ];
}

struct_arrayspawn()
{
	struct = spawnstruct();
	struct.array = [];
	struct.lastindex = 0;
	return struct;
}

structarray_add( struct, object )
{
/#
	assert( !isDefined( object.struct_array_index ) );
#/
	struct.array[ struct.lastindex ] = object;
	object.struct_array_index = struct.lastindex;
	struct.lastindex++;
}

structarray_remove( struct, object )
{
	structarray_swaptolast( struct, object );
	struct.lastindex--;

}

structarray_swaptolast( struct, object )
{
	struct structarray_swap( struct.array[ struct.lastindex - 1 ], object );
}

structarray_shuffle( struct, shuffle )
{
	i = 0;
	while ( i < shuffle )
	{
		struct structarray_swap( struct.array[ i ], struct.array[ randomint( struct.lastindex ) ] );
		i++;
	}
}

structarray_swap( object1, object2 )
{
	index1 = object1.struct_array_index;
	index2 = object2.struct_array_index;
	self.array[ index2 ] = object1;
	self.array[ index1 ] = object2;
	self.array[ index1 ].struct_array_index = index1;
	self.array[ index2 ].struct_array_index = index2;
}

waittill_either( msg1, msg2 )
{
	self endon( msg1 );
	self waittill( msg2 );
}

combinearrays( array1, array2 )
{
/#
	if ( !isDefined( array1 ) )
	{
		assert( isDefined( array2 ) );
	}
#/
	if ( !isDefined( array1 ) && isDefined( array2 ) )
	{
		return array2;
	}
	if ( !isDefined( array2 ) && isDefined( array1 ) )
	{
		return array1;
	}
	_a1822 = array2;
	_k1822 = getFirstArrayKey( _a1822 );
	while ( isDefined( _k1822 ) )
	{
		elem = _a1822[ _k1822 ];
		array1[ array1.size ] = elem;
		_k1822 = getNextArrayKey( _a1822, _k1822 );
	}
	return array1;
}

getclosest( org, array, dist )
{
	return comparesizes( org, array, dist, ::closerfunc );
}

getclosestfx( org, fxarray, dist )
{
	return comparesizesfx( org, fxarray, dist, ::closerfunc );
}

getfarthest( org, array, dist )
{
	return comparesizes( org, array, dist, ::fartherfunc );
}

comparesizesfx( org, array, dist, comparefunc )
{
	if ( !array.size )
	{
		return undefined;
	}
	if ( isDefined( dist ) )
	{
		distsqr = dist * dist;
		struct = undefined;
		keys = getarraykeys( array );
		i = 0;
		while ( i < keys.size )
		{
			newdistsqr = distancesquared( array[ keys[ i ] ].v[ "origin" ], org );
			if ( [[ comparefunc ]]( newdistsqr, distsqr ) )
			{
				i++;
				continue;
			}
			else
			{
				distsqr = newdistsqr;
				struct = array[ keys[ i ] ];
			}
			i++;
		}
		return struct;
	}
	keys = getarraykeys( array );
	struct = array[ keys[ 0 ] ];
	distsqr = distancesquared( struct.v[ "origin" ], org );
	i = 1;
	while ( i < keys.size )
	{
		newdistsqr = distancesquared( array[ keys[ i ] ].v[ "origin" ], org );
		if ( [[ comparefunc ]]( newdistsqr, distsqr ) )
		{
			i++;
			continue;
		}
		else
		{
			distsqr = newdistsqr;
			struct = array[ keys[ i ] ];
		}
		i++;
	}
	return struct;
}

comparesizes( org, array, dist, comparefunc )
{
	if ( !array.size )
	{
		return undefined;
	}
	if ( isDefined( dist ) )
	{
		distsqr = dist * dist;
		ent = undefined;
		keys = getarraykeys( array );
		i = 0;
		while ( i < keys.size )
		{
			if ( !isDefined( array[ keys[ i ] ] ) )
			{
				i++;
				continue;
			}
			else newdistsqr = distancesquared( array[ keys[ i ] ].origin, org );
			if ( [[ comparefunc ]]( newdistsqr, distsqr ) )
			{
				i++;
				continue;
			}
			else
			{
				distsqr = newdistsqr;
				ent = array[ keys[ i ] ];
			}
			i++;
		}
		return ent;
	}
	keys = getarraykeys( array );
	ent = array[ keys[ 0 ] ];
	distsqr = distancesquared( ent.origin, org );
	i = 1;
	while ( i < keys.size )
	{
		if ( !isDefined( array[ keys[ i ] ] ) )
		{
			i++;
			continue;
		}
		else newdistsqr = distancesquared( array[ keys[ i ] ].origin, org );
		if ( [[ comparefunc ]]( newdistsqr, distsqr ) )
		{
			i++;
			continue;
		}
		else
		{
			distsqr = newdistsqr;
			ent = array[ keys[ i ] ];
		}
		i++;
	}
	return ent;
}

closerfunc( dist1, dist2 )
{
	return dist1 >= dist2;
}

fartherfunc( dist1, dist2 )
{
	return dist1 <= dist2;
}

get_array_of_closest( org, array, excluders, max, maxdist )
{
	if ( !isDefined( max ) )
	{
		max = array.size;
	}
	if ( !isDefined( excluders ) )
	{
		excluders = [];
	}
	maxdists2rd = undefined;
	if ( isDefined( maxdist ) )
	{
		maxdists2rd = maxdist * maxdist;
	}
	dist = [];
	index = [];
	i = 0;
	while ( i < array.size )
	{
		if ( !isDefined( array[ i ] ) )
		{
			i++;
			continue;
		}
		else excluded = 0;
		p = 0;
		while ( p < excluders.size )
		{
			if ( array[ i ] != excluders[ p ] )
			{
				p++;
				continue;
			}
			else
			{
				excluded = 1;
				break;
			}
			p++;
		}
		if ( excluded )
		{
			i++;
			continue;
		}
		else length = distancesquared( org, array[ i ].origin );
		if ( isDefined( maxdists2rd ) && maxdists2rd < length )
		{
			i++;
			continue;
		}
		else
		{
			dist[ dist.size ] = length;
			index[ index.size ] = i;
		}
		i++;
	}
	for ( ;; )
	{
		change = 0;
		i = 0;
		while ( i < ( dist.size - 1 ) )
		{
			if ( dist[ i ] <= dist[ i + 1 ] )
			{
				i++;
				continue;
			}
			else
			{
				change = 1;
				temp = dist[ i ];
				dist[ i ] = dist[ i + 1 ];
				dist[ i + 1 ] = temp;
				temp = index[ i ];
				index[ i ] = index[ i + 1 ];
				index[ i + 1 ] = temp;
			}
			i++;
		}
		if ( !change )
		{
			break;
		}
		else
		{
		}
	}
	newarray = [];
	if ( max > dist.size )
	{
		max = dist.size;
	}
	i = 0;
	while ( i < max )
	{
		newarray[ i ] = array[ index[ i ] ];
		i++;
	}
	return newarray;
}

set_dvar_if_unset( dvar, value, reset )
{
	if ( !isDefined( reset ) )
	{
		reset = 0;
	}
	if ( reset || getDvar( dvar ) == "" )
	{
		setdvar( dvar, value );
		return value;
	}
	return getDvar( dvar );
}

set_dvar_float_if_unset( dvar, value, reset )
{
	if ( !isDefined( reset ) )
	{
		reset = 0;
	}
	if ( reset || getDvar( dvar ) == "" )
	{
		setdvar( dvar, value );
	}
	return getDvarFloat( dvar );
}

set_dvar_int_if_unset( dvar, value, reset )
{
	if ( !isDefined( reset ) )
	{
		reset = 0;
	}
	if ( reset || getDvar( dvar ) == "" )
	{
		setdvar( dvar, value );
		return int( value );
	}
	return getDvarInt( dvar );
}

drawcylinder( pos, rad, height, duration, stop_notify )
{
/#
	if ( !isDefined( duration ) )
	{
		duration = 0;
	}
	level thread drawcylinder_think( pos, rad, height, duration, stop_notify );
#/
}

drawcylinder_think( pos, rad, height, seconds, stop_notify )
{
/#
	if ( isDefined( stop_notify ) )
	{
		level endon( stop_notify );
	}
	stop_time = getTime() + ( seconds * 1000 );
	currad = rad;
	curheight = height;
	for ( ;; )
	{
		if ( seconds > 0 && stop_time <= getTime() )
		{
			return;
		}
		r = 0;
		while ( r < 20 )
		{
			theta = ( r / 20 ) * 360;
			theta2 = ( ( r + 1 ) / 20 ) * 360;
			line( pos + ( cos( theta ) * currad, sin( theta ) * currad, 0 ), pos + ( cos( theta2 ) * currad, sin( theta2 ) * currad, 0 ) );
			line( pos + ( cos( theta ) * currad, sin( theta ) * currad, curheight ), pos + ( cos( theta2 ) * currad, sin( theta2 ) * currad, curheight ) );
			line( pos + ( cos( theta ) * currad, sin( theta ) * currad, 0 ), pos + ( cos( theta ) * currad, sin( theta ) * currad, curheight ) );
			r++;
		}
		wait 0,05;
#/
	}
}

is_bot()
{
	if ( isplayer( self ) && isDefined( self.pers[ "isBot" ] ) )
	{
		return self.pers[ "isBot" ] != 0;
	}
}

add_trigger_to_ent( ent )
{
	if ( !isDefined( ent._triggers ) )
	{
		ent._triggers = [];
	}
	ent._triggers[ self getentitynumber() ] = 1;
}

remove_trigger_from_ent( ent )
{
	if ( !isDefined( ent ) )
	{
		return;
	}
	if ( !isDefined( ent._triggers ) )
	{
		return;
	}
	if ( !isDefined( ent._triggers[ self getentitynumber() ] ) )
	{
		return;
	}
	ent._triggers[ self getentitynumber() ] = 0;
}

ent_already_in_trigger( trig )
{
	if ( !isDefined( self._triggers ) )
	{
		return 0;
	}
	if ( !isDefined( self._triggers[ trig getentitynumber() ] ) )
	{
		return 0;
	}
	if ( !self._triggers[ trig getentitynumber() ] )
	{
		return 0;
	}
	return 1;
}

trigger_thread_death_monitor( ent, ender )
{
	ent waittill( "death" );
	self endon( ender );
	self remove_trigger_from_ent( ent );
}

trigger_thread( ent, on_enter_payload, on_exit_payload )
{
	ent endon( "entityshutdown" );
	ent endon( "death" );
	if ( ent ent_already_in_trigger( self ) )
	{
		return;
	}
	self add_trigger_to_ent( ent );
	ender = "end_trig_death_monitor" + self getentitynumber() + " " + ent getentitynumber();
	self thread trigger_thread_death_monitor( ent, ender );
	endon_condition = "leave_trigger_" + self getentitynumber();
	if ( isDefined( on_enter_payload ) )
	{
		self thread [[ on_enter_payload ]]( ent, endon_condition );
	}
	while ( isDefined( ent ) && ent istouching( self ) )
	{
		wait 0,01;
	}
	ent notify( endon_condition );
	if ( isDefined( ent ) && isDefined( on_exit_payload ) )
	{
		self thread [[ on_exit_payload ]]( ent );
	}
	if ( isDefined( ent ) )
	{
		self remove_trigger_from_ent( ent );
	}
	self notify( ender );
}

isoneround()
{
	if ( level.roundlimit == 1 )
	{
		return 1;
	}
	return 0;
}

isfirstround()
{
	if ( level.roundlimit > 1 && game[ "roundsplayed" ] == 0 )
	{
		return 1;
	}
	return 0;
}

islastround()
{
	if ( level.roundlimit > 1 && game[ "roundsplayed" ] >= ( level.roundlimit - 1 ) )
	{
		return 1;
	}
	return 0;
}

waslastround()
{
	if ( level.forcedend )
	{
		return 1;
	}
	if ( isDefined( level.shouldplayovertimeround ) )
	{
		if ( [[ level.shouldplayovertimeround ]]() )
		{
			level.nextroundisovertime = 1;
			return 0;
		}
		else
		{
			if ( isDefined( game[ "overtime_round" ] ) )
			{
				return 1;
			}
		}
	}
	if ( !hitroundlimit() || hitscorelimit() && hitroundwinlimit() )
	{
		return 1;
	}
	return 0;
}

hitroundlimit()
{
	if ( level.roundlimit <= 0 )
	{
		return 0;
	}
	return getroundsplayed() >= level.roundlimit;
}

anyteamhitroundwinlimit()
{
	_a2296 = level.teams;
	_k2296 = getFirstArrayKey( _a2296 );
	while ( isDefined( _k2296 ) )
	{
		team = _a2296[ _k2296 ];
		if ( getroundswon( team ) >= level.roundwinlimit )
		{
			return 1;
		}
		_k2296 = getNextArrayKey( _a2296, _k2296 );
	}
	return 0;
}

anyteamhitroundlimitwithdraws()
{
	tie_wins = game[ "roundswon" ][ "tie" ];
	_a2309 = level.teams;
	_k2309 = getFirstArrayKey( _a2309 );
	while ( isDefined( _k2309 ) )
	{
		team = _a2309[ _k2309 ];
		if ( ( getroundswon( team ) + tie_wins ) >= level.roundwinlimit )
		{
			return 1;
		}
		_k2309 = getNextArrayKey( _a2309, _k2309 );
	}
	return 0;
}

getroundwinlimitwinningteam()
{
	max_wins = 0;
	winning_team = undefined;
	_a2323 = level.teams;
	_k2323 = getFirstArrayKey( _a2323 );
	while ( isDefined( _k2323 ) )
	{
		team = _a2323[ _k2323 ];
		wins = getroundswon( team );
		if ( !isDefined( winning_team ) )
		{
			max_wins = wins;
			winning_team = team;
		}
		else if ( wins == max_wins )
		{
			winning_team = "tie";
		}
		else
		{
			if ( wins > max_wins )
			{
				max_wins = wins;
				winning_team = team;
			}
		}
		_k2323 = getNextArrayKey( _a2323, _k2323 );
	}
	return winning_team;
}

hitroundwinlimit()
{
	if ( !isDefined( level.roundwinlimit ) || level.roundwinlimit <= 0 )
	{
		return 0;
	}
	if ( anyteamhitroundwinlimit() )
	{
		return 1;
	}
	if ( anyteamhitroundlimitwithdraws() )
	{
		if ( getroundwinlimitwinningteam() != "tie" )
		{
			return 1;
		}
	}
	return 0;
}

anyteamhitscorelimit()
{
	_a2379 = level.teams;
	_k2379 = getFirstArrayKey( _a2379 );
	while ( isDefined( _k2379 ) )
	{
		team = _a2379[ _k2379 ];
		if ( game[ "teamScores" ][ team ] >= level.scorelimit )
		{
			return 1;
		}
		_k2379 = getNextArrayKey( _a2379, _k2379 );
	}
	return 0;
}

hitscorelimit()
{
	if ( isscoreroundbased() )
	{
		return 0;
	}
	if ( level.scorelimit <= 0 )
	{
		return 0;
	}
	if ( level.teambased )
	{
		if ( anyteamhitscorelimit() )
		{
			return 1;
		}
	}
	else
	{
		i = 0;
		while ( i < level.players.size )
		{
			player = level.players[ i ];
			if ( isDefined( player.pointstowin ) && player.pointstowin >= level.scorelimit )
			{
				return 1;
			}
			i++;
		}
	}
	return 0;
}

getroundswon( team )
{
	return game[ "roundswon" ][ team ];
}

getotherteamsroundswon( skip_team )
{
	roundswon = 0;
	_a2423 = level.teams;
	_k2423 = getFirstArrayKey( _a2423 );
	while ( isDefined( _k2423 ) )
	{
		team = _a2423[ _k2423 ];
		if ( team == skip_team )
		{
		}
		else
		{
			roundswon += game[ "roundswon" ][ team ];
		}
		_k2423 = getNextArrayKey( _a2423, _k2423 );
	}
	return roundswon;
}

getroundsplayed()
{
	return game[ "roundsplayed" ];
}

isscoreroundbased()
{
	return level.scoreroundbased;
}

isroundbased()
{
	if ( level.roundlimit != 1 && level.roundwinlimit != 1 )
	{
		return 1;
	}
	return 0;
}

waittillnotmoving()
{
	if ( self ishacked() )
	{
		wait 0,05;
		return;
	}
	if ( self.classname == "grenade" )
	{
		self waittill( "stationary" );
	}
	else prevorigin = self.origin;
	while ( 1 )
	{
		wait 0,15;
		if ( self.origin == prevorigin )
		{
			return;
		}
		else
		{
			prevorigin = self.origin;
		}
	}
}

mayapplyscreeneffect()
{
/#
	assert( isDefined( self ) );
#/
/#
	assert( isplayer( self ) );
#/
	return !isDefined( self.viewlockedentity );
}

getdvarfloatdefault( dvarname, defaultvalue )
{
	value = getDvar( dvarname );
	if ( value != "" )
	{
		return float( value );
	}
	return defaultvalue;
}

getdvarintdefault( dvarname, defaultvalue )
{
	value = getDvar( dvarname );
	if ( value != "" )
	{
		return int( value );
	}
	return defaultvalue;
}

closestpointonline( point, linestart, lineend )
{
	linemagsqrd = lengthsquared( lineend - linestart );
	t = ( ( ( ( point[ 0 ] - linestart[ 0 ] ) * ( lineend[ 0 ] - linestart[ 0 ] ) ) + ( ( point[ 1 ] - linestart[ 1 ] ) * ( lineend[ 1 ] - linestart[ 1 ] ) ) ) + ( ( point[ 2 ] - linestart[ 2 ] ) * ( lineend[ 2 ] - linestart[ 2 ] ) ) ) / linemagsqrd;
	if ( t < 0 )
	{
		return linestart;
	}
	else
	{
		if ( t > 1 )
		{
			return lineend;
		}
	}
	start_x = linestart[ 0 ] + ( t * ( lineend[ 0 ] - linestart[ 0 ] ) );
	start_y = linestart[ 1 ] + ( t * ( lineend[ 1 ] - linestart[ 1 ] ) );
	start_z = linestart[ 2 ] + ( t * ( lineend[ 2 ] - linestart[ 2 ] ) );
	return ( start_x, start_y, start_z );
}

isstrstart( string1, substr )
{
	return getsubstr( string1, 0, substr.size ) == substr;
}

spread_array_thread( entities, process, var1, var2, var3 )
{
	keys = getarraykeys( entities );
	if ( isDefined( var3 ) )
	{
		i = 0;
		while ( i < keys.size )
		{
			entities[ keys[ i ] ] thread [[ process ]]( var1, var2, var3 );
			wait 0,1;
			i++;
		}
		return;
	}
	if ( isDefined( var2 ) )
	{
		i = 0;
		while ( i < keys.size )
		{
			entities[ keys[ i ] ] thread [[ process ]]( var1, var2 );
			wait 0,1;
			i++;
		}
		return;
	}
	if ( isDefined( var1 ) )
	{
		i = 0;
		while ( i < keys.size )
		{
			entities[ keys[ i ] ] thread [[ process ]]( var1 );
			wait 0,1;
			i++;
		}
		return;
	}
	i = 0;
	while ( i < keys.size )
	{
		entities[ keys[ i ] ] thread [[ process ]]();
		wait 0,1;
		i++;
	}
}

freeze_player_controls( boolean )
{
/#
	assert( isDefined( boolean ), "'freeze_player_controls()' has not been passed an argument properly." );
#/
	if ( boolean && isDefined( self ) )
	{
		self freezecontrols( boolean );
	}
	else
	{
		if ( !boolean && isDefined( self ) && !level.gameended )
		{
			self freezecontrols( boolean );
		}
	}
}

gethostplayer()
{
	players = get_players();
	index = 0;
	while ( index < players.size )
	{
		if ( players[ index ] ishost() )
		{
			return players[ index ];
		}
		index++;
	}
}

gethostplayerforbots()
{
	players = get_players();
	index = 0;
	while ( index < players.size )
	{
		if ( players[ index ] ishostforbots() )
		{
			return players[ index ];
		}
		index++;
	}
}

ispregame()
{
	if ( isDefined( level.pregame ) )
	{
		return level.pregame;
	}
}

iskillstreaksenabled()
{
	if ( isDefined( level.killstreaksenabled ) )
	{
		return level.killstreaksenabled;
	}
}

isrankenabled()
{
	if ( isDefined( level.rankenabled ) )
	{
		return level.rankenabled;
	}
}

playsmokesound( position, duration, startsound, stopsound, loopsound )
{
	smokesound = spawn( "script_origin", ( 0, 0, 1 ) );
	smokesound.origin = position;
	smokesound playsound( startsound );
	smokesound playloopsound( loopsound );
	if ( duration > 0,5 )
	{
		wait ( duration - 0,5 );
	}
	thread playsoundinspace( stopsound, position );
	smokesound stoploopsound( 0,5 );
	wait 0,5;
	smokesound delete();
}

playsoundinspace( alias, origin, master )
{
	org = spawn( "script_origin", ( 0, 0, 1 ) );
	if ( !isDefined( origin ) )
	{
		origin = self.origin;
	}
	org.origin = origin;
	if ( isDefined( master ) && master )
	{
		org playsoundasmaster( alias );
	}
	else
	{
		org playsound( alias );
	}
	wait 10;
	org delete();
}

get2dyaw( start, end )
{
	yaw = 0;
	vector = ( end[ 0 ] - start[ 0 ], end[ 1 ] - start[ 1 ], 0 );
	return vectoangles( vector );
}

vectoangles( vector )
{
	yaw = 0;
	vecx = vector[ 0 ];
	vecy = vector[ 1 ];
	if ( vecx == 0 && vecy == 0 )
	{
		return 0;
	}
	if ( vecy < 0,001 && vecy > -0,001 )
	{
		vecy = 0,001;
	}
	yaw = atan( vecx / vecy );
	if ( vecy < 0 )
	{
		yaw += 180;
	}
	return 90 - yaw;
}

deleteaftertime( time )
{
/#
	assert( isDefined( self ) );
#/
/#
	assert( isDefined( time ) );
#/
/#
	assert( time >= 0,05 );
#/
	self thread deleteaftertimethread( time );
}

deleteaftertimethread( time )
{
	self endon( "death" );
	wait time;
	self delete();
}

setusingremote( remotename )
{
	if ( isDefined( self.carryicon ) )
	{
		self.carryicon.alpha = 0;
	}
/#
	assert( !self isusingremote() );
#/
	self.usingremote = remotename;
	self disableoffhandweapons();
	self notify( "using_remote" );
}

getremotename()
{
/#
	assert( self isusingremote() );
#/
	return self.usingremote;
}

isusingremote()
{
	return isDefined( self.usingremote );
}

getlastweapon()
{
	last_weapon = undefined;
	if ( self hasweapon( self.lastnonkillstreakweapon ) )
	{
		last_weapon = self.lastnonkillstreakweapon;
	}
	else
	{
		if ( self hasweapon( self.lastdroppableweapon ) )
		{
			last_weapon = self.lastdroppableweapon;
		}
	}
/#
	assert( isDefined( last_weapon ) );
#/
	return last_weapon;
}

freezecontrolswrapper( frozen )
{
	if ( isDefined( level.hostmigrationtimer ) )
	{
		self freeze_player_controls( 1 );
		return;
	}
	self freeze_player_controls( frozen );
}

setobjectivetext( team, text )
{
	game[ "strings" ][ "objective_" + team ] = text;
	precachestring( text );
}

setobjectivescoretext( team, text )
{
	game[ "strings" ][ "objective_score_" + team ] = text;
	precachestring( text );
}

setobjectivehinttext( team, text )
{
	game[ "strings" ][ "objective_hint_" + team ] = text;
	precachestring( text );
}

getobjectivetext( team )
{
	return game[ "strings" ][ "objective_" + team ];
}

getobjectivescoretext( team )
{
	return game[ "strings" ][ "objective_score_" + team ];
}

getobjectivehinttext( team )
{
	return game[ "strings" ][ "objective_hint_" + team ];
}

registerroundswitch( minvalue, maxvalue )
{
	level.roundswitch = clamp( getgametypesetting( "roundSwitch" ), minvalue, maxvalue );
	level.roundswitchmin = minvalue;
	level.roundswitchmax = maxvalue;
}

registerroundlimit( minvalue, maxvalue )
{
	level.roundlimit = clamp( getgametypesetting( "roundLimit" ), minvalue, maxvalue );
	level.roundlimitmin = minvalue;
	level.roundlimitmax = maxvalue;
}

registerroundwinlimit( minvalue, maxvalue )
{
	level.roundwinlimit = clamp( getgametypesetting( "roundWinLimit" ), minvalue, maxvalue );
	level.roundwinlimitmin = minvalue;
	level.roundwinlimitmax = maxvalue;
}

registerscorelimit( minvalue, maxvalue )
{
	level.scorelimit = clamp( getgametypesetting( "scoreLimit" ), minvalue, maxvalue );
	level.scorelimitmin = minvalue;
	level.scorelimitmax = maxvalue;
	setdvar( "ui_scorelimit", level.scorelimit );
}

registertimelimit( minvalue, maxvalue )
{
	level.timelimit = clamp( getgametypesetting( "timeLimit" ), minvalue, maxvalue );
	level.timelimitmin = minvalue;
	level.timelimitmax = maxvalue;
	setdvar( "ui_timelimit", level.timelimit );
}

registernumlives( minvalue, maxvalue )
{
	level.numlives = clamp( getgametypesetting( "playerNumLives" ), minvalue, maxvalue );
	level.numlivesmin = minvalue;
	level.numlivesmax = maxvalue;
}

getplayerfromclientnum( clientnum )
{
	if ( clientnum < 0 )
	{
		return undefined;
	}
	i = 0;
	while ( i < level.players.size )
	{
		if ( level.players[ i ] getentitynumber() == clientnum )
		{
			return level.players[ i ];
		}
		i++;
	}
	return undefined;
}

setclientfield( field_name, value )
{
	if ( self == level )
	{
		codesetworldclientfield( field_name, value );
	}
	else
	{
		codesetclientfield( self, field_name, value );
	}
}

setclientfieldtoplayer( field_name, value )
{
	codesetplayerstateclientfield( self, field_name, value );
}

getclientfield( field_name )
{
	if ( self == level )
	{
		return codegetworldclientfield( field_name );
	}
	else
	{
		return codegetclientfield( self, field_name );
	}
}

getclientfieldtoplayer( field_name )
{
	return codegetplayerstateclientfield( self, field_name );
}

isenemyplayer( player )
{
/#
	assert( isDefined( player ) );
#/
	if ( !isplayer( player ) )
	{
		return 0;
	}
	if ( level.teambased )
	{
		if ( player.team == self.team )
		{
			return 0;
		}
	}
	else
	{
		if ( player == self )
		{
			return 0;
		}
	}
	return 1;
}

getweaponclass( weapon )
{
/#
	assert( isDefined( weapon ) );
#/
	if ( !isDefined( weapon ) )
	{
		return undefined;
	}
	if ( !isDefined( level.weaponclassarray ) )
	{
		level.weaponclassarray = [];
	}
	if ( isDefined( level.weaponclassarray[ weapon ] ) )
	{
		return level.weaponclassarray[ weapon ];
	}
	baseweaponindex = getbaseweaponitemindex( weapon ) + 1;
	weaponclass = tablelookupcolumnforrow( "mp/statstable.csv", baseweaponindex, 2 );
	level.weaponclassarray[ weapon ] = weaponclass;
	return weaponclass;
}

ispressbuild()
{
	buildtype = getDvar( #"19B966D7" );
	if ( isDefined( buildtype ) && buildtype == "press" )
	{
		return 1;
	}
	return 0;
}

isflashbanged()
{
	if ( isDefined( self.flashendtime ) )
	{
		return getTime() < self.flashendtime;
	}
}

ishacked()
{
	if ( isDefined( self.hacked ) )
	{
		return self.hacked;
	}
}

domaxdamage( origin, attacker, inflictor, headshot, mod )
{
	if ( isDefined( self.damagedtodeath ) && self.damagedtodeath )
	{
		return;
	}
	if ( isDefined( self.maxhealth ) )
	{
		damage = self.maxhealth + 1;
	}
	else
	{
		damage = self.health + 1;
	}
	self.damagedtodeath = 1;
	self dodamage( damage, origin, attacker, inflictor, headshot, mod );
}
