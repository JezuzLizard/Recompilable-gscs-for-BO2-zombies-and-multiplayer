#include maps/mp/zombies/_zm_weap_cymbal_monkey;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/zombies/_zm_equipment;
#include maps/mp/zombies/_zm_score;
#include maps/mp/zombies/_zm_pers_upgrades_functions;
#include maps/mp/zombies/_zm_melee_weapon;
#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/gametypes_zm/_weapons;
#include maps/mp/gametypes_zm/_weaponobjects;
#include maps/mp/zombies/_zm_magicbox;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/zombies/_zm_weap_claymore;
#include maps/mp/zombies/_zm_weap_ballistic_knife;


init() //checked matches cerberus output
{
	//begin debug
	level.custom_zm_weapons_loaded = 1;
	maps/mp/zombies/_zm_bot::init();
	if ( !isDefined( level.debugLogging_zm_weapons ) )
	{
		level.debugLogging_zm_weapons = 0;
	}
	//end debug
	init_weapons();
	init_weapon_upgrade();
	init_weapon_toggle();
	precacheshader( "minimap_icon_mystery_box" );
	precacheshader( "specialty_instakill_zombies" );
	precacheshader( "specialty_firesale_zombies" );
	precacheitem( "zombie_fists_zm" );
	level._weaponobjects_on_player_connect_override = ::weaponobjects_on_player_connect_override;
	level._zombiemode_check_firesale_loc_valid_func = ::default_check_firesale_loc_valid_func;
	level.missileentities = [];
	setupretrievablehintstrings();
	level thread onplayerconnect();

}

setupretrievablehintstrings() //checked matches cerberus output
{
	maps/mp/gametypes_zm/_weaponobjects::createretrievablehint( "claymore", &"ZOMBIE_CLAYMORE_PICKUP" );
}

onplayerconnect() //checked matches cerberus output
{
	for ( ;; )
	{
		level waittill( "connecting", player );
		player thread onplayerspawned();
	}
}

onplayerspawned() //checked matches cerberus output
{
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "spawned_player" );
		self thread watchforgrenadeduds();
		self thread watchforgrenadelauncherduds();
		self.staticweaponsstarttime = getTime();
	}
}

watchforgrenadeduds() //checked matches cerberus output
{
	self endon( "spawned_player" );
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "grenade_fire", grenade, weapname );
		if ( !is_equipment( weapname ) && weapname != "claymore_zm" )
		{
			grenade thread checkgrenadefordud( weapname, 1, self );
			grenade thread watchforscriptexplosion( weapname, 1, self );
		}
	}
}

watchforgrenadelauncherduds() //checked matches cerberus output
{
	self endon( "spawned_player" );
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "grenade_launcher_fire", grenade, weapname );
		grenade thread checkgrenadefordud( weapname, 0, self );
		grenade thread watchforscriptexplosion( weapname, 0, self );
	}
}

grenade_safe_to_throw( player, weapname ) //checked matches cerberus output
{
	if ( isDefined( level.grenade_safe_to_throw ) )
	{
		return self [[ level.grenade_safe_to_throw ]]( player, weapname );
	}
	return 1;
}

grenade_safe_to_bounce( player, weapname ) //checked matches cerberus output
{
	if ( isDefined( level.grenade_safe_to_bounce ) )
	{
		return self [[ level.grenade_safe_to_bounce ]]( player, weapname );
	}
	return 1;
}

makegrenadedudanddestroy() //checked matches cerberus output
{
	self endon( "death" );
	self notify( "grenade_dud" );
	self makegrenadedud();
	wait 3;
	if ( isDefined( self ) )
	{
		self delete();
	}
}

checkgrenadefordud( weapname, isthrowngrenade, player ) //checked matches cerberus output
{
	self endon( "death" );
	player endon( "zombify" );
	if ( !self grenade_safe_to_throw( player, weapname ) )
	{
		self thread makegrenadedudanddestroy();
		return;
	}
	for ( ;; )
	{
		self waittill_any_timeout( 0.25, "grenade_bounce", "stationary" );
		if ( !self grenade_safe_to_bounce( player, weapname ) )
		{
			self thread makegrenadedudanddestroy();
			return;
		}
	}
}

wait_explode() //checked matches cerberus output
{
	self endon( "grenade_dud" );
	self endon( "done" );
	self waittill( "explode", position );
	level.explode_position = position;
	level.explode_position_valid = 1;
	self notify( "done" );
}

wait_timeout( time ) //checked matches cerberus output
{
	self endon( "grenade_dud" );
	self endon( "done" );
	wait time;
	self notify( "done" );
}

wait_for_explosion( time ) //checked changed to match cerberus output
{
	level.explode_position = ( 0, 0, 0 );
	level.explode_position_valid = 0;
	self thread wait_explode();
	self thread wait_timeout( time );
	self waittill( "done" );
	self notify( "death_or_explode", level.explode_position_valid, level.explode_position );
}

watchforscriptexplosion( weapname, isthrowngrenade, player ) //checked changed to match cerberus output
{
	self endon( "grenade_dud" );
	if ( is_lethal_grenade( weapname ) || is_grenade_launcher( weapname ) )
	{
		self thread wait_for_explosion( 20 );
		self waittill( "death_or_explode", exploded, position );
		if ( exploded )
		{
			level notify( "grenade_exploded", position, 256, 300, 75 );
		}
	}
}

get_nonalternate_weapon( altweapon ) //checked changed to match cerberus output
{
	if ( is_alt_weapon( altweapon ) )
	{
		alt = weaponaltweaponname( altweapon );
		if ( alt == "none" )
		{
			primaryweapons = self getweaponslistprimaries();
			alt = primaryweapons[ 0 ];
			foreach ( weapon in primaryweapons )
			{
				if ( weaponaltweaponname( weapon ) == altweapon )
				{
					alt = weapon;
					break;
				}
			}
		}
		return alt;
	}
	return altweapon;
}

switch_from_alt_weapon( current_weapon ) //checked changed to match cerberus output
{
	if ( is_alt_weapon( current_weapon ) )
	{
		alt = weaponaltweaponname( current_weapon );
		if ( alt == "none" )
		{
			primaryweapons = self getweaponslistprimaries();
			alt = primaryweapons[ 0 ];
			foreach ( weapon in primaryweapons )
			{
				if ( weaponaltweaponname( weapon ) == current_weapon )
				{
					alt = weapon;
					break;
				}
			}
		}
		self switchtoweaponimmediate( alt );
		self waittill_notify_or_timeout( "weapon_change_complete", 1 );
		return alt;
	}
	return current_weapon;
}

give_fallback_weapon() //checked matches cerberus output
{
	self giveweapon( "zombie_fists_zm" );
	self switchtoweapon( "zombie_fists_zm" );
}

take_fallback_weapon() //checked matches cerberus output
{
	if ( self hasweapon( "zombie_fists_zm" ) )
	{
		self takeweapon( "zombie_fists_zm" );
	}
}

switch_back_primary_weapon( oldprimary ) //checked changed to match cerberus output
{
	if ( is_true( self.laststand ) )
	{
		return;
	}
	primaryweapons = self getweaponslistprimaries();
	if ( isDefined( oldprimary ) && isinarray( primaryweapons, oldprimary ) )
	{
		self switchtoweapon( oldprimary );
	}
	else if ( isDefined( primaryweapons ) && primaryweapons.size > 0 )
	{
		self switchtoweapon( primaryweapons[ 0 ] );
	}
}

add_retrievable_knife_init_name( name ) //checked matches cerberus output
{
	if ( !isDefined( level.retrievable_knife_init_names ) )
	{
		level.retrievable_knife_init_names = [];
	}
	level.retrievable_knife_init_names[ level.retrievable_knife_init_names.size ] = name;
}

watchweaponusagezm() //checked changed to match cerberus output
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	for ( ;; )
	{
		self waittill( "weapon_fired", curweapon );
		self.lastfiretime = getTime();
		self.hasdonecombat = 1;
		if ( isDefined( self.hitsthismag[ curweapon ] ) )
		{
			self thread updatemagshots( curweapon );
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
				}
			case "pistol":
			case "pistol spread":
			case "pistolspread":
			case "mg":
			case "smg":
			case "spread":
				self trackweaponfire( curweapon );
				level.globalshotsfired++;
				break;
			case "grenade":
			case "rocketlauncher":
				if ( is_alt_weapon( curweapon ) )
				{
					curweapon = weaponaltweaponname( curweapon );
				}
				self addweaponstat( curweapon, "shots", 1 );
				break;
			default:
			
			switch( curweapon )
			{
				case "m202_flash_mp":
				case "m220_tow_mp":
				case "m32_mp":
				case "minigun_mp":
				case "mp40_blinged_mp":
					self.usedkillstreakweapon[ curweapon ] = 1;
					break;
				default:
				
			}
		}
	}
}

trackweaponzm() //checked changed to match cerberus output
{
	self.currentweapon = self getcurrentweapon();
	self.currenttime = getTime();
	spawnid = getplayerspawnid( self );
	while ( 1 )
	{
		event = self waittill_any_return( "weapon_change", "death", "disconnect", "bled_out" );
		newtime = getTime();
		if ( event == "weapon_change" )
		{
			newweapon = self getcurrentweapon();
			if ( newweapon != "none" && newweapon != self.currentweapon )
			{
				updatelastheldweapontimingszm( newtime );
				self.currentweapon = newweapon;
				self.currenttime = newtime;
			}
		}
		if ( event != "disconnect" )
		{
			updateweapontimingszm( newtime );
		}
		//return; //changed at own discretion
	}
}

updatelastheldweapontimingszm( newtime ) //checked matches cerberus output
{
	if ( isDefined( self.currentweapon ) && isDefined( self.currenttime ) )
	{
		curweapon = self.currentweapon;
		totaltime = int( ( newtime - self.currenttime ) / 1000 );
		if ( totaltime > 0 )
		{
			if ( is_alt_weapon( curweapon ) )
			{
				curweapon = weaponaltweaponname( curweapon );
			}
			self addweaponstat( curweapon, "timeUsed", totaltime );
		}
	}
}

updateweapontimingszm( newtime ) //checked matches cerberus output
{
	if ( self is_bot() )
	{
		return;
	}
	updatelastheldweapontimingszm( newtime );
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
}

watchweaponchangezm() //checked matches cerberus output
{
	self endon( "death" );
	self endon( "disconnect" );
	self.lastdroppableweapon = self getcurrentweapon();
	self.hitsthismag = [];
	weapon = self getcurrentweapon();
	if ( isDefined( weapon ) && weapon != "none" && !isDefined( self.hitsthismag[ weapon ] ) )
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
			if ( !isDefined( self.hitsthismag[ newweapon ] ) )
			{
				self.hitsthismag[ newweapon ] = weaponclipsize( newweapon );
			}
		}
	}
}

weaponobjects_on_player_connect_override_internal() //checked changed to match cerberus output
{
	self maps/mp/gametypes_zm/_weaponobjects::createbasewatchers();
	self createclaymorewatcher_zm();
	for ( i = 0; i < level.retrievable_knife_init_names.size; i++ )
	{
		self createballisticknifewatcher_zm( level.retrievable_knife_init_names[ i ], level.retrievable_knife_init_names[ i ] + "_zm" );
	}
	self maps/mp/gametypes_zm/_weaponobjects::setupretrievablewatcher();
	if ( !isDefined( self.weaponobjectwatcherarray ) )
	{
		self.weaponobjectwatcherarray = [];
	}
	self thread maps/mp/gametypes_zm/_weaponobjects::watchweaponobjectspawn();
	self thread maps/mp/gametypes_zm/_weaponobjects::watchweaponprojectileobjectspawn();
	self thread maps/mp/gametypes_zm/_weaponobjects::deleteweaponobjectson();
	self.concussionendtime = 0;
	self.hasdonecombat = 0;
	self.lastfiretime = 0;
	self thread watchweaponusagezm();
	self thread maps/mp/gametypes_zm/_weapons::watchgrenadeusage();
	self thread maps/mp/gametypes_zm/_weapons::watchmissileusage();
	self thread watchweaponchangezm();
	self thread maps/mp/gametypes_zm/_weapons::watchturretuse();
	self thread trackweaponzm();
	self notify( "weapon_watchers_created" );
}

weaponobjects_on_player_connect_override() //checked matches cerberus output
{
	add_retrievable_knife_init_name( "knife_ballistic" );
	add_retrievable_knife_init_name( "knife_ballistic_upgraded" );
	onplayerconnect_callback( ::weaponobjects_on_player_connect_override_internal );
}

createclaymorewatcher_zm() //checked changed to match cerberus output
{
	watcher = self maps/mp/gametypes_zm/_weaponobjects::createuseweaponobjectwatcher( "claymore", "claymore_zm", self.team );
	watcher.onspawnretrievetriggers = maps/mp/zombies/_zm_weap_claymore::on_spawn_retrieve_trigger;
	watcher.adjusttriggerorigin = maps/mp/zombies/_zm_weap_claymore::adjust_trigger_origin;
	watcher.pickup = level.pickup_claymores;
	watcher.pickup_trigger_listener = level.pickup_claymores_trigger_listener;
	watcher.skip_weapon_object_damage = 1;
	watcher.headicon = 0;
	watcher.watchforfire = 1;
	watcher.detonate = ::claymoredetonate;
	watcher.ondamage = level.claymores_on_damage;
}

createballisticknifewatcher_zm( name, weapon ) //checked changed to match cerberus output
{
	watcher = self maps/mp/gametypes_zm/_weaponobjects::createuseweaponobjectwatcher( name, weapon, self.team );
	watcher.onspawn = maps/mp/zombies/_zm_weap_ballistic_knife::on_spawn;
	watcher.onspawnretrievetriggers = maps/mp/zombies/_zm_weap_ballistic_knife::on_spawn_retrieve_trigger;
	watcher.storedifferentobject = 1;
	watcher.headicon = 0;
}

isempweapon( weaponname ) //checked changed at own discretion
{
	if ( isDefined( weaponname ) && weaponname == "emp_grenade_zm" )
	{
		return 1;
	}
	return 0;
}

claymoredetonate( attacker, weaponname ) //checked matches cerberus output
{
	from_emp = isempweapon( weaponname );
	if ( from_emp )
	{
		self delete();
		return;
	}
	if ( isDefined( attacker ) )
	{
		self detonate( attacker );
	}
	else if ( isDefined( self.owner ) && isplayer( self.owner ) )
	{
		self detonate( self.owner );
	}
	else
	{
		self detonate();
	}
}

default_check_firesale_loc_valid_func() //checked matches cerberus output
{
	return 1;
}

add_zombie_weapon( weapon_name, upgrade_name, hint, cost, weaponvo, weaponvoresp, ammo_cost, create_vox ) //checked matches cerberus output
{
	if ( isDefined( level.zombie_include_weapons ) && !isDefined( level.zombie_include_weapons[ weapon_name ] ) )
	{
		return;
	}
	table = "mp/zombiemode.csv";
	table_cost = tablelookup( table, 0, weapon_name, 1 );
	table_ammo_cost = tablelookup( table, 0, weapon_name, 2 );
	if ( isDefined( table_cost ) && table_cost != "" )
	{
		cost = round_up_to_ten( int( table_cost ) );
	}
	if ( isDefined( table_ammo_cost ) && table_ammo_cost != "" )
	{
		ammo_cost = round_up_to_ten( int( table_ammo_cost ) );
	}
	precachestring( hint );
	struct = spawnstruct();
	if ( !isDefined( level.zombie_weapons ) )
	{
		level.zombie_weapons = [];
	}
	if ( !isDefined( level.zombie_weapons_upgraded ) )
	{
		level.zombie_weapons_upgraded = [];
	}
	if ( isDefined( upgrade_name ) )
	{
		level.zombie_weapons_upgraded[ upgrade_name ] = weapon_name;
	}

	struct.weapon_name = weapon_name;
	struct.upgrade_name = upgrade_name;
	struct.weapon_classname = "weapon_" + weapon_name;
	struct.hint = hint;
	struct.cost = cost;
	struct.vox = weaponvo;
	struct.vox_response = weaponvoresp;
	struct.is_in_box = level.zombie_include_weapons[ weapon_name ];
	if ( !isDefined( ammo_cost ) )
	{
		ammo_cost = round_up_to_ten( int( cost * 0.5 ) );
	}
	struct.ammo_cost = ammo_cost;
	
	
	level.zombie_weapons[ weapon_name ] = struct;
	if ( is_true( level.zombiemode_reusing_pack_a_punch ) && isDefined( upgrade_name ) )
	{
		add_attachments( weapon_name, upgrade_name );
	}
	if ( isDefined( create_vox ) )
	{
		level.vox maps/mp/zombies/_zm_audio::zmbvoxadd( "player", "weapon_pickup", weapon_name, weaponvo, undefined );
	}
}

add_attachments( weapon_name, upgrade_name ) //checked does not match cerberus output did not change
{
	table = "zm/pap_attach.csv";
	if ( isDefined( level.weapon_attachment_table ) )
	{
		table = level.weapon_attachment_table;
	}
	row = tablelookuprownum( table, 0, upgrade_name );
	if ( row > -1 )
	{
		level.zombie_weapons[ weapon_name ].default_attachment = TableLookUp( table, 0, upgrade_name, 1 );
		level.zombie_weapons[ weapon_name ].addon_attachments = [];
		index = 2;
		next_addon = TableLookUp( table, 0, upgrade_name, index );

		while ( isdefined( next_addon ) && next_addon.size > 0 )
		{
			level.zombie_weapons[ weapon_name ].addon_attachments[ level.zombie_weapons[ weapon_name ].addon_attachments.size ] = next_addon;
			index++;
			next_addon = TableLookUp( table, 0, upgrade_name, index );
		}
	}
}

default_weighting_func() //checked matches cerberus output
{
	return 1;
}

default_tesla_weighting_func() //checked changed to match cerberus output
{
	num_to_add = 1;
	if ( isDefined( level.pulls_since_last_tesla_gun ) )
	{
		if ( isDefined( level.player_drops_tesla_gun ) && level.player_drops_tesla_gun == 1 )
		{
			num_to_add += int( 0.2 * level.zombie_include_weapons.size );
		}
		if ( !isDefined( level.player_seen_tesla_gun ) || level.player_seen_tesla_gun == 0 )
		{
			if ( level.round_number > 10 )
			{
				num_to_add += int( 0.2 * level.zombie_include_weapons.size );
			}
			else if ( level.round_number > 5 )
			{
				num_to_add += int( 0.15 * level.zombie_include_weapons.size );
			}
		}
	}
	return num_to_add;
}

default_1st_move_weighting_func() //checked matches cerberus output
{
	if ( level.chest_moves > 0 )
	{
		num_to_add = 1;
		return num_to_add;
	}
	else
	{
		return 0;
	}
}

default_upgrade_weapon_weighting_func() //checked matches cerberus output
{
	if ( level.chest_moves > 1 )
	{
		return 1;
	}
	else
	{
		return 0;
	}
}

default_cymbal_monkey_weighting_func() //checked changed to match cerberus output
{
	players = get_players();
	count = 0;
    for ( i = 0; i < players.size; i++ )
	{
		if ( players[ i ] has_weapon_or_upgrade( "cymbal_monkey_zm" ) )
		{
			count++;
		}
	}
	if ( count > 0 )
	{
		return 1;
	}
	else if ( level.round_number < 10 )
	{
		return 3;
	}
	else
	{
		return 5;
	}
}

is_weapon_included( weapon_name ) //checked matches cerberus output
{
	if ( !isDefined( level.zombie_weapons ) )
	{
		return 0;
	}
	return isDefined( level.zombie_weapons[ weapon_name ] );
}

is_weapon_or_base_included( weapon_name ) //checked matches cerberus output
{
	if ( !isDefined( level.zombie_weapons ) )
	{
		return 0;
	}
	if ( isDefined( level.zombie_weapons[ weapon_name ] ) )
	{
		return 1;
	}
	base = get_base_weapon_name( weapon_name, 1 );
	if ( isDefined( level.zombie_weapons[ base ] ) )
	{
		return 1;
	}
	return 0;
}

include_zombie_weapon( weapon_name, in_box, collector, weighting_func ) //checked matches cerberus output
{
	if ( !isDefined( level.zombie_include_weapons ) )
	{
		level.zombie_include_weapons = [];
	}
	if ( !isDefined( in_box ) )
	{
		in_box = 1;
	}
	
	level.zombie_include_weapons[ weapon_name ] = in_box;
	precacheitem( weapon_name );
	if ( !isDefined( weighting_func ) )
	{
		level.weapon_weighting_funcs[ weapon_name ] = ::default_weighting_func;
	}
	else
	{
		level.weapon_weighting_funcs[ weapon_name ] = weighting_func;
	}
}

init_weapons() //checked matches cerberus output
{
	if ( isdefined( level._zombie_custom_add_weapons ) )
	{
		[[ level._zombie_custom_add_weapons ]]();
	}
	precachemodel( "zombie_teddybear" );
}

add_limited_weapon( weapon_name, amount ) //checked matches cerberus output
{
	if ( !isDefined( level.limited_weapons ) )
	{
		level.limited_weapons = [];
	}
	level.limited_weapons[ weapon_name ] = amount;
}

limited_weapon_below_quota( weapon, ignore_player, pap_triggers ) //checked changed to match cerberus output
{
	if ( isDefined( level.limited_weapons[ weapon ] ) )
	{
		if ( !isDefined( pap_triggers ) )
		{
			if ( !isDefined( level.pap_triggers ) )
			{
				pap_triggers = getentarray( "specialty_weapupgrade", "script_noteworthy" );
			}
			else
			{
				pap_triggers = level.pap_triggers;
			}
		}
		if ( is_true( level.no_limited_weapons ) )
		{
			return 0;
		}
		upgradedweapon = weapon;
		if ( isDefined( level.zombie_weapons[ weapon ] ) && isDefined( level.zombie_weapons[ weapon ].upgrade_name ) )
		{
			upgradedweapon = level.zombie_weapons[ weapon ].upgrade_name;
		}
		players = get_players();
		count = 0;
		limit = level.limited_weapons[ weapon ];
		i = 0;
		while ( i < players.size)
		{
			if ( isDefined( ignore_player ) && ignore_player == players[ i ] )
			{
				i++;
				continue;
			}
			if ( players[ i ] has_weapon_or_upgrade( weapon ) )
			{
				count++;
				if ( count >= limit )
				{
					return 0;
				}
			}
			i++;
		}
		for ( k = 0; k < pap_triggers.size; k++ )
		{
			if ( isDefined( pap_triggers[ k ].current_weapon ) && pap_triggers[ k ].current_weapon == weapon || isDefined( pap_triggers[ k ].current_weapon ) && pap_triggers[ k ].current_weapon == upgradedweapon )
			{
				count++;
				if ( count >= limit )
				{
					return 0;
				}
			}
		}
		for ( chestindex = 0; chestindex < level.chests.size; chestindex++ )
		{
			if ( isDefined( level.chests[ chestindex ].zbarrier.weapon_string ) && level.chests[ chestindex ].zbarrier.weapon_string == weapon )
			{
				count++;
				if ( count >= limit )
				{
					return 0;
				}
			}
		}
		if ( isDefined( level.custom_limited_weapon_checks ) )
		{
			foreach ( check in level.custom_limited_weapon_checks )
			{
				count = count + [[ check ]]( weapon );
			}
			if ( count >= limit )
			{
				return 0;
			}
		}
		if ( isDefined( level.random_weapon_powerups ) )
		{
			for ( powerupindex = 0; powerupindex < level.random_weapon_powerups.size; powerupindex++ )
			{
				if ( isDefined( level.random_weapon_powerups[ powerupindex ] ) && level.random_weapon_powerups[ powerupindex ].base_weapon == weapon )
				{
					count++;
					if ( count >= limit )
					{
						return 0;
					}
				}
			}
		}
	}
	return 1;
}

add_custom_limited_weapon_check( callback ) //checked matches cerberus output
{
	if ( !isDefined( level.custom_limited_weapon_checks ) )
	{
		level.custom_limited_weapon_checks = [];
	}
	level.custom_limited_weapon_checks[ level.custom_limited_weapon_checks.size ] = callback;
}

add_weapon_to_content( weapon_name, package ) //checked matches cerberus output
{
	if ( !isDefined( level.content_weapons ) )
	{
		level.content_weapons = [];
	}
	level.content_weapons[ weapon_name ] = package;
}

player_can_use_content( weapon ) //checked matches cerberus output
{
	if ( isDefined( level.content_weapons ) )
	{
		if ( isDefined( level.content_weapons[ weapon ] ) )
		{
			return self hasdlcavailable( level.content_weapons[ weapon ] );
		}
	}
	return 1;
}

init_spawnable_weapon_upgrade() //checked partially changed to match cerberus output
{
	spawn_list = [];
	spawnable_weapon_spawns = getstructarray( "weapon_upgrade", "targetname" );
	spawnable_weapon_spawns = arraycombine( spawnable_weapon_spawns, getstructarray( "bowie_upgrade", "targetname" ), 1, 0 );
	spawnable_weapon_spawns = arraycombine( spawnable_weapon_spawns, getstructarray( "sickle_upgrade", "targetname" ), 1, 0 );
	spawnable_weapon_spawns = arraycombine( spawnable_weapon_spawns, getstructarray( "tazer_upgrade", "targetname" ), 1, 0 );
	spawnable_weapon_spawns = arraycombine( spawnable_weapon_spawns, getstructarray( "buildable_wallbuy", "targetname" ), 1, 0 );
	if ( !is_true( level.headshots_only ) )
	{
		spawnable_weapon_spawns = arraycombine( spawnable_weapon_spawns, getstructarray( "claymore_purchase", "targetname" ), 1, 0 );
	}
	match_string = "";
	location = level.scr_zm_map_start_location;
	if ( location == "default" || location == "" && isDefined( level.default_start_location ) )
	{
		location = level.default_start_location;
	}
	match_string = level.scr_zm_ui_gametype;
	if ( location != "" )
	{
		match_string = match_string + "_" + location;
	}
	match_string_plus_space = " " + match_string;
	i = 0;
	while ( i < spawnable_weapon_spawns.size )
	{
		spawnable_weapon = spawnable_weapon_spawns[ i ];
		if ( isDefined( spawnable_weapon.zombie_weapon_upgrade ) && spawnable_weapon.zombie_weapon_upgrade == "sticky_grenade_zm" && is_true( level.headshots_only ) )
		{
			i++;
			continue;
		}
		if ( !isDefined( spawnable_weapon.script_noteworthy ) || spawnable_weapon.script_noteworthy == "" )
		{
			spawn_list[ spawn_list.size ] = spawnable_weapon;
			i++;
			continue;
		}
		matches = strtok( spawnable_weapon.script_noteworthy, "," );
		for ( j = 0; j < matches.size; j++ )
		{
			if ( matches[ j ] == match_string || matches[ j ] == match_string_plus_space )
			{
				spawn_list[ spawn_list.size ] = spawnable_weapon;
			}
		}
		i++;
	}
	tempmodel = spawn( "script_model", ( 0, 0, 0 ) );
	i = 0;
	while ( i < spawn_list.size )
	{
		clientfieldname = spawn_list[ i ].zombie_weapon_upgrade + "_" + spawn_list[ i ].origin;
		numbits = 2;
		if ( isDefined( level._wallbuy_override_num_bits ) )
		{
			numbits = level._wallbuy_override_num_bits;
		}
		registerclientfield( "world", clientfieldname, 1, numbits, "int" );
		target_struct = getstruct( spawn_list[ i ].target, "targetname" );
		if ( spawn_list[ i ].targetname == "buildable_wallbuy" )
		{
			bits = 4;
			if ( isDefined( level.buildable_wallbuy_weapons ) )
			{
				bits = getminbitcountfornum( level.buildable_wallbuy_weapons.size + 1 );
			}
			registerclientfield( "world", clientfieldname + "_idx", 12000, bits, "int" );
			spawn_list[ i ].clientfieldname = clientfieldname;
			i++;
			continue;
		}
		precachemodel( target_struct.model );
		unitrigger_stub = spawnstruct();
		unitrigger_stub.origin = spawn_list[ i ].origin;
		unitrigger_stub.angles = spawn_list[ i ].angles;
		tempmodel.origin = spawn_list[ i ].origin;
		tempmodel.angles = spawn_list[ i ].angles;
		mins = undefined;
		maxs = undefined;
		absmins = undefined;
		absmaxs = undefined;
		tempmodel setmodel( target_struct.model );
		tempmodel useweaponhidetags( spawn_list[ i ].zombie_weapon_upgrade );
		mins = tempmodel getmins();
		maxs = tempmodel getmaxs();
		absmins = tempmodel getabsmins();
		absmaxs = tempmodel getabsmaxs();
		bounds = absmaxs - absmins;
		unitrigger_stub.script_length = bounds[ 0 ] * 0.25;
		unitrigger_stub.script_width = bounds[ 1 ];
		unitrigger_stub.script_height = bounds[ 2 ];
		unitrigger_stub.origin -= anglesToRight( unitrigger_stub.angles ) * ( unitrigger_stub.script_length * 0.4 );
		unitrigger_stub.target = spawn_list[ i ].target;
		unitrigger_stub.targetname = spawn_list[ i ].targetname;
		unitrigger_stub.cursor_hint = "HINT_NOICON";
		if ( spawn_list[ i ].targetname == "weapon_upgrade" )
		{
			unitrigger_stub.cost = get_weapon_cost( spawn_list[ i ].zombie_weapon_upgrade );
			if ( !is_true( level.monolingustic_prompt_format ) )
			{
				unitrigger_stub.hint_string = get_weapon_hint( spawn_list[ i ].zombie_weapon_upgrade );
				unitrigger_stub.hint_parm1 = unitrigger_stub.cost;
			}
			else
			{
				unitrigger_stub.hint_parm1 = get_weapon_display_name( spawn_list[ i ].zombie_weapon_upgrade );
				if ( !isDefined( unitrigger_stub.hint_parm1 ) || unitrigger_stub.hint_parm1 == "" || unitrigger_stub.hint_parm1 == "none" )
				{
					unitrigger_stub.hint_parm1 = "missing weapon name " + spawn_list[ i ].zombie_weapon_upgrade;
				}
				unitrigger_stub.hint_parm2 = unitrigger_stub.cost;
				unitrigger_stub.hint_string = &"ZOMBIE_WEAPONCOSTONLY";
			}
		}
		unitrigger_stub.weapon_upgrade = spawn_list[ i ].zombie_weapon_upgrade;
		unitrigger_stub.script_unitrigger_type = "unitrigger_box_use";
		unitrigger_stub.require_look_at = 1;
		if ( isDefined( spawn_list[ i ].require_look_from ) && spawn_list[ i ].require_look_from )
		{
			unitrigger_stub.require_look_from = 1;
		}
		unitrigger_stub.zombie_weapon_upgrade = spawn_list[ i ].zombie_weapon_upgrade;
		unitrigger_stub.clientfieldname = clientfieldname;
		maps/mp/zombies/_zm_unitrigger::unitrigger_force_per_player_triggers( unitrigger_stub, 1 );
		if ( is_melee_weapon( unitrigger_stub.zombie_weapon_upgrade ) )
		{
			if ( unitrigger_stub.zombie_weapon_upgrade == "tazer_knuckles_zm" && isDefined( level.taser_trig_adjustment ) )
			{
				unitrigger_stub.origin += level.taser_trig_adjustment;
			}
			maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( unitrigger_stub, ::weapon_spawn_think );
		}
		else if ( unitrigger_stub.zombie_weapon_upgrade == "claymore_zm" )
		{
			unitrigger_stub.prompt_and_visibility_func = ::claymore_unitrigger_update_prompt;
			maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( unitrigger_stub, ::buy_claymores );
		}
		else
		{
			unitrigger_stub.prompt_and_visibility_func = ::wall_weapon_update_prompt;
			maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( unitrigger_stub, ::weapon_spawn_think );
		}
		spawn_list[ i ].trigger_stub = unitrigger_stub;
		i++;
	}
	level._spawned_wallbuys = spawn_list;
	tempmodel delete();
}

add_dynamic_wallbuy( weapon, wallbuy, pristine ) //checked partially changed to match cerberus output
{
	spawned_wallbuy = undefined;
	for ( i = 0; i < level._spawned_wallbuys.size; i++ )
	{
		if ( level._spawned_wallbuys[ i ].target == wallbuy )
		{
			spawned_wallbuy = level._spawned_wallbuys[ i ];
			break;
		}
	}
	if ( !isDefined( spawned_wallbuy ) )
	{
		return;
	}
	if ( isDefined( spawned_wallbuy.trigger_stub ) )
	{
		return;
	}
	target_struct = getstruct( wallbuy, "targetname" );
	wallmodel = spawn_weapon_model( weapon, undefined, target_struct.origin, target_struct.angles );
	clientfieldname = spawned_wallbuy.clientfieldname;
	model = getweaponmodel( weapon );
	unitrigger_stub = spawnstruct();
	unitrigger_stub.origin = target_struct.origin;
	unitrigger_stub.angles = target_struct.angles;
	wallmodel.origin = target_struct.origin;
	wallmodel.angles = target_struct.angles;
	mins = undefined;
	maxs = undefined;
	absmins = undefined;
	absmaxs = undefined;
	wallmodel setmodel( model );
	wallmodel useweaponhidetags( weapon );
	mins = wallmodel getmins();
	maxs = wallmodel getmaxs();
	absmins = wallmodel getabsmins();
	absmaxs = wallmodel getabsmaxs();
	bounds = absmaxs - absmins;
	unitrigger_stub.script_length = bounds[ 0 ] * 0.25;
	unitrigger_stub.script_width = bounds[ 1 ];
	unitrigger_stub.script_height = bounds[ 2 ];
	unitrigger_stub.origin -= anglesToRight( unitrigger_stub.angles ) * ( unitrigger_stub.script_length * 0.4 );
	unitrigger_stub.target = spawned_wallbuy.target;
	unitrigger_stub.targetname = "weapon_upgrade";
	unitrigger_stub.cursor_hint = "HINT_NOICON";
	unitrigger_stub.first_time_triggered = !pristine;
	if ( !is_melee_weapon( weapon ) )
	{
		if ( pristine || weapon == "claymore_zm" )
		{
			unitrigger_stub.hint_string = get_weapon_hint( weapon );
		}
		else
		{
			unitrigger_stub.hint_string = get_weapon_hint_ammo();
		}
		unitrigger_stub.cost = get_weapon_cost( weapon );
		unitrigger_stub.hint_parm1 = unitrigger_stub.cost;
	}
	unitrigger_stub.weapon_upgrade = weapon;
	unitrigger_stub.script_unitrigger_type = "unitrigger_box_use";
	unitrigger_stub.require_look_at = 1;
	unitrigger_stub.zombie_weapon_upgrade = weapon;
	unitrigger_stub.clientfieldname = clientfieldname;
	maps/mp/zombies/_zm_unitrigger::unitrigger_force_per_player_triggers( unitrigger_stub, 1 );
	if ( is_melee_weapon( weapon ) )
	{
		if ( weapon == "tazer_knuckles_zm" && isDefined( level.taser_trig_adjustment ) )
		{
			unitrigger_stub.origin += level.taser_trig_adjustment;
		}
		maps/mp/zombies/_zm_melee_weapon::add_stub( unitrigger_stub, weapon );
		maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( unitrigger_stub, ::melee_weapon_think );
	}
	else if ( weapon == "claymore_zm" )
	{
		unitrigger_stub.prompt_and_visibility_func = ::claymore_unitrigger_update_prompt;
		maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( unitrigger_stub, ::buy_claymores );
	}
	else
	{
		unitrigger_stub.prompt_and_visibility_func = ::wall_weapon_update_prompt;
		maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( unitrigger_stub, ::weapon_spawn_think );
	}
	spawned_wallbuy.trigger_stub = unitrigger_stub;
	weaponidx = undefined;
	if ( isDefined( level.buildable_wallbuy_weapons ) )
	{
		for ( i = 0; i < level.buildable_wallbuy_weapons.size; i++ )
		{
			if ( weapon == level.buildable_wallbuy_weapons[ i ] )
			{
				weaponidx = i;
				break;
			}
		}
	}
	if ( isDefined( weaponidx ) )
	{
		level setclientfield( clientfieldname + "_idx", weaponidx + 1 );
		wallmodel delete();
		if ( !pristine )
		{
			level setclientfield( clientfieldname, 1 );
		}
	}
	else
	{
		level setclientfield( clientfieldname, 1 );
		wallmodel show();
	}
}

wall_weapon_update_prompt( player ) //checked partially changed to match cerberus output //partially changed at own discretion
{
	weapon = self.stub.zombie_weapon_upgrade;
	if ( isDefined( level.monolingustic_prompt_format ) && !level.monolingustic_prompt_format )
	{
		player_has_weapon = player has_weapon_or_upgrade( weapon );
		if ( !player_has_weapon && is_true( level.weapons_using_ammo_sharing ) )
		{
			shared_ammo_weapon = player get_shared_ammo_weapon( self.zombie_weapon_upgrade );
			if ( isDefined( shared_ammo_weapon ) )
			{
				weapon = shared_ammo_weapon;
				player_has_weapon = 1;
			}
		}
		if ( !player_has_weapon )
		{
			cost = get_weapon_cost( weapon );
			self.stub.hint_string = get_weapon_hint( weapon );
			self sethintstring( self.stub.hint_string, cost );
		}
		else if ( is_true( level.use_legacy_weapon_prompt_format ) )
		{
			cost = get_weapon_cost( weapon );
			ammo_cost = get_ammo_cost( weapon );
			self.stub.hint_string = get_weapon_hint_ammo();
			self sethintstring( self.stub.hint_string, cost, ammo_cost );
		}
		else if ( player has_upgrade( weapon ) )
		{
			ammo_cost = get_upgraded_ammo_cost( weapon );
		}
		else
		{
			ammo_cost = get_ammo_cost( weapon );
		}
		self.stub.hint_string = &"ZOMBIE_WEAPONAMMOONLY";
		self sethintstring( self.stub.hint_string, ammo_cost );
	}
	else if ( !player has_weapon_or_upgrade( weapon ) )
	{
		string_override = 0;
		if ( is_true( player.pers_upgrades_awarded[ "nube" ] ) )
		{
			string_override = maps/mp/zombies/_zm_pers_upgrades_functions::pers_nube_ammo_hint_string( player, weapon );
		}
		if ( !string_override )
		{
			cost = get_weapon_cost( weapon );
			weapon_display = get_weapon_display_name( weapon );
			if ( !isDefined( weapon_display ) || weapon_display == "" || weapon_display == "none" )
			{
				weapon_display = "missing weapon name " + weapon;
			}
			self.stub.hint_string = &"ZOMBIE_WEAPONCOSTONLY";
			self sethintstring( self.stub.hint_string, weapon_display, cost );
		}
	}
	else if ( player has_upgrade( weapon ) )
	{
		ammo_cost = get_upgraded_ammo_cost( weapon );
	}
	else
	{
		ammo_cost = get_ammo_cost( weapon );
	}
	self.stub.hint_string = &"ZOMBIE_WEAPONAMMOONLY";
	self sethintstring( self.stub.hint_string, ammo_cost );
	self.stub.cursor_hint = "HINT_WEAPON";
	self.stub.cursor_hint_weapon = weapon;
	self setcursorhint( self.stub.cursor_hint, self.stub.cursor_hint_weapon );
	return 1;
}

reset_wallbuy_internal( set_hint_string ) //checked matches cerberus output
{
	if ( isDefined( self.first_time_triggered ) && self.first_time_triggered == 1 )
	{
		self.first_time_triggered = 0;
		if ( isDefined( self.clientfieldname ) )
		{
			level setclientfield( self.clientfieldname, 0 );
		}
		if ( set_hint_string )
		{
			hint_string = get_weapon_hint( self.zombie_weapon_upgrade );
			cost = get_weapon_cost( self.zombie_weapon_upgrade );
			self sethintstring( hint_string, cost );
		}
	}
}

reset_wallbuys() //checked changed to match cerberus output
{
	weapon_spawns = [];
	weapon_spawns = getentarray( "weapon_upgrade", "targetname" );
	melee_and_grenade_spawns = [];
	melee_and_grenade_spawns = getentarray( "bowie_upgrade", "targetname" );
	melee_and_grenade_spawns = arraycombine( melee_and_grenade_spawns, getentarray( "sickle_upgrade", "targetname" ), 1, 0 );
	melee_and_grenade_spawns = arraycombine( melee_and_grenade_spawns, getentarray( "tazer_upgrade", "targetname" ), 1, 0 );
	if ( !is_true( level.headshots_only ) )
	{
		melee_and_grenade_spawns = arraycombine( melee_and_grenade_spawns, getentarray( "claymore_purchase", "targetname" ), 1, 0 );
	}
	for ( i = 0; i < weapon_spawns.size; i++ )
	{
		weapon_spawns[ i ] reset_wallbuy_internal( 1 );
	}
	for ( i = 0; i < melee_and_grenade_spawns.size; i++ )
	{
		melee_and_grenade_spawns[ i ] reset_wallbuy_internal( 0 );
	}
	if ( isDefined( level._unitriggers ) )
	{
		candidates = [];
		for ( i = 0; i < level._unitriggers.trigger_stubs.size; i++ )
		{
			stub = level._unitriggers.trigger_stubs[ i ];
			tn = stub.targetname;
			if ( tn == "weapon_upgrade" || tn == "bowie_upgrade" || tn == "sickle_upgrade" || tn == "tazer_upgrade" || tn == "claymore_purchase" )
			{
				stub.first_time_triggered = 0;
				if ( isDefined( stub.clientfieldname ) )
				{
					level setclientfield( stub.clientfieldname, 0 );
				}
				if ( tn == "weapon_upgrade" )
				{
					stub.hint_string = get_weapon_hint( stub.zombie_weapon_upgrade );
					stub.cost = get_weapon_cost( stub.zombie_weapon_upgrade );
					stub.hint_parm1 = stub.cost;
				}
			}
		}
	}
}

init_weapon_upgrade() //checked changed to match cerberus output
{
	init_spawnable_weapon_upgrade(); 
	weapon_spawns = [];
	weapon_spawns = getentarray( "weapon_upgrade", "targetname" );
	for ( i = 0; i < weapon_spawns.size; i++ )
	{
		if ( !is_true( level.monolingustic_prompt_format ) )
		{
			hint_string = get_weapon_hint( weapon_spawns[ i ].zombie_weapon_upgrade );
			cost = get_weapon_cost( weapon_spawns[ i ].zombie_weapon_upgrade );
			weapon_spawns[ i ] sethintstring( hint_string, cost );
			weapon_spawns[ i ] setcursorhint( "HINT_NOICON" );
		}
		else
		{
			cost = get_weapon_cost( weapon_spawns[ i ].zombie_weapon_upgrade );
			weapon_display = get_weapon_display_name( weapon_spawns[ i ].zombie_weapon_upgrade );
			if ( !isDefined( weapon_display ) || weapon_display == "" || weapon_display == "none" )
			{
				weapon_display = "missing weapon name " + weapon_spawns[ i ].zombie_weapon_upgrade;
			}
			hint_string = &"ZOMBIE_WEAPONCOSTONLY";
			weapon_spawns[ i ] sethintstring( hint_string, weapon_display, cost );
		}
		weapon_spawns[ i ] usetriggerrequirelookat();
		weapon_spawns[ i ] thread weapon_spawn_think();
		model = getent( weapon_spawns[ i ].target, "targetname" );
		if ( isDefined( model ) )
		{
			model useweaponhidetags( weapon_spawns[ i ].zombie_weapon_upgrade );
			model hide();
		}
	}
}

init_weapon_toggle() //checked changed to match cerberus output
{
	if ( !isDefined( level.magic_box_weapon_toggle_init_callback ) )
	{
		return;
	}
	level.zombie_weapon_toggles = [];
	level.zombie_weapon_toggle_max_active_count = 0;
	level.zombie_weapon_toggle_active_count = 0;
	precachestring( &"ZOMBIE_WEAPON_TOGGLE_DISABLED" );
	precachestring( &"ZOMBIE_WEAPON_TOGGLE_ACTIVATE" );
	precachestring( &"ZOMBIE_WEAPON_TOGGLE_DEACTIVATE" );
	precachestring( &"ZOMBIE_WEAPON_TOGGLE_ACQUIRED" );
	level.zombie_weapon_toggle_disabled_hint = &"ZOMBIE_WEAPON_TOGGLE_DISABLED";
	level.zombie_weapon_toggle_activate_hint = &"ZOMBIE_WEAPON_TOGGLE_ACTIVATE";
	level.zombie_weapon_toggle_deactivate_hint = &"ZOMBIE_WEAPON_TOGGLE_DEACTIVATE";
	level.zombie_weapon_toggle_acquired_hint = &"ZOMBIE_WEAPON_TOGGLE_ACQUIRED";
	precachemodel( "zombie_zapper_cagelight" );
	precachemodel( "zombie_zapper_cagelight_green" );
	precachemodel( "zombie_zapper_cagelight_red" );
	precachemodel( "zombie_zapper_cagelight_on" );
	level.zombie_weapon_toggle_disabled_light = "zombie_zapper_cagelight";
	level.zombie_weapon_toggle_active_light = "zombie_zapper_cagelight_green";
	level.zombie_weapon_toggle_inactive_light = "zombie_zapper_cagelight_red";
	level.zombie_weapon_toggle_acquired_light = "zombie_zapper_cagelight_on";
	weapon_toggle_ents = [];
	weapon_toggle_ents = getentarray( "magic_box_weapon_toggle", "targetname" );
	for ( i = 0; i < weapon_toggle_ents.size; i++ )
	{
		struct = spawnstruct();
		struct.trigger = weapon_toggle_ents[ i ];
		struct.weapon_name = struct.trigger.script_string;
		struct.upgrade_name = level.zombie_weapons[ struct.trigger.script_string ].upgrade_name;
		struct.enabled = 0;
		struct.active = 0;
		struct.acquired = 0;
		target_array = [];
		target_array = getentarray( struct.trigger.target, "targetname" );
		for ( j = 0; j < target_array.size; j++ )
		{
			switch( target_array[ j ].script_string )
			{
				case "light":
					struct.light = target_array[ j ];
					struct.light setmodel( level.zombie_weapon_toggle_disabled_light );
					break;
				case "weapon":
					struct.weapon_model = target_array[ j ];
					struct.weapon_model hide();
					break;
			}
		}
		struct.trigger sethintstring( level.zombie_weapon_toggle_disabled_hint );
		struct.trigger setcursorhint( "HINT_NOICON" );
		struct.trigger usetriggerrequirelookat();
		struct thread weapon_toggle_think();
		level.zombie_weapon_toggles[ struct.weapon_name ] = struct;
	}
	level thread [[ level.magic_box_weapon_toggle_init_callback ]]();
}

get_weapon_toggle( weapon_name ) //checked changed to match cerberus output
{
	if ( !isDefined( level.zombie_weapon_toggles ) )
	{
		return undefined;
	}
	if ( isDefined( level.zombie_weapon_toggles[ weapon_name ] ) )
	{
		return level.zombie_weapon_toggles[ weapon_name ];
	}
	keys = getarraykeys( level.zombie_weapon_toggles );
	for ( i = 0; i < keys.size; i++ )
	{
		if ( weapon_name == level.zombie_weapon_toggles[ keys[ i ] ].upgrade_name )
		{
			return level.zombie_weapon_toggles[ keys[ i ] ];
		}
	}
	return undefined;
}

is_weapon_toggle( weapon_name ) //checked matches cerberus output
{
	return isDefined( get_weapon_toggle( weapon_name ) );
}

disable_weapon_toggle( weapon_name ) //checked matches cerberus output
{
	toggle = get_weapon_toggle( weapon_name );
	if ( !isDefined( toggle ) )
	{
		return;
	}
	if ( toggle.active )
	{
		level.zombie_weapon_toggle_active_count--;

	}
	toggle.enabled = 0;
	toggle.active = 0;
	toggle.light setmodel( level.zombie_weapon_toggle_disabled_light );
	toggle.weapon_model hide();
	toggle.trigger sethintstring( level.zombie_weapon_toggle_disabled_hint );
}

enable_weapon_toggle( weapon_name ) //checked matches cerberus output
{
	toggle = get_weapon_toggle( weapon_name );
	if ( !isDefined( toggle ) )
	{
		return;
	}
	toggle.enabled = 1;
	toggle.weapon_model show();
	toggle.weapon_model useweaponhidetags( weapon_name );
	deactivate_weapon_toggle( weapon_name );
}

activate_weapon_toggle( weapon_name, trig_for_vox ) //checked matches cerberus output
{
	if ( level.zombie_weapon_toggle_active_count >= level.zombie_weapon_toggle_max_active_count )
	{
		if ( isDefined( trig_for_vox ) )
		{
			trig_for_vox thread maps/mp/zombies/_zm_audio::weapon_toggle_vox( "max" );
		}
		return;
	}
	toggle = get_weapon_toggle( weapon_name );
	if ( !isDefined( toggle ) )
	{
		return;
	}
	if ( isDefined( trig_for_vox ) )
	{
		trig_for_vox thread maps/mp/zombies/_zm_audio::weapon_toggle_vox( "activate", weapon_name );
	}
	level.zombie_weapon_toggle_active_count++;
	toggle.active = 1;
	toggle.light setmodel( level.zombie_weapon_toggle_active_light );
	toggle.trigger sethintstring( level.zombie_weapon_toggle_deactivate_hint );
}

deactivate_weapon_toggle( weapon_name, trig_for_vox ) //checked matches cerberus output
{
	toggle = get_weapon_toggle( weapon_name );
	if ( !isDefined( toggle ) )
	{
		return;
	}
	if ( isDefined( trig_for_vox ) )
	{
		trig_for_vox thread maps/mp/zombies/_zm_audio::weapon_toggle_vox( "deactivate", weapon_name );
	}
	if ( toggle.active )
	{
		level.zombie_weapon_toggle_active_count--;

	}
	toggle.active = 0;
	toggle.light setmodel( level.zombie_weapon_toggle_inactive_light );
	toggle.trigger sethintstring( level.zombie_weapon_toggle_activate_hint );
}

acquire_weapon_toggle( weapon_name, player ) //checked matches cerberus output
{
	toggle = get_weapon_toggle( weapon_name );
	if ( !isDefined( toggle ) )
	{
		return;
	}
	if ( !toggle.active || toggle.acquired )
	{
		return;
	}
	toggle.acquired = 1;
	toggle.light setmodel( level.zombie_weapon_toggle_acquired_light );
	toggle.trigger sethintstring( level.zombie_weapon_toggle_acquired_hint );
	toggle thread unacquire_weapon_toggle_on_death_or_disconnect_thread( player );
}

unacquire_weapon_toggle_on_death_or_disconnect_thread( player ) //checked matches cerberus output
{
	self notify( "end_unacquire_weapon_thread" );
	self endon( "end_unacquire_weapon_thread" );
	player waittill_any( "spawned_spectator", "disconnect" );
	unacquire_weapon_toggle( self.weapon_name );
}

unacquire_weapon_toggle( weapon_name ) //checked matches cerberus output
{
	toggle = get_weapon_toggle( weapon_name );
	if ( !isDefined( toggle ) )
	{
		return;
	}
	if ( !toggle.active || !toggle.acquired )
	{
		return;
	}
	toggle.acquired = 0;
	toggle.light setmodel( level.zombie_weapon_toggle_active_light );
	toggle.trigger sethintstring( level.zombie_weapon_toggle_deactivate_hint );
	toggle notify( "end_unacquire_weapon_thread" );
}

weapon_toggle_think() //checked changed to match cerberus output
{
	for ( ;; )
	{
		self.trigger waittill( "trigger", player );
		if ( !is_player_valid( player ) )
		{
			player thread ignore_triggers( 0.5 );
			continue;
		}
		if ( !self.enabled || self.acquired )
		{
			self.trigger thread maps/mp/zombies/_zm_audio::weapon_toggle_vox( "max" );
			continue;
		}
		if ( !self.active )
		{
			activate_weapon_toggle( self.weapon_name, self.trigger );
			break;
		}
		deactivate_weapon_toggle( self.weapon_name, self.trigger );
	}
}

get_weapon_hint( weapon_name ) //checked matches cerberus output
{
	return level.zombie_weapons[ weapon_name ].hint;
}

get_weapon_cost( weapon_name ) //checked matches cerberus output
{
	return level.zombie_weapons[ weapon_name ].cost;
}

get_ammo_cost( weapon_name ) //checked matches cerberus output
{
	return level.zombie_weapons[ weapon_name ].ammo_cost;
}

get_upgraded_ammo_cost( weapon_name ) //checked matches cerberus output
{
	if ( isDefined( level.zombie_weapons[ weapon_name ].upgraded_ammo_cost ) )
	{
		return level.zombie_weapons[ weapon_name ].upgraded_ammo_cost;
	}
	return 4500;
}

get_weapon_display_name( weapon_name ) //checked changed to match cerberus output
{
	weapon_display = getweapondisplayname( weapon_name );
	if ( !isDefined( weapon_display ) || weapon_display == "" || weapon_display == "none" )
	{
		weapon_display = &"MPUI_NONE";
	}
	return weapon_display;
}

get_is_in_box( weapon_name ) //checked matches cerberus output
{
	return level.zombie_weapons[ weapon_name ].is_in_box;
}

weapon_supports_default_attachment( weaponname ) //checked matches cerberus output
{
	weaponname = get_base_weapon_name( weaponname );
	if ( isDefined( weaponname ) )
	{
		attachment = level.zombie_weapons[ weaponname ].default_attachment;
	}
	return isDefined( attachment );
}

default_attachment( weaponname ) //checked matches cerberus output
{
	weaponname = get_base_weapon_name( weaponname );
	if ( isDefined( weaponname ) )
	{
		attachment = level.zombie_weapons[ weaponname ].default_attachment;
	}
	if ( isDefined( attachment ) )
	{
		return attachment;
	}
	else
	{
		return "none";
	}
}

weapon_supports_attachments( weaponname ) //checked changed at own discretion
{
	weaponname = get_base_weapon_name( weaponname );
	if ( isDefined( weaponname ) )
	{
		attachments = level.zombie_weapons[ weaponname ].addon_attachments;
	}
	if ( isDefined( attachments ) && attachments.size > 0 ) //was 1
	{
		return 1;
	}
	return 0;
}

random_attachment( weaponname, exclude ) //checked changed to match cerberus output
{
	lo = 0;
	if ( isDefined( level.zombie_weapons[ weaponname ].addon_attachments ) && level.zombie_weapons[ weaponname ].addon_attachments.size > 0 )
	{
		attachments = level.zombie_weapons[ weaponname ].addon_attachments;
	}
	else
	{
		attachments = getweaponsupportedattachments( weaponname );
		lo = 1;
	}
	minatt = lo;
	if ( isDefined( exclude ) && exclude != "none" )
	{
		minatt = lo + 1;
	}
	if ( attachments.size > minatt )
	{
		while ( 1 )
		{
			idx = randomint( attachments.size - lo ) + lo;
			if ( !isDefined( exclude ) || attachments[ idx ] != exclude )
			{
				return attachments[ idx ];
			}
		}
	}
	return "none";
}

get_base_name( weaponname ) //checked matches cerberus output
{
	split = strtok( weaponname, "+" );
	if ( split.size > 1 )
	{
		return split[ 0 ];
	}
	return weaponname;
}

get_attachment_name( weaponname, att_id ) //checked changed to match cerberus output
{
	split = strtok( weaponname, "+" );
	if ( isDefined( att_id ) )
	{
		attachment = att_id + 1;
		if ( split.size > attachment )
		{
			return split[ attachment ];
		}
	}
	else if ( split.size > 1 )
	{
		att = split[ 1 ];
		for ( idx = 2; split.size > idx; idx++ )
		{
			att = ( att + "+" ) + split[ idx ];
		}
		return att;
	}
	return undefined;
}

get_attachment_index( weapon ) //checked changed to match cerberus output
{
	att = get_attachment_name( weapon );
	if ( att == "none" )
	{
		return -1;
	}
	base = get_base_name( weapon );
	if ( att == level.zombie_weapons[ base ].default_attachment )
	{
		return 0;
	}
	if ( isDefined( level.zombie_weapons[ base ].addon_attachments ) )
	{
		for ( i = 0; i < level.zombie_weapons[base].addon_attachments.size; i++ )
		{
			if ( level.zombie_weapons[ base ].addon_attachments[ i ] == att )
			{
				return i + 1;
			}
		}
	}
	return -1;
}

weapon_supports_this_attachment( weapon, att ) //checked changed to match cerberus output
{
	base = get_base_name( weapon );
	if ( att == level.zombie_weapons[ base ].default_attachment )
	{
		return 1;
	}
	if ( isDefined( level.zombie_weapons[ base ].addon_attachments ) )
	{
		for(i = 0; i < level.zombie_weapons[base].addon_attachments.size; i++)
		{
			if ( level.zombie_weapons[ base ].addon_attachments[ i ] == att )
			{
				return 1;
			}
		}
	}
	return 0;
}

has_attachment( weaponname, att ) //checked matches cerberus output
{
	split = strtok( weaponname, "+" );
	idx = 1;
	while ( split.size > idx )
	{
		if ( att == split[ idx ] )
		{
			return 1;
		}
	}
	return 0;
}

get_base_weapon_name( upgradedweaponname, base_if_not_upgraded ) //checked matches cerberus output
{
	if ( !isDefined( upgradedweaponname ) || upgradedweaponname == "" )
	{
		return undefined;
	}
	upgradedweaponname = tolower( upgradedweaponname );
	upgradedweaponname = get_base_name( upgradedweaponname );
	if ( isDefined( level.zombie_weapons_upgraded[ upgradedweaponname ] ) )
	{
		return level.zombie_weapons_upgraded[ upgradedweaponname ];
	}
	if ( isDefined( base_if_not_upgraded ) && base_if_not_upgraded )
	{
		return upgradedweaponname;
	}
	return undefined;
}

get_upgrade_weapon( weaponname, add_attachment ) //checked changed to match cerberus output
{
	rootweaponname = tolower( weaponname );
	rootweaponname = get_base_name( rootweaponname );
	baseweaponname = get_base_weapon_name( rootweaponname, 1 );
	newweapon = rootweaponname;
	if ( !is_weapon_upgraded( rootweaponname ) )
	{
		newweapon = level.zombie_weapons[ rootweaponname ].upgrade_name;
	}
	if ( is_true( add_attachment ) && is_true( level.zombiemode_reusing_pack_a_punch ) )
	{
		oldatt = get_attachment_name( weaponname );
		att = random_attachment( baseweaponname, oldatt );
		newweapon = newweapon + "+" + att;
	}
	else if ( isDefined( level.zombie_weapons[ rootweaponname ] ) && isDefined( level.zombie_weapons[ rootweaponname ].default_attachment ) )
	{
		att = level.zombie_weapons[ rootweaponname ].default_attachment;
		newweapon = newweapon + "+" + att;
	}
	return newweapon;
}

can_upgrade_weapon( weaponname ) //checked changed to match cerberus output
{
	if ( !isDefined( weaponname ) || weaponname == "" || weaponname == "zombie_fists_zm" )
	{
		return 0;
	}
	weaponname = tolower( weaponname );
	weaponname = get_base_name( weaponname );
	if ( !is_weapon_upgraded( weaponname ) && isDefined( level.zombie_weapons[ weaponname ].upgrade_name ) )
	{
		return 1;
	}
	if ( is_true( level.zombiemode_reusing_pack_a_punch ) && weapon_supports_attachments( weaponname ) )
	{
		return 1;
	}
	return 0;
}

will_upgrade_weapon_as_attachment( weaponname ) //checked changed to match cerberus output
{
	if ( !isDefined( weaponname ) || weaponname == "" || weaponname == "zombie_fists_zm" )
	{
		return 0;
	}
	weaponname = tolower( weaponname );
	weaponname = get_base_name( weaponname );
	if ( !is_weapon_upgraded( weaponname ) )
	{
		return 0;
	}
	if ( is_true( level.zombiemode_reusing_pack_a_punch ) && weapon_supports_attachments( weaponname ) )
	{
		return 1;
	}
	return 0;
}

is_weapon_upgraded( weaponname ) //checked changed to match cerberus output
{
	if ( !isDefined( weaponname ) || weaponname == "" || weaponname == "zombie_fists_zm" )
	{
		return 0;
	}
	weaponname = tolower( weaponname );
	weaponname = get_base_name( weaponname );
	if ( isDefined( level.zombie_weapons_upgraded[ weaponname ] ) )
	{
		return 1;
	}
	return 0;
}

get_weapon_with_attachments( weaponname ) //checked changed to match cerberus output
{
	if ( self hasweapon( weaponname ) )
	{
		return weaponname;
	}
	if ( is_true( level.zombiemode_reusing_pack_a_punch ) )
	{
		weaponname = tolower( weaponname );
		weaponname = get_base_name( weaponname );
		weapons = self getweaponslist( 1 );
		foreach ( weapon in weapons )
		{
			weapon = tolower( weapon );
			weapon_base = get_base_name( weapon );
			if ( weaponname == weapon_base )
			{
				return weapon;
			}
		}
	}
	return undefined;
}

has_weapon_or_attachments( weaponname ) //checked changed to match cerberus output
{
	if ( self hasweapon( weaponname ) )
	{
		return 1;
	}
	if ( is_true( level.zombiemode_reusing_pack_a_punch ) )
	{
		weaponname = tolower( weaponname );
		weaponname = get_base_name( weaponname );
		weapons = self getweaponslist( 1 );
		foreach ( weapon in weapons )
		{
			weapon = tolower( weapon );
			weapon = get_base_name( weapon );
			if ( weaponname == weapon )
			{
				return 1;
			}
		}
	}
	return 0;
}

has_upgrade( weaponname ) //checked matches cerberus output
{
	weaponname = get_base_name( weaponname );
	has_upgrade = 0;
	if ( isDefined( level.zombie_weapons[ weaponname ] ) && isDefined( level.zombie_weapons[ weaponname ].upgrade_name ) )
	{
		has_upgrade = self has_weapon_or_attachments( level.zombie_weapons[ weaponname ].upgrade_name );
	}
	if ( !has_upgrade && weaponname == "knife_ballistic_zm" )
	{
		has_weapon = self maps/mp/zombies/_zm_melee_weapon::has_upgraded_ballistic_knife();
	}
	return has_upgrade;
}

has_weapon_or_upgrade( weaponname ) //checked changed at own discretion
{
	weaponname = get_base_name( weaponname );
	upgradedweaponname = weaponname;
	if ( isDefined( level.zombie_weapons[ weaponname ] ) && isDefined( level.zombie_weapons[ weaponname ].upgrade_name ) )
	{
		upgradedweaponname = level.zombie_weapons[ weaponname ].upgrade_name;
	}
	has_weapon = 0;
	if ( isDefined( level.zombie_weapons[ weaponname ] ) )
	{
		if ( self has_weapon_or_attachments( weaponname ) || self has_upgrade( weaponname ) )
		{
			has_weapon = 1;
		}
	}
	if ( !has_weapon && weaponname == "knife_ballistic_zm" )
	{
		has_weapon = self maps/mp/zombies/_zm_melee_weapon::has_any_ballistic_knife();
	}
	if ( !has_weapon && is_equipment( weaponname ) )
	{
		has_weapon = self is_equipment_active( weaponname );
	}
	return has_weapon;
}

add_shared_ammo_weapon( str_weapon, str_base_weapon ) //checked matches cerberus output
{
	level.zombie_weapons[ str_weapon ].shared_ammo_weapon = str_base_weapon;
}

get_shared_ammo_weapon( base_weapon ) //checked changed to match cerberus output
{
	base_weapon = get_base_name( base_weapon );
	weapons = self getweaponslist( 1 );
	foreach ( weapon in weapons )
	{
		weapon = tolower( weapon );
		weapon = get_base_name( weapon );
		if ( !isdefined( level.zombie_weapons[ weapon ] ) && isdefined( level.zombie_weapons_upgraded[ weapon ] ) )
		{
			weapon = level.zombie_weapons_upgraded[ weapon ];
		}
		if ( isdefined( level.zombie_weapons[ weapon ] ) && isdefined( level.zombie_weapons[ weapon ].shared_ammo_weapon ) && level.zombie_weapons[ weapon ].shared_ammo_weapon == base_weapon )
		{
			return weapon;
		}
	}
	return undefined;
}

get_player_weapon_with_same_base( weaponname ) //checked changed tp match cerberus output
{
	weaponname = tolower( weaponname );
	weaponname = get_base_name( weaponname );
	retweapon = get_weapon_with_attachments( weaponname );
	if ( !isDefined( retweapon ) )
	{
		if ( isDefined( level.zombie_weapons[ weaponname ] ) )
		{
			retweapon = get_weapon_with_attachments( level.zombie_weapons[ weaponname ].upgrade_name );
		}
		else if ( isDefined( level.zombie_weapons_upgraded[ weaponname ] ) )
		{
			return get_weapon_with_attachments( level.zombie_weapons_upgraded[ weaponname ] );
		}
	}
	return retweapon;
}

get_weapon_hint_ammo() //checked matches cerberus output
{
	if ( !is_true( level.has_pack_a_punch ) )
	{
		return &"ZOMBIE_WEAPONCOSTAMMO";
	}
	else
	{
		return &"ZOMBIE_WEAPONCOSTAMMO_UPGRADE";
	}
}

weapon_set_first_time_hint( cost, ammo_cost ) //checked matches cerberus output
{
	self sethintstring( get_weapon_hint_ammo(), cost, ammo_cost );
}

weapon_spawn_think() //checked changed to match cerberus output
{
	cost = get_weapon_cost( self.zombie_weapon_upgrade );
	ammo_cost = get_ammo_cost( self.zombie_weapon_upgrade );
	is_grenade = weapontype( self.zombie_weapon_upgrade ) == "grenade";
	shared_ammo_weapon = undefined;
	second_endon = undefined;
	if ( isDefined( self.stub ) )
	{
		second_endon = "kill_trigger";
		self.first_time_triggered = self.stub.first_time_triggered;
	}
	if ( isDefined( self.stub ) && is_true( self.stub.trigger_per_player ) )
	{
		self thread decide_hide_show_hint( "stop_hint_logic", second_endon, self.parent_player );
	}
	else
	{
		self thread decide_hide_show_hint( "stop_hint_logic", second_endon );
	}
	if ( is_grenade )
	{
		self.first_time_triggered = 0;
		hint = get_weapon_hint( self.zombie_weapon_upgrade );
		self sethintstring( hint, cost );
	}
	else if ( !isDefined( self.first_time_triggered ) )
	{
		self.first_time_triggered = 0;
		if ( isDefined( self.stub ) )
		{
			self.stub.first_time_triggered = 0;
		}
	}
	else if ( self.first_time_triggered )
	{
		if ( is_true( level.use_legacy_weapon_prompt_format ) )
		{
			self weapon_set_first_time_hint( cost, get_ammo_cost( self.zombie_weapon_upgrade ) );
		}
	}
	for ( ;; )
	{
		self waittill( "trigger", player );
		if ( !is_player_valid( player ) )
		{
			player thread ignore_triggers( 0.5 );
			continue;
		}
		if ( !player can_buy_weapon() )
		{
			wait 0.1;
			continue;
		}
		if ( isDefined( self.stub ) && is_true( self.stub.require_look_from ) )
		{
			toplayer = player get_eye() - self.origin;
			forward = -1 * anglesToRight( self.angles );
			dot = vectordot( toplayer, forward );
			if ( dot < 0 )
			{
				continue;
			}
		}
		if ( player has_powerup_weapon() )
		{
			wait 0.1;
			continue;
		}
		player_has_weapon = player has_weapon_or_upgrade( self.zombie_weapon_upgrade );
		if ( !player_has_weapon && is_true( level.weapons_using_ammo_sharing ) )
		{
			shared_ammo_weapon = player get_shared_ammo_weapon( self.zombie_weapon_upgrade );
			if ( isDefined( shared_ammo_weapon ) )
			{
				player_has_weapon = 1;
			}
		}
		if ( is_true( level.pers_upgrade_nube ) )
		{
			player_has_weapon = maps/mp/zombies/_zm_pers_upgrades_functions::pers_nube_should_we_give_raygun( player_has_weapon, player, self.zombie_weapon_upgrade );
		}
		cost = get_weapon_cost( self.zombie_weapon_upgrade );
		if ( player maps/mp/zombies/_zm_pers_upgrades_functions::is_pers_double_points_active() )
		{
			cost = int( cost / 2 );
		}
		if ( !player_has_weapon )
		{
			if ( player.score >= cost )
			{
				if ( self.first_time_triggered == 0 )
				{
					self show_all_weapon_buys( player, cost, ammo_cost, is_grenade );
				}
				player maps/mp/zombies/_zm_score::minus_to_player_score( cost, 1 );
				bbprint( "zombie_uses", "playername %s playerscore %d round %d cost %d name %s x %f y %f z %f type %s", player.name, player.score, level.round_number, cost, self.zombie_weapon_upgrade, self.origin, "weapon" );
				level notify( "weapon_bought", player, self.zombie_weapon_upgrade );
				if ( self.zombie_weapon_upgrade == "riotshield_zm" )
				{
					player maps/mp/zombies/_zm_equipment::equipment_give( "riotshield_zm" );
					if ( isDefined( player.player_shield_reset_health ) )
					{
						player [[ player.player_shield_reset_health ]]();
					}
				}
				else if ( self.zombie_weapon_upgrade == "jetgun_zm" )
				{
					player maps/mp/zombies/_zm_equipment::equipment_give( "jetgun_zm" );
				}
				else if ( is_lethal_grenade( self.zombie_weapon_upgrade ) )
				{
					player takeweapon( player get_player_lethal_grenade() );
					player set_player_lethal_grenade( self.zombie_weapon_upgrade );
				}
				str_weapon = self.zombie_weapon_upgrade;
				if ( is_true( level.pers_upgrade_nube ) )
				{
					str_weapon = maps/mp/zombies/_zm_pers_upgrades_functions::pers_nube_weapon_upgrade_check( player, str_weapon );
				}
				player weapon_give( str_weapon );
				player maps/mp/zombies/_zm_stats::increment_client_stat( "wallbuy_weapons_purchased" );
				player maps/mp/zombies/_zm_stats::increment_player_stat( "wallbuy_weapons_purchased" );
			}
			else
			{
				play_sound_on_ent( "no_purchase" );
				player maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "no_money_weapon" );
			}
		}
		else
		{
			str_weapon = self.zombie_weapon_upgrade;
			if ( isDefined( shared_ammo_weapon ) )
			{
				str_weapon = shared_ammo_weapon;
			}
			if ( is_true( level.pers_upgrade_nube ) )
			{
				str_weapon = maps/mp/zombies/_zm_pers_upgrades_functions::pers_nube_weapon_ammo_check( player, str_weapon );
			}
			if ( is_true( self.hacked ) )
			{
				if ( !player has_upgrade( str_weapon ) )
				{
					ammo_cost = 4500;
				}
				else
				{
					ammo_cost = get_ammo_cost( str_weapon );
				}
			}
			else if ( player has_upgrade( str_weapon ) )
			{
				ammo_cost = 4500;
			}
			else
			{
				ammo_cost = get_ammo_cost( str_weapon );
			}
			if ( is_true( player.pers_upgrades_awarded[ "nube" ] ) )
			{
				ammo_cost = maps/mp/zombies/_zm_pers_upgrades_functions::pers_nube_override_ammo_cost( player, self.zombie_weapon_upgrade, ammo_cost );
			}
			if ( player maps/mp/zombies/_zm_pers_upgrades_functions::is_pers_double_points_active() )
			{
				ammo_cost = int( ammo_cost / 2 );
			}
			if ( str_weapon == "riotshield_zm" )
			{
				play_sound_on_ent( "no_purchase" );
			}
			else if ( player.score >= ammo_cost )
			{
				if ( self.first_time_triggered == 0 )
				{
					self show_all_weapon_buys( player, cost, ammo_cost, is_grenade );
				}
				if ( player has_upgrade( str_weapon ) )
				{
					player maps/mp/zombies/_zm_stats::increment_client_stat( "upgraded_ammo_purchased" );
					player maps/mp/zombies/_zm_stats::increment_player_stat( "upgraded_ammo_purchased" );
				}
				else
				{
					player maps/mp/zombies/_zm_stats::increment_client_stat( "ammo_purchased" );
					player maps/mp/zombies/_zm_stats::increment_player_stat( "ammo_purchased" );
				}
				if ( str_weapon == "riotshield_zm" )
				{
					if ( isDefined( player.player_shield_reset_health ) )
					{
						ammo_given = player [[ player.player_shield_reset_health ]]();
					}
					else
					{
						ammo_given = 0;
					}
				}
				else if ( player has_upgrade( str_weapon ) )
				{
					ammo_given = player ammo_give( level.zombie_weapons[ str_weapon ].upgrade_name );
				}
				else
				{
					ammo_given = player ammo_give( str_weapon );
				}
				if ( ammo_given )
				{
					player maps/mp/zombies/_zm_score::minus_to_player_score( ammo_cost, 1 );
					bbprint( "zombie_uses", "playername %s playerscore %d round %d cost %d name %s x %f y %f z %f type %s", player.name, player.score, level.round_number, ammo_cost, str_weapon, self.origin, "ammo" );
				}
			}
			else
			{
				play_sound_on_ent( "no_purchase" );
				if ( isDefined( level.custom_generic_deny_vo_func ) )
				{
					player [[ level.custom_generic_deny_vo_func ]]();
				}
				else
				{
					player maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "no_money_weapon" );
				}
			}
		}
		if ( isDefined( self.stub ) && isDefined( self.stub.prompt_and_visibility_func ) )
		{
			self [[ self.stub.prompt_and_visibility_func ]]( player );
		}
	}
}

show_all_weapon_buys( player, cost, ammo_cost, is_grenade ) //checked changed to match cerberus output
{
	model = getent( self.target, "targetname" );
	if ( isDefined( model ) )
	{
		model thread weapon_show( player );
	}
	else if ( isDefined( self.clientfieldname ) )
	{
		level setclientfield( self.clientfieldname, 1 );
	}
	self.first_time_triggered = 1;
	if ( isDefined( self.stub ) )
	{
		self.stub.first_time_triggered = 1;
	}
	if ( !is_grenade )
	{
		self weapon_set_first_time_hint( cost, ammo_cost );
	}
	if ( !is_true( level.dont_link_common_wallbuys ) && isDefined( level._spawned_wallbuys ) )
	{
		i = 0;
		while ( i < level._spawned_wallbuys.size )
		{
			wallbuy = level._spawned_wallbuys[ i ];
			if ( isDefined( self.stub ) && isDefined( wallbuy.trigger_stub ) && self.stub.clientfieldname == wallbuy.trigger_stub.clientfieldname )
			{
				i++;
				continue;
			}
			if ( self.zombie_weapon_upgrade == wallbuy.zombie_weapon_upgrade )
			{
				if ( isDefined( wallbuy.trigger_stub ) && isDefined( wallbuy.trigger_stub.clientfieldname ) )
				{
					level setclientfield( wallbuy.trigger_stub.clientfieldname, 1 );
				}
				else if ( isDefined( wallbuy.target ) )
				{
					model = getent( wallbuy.target, "targetname" );
					if ( isDefined( model ) )
					{
						model thread weapon_show( player );
					}
				}
				if ( isDefined( wallbuy.trigger_stub ) )
				{
					wallbuy.trigger_stub.first_time_triggered = 1;
					if ( isDefined( wallbuy.trigger_stub.trigger ) )
					{
						wallbuy.trigger_stub.trigger.first_time_triggered = 1;
						if ( !is_grenade )
						{
							wallbuy.trigger_stub.trigger weapon_set_first_time_hint( cost, ammo_cost );
						}
					}
					i++;
					continue;
				}
				if ( !is_grenade )
				{
					wallbuy weapon_set_first_time_hint( cost, ammo_cost );
				}
			}
			i++;
		}
	}
}

weapon_show( player ) //checked matches cerberus output
{
	player_angles = vectorToAngles( player.origin - self.origin );
	player_yaw = player_angles[ 1 ];
	weapon_yaw = self.angles[ 1 ];
	if ( isDefined( self.script_int ) )
	{
		weapon_yaw -= self.script_int;
	}
	yaw_diff = absAngleClamp180( player_yaw - weapon_yaw );
	if ( yaw_diff > 0 )
	{
		yaw = weapon_yaw - 90;
	}
	else
	{
		yaw = weapon_yaw + 90;
	}
	self.og_origin = self.origin;
	self.origin += anglesToForward( ( 0, yaw, 0 ) ) * 8;
	wait 0.05;
	self show();
	play_sound_at_pos( "weapon_show", self.origin, self );
	time = 1;
	if ( !isDefined( self._linked_ent ) )
	{
		self moveto( self.og_origin, time );
	}
}

get_pack_a_punch_weapon_options( weapon ) //checked changed to match cerberus output
{
	if ( !isDefined( self.pack_a_punch_weapon_options ) )
	{
		self.pack_a_punch_weapon_options = [];
	}
	if ( !is_weapon_upgraded( weapon ) )
	{
		return self calcweaponoptions( 0, 0, 0, 0, 0 );
	}
	if ( isDefined( self.pack_a_punch_weapon_options[ weapon ] ) )
	{
		return self.pack_a_punch_weapon_options[ weapon ];
	}
	smiley_face_reticle_index = 1;
	base = get_base_name( weapon );
	camo_index = 39;
	if ( level.script == "zm_prison" )
	{
		camo_index = 40;
	}
	else if ( level.script == "zm_tomb" )
	{
		camo_index = 45;
	}
	lens_index = randomintrange( 0, 6 );
	reticle_index = randomintrange( 0, 16 );
	reticle_color_index = randomintrange( 0, 6 );
	plain_reticle_index = 16;
	r = randomint( 10 );
	use_plain = r < 3;
	if ( base == "saritch_upgraded_zm" )
	{
		reticle_index = smiley_face_reticle_index;
	}
	else if ( use_plain )
	{
		reticle_index = plain_reticle_index;
	}
	scary_eyes_reticle_index = 8;
	purple_reticle_color_index = 3;
	if ( reticle_index == scary_eyes_reticle_index )
	{
		reticle_color_index = purple_reticle_color_index;
	}
	letter_a_reticle_index = 2;
	pink_reticle_color_index = 6;
	if ( reticle_index == letter_a_reticle_index )
	{
		reticle_color_index = pink_reticle_color_index;
	}
	letter_e_reticle_index = 7;
	green_reticle_color_index = 1;
	if ( reticle_index == letter_e_reticle_index )
	{
		reticle_color_index = green_reticle_color_index;
	}
	self.pack_a_punch_weapon_options[ weapon ] = self calcweaponoptions( camo_index, lens_index, reticle_index, reticle_color_index );
	return self.pack_a_punch_weapon_options[ weapon ];
}

weapon_give( weapon, is_upgrade, magic_box, nosound ) //checked changed to match cerberus output
{
	primaryweapons = self getweaponslistprimaries();
	current_weapon = self getcurrentweapon();
	current_weapon = self maps/mp/zombies/_zm_weapons::switch_from_alt_weapon( current_weapon );
	if ( !isDefined( is_upgrade ) )
	{
		is_upgrade = 0;
	}
	weapon_limit = get_player_weapon_limit( self );
	if ( is_equipment( weapon ) )
	{
		self maps/mp/zombies/_zm_equipment::equipment_give( weapon );
	}
	if ( weapon == "riotshield_zm" )
	{
		if ( isDefined( self.player_shield_reset_health ) )
		{
			self [[ self.player_shield_reset_health ]]();
		}
	}
	if ( self hasweapon( weapon ) )
	{
		if ( issubstr( weapon, "knife_ballistic_" ) )
		{
			self notify( "zmb_lost_knife" );
		}
		self givestartammo( weapon );
		if ( !is_offhand_weapon( weapon ) )
		{
			self switchtoweapon( weapon );
		}
		return;
	}
	if ( is_melee_weapon( weapon ) )
	{
		current_weapon = maps/mp/zombies/_zm_melee_weapon::change_melee_weapon( weapon, current_weapon );
	}
	else if ( is_lethal_grenade( weapon ) )
	{
		old_lethal = self get_player_lethal_grenade();
		if ( isDefined( old_lethal ) && old_lethal != "" )
		{
			self takeweapon( old_lethal );
			unacquire_weapon_toggle( old_lethal );
		}
		self set_player_lethal_grenade( weapon );
	}
	else if ( is_tactical_grenade( weapon ) )
	{
		old_tactical = self get_player_tactical_grenade();
		if ( isDefined( old_tactical ) && old_tactical != "" )
		{
			self takeweapon( old_tactical );
			unacquire_weapon_toggle( old_tactical );
		}
		self set_player_tactical_grenade( weapon );
	}
	else if ( is_placeable_mine( weapon ) )
	{
		old_mine = self get_player_placeable_mine();
		if ( isDefined( old_mine ) )
		{
			self takeweapon( old_mine );
			unacquire_weapon_toggle( old_mine );
		}
		self set_player_placeable_mine( weapon );
	}
	if ( !is_offhand_weapon( weapon ) )
	{
		self maps/mp/zombies/_zm_weapons::take_fallback_weapon();
	}
	if ( primaryweapons.size >= weapon_limit )
	{
		if ( is_placeable_mine( current_weapon ) || is_equipment( current_weapon ) )
		{
			current_weapon = undefined;
		}
		if ( isDefined( current_weapon ) )
		{
			if ( !is_offhand_weapon( weapon ) )
			{
				if ( current_weapon == "tesla_gun_zm" )
				{
					level.player_drops_tesla_gun = 1;
				}
				if ( issubstr( current_weapon, "knife_ballistic_" ) )
				{
					self notify( "zmb_lost_knife" );
				}
				self takeweapon( current_weapon );
				unacquire_weapon_toggle( current_weapon );
			}
		}
	}
	if ( isDefined( level.zombiemode_offhand_weapon_give_override ) )
	{
		if ( self [[ level.zombiemode_offhand_weapon_give_override ]]( weapon ) )
		{
			return;
		}
	}
	if ( weapon == "cymbal_monkey_zm" )
	{
		self maps/mp/zombies/_zm_weap_cymbal_monkey::player_give_cymbal_monkey();
		self play_weapon_vo( weapon, magic_box );
		return;
	}
	else if ( issubstr( weapon, "knife_ballistic_" ) )
	{
		weapon = self maps/mp/zombies/_zm_melee_weapon::give_ballistic_knife( weapon, issubstr( weapon, "upgraded" ) );
	}
	else if ( weapon == "claymore_zm" )
	{
		self thread maps/mp/zombies/_zm_weap_claymore::claymore_setup();
		self play_weapon_vo( weapon, magic_box );
		return;
	}
	if ( isDefined( level.zombie_weapons_callbacks ) && isDefined( level.zombie_weapons_callbacks[ weapon ] ) )
	{
		self thread [[ level.zombie_weapons_callbacks[ weapon ] ]]();
		play_weapon_vo( weapon, magic_box );
		return;
	}
	if ( !is_true( nosound ) )
	{
		self play_sound_on_ent( "purchase" );
	}
	if ( weapon == "ray_gun_zm" )
	{
		playsoundatposition( "mus_raygun_stinger", ( 0, 0, 0 ) );
	}
	if ( !is_weapon_upgraded( weapon ) )
	{
		self giveweapon( weapon );
	}
	else
	{
		self giveweapon( weapon, 0, self get_pack_a_punch_weapon_options( weapon ) );
	}
	acquire_weapon_toggle( weapon, self );
	self givestartammo( weapon );
	if ( !is_offhand_weapon( weapon ) )
	{
		if ( !is_melee_weapon( weapon ) )
		{
			self switchtoweapon( weapon );
		}
		else
		{
			self switchtoweapon( current_weapon );
		}
	}
	self play_weapon_vo( weapon, magic_box );
}

play_weapon_vo( weapon, magic_box ) //checked matches cerberus output
{
	if ( isDefined( level._audio_custom_weapon_check ) )
	{
		type = self [[ level._audio_custom_weapon_check ]]( weapon, magic_box );
	}
	else
	{
		type = self weapon_type_check( weapon );
	}
	if ( type == "crappy" )
	{
		return;
	}
	if ( type != "favorite" && type != "upgrade" )
	{
		type = weapon;
	}
	self maps/mp/zombies/_zm_audio::create_and_play_dialog( "weapon_pickup", type );
}

weapon_type_check( weapon ) //checked matches cerberus output
{
	if ( !isDefined( self.entity_num ) )
	{
		return "crappy";
	}
	weapon = get_base_name( weapon );
	if ( self is_favorite_weapon( weapon ) )
	{
		return "favorite";
	}
	if ( issubstr( weapon, "upgraded" ) )
	{
		return "upgrade";
	}
	else
	{
		return level.zombie_weapons[ weapon ].vox;
	}
}

get_player_index( player ) //checked matches cerberus output
{
	return player.characterindex;
}

ammo_give( weapon ) //checked changed to match cerberus output
{
	give_ammo = 0;
	if ( !is_offhand_weapon( weapon ) )
	{
		weapon = get_weapon_with_attachments( weapon );
		if ( isDefined( weapon ) )
		{
			stockmax = 0;
			stockmax = weaponstartammo( weapon );
			clipcount = self getweaponammoclip( weapon );
			currstock = self getammocount( weapon );
			if ( ( currstock - clipcount ) >= stockmax )
			{
				give_ammo = 0;
			}
			else
			{
				give_ammo = 1;
			}
		}
	}
	else if ( self has_weapon_or_upgrade( weapon ) )
	{
		if ( self getammocount( weapon ) < weaponmaxammo( weapon ) )
		{
			give_ammo = 1;
		}
	}
	if ( give_ammo )
	{
		self play_sound_on_ent( "purchase" );
		self givemaxammo( weapon );
		alt_weap = weaponaltweaponname( weapon );
		if ( alt_weap != "none" )
		{
			self givemaxammo( alt_weap );
		}
		return 1;
	}
	if ( !give_ammo )
	{
		return 0;
	}
}

get_player_weapondata( player, weapon ) //checked matches cerberus output
{
	weapondata = [];
	if ( !isDefined( weapon ) )
	{
		weapondata[ "name" ] = player getcurrentweapon();
	}
	else
	{
		weapondata[ "name" ] = weapon;
	}
	weapondata[ "dw_name" ] = weapondualwieldweaponname( weapondata[ "name" ] );
	weapondata[ "alt_name" ] = weaponaltweaponname( weapondata[ "name" ] );
	if ( weapondata[ "name" ] != "none" )
	{
		weapondata[ "clip" ] = player getweaponammoclip( weapondata[ "name" ] );
		weapondata[ "stock" ] = player getweaponammostock( weapondata[ "name" ] );
		weapondata[ "fuel" ] = player getweaponammofuel( weapondata[ "name" ] );
		weapondata[ "heat" ] = player isweaponoverheating( 1, weapondata[ "name" ] );
		weapondata[ "overheat" ] = player isweaponoverheating( 0, weapondata[ "name" ] );
	}
	else
	{
		weapondata[ "clip" ] = 0;
		weapondata[ "stock" ] = 0;
		weapondata[ "fuel" ] = 0;
		weapondata[ "heat" ] = 0;
		weapondata[ "overheat" ] = 0;
	}
	if ( weapondata[ "dw_name" ] != "none" )
	{
		weapondata[ "lh_clip" ] = player getweaponammoclip( weapondata[ "dw_name" ] );
	}
	else
	{
		weapondata[ "lh_clip" ] = 0;
	}
	if ( weapondata[ "alt_name" ] != "none" )
	{
		weapondata[ "alt_clip" ] = player getweaponammoclip( weapondata[ "alt_name" ] );
		weapondata[ "alt_stock" ] = player getweaponammostock( weapondata[ "alt_name" ] );
	}
	else
	{
		weapondata[ "alt_clip" ] = 0;
		weapondata[ "alt_stock" ] = 0;
	}
	return weapondata;
}

weapon_is_better( left, right ) //checked changed to match cerberus output
{
	if ( left != right )
	{
		left_upgraded = !isDefined( level.zombie_weapons[ left ] );
		right_upgraded = !isDefined( level.zombie_weapons[ right ] );
		if ( left_upgraded && right_upgraded )
		{
			leftatt = get_attachment_index( left );
			rightatt = get_attachment_index( right );
			return leftatt > rightatt;
		}
		else if ( left_upgraded )
		{
			return 1;
		}
	}
	return 0;
}

merge_weapons( oldweapondata, newweapondata ) //checked matches cerberus output
{
	weapondata = [];
	weapondata[ "name" ] = "none";
	if ( weapon_is_better( oldweapondata[ "name" ], newweapondata[ "name" ] ) )
	{
		weapondata[ "name" ] = oldweapondata[ "name" ];
	}
	else
	{
		weapondata[ "name" ] = newweapondata[ "name" ];
	}
	name = weapondata[ "name" ];
	dw_name = weapondualwieldweaponname( name );
	alt_name = weaponaltweaponname( name );
	if ( name != "none" )
	{
		weapondata[ "clip" ] = newweapondata[ "clip" ] + oldweapondata[ "clip" ];
		weapondata[ "clip" ] = int( min( weapondata[ "clip" ], weaponclipsize( name ) ) );
		weapondata[ "stock" ] = newweapondata[ "stock" ] + oldweapondata[ "stock" ];
		weapondata[ "stock" ] = int( min( weapondata[ "stock" ], weaponmaxammo( name ) ) );
		weapondata[ "fuel" ] = newweapondata[ "fuel" ] + oldweapondata[ "fuel" ];
		weapondata[ "fuel" ] = int( min( weapondata[ "fuel" ], weaponfuellife( name ) ) );
		weapondata[ "heat" ] = int( min( newweapondata[ "heat" ], oldweapondata[ "heat" ] ) );
		weapondata[ "overheat" ] = int( min( newweapondata[ "overheat" ], oldweapondata[ "overheat" ] ) );
	}
	if ( dw_name != "none" )
	{
		weapondata[ "lh_clip" ] = newweapondata[ "lh_clip" ] + oldweapondata[ "lh_clip" ];
		weapondata[ "lh_clip" ] = int( min( weapondata[ "lh_clip" ], weaponclipsize( dw_name ) ) );
	}
	if ( alt_name != "none" )
	{
		weapondata[ "alt_clip" ] = newweapondata[ "alt_clip" ] + oldweapondata[ "alt_clip" ];
		weapondata[ "alt_clip" ] = int( min( weapondata[ "alt_clip" ], weaponclipsize( alt_name ) ) );
		weapondata[ "alt_stock" ] = newweapondata[ "alt_stock" ] + oldweapondata[ "alt_stock" ];
		weapondata[ "alt_stock" ] = int( min( weapondata[ "alt_stock" ], weaponmaxammo( alt_name ) ) );
	}
	return weapondata;
}

weapondata_give( weapondata ) //checked matches cerberus output
{
	current = get_player_weapon_with_same_base( weapondata[ "name" ] );
	if ( isDefined( current ) )
	{
		curweapondata = get_player_weapondata( self, current );
		self takeweapon( current );
		weapondata = merge_weapons( curweapondata, weapondata );
	}
	name = weapondata[ "name" ];
	weapon_give( name, undefined, undefined, 1 );
	dw_name = weapondualwieldweaponname( name );
	alt_name = weaponaltweaponname( name );
	if ( name != "none" )
	{
		self setweaponammoclip( name, weapondata[ "clip" ] );
		self setweaponammostock( name, weapondata[ "stock" ] );
		if ( isDefined( weapondata[ "fuel" ] ) )
		{
			self setweaponammofuel( name, weapondata[ "fuel" ] );
		}
		if ( isDefined( weapondata[ "heat" ] ) && isDefined( weapondata[ "overheat" ] ) )
		{
			self setweaponoverheating( weapondata[ "overheat" ], weapondata[ "heat" ], name );
		}
	}
	if ( dw_name != "none" )
	{
		self setweaponammoclip( dw_name, weapondata[ "lh_clip" ] );
	}
	if ( alt_name != "none" )
	{
		self setweaponammoclip( alt_name, weapondata[ "alt_clip" ] );
		self setweaponammostock( alt_name, weapondata[ "alt_stock" ] );
	}
}

register_zombie_weapon_callback( str_weapon, func ) //checked matches cerberus output
{
	if ( !isDefined( level.zombie_weapons_callbacks ) )
	{
		level.zombie_weapons_callbacks = [];
	}
	if ( !isDefined( level.zombie_weapons_callbacks[ str_weapon ] ) )
	{
		level.zombie_weapons_callbacks[ str_weapon ] = func;
	}
}










