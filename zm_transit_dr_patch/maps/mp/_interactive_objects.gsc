#include common_scripts/utility;
#include maps/mp/_utility;

init()
{
	level.barrelexplodingthisframe = 0;
	qbarrels = 0;
	all_barrels = [];
	barrels = getentarray( "explodable_barrel", "targetname" );
	while ( isDefined( barrels ) && barrels.size > 0 )
	{
		qbarrels = 1;
		i = 0;
		while ( i < barrels.size )
		{
			all_barrels[ all_barrels.size ] = barrels[ i ];
			i++;
		}
	}
	barrels = getentarray( "explodable_barrel", "script_noteworthy" );
	while ( isDefined( barrels ) && barrels.size > 0 )
	{
		qbarrels = 1;
		i = 0;
		while ( i < barrels.size )
		{
			all_barrels[ all_barrels.size ] = barrels[ i ];
			i++;
		}
	}
	if ( qbarrels )
	{
		precachemodel( "global_explosive_barrel" );
		level.barrelburn = 100;
		level.barrelhealth = 250;
		level.barrelingsound = "exp_redbarrel_ignition";
		level.barrelexpsound = "exp_redbarrel";
		level.breakables_fx[ "barrel" ][ "burn_start" ] = loadfx( "destructibles/fx_barrel_ignite" );
		level.breakables_fx[ "barrel" ][ "burn" ] = loadfx( "destructibles/fx_barrel_fire_top" );
		level.breakables_fx[ "barrel" ][ "explode" ] = loadfx( "destructibles/fx_barrelexp" );
		array_thread( all_barrels, ::explodable_barrel_think );
	}
	qcrates = 0;
	all_crates = [];
	crates = getentarray( "flammable_crate", "targetname" );
	while ( isDefined( crates ) && crates.size > 0 )
	{
		qcrates = 1;
		i = 0;
		while ( i < crates.size )
		{
			all_crates[ all_crates.size ] = crates[ i ];
			i++;
		}
	}
	crates = getentarray( "flammable_crate", "script_noteworthy" );
	while ( isDefined( crates ) && crates.size > 0 )
	{
		qcrates = 1;
		i = 0;
		while ( i < crates.size )
		{
			all_crates[ all_crates.size ] = crates[ i ];
			i++;
		}
	}
	if ( qcrates )
	{
		precachemodel( "global_flammable_crate_jap_piece01_d" );
		level.crateburn = 100;
		level.cratehealth = 200;
		level.breakables_fx[ "ammo_crate" ][ "burn_start" ] = loadfx( "destructibles/fx_ammobox_ignite" );
		level.breakables_fx[ "ammo_crate" ][ "burn" ] = loadfx( "destructibles/fx_ammobox_fire_top" );
		level.breakables_fx[ "ammo_crate" ][ "explode" ] = loadfx( "destructibles/fx_ammoboxExp" );
		level.crateignsound = "Ignition_ammocrate";
		level.crateexpsound = "Explo_ammocrate";
		array_thread( all_crates, ::flammable_crate_think );
	}
	if ( !qbarrels && !qcrates )
	{
		return;
	}
}

explodable_barrel_think()
{
	if ( self.classname != "script_model" )
	{
		return;
	}
	self endon( "exploding" );
	self breakable_clip();
	self.health = level.barrelhealth;
	self setcandamage( 1 );
	self.targetname = "explodable_barrel";
	if ( sessionmodeiszombiesgame() )
	{
		self.removeexplodable = 1;
	}
	for ( ;; )
	{
		self waittill( "damage", amount, attacker, direction_vec, p, type );
/#
		println( "BARRELDAMAGE: " + type );
#/
		if ( type == "MOD_MELEE" || type == "MOD_IMPACT" )
		{
			continue;
		}
		else
		{
			if ( isDefined( self.script_requires_player ) && self.script_requires_player && !isplayer( attacker ) )
			{
				break;
			}
			else
			{
				if ( isDefined( self.script_selfisattacker ) && self.script_selfisattacker )
				{
					self.damageowner = self;
				}
				else
				{
					self.damageowner = attacker;
				}
				self.health -= amount;
				if ( self.health <= level.barrelburn )
				{
					self thread explodable_barrel_burn();
				}
			}
		}
	}
}

explodable_barrel_burn()
{
	count = 0;
	startedfx = 0;
	up = anglesToUp( vectorScale( ( 0, 0, 1 ), 90 ) );
	worldup = anglesToUp( vectorScale( ( 0, 0, 1 ), 90 ) );
	dot = vectordot( up, worldup );
	offset1 = ( 0, 0, 1 );
	offset2 = up * vectorScale( ( 0, 0, 1 ), 44 );
	if ( dot < 0,5 )
	{
		offset1 = ( up * vectorScale( ( 0, 0, 1 ), 22 ) ) - vectorScale( ( 0, 0, 1 ), 30 );
		offset2 = ( up * vectorScale( ( 0, 0, 1 ), 22 ) ) + vectorScale( ( 0, 0, 1 ), 14 );
	}
	while ( self.health > 0 )
	{
		if ( !startedfx )
		{
			playfx( level.breakables_fx[ "barrel" ][ "burn_start" ], self.origin + offset1 );
			level thread play_sound_in_space( level.barrelingsound, self.origin );
			startedfx = 1;
		}
		if ( count > 20 )
		{
			count = 0;
		}
		playfx( level.breakables_fx[ "barrel" ][ "burn" ], self.origin + offset2 );
		self playloopsound( "barrel_fuse" );
		if ( count == 0 )
		{
			self.health -= 10 + randomint( 10 );
		}
		count++;
		wait 0,05;
	}
	level notify( "explosion_started" );
	self thread explodable_barrel_explode();
}

explodable_barrel_explode()
{
	self notify( "exploding" );
	self death_notify_wrapper();
	up = anglesToUp( vectorScale( ( 0, 0, 1 ), 90 ) );
	worldup = anglesToUp( vectorScale( ( 0, 0, 1 ), 90 ) );
	dot = vectordot( up, worldup );
	offset = ( 0, 0, 1 );
	if ( dot < 0,5 )
	{
		start = self.origin + vectorScale( up, 22 );
		trace = physicstrace( start, start + vectorScale( ( 0, 0, 1 ), 64 ) );
		end = trace[ "position" ];
		offset = end - self.origin;
	}
	offset += vectorScale( ( 0, 0, 1 ), 4 );
	mindamage = 1;
	maxdamage = 250;
	blastradius = 250;
	level thread play_sound_in_space( level.barrelexpsound, self.origin );
	playfx( level.breakables_fx[ "barrel" ][ "explode" ], self.origin + offset );
	physicsexplosionsphere( self.origin + offset, 100, 80, 1, maxdamage, mindamage );
	level.barrelexplodingthisframe = 1;
	if ( isDefined( self.remove ) )
	{
		self.remove delete();
	}
	if ( isDefined( self.radius ) )
	{
		blastradius = self.radius;
	}
	self radiusdamage( self.origin + vectorScale( ( 0, 0, 1 ), 56 ), blastradius, maxdamage, mindamage, self.damageowner );
	attacker = undefined;
	if ( isDefined( self.damageowner ) )
	{
		attacker = self.damageowner;
	}
	level.lastexplodingbarrel[ "time" ] = getTime();
	level.lastexplodingbarrel[ "origin" ] = self.origin + vectorScale( ( 0, 0, 1 ), 30 );
	if ( isDefined( self.removeexplodable ) )
	{
		self hide();
	}
	else
	{
		self setmodel( "global_explosive_barrel" );
	}
	if ( dot < 0,5 )
	{
		start = self.origin + vectorScale( up, 22 );
		trace = physicstrace( start, start + vectorScale( ( 0, 0, 1 ), 64 ) );
		pos = trace[ "position" ];
		self.origin = pos;
		self.angles += vectorScale( ( 0, 0, 1 ), 90 );
	}
	wait 0,05;
	level.barrelexplodingthisframe = 0;
}

flammable_crate_think()
{
	if ( self.classname != "script_model" )
	{
		return;
	}
	self endon( "exploding" );
	self breakable_clip();
	self.health = level.cratehealth;
	self setcandamage( 1 );
	for ( ;; )
	{
		self waittill( "damage", amount, attacker, direction_vec, p, type );
		if ( isDefined( self.script_requires_player ) && self.script_requires_player && !isplayer( attacker ) )
		{
			continue;
		}
		else
		{
			if ( isDefined( self.script_selfisattacker ) && self.script_selfisattacker )
			{
				self.damageowner = self;
			}
			else
			{
				self.damageowner = attacker;
			}
			if ( level.barrelexplodingthisframe )
			{
				wait randomfloat( 1 );
			}
			self.health -= amount;
			if ( self.health <= level.crateburn )
			{
				self thread flammable_crate_burn();
			}
		}
	}
}

flammable_crate_burn()
{
	count = 0;
	startedfx = 0;
	up = anglesToUp( vectorScale( ( 0, 0, 1 ), 90 ) );
	worldup = anglesToUp( vectorScale( ( 0, 0, 1 ), 90 ) );
	dot = vectordot( up, worldup );
	offset1 = ( 0, 0, 1 );
	offset2 = up * vectorScale( ( 0, 0, 1 ), 44 );
	if ( dot < 0,5 )
	{
		offset1 = ( up * vectorScale( ( 0, 0, 1 ), 22 ) ) - vectorScale( ( 0, 0, 1 ), 30 );
		offset2 = ( up * vectorScale( ( 0, 0, 1 ), 22 ) ) + vectorScale( ( 0, 0, 1 ), 14 );
	}
	while ( self.health > 0 )
	{
		if ( !startedfx )
		{
			playfx( level.breakables_fx[ "ammo_crate" ][ "burn_start" ], self.origin );
			level thread play_sound_in_space( level.crateignsound, self.origin );
			startedfx = 1;
		}
		if ( count > 20 )
		{
			count = 0;
		}
		playfx( level.breakables_fx[ "ammo_crate" ][ "burn" ], self.origin );
		if ( count == 0 )
		{
			self.health -= 10 + randomint( 10 );
		}
		count++;
		wait 0,05;
	}
	self thread flammable_crate_explode();
}

flammable_crate_explode()
{
	self notify( "exploding" );
	self death_notify_wrapper();
	up = anglesToUp( vectorScale( ( 0, 0, 1 ), 90 ) );
	worldup = anglesToUp( vectorScale( ( 0, 0, 1 ), 90 ) );
	dot = vectordot( up, worldup );
	offset = ( 0, 0, 1 );
	if ( dot < 0,5 )
	{
		start = self.origin + vectorScale( up, 22 );
		trace = physicstrace( start, start + vectorScale( ( 0, 0, 1 ), 64 ) );
		end = trace[ "position" ];
		offset = end - self.origin;
	}
	offset += vectorScale( ( 0, 0, 1 ), 4 );
	mindamage = 1;
	maxdamage = 250;
	blastradius = 250;
	level thread play_sound_in_space( level.crateexpsound, self.origin );
	playfx( level.breakables_fx[ "ammo_crate" ][ "explode" ], self.origin );
	physicsexplosionsphere( self.origin + offset, 100, 80, 1, maxdamage, mindamage );
	level.barrelexplodingthisframe = 1;
	if ( isDefined( self.remove ) )
	{
		self.remove delete();
	}
	if ( isDefined( self.radius ) )
	{
		blastradius = self.radius;
	}
	attacker = undefined;
	if ( isDefined( self.damageowner ) )
	{
		attacker = self.damageowner;
	}
	self radiusdamage( self.origin + vectorScale( ( 0, 0, 1 ), 30 ), blastradius, maxdamage, mindamage, attacker );
	self setmodel( "global_flammable_crate_jap_piece01_d" );
	if ( dot < 0,5 )
	{
		start = self.origin + vectorScale( up, 22 );
		trace = physicstrace( start, start + vectorScale( ( 0, 0, 1 ), 64 ) );
		pos = trace[ "position" ];
		self.origin = pos;
		self.angles += vectorScale( ( 0, 0, 1 ), 90 );
	}
	wait 0,05;
	level.barrelexplodingthisframe = 0;
}

breakable_clip()
{
	if ( isDefined( self.target ) )
	{
		targ = getent( self.target, "targetname" );
		if ( targ.classname == "script_brushmodel" )
		{
			self.remove = targ;
			return;
		}
	}
	if ( isDefined( level.breakables_clip ) && level.breakables_clip.size > 0 )
	{
		self.remove = getclosestent( self.origin, level.breakables_clip );
	}
	if ( isDefined( self.remove ) )
	{
		arrayremovevalue( level.breakables_clip, self.remove );
	}
}

getclosestent( org, array )
{
	if ( array.size < 1 )
	{
		return;
	}
	dist = 256;
	ent = undefined;
	i = 0;
	while ( i < array.size )
	{
		newdist = distance( array[ i ] getorigin(), org );
		if ( newdist >= dist )
		{
			i++;
			continue;
		}
		else
		{
			dist = newdist;
			ent = array[ i ];
		}
		i++;
	}
	return ent;
}
