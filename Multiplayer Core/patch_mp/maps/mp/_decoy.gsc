#include maps/mp/_entityheadicons;
#include maps/mp/gametypes/_weaponobjects;
#include maps/mp/_utility;
#include common_scripts/utility;

init()
{
	level.decoyweapons = [];
	level.decoyweapons[ "fullauto" ] = [];
	level.decoyweapons[ "semiauto" ] = [];
	level.decoyweapons[ "fullauto" ][ level.decoyweapons[ "fullauto" ].size ] = "uzi_mp";
	level.decoyweapons[ "semiauto" ][ level.decoyweapons[ "semiauto" ].size ] = "m1911_mp";
	level.decoyweapons[ "semiauto" ][ level.decoyweapons[ "semiauto" ].size ] = "python_mp";
	level.decoyweapons[ "semiauto" ][ level.decoyweapons[ "semiauto" ].size ] = "cz75_mp";
	level.decoyweapons[ "semiauto" ][ level.decoyweapons[ "semiauto" ].size ] = "fnfal_mp";
}

createdecoywatcher()
{
	watcher = self maps/mp/gametypes/_weaponobjects::createuseweaponobjectwatcher( "nightingale", "nightingale_mp", self.team );
	watcher.onspawn = ::onspawndecoy;
	watcher.detonate = ::decoydetonate;
	watcher.deleteondifferentobjectspawn = 0;
	watcher.headicon = 0;
}

onspawndecoy( watcher, owner )
{
	owner endon( "disconnect" );
	self endon( "death" );
	maps/mp/gametypes/_weaponobjects::onspawnuseweaponobject( watcher, owner );
	self.initial_velocity = self getvelocity();
	delay = 1;
	wait delay;
	decoy_time = 30;
	spawn_time = getTime();
	owner addweaponstat( "nightingale_mp", "used", 1 );
	self thread simulateweaponfire( owner );
	while ( 1 )
	{
		if ( getTime() > ( spawn_time + ( decoy_time * 1000 ) ) )
		{
			self destroydecoy( watcher, owner );
			return;
		}
		wait 0,05;
	}
}

movedecoy( owner, count, fire_time, main_dir, max_offset_angle )
{
	self endon( "death" );
	self endon( "done" );
	if ( !self isonground() )
	{
		return;
	}
	min_speed = 100;
	max_speed = 200;
	min_up_speed = 100;
	max_up_speed = 200;
	current_main_dir = randomintrange( main_dir - max_offset_angle, main_dir + max_offset_angle );
	avel = ( randomfloatrange( 800, 1800 ) * ( ( randomintrange( 0, 2 ) * 2 ) - 1 ), 0, randomfloatrange( 580, 940 ) * ( ( randomintrange( 0, 2 ) * 2 ) - 1 ) );
	intial_up = randomfloatrange( min_up_speed, max_up_speed );
	start_time = getTime();
	gravity = getDvarInt( "bg_gravity" );
	i = 0;
	while ( i < 1 )
	{
		angles = ( 0, randomintrange( current_main_dir - max_offset_angle, current_main_dir + max_offset_angle ), 0 );
		dir = anglesToForward( angles );
		dir = vectorScale( dir, randomfloatrange( min_speed, max_speed ) );
		deltatime = ( getTime() - start_time ) * 0,001;
		up = ( 0, 0, intial_up - ( 800 * deltatime ) );
		self launch( dir + up, avel );
		wait fire_time;
		i++;
	}
}

destroydecoy( watcher, owner )
{
	self notify( "done" );
	self maps/mp/_entityheadicons::setentityheadicon( "none" );
}

decoydetonate( attacker )
{
	self notify( "done" );
	self maps/mp/_entityheadicons::setentityheadicon( "none" );
}

getweaponfordecoy( owner )
{
	weapon = pickrandomweapon();
	return weapon;
}

simulateweaponfire( owner )
{
	owner endon( "disconnect" );
	self endon( "death" );
	self endon( "done" );
	weapon = getweaponfordecoy( owner );
	if ( weapon == "none" )
	{
		return;
	}
	self thread watchforexplosion( owner, weapon );
	self thread trackmaindirection();
	self.max_offset_angle = 30;
	weapon_class = getweaponclass( weapon );
	switch( weapon_class )
	{
		case "weapon_assault":
		case "weapon_cqb":
		case "weapon_hmg":
		case "weapon_lmg":
		case "weapon_smg":
			simulateweaponfiremachinegun( owner, weapon );
			break;
		case "weapon_sniper":
			simulateweaponfiresniper( owner, weapon );
			break;
		case "weapon_pistol":
			simulateweaponfirepistol( owner, weapon );
			break;
		case "weapon_shotgun":
			simulateweaponfireshotgun( owner, weapon );
			break;
		default:
			simulateweaponfiremachinegun( owner, weapon );
			break;
	}
}

simulateweaponfiremachinegun( owner, weapon )
{
	if ( weaponissemiauto( weapon ) )
	{
		simulateweaponfiremachinegunsemiauto( owner, weapon );
	}
	else
	{
		simulateweaponfiremachinegunfullauto( owner, weapon );
	}
}

simulateweaponfiremachinegunsemiauto( owner, weapon )
{
	firetime = weaponfiretime( weapon );
	clipsize = weaponclipsize( weapon );
	reloadtime = weaponreloadtime( weapon );
	burst_spacing_min = 4;
	burst_spacing_max = 10;
	while ( 1 )
	{
		if ( clipsize <= 1 )
		{
			burst_count = 1;
		}
		else
		{
			burst_count = randomintrange( 1, clipsize );
		}
		self thread movedecoy( owner, burst_count, firetime, self.main_dir, self.max_offset_angle );
		self fireburst( owner, weapon, firetime, burst_count, 1 );
		finishwhileloop( weapon, reloadtime, burst_spacing_min, burst_spacing_max );
	}
}

simulateweaponfirepistol( owner, weapon )
{
	firetime = weaponfiretime( weapon );
	clipsize = weaponclipsize( weapon );
	reloadtime = weaponreloadtime( weapon );
	burst_spacing_min = 0,5;
	burst_spacing_max = 4;
	while ( 1 )
	{
		burst_count = randomintrange( 1, clipsize );
		self thread movedecoy( owner, burst_count, firetime, self.main_dir, self.max_offset_angle );
		self fireburst( owner, weapon, firetime, burst_count, 0 );
		finishwhileloop( weapon, reloadtime, burst_spacing_min, burst_spacing_max );
	}
}

simulateweaponfireshotgun( owner, weapon )
{
	firetime = weaponfiretime( weapon );
	clipsize = weaponclipsize( weapon );
	reloadtime = weaponreloadtime( weapon );
	if ( clipsize > 2 )
	{
		clipsize = 2;
	}
	burst_spacing_min = 0,5;
	burst_spacing_max = 4;
	while ( 1 )
	{
		burst_count = randomintrange( 1, clipsize );
		self thread movedecoy( owner, burst_count, firetime, self.main_dir, self.max_offset_angle );
		self fireburst( owner, weapon, firetime, burst_count, 0 );
		finishwhileloop( weapon, reloadtime, burst_spacing_min, burst_spacing_max );
	}
}

simulateweaponfiremachinegunfullauto( owner, weapon )
{
	firetime = weaponfiretime( weapon );
	clipsize = weaponclipsize( weapon );
	reloadtime = weaponreloadtime( weapon );
	if ( clipsize > 30 )
	{
		clipsize = 30;
	}
	burst_spacing_min = 2;
	burst_spacing_max = 6;
	while ( 1 )
	{
		burst_count = randomintrange( int( clipsize * 0,6 ), clipsize );
		interrupt = 0;
		self thread movedecoy( owner, burst_count, firetime, self.main_dir, self.max_offset_angle );
		self fireburst( owner, weapon, firetime, burst_count, interrupt );
		finishwhileloop( weapon, reloadtime, burst_spacing_min, burst_spacing_max );
	}
}

simulateweaponfiresniper( owner, weapon )
{
	firetime = weaponfiretime( weapon );
	clipsize = weaponclipsize( weapon );
	reloadtime = weaponreloadtime( weapon );
	if ( clipsize > 2 )
	{
		clipsize = 2;
	}
	burst_spacing_min = 3;
	burst_spacing_max = 5;
	while ( 1 )
	{
		burst_count = randomintrange( 1, clipsize );
		self thread movedecoy( owner, burst_count, firetime, self.main_dir, self.max_offset_angle );
		self fireburst( owner, weapon, firetime, burst_count, 0 );
		finishwhileloop( weapon, reloadtime, burst_spacing_min, burst_spacing_max );
	}
}

fireburst( owner, weapon, firetime, count, interrupt )
{
	interrupt_shot = count;
	if ( interrupt )
	{
		interrupt_shot = int( count * randomfloatrange( 0,6, 0,8 ) );
	}
	self fakefire( owner, self.origin, weapon, interrupt_shot );
	wait ( firetime * interrupt_shot );
	if ( interrupt )
	{
		self fakefire( owner, self.origin, weapon, count - interrupt_shot );
		wait ( firetime * ( count - interrupt_shot ) );
	}
}

finishwhileloop( weapon, reloadtime, burst_spacing_min, burst_spacing_max )
{
	if ( shouldplayreloadsound() )
	{
		playreloadsounds( weapon, reloadtime );
	}
	else
	{
		wait randomfloatrange( burst_spacing_min, burst_spacing_max );
	}
}

playreloadsounds( weapon, reloadtime )
{
	divy_it_up = ( reloadtime - 0,1 ) / 2;
	wait 0,1;
	self playsound( "fly_assault_reload_npc_mag_out" );
	wait divy_it_up;
	self playsound( "fly_assault_reload_npc_mag_in" );
	wait divy_it_up;
}

watchforexplosion( owner, weapon )
{
	self thread watchfordeathbeforeexplosion();
	owner endon( "disconnect" );
	self endon( "death_before_explode" );
	self waittill( "explode", pos );
	level thread doexplosion( owner, pos, weapon, randomintrange( 5, 10 ) );
}

watchfordeathbeforeexplosion()
{
	self waittill( "death" );
	wait 0,1;
	self notify( "death_before_explode" );
}

doexplosion( owner, pos, weapon, count )
{
	min_offset = 100;
	max_offset = 500;
	i = 0;
	while ( i < count )
	{
		wait randomfloatrange( 0,1, 0,5 );
		offset = ( randomfloatrange( min_offset, max_offset ) * ( ( randomintrange( 0, 2 ) * 2 ) - 1 ), randomfloatrange( min_offset, max_offset ) * ( ( randomintrange( 0, 2 ) * 2 ) - 1 ), 0 );
		owner fakefire( owner, pos + offset, weapon, 1 );
		i++;
	}
}

pickrandomweapon()
{
	type = "fullauto";
	if ( randomintrange( 0, 10 ) < 3 )
	{
		type = "semiauto";
	}
	randomval = randomintrange( 0, level.decoyweapons[ type ].size );
/#
	println( "Decoy type: " + type + " weapon: " + level.decoyweapons[ type ][ randomval ] );
#/
	return level.decoyweapons[ type ][ randomval ];
}

shouldplayreloadsound()
{
	if ( randomintrange( 0, 5 ) == 1 )
	{
		return 1;
	}
	return 0;
}

trackmaindirection()
{
	self endon( "death" );
	self endon( "done" );
	self.main_dir = int( vectorToAngle( ( self.initial_velocity[ 0 ], self.initial_velocity[ 1 ], 0 ) )[ 1 ] );
	up = ( 0, 0, 1 );
	while ( 1 )
	{
		self waittill( "grenade_bounce", pos, normal );
		dot = vectordot( normal, up );
		if ( dot < 0,5 && dot > -0,5 )
		{
			self.main_dir = int( vectorToAngle( ( normal[ 0 ], normal[ 1 ], 0 ) )[ 1 ] );
		}
	}
}
