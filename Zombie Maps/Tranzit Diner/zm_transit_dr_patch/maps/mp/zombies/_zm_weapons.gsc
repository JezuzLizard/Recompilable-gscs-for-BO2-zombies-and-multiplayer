#include maps/mp/zombies/_zm_weap_cymbal_monkey;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/zombies/_zm_equipment;
#include maps/mp/zombies/_zm_laststand;
#include maps/mp/zombies/_zm_score;
#include maps/mp/zombies/_zm_melee_weapon;
#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/zombies/_zm_chugabud;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/gametypes_zm/_weapons;
#include maps/mp/gametypes_zm/_weaponobjects;
#include maps/mp/zombies/_zm_magicbox;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init()
{
/#
	println( "ZM >> init (_zm_weapons.gsc)" );
#/
	init_weapons();
	init_weapon_upgrade();
	init_weapon_toggle();
	init_pay_turret();
	init_weapon_cabinet();
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

setupretrievablehintstrings()
{
	maps/mp/gametypes_zm/_weaponobjects::createretrievablehint( "claymore", &"WEAPON_CLAYMORE_PICKUP" );
}

onplayerconnect()
{
	for ( ;; )
	{
		level waittill( "connecting", player );
		player thread onplayerspawned();
	}
}

onplayerspawned()
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

watchforgrenadeduds()
{
	self endon( "spawned_player" );
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "grenade_fire", grenade, weapname );
		grenade thread checkgrenadefordud( weapname, 1, self );
		grenade thread watchforscriptexplosion( weapname, 1, self );
	}
}

watchforgrenadelauncherduds()
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

grenade_safe_to_throw( player, weapname )
{
	if ( isDefined( level.grenade_safe_to_throw ) )
	{
		return self [[ level.grenade_safe_to_throw ]]( player, weapname );
	}
	return 1;
}

grenade_safe_to_bounce( player, weapname )
{
	if ( isDefined( level.grenade_safe_to_bounce ) )
	{
		return self [[ level.grenade_safe_to_bounce ]]( player, weapname );
	}
	return 1;
}

makegrenadedudanddestroy()
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

checkgrenadefordud( weapname, isthrowngrenade, player )
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
		self waittill_any_timeout( 0,25, "grenade_bounce", "stationary" );
		if ( !self grenade_safe_to_bounce( player, weapname ) )
		{
			self thread makegrenadedudanddestroy();
			return;
		}
	}
}

wait_explode()
{
	self endon( "grenade_dud" );
	self endon( "done" );
	self waittill( "explode", position );
	level.explode_position = position;
	level.explode_position_valid = 1;
	self notify( "done" );
}

wait_timeout( time )
{
	self endon( "grenade_dud" );
	self endon( "done" );
	wait time;
	self notify( "done" );
}

wait_for_explosion( time )
{
	level.explode_position = ( 0, 0, 0 );
	level.explode_position_valid = 0;
	self thread wait_explode();
	self thread wait_timeout( time );
	self waittill( "done" );
	self notify( "death_or_explode" );
}

watchforscriptexplosion( weapname, isthrowngrenade, player )
{
	self endon( "grenade_dud" );
	if ( is_lethal_grenade( weapname ) || is_grenade_launcher( weapname ) )
	{
		self thread wait_for_explosion( 20 );
		self waittill( "death_or_explode", exploded, position );
		if ( exploded )
		{
			level notify( "grenade_exploded" );
		}
	}
}

switch_from_alt_weapon( current_weapon )
{
	if ( is_alt_weapon( current_weapon ) )
	{
		alt = weaponaltweaponname( current_weapon );
		while ( alt == "none" )
		{
			primaryweapons = self getweaponslistprimaries();
			alt = primaryweapons[ 0 ];
			_a200 = primaryweapons;
			_k200 = getFirstArrayKey( _a200 );
			while ( isDefined( _k200 ) )
			{
				weapon = _a200[ _k200 ];
				if ( weaponaltweaponname( weapon ) == current_weapon )
				{
					alt = weapon;
					break;
				}
				else
				{
					_k200 = getNextArrayKey( _a200, _k200 );
				}
			}
		}
		self switchtoweaponimmediate( alt );
		self waittill_notify_or_timeout( "weapon_change_complete", 1 );
		return alt;
	}
	return current_weapon;
}

give_fallback_weapon()
{
	self giveweapon( "zombie_fists_zm" );
	self switchtoweapon( "zombie_fists_zm" );
}

take_fallback_weapon()
{
	if ( self hasweapon( "zombie_fists_zm" ) )
	{
		self takeweapon( "zombie_fists_zm" );
	}
}

switch_back_primary_weapon( oldprimary )
{
	if ( isDefined( self.laststand ) && self.laststand )
	{
		return;
	}
	primaryweapons = self getweaponslistprimaries();
	if ( isDefined( oldprimary ) && isinarray( primaryweapons, oldprimary ) )
	{
		self switchtoweapon( oldprimary );
	}
	else
	{
		if ( isDefined( primaryweapons ) && primaryweapons.size > 0 )
		{
			self switchtoweapon( primaryweapons[ 0 ] );
		}
	}
}

add_retrievable_knife_init_name( name )
{
	if ( !isDefined( level.retrievable_knife_init_names ) )
	{
		level.retrievable_knife_init_names = [];
	}
	level.retrievable_knife_init_names[ level.retrievable_knife_init_names.size ] = name;
}

watchweaponusagezm()
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
			else case "mg":
			case "pistol":
			case "pistol spread":
			case "pistolspread":
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
			}
			switch( curweapon )
			{
				case "m202_flash_mp":
				case "m220_tow_mp":
				case "m32_mp":
				case "minigun_mp":
				case "mp40_blinged_mp":
					self.usedkillstreakweapon[ curweapon ] = 1;
					break;
				continue;
				default:
				}
			}
		}
	}
}

trackweaponzm()
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
			continue;
		}
		else
		{
			if ( event != "disconnect" )
			{
				updateweapontimingszm( newtime );
			}
			return;
		}
	}
}

updatelastheldweapontimingszm( newtime )
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

updateweapontimingszm( newtime )
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

watchweaponchangezm()
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

weaponobjects_on_player_connect_override_internal()
{
	self maps/mp/gametypes_zm/_weaponobjects::createbasewatchers();
	self createclaymorewatcher_zm();
	i = 0;
	while ( i < level.retrievable_knife_init_names.size )
	{
		self createballisticknifewatcher_zm( level.retrievable_knife_init_names[ i ], level.retrievable_knife_init_names[ i ] + "_zm" );
		i++;
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

weaponobjects_on_player_connect_override()
{
	add_retrievable_knife_init_name( "knife_ballistic" );
	add_retrievable_knife_init_name( "knife_ballistic_upgraded" );
	onplayerconnect_callback( ::weaponobjects_on_player_connect_override_internal );
}

createclaymorewatcher_zm()
{
	watcher = self maps/mp/gametypes_zm/_weaponobjects::createuseweaponobjectwatcher( "claymore", "claymore_zm", self.team );
	watcher.onspawnretrievetriggers = ::maps/mp/zombies/_zm_weap_claymore::on_spawn_retrieve_trigger;
	watcher.adjusttriggerorigin = ::maps/mp/zombies/_zm_weap_claymore::adjust_trigger_origin;
	watcher.pickup = level.pickup_claymores;
	watcher.pickup_trigger_listener = level.pickup_claymores_trigger_listener;
	watcher.skip_weapon_object_damage = 1;
	watcher.headicon = 0;
	watcher.watchforfire = 1;
	watcher.detonate = ::claymoredetonate;
	watcher.ondamage = level.claymores_on_damage;
}

createballisticknifewatcher_zm( name, weapon )
{
	watcher = self maps/mp/gametypes_zm/_weaponobjects::createuseweaponobjectwatcher( name, weapon, self.team );
	watcher.onspawn = ::maps/mp/zombies/_zm_weap_ballistic_knife::on_spawn;
	watcher.onspawnretrievetriggers = ::maps/mp/zombies/_zm_weap_ballistic_knife::on_spawn_retrieve_trigger;
	watcher.storedifferentobject = 1;
	watcher.headicon = 0;
}

isempweapon( weaponname )
{
	if ( isDefined( weaponname ) && weaponname != "emp_mp" || weaponname == "emp_grenade_mp" && weaponname == "emp_grenade_zm" )
	{
		return 1;
	}
	return 0;
}

claymoredetonate( attacker, weaponname )
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

default_check_firesale_loc_valid_func()
{
	return 1;
}

add_zombie_weapon( weapon_name, upgrade_name, hint, cost, weaponvo, weaponvoresp, ammo_cost, create_vox )
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
	struct.weapon_name = weapon_name;
	struct.upgrade_name = upgrade_name;
	struct.weapon_classname = "weapon_" + weapon_name;
	struct.hint = hint;
	struct.cost = cost;
	struct.vox = weaponvo;
	struct.vox_response = weaponvoresp;
/#
	println( "ZM >> Looking for weapon - " + weapon_name );
#/
	struct.is_in_box = level.zombie_include_weapons[ weapon_name ];
	if ( !isDefined( ammo_cost ) )
	{
		ammo_cost = round_up_to_ten( int( cost * 0,5 ) );
	}
	struct.ammo_cost = ammo_cost;
	level.zombie_weapons[ weapon_name ] = struct;
	if ( isDefined( level.zombiemode_reusing_pack_a_punch ) && level.zombiemode_reusing_pack_a_punch && isDefined( upgrade_name ) )
	{
		add_attachments( weapon_name, upgrade_name );
	}
	if ( isDefined( create_vox ) )
	{
		level.vox maps/mp/zombies/_zm_audio::zmbvoxadd( "player", "weapon_pickup", weapon_name, weaponvo, undefined );
	}
/#
	if ( isDefined( level.devgui_add_weapon ) )
	{
		[[ level.devgui_add_weapon ]]( weapon_name, upgrade_name, hint, cost, weaponvo, weaponvoresp, ammo_cost );
#/
	}
}

add_attachments( weapon_name, upgrade_name )
{
	table = "zm/pap_attach.csv";
	if ( isDefined( level.weapon_attachment_table ) )
	{
		table = level.weapon_attachment_table;
	}
	row = tablelookuprownum( table, 0, upgrade_name );
	while ( row > -1 )
	{
		level.zombie_weapons[ weapon_name ].default_attachment = tablelookup( table, 0, upgrade_name, 1 );
		level.zombie_weapons[ weapon_name ].addon_attachments = [];
		index = 2;
		next_addon = tablelookup( table, 0, upgrade_name, index );
		while ( isDefined( next_addon ) && next_addon.size > 0 )
		{
			level.zombie_weapons[ weapon_name ].addon_attachments[ level.zombie_weapons[ weapon_name ].addon_attachments.size ] = next_addon;
			index++;
			next_addon = tablelookup( table, 0, upgrade_name, index );
		}
	}
}

default_weighting_func()
{
	return 1;
}

default_tesla_weighting_func()
{
	num_to_add = 1;
	if ( isDefined( level.pulls_since_last_tesla_gun ) )
	{
		if ( isDefined( level.player_drops_tesla_gun ) && level.player_drops_tesla_gun == 1 )
		{
			num_to_add += int( 0,2 * level.zombie_include_weapons.size );
		}
		if ( !isDefined( level.player_seen_tesla_gun ) || level.player_seen_tesla_gun == 0 )
		{
			if ( level.round_number > 10 )
			{
				num_to_add += int( 0,2 * level.zombie_include_weapons.size );
			}
			else
			{
				if ( level.round_number > 5 )
				{
					num_to_add += int( 0,15 * level.zombie_include_weapons.size );
				}
			}
		}
	}
	return num_to_add;
}

default_1st_move_weighting_func()
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

default_upgrade_weapon_weighting_func()
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

default_cymbal_monkey_weighting_func()
{
	players = get_players();
	count = 0;
	i = 0;
	while ( i < players.size )
	{
		if ( players[ i ] has_weapon_or_upgrade( "cymbal_monkey_zm" ) )
		{
			count++;
		}
		i++;
	}
	if ( count > 0 )
	{
		return 1;
	}
	else
	{
		if ( level.round_number < 10 )
		{
			return 3;
		}
		else
		{
			return 5;
		}
	}
}

is_weapon_included( weapon_name )
{
	if ( !isDefined( level.zombie_weapons ) )
	{
		return 0;
	}
	return isDefined( level.zombie_weapons[ weapon_name ] );
}

is_weapon_or_base_included( weapon_name )
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

include_zombie_weapon( weapon_name, in_box, collector, weighting_func )
{
	if ( !isDefined( level.zombie_include_weapons ) )
	{
		level.zombie_include_weapons = [];
	}
	if ( !isDefined( in_box ) )
	{
		in_box = 1;
	}
/#
	println( "ZM >> Including weapon - " + weapon_name );
#/
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

init_weapons()
{
	if ( isDefined( level._zombie_custom_add_weapons ) )
	{
		[[ level._zombie_custom_add_weapons ]]();
	}
	precachemodel( "zombie_teddybear" );
}

add_limited_weapon( weapon_name, amount )
{
	if ( !isDefined( level.limited_weapons ) )
	{
		level.limited_weapons = [];
	}
	level.limited_weapons[ weapon_name ] = amount;
}

limited_weapon_below_quota( weapon, ignore_player, pap_triggers )
{
	while ( isDefined( level.limited_weapons[ weapon ] ) )
	{
		if ( !isDefined( pap_triggers ) )
		{
			pap_triggers = getentarray( "specialty_weapupgrade", "script_noteworthy" );
		}
		players = get_players();
		count = 0;
		limit = level.limited_weapons[ weapon ];
		i = 0;
		while ( i < players.size )
		{
			if ( isDefined( ignore_player ) && ignore_player == players[ i ] )
			{
				i++;
				continue;
			}
			else
			{
				if ( players[ i ] has_weapon_or_upgrade( weapon ) )
				{
					count++;
					if ( count >= limit )
					{
						return 0;
					}
				}
			}
			i++;
		}
		k = 0;
		while ( k < pap_triggers.size )
		{
			if ( isDefined( pap_triggers[ k ].current_weapon ) && pap_triggers[ k ].current_weapon == weapon )
			{
				count++;
				if ( count >= limit )
				{
					return 0;
				}
			}
			k++;
		}
		if ( maps/mp/zombies/_zm_chugabud::is_weapon_available_in_chugabud_corpse( weapon ) )
		{
			return 0;
		}
		chestindex = 0;
		while ( chestindex < level.chests.size )
		{
			if ( isDefined( level.chests[ chestindex ].zbarrier.weapon_string ) && level.chests[ chestindex ].zbarrier.weapon_string == weapon )
			{
				count++;
				if ( count >= limit )
				{
					return 0;
				}
			}
			chestindex++;
		}
		while ( isDefined( level.random_weapon_powerups ) )
		{
			powerupindex = 0;
			while ( powerupindex < level.random_weapon_powerups.size )
			{
				if ( isDefined( level.random_weapon_powerups[ powerupindex ] ) && level.random_weapon_powerups[ powerupindex ].base_weapon == weapon )
				{
					count++;
					if ( count >= limit )
					{
						return 0;
					}
				}
				powerupindex++;
			}
		}
	}
	return 1;
}

init_pay_turret()
{
	pay_turrets = [];
	pay_turrets = getentarray( "pay_turret", "targetname" );
	i = 0;
	while ( i < pay_turrets.size )
	{
		cost = level.pay_turret_cost;
		if ( !isDefined( cost ) )
		{
			cost = 1000;
		}
		pay_turrets[ i ] sethintstring( &"ZOMBIE_PAY_TURRET", cost );
		pay_turrets[ i ] setcursorhint( "HINT_NOICON" );
		pay_turrets[ i ] usetriggerrequirelookat();
		pay_turrets[ i ] thread pay_turret_think( cost );
		i++;
	}
}

init_spawnable_weapon_upgrade()
{
	spawn_list = [];
	spawnable_weapon_spawns = getstructarray( "weapon_upgrade", "targetname" );
	spawnable_weapon_spawns = arraycombine( spawnable_weapon_spawns, getstructarray( "bowie_upgrade", "targetname" ), 1, 0 );
	spawnable_weapon_spawns = arraycombine( spawnable_weapon_spawns, getstructarray( "sickle_upgrade", "targetname" ), 1, 0 );
	spawnable_weapon_spawns = arraycombine( spawnable_weapon_spawns, getstructarray( "tazer_upgrade", "targetname" ), 1, 0 );
	if ( !is_true( level.headshots_only ) )
	{
		spawnable_weapon_spawns = arraycombine( spawnable_weapon_spawns, getstructarray( "claymore_purchase", "targetname" ), 1, 0 );
	}
	match_string = "";
	location = level.scr_zm_map_start_location;
	if ( location != "default" && location == "" && isDefined( level.default_start_location ) )
	{
		location = level.default_start_location;
	}
	match_string = level.scr_zm_ui_gametype;
	if ( location != "" )
	{
		match_string = ( match_string + "_" ) + location;
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
		else
		{
			if ( !isDefined( spawnable_weapon.script_noteworthy ) || spawnable_weapon.script_noteworthy == "" )
			{
				spawn_list[ spawn_list.size ] = spawnable_weapon;
				i++;
				continue;
			}
			else
			{
				matches = strtok( spawnable_weapon.script_noteworthy, "," );
				j = 0;
				while ( j < matches.size )
				{
					if ( matches[ j ] == match_string || matches[ j ] == match_string_plus_space )
					{
						spawn_list[ spawn_list.size ] = spawnable_weapon;
					}
					j++;
				}
			}
		}
		i++;
	}
	tempmodel = spawn( "script_model", ( 0, 0, 0 ) );
	i = 0;
	while ( i < spawn_list.size )
	{
		clientfieldname = ( spawn_list[ i ].zombie_weapon_upgrade + "_" ) + spawn_list[ i ].origin;
		registerclientfield( "world", clientfieldname, 1, 2, "int" );
		target_struct = getstruct( spawn_list[ i ].target, "targetname" );
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
		unitrigger_stub.script_length = bounds[ 0 ] * 0,25;
		unitrigger_stub.script_width = bounds[ 1 ];
		unitrigger_stub.script_height = bounds[ 2 ];
		unitrigger_stub.origin -= anglesToRight( unitrigger_stub.angles ) * ( unitrigger_stub.script_length * 0,4 );
		unitrigger_stub.target = spawn_list[ i ].target;
		unitrigger_stub.targetname = spawn_list[ i ].targetname;
		unitrigger_stub.cursor_hint = "HINT_NOICON";
		if ( spawn_list[ i ].targetname == "weapon_upgrade" )
		{
			unitrigger_stub.hint_string = get_weapon_hint( spawn_list[ i ].zombie_weapon_upgrade );
			unitrigger_stub.cost = get_weapon_cost( spawn_list[ i ].zombie_weapon_upgrade );
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
		if ( unitrigger_stub.zombie_weapon_upgrade == "claymore_zm" )
		{
			unitrigger_force_per_player_triggers( unitrigger_stub, 1 );
			unitrigger_stub.prompt_and_visibility_func = ::maps/mp/zombies/_zm_weap_claymore::claymore_unitrigger_update_prompt;
			maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( unitrigger_stub, ::maps/mp/zombies/_zm_weap_claymore::buy_claymores );
		}
		else
		{
			if ( unitrigger_stub.zombie_weapon_upgrade == "tazer_knuckles_zm" && isDefined( level.taser_trig_adjustment ) )
			{
				unitrigger_stub.origin += level.taser_trig_adjustment;
			}
			maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( unitrigger_stub, ::weapon_spawn_think );
		}
		spawn_list[ i ].trigger_stub = unitrigger_stub;
		i++;
	}
	level._spawned_wallbuys = spawn_list;
	tempmodel delete();
}

reset_wallbuy_internal( set_hint_string )
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

reset_wallbuys()
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
	i = 0;
	while ( i < weapon_spawns.size )
	{
		weapon_spawns[ i ] reset_wallbuy_internal( 1 );
		i++;
	}
	i = 0;
	while ( i < melee_and_grenade_spawns.size )
	{
		melee_and_grenade_spawns[ i ] reset_wallbuy_internal( 0 );
		i++;
	}
	while ( isDefined( level._unitriggers ) )
	{
		candidates = [];
		i = 0;
		while ( i < level._unitriggers.trigger_stubs.size )
		{
			stub = level._unitriggers.trigger_stubs[ i ];
			tn = stub.targetname;
			if ( tn != "weapon_upgrade" && tn != "bowie_upgrade" && tn != "sickle_upgrade" || tn == "tazer_upgrade" && tn == "claymore_purchase" )
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
				}
			}
			i++;
		}
	}
}

init_weapon_upgrade()
{
	init_spawnable_weapon_upgrade();
	weapon_spawns = [];
	weapon_spawns = getentarray( "weapon_upgrade", "targetname" );
	i = 0;
	while ( i < weapon_spawns.size )
	{
		hint_string = get_weapon_hint( weapon_spawns[ i ].zombie_weapon_upgrade );
		cost = get_weapon_cost( weapon_spawns[ i ].zombie_weapon_upgrade );
		weapon_spawns[ i ] sethintstring( hint_string, cost );
		weapon_spawns[ i ] setcursorhint( "HINT_NOICON" );
		weapon_spawns[ i ] usetriggerrequirelookat();
		weapon_spawns[ i ] thread weapon_spawn_think();
		model = getent( weapon_spawns[ i ].target, "targetname" );
		if ( isDefined( model ) )
		{
			model useweaponhidetags( weapon_spawns[ i ].zombie_weapon_upgrade );
			model hide();
		}
		i++;
	}
}

init_weapon_toggle()
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
	i = 0;
	while ( i < weapon_toggle_ents.size )
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
		j = 0;
		while ( j < target_array.size )
		{
			switch( target_array[ j ].script_string )
			{
				case "light":
					struct.light = target_array[ j ];
					struct.light setmodel( level.zombie_weapon_toggle_disabled_light );
					break;
				j++;
				continue;
				case "weapon":
					struct.weapon_model = target_array[ j ];
					struct.weapon_model hide();
					break;
				j++;
				continue;
			}
			j++;
		}
		struct.trigger sethintstring( level.zombie_weapon_toggle_disabled_hint );
		struct.trigger setcursorhint( "HINT_NOICON" );
		struct.trigger usetriggerrequirelookat();
		struct thread weapon_toggle_think();
		level.zombie_weapon_toggles[ struct.weapon_name ] = struct;
		i++;
	}
	level thread [[ level.magic_box_weapon_toggle_init_callback ]]();
}

get_weapon_toggle( weapon_name )
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
	i = 0;
	while ( i < keys.size )
	{
		if ( weapon_name == level.zombie_weapon_toggles[ keys[ i ] ].upgrade_name )
		{
			return level.zombie_weapon_toggles[ keys[ i ] ];
		}
		i++;
	}
	return undefined;
}

is_weapon_toggle( weapon_name )
{
	return isDefined( get_weapon_toggle( weapon_name ) );
}

disable_weapon_toggle( weapon_name )
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

enable_weapon_toggle( weapon_name )
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

activate_weapon_toggle( weapon_name, trig_for_vox )
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

deactivate_weapon_toggle( weapon_name, trig_for_vox )
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

acquire_weapon_toggle( weapon_name, player )
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

unacquire_weapon_toggle_on_death_or_disconnect_thread( player )
{
	self notify( "end_unacquire_weapon_thread" );
	self endon( "end_unacquire_weapon_thread" );
	player waittill_any( "spawned_spectator", "disconnect" );
	unacquire_weapon_toggle( self.weapon_name );
}

unacquire_weapon_toggle( weapon_name )
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

weapon_toggle_think()
{
	for ( ;; )
	{
		self.trigger waittill( "trigger", player );
		if ( !is_player_valid( player ) )
		{
			player thread ignore_triggers( 0,5 );
			continue;
		}
		else if ( !self.enabled || self.acquired )
		{
			self.trigger thread maps/mp/zombies/_zm_audio::weapon_toggle_vox( "max" );
			continue;
		}
		else
		{
			if ( !self.active )
			{
				activate_weapon_toggle( self.weapon_name, self.trigger );
				break;
			}
			else
			{
				deactivate_weapon_toggle( self.weapon_name, self.trigger );
			}
		}
	}
}

init_weapon_cabinet()
{
	weapon_cabs = getentarray( "weapon_cabinet_use", "targetname" );
/#
	println( "ZM >> init_weapon_cabinet (_zm_weapons.gsc) num=" + weapon_cabs.size );
#/
	i = 0;
	while ( i < weapon_cabs.size )
	{
		weapon_cabs[ i ] sethintstring( &"ZOMBIE_CABINET_OPEN_1500" );
		weapon_cabs[ i ] setcursorhint( "HINT_NOICON" );
		weapon_cabs[ i ] usetriggerrequirelookat();
		i++;
	}
	array_thread( weapon_cabs, ::weapon_cabinet_think );
}

get_weapon_hint( weapon_name )
{
/#
	assert( isDefined( level.zombie_weapons[ weapon_name ] ), weapon_name + " was not included or is not part of the zombie weapon list." );
#/
	return level.zombie_weapons[ weapon_name ].hint;
}

get_weapon_cost( weapon_name )
{
/#
	assert( isDefined( level.zombie_weapons[ weapon_name ] ), weapon_name + " was not included or is not part of the zombie weapon list." );
#/
	return level.zombie_weapons[ weapon_name ].cost;
}

get_ammo_cost( weapon_name )
{
/#
	assert( isDefined( level.zombie_weapons[ weapon_name ] ), weapon_name + " was not included or is not part of the zombie weapon list." );
#/
	return level.zombie_weapons[ weapon_name ].ammo_cost;
}

get_is_in_box( weapon_name )
{
/#
	assert( isDefined( level.zombie_weapons[ weapon_name ] ), weapon_name + " was not included or is not part of the zombie weapon list." );
#/
	return level.zombie_weapons[ weapon_name ].is_in_box;
}

weapon_supports_attachments( weaponname )
{
	weaponname = get_base_weapon_name( weaponname );
	attachments = level.zombie_weapons[ weaponname ].addon_attachments;
	if ( isDefined( attachments ) )
	{
		return attachments.size > 1;
	}
}

random_attachment( weaponname, exclude )
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
	while ( attachments.size > minatt )
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

get_base_name( weaponname )
{
	split = strtok( weaponname, "+" );
	if ( split.size > 1 )
	{
		return split[ 0 ];
	}
	return weaponname;
}

get_attachment_name( weaponname, att_id )
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
	else
	{
		if ( split.size > 1 )
		{
			att = split[ 1 ];
			idx = 2;
			while ( split.size > idx )
			{
				att = ( att + "+" ) + split[ idx ];
				idx++;
			}
			return att;
		}
	}
	return undefined;
}

get_attachment_index( weapon )
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
	while ( isDefined( level.zombie_weapons[ base ].addon_attachments ) )
	{
		i = 0;
		while ( i < level.zombie_weapons[ base ].addon_attachments.size )
		{
			if ( level.zombie_weapons[ base ].addon_attachments[ i ] == att )
			{
				return i + 1;
			}
			i++;
		}
	}
/#
	println( "ZM WEAPON ERROR: Unrecognized attachment in weapon " + weapon );
#/
	return -1;
}

has_attachment( weaponname, att )
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

get_base_weapon_name( upgradedweaponname, base_if_not_upgraded )
{
	if ( !isDefined( upgradedweaponname ) || upgradedweaponname == "" )
	{
		return undefined;
	}
	upgradedweaponname = tolower( upgradedweaponname );
	upgradedweaponname = get_base_name( upgradedweaponname );
	ziw_keys = getarraykeys( level.zombie_weapons );
	i = 0;
	while ( i < level.zombie_weapons.size )
	{
		if ( isDefined( level.zombie_weapons[ ziw_keys[ i ] ].upgrade_name ) && level.zombie_weapons[ ziw_keys[ i ] ].upgrade_name == upgradedweaponname )
		{
			return ziw_keys[ i ];
		}
		i++;
	}
	if ( isDefined( base_if_not_upgraded ) && base_if_not_upgraded )
	{
		return upgradedweaponname;
	}
	return undefined;
}

get_upgrade_weapon( weaponname, add_attachment )
{
	rootweaponname = tolower( weaponname );
	rootweaponname = get_base_name( rootweaponname );
	baseweaponname = get_base_weapon_name( rootweaponname, 1 );
	newweapon = rootweaponname;
	if ( !is_weapon_upgraded( rootweaponname ) )
	{
		newweapon = level.zombie_weapons[ rootweaponname ].upgrade_name;
	}
	if ( isDefined( add_attachment ) && add_attachment && isDefined( level.zombiemode_reusing_pack_a_punch ) && level.zombiemode_reusing_pack_a_punch )
	{
		oldatt = get_attachment_name( weaponname );
		att = random_attachment( baseweaponname, oldatt );
		newweapon = ( newweapon + "+" ) + att;
	}
	else
	{
		if ( isDefined( level.zombie_weapons[ rootweaponname ] ) && isDefined( level.zombie_weapons[ rootweaponname ].default_attachment ) )
		{
			att = level.zombie_weapons[ rootweaponname ].default_attachment;
			newweapon = ( newweapon + "+" ) + att;
		}
	}
	return newweapon;
}

can_upgrade_weapon( weaponname )
{
	if ( isDefined( weaponname ) || weaponname == "" && weaponname == "zombie_fists_zm" )
	{
		return 0;
	}
	weaponname = tolower( weaponname );
	weaponname = get_base_name( weaponname );
	if ( !is_weapon_upgraded( weaponname ) )
	{
		return isDefined( level.zombie_weapons[ weaponname ].upgrade_name );
	}
	if ( isDefined( level.zombiemode_reusing_pack_a_punch ) && level.zombiemode_reusing_pack_a_punch && weapon_supports_attachments( weaponname ) )
	{
		return 1;
	}
	return 0;
}

will_upgrade_weapon_as_attachment( weaponname )
{
	if ( isDefined( weaponname ) || weaponname == "" && weaponname == "zombie_fists_zm" )
	{
		return 0;
	}
	weaponname = tolower( weaponname );
	weaponname = get_base_name( weaponname );
	if ( !is_weapon_upgraded( weaponname ) )
	{
		return 0;
	}
	if ( isDefined( level.zombiemode_reusing_pack_a_punch ) && level.zombiemode_reusing_pack_a_punch && weapon_supports_attachments( weaponname ) )
	{
		return 1;
	}
	return 0;
}

is_weapon_upgraded( weaponname )
{
	if ( isDefined( weaponname ) || weaponname == "" && weaponname == "zombie_fists_zm" )
	{
		return 0;
	}
	weaponname = tolower( weaponname );
	weaponname = get_base_name( weaponname );
	ziw_keys = getarraykeys( level.zombie_weapons );
	i = 0;
	while ( i < level.zombie_weapons.size )
	{
		if ( isDefined( level.zombie_weapons[ ziw_keys[ i ] ].upgrade_name ) && level.zombie_weapons[ ziw_keys[ i ] ].upgrade_name == weaponname )
		{
			return 1;
		}
		i++;
	}
	return 0;
}

get_weapon_with_attachments( weaponname )
{
	if ( self hasweapon( weaponname ) )
	{
		return weaponname;
	}
	while ( isDefined( level.zombiemode_reusing_pack_a_punch ) && level.zombiemode_reusing_pack_a_punch )
	{
		weaponname = tolower( weaponname );
		weaponname = get_base_name( weaponname );
		weapons = self getweaponslist( 1 );
		_a1818 = weapons;
		_k1818 = getFirstArrayKey( _a1818 );
		while ( isDefined( _k1818 ) )
		{
			weapon = _a1818[ _k1818 ];
			weapon = tolower( weapon );
			weapon_base = get_base_name( weapon );
			if ( weaponname == weapon_base )
			{
				return weapon;
			}
			_k1818 = getNextArrayKey( _a1818, _k1818 );
		}
	}
	return undefined;
}

has_weapon_or_attachments( weaponname )
{
	if ( self hasweapon( weaponname ) )
	{
		return 1;
	}
	while ( isDefined( level.zombiemode_reusing_pack_a_punch ) && level.zombiemode_reusing_pack_a_punch )
	{
		weaponname = tolower( weaponname );
		weaponname = get_base_name( weaponname );
		weapons = self getweaponslist( 1 );
		_a1840 = weapons;
		_k1840 = getFirstArrayKey( _a1840 );
		while ( isDefined( _k1840 ) )
		{
			weapon = _a1840[ _k1840 ];
			weapon = tolower( weapon );
			weapon = get_base_name( weapon );
			if ( weaponname == weapon )
			{
				return 1;
			}
			_k1840 = getNextArrayKey( _a1840, _k1840 );
		}
	}
	return 0;
}

has_upgrade( weaponname )
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

has_weapon_or_upgrade( weaponname )
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
		if ( !self has_weapon_or_attachments( weaponname ) )
		{
			has_weapon = self has_upgrade( weaponname );
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

get_player_weapon_with_same_base( weaponname )
{
	weaponname = tolower( weaponname );
	weaponname = get_base_name( weaponname );
	retweapon = get_weapon_with_attachments( weaponname );
	while ( !isDefined( retweapon ) )
	{
		if ( isDefined( level.zombie_weapons[ weaponname ] ) )
		{
			retweapon = get_weapon_with_attachments( level.zombie_weapons[ weaponname ].upgrade_name );
			break;
		}
		else
		{
			ziw_keys = getarraykeys( level.zombie_weapons );
			i = 0;
			while ( i < level.zombie_weapons.size )
			{
				if ( isDefined( level.zombie_weapons[ ziw_keys[ i ] ].upgrade_name ) && level.zombie_weapons[ ziw_keys[ i ] ].upgrade_name == weaponname )
				{
					retweapon = get_weapon_with_attachments( ziw_keys[ i ] );
				}
				i++;
			}
		}
	}
	return retweapon;
}

pay_turret_think( cost )
{
	if ( !isDefined( self.target ) )
	{
		return;
	}
	turret = getent( self.target, "targetname" );
	if ( !isDefined( turret ) )
	{
		return;
	}
	turret maketurretunusable();
	zone_name = turret get_current_zone();
	if ( !isDefined( zone_name ) )
	{
		zone_name = "";
	}
	while ( 1 )
	{
		self waittill( "trigger", player );
		while ( !is_player_valid( player ) )
		{
			player thread ignore_triggers( 0,5 );
		}
		while ( player in_revive_trigger() )
		{
			wait 0,1;
		}
		while ( player.is_drinking > 0 )
		{
			wait 0,1;
		}
		if ( player.score >= cost )
		{
			player maps/mp/zombies/_zm_score::minus_to_player_score( cost );
			bbprint( "zombie_uses", "playername %s playerscore %d round %d cost %d name %s x %f y %f z %f type %s", player.name, player.score, level.round_number, cost, zone_name, self.origin, "turret" );
			turret maketurretusable();
			turret useby( player );
			self disable_trigger();
			player maps/mp/zombies/_zm_audio::create_and_play_dialog( "weapon_pickup", "mg" );
			player.curr_pay_turret = turret;
			turret thread watch_for_laststand( player );
			turret thread watch_for_fake_death( player );
			if ( isDefined( level.turret_timer ) )
			{
				turret thread watch_for_timeout( player, level.turret_timer );
			}
			while ( isDefined( turret getturretowner() ) && turret getturretowner() == player )
			{
				wait 0,05;
			}
			turret notify( "stop watching" );
			player.curr_pay_turret = undefined;
			turret maketurretunusable();
			self enable_trigger();
			continue;
		}
		else
		{
			play_sound_on_ent( "no_purchase" );
			player maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "no_money", undefined, 0 );
		}
	}
}

watch_for_laststand( player )
{
	self endon( "stop watching" );
	while ( !player maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
	{
		if ( isDefined( level.intermission ) && level.intermission )
		{
			intermission = 1;
		}
		wait 0,05;
	}
	if ( isDefined( self getturretowner() ) && self getturretowner() == player )
	{
		self useby( player );
	}
}

watch_for_fake_death( player )
{
	self endon( "stop watching" );
	player waittill( "fake_death" );
	if ( isDefined( self getturretowner() ) && self getturretowner() == player )
	{
		self useby( player );
	}
}

watch_for_timeout( player, time )
{
	self endon( "stop watching" );
	self thread cancel_timer_on_end( player );
	wait time;
	if ( isDefined( self getturretowner() ) && self getturretowner() == player )
	{
		self useby( player );
	}
}

cancel_timer_on_end( player )
{
	self waittill( "stop watching" );
	player notify( "stop watching" );
}

weapon_cabinet_door_open( left_or_right )
{
	if ( left_or_right == "left" )
	{
		self rotateyaw( 120, 0,3, 0,2, 0,1 );
	}
	else
	{
		if ( left_or_right == "right" )
		{
			self rotateyaw( -120, 0,3, 0,2, 0,1 );
		}
	}
}

weapon_set_first_time_hint( cost, ammo_cost )
{
	if ( isDefined( level.has_pack_a_punch ) && !level.has_pack_a_punch )
	{
		self sethintstring( &"ZOMBIE_WEAPONCOSTAMMO", cost, ammo_cost );
	}
	else
	{
		self sethintstring( &"ZOMBIE_WEAPONCOSTAMMO_UPGRADE", cost, ammo_cost );
	}
}

weapon_spawn_think()
{
	cost = get_weapon_cost( self.zombie_weapon_upgrade );
	ammo_cost = get_ammo_cost( self.zombie_weapon_upgrade );
	is_grenade = weapontype( self.zombie_weapon_upgrade ) == "grenade";
	second_endon = undefined;
	if ( isDefined( self.stub ) )
	{
		second_endon = "kill_trigger";
		self.first_time_triggered = self.stub.first_time_triggered;
	}
	self thread decide_hide_show_hint( "stop_hint_logic", second_endon );
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
	else
	{
		if ( self.first_time_triggered )
		{
			self weapon_set_first_time_hint( cost, get_ammo_cost( self.zombie_weapon_upgrade ) );
		}
	}
	for ( ;; )
	{
		self waittill( "trigger", player );
		if ( !is_player_valid( player ) )
		{
			player thread ignore_triggers( 0,5 );
			continue;
		}
		else if ( !player can_buy_weapon() )
		{
			wait 0,1;
			continue;
		}
		else if ( isDefined( self.stub ) && isDefined( self.stub.require_look_from ) && self.stub.require_look_from )
		{
			toplayer = player get_eye() - self.origin;
			forward = -1 * anglesToRight( self.angles );
			dot = vectordot( toplayer, forward );
			if ( dot < 0 )
			{
				continue;
			}
		}
		else if ( player has_powerup_weapon() )
		{
			wait 0,1;
			continue;
		}
		else
		{
			player_has_weapon = player has_weapon_or_upgrade( self.zombie_weapon_upgrade );
			if ( !player_has_weapon )
			{
				if ( player.score >= cost )
				{
					if ( self.first_time_triggered == 0 )
					{
						self show_all_weapon_buys( player, cost, ammo_cost, is_grenade );
					}
					player maps/mp/zombies/_zm_score::minus_to_player_score( cost );
					bbprint( "zombie_uses", "playername %s playerscore %d round %d cost %d name %s x %f y %f z %f type %s", player.name, player.score, level.round_number, cost, self.zombie_weapon_upgrade, self.origin, "weapon" );
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
					else
					{
						if ( is_lethal_grenade( self.zombie_weapon_upgrade ) )
						{
							player takeweapon( player get_player_lethal_grenade() );
							player set_player_lethal_grenade( self.zombie_weapon_upgrade );
						}
						player weapon_give( self.zombie_weapon_upgrade );
					}
					player maps/mp/zombies/_zm_stats::increment_client_stat( "wallbuy_weapons_purchased" );
					player maps/mp/zombies/_zm_stats::increment_player_stat( "wallbuy_weapons_purchased" );
				}
				else
				{
					play_sound_on_ent( "no_purchase" );
					player maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "no_money_weapon" );
				}
			}
			else if ( isDefined( self.hacked ) && self.hacked )
			{
				if ( !player has_upgrade( self.zombie_weapon_upgrade ) )
				{
					ammo_cost = 4500;
				}
				else
				{
					ammo_cost = get_ammo_cost( self.zombie_weapon_upgrade );
				}
			}
			else
			{
				if ( player has_upgrade( self.zombie_weapon_upgrade ) )
				{
					ammo_cost = 4500;
					break;
				}
				else
				{
					ammo_cost = get_ammo_cost( self.zombie_weapon_upgrade );
				}
			}
			if ( self.zombie_weapon_upgrade == "riotshield_zm" )
			{
				play_sound_on_ent( "no_purchase" );
			}
			else if ( player.score >= ammo_cost )
			{
				if ( self.first_time_triggered == 0 )
				{
					self show_all_weapon_buys( player, cost, ammo_cost, is_grenade );
				}
				if ( player has_upgrade( self.zombie_weapon_upgrade ) )
				{
					player maps/mp/zombies/_zm_stats::increment_client_stat( "upgraded_ammo_purchased" );
					player maps/mp/zombies/_zm_stats::increment_player_stat( "upgraded_ammo_purchased" );
				}
				else
				{
					player maps/mp/zombies/_zm_stats::increment_client_stat( "ammo_purchased" );
					player maps/mp/zombies/_zm_stats::increment_player_stat( "ammo_purchased" );
				}
				if ( self.zombie_weapon_upgrade == "riotshield_zm" )
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
				else if ( player has_upgrade( self.zombie_weapon_upgrade ) )
				{
					ammo_given = player ammo_give( level.zombie_weapons[ self.zombie_weapon_upgrade ].upgrade_name );
				}
				else
				{
					ammo_given = player ammo_give( self.zombie_weapon_upgrade );
				}
				if ( ammo_given )
				{
					player maps/mp/zombies/_zm_score::minus_to_player_score( ammo_cost );
					bbprint( "zombie_uses", "playername %s playerscore %d round %d cost %d name %s x %f y %f z %f type %s", player.name, player.score, level.round_number, ammo_cost, self.zombie_weapon_upgrade, self.origin, "ammo" );
				}
			}
			else play_sound_on_ent( "no_purchase" );
			if ( isDefined( level.custom_generic_deny_vo_func ) )
			{
				player [[ level.custom_generic_deny_vo_func ]]();
			}
			else
			{
				player maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "no_money_weapon" );
			}
			if ( isDefined( self.stub ) && isDefined( self.stub.prompt_and_visibility_func ) )
			{
				self [[ self.stub.prompt_and_visibility_func ]]( player );
			}
		}
	}
}

show_all_weapon_buys( player, cost, ammo_cost, is_grenade )
{
	model = getent( self.target, "targetname" );
	if ( isDefined( model ) )
	{
		model thread weapon_show( player );
	}
	else
	{
		if ( isDefined( self.clientfieldname ) )
		{
			level setclientfield( self.clientfieldname, 1 );
		}
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
	if ( isDefined( level.dont_link_common_wallbuys ) && !level.dont_link_common_wallbuys && isDefined( level._spawned_wallbuys ) )
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
			else
			{
				if ( self.zombie_weapon_upgrade == wallbuy.zombie_weapon_upgrade )
				{
					if ( isDefined( wallbuy.trigger_stub ) && isDefined( wallbuy.trigger_stub.clientfieldname ) )
					{
						level setclientfield( wallbuy.trigger_stub.clientfieldname, 1 );
					}
					else
					{
						if ( isDefined( wallbuy.target ) )
						{
							model = getent( wallbuy.target, "targetname" );
							if ( isDefined( model ) )
							{
								model thread weapon_show( player );
							}
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
					else
					{
						if ( !is_grenade )
						{
							wallbuy weapon_set_first_time_hint( cost, ammo_cost );
						}
					}
				}
			}
			i++;
		}
	}
}

weapon_show( player )
{
	player_angles = vectorToAngle( player.origin - self.origin );
	player_yaw = player_angles[ 1 ];
	weapon_yaw = self.angles[ 1 ];
	if ( isDefined( self.script_int ) )
	{
		weapon_yaw -= self.script_int;
	}
	yaw_diff = angleClamp180( player_yaw - weapon_yaw );
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
	wait 0,05;
	self show();
	play_sound_at_pos( "weapon_show", self.origin, self );
	time = 1;
	if ( !isDefined( self._linked_ent ) )
	{
		self moveto( self.og_origin, time );
	}
}

get_pack_a_punch_weapon_options( weapon )
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
	else
	{
		if ( use_plain )
		{
			reticle_index = plain_reticle_index;
		}
	}
/#
	if ( getDvarInt( #"471F9AB9" ) >= 0 )
	{
		reticle_index = getDvarInt( #"471F9AB9" );
#/
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

weapon_give( weapon, is_upgrade, magic_box )
{
	primaryweapons = self getweaponslistprimaries();
	current_weapon = self getcurrentweapon();
	current_weapon = self maps/mp/zombies/_zm_weapons::switch_from_alt_weapon( current_weapon );
	weapon_limit = 2;
	if ( !isDefined( is_upgrade ) )
	{
		is_upgrade = 0;
	}
	if ( self hasperk( "specialty_additionalprimaryweapon" ) )
	{
		weapon_limit = 3;
	}
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
	else
	{
		if ( is_placeable_mine( weapon ) )
		{
			old_mine = self get_player_placeable_mine();
			if ( isDefined( old_mine ) )
			{
				self takeweapon( old_mine );
				unacquire_weapon_toggle( old_mine );
			}
			self set_player_placeable_mine( weapon );
		}
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
		self play_weapon_vo( weapon );
		return;
	}
	else if ( issubstr( weapon, "knife_ballistic_" ) )
	{
		weapon = self maps/mp/zombies/_zm_melee_weapon::give_ballistic_knife( weapon, issubstr( weapon, "upgraded" ) );
	}
	else
	{
		if ( weapon == "claymore_zm" )
		{
			self thread maps/mp/zombies/_zm_weap_claymore::claymore_setup();
			self play_weapon_vo( weapon );
			return;
		}
	}
	self play_sound_on_ent( "purchase" );
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
	self play_weapon_vo( weapon );
}

play_weapon_vo( weapon )
{
	if ( isDefined( level._audio_custom_weapon_check ) )
	{
		type = self [[ level._audio_custom_weapon_check ]]( weapon );
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

weapon_type_check( weapon )
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

get_player_index( player )
{
/#
	assert( isplayer( player ) );
#/
/#
	assert( isDefined( player.characterindex ) );
#/
/#
	if ( player.entity_num == 0 && getDvar( #"2222BA21" ) != "" )
	{
		new_vo_index = getDvarInt( #"2222BA21" );
		return new_vo_index;
#/
	}
	return player.characterindex;
}

ammo_give( weapon )
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
	else
	{
		if ( self has_weapon_or_upgrade( weapon ) )
		{
			if ( self getammocount( weapon ) < weaponmaxammo( weapon ) )
			{
				give_ammo = 1;
			}
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

weapon_cabinet_think()
{
	weapons = getentarray( "cabinet_weapon", "targetname" );
	doors = getentarray( self.target, "targetname" );
	i = 0;
	while ( i < doors.size )
	{
		doors[ i ] notsolid();
		i++;
	}
	self.has_been_used_once = 0;
	self thread decide_hide_show_hint();
	while ( 1 )
	{
		self waittill( "trigger", player );
		while ( !player can_buy_weapon() )
		{
			wait 0,1;
		}
		cost = 1500;
		if ( self.has_been_used_once )
		{
			cost = get_weapon_cost( self.zombie_weapon_upgrade );
		}
		else
		{
			if ( isDefined( self.zombie_cost ) )
			{
				cost = self.zombie_cost;
			}
		}
		ammo_cost = get_ammo_cost( self.zombie_weapon_upgrade );
		while ( !is_player_valid( player ) )
		{
			player thread ignore_triggers( 0,5 );
		}
		if ( self.has_been_used_once )
		{
			player_has_weapon = player has_weapon_or_upgrade( self.zombie_weapon_upgrade );
			if ( !player_has_weapon )
			{
				if ( player.score >= cost )
				{
					self play_sound_on_ent( "purchase" );
					player maps/mp/zombies/_zm_score::minus_to_player_score( cost );
					player weapon_give( self.zombie_weapon_upgrade );
				}
				else
				{
					play_sound_on_ent( "no_purchase" );
					player maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "no_money_weapon" );
				}
			}
			else if ( player.score >= ammo_cost )
			{
				ammo_given = player ammo_give( self.zombie_weapon_upgrade );
				if ( ammo_given )
				{
					self play_sound_on_ent( "purchase" );
					player maps/mp/zombies/_zm_score::minus_to_player_score( ammo_cost );
				}
			}
			else play_sound_on_ent( "no_purchase" );
			if ( isDefined( level.custom_generic_deny_vo_func ) )
			{
				player [[ level.custom_generic_deny_vo_func ]]();
			}
			else
			{
				player maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "no_money_weapon" );
			}
			continue;
		}
		else if ( player.score >= cost )
		{
			self.has_been_used_once = 1;
			self play_sound_on_ent( "purchase" );
			self sethintstring( &"ZOMBIE_WEAPONCOSTAMMO", cost, ammo_cost );
			self setcursorhint( "HINT_NOICON" );
			player maps/mp/zombies/_zm_score::minus_to_player_score( self.zombie_cost );
			doors = getentarray( self.target, "targetname" );
			i = 0;
			while ( i < doors.size )
			{
				doors[ i ] thread weapon_cabinet_door_open( doors[ i ].script_noteworthy );
				i++;
			}
			player_has_weapon = player has_weapon_or_upgrade( self.zombie_weapon_upgrade );
			if ( !player_has_weapon )
			{
				player weapon_give( self.zombie_weapon_upgrade );
			}
			else if ( player has_upgrade( self.zombie_weapon_upgrade ) )
			{
				player ammo_give( self.zombie_weapon_upgrade + "_upgraded" );
			}
			else
			{
				player ammo_give( self.zombie_weapon_upgrade );
			}
			continue;
		}
		else
		{
			play_sound_on_ent( "no_purchase" );
			player maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "no_money_weapon" );
		}
	}
}

get_player_weapondata( player, weapon )
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
	}
	else
	{
		weapondata[ "clip" ] = 0;
		weapondata[ "stock" ] = 0;
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

weapon_is_better( left, right )
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
		else
		{
			if ( left_upgraded )
			{
				return 1;
			}
		}
	}
	return 0;
}

merge_weapons( oldweapondata, newweapondata )
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

weapondata_give( weapondata )
{
	current = get_player_weapon_with_same_base( weapondata[ "name" ] );
	if ( isDefined( current ) )
	{
		curweapondata = get_player_weapondata( self, current );
		self takeweapon( current );
		weapondata = merge_weapons( curweapondata, weapondata );
	}
	name = weapondata[ "name" ];
	weapon_give( name );
	dw_name = weapondualwieldweaponname( name );
	alt_name = weaponaltweaponname( name );
	if ( name != "none" )
	{
		self setweaponammoclip( name, weapondata[ "clip" ] );
		self setweaponammostock( name, weapondata[ "stock" ] );
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
