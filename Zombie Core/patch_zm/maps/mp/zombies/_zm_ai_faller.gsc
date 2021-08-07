#include maps/mp/zombies/_zm_laststand;
#include maps/mp/animscripts/zm_shared;
#include maps/mp/zombies/_zm_spawner;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

zombie_faller_delete() //checked matches cerberus output
{
	level.zombie_total++;
	self maps/mp/zombies/_zm_spawner::reset_attack_spot();
	if ( isDefined( self.zombie_faller_location ) )
	{
		self.zombie_faller_location.is_enabled = 1;
		self.zombie_faller_location = undefined;
	}
	self delete();
}

faller_script_parameters() //checked changed to match cerberus output
{
	if ( isDefined( self.script_parameters ) )
	{
		parms = strtok( self.script_parameters, ";" );
		if ( isDefined( parms ) && parms.size > 0 )
		{
			for ( i = 0; i < parms.size; i++ )
			{
				if ( parms[ i ] == "drop_now" )
				{
					self.drop_now = 1;
				}
				if ( parms[ i ] == "drop_not_occupied" )
				{
					self.drop_not_occupied = 1;
				}
				if ( parms[ i ] == "emerge_top" )
				{
					self.emerge_top = 1;
				}
				if ( parms[ i ] == "emerge_bottom" )
				{
					self.emerge_bottom = 1;
				}
			}
		}
	}
}

setup_deathfunc( func_name ) //checked matches cerberus output
{
	self endon( "death" );
	while ( !is_true( self.zombie_init_done ) )
	{
		wait_network_frame();
	}
	if ( isDefined( func_name ) )
	{
		self.deathfunction = func_name;
	}
	else if ( isDefined( level.custom_faller_death ) )
	{
		self.deathfunction = level.custom_faller_death;
	}
	else
	{
		self.deathfunction = ::zombie_fall_death_func;
	}
}

do_zombie_fall( spot ) //checked changed to match cerberus output
{
	self endon( "death" );
	self.zombie_faller_location = spot;
	self.zombie_faller_location.is_enabled = 0;
	self.zombie_faller_location faller_script_parameters();
	if ( is_true( self.zombie_faller_location.emerge_bottom ) || is_true( self.zombie_faller_location.emerge_top ) )
	{
		self do_zombie_emerge( spot );
		return;
	}
	self thread setup_deathfunc();
	self.no_powerups = 1;
	self.in_the_ceiling = 1;
	self.anchor = spawn( "script_origin", self.origin );
	self.anchor.angles = self.angles;
	self linkto( self.anchor );
	if ( !isDefined( spot.angles ) )
	{
		spot.angles = ( 0, 0, 0 );
	}
	anim_org = spot.origin;
	anim_ang = spot.angles;
	self ghost();
	self.anchor moveto( anim_org, 0.05 );
	self.anchor waittill( "movedone" );
	target_org = get_desired_origin();
	if ( isDefined( target_org ) )
	{
		anim_ang = vectorToAngles( target_org - self.origin );
		self.anchor rotateto( ( 0, anim_ang[ 1 ], 0 ), 0.05 );
		self.anchor waittill( "rotatedone" );
	}
	self unlink();
	if ( isDefined( self.anchor ) )
	{
		self.anchor delete();
	}
	self thread maps/mp/zombies/_zm_spawner::hide_pop();
	self thread zombie_fall_death( spot );
	self thread zombie_fall_fx( spot );
	self thread zombie_faller_death_wait();
	self thread zombie_faller_do_fall();
	self.no_powerups = 0;
	self notify( "risen", spot.script_string );
}

zombie_faller_do_fall() //checked changed to match cerberus output
{
	self endon( "death" );
	self animscripted( self.origin, self.zombie_faller_location.angles, "zm_faller_emerge" );
	self maps/mp/animscripts/zm_shared::donotetracks( "emerge_anim", ::handle_fall_notetracks, self.zombie_faller_location );
	self.zombie_faller_wait_start = getTime();
	self.zombie_faller_should_drop = 0;
	self thread zombie_fall_wait();
	self thread zombie_faller_watch_all_players();
	while ( !self.zombie_faller_should_drop )
	{
		if ( self zombie_fall_should_attack( self.zombie_faller_location ) )
		{
			self animscripted( self.origin, self.zombie_faller_location.angles, "zm_faller_attack" );
			self maps/mp/animscripts/zm_shared::donotetracks( "attack_anim", ::handle_fall_notetracks, self.zombie_faller_location );
			if ( !self zombie_faller_always_drop() && randomfloat( 1 ) > 0.5 )
			{
				self.zombie_faller_should_drop = 1;
			}
		}
		else if ( self zombie_faller_always_drop() )
		{
			self.zombie_faller_should_drop = 1;
			break;
		}
		else if ( getTime() >= ( self.zombie_faller_wait_start + 20000 ) )
		{
			self.zombie_faller_should_drop = 1;
			break;
		}
		else if ( self zombie_faller_drop_not_occupied() )
		{
			self.zombie_faller_should_drop = 1;
			break;
		}
		else 
		{
			self animscripted( self.origin, self.zombie_faller_location.angles, "zm_faller_attack" );
			self maps/mp/animscripts/zm_shared::donotetracks( "attack_anim", ::handle_fall_notetracks, self.zombie_faller_location );
		}
	}
	self notify( "falling" );
	spot = self.zombie_faller_location;
	self zombie_faller_enable_location();
	self animscripted( self.origin, spot.angles, "zm_faller_fall" );
	self maps/mp/animscripts/zm_shared::donotetracks( "fall_anim", ::handle_fall_notetracks, spot );
	self.deathfunction = maps/mp/zombies/_zm_spawner::zombie_death_animscript;
	self notify( "fall_anim_finished" );
	spot notify( "stop_zombie_fall_fx" );
	self stopanimscripted();
	landanimdelta = 15;
	ground_pos = groundpos_ignore_water_new( self.origin );
	physdist = self.origin[ 2 ] - ground_pos[ 2 ] + landanimdelta;
	if ( physdist > 0 )
	{
		self animcustom( ::zombie_fall_loop );
		self waittill( "faller_on_ground" );
		self animcustom( ::zombie_land );
		self waittill( "zombie_land_done" );
	}
	self.in_the_ceiling = 0;
	self traversemode( "gravity" );
	self.no_powerups = 0;
}

zombie_fall_loop() //checked changed to match cerberus output
{
	self endon( "death" );
	self setanimstatefromasd( "zm_faller_fall_loop" );
	while ( 1 )
	{
		ground_pos = groundpos_ignore_water_new( self.origin );
		if ( self.origin[ 2 ] - ground_pos[ 2 ] < 20 )
		{
			self notify( "faller_on_ground" );
			break;
		}
		wait 0.05;
	}
}

zombie_land() //checked matches cerberus output
{
	self setanimstatefromasd( "zm_faller_land" );
	maps/mp/animscripts/zm_shared::donotetracks( "land_anim" );
	self notify( "zombie_land_done" );
}

zombie_faller_always_drop() //checked matches cerberus output
{
	if ( is_true( self.zombie_faller_location.drop_now ) )
	{
		return 1;
	}
	return 0;
}

zombie_faller_drop_not_occupied() //checked matches cerberus output
{
	if ( is_true( self.zombie_faller_location.drop_not_occupied ) )
	{
		if ( isDefined( self.zone_name ) && isDefined( level.zones[ self.zone_name ] ) )
		{
			return !level.zones[ self.zone_name ].is_occupied;
		}
	}
	return 0;
}

zombie_faller_watch_all_players() //checked changed to match cerberus output
{
	players = get_players();
	for ( i = 0; i < players.size; i++ )
	{
		self thread zombie_faller_watch_player( players[ i ] );
	}
}

zombie_faller_watch_player( player ) //checked changed to match cerberus output
{
	self endon( "falling" );
	self endon( "death" );
	player endon( "disconnect" );
	range = 200;
	rangesqr = range * range;
	timer = 5000;
	inrange = 0;
	inrangetime = 0;
	closerange = 60;
	closerangesqr = closerange * closerange;
	dirtoplayerenter = ( 0, 0, 0 );
	incloserange = 0;
	while ( 1 )
	{
		distsqr = distance2dsquared( self.origin, player.origin );
		if ( distsqr < rangesqr )
		{
			if ( inrange )
			{
				if ( ( inrangetime + timer ) < getTime() )
				{
					self.zombie_faller_should_drop = 1;
					break;
				}
			}
			else
			{
				inrange = 1;
				inrangetime = getTime();
			}
		}
		else
		{
			inrange = 0;
		}
		if ( distsqr < closerangesqr )
		{
			if ( !incloserange )
			{
				dirtoplayerenter = player.origin - self.origin;
				dirtoplayerenter = ( dirtoplayerenter[ 0 ], dirtoplayerenter[ 1 ], 0 );
				dirtoplayerenter = vectornormalize( dirtoplayerenter );
			}
			incloserange = 1;
		}
		else if ( incloserange )
		{
			dirtoplayerexit = player.origin - self.origin;
			dirtoplayerexit = ( dirtoplayerexit[ 0 ], dirtoplayerexit[ 1 ], 0 );
			dirtoplayerexit = vectornormalize( dirtoplayerexit );
			if ( vectordot( dirtoplayerenter, dirtoplayerexit ) < 0 )
			{
				self.zombie_faller_should_drop = 1;
				break;
			}
		}
		incloserange = 0;
		wait 0.1;
	}
}

zombie_fall_wait() //checked changed to match cerberus output
{
	self endon( "falling" );
	self endon( "death" );
	if ( isDefined( self.zone_name ) )
	{
		if ( isDefined( level.zones ) && isDefined( level.zones[ self.zone_name ] ) )
		{
			zone = level.zones[ self.zone_name ];
			while ( 1 )
			{
				if ( !zone.is_enabled || !zone.is_active )
				{
					if ( !self potentially_visible( 2250000 ) )
					{
						if ( self.health != level.zombie_health )
						{
							self.zombie_faller_should_drop = 1;
							break;
						}
						else 
						{
							self zombie_faller_delete();
							return;
						}
					}
				}
				wait 0.5;
			}
		}
	}
}

zombie_fall_should_attack( spot )
{
	victims = zombie_fall_get_vicitims( spot );
	return victims.size > 0;
}

zombie_fall_get_vicitims( spot ) //checked partially changed to match cerberus output //continues in for loops bad
{
	ret = [];
	players = getplayers();
	checkdist2 = 40;
	checkdist2 *= checkdist2;
	i = 0;
	while ( i < players.size )
	{
		player = players[ i ];
		if ( player maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
		{
			i++;
			continue;
		}
		stance = player getstance();
		if ( stance == "crouch" || stance == "prone" )
		{
			i++;
			continue;
		}
		zcheck = self.origin[ 2 ] - player.origin[ 2 ];
		if ( zcheck < 0 || zcheck > 120 )
		{
			i++;
			continue;
		}
		dist2 = distance2dsquared( player.origin, self.origin );
		if ( dist2 < checkdist2 )
		{
			ret[ ret.size ] = player;
		}
		i++;
	}
	return ret;
}

get_fall_anim( spot ) //checked matches cerberus output
{
	return level._zombie_fall_anims[ self.animname ][ "fall" ];
}

zombie_faller_enable_location() //checked matches cerberus output
{
	if ( isDefined( self.zombie_faller_location ) )
	{
		self.zombie_faller_location.is_enabled = 1;
		self.zombie_faller_location = undefined;
	}
}

zombie_faller_death_wait( endon_notify ) //checked matches cerberus output
{
	self endon( "falling" );
	if ( isDefined( endon_notify ) )
	{
		self endon( endon_notify );
	}
	self waittill( "death" );
	self zombie_faller_enable_location();
}

zombie_fall_death_func() //checked matches cerberus output
{
	self animmode( "noclip" );
	self.deathanim = "zm_faller_emerge_death";
	return self maps/mp/zombies/_zm_spawner::zombie_death_animscript();
}

zombie_fall_death( spot ) //checked matches cerberus output
{
	self endon( "fall_anim_finished" );
	while ( self.health > 1 )
	{
		self waittill( "damage", amount, attacker, dir, p, type );
	}
	self stopanimscripted();
	spot notify( "stop_zombie_fall_fx" );
}

_damage_mod_to_damage_type( type ) //checked changed to match cerberus output
{
	toks = strtok( type, "_" );
	if ( toks.size < 2 )
	{
		return type;
	}
	returnstr = toks[ 1 ];
	for ( i = 2; i < toks.size; i++ )
	{
		returnstr += toks[ i ];
	}
	returnstr = tolower( returnstr );
	return returnstr;
}

zombie_fall_fx( spot ) //checked matches cerberus output
{
	spot thread zombie_fall_dust_fx( self );
	spot thread zombie_fall_burst_fx();
	playsoundatposition( "zmb_zombie_spawn", spot.origin );
	self endon( "death" );
	spot endon( "stop_zombie_fall_fx" );
	wait 1;
	if ( self.zombie_move_speed != "sprint" )
	{
		wait 1;
	}
}

zombie_fall_burst_fx() //checked matches cerberus output
{
	self endon( "stop_zombie_fall_fx" );
	self endon( "fall_anim_finished" );
	playfx( level._effect[ "rise_burst" ], self.origin + ( 0, 0, randomintrange( 5, 10 ) ) );
	wait 0.25;
	playfx( level._effect[ "rise_billow" ], self.origin + ( randomintrange( -10, 10 ), randomintrange( -10, 10 ), randomintrange( 5, 10 ) ) );
}

zombie_fall_dust_fx( zombie ) //checked does not match cerberus output did not change
{
	dust_tag = "J_SpineUpper";
	self endon( "stop_zombie_fall_dust_fx" );
	self thread stop_zombie_fall_dust_fx( zombie );
	dust_time = 4.5;
	dust_interval = 0.3;
	t = 0;
	while ( t < dust_time )
	{
		playfxontag( level._effect[ "rise_dust" ], zombie, dust_tag );
		wait dust_interval;
		t += dust_interval;
	}
}

stop_zombie_fall_dust_fx( zombie ) //checked matches cerberus output
{
	zombie waittill( "death" );
	self notify( "stop_zombie_fall_dust_fx" );
}

handle_fall_notetracks( note, spot ) //checked changed to match cerberus output
{
	if ( note == "deathout" )
	{
		self.deathfunction = ::faller_death_ragdoll;
	}
	if ( note == "fire" )
	{
		victims = zombie_fall_get_vicitims( spot );
		for ( i = 0; i < victims.size; i++)
		{
			victims[ i ] dodamage( self.meleedamage, self.origin, self, self, "none", "MOD_MELEE" );
			self.zombie_faller_should_drop = 1;
		}
	}
}

faller_death_ragdoll() //checked matches cerberus output
{
	self startragdoll();
	self launchragdoll( ( 0, 0, -1 ) );
	return self maps/mp/zombies/_zm_spawner::zombie_death_animscript();
}

in_player_fov( player ) //checked does not match cerberus output did not change
{
	playerangles = player getplayerangles();
	playerforwardvec = anglesToForward( playerangles );
	playerunitforwardvec = vectornormalize( playerforwardvec );
	banzaipos = self.origin;
	playerpos = player getorigin();
	playertobanzaivec = banzaipos - playerpos;
	playertobanzaiunitvec = vectornormalize( playertobanzaivec );
	forwarddotbanzai = vectordot( playerunitforwardvec, playertobanzaiunitvec );
	anglefromcenter = acos( forwarddotbanzai );
	playerfov = getDvarFloat( "cg_fov" );
	banzaivsplayerfovbuffer = getDvarFloat( "g_banzai_player_fov_buffer" );
	if ( banzaivsplayerfovbuffer <= 0 )
	{
		banzaivsplayerfovbuffer = 0.2;
	}
	inplayerfov = anglefromcenter <= ( playerfov * 0.5 ) * ( 1 - banzaivsplayerfovbuffer );
	return inplayerfov;
}

potentially_visible( how_close ) //checked changed to match cerberus output
{
	if ( !isDefined( how_close ) )
	{
		how_close = 1000000;
	}
	potentiallyvisible = 0;
	players = getplayers();
	for ( i = 0; i < players.size; i++ )
	{
		dist = distancesquared( self.origin, players[ i ].origin );
		if ( dist < how_close )
		{
			inplayerfov = self in_player_fov( players[ i ] );
			if ( inplayerfov )
			{
				potentiallyvisible = 1;
				break;
			}
		}
	}
	return potentiallyvisible;
}

do_zombie_emerge( spot ) //checked changed to match cerberus output
{
	self endon( "death" );
	self thread setup_deathfunc( ::faller_death_ragdoll );
	self.no_powerups = 1;
	self.in_the_ceiling = 1;
	anim_org = spot.origin;
	anim_ang = spot.angles;
	self thread zombie_emerge_fx( spot );
	self thread zombie_faller_death_wait( "risen" );
	if ( isDefined( level.custom_faller_entrance_logic ) )
	{
		self thread [[ level.custom_faller_entrance_logic ]]();
	}
	self zombie_faller_emerge( spot );
	self.create_eyes = 1;
	wait 0.1;
	self notify( "risen", spot.script_string );
	self zombie_faller_enable_location();
}

zombie_faller_emerge( spot ) //checked matches cerberus output
{
	self endon( "death" );
	if ( is_true( self.zombie_faller_location.emerge_bottom ) )
	{
		self animscripted( self.zombie_faller_location.origin, self.zombie_faller_location.angles, "zombie_riser_elevator_from_floor" );
	}
	else
	{
		self animscripted( self.zombie_faller_location.origin, self.zombie_faller_location.angles, "zombie_riser_elevator_from_ceiling" );
	}
	self maps/mp/animscripts/zm_shared::donotetracks( "rise_anim" );
	self.deathfunction = maps/mp/zombies/_zm_spawner::zombie_death_animscript;
	self.in_the_ceiling = 0;
	self.no_powerups = 0;
}

zombie_emerge_fx( spot ) //checked matches cerberus output
{
	spot thread zombie_emerge_dust_fx( self );
	playsoundatposition( "zmb_zombie_spawn", spot.origin );
	self endon( "death" );
	spot endon( "stop_zombie_fall_fx" );
	wait 1;
}

zombie_emerge_dust_fx( zombie ) //checked does not match cerberus output did not change
{
	dust_tag = "J_SpineUpper";
	self endon( "stop_zombie_fall_dust_fx" );
	self thread stop_zombie_fall_dust_fx( zombie );
	dust_time = 3.5;
	dust_interval = 0.5;
	t = 0;
	while ( t < dust_time )
	{
		playfxontag( level._effect[ "rise_dust" ], zombie, dust_tag );
		wait dust_interval;
		t += dust_interval;
	}
}

stop_zombie_emerge_dust_fx( zombie ) //checked matches cerberus output
{
	zombie waittill( "death" );
	self notify( "stop_zombie_fall_dust_fx" );
}


