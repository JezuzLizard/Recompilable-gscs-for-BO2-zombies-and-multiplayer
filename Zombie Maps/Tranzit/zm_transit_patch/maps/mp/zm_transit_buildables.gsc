#include maps/mp/zm_transit_sq;
#include maps/mp/zombies/_zm_buildables;
#include maps/mp/zm_transit_utility;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init_buildables()
{
	level.buildable_piece_count = 27;
	add_zombie_buildable( "riotshield_zm", &"ZOMBIE_BUILD_RIOT", &"ZOMBIE_BUILDING_RIOT", &"ZOMBIE_BOUGHT_RIOT" );
	add_zombie_buildable( "jetgun_zm", &"ZOMBIE_BUILD_JETGUN", &"ZOMBIE_BUILDING_JETGUN", &"ZOMBIE_BOUGHT_JETGUN" );
	add_zombie_buildable( "turret", &"ZOMBIE_BUILD_TURRET", &"ZOMBIE_BUILDING_TURRET", &"ZOMBIE_BOUGHT_TURRET" );
	add_zombie_buildable( "electric_trap", &"ZOMBIE_BUILD_ELECTRIC_TRAP", &"ZOMBIE_BUILDING_ELECTRIC_TRAP", &"ZOMBIE_BOUGHT_ELECTRIC_TRAP" );
	add_zombie_buildable( "cattlecatcher", &"ZOMBIE_BUILD_CATTLE_CATCHER", &"ZOMBIE_BUILDING_CATTLE_CATCHER" );
	add_zombie_buildable( "bushatch", &"ZOMBIE_BUILD_BUSHATCH", &"ZOMBIE_BUILDING_BUSHATCH" );
	add_zombie_buildable( "dinerhatch", &"ZOMBIE_BUILD_DINERHATCH", &"ZOMBIE_BUILDING_DINERHATCH" );
	add_zombie_buildable( "busladder", &"ZOMBIE_BUILD_BUSLADDER", &"ZOMBIE_BUILDING_BUSLADDER" );
	add_zombie_buildable( "powerswitch", &"ZOMBIE_BUILD_POWER_SWITCH", &"ZOMBIE_BUILDING_POWER_SWITCH" );
	add_zombie_buildable( "pap", &"ZOMBIE_BUILD_PAP", &"ZOMBIE_BUILDING_PAP" );
	add_zombie_buildable( "turbine", &"ZOMBIE_BUILD_TURBINE", &"ZOMBIE_BUILDING_TURBINE", &"ZOMBIE_BOUGHT_TURBINE" );
	add_zombie_buildable( "sq_common", &"ZOMBIE_BUILD_SQ_COMMON", &"ZOMBIE_BUILDING_SQ_COMMON" );
}

include_buildables()
{
	battery = generate_zombie_buildable_piece( "pap", "p6_zm_buildable_battery", 32, 64, 0, "zm_hud_icon_battery", ::onpickup_common, ::ondrop_common, undefined, "tag_part_03", undefined, 1 );
	riotshield_dolly = generate_zombie_buildable_piece( "riotshield_zm", "t6_wpn_zmb_shield_dolly", 32, 64, 0, "zm_hud_icon_dolly", ::onpickup_common, ::ondrop_common, undefined, "TAG_RIOT_SHIELD_DOLLY", undefined, 2 );
	riotshield_door = generate_zombie_buildable_piece( "riotshield_zm", "t6_wpn_zmb_shield_door", 48, 15, 25, "zm_hud_icon_cardoor", ::onpickup_common, ::ondrop_common, undefined, "TAG_RIOT_SHIELD_DOOR", undefined, 3 );
	riotshield = spawnstruct();
	riotshield.name = "riotshield_zm";
	riotshield add_buildable_piece( riotshield_dolly );
	riotshield add_buildable_piece( riotshield_door );
	riotshield.onbuyweapon = ::onbuyweapon_riotshield;
	riotshield.triggerthink = ::riotshieldbuildable;
	include_buildable( riotshield );
	maps/mp/zombies/_zm_buildables::hide_buildable_table_model( "riotshield_zm_buildable_trigger" );
	powerswitch_arm = generate_zombie_buildable_piece( "powerswitch", "p6_zm_buildable_pswitch_hand", 32, 64, 10, "zm_hud_icon_arm", ::onpickup_common, ::ondrop_common, undefined, undefined, undefined, 4 );
	powerswitch_lever = generate_zombie_buildable_piece( "powerswitch", "p6_zm_buildable_pswitch_body", 48, 64, 0, "zm_hud_icon_panel", ::onpickup_common, ::ondrop_common, undefined, undefined, undefined, 5 );
	powerswitch_box = generate_zombie_buildable_piece( "powerswitch", "p6_zm_buildable_pswitch_lever", 32, 15, 0, "zm_hud_icon_lever", ::onpickup_common, ::ondrop_common, undefined, undefined, undefined, 6 );
	powerswitch = spawnstruct();
	powerswitch.name = "powerswitch";
	powerswitch add_buildable_piece( powerswitch_arm );
	powerswitch add_buildable_piece( powerswitch_lever );
	powerswitch add_buildable_piece( powerswitch_box );
	powerswitch.onuseplantobject = ::onuseplantobject_powerswitch;
	powerswitch.triggerthink = ::powerswitchbuildable;
	include_buildable( powerswitch );
	packapunch_machine = generate_zombie_buildable_piece( "pap", "p6_zm_buildable_pap_body", 48, 64, 0, "zm_hud_icon_papbody", ::onpickup_common, ::ondrop_common, undefined, "tag_part_02", undefined, 7 );
	packapunch_legs = generate_zombie_buildable_piece( "pap", "p6_zm_buildable_pap_table", 48, 15, 0, "zm_hud_icon_chairleg", ::onpickup_common, ::ondrop_common, undefined, "tag_part_01", undefined, 8 );
	packapunch = spawnstruct();
	packapunch.name = "pap";
	packapunch add_buildable_piece( battery, "tag_part_03", 0 );
	packapunch add_buildable_piece( packapunch_machine );
	packapunch add_buildable_piece( packapunch_legs );
	packapunch.triggerthink = ::papbuildable;
	include_buildable( packapunch );
	maps/mp/zombies/_zm_buildables::hide_buildable_table_model( "pap_buildable_trigger" );
	turbine_fan = generate_zombie_buildable_piece( "turbine", "p6_zm_buildable_turbine_fan", 32, 64, 0, "zm_hud_icon_fan", ::onpickup_common, ::ondrop_common, undefined, "tag_part_03", undefined, 9 );
	turbine_panel = generate_zombie_buildable_piece( "turbine", "p6_zm_buildable_turbine_rudder", 32, 64, 0, "zm_hud_icon_rudder", ::onpickup_common, ::ondrop_common, undefined, "tag_part_04", undefined, 10 );
	turbine_body = generate_zombie_buildable_piece( "turbine", "p6_zm_buildable_turbine_mannequin", 32, 15, 0, "zm_hud_icon_mannequin", ::onpickup_common, ::ondrop_common, undefined, "tag_part_01", undefined, 11 );
	turbine = spawnstruct();
	turbine.name = "turbine";
	turbine add_buildable_piece( turbine_fan );
	turbine add_buildable_piece( turbine_panel );
	turbine add_buildable_piece( turbine_body );
	turbine.onuseplantobject = ::onuseplantobject_turbine;
	turbine.triggerthink = ::turbinebuildable;
	include_buildable( turbine );
	maps/mp/zombies/_zm_buildables::hide_buildable_table_model( "turbine_buildable_trigger" );
	turret_barrel = generate_zombie_buildable_piece( "turret", "t6_wpn_lmg_rpd_world", 32, 64, 10, "zm_hud_icon_turrethead", ::onpickup_common, ::ondrop_common, undefined, "tag_aim", undefined, 12 );
	turret_body = generate_zombie_buildable_piece( "turret", "p6_zm_buildable_turret_mower", 48, 64, 0, "zm_hud_icon_lawnmower", ::onpickup_common, ::ondrop_common, undefined, "tag_part_01", undefined, 13 );
	turret_ammo = generate_zombie_buildable_piece( "turret", "p6_zm_buildable_turret_ammo", 32, 15, 0, "zm_hud_icon_ammobox", ::onpickup_common, ::ondrop_common, undefined, "tag_part_02", undefined, 14 );
	turret = spawnstruct();
	turret.name = "turret";
	turret add_buildable_piece( turret_barrel );
	turret add_buildable_piece( turret_body );
	turret add_buildable_piece( turret_ammo );
	turret.triggerthink = ::turretbuildable;
	include_buildable( turret );
	maps/mp/zombies/_zm_buildables::hide_buildable_table_model( "turret_buildable_trigger" );
	electric_trap_spool = generate_zombie_buildable_piece( "electric_trap", "p6_zm_buildable_etrap_base", 32, 64, 0, "zm_hud_icon_coil", ::onpickup_common, ::ondrop_common, undefined, "tag_part_02", undefined, 15 );
	electric_trap_coil = generate_zombie_buildable_piece( "electric_trap", "p6_zm_buildable_etrap_tvtube", 32, 64, 10, "zm_hud_icon_tvtube", ::onpickup_common, ::ondrop_common, undefined, "tag_part_01", undefined, 16 );
	electric_trap = spawnstruct();
	electric_trap.name = "electric_trap";
	electric_trap add_buildable_piece( electric_trap_spool );
	electric_trap add_buildable_piece( electric_trap_coil );
	electric_trap add_buildable_piece( battery, "tag_part_03", 0 );
	electric_trap.triggerthink = ::electrictrapbuildable;
	include_buildable( electric_trap );
	maps/mp/zombies/_zm_buildables::hide_buildable_table_model( "electric_trap_buildable_trigger" );
	jetgun_wires = generate_zombie_buildable_piece( "jetgun_zm", "p6_zm_buildable_jetgun_wires", 32, 64, 0, "zm_hud_icon_jetgun_wires", ::onpickup_common, ::ondrop_common, undefined, "TAG_WIRES", undefined, 17 );
	jetgun_engine = generate_zombie_buildable_piece( "jetgun_zm", "p6_zm_buildable_jetgun_engine", 48, 64, 0, "zm_hud_icon_jetgun_engine", ::onpickup_common, ::ondrop_common, undefined, "TAG_ENGINE", undefined, 18 );
	jetgun_gauges = generate_zombie_buildable_piece( "jetgun_zm", "p6_zm_buildable_jetgun_guages", 32, 15, 0, "zm_hud_icon_jetgun_gauges", ::onpickup_common, ::ondrop_common, undefined, "TAG_DIALS", undefined, 19 );
	jetgun_handle = generate_zombie_buildable_piece( "jetgun_zm", "p6_zm_buildable_jetgun_handles", 32, 15, 0, "zm_hud_icon_jetgun_handles", ::onpickup_common, ::ondrop_common, undefined, "TAG_HANDLES", undefined, 20 );
	jetgun = spawnstruct();
	jetgun.name = "jetgun_zm";
	jetgun add_buildable_piece( jetgun_wires );
	jetgun add_buildable_piece( jetgun_engine );
	jetgun add_buildable_piece( jetgun_gauges );
	jetgun add_buildable_piece( jetgun_handle );
	jetgun.onbuyweapon = ::onbuyweapon_jetgun;
	jetgun.triggerthink = ::jetgunbuildable;
	include_buildable( jetgun );
	maps/mp/zombies/_zm_buildables::hide_buildable_table_model( "jetgun_zm_buildable_trigger" );
	cattlecatcher_plow = generate_zombie_buildable_piece( "cattlecatcher", "veh_t6_civ_bus_zombie_cow_catcher", 72, 100, 20, "zm_hud_icon_plow", ::onpickup_common, ::ondrop_common, undefined, undefined, undefined, 21 );
	bushatch_hatch = generate_zombie_buildable_piece( "bushatch", "veh_t6_civ_bus_zombie_roof_hatch", 32, 64, 5, "zm_hud_icon_hatch", ::onpickup_common, ::ondrop_common, undefined, undefined, undefined, 22 );
	busladder_ladder = generate_zombie_buildable_piece( "busladder", "com_stepladder_large_closed", 32, 64, 0, "zm_hud_icon_ladder", ::onpickup_common, ::ondrop_common, undefined, undefined, undefined, 23 );
	cattlecatcher = spawnstruct();
	cattlecatcher.name = "cattlecatcher";
	cattlecatcher add_buildable_piece( cattlecatcher_plow );
	cattlecatcher.triggerthink = ::cattlecatcherbuildable;
	include_buildable( cattlecatcher );
	bushatch = spawnstruct();
	bushatch.name = "bushatch";
	bushatch add_buildable_piece( bushatch_hatch, undefined, 1 );
	bushatch.triggerthink = ::bushatchbuildable;
	include_buildable( bushatch );
	dinerhatch = spawnstruct();
	dinerhatch.name = "dinerhatch";
	dinerhatch add_buildable_piece( bushatch_hatch, undefined, 1 );
	dinerhatch.triggerthink = ::dinerhatchbuildable;
	include_buildable( dinerhatch );
	busladder = spawnstruct();
	busladder.name = "busladder";
	busladder add_buildable_piece( busladder_ladder );
	busladder.triggerthink = ::busladderbuildable;
	include_buildable( busladder );
	if ( !isDefined( level.gamedifficulty ) || level.gamedifficulty != 0 )
	{
		sq_common_electricbox = generate_zombie_buildable_piece( "sq_common", "p6_zm_buildable_sq_electric_box", 32, 64, 0, "zm_hud_icon_sq_powerbox", ::onpickup_common, ::ondrop_common, undefined, "tag_part_02", undefined, 24 );
		sq_common_meteor = generate_zombie_buildable_piece( "sq_common", "p6_zm_buildable_sq_meteor", 76, 64, 0, "zm_hud_icon_sq_meteor", ::onpickup_common, ::ondrop_common, undefined, "tag_part_04", undefined, 25 );
		sq_common_scaffolding = generate_zombie_buildable_piece( "sq_common", "p6_zm_buildable_sq_scaffolding", 64, 96, 0, "zm_hud_icon_sq_scafold", ::onpickup_common, ::ondrop_common, undefined, "tag_part_01", undefined, 26 );
		sq_common_transceiver = generate_zombie_buildable_piece( "sq_common", "p6_zm_buildable_sq_transceiver", 64, 96, 0, "zm_hud_icon_sq_tranceiver", ::onpickup_common, ::ondrop_common, undefined, "tag_part_03", undefined, 27 );
		sqcommon = spawnstruct();
		sqcommon.name = "sq_common";
		sqcommon add_buildable_piece( sq_common_electricbox );
		sqcommon add_buildable_piece( sq_common_meteor );
		sqcommon add_buildable_piece( sq_common_scaffolding );
		sqcommon add_buildable_piece( sq_common_transceiver );
		sqcommon.triggerthink = ::sqcommonbuildable;
		include_buildable( sqcommon );
		maps/mp/zombies/_zm_buildables::hide_buildable_table_model( "sq_common_buildable_trigger" );
	}
}

sqcommonbuildable()
{
	level.sq_buildable = maps/mp/zombies/_zm_buildables::buildable_trigger_think( "sq_common_buildable_trigger", "sq_common", "sq_common", "", 1, 0 );
}

busladderbuildable()
{
	blb = maps/mp/zombies/_zm_buildables::vehicle_buildable_trigger_think( level.the_bus, "bus_ladder_trigger", "busladder", "busladder", "", 0, 0 );
	blb.require_look_at = 0;
	blb.custom_buildablestub_update_prompt = ::busisonormovingbuildableupdateprompt;
}

busisonormovingbuildableupdateprompt( player, sethintstringnow, buildabletrigger )
{
	if ( isDefined( player.isonbus ) || player.isonbus && level.the_bus getspeedmph() > 0 )
	{
		if ( isDefined( self ) )
		{
			self.hint_string = "";
			if ( isDefined( sethintstringnow ) && sethintstringnow && isDefined( buildabletrigger ) )
			{
				buildabletrigger sethintstring( self.hint_string );
			}
		}
		return 0;
	}
	return 1;
}

bushatchbuildable()
{
	bhb = maps/mp/zombies/_zm_buildables::vehicle_buildable_trigger_think( level.the_bus, "bus_hatch_bottom_trigger", "bushatch", "bushatch", "", 0, 0 );
	bhb.require_look_at = 0;
}

dinerhatchbuildable()
{
	dhb = maps/mp/zombies/_zm_buildables::buildable_trigger_think( "diner_hatch_trigger", "dinerhatch", "dinerhatch", "", 1, 0 );
	dhb.require_look_at = 0;
}

cattlecatcherbuildable()
{
	ccb = maps/mp/zombies/_zm_buildables::vehicle_buildable_trigger_think( level.the_bus, "trigger_plow", "cattlecatcher", "cattlecatcher", "", 0, 0 );
	ccb.require_look_at = 0;
	ccb.custom_buildablestub_update_prompt = ::busisonormovingbuildableupdateprompt;
}

papbuildable()
{
	maps/mp/zombies/_zm_buildables::buildable_trigger_think( "pap_buildable_trigger", "pap", "pap", "", 1, 0 );
}

riotshieldbuildable()
{
	maps/mp/zombies/_zm_buildables::buildable_trigger_think( "riotshield_zm_buildable_trigger", "riotshield_zm", "riotshield_zm", &"ZOMBIE_GRAB_RIOTSHIELD", 1, 1 );
}

powerswitchbuildable()
{
	maps/mp/zombies/_zm_buildables::buildable_trigger_think( "powerswitch_buildable_trigger", "powerswitch", "powerswitch", "", 1, 0 );
}

turbinebuildable()
{
	level.turbine_buildable = maps/mp/zombies/_zm_buildables::buildable_trigger_think( "turbine_buildable_trigger", "turbine", "equip_turbine_zm", &"ZOMBIE_GRAB_TURBINE_PICKUP_HINT_STRING", 1, 1 );
}

turretbuildable()
{
	maps/mp/zombies/_zm_buildables::buildable_trigger_think( "turret_buildable_trigger", "turret", "equip_turret_zm", &"ZOMBIE_GRAB_TURRET_PICKUP_HINT_STRING", 1, 1 );
}

electrictrapbuildable()
{
	maps/mp/zombies/_zm_buildables::buildable_trigger_think( "electric_trap_buildable_trigger", "electric_trap", "equip_electrictrap_zm", &"ZOMBIE_GRAB_ELECTRICTRAP", 1, 1 );
}

jetgunbuildable()
{
	level.jetgun_buildable = maps/mp/zombies/_zm_buildables::buildable_trigger_think( "jetgun_zm_buildable_trigger", "jetgun_zm", "jetgun_zm", &"ZOMBIE_GRAB_JETGUN", 1, 1 );
}

ondrop_common( player )
{
/#
	println( "ZM >> Common part callback onDrop()" );
#/
	self droponbus( player );
	self.piece_owner = undefined;
}

onpickup_common( player )
{
/#
	println( "ZM >> Common part callback onPickup()" );
#/
	player playsound( "zmb_buildable_pickup" );
	self pickupfrombus();
	self.piece_owner = player;
	if ( isDefined( self.buildablename ) )
	{
		if ( self.buildablename == "turbine" )
		{
			check_for_buildable_turbine_vox( level.turbine_buildable, 0 );
			return;
		}
		else
		{
			if ( self.buildablename == "jetgun_zm" )
			{
				check_for_buildable_jetgun_vox( level.jetgun_buildable, 0 );
			}
		}
	}
}

onbuyweapon_riotshield( player )
{
	if ( isDefined( player.player_shield_reset_health ) )
	{
		player [[ player.player_shield_reset_health ]]();
	}
	if ( isDefined( player.player_shield_reset_location ) )
	{
		player [[ player.player_shield_reset_location ]]();
	}
}

onuseplantobject_powerswitch( player )
{
/#
	println( "ZM >> PowerSwitch Buildable CallBack onUsePlantObject()" );
#/
	if ( !isDefined( player player_get_buildable_piece() ) )
	{
		return;
	}
	switch( player player_get_buildable_piece().modelname )
	{
		case "p6_zm_buildable_pswitch_hand":
			getent( "powerswitch_p6_zm_buildable_pswitch_hand", "targetname" ) show();
			break;
		case "p6_zm_buildable_pswitch_body":
			panel = getent( "powerswitch_p6_zm_buildable_pswitch_body", "targetname" );
			panel show();
			break;
		case "p6_zm_buildable_pswitch_lever":
			getent( "powerswitch_p6_zm_buildable_pswitch_lever", "targetname" ) show();
			break;
	}
}

onuseplantobject_turbine( player )
{
/#
	println( "ZM >> Turbine Buildable CallBack onUsePlantObject()" );
#/
	buildable = self.buildablezone;
	first_part = "tag_part_03";
	second_part = "tag_part_02";
	i = 0;
	while ( i < buildable.pieces.size )
	{
		if ( buildable.pieces[ i ].part_name == first_part )
		{
			if ( isDefined( buildable.pieces[ i ].built ) || buildable.pieces[ i ].built && player player_get_buildable_piece().part_name == first_part )
			{
				buildable.stub.model showpart( second_part );
				i++;
				continue;
			}
			else
			{
				buildable.stub.model hidepart( second_part );
			}
		}
		i++;
	}
	check_for_buildable_turbine_vox( level.turbine_buildable, 1 );
}

check_for_buildable_turbine_vox( stub, start_build_counter )
{
	if ( isDefined( level.maxis_turbine_vox_played ) && level.maxis_turbine_vox_played )
	{
		return;
	}
	buildable = stub.buildablezone;
	piece_counter = 0;
	build_counter = start_build_counter;
	i = 0;
	while ( i < buildable.pieces.size )
	{
		if ( isDefined( buildable.pieces[ i ].built ) || buildable.pieces[ i ].built && isDefined( buildable.pieces[ i ].piece_owner ) )
		{
			piece_counter++;
		}
		if ( isDefined( buildable.pieces[ i ].built ) && buildable.pieces[ i ].built )
		{
			build_counter++;
		}
		i++;
	}
	if ( build_counter >= 2 && piece_counter == 3 )
	{
		if ( !flag( "power_on" ) )
		{
			level.maxis_turbine_vox_played = 1;
			level thread maps/mp/zm_transit_sq::maxissay( "vox_maxi_turbine_final_0", stub.origin );
		}
	}
}

onbuyweapon_jetgun( player )
{
	player switchtoweapon( self.stub.weaponname );
}

check_for_buildable_jetgun_vox( stub, start_build_counter )
{
	if ( isDefined( level.rich_jetgun_vox_played ) || level.rich_jetgun_vox_played && !flag( "power_on" ) )
	{
		return;
	}
	buildable = stub.buildablezone;
	piece_counter = 0;
	build_counter = start_build_counter;
	i = 0;
	while ( i < buildable.pieces.size )
	{
		if ( isDefined( buildable.pieces[ i ].built ) || buildable.pieces[ i ].built && isDefined( buildable.pieces[ i ].piece_owner ) )
		{
			piece_counter++;
		}
		if ( isDefined( buildable.pieces[ i ].built ) && buildable.pieces[ i ].built )
		{
			build_counter++;
		}
		i++;
	}
	if ( build_counter == 3 && piece_counter == 4 )
	{
		level thread maps/mp/zm_transit_sq::richtofensay( "vox_zmba_sidequest_jet_last_0" );
	}
	else
	{
		if ( build_counter == 4 )
		{
			level thread maps/mp/zm_transit_sq::richtofensay( "vox_zmba_sidequest_jet_complete_0" );
		}
	}
}

onenduse_sidequestcommon( team, player, result )
{
	if ( isDefined( result ) && result )
	{
		if ( isDefined( level.sq_clip ) )
		{
			level.sq_clip trigger_on();
			level.sq_clip connectpaths();
		}
	}
}

droponbus( player )
{
	if ( isDefined( player ) && isDefined( player.isonbus ) && player.isonbus )
	{
		self.model linkto( level.the_bus );
		self.linked_to_bus = 1;
		self.unitrigger.link_parent = level.the_bus;
	}
	else
	{
		self.unitrigger.link_parent = undefined;
	}
}

pickupfrombus()
{
	if ( isDefined( self.linked_to_bus ) && self.linked_to_bus )
	{
		if ( isDefined( self.model ) )
		{
			self.model unlink();
		}
		self.linked_to_bus = undefined;
	}
	if ( isDefined( self.unitrigger ) )
	{
		self.unitrigger.link_parent = undefined;
	}
}
