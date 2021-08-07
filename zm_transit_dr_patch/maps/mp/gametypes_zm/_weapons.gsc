#include maps/mp/gametypes_zm/_gameobjects;
#include maps/mp/gametypes_zm/_shellshock;
#include maps/mp/gametypes_zm/_globallogic_utils;
#include maps/mp/_challenges;
#include maps/mp/gametypes_zm/_weapons;
#include maps/mp/_bb;
#include maps/mp/gametypes_zm/_weapon_utils;
#include maps/mp/_utility;
#include common_scripts/utility;

init()
{
	precacheitem( "knife_mp" );
	precacheitem( "knife_held_mp" );
	precacheitem( "dogs_mp" );
	precacheitem( "dog_bite_mp" );
	precacheitem( "explosive_bolt_mp" );
	precachemodel( "t6_wpn_claymore_world_detect" );
	precachemodel( "t6_wpn_c4_world_detect" );
	precachemodel( "t5_weapon_scrambler_world_detect" );
	precachemodel( "t6_wpn_tac_insert_detect" );
	precachemodel( "t6_wpn_taser_mine_world_detect" );
	precachemodel( "t6_wpn_motion_sensor_world_detect" );
	precachemodel( "t6_wpn_trophy_system_world_detect" );
	precachemodel( "t6_wpn_bouncing_betty_world_detect" );
	precachemodel( "t6_wpn_shield_stow_world" );
	precachemodel( "t6_wpn_shield_carry_world" );
	precachemodel( "t5_weapon_camera_head_world" );
	precacheitem( "scavenger_item_mp" );
	precacheitem( "scavenger_item_hack_mp" );
	precacheshader( "hud_scavenger_pickup" );
	precacheshellshock( "default" );
	precacheshellshock( "concussion_grenade_mp" );
	precacheshellshock( "tabun_gas_mp" );
	precacheshellshock( "tabun_gas_nokick_mp" );
	precacheshellshock( "proximity_grenade" );
	precacheshellshock( "proximity_grenade_exit" );
	level.missileentities = [];
	level.hackertooltargets = [];
	if ( !isDefined( level.grenadelauncherdudtime ) )
	{
		level.grenadelauncherdudtime = 0;
	}
	if ( !isDefined( level.throwngrenadedudtime ) )
	{
		level.throwngrenadedudtime = 0;
	}
	level thread onplayerconnect();
	maps/mp/gametypes_zm/_weaponobjects::init();
	maps/mp/_sticky_grenade::init();
}

onplayerconnect()
{
	for ( ;; )
	{
		level waittill( "connecting", player );
		player.usedweapons = 0;
		player.lastfiretime = 0;
		player.hits = 0;
		player scavenger_hud_create();
		player thread onplayerspawned();
	}
}

onplayerspawned()
{
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "spawned_player" );
		self.concussionendtime = 0;
		self.hasdonecombat = 0;
		self.shielddamageblocked = 0;
		self thread watchweaponusage();
		self thread watchgrenadeusage();
		self thread watchmissileusage();
		self thread watchweaponchange();
		self thread watchturretuse();
		self thread watchriotshielduse();
		self thread trackweapon();
		self.droppeddeathweapon = undefined;
		self.tookweaponfrom = [];
		self.pickedupweaponkills = [];
		self thread updatestowedweapon();
	}
}

watchturretuse()
{
	self endon( "death" );
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "turretownerchange", turret );
		self thread watchfortowfire( turret );
	}
}

watchfortowfire( turret )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "turretownerchange" );
	while ( 1 )
	{
		self waittill( "turret_tow_fire" );
		self thread watchmissleunlink( turret );
		self waittill( "turret_tow_unlink" );
	}
}

watchmissleunlink( turret )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "turretownerchange" );
	self waittill( "turret_tow_unlink" );
	self relinktoturret( turret );
}

watchweaponchange()
{
	self endon( "death" );
	self endon( "disconnect" );
	self.lastdroppableweapon = self getcurrentweapon();
	self.hitsthismag = [];
	weapon = self getcurrentweapon();
	if ( isprimaryweapon( weapon ) && !isDefined( self.hitsthismag[ weapon ] ) )
	{
		self.hitsthismag[ weapon ] = weaponclipsize( weapon );
	}
	while ( 1 )
	{
		previous_weapon = self getcurrentweapon();
		self waittill( "weapon_change", newweapon );
		if ( maydropweapon( newweapon ) )
		{
			self.lastdroppableweapon = newweapon;
		}
		if ( newweapon != "none" )
		{
			if ( !isprimaryweapon( newweapon ) && issidearm( newweapon ) && !isDefined( self.hitsthismag[ newweapon ] ) )
			{
				self.hitsthismag[ newweapon ] = weaponclipsize( newweapon );
			}
		}
	}
}

watchriotshielduse()
{
}

updatelastheldweapontimings( newtime )
{
	if ( isDefined( self.currentweapon ) && isDefined( self.currentweaponstarttime ) )
	{
		totaltime = int( ( newtime - self.currentweaponstarttime ) / 1000 );
		if ( totaltime > 0 )
		{
			self addweaponstat( self.currentweapon, "timeUsed", totaltime );
			self.currentweaponstarttime = newtime;
		}
	}
}

updateweapontimings( newtime )
{
	if ( self is_bot() )
	{
		return;
	}
	updatelastheldweapontimings( newtime );
	if ( !isDefined( self.staticweaponsstarttime ) )
	{
		return;
	}
	totaltime = int( ( newtime - self.staticweaponsstarttime ) / 1000 );
	if ( totaltime < 0 )
	{
		return;
	}
	self.staticweaponsstarttime = newtime;
	while ( isDefined( self.weapon_array_grenade ) )
	{
		i = 0;
		while ( i < self.weapon_array_grenade.size )
		{
			self addweaponstat( self.weapon_array_grenade[ i ], "timeUsed", totaltime );
			i++;
		}
	}
	while ( isDefined( self.weapon_array_inventory ) )
	{
		i = 0;
		while ( i < self.weapon_array_inventory.size )
		{
			self addweaponstat( self.weapon_array_inventory[ i ], "timeUsed", totaltime );
			i++;
		}
	}
	while ( isDefined( self.killstreak ) )
	{
		i = 0;
		while ( i < self.killstreak.size )
		{
			killstreakweapon = level.menureferenceforkillstreak[ self.killstreak[ i ] ];
			if ( isDefined( killstreakweapon ) )
			{
				self addweaponstat( killstreakweapon, "timeUsed", totaltime );
			}
			i++;
		}
	}
	while ( level.rankedmatch && level.perksenabled )
	{
		perksindexarray = [];
		specialtys = self.specialty;
		if ( !isDefined( specialtys ) )
		{
			return;
		}
		if ( !isDefined( self.class ) )
		{
			return;
		}
		while ( isDefined( self.class_num ) )
		{
			numspecialties = 0;
			while ( numspecialties < level.maxspecialties )
			{
				perk = self getloadoutitem( self.class_num, "specialty" + ( numspecialties + 1 ) );
				if ( perk != 0 )
				{
					perksindexarray[ perk ] = 1;
				}
				numspecialties++;
			}
			perkindexarraykeys = getarraykeys( perksindexarray );
			i = 0;
			while ( i < perkindexarraykeys.size )
			{
				if ( perksindexarray[ perkindexarraykeys[ i ] ] == 1 )
				{
					self adddstat( "itemStats", perkindexarraykeys[ i ], "stats", "timeUsed", "statValue", totaltime );
				}
				i++;
			}
		}
	}
}

trackweapon()
{
	currentweapon = self getcurrentweapon();
	currenttime = getTime();
	spawnid = getplayerspawnid( self );
	while ( 1 )
	{
		event = self waittill_any_return( "weapon_change", "death", "disconnect" );
		newtime = getTime();
		if ( event == "weapon_change" )
		{
			self maps/mp/_bb::commitweapondata( spawnid, currentweapon, currenttime );
			newweapon = self getcurrentweapon();
			if ( newweapon != "none" && newweapon != currentweapon )
			{
				updatelastheldweapontimings( newtime );
				currentweapon = newweapon;
				currenttime = newtime;
			}
			continue;
		}
		else
		{
			if ( event != "disconnect" )
			{
				self maps/mp/_bb::commitweapondata( spawnid, currentweapon, currenttime );
				updateweapontimings( newtime );
			}
			return;
		}
	}
}

maydropweapon( weapon )
{
	if ( level.disableweapondrop == 1 )
	{
		return 0;
	}
	if ( weapon == "none" )
	{
		return 0;
	}
	if ( ishackweapon( weapon ) )
	{
		return 0;
	}
	invtype = weaponinventorytype( weapon );
	if ( invtype != "primary" )
	{
		return 0;
	}
	if ( weapon == "none" )
	{
		return 0;
	}
	return 1;
}

dropweaponfordeath( attacker )
{
	if ( level.disableweapondrop == 1 )
	{
		return;
	}
	weapon = self.lastdroppableweapon;
	if ( isDefined( self.droppeddeathweapon ) )
	{
		return;
	}
	if ( !isDefined( weapon ) )
	{
/#
		if ( getDvar( #"08F7FC88" ) == "1" )
		{
			println( "didn't drop weapon: not defined" );
#/
		}
		return;
	}
	if ( weapon == "none" )
	{
/#
		if ( getDvar( #"08F7FC88" ) == "1" )
		{
			println( "didn't drop weapon: weapon == none" );
#/
		}
		return;
	}
	if ( !self hasweapon( weapon ) )
	{
/#
		if ( getDvar( #"08F7FC88" ) == "1" )
		{
			println( "didn't drop weapon: don't have it anymore (" + weapon + ")" );
#/
		}
		return;
	}
	if ( !self anyammoforweaponmodes( weapon ) )
	{
/#
		if ( getDvar( #"08F7FC88" ) == "1" )
		{
			println( "didn't drop weapon: no ammo for weapon modes" );
#/
		}
		return;
	}
	if ( !shoulddroplimitedweapon( weapon, self ) )
	{
		return;
	}
	clipammo = self getweaponammoclip( weapon );
	stockammo = self getweaponammostock( weapon );
	clip_and_stock_ammo = clipammo + stockammo;
	if ( !clip_and_stock_ammo )
	{
/#
		if ( getDvar( #"08F7FC88" ) == "1" )
		{
			println( "didn't drop weapon: no ammo" );
#/
		}
		return;
	}
	stockmax = weaponmaxammo( weapon );
	if ( stockammo > stockmax )
	{
		stockammo = stockmax;
	}
	item = self dropitem( weapon );
	if ( !isDefined( item ) )
	{
/#
		iprintlnbold( "dropItem: was not able to drop weapon " + weapon );
#/
		return;
	}
/#
	if ( getDvar( #"08F7FC88" ) == "1" )
	{
		println( "dropped weapon: " + weapon );
#/
	}
	droplimitedweapon( weapon, self, item );
	self.droppeddeathweapon = 1;
	item itemweaponsetammo( clipammo, stockammo );
	item.owner = self;
	item.ownersattacker = attacker;
	item thread watchpickup();
	item thread deletepickupafterawhile();
}

dropweapontoground( weapon )
{
	if ( !isDefined( weapon ) )
	{
/#
		if ( getDvar( #"08F7FC88" ) == "1" )
		{
			println( "didn't drop weapon: not defined" );
#/
		}
		return;
	}
	if ( weapon == "none" )
	{
/#
		if ( getDvar( #"08F7FC88" ) == "1" )
		{
			println( "didn't drop weapon: weapon == none" );
#/
		}
		return;
	}
	if ( !self hasweapon( weapon ) )
	{
/#
		if ( getDvar( #"08F7FC88" ) == "1" )
		{
			println( "didn't drop weapon: don't have it anymore (" + weapon + ")" );
#/
		}
		return;
	}
	if ( !self anyammoforweaponmodes( weapon ) )
	{
/#
		if ( getDvar( #"08F7FC88" ) == "1" )
		{
			println( "didn't drop weapon: no ammo for weapon modes" );
#/
		}
		switch( weapon )
		{
			case "m202_flash_mp":
			case "m220_tow_mp":
			case "m32_mp":
			case "minigun_mp":
			case "mp40_blinged_mp":
				self takeweapon( weapon );
				break;
			default:
			}
			return;
		}
		if ( !shoulddroplimitedweapon( weapon, self ) )
		{
			return;
		}
		clipammo = self getweaponammoclip( weapon );
		stockammo = self getweaponammostock( weapon );
		clip_and_stock_ammo = clipammo + stockammo;
		if ( !clip_and_stock_ammo )
		{
/#
			if ( getDvar( #"08F7FC88" ) == "1" )
			{
				println( "didn't drop weapon: no ammo" );
#/
			}
			return;
		}
		stockmax = weaponmaxammo( weapon );
		if ( stockammo > stockmax )
		{
			stockammo = stockmax;
		}
		item = self dropitem( weapon );
/#
		if ( getDvar( #"08F7FC88" ) == "1" )
		{
			println( "dropped weapon: " + weapon );
#/
		}
		droplimitedweapon( weapon, self, item );
		item itemweaponsetammo( clipammo, stockammo );
		item.owner = self;
		item thread watchpickup();
		item thread deletepickupafterawhile();
	}
}

deletepickupafterawhile()
{
	self endon( "death" );
	wait 60;
	if ( !isDefined( self ) )
	{
		return;
	}
	self delete();
}

getitemweaponname()
{
	classname = self.classname;
/#
	assert( getsubstr( classname, 0, 7 ) == "weapon_" );
#/
	weapname = getsubstr( classname, 7 );
	return weapname;
}

watchpickup()
{
	self endon( "death" );
	weapname = self getitemweaponname();
	while ( 1 )
	{
		self waittill( "trigger", player, droppeditem );
		if ( isDefined( droppeditem ) )
		{
			break;
		}
		else
		{
		}
	}
/#
	if ( getDvar( #"08F7FC88" ) == "1" )
	{
		println( "picked up weapon: " + weapname + ", " + isDefined( self.ownersattacker ) );
#/
	}
/#
	assert( isDefined( player.tookweaponfrom ) );
#/
/#
	assert( isDefined( player.pickedupweaponkills ) );
#/
	droppedweaponname = droppeditem getitemweaponname();
	if ( isDefined( player.tookweaponfrom[ droppedweaponname ] ) )
	{
		droppeditem.owner = player.tookweaponfrom[ droppedweaponname ];
		droppeditem.ownersattacker = player;
	}
	droppeditem thread watchpickup();
	if ( isDefined( self.ownersattacker ) && self.ownersattacker == player )
	{
		player.tookweaponfrom[ weapname ] = self.owner;
		player.pickedupweaponkills[ weapname ] = 0;
	}
	else }

itemremoveammofromaltmodes()
{
	origweapname = self getitemweaponname();
	curweapname = weaponaltweaponname( origweapname );
	altindex = 1;
	while ( curweapname != "none" && curweapname != origweapname )
	{
		self itemweaponsetammo( 0, 0, altindex );
		curweapname = weaponaltweaponname( curweapname );
		altindex++;
	}
}

dropoffhand()
{
	grenadetypes = [];
	index = 0;
	while ( index < grenadetypes.size )
	{
		if ( !self hasweapon( grenadetypes[ index ] ) )
		{
			index++;
			continue;
		}
		else count = self getammocount( grenadetypes[ index ] );
		if ( !count )
		{
			index++;
			continue;
		}
		else
		{
			self dropitem( grenadetypes[ index ] );
		}
		index++;
	}
}

watchweaponusage()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	self.usedkillstreakweapon = [];
	self.usedkillstreakweapon[ "minigun_mp" ] = 0;
	self.usedkillstreakweapon[ "m32_mp" ] = 0;
	self.usedkillstreakweapon[ "m202_flash_mp" ] = 0;
	self.usedkillstreakweapon[ "m220_tow_mp" ] = 0;
	self.usedkillstreakweapon[ "mp40_blinged_mp" ] = 0;
	self.killstreaktype = [];
	self.killstreaktype[ "minigun_mp" ] = "minigun_mp";
	self.killstreaktype[ "m32_mp" ] = "m32_mp";
	self.killstreaktype[ "m202_flash_mp" ] = "m202_flash_mp";
	self.killstreaktype[ "m220_tow_mp" ] = "m220_tow_mp";
	self.killstreaktype[ "mp40_blinged_mp" ] = "mp40_blinged_drop_mp";
	for ( ;; )
	{
		self waittill( "weapon_fired", curweapon );
		self.lastfiretime = getTime();
		self.hasdonecombat = 1;
		if ( maps/mp/gametypes_zm/_weapons::isprimaryweapon( curweapon ) || maps/mp/gametypes_zm/_weapons::issidearm( curweapon ) )
		{
			if ( isDefined( self.hitsthismag[ curweapon ] ) )
			{
				self thread updatemagshots( curweapon );
			}
		}
		switch( weaponclass( curweapon ) )
		{
			case "rifle":
				if ( curweapon == "crossbow_explosive_mp" )
				{
					level.globalcrossbowfired++;
					self addweaponstat( curweapon, "shots", 1 );
					self thread begingrenadetracking();
					break;
				continue;
			}
			else case "mg":
			case "pistol":
			case "smg":
			case "spread":
				self trackweaponfire( curweapon );
				level.globalshotsfired++;
				break;
			continue;
			case "grenade":
			case "rocketlauncher":
				self addweaponstat( curweapon, "shots", 1 );
				break;
			continue;
			default:
			}
		}
	}
}

updatemagshots( weaponname )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "updateMagShots_" + weaponname );
	self.hitsthismag[ weaponname ]--;

	wait 0,05;
	self.hitsthismag[ weaponname ] = weaponclipsize( weaponname );
}

checkhitsthismag( weaponname )
{
	self endon( "death" );
	self endon( "disconnect" );
	self notify( "updateMagShots_" + weaponname );
	waittillframeend;
	if ( isDefined( self.hitsthismag[ weaponname ] ) && self.hitsthismag[ weaponname ] == 0 )
	{
		if ( !sessionmodeiszombiesgame() )
		{
			weaponclass = getweaponclass( weaponname );
			maps/mp/_challenges::fullclipnomisses( weaponclass, weaponname );
		}
		self.hitsthismag[ weaponname ] = weaponclipsize( weaponname );
	}
}

trackweaponfire( curweapon )
{
	shotsfired = 1;
	if ( isDefined( self.laststandparams ) && self.laststandparams.laststandstarttime == getTime() )
	{
		self.hits = 0;
		return;
	}
	pixbeginevent( "trackWeaponFire" );
	self addweaponstat( curweapon, "shots", shotsfired );
	self addweaponstat( curweapon, "hits", self.hits );
	if ( isDefined( level.add_client_stat ) )
	{
		self [[ level.add_client_stat ]]( "total_shots", shotsfired );
		self [[ level.add_client_stat ]]( "hits", self.hits );
	}
	else
	{
		self addplayerstat( "total_shots", shotsfired );
		self addplayerstat( "hits", self.hits );
		self addplayerstat( "misses", int( max( 0, shotsfired - self.hits ) ) );
	}
	self incrementplayerstat( "total_shots", shotsfired );
	self incrementplayerstat( "hits", self.hits );
	self incrementplayerstat( "misses", int( max( 0, shotsfired - self.hits ) ) );
	self maps/mp/_bb::bbaddtostat( "shots", shotsfired );
	self maps/mp/_bb::bbaddtostat( "hits", self.hits );
	self.hits = 0;
	pixendevent();
}

checkhit( sweapon )
{
	switch( weaponclass( sweapon ) )
	{
		case "mg":
		case "pistol":
		case "rifle":
		case "smg":
			self.hits++;
			break;
		case "pistol spread":
		case "spread":
			self.hits = 1;
			break;
		default:
		}
		waittillframeend;
		if ( isDefined( self.hitsthismag ) && isDefined( self.hitsthismag[ sweapon ] ) )
		{
			self thread checkhitsthismag( sweapon );
		}
		if ( sweapon != "bazooka_mp" || isstrstart( sweapon, "t34" ) && isstrstart( sweapon, "panzer" ) )
		{
			self addweaponstat( sweapon, "hits", 1 );
		}
	}
}

watchgrenadeusage()
{
	self endon( "death" );
	self endon( "disconnect" );
	self.throwinggrenade = 0;
	self.gotpullbacknotify = 0;
	self thread beginothergrenadetracking();
	self thread watchforthrowbacks();
	self thread watchforgrenadeduds();
	self thread watchforgrenadelauncherduds();
	for ( ;; )
	{
		self waittill( "grenade_pullback", weaponname );
		self addweaponstat( weaponname, "shots", 1 );
		self.hasdonecombat = 1;
		self.throwinggrenade = 1;
		self.gotpullbacknotify = 1;
		if ( weaponname == "satchel_charge_mp" )
		{
			self thread beginsatcheltracking();
		}
		self thread begingrenadetracking();
	}
}

watchmissileusage()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	for ( ;; )
	{
		self waittill( "missile_fire", missile, weapon_name );
		self.hasdonecombat = 1;
/#
		assert( isDefined( missile ) );
#/
		level.missileentities[ level.missileentities.size ] = missile;
		missile thread watchmissiledeath();
	}
}

watchmissiledeath()
{
	self waittill( "death" );
	arrayremovevalue( level.missileentities, self );
}

dropweaponstoground( origin, radius )
{
	weapons = getdroppedweapons();
	i = 0;
	while ( i < weapons.size )
	{
		if ( distancesquared( origin, weapons[ i ].origin ) < ( radius * radius ) )
		{
			trace = bullettrace( weapons[ i ].origin, weapons[ i ].origin + vectorScale( ( 0, 0, 1 ), 2000 ), 0, weapons[ i ] );
			weapons[ i ].origin = trace[ "position" ];
		}
		i++;
	}
}

dropgrenadestoground( origin, radius )
{
	grenades = getentarray( "grenade", "classname" );
	i = 0;
	while ( i < grenades.size )
	{
		if ( distancesquared( origin, grenades[ i ].origin ) < ( radius * radius ) )
		{
			grenades[ i ] launch( vectorScale( ( 0, 0, 1 ), 5 ) );
		}
		i++;
	}
}

watchgrenadecancel()
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "grenade_fire" );
	self waittill( "weapon_change" );
	self.throwinggrenade = 0;
	self.gotpullbacknotify = 0;
}

begingrenadetracking()
{
	self endon( "death" );
	self endon( "disconnect" );
	starttime = getTime();
	self thread watchgrenadecancel();
	self waittill( "grenade_fire", grenade, weaponname );
/#
	assert( isDefined( grenade ) );
#/
	level.missileentities[ level.missileentities.size ] = grenade;
	grenade thread watchmissiledeath();
	if ( grenade maps/mp/gametypes_zm/_weaponobjects::ishacked() )
	{
		return;
	}
	bbprint( "mpequipmentuses", "gametime %d spawnid %d weaponname %s", getTime(), getplayerspawnid( self ), weaponname );
	if ( ( getTime() - starttime ) > 1000 )
	{
		grenade.iscooked = 1;
	}
	switch( weaponname )
	{
		case "frag_grenade_zm":
		case "sticky_grenade_zm":
			self addweaponstat( weaponname, "used", 1 );
			case "explosive_bolt_zm":
				grenade.originalowner = self;
				break;
		}
		if ( weaponname == "sticky_grenade_zm" || weaponname == "frag_grenade_zm" )
		{
			grenade setteam( self.pers[ "team" ] );
			grenade setowner( self );
		}
		self.throwinggrenade = 0;
	}
}

beginothergrenadetracking()
{
}

checkstucktoplayer( deleteonteamchange, awardscoreevent, weaponname )
{
	self endon( "death" );
	self waittill( "stuck_to_player", player );
	if ( isDefined( player ) )
	{
		if ( deleteonteamchange )
		{
			self thread stucktoplayerteamchange( player );
		}
		if ( awardscoreevent && isDefined( self.originalowner ) )
		{
			if ( self.originalowner isenemyplayer( player ) )
			{
			}
		}
		self.stucktoplayer = player;
	}
}

checkhatchetbounce()
{
	self endon( "stuck_to_player" );
	self endon( "death" );
	self waittill( "grenade_bounce" );
	self.bounced = 1;
}

stucktoplayerteamchange( player )
{
	self endon( "death" );
	player endon( "disconnect" );
	originalteam = player.pers[ "team" ];
	while ( 1 )
	{
		player waittill( "joined_team" );
		if ( player.pers[ "team" ] != originalteam )
		{
			self detonate();
			return;
		}
	}
}

beginsatcheltracking()
{
	self endon( "death" );
	self endon( "disconnect" );
	self waittill_any( "grenade_fire", "weapon_change" );
	self.throwinggrenade = 0;
}

watchforthrowbacks()
{
	self endon( "death" );
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "grenade_fire", grenade, weapname );
		if ( self.gotpullbacknotify )
		{
			self.gotpullbacknotify = 0;
			continue;
		}
		else if ( !issubstr( weapname, "frag_" ) )
		{
			continue;
		}
		else
		{
			grenade.threwback = 1;
			grenade.originalowner = self;
		}
	}
}

registergrenadelauncherduddvar( dvarstring, defaultvalue, minvalue, maxvalue )
{
	dvarstring = "scr_" + dvarstring + "_grenadeLauncherDudTime";
	if ( getDvar( dvarstring ) == "" )
	{
		setdvar( dvarstring, defaultvalue );
	}
	if ( getDvarInt( dvarstring ) > maxvalue )
	{
		setdvar( dvarstring, maxvalue );
	}
	else
	{
		if ( getDvarInt( dvarstring ) < minvalue )
		{
			setdvar( dvarstring, minvalue );
		}
	}
	level.grenadelauncherdudtimedvar = dvarstring;
	level.grenadelauncherdudtimemin = minvalue;
	level.grenadelauncherdudtimemax = maxvalue;
	level.grenadelauncherdudtime = getDvarInt( level.grenadelauncherdudtimedvar );
}

registerthrowngrenadeduddvar( dvarstring, defaultvalue, minvalue, maxvalue )
{
	dvarstring = "scr_" + dvarstring + "_thrownGrenadeDudTime";
	if ( getDvar( dvarstring ) == "" )
	{
		setdvar( dvarstring, defaultvalue );
	}
	if ( getDvarInt( dvarstring ) > maxvalue )
	{
		setdvar( dvarstring, maxvalue );
	}
	else
	{
		if ( getDvarInt( dvarstring ) < minvalue )
		{
			setdvar( dvarstring, minvalue );
		}
	}
	level.throwngrenadedudtimedvar = dvarstring;
	level.throwngrenadedudtimemin = minvalue;
	level.throwngrenadedudtimemax = maxvalue;
	level.throwngrenadedudtime = getDvarInt( level.throwngrenadedudtimedvar );
}

registerkillstreakdelay( dvarstring, defaultvalue, minvalue, maxvalue )
{
	dvarstring = "scr_" + dvarstring + "_killstreakDelayTime";
	if ( getDvar( dvarstring ) == "" )
	{
		setdvar( dvarstring, defaultvalue );
	}
	if ( getDvarInt( dvarstring ) > maxvalue )
	{
		setdvar( dvarstring, maxvalue );
	}
	else
	{
		if ( getDvarInt( dvarstring ) < minvalue )
		{
			setdvar( dvarstring, minvalue );
		}
	}
	level.killstreakrounddelay = getDvarInt( dvarstring );
}

turngrenadeintoadud( weapname, isthrowngrenade, player )
{
	if ( level.grenadelauncherdudtime >= ( maps/mp/gametypes_zm/_globallogic_utils::gettimepassed() / 1000 ) && !isthrowngrenade )
	{
		if ( issubstr( weapname, "gl_" ) || weapname == "china_lake_mp" )
		{
			timeleft = int( level.grenadelauncherdudtime - ( maps/mp/gametypes_zm/_globallogic_utils::gettimepassed() / 1000 ) );
			if ( !timeleft )
			{
				timeleft = 1;
			}
			player iprintlnbold( &"MP_LAUNCHER_UNAVAILABLE_FOR_N", " " + timeleft + " ", &"EXE_SECONDS" );
			self makegrenadedud();
		}
	}
	else
	{
		if ( level.throwngrenadedudtime >= ( maps/mp/gametypes_zm/_globallogic_utils::gettimepassed() / 1000 ) && isthrowngrenade )
		{
			if ( weapname == "frag_grenade_mp" || weapname == "sticky_grenade_mp" )
			{
				if ( isDefined( player.suicide ) && player.suicide )
				{
					return;
				}
				timeleft = int( level.throwngrenadedudtime - ( maps/mp/gametypes_zm/_globallogic_utils::gettimepassed() / 1000 ) );
				if ( !timeleft )
				{
					timeleft = 1;
				}
				player iprintlnbold( &"MP_GRENADE_UNAVAILABLE_FOR_N", " " + timeleft + " ", &"EXE_SECONDS" );
				self makegrenadedud();
			}
		}
	}
}

watchforgrenadeduds()
{
	self endon( "spawned_player" );
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "grenade_fire", grenade, weapname );
		grenade turngrenadeintoadud( weapname, 1, self );
	}
}

watchforgrenadelauncherduds()
{
	self endon( "spawned_player" );
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "grenade_launcher_fire", grenade, weapname );
		grenade turngrenadeintoadud( weapname, 0, self );
	}
}

getdamageableents( pos, radius, dolos, startradius )
{
	ents = [];
	if ( !isDefined( dolos ) )
	{
		dolos = 0;
	}
	if ( !isDefined( startradius ) )
	{
		startradius = 0;
	}
	players = level.players;
	i = 0;
	while ( i < players.size )
	{
		if ( !isalive( players[ i ] ) || players[ i ].sessionstate != "playing" )
		{
			i++;
			continue;
		}
		else
		{
			playerpos = players[ i ].origin + vectorScale( ( 0, 0, 1 ), 32 );
			distsq = distancesquared( pos, playerpos );
			if ( distsq < ( radius * radius ) || !dolos && weapondamagetracepassed( pos, playerpos, startradius, undefined ) )
			{
				newent = spawnstruct();
				newent.isplayer = 1;
				newent.isadestructable = 0;
				newent.isadestructible = 0;
				newent.isactor = 0;
				newent.entity = players[ i ];
				newent.damagecenter = playerpos;
				ents[ ents.size ] = newent;
			}
		}
		i++;
	}
	grenades = getentarray( "grenade", "classname" );
	i = 0;
	while ( i < grenades.size )
	{
		entpos = grenades[ i ].origin;
		distsq = distancesquared( pos, entpos );
		if ( distsq < ( radius * radius ) || !dolos && weapondamagetracepassed( pos, entpos, startradius, grenades[ i ] ) )
		{
			newent = spawnstruct();
			newent.isplayer = 0;
			newent.isadestructable = 0;
			newent.isadestructible = 0;
			newent.isactor = 0;
			newent.entity = grenades[ i ];
			newent.damagecenter = entpos;
			ents[ ents.size ] = newent;
		}
		i++;
	}
	destructibles = getentarray( "destructible", "targetname" );
	i = 0;
	while ( i < destructibles.size )
	{
		entpos = destructibles[ i ].origin;
		distsq = distancesquared( pos, entpos );
		if ( distsq < ( radius * radius ) || !dolos && weapondamagetracepassed( pos, entpos, startradius, destructibles[ i ] ) )
		{
			newent = spawnstruct();
			newent.isplayer = 0;
			newent.isadestructable = 0;
			newent.isadestructible = 1;
			newent.isactor = 0;
			newent.entity = destructibles[ i ];
			newent.damagecenter = entpos;
			ents[ ents.size ] = newent;
		}
		i++;
	}
	destructables = getentarray( "destructable", "targetname" );
	i = 0;
	while ( i < destructables.size )
	{
		entpos = destructables[ i ].origin;
		distsq = distancesquared( pos, entpos );
		if ( distsq < ( radius * radius ) || !dolos && weapondamagetracepassed( pos, entpos, startradius, destructables[ i ] ) )
		{
			newent = spawnstruct();
			newent.isplayer = 0;
			newent.isadestructable = 1;
			newent.isadestructible = 0;
			newent.isactor = 0;
			newent.entity = destructables[ i ];
			newent.damagecenter = entpos;
			ents[ ents.size ] = newent;
		}
		i++;
	}
	return ents;
}

weapondamagetracepassed( from, to, startradius, ignore )
{
	trace = weapondamagetrace( from, to, startradius, ignore );
	return trace[ "fraction" ] == 1;
}

weapondamagetrace( from, to, startradius, ignore )
{
	midpos = undefined;
	diff = to - from;
	if ( lengthsquared( diff ) < ( startradius * startradius ) )
	{
		midpos = to;
	}
	dir = vectornormalize( diff );
	midpos = from + ( dir[ 0 ] * startradius, dir[ 1 ] * startradius, dir[ 2 ] * startradius );
	trace = bullettrace( midpos, to, 0, ignore );
	if ( getDvarInt( #"0A1C40B1" ) != 0 )
	{
		if ( trace[ "fraction" ] == 1 )
		{
			thread debugline( midpos, to, ( 0, 0, 1 ) );
		}
		else
		{
			thread debugline( midpos, trace[ "position" ], ( 1, 0,9, 0,8 ) );
			thread debugline( trace[ "position" ], to, ( 1, 0,4, 0,3 ) );
		}
	}
	return trace;
}

damageent( einflictor, eattacker, idamage, smeansofdeath, sweapon, damagepos, damagedir )
{
	if ( self.isplayer )
	{
		self.damageorigin = damagepos;
		self.entity thread [[ level.callbackplayerdamage ]]( einflictor, eattacker, idamage, 0, smeansofdeath, sweapon, damagepos, damagedir, "none", 0, 0 );
	}
	else if ( self.isactor )
	{
		self.damageorigin = damagepos;
		self.entity thread [[ level.callbackactordamage ]]( einflictor, eattacker, idamage, 0, smeansofdeath, sweapon, damagepos, damagedir, "none", 0, 0 );
	}
	else if ( self.isadestructible )
	{
		self.damageorigin = damagepos;
		self.entity dodamage( idamage, damagepos, eattacker, einflictor, 0, smeansofdeath, 0, sweapon );
	}
	else
	{
		if ( self.isadestructable || sweapon == "claymore_mp" && sweapon == "airstrike_mp" )
		{
			return;
		}
		self.entity damage_notify_wrapper( idamage, eattacker, ( 0, 0, 1 ), ( 0, 0, 1 ), "mod_explosive", "", "" );
	}
}

debugline( a, b, color )
{
/#
	i = 0;
	while ( i < 600 )
	{
		line( a, b, color );
		wait 0,05;
		i++;
#/
	}
}

onweapondamage( eattacker, einflictor, sweapon, meansofdeath, damage )
{
	self endon( "death" );
	self endon( "disconnect" );
	switch( sweapon )
	{
		case "concussion_grenade_mp":
			radius = 512;
			if ( self == eattacker )
			{
				radius *= 0,5;
			}
			scale = 1 - ( distance( self.origin, einflictor.origin ) / radius );
			if ( scale < 0 )
			{
				scale = 0;
			}
			time = 2 + ( 4 * scale );
			wait 0,05;
			if ( self hasperk( "specialty_stunprotection" ) )
			{
				time *= 0,1;
			}
			self thread playconcussionsound( time );
			if ( self mayapplyscreeneffect() )
			{
				self shellshock( "concussion_grenade_mp", time, 0 );
			}
			self.concussionendtime = getTime() + ( time * 1000 );
			break;
		default:
			maps/mp/gametypes_zm/_shellshock::shellshockondamage( meansofdeath, damage );
			break;
	}
}

playconcussionsound( duration )
{
	self endon( "death" );
	self endon( "disconnect" );
	concussionsound = spawn( "script_origin", ( 0, 0, 1 ) );
	concussionsound.origin = self.origin;
	concussionsound linkto( self );
	concussionsound thread deleteentonownerdeath( self );
	concussionsound playsound( "" );
	concussionsound playloopsound( "" );
	if ( duration > 0,5 )
	{
		wait ( duration - 0,5 );
	}
	concussionsound playsound( "" );
	concussionsound stoploopsound( 0,5 );
	wait 0,5;
	concussionsound notify( "delete" );
	concussionsound delete();
}

deleteentonownerdeath( owner )
{
	self endon( "delete" );
	owner waittill( "death" );
	self delete();
}

monitor_dog_special_grenades()
{
}

isprimaryweapon( weaponname )
{
	return isDefined( level.primary_weapon_array[ weaponname ] );
}

issidearm( weaponname )
{
	return isDefined( level.side_arm_array[ weaponname ] );
}

isinventory( weaponname )
{
	return isDefined( level.inventory_array[ weaponname ] );
}

isgrenade( weaponname )
{
	return isDefined( level.grenade_array[ weaponname ] );
}

isexplosivebulletweapon( weaponname )
{
	if ( weaponname != "chopper_minigun_mp" && weaponname != "cobra_20mm_mp" || weaponname == "littlebird_guard_minigun_mp" && weaponname == "cobra_20mm_comlink_mp" )
	{
		return 1;
	}
	return 0;
}

getweaponclass_array( current )
{
	if ( isprimaryweapon( current ) )
	{
		return level.primary_weapon_array;
	}
	else
	{
		if ( issidearm( current ) )
		{
			return level.side_arm_array;
		}
		else
		{
			if ( isgrenade( current ) )
			{
				return level.grenade_array;
			}
			else
			{
				return level.inventory_array;
			}
		}
	}
}

updatestowedweapon()
{
	self endon( "spawned" );
	self endon( "killed_player" );
	self endon( "disconnect" );
	self.tag_stowed_back = undefined;
	self.tag_stowed_hip = undefined;
	team = self.pers[ "team" ];
	class = self.pers[ "class" ];
	while ( 1 )
	{
		self waittill( "weapon_change", newweapon );
		self.weapon_array_primary = [];
		self.weapon_array_sidearm = [];
		self.weapon_array_grenade = [];
		self.weapon_array_inventory = [];
		weaponslist = self getweaponslist();
		idx = 0;
		while ( idx < weaponslist.size )
		{
			switch( weaponslist[ idx ] )
			{
				case "m202_flash_mp":
				case "m220_tow_mp":
				case "m32_mp":
				case "minigun_mp":
				case "mp40_blinged_mp":
				case "zipline_mp":
					idx++;
					continue;
					default:
					}
					if ( isprimaryweapon( weaponslist[ idx ] ) )
					{
						self.weapon_array_primary[ self.weapon_array_primary.size ] = weaponslist[ idx ];
						idx++;
						continue;
					}
					else if ( issidearm( weaponslist[ idx ] ) )
					{
						self.weapon_array_sidearm[ self.weapon_array_sidearm.size ] = weaponslist[ idx ];
						idx++;
						continue;
					}
					else if ( isgrenade( weaponslist[ idx ] ) )
					{
						self.weapon_array_grenade[ self.weapon_array_grenade.size ] = weaponslist[ idx ];
						idx++;
						continue;
					}
					else if ( isinventory( weaponslist[ idx ] ) )
					{
						self.weapon_array_inventory[ self.weapon_array_inventory.size ] = weaponslist[ idx ];
						idx++;
						continue;
					}
					else
					{
						if ( isweaponprimary( weaponslist[ idx ] ) )
						{
							self.weapon_array_primary[ self.weapon_array_primary.size ] = weaponslist[ idx ];
						}
					}
					idx++;
				}
				detach_all_weapons();
				stow_on_back();
				stow_on_hip();
			}
		}
	}
}

forcestowedweaponupdate()
{
	detach_all_weapons();
	stow_on_back();
	stow_on_hip();
}

detachcarryobjectmodel()
{
	if ( isDefined( self.carryobject ) && isDefined( self.carryobject maps/mp/gametypes_zm/_gameobjects::getvisiblecarriermodel() ) )
	{
		if ( isDefined( self.tag_stowed_back ) )
		{
			self detach( self.tag_stowed_back, "tag_stowed_back" );
			self.tag_stowed_back = undefined;
		}
	}
}

detach_all_weapons()
{
	if ( isDefined( self.tag_stowed_back ) )
	{
		clear_weapon = 1;
		if ( isDefined( self.carryobject ) )
		{
			carriermodel = self.carryobject maps/mp/gametypes_zm/_gameobjects::getvisiblecarriermodel();
			if ( isDefined( carriermodel ) && carriermodel == self.tag_stowed_back )
			{
				self detach( self.tag_stowed_back, "tag_stowed_back" );
				clear_weapon = 0;
			}
		}
		if ( clear_weapon )
		{
			self clearstowedweapon();
		}
		self.tag_stowed_back = undefined;
	}
	if ( isDefined( self.tag_stowed_hip ) )
	{
		detach_model = getweaponmodel( self.tag_stowed_hip );
		self detach( detach_model, "tag_stowed_hip_rear" );
		self.tag_stowed_hip = undefined;
	}
}

non_stowed_weapon( weapon )
{
	if ( self hasweapon( "knife_ballistic_mp" ) && weapon != "knife_ballistic_mp" )
	{
		return 1;
	}
	if ( self hasweapon( "knife_held_mp" ) && weapon != "knife_held_mp" )
	{
		return 1;
	}
	return 0;
}

stow_on_back( current )
{
	current = self getcurrentweapon();
	self.tag_stowed_back = undefined;
	weaponoptions = 0;
	index_weapon = "";
	if ( isDefined( self.carryobject ) && isDefined( self.carryobject maps/mp/gametypes_zm/_gameobjects::getvisiblecarriermodel() ) )
	{
		self.tag_stowed_back = self.carryobject maps/mp/gametypes_zm/_gameobjects::getvisiblecarriermodel();
		self attach( self.tag_stowed_back, "tag_stowed_back", 1 );
		return;
	}
	else
	{
		if ( non_stowed_weapon( current ) || self.hasriotshield )
		{
			return;
		}
		else
		{
			idx = 0;
			while ( idx < self.weapon_array_primary.size )
			{
				temp_index_weapon = self.weapon_array_primary[ idx ];
/#
				assert( isDefined( temp_index_weapon ), "Primary weapon list corrupted." );
#/
				if ( temp_index_weapon == current )
				{
					idx++;
					continue;
				}
				else if ( current == "none" )
				{
					idx++;
					continue;
				}
				else if ( !issubstr( current, "gl_" ) && !issubstr( temp_index_weapon, "gl_" ) && !issubstr( current, "mk_" ) && !issubstr( temp_index_weapon, "mk_" ) && !issubstr( current, "dualoptic_" ) && !issubstr( temp_index_weapon, "dualoptic_" ) || issubstr( current, "ft_" ) && issubstr( temp_index_weapon, "ft_" ) )
				{
					index_weapon_tok = strtok( temp_index_weapon, "_" );
					current_tok = strtok( current, "_" );
					i = 0;
					while ( i < index_weapon_tok.size )
					{
						if ( !issubstr( current, index_weapon_tok[ i ] ) || index_weapon_tok.size != current_tok.size )
						{
							i = 0;
							break;
						}
						else
						{
							i++;
						}
					}
					if ( i == index_weapon_tok.size )
					{
						idx++;
						continue;
					}
				}
				else
				{
					index_weapon = temp_index_weapon;
/#
					assert( isDefined( self.curclass ), "Player missing current class" );
#/
					if ( issubstr( index_weapon, self.pers[ "primaryWeapon" ] ) && issubstr( self.curclass, "CUSTOM" ) )
					{
						self.tag_stowed_back = getweaponmodel( index_weapon, self getloadoutitem( self.class_num, "primarycamo" ) );
					}
					else
					{
						stowedmodelindex = getweaponstowedmodel( index_weapon );
						self.tag_stowed_back = getweaponmodel( index_weapon, stowedmodelindex );
					}
					if ( issubstr( self.curclass, "CUSTOM" ) )
					{
						weaponoptions = self calcweaponoptions( self.class_num, 0 );
					}
				}
				idx++;
			}
		}
	}
	if ( !isDefined( self.tag_stowed_back ) )
	{
		return;
	}
	self setstowedweapon( index_weapon );
}

stow_on_hip()
{
	current = self getcurrentweapon();
	self.tag_stowed_hip = undefined;
	idx = 0;
	while ( idx < self.weapon_array_inventory.size )
	{
		if ( self.weapon_array_inventory[ idx ] == current )
		{
			idx++;
			continue;
		}
		else if ( !self getweaponammostock( self.weapon_array_inventory[ idx ] ) )
		{
			idx++;
			continue;
		}
		else
		{
			self.tag_stowed_hip = self.weapon_array_inventory[ idx ];
		}
		idx++;
	}
	if ( !isDefined( self.tag_stowed_hip ) )
	{
		return;
	}
	if ( self.tag_stowed_hip != "satchel_charge_mp" || self.tag_stowed_hip == "claymore_mp" && self.tag_stowed_hip == "bouncingbetty_mp" )
	{
		self.tag_stowed_hip = undefined;
		return;
	}
	weapon_model = getweaponmodel( self.tag_stowed_hip );
	self attach( weapon_model, "tag_stowed_hip_rear", 1 );
}

stow_inventory( inventories, current )
{
	if ( isDefined( self.inventory_tag ) )
	{
		detach_model = getweaponmodel( self.inventory_tag );
		self detach( detach_model, "tag_stowed_hip_rear" );
		self.inventory_tag = undefined;
	}
	if ( !isDefined( inventories[ 0 ] ) || self getweaponammostock( inventories[ 0 ] ) == 0 )
	{
		return;
	}
	if ( inventories[ 0 ] != current )
	{
		self.inventory_tag = inventories[ 0 ];
		weapon_model = getweaponmodel( self.inventory_tag );
		self attach( weapon_model, "tag_stowed_hip_rear", 1 );
	}
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

player_is_driver()
{
	if ( !isalive( self ) )
	{
		return 0;
	}
	if ( self isremotecontrolling() )
	{
		return 0;
	}
	vehicle = self getvehicleoccupied();
	if ( isDefined( vehicle ) )
	{
		seat = vehicle getoccupantseat( self );
		if ( isDefined( seat ) && seat == 0 )
		{
			return 1;
		}
	}
	return 0;
}

loadout_get_class_num()
{
/#
	assert( isplayer( self ) );
#/
/#
	assert( isDefined( self.class ) );
#/
	if ( isDefined( level.classtoclassnum[ self.class ] ) )
	{
		return level.classtoclassnum[ self.class ];
	}
	class_num = int( self.class[ self.class.size - 1 ] ) - 1;
	if ( class_num == -1 )
	{
		class_num = 9;
	}
	return class_num;
}

loadout_get_offhand_weapon( stat )
{
	if ( isDefined( level.givecustomloadout ) )
	{
		return "weapon_null_mp";
	}
	class_num = self loadout_get_class_num();
	index = 0;
	if ( isDefined( level.tbl_weaponids[ index ] ) && isDefined( level.tbl_weaponids[ index ][ "reference" ] ) )
	{
		return level.tbl_weaponids[ index ][ "reference" ] + "_mp";
	}
	return "weapon_null_mp";
}

loadout_get_offhand_count( stat )
{
	if ( isDefined( level.givecustomloadout ) )
	{
		return 0;
	}
	class_num = self loadout_get_class_num();
	count = 0;
	return count;
}

scavenger_think()
{
	self endon( "death" );
	self waittill( "scavenger", player );
	primary_weapons = player getweaponslistprimaries();
	offhand_weapons_and_alts = array_exclude( player getweaponslist( 1 ), primary_weapons );
	arrayremovevalue( offhand_weapons_and_alts, "knife_mp" );
	player playsound( "fly_equipment_pickup_npc" );
	player playlocalsound( "fly_equipment_pickup_plr" );
	player.scavenger_icon.alpha = 1;
	player.scavenger_icon fadeovertime( 2,5 );
	player.scavenger_icon.alpha = 0;
	scavenger_lethal_proc = 1;
	scavenger_tactical_proc = 1;
	if ( !isDefined( player.scavenger_lethal_proc ) )
	{
		player.scavenger_lethal_proc = 0;
		player.scavenger_tactical_proc = 0;
	}
	loadout_primary = player loadout_get_offhand_weapon( "primarygrenade" );
	loadout_primary_count = player loadout_get_offhand_count( "primarygrenadecount" );
	loadout_secondary = player loadout_get_offhand_weapon( "specialgrenade" );
	loadout_secondary_count = player loadout_get_offhand_count( "specialgrenadeCount" );
	i = 0;
	while ( i < offhand_weapons_and_alts.size )
	{
		weapon = offhand_weapons_and_alts[ i ];
		if ( ishackweapon( weapon ) )
		{
			break;
		i++;
		continue;
	}
	else switch( weapon )
	{
		case "bouncingbetty_mp":
		case "claymore_mp":
		case "frag_grenade_mp":
		case "hatchet_mp":
		case "satchel_charge_mp":
		case "sticky_grenade_mp":
			if ( isDefined( player.grenadetypeprimarycount ) && player.grenadetypeprimarycount < 1 )
			{
				break;
			i++;
			continue;
		}
		else
		{
			if ( player getweaponammostock( weapon ) != loadout_primary_count )
			{
				if ( player.scavenger_lethal_proc < scavenger_lethal_proc )
				{
					player.scavenger_lethal_proc++;
					break;
				i++;
				continue;
			}
			else player.scavenger_lethal_proc = 0;
			player.scavenger_tactical_proc = 0;
		}
		case "concussion_grenade_mp":
		case "emp_grenade_mp":
		case "flash_grenade_mp":
		case "nightingale_mp":
		case "pda_hack_mp":
		case "proximity_grenade_mp":
		case "sensor_grenade_mp":
		case "tabun_gas_mp":
		case "trophy_system_mp":
		case "willy_pete_mp":
			if ( isDefined( player.grenadetypesecondarycount ) && player.grenadetypesecondarycount < 1 )
			{
				break;
			i++;
			continue;
		}
		else
		{
			if ( weapon == loadout_secondary && player getweaponammostock( weapon ) != loadout_secondary_count )
			{
				if ( player.scavenger_tactical_proc < scavenger_tactical_proc )
				{
					player.scavenger_tactical_proc++;
					break;
				i++;
				continue;
			}
			else player.scavenger_tactical_proc = 0;
			player.scavenger_lethal_proc = 0;
		}
		maxammo = weaponmaxammo( weapon );
		stock = player getweaponammostock( weapon );
		if ( isDefined( level.customloadoutscavenge ) )
		{
			maxammo = self [[ level.customloadoutscavenge ]]( weapon );
		}
		else if ( weapon == loadout_primary )
		{
			maxammo = loadout_primary_count;
		}
		else
		{
			if ( weapon == loadout_secondary )
			{
				maxammo = loadout_secondary_count;
			}
		}
		if ( stock < maxammo )
		{
			ammo = stock + 1;
			if ( ammo > maxammo )
			{
				ammo = maxammo;
			}
			player setweaponammostock( weapon, ammo );
			player thread maps/mp/_challenges::scavengedgrenade();
		}
		break;
	i++;
	continue;
	default:
		if ( islauncherweapon( weapon ) )
		{
			stock = player getweaponammostock( weapon );
			start = player getfractionstartammo( weapon );
			clip = weaponclipsize( weapon );
			clip *= getdvarfloatdefault( "scavenger_clip_multiplier", 2 );
			clip = int( clip );
			maxammo = weaponmaxammo( weapon );
			if ( stock < ( maxammo - clip ) )
			{
				ammo = stock + clip;
				player setweaponammostock( weapon, ammo );
				break;
			}
			else
			{
				player setweaponammostock( weapon, maxammo );
			}
		}
		break;
	i++;
	continue;
}
}
}
i++;
}
i = 0;
while ( i < primary_weapons.size )
{
weapon = primary_weapons[ i ];
if ( ishackweapon( weapon ) || weapon == "kniferang_mp" )
{
i++;
continue;
}
else
{
stock = player getweaponammostock( weapon );
start = player getfractionstartammo( weapon );
clip = weaponclipsize( weapon );
clip *= getdvarfloatdefault( "scavenger_clip_multiplier", 2 );
clip = int( clip );
maxammo = weaponmaxammo( weapon );
if ( stock < ( maxammo - clip ) )
{
ammo = stock + clip;
player setweaponammostock( weapon, ammo );
i++;
continue;
}
else
{
player setweaponammostock( weapon, maxammo );
}
}
i++;
}
}

scavenger_hud_create()
{
	if ( level.wagermatch )
	{
		return;
	}
	self.scavenger_icon = newclienthudelem( self );
	self.scavenger_icon.horzalign = "center";
	self.scavenger_icon.vertalign = "middle";
	self.scavenger_icon.x = -16;
	self.scavenger_icon.y = 16;
	self.scavenger_icon.alpha = 0;
	width = 32;
	height = 16;
	if ( self issplitscreen() )
	{
		width = int( width * 0,5 );
		height = int( height * 0,5 );
		self.scavenger_icon.x = -8;
	}
	self.scavenger_icon setshader( "hud_scavenger_pickup", width, height );
}

dropscavengerfordeath( attacker )
{
	if ( sessionmodeiszombiesgame() )
	{
		return;
	}
	if ( level.wagermatch )
	{
		return;
	}
	if ( !isDefined( attacker ) )
	{
		return;
	}
	if ( attacker == self )
	{
		return;
	}
	if ( level.gametype == "hack" )
	{
		item = self dropscavengeritem( "scavenger_item_hack_mp" );
	}
	else
	{
		item = self dropscavengeritem( "scavenger_item_mp" );
	}
	item thread scavenger_think();
}

addlimitedweapon( weapon_name, owner, num_drops )
{
	limited_info = spawnstruct();
	limited_info.weapon = weapon_name;
	limited_info.drops = num_drops;
	owner.limited_info = limited_info;
}

shoulddroplimitedweapon( weapon_name, owner )
{
	limited_info = owner.limited_info;
	if ( !isDefined( limited_info ) )
	{
		return 1;
	}
	if ( limited_info.weapon != weapon_name )
	{
		return 1;
	}
	if ( limited_info.drops <= 0 )
	{
		return 0;
	}
	return 1;
}

droplimitedweapon( weapon_name, owner, item )
{
	limited_info = owner.limited_info;
	if ( !isDefined( limited_info ) )
	{
		return;
	}
	if ( limited_info.weapon != weapon_name )
	{
		return;
	}
	limited_info.drops -= 1;
	owner.limited_info = undefined;
	item thread limitedpickup( limited_info );
}

limitedpickup( limited_info )
{
	self endon( "death" );
	self waittill( "trigger", player, item );
	if ( !isDefined( item ) )
	{
		return;
	}
	player.limited_info = limited_info;
}
