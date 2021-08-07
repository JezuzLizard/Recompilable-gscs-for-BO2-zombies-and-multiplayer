#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/zombies/_zm_weap_claymore;
#include maps/mp/zombies/_zm_melee_weapon;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/zombies/_zm_score;
#include maps/mp/zombies/_zm_buildables_pooled;
#include maps/mp/zombies/_zm_sidequests;
#include maps/mp/zombies/_zm_magicbox;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/zombies/_zm_buildables;
#include maps/mp/_utility;
#include common_scripts/utility;

prepare_chalk_weapon_list()
{
	level.buildable_wallbuy_weapons = [];
	level.buildable_wallbuy_weapons[ 0 ] = "ak74u_zm";
	level.buildable_wallbuy_weapons[ 1 ] = "an94_zm";
	level.buildable_wallbuy_weapons[ 2 ] = "pdw57_zm";
	level.buildable_wallbuy_weapons[ 3 ] = "svu_zm";
	level.buildable_wallbuy_weapons[ 4 ] = "tazer_knuckles_zm";
	level.buildable_wallbuy_weapons[ 5 ] = "870mcs_zm";
	level.buildable_wallbuy_weapon_hints = [];
	level.buildable_wallbuy_weapon_hints[ "ak74u_zm" ] = &"ZM_BURIED_WB_AK74U";
	level.buildable_wallbuy_weapon_hints[ "an94_zm" ] = &"ZM_BURIED_WB_AN94";
	level.buildable_wallbuy_weapon_hints[ "pdw57_zm" ] = &"ZM_BURIED_WB_PDW57";
	level.buildable_wallbuy_weapon_hints[ "svu_zm" ] = &"ZM_BURIED_WB_SVU";
	level.buildable_wallbuy_weapon_hints[ "tazer_knuckles_zm" ] = &"ZM_BURIED_WB_TAZER";
	level.buildable_wallbuy_weapon_hints[ "870mcs_zm" ] = &"ZM_BURIED_WB_870MCS";
	level.buildable_wallbuy_pickup_hints = [];
	level.buildable_wallbuy_pickup_hints[ "ak74u_zm" ] = &"ZM_BURIED_PU_AK74U";
	level.buildable_wallbuy_pickup_hints[ "an94_zm" ] = &"ZM_BURIED_PU_AN94";
	level.buildable_wallbuy_pickup_hints[ "pdw57_zm" ] = &"ZM_BURIED_PU_PDW57";
	level.buildable_wallbuy_pickup_hints[ "svu_zm" ] = &"ZM_BURIED_PU_SVU";
	level.buildable_wallbuy_pickup_hints[ "tazer_knuckles_zm" ] = &"ZM_BURIED_PU_TAZER";
	level.buildable_wallbuy_pickup_hints[ "870mcs_zm" ] = &"ZM_BURIED_PU_870MCS";
	level.buildable_wallbuy_weapon_models = [];
	level.buildable_wallbuy_weapon_angles = [];
	_a64 = level.buildable_wallbuy_weapon_models;
	_k64 = getFirstArrayKey( _a64 );
	while ( isDefined( _k64 ) )
	{
		model = _a64[ _k64 ];
		if ( isDefined( model ) )
		{
			precachemodel( model );
		}
		_k64 = getNextArrayKey( _a64, _k64 );
	}
}

init_buildables( buildablesenabledlist )
{
	registerclientfield( "scriptmover", "buildable_glint_fx", 12000, 1, "int" );
	precacheitem( "chalk_draw_zm" );
	precacheitem( "no_hands_zm" );
	level._effect[ "wallbuy_replace" ] = loadfx( "maps/zombie_buried/fx_buried_booze_candy_spawn" );
	level._effect[ "wallbuy_drawing" ] = loadfx( "maps/zombie/fx_zmb_wall_dyn_chalk_drawing" );
	level.str_buildables_build = &"ZOMBIE_BUILD_SQ_COMMON";
	level.str_buildables_building = &"ZOMBIE_BUILDING_SQ_COMMON";
	level.str_buildables_grab_part = &"ZOMBIE_BUILD_PIECE_GRAB";
	level.str_buildables_swap_part = &"ZOMBIE_BUILD_PIECE_SWITCH";
	level.safe_place_for_buildable_piece = ::safe_place_for_buildable_piece;
	level.buildable_slot_count = max( 1, 2 ) + 1;
	level.buildable_clientfields = [];
	level.buildable_clientfields[ 0 ] = "buildable";
	level.buildable_clientfields[ 1 ] = "buildable" + "_pu";
	level.buildable_piece_counts = [];
	level.buildable_piece_counts[ 0 ] = 15;
	level.buildable_piece_counts[ 1 ] = 4;
	if ( -1 )
	{
		level.buildable_clientfields[ 2 ] = "buildable" + "_sq";
		level.buildable_piece_counts[ 2 ] = 13;
	}
	if ( isinarray( buildablesenabledlist, "sq_common" ) )
	{
		add_zombie_buildable( "sq_common", level.str_buildables_build, level.str_buildables_building );
	}
	if ( isinarray( buildablesenabledlist, "buried_sq_tpo_switch" ) )
	{
		add_zombie_buildable( "buried_sq_tpo_switch", level.str_buildables_build, level.str_buildables_building );
	}
	if ( isinarray( buildablesenabledlist, "buried_sq_ghost_lamp" ) )
	{
		add_zombie_buildable( "buried_sq_ghost_lamp", level.str_buildables_build, level.str_buildables_building );
	}
	if ( isinarray( buildablesenabledlist, "buried_sq_bt_m_tower" ) )
	{
		add_zombie_buildable( "buried_sq_bt_m_tower", level.str_buildables_build, level.str_buildables_building );
	}
	if ( isinarray( buildablesenabledlist, "buried_sq_bt_r_tower" ) )
	{
		add_zombie_buildable( "buried_sq_bt_r_tower", level.str_buildables_build, level.str_buildables_building );
	}
	if ( isinarray( buildablesenabledlist, "buried_sq_oillamp" ) )
	{
		add_zombie_buildable( "buried_sq_oillamp", level.str_buildables_build, level.str_buildables_building, &"NULL_EMPTY" );
	}
	if ( isinarray( buildablesenabledlist, "turbine" ) )
	{
		add_zombie_buildable( "turbine", level.str_buildables_build, level.str_buildables_building, &"NULL_EMPTY" );
		add_zombie_buildable_vox_category( "turbine", "trb" );
	}
	if ( isinarray( buildablesenabledlist, "springpad_zm" ) )
	{
		add_zombie_buildable( "springpad_zm", level.str_buildables_build, level.str_buildables_building, &"NULL_EMPTY" );
		add_zombie_buildable_vox_category( "springpad_zm", "stm" );
	}
	if ( isinarray( buildablesenabledlist, "subwoofer_zm" ) )
	{
		add_zombie_buildable( "subwoofer_zm", level.str_buildables_build, level.str_buildables_building, &"NULL_EMPTY" );
		add_zombie_buildable_vox_category( "subwoofer_zm", "sw" );
	}
	if ( isinarray( buildablesenabledlist, "headchopper_zm" ) )
	{
		add_zombie_buildable( "headchopper_zm", level.str_buildables_build, level.str_buildables_building, &"NULL_EMPTY" );
		add_zombie_buildable_vox_category( "headchopper_zm", "hc" );
	}
	if ( isinarray( buildablesenabledlist, "booze" ) )
	{
		add_zombie_buildable( "booze", &"ZM_BURIED_LEAVE_BOOZE", level.str_buildables_building, &"NULL_EMPTY" );
		add_zombie_buildable_piece_vox_category( "booze", "booze" );
	}
	if ( isinarray( buildablesenabledlist, "candy" ) )
	{
		add_zombie_buildable( "candy", &"ZM_BURIED_LEAVE_CANDY", level.str_buildables_building, &"NULL_EMPTY" );
		add_zombie_buildable_piece_vox_category( "candy", "candy" );
	}
	if ( isinarray( buildablesenabledlist, "chalk" ) )
	{
		add_zombie_buildable( "chalk", &"NULL_EMPTY", level.str_buildables_building, &"NULL_EMPTY" );
		add_zombie_buildable_piece_vox_category( "chalk", "gunshop_chalk", 300 );
	}
	if ( isinarray( buildablesenabledlist, "sloth" ) )
	{
		add_zombie_buildable( "sloth", &"ZM_BURIED_BOOZE_GV", level.str_buildables_building, &"NULL_EMPTY" );
	}
	if ( isinarray( buildablesenabledlist, "keys_zm" ) )
	{
		add_zombie_buildable( "keys_zm", &"ZM_BURIED_KEYS_BL", level.str_buildables_building, &"NULL_EMPTY" );
		add_zombie_buildable_piece_vox_category( "keys_zm", "key" );
	}
	level thread chalk_host_migration();
}

include_buildables( buildablesenabledlist )
{
	turbine_fan = generate_zombie_buildable_piece( "turbine", "p6_zm_buildable_turbine_fan", 32, 64, 0, "zm_hud_icon_fan", ::onpickup_common, ::ondrop_common, undefined, "tag_part_03", undefined, 1 );
	turbine_panel = generate_zombie_buildable_piece( "turbine", "p6_zm_buildable_turbine_rudder", 32, 64, 0, "zm_hud_icon_rudder", ::onpickup_common, ::ondrop_common, undefined, "tag_part_04", undefined, 2 );
	turbine_body = generate_zombie_buildable_piece( "turbine", "p6_zm_buildable_turbine_mannequin", 32, 15, 0, "zm_hud_icon_mannequin", ::onpickup_common, ::ondrop_common, undefined, "tag_part_01", undefined, 3 );
	springpad_door = generate_zombie_buildable_piece( "springpad_zm", "p6_zm_buildable_tramplesteam_door", 32, 64, 0, "zom_hud_trample_steam_screen", ::onpickup_common, ::ondrop_common, undefined, "Tag_part_02", undefined, 4 );
	springpad_flag = generate_zombie_buildable_piece( "springpad_zm", "p6_zm_buildable_tramplesteam_bellows", 32, 15, 0, "zom_hud_trample_steam_bellow", ::onpickup_common, ::ondrop_common, undefined, "Tag_part_04", undefined, 5 );
	springpad_motor = generate_zombie_buildable_piece( "springpad_zm", "p6_zm_buildable_tramplesteam_compressor", 32, 15, 0, "zom_hud_trample_steam_compressor", ::onpickup_common, ::ondrop_common, undefined, "Tag_part_01", undefined, 6 );
	springpad_whistle = generate_zombie_buildable_piece( "springpad_zm", "p6_zm_buildable_tramplesteam_flag", 48, 15, 0, "zom_hud_trample_steam_whistle", ::onpickup_common, ::ondrop_common, undefined, "Tag_part_03", undefined, 7 );
	sq_common_electricbox = generate_zombie_buildable_piece( "sq_common", "p6_zm_buildable_sq_electric_box", 32, 64, 0, "zm_hud_icon_sq_powerbox", ::onpickup_common, ::ondrop_common, undefined, "tag_part_02", undefined, 1, 2 );
	sq_common_meteor = generate_zombie_buildable_piece( "sq_common", "p6_zm_buildable_sq_meteor", 32, 64, 0, "zm_hud_icon_sq_meteor", ::onpickup_common, ::ondrop_common, undefined, "tag_part_04", undefined, 2, 2 );
	sq_common_scaffolding = generate_zombie_buildable_piece( "sq_common", "p6_zm_buildable_sq_scaffolding", 64, 96, 0, "zm_hud_icon_sq_scafold", ::onpickup_common, ::ondrop_common, undefined, "tag_part_01", undefined, 3, 2 );
	sq_common_transceiver = generate_zombie_buildable_piece( "sq_common", "p6_zm_buildable_sq_transceiver", 64, 96, 0, "zm_hud_icon_sq_tranceiver", ::onpickup_common, ::ondrop_common, undefined, "tag_part_03", undefined, 4, 2 );
	sq_lamp_piece = generate_zombie_buildable_piece( "buried_sq_oillamp", "p6_zm_bu_lantern_silver_on", 32, 64, 0, "zm_hud_icon_jetgun_engine", ::onpickup_common, ::ondrop_common, undefined, undefined, undefined, 13, 2 );
	sq_m_tower_vacuum_tube = generate_zombie_buildable_piece( "buried_sq_bt_m_tower", "p6_zm_bu_sq_vaccume_tube", 32, 64, 0, "zm_hud_icon_sq_powerbox", ::onpickup_common, ::ondrop_common, undefined, "j_vaccume_01", undefined, 7, 2 );
	sq_m_tower_battery = generate_zombie_buildable_piece( "buried_sq_bt_m_tower", "p6_zm_bu_sq_buildable_battery", 32, 64, 0, "zm_hud_icon_battery", ::onpickup_common, ::ondrop_common, undefined, "j_battery", undefined, 8, 2 );
	sq_r_tower_crystal = generate_zombie_buildable_piece( "buried_sq_bt_r_tower", "p6_zm_bu_sq_crystal", 96, 64, 0, "zm_hud_icon_sq_powerbox", ::onpickup_common, ::ondrop_common, undefined, "j_crystal_01", undefined, 9, 2 );
	sq_r_tower_satellite = generate_zombie_buildable_piece( "buried_sq_bt_r_tower", "p6_zm_bu_sq_satellite_dish", 32, 64, 0, "zm_hud_icon_sq_powerbox", ::onpickup_common, ::ondrop_common, "j_satellite", undefined, undefined, 10, 2 );
	sq_s_tower_antenna = generate_zombie_buildable_piece( "buried_sq_bt_m_tower", "p6_zm_bu_sq_antenna", 32, 64, 0, "zm_hud_icon_sq_powerbox", ::onpickup_common, ::ondrop_common, undefined, "j_antenna", undefined, 11, 2 );
	sq_s_tower_wire = generate_zombie_buildable_piece( "buried_sq_bt_m_tower", "p6_zm_bu_sq_wire_spool", 32, 64, 0, "zm_hud_icon_sq_powerbox", ::onpickup_common, ::ondrop_common, undefined, "j_wire", undefined, 12, 2 );
	subwoofer_speaker = generate_zombie_buildable_piece( "subwoofer_zm", "t6_wpn_zmb_subwoofer_parts_speaker", 32, 64, 0, "zom_hud_icon_buildable_woof_speaker", ::onpickup_common, ::ondrop_common, undefined, "TAG_SPEAKER", undefined, 8 );
	subwoofer_motor = generate_zombie_buildable_piece( "subwoofer_zm", "t6_wpn_zmb_subwoofer_parts_motor", 48, 15, 0, "zom_hud_icon_buildable_woof_motor", ::onpickup_common, ::ondrop_common, undefined, "TAG_ENGINE", undefined, 9 );
	subwoofer_table = generate_zombie_buildable_piece( "subwoofer_zm", "t6_wpn_zmb_subwoofer_parts_table", 48, 15, 0, "zom_hud_icon_buildable_woof_frame", ::onpickup_common, ::ondrop_common, undefined, "TAG_SPIN", undefined, 11 );
	subwoofer_mount = generate_zombie_buildable_piece( "subwoofer_zm", "t6_wpn_zmb_subwoofer_parts_mount", 32, 15, 0, "zom_hud_icon_buildable_woof_chains", ::onpickup_common, ::ondrop_common, undefined, "TAG_MOUNT", undefined, 10 );
	headchopper_blade = generate_zombie_buildable_piece( "headchopper_zm", "t6_wpn_zmb_chopper_part_blade", 32, 64, 0, "zom_hud_icon_buildable_chop_a", ::onpickup_common, ::ondrop_common, undefined, "TAG_SAW", undefined, 12 );
	headchopper_crank = generate_zombie_buildable_piece( "headchopper_zm", "t6_wpn_zmb_chopper_part_crank", 32, 15, 0, "zom_hud_icon_buildable_chop_b", ::onpickup_common, ::ondrop_common, undefined, "TAG_CRANK", undefined, 13 );
	headchopper_hinge = generate_zombie_buildable_piece( "headchopper_zm", "t6_wpn_zmb_chopper_part_hinge", 32, 15, 0, "zom_hud_icon_buildable_chop_c", ::onpickup_common, ::ondrop_common, undefined, "TAG_GEARS", undefined, 14 );
	headchopper_mount = generate_zombie_buildable_piece( "headchopper_zm", "t6_wpn_zmb_chopper_part_mount", 32, 15, 0, "zom_hud_icon_buildable_chop_d", ::onpickup_common, ::ondrop_common, undefined, "TAG_MOUNT", undefined, 15 );
	bottle = generate_zombie_buildable_piece( "booze", "p6_zm_bu_booze", 32, 64, 2,4, "zom_hud_icon_buildable_sloth_booze", ::onpickup_booze, ::ondrop_booze, undefined, undefined, 0, 1, 1 );
	cane = generate_zombie_buildable_piece( "candy", "p6_zm_bu_sloth_candy_bowl", 32, 64, 2,4, "zom_hud_icon_buildable_sloth_candy", ::onpickup_candy, ::ondrop_candy, undefined, undefined, 0, 2, 1 );
	pencil = generate_zombie_buildable_piece( "chalk", "p6_zm_bu_chalk", 32, 64, 2,4, "zom_hud_icon_buildable_weap_chalk", ::onpickup_common, ::ondrop_chalk, undefined, undefined, 0, 4, 1 );
	key_chain = generate_zombie_buildable_piece( "keys_zm", "p6_zm_bu_sloth_key", 32, 64, 9, "zom_hud_icon_buildable_sloth_key", ::onpickup_keys, ::ondrop_keys, undefined, undefined, 0, 3, 1 );
	if ( isinarray( buildablesenabledlist, "turbine" ) )
	{
		turbine = spawnstruct();
		turbine.name = "turbine";
		turbine add_buildable_piece( turbine_fan );
		turbine add_buildable_piece( turbine_panel );
		turbine add_buildable_piece( turbine_body );
		turbine.onuseplantobject = ::onuseplantobject_turbine;
		turbine.triggerthink = ::turbinebuildable;
		include_buildable( turbine );
		maps/mp/zombies/_zm_buildables::hide_buildable_table_model( "turbine_buildable_trigger" );
	}
	if ( isinarray( buildablesenabledlist, "springpad_zm" ) )
	{
		springpad = spawnstruct();
		springpad.name = "springpad_zm";
		springpad add_buildable_piece( springpad_door );
		springpad add_buildable_piece( springpad_flag );
		springpad add_buildable_piece( springpad_motor );
		springpad add_buildable_piece( springpad_whistle );
		springpad.triggerthink = ::springpadbuildable;
		include_buildable( springpad );
	}
	if ( isinarray( buildablesenabledlist, "sq_common" ) )
	{
		if ( is_sidequest_allowed( "zclassic" ) )
		{
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
	if ( isinarray( buildablesenabledlist, "buried_sq_oillamp" ) )
	{
		if ( is_sidequest_allowed( "zclassic" ) )
		{
			sq_oillamp = spawnstruct();
			sq_oillamp.name = "buried_sq_oillamp";
			sq_oillamp add_buildable_piece( sq_lamp_piece );
			sq_oillamp.triggerthink = ::sqoillampbuildable;
			include_buildable( sq_oillamp );
		}
	}
	if ( isinarray( buildablesenabledlist, "buried_sq_bt_m_tower" ) )
	{
		if ( is_sidequest_allowed( "zclassic" ) )
		{
			sq_m_tower = spawnstruct();
			sq_m_tower.name = "buried_sq_bt_m_tower";
			sq_m_tower add_buildable_piece( sq_m_tower_vacuum_tube );
			sq_m_tower add_buildable_piece( sq_m_tower_battery );
			sq_m_tower add_buildable_piece( sq_s_tower_antenna, undefined, 1 );
			sq_m_tower add_buildable_piece( sq_s_tower_wire, undefined, 1 );
			sq_m_tower.triggerthink = ::sqmtowerbuildable;
			sq_m_tower.onuseplantobject = ::onuseplantobject_mtower;
			include_buildable( sq_m_tower );
		}
		else
		{
			remove_maxis_tower();
		}
	}
	if ( isinarray( buildablesenabledlist, "buried_sq_bt_r_tower" ) )
	{
		if ( is_sidequest_allowed( "zclassic" ) )
		{
			sq_r_tower = spawnstruct();
			sq_r_tower.name = "buried_sq_bt_r_tower";
			sq_r_tower add_buildable_piece( sq_r_tower_crystal );
			sq_r_tower add_buildable_piece( sq_r_tower_satellite );
			sq_r_tower add_buildable_piece( sq_s_tower_antenna, undefined, 1 );
			sq_r_tower add_buildable_piece( sq_s_tower_wire, undefined, 1 );
			sq_r_tower.triggerthink = ::sqrtowerbuildable;
			sq_r_tower.onuseplantobject = ::onuseplantobject_rtower;
			include_buildable( sq_r_tower );
		}
		else
		{
			remove_ricky_tower();
		}
	}
	if ( isinarray( buildablesenabledlist, "subwoofer_zm" ) )
	{
		subwoofer = spawnstruct();
		subwoofer.name = "subwoofer_zm";
		subwoofer add_buildable_piece( subwoofer_speaker );
		subwoofer add_buildable_piece( subwoofer_motor );
		subwoofer add_buildable_piece( subwoofer_table );
		subwoofer add_buildable_piece( subwoofer_mount );
		subwoofer.triggerthink = ::subwooferbuildable;
		include_buildable( subwoofer );
	}
	if ( isinarray( buildablesenabledlist, "headchopper_zm" ) )
	{
		ent = getent( "buildable_headchopper", "targetname" );
		ent setmodel( "t6_wpn_zmb_chopper" );
		headchopper = spawnstruct();
		headchopper.name = "headchopper_zm";
		headchopper add_buildable_piece( headchopper_blade );
		headchopper add_buildable_piece( headchopper_crank );
		headchopper add_buildable_piece( headchopper_hinge );
		headchopper add_buildable_piece( headchopper_mount );
		headchopper.triggerthink = ::headchopperbuildable;
		include_buildable( headchopper );
	}
	if ( isinarray( buildablesenabledlist, "booze" ) )
	{
		level.booze_model = "p6_zm_bu_sloth_booze_jug";
		precachemodel( level.booze_model );
		bottle.hint_grab = &"ZM_BURIED_BOOZE_G";
		bottle.hint_swap = &"ZM_BURIED_BOOZE_G";
		bottle manage_multiple_pieces( 2 );
		bottle.onspawn = ::piece_spawn_booze;
		bottle.onunspawn = ::piece_unspawn_booze;
		bottle.ondestroy = ::piece_destroy_booze;
		level.booze_piece = bottle;
		booze = spawnstruct();
		booze.name = "booze";
		booze.hint_more = &"ZM_BURIED_I_NEED_BOOZE";
		booze.hint_wrong = &"ZM_BURIED_I_SAID_BOOZE";
		booze add_buildable_piece( bottle );
		booze.triggerthink = ::boozebuildable;
		booze.onuseplantobject = ::onuseplantobject_booze_and_candy;
		include_buildable( booze );
	}
	if ( isinarray( buildablesenabledlist, "candy" ) )
	{
		level.candy_model = "p6_zm_bu_sloth_candy_bowl";
		precachemodel( level.candy_model );
		cane.hint_grab = &"ZM_BURIED_CANDY_G";
		cane.hint_swap = &"ZM_BURIED_CANDY_G";
		cane manage_multiple_pieces( 1 );
		cane.onspawn = ::piece_spawn_candy;
		cane.onunspawn = ::piece_unspawn_candy;
		cane.ondestroy = ::piece_destroy_candy;
		level.candy_piece = cane;
		candy = spawnstruct();
		candy.name = "candy";
		candy.hint_more = &"ZM_BURIED_I_WANT_CANDY";
		candy.hint_wrong = &"ZM_BURIED_THATS_NOT_CANDY";
		candy add_buildable_piece( cane );
		candy.triggerthink = ::candybuildable;
		candy.onuseplantobject = ::onuseplantobject_booze_and_candy;
		include_buildable( candy );
	}
	if ( isinarray( buildablesenabledlist, "sloth" ) )
	{
		sloth_buildable = spawnstruct();
		sloth_buildable.name = "sloth";
		sloth_buildable.hint_more = &"NULL_EMPTY";
		sloth_buildable.hint_wrong = &"NULL_EMPTY";
		sloth_buildable add_buildable_piece( bottle );
		sloth_buildable add_buildable_piece( cane );
		sloth_buildable.triggerthink = ::slothbuildable;
		sloth_buildable.onuseplantobject = ::onuseplantobject_sloth;
		sloth_buildable.snd_build_add_vo_override = ::empty;
		include_buildable( sloth_buildable );
	}
	if ( isinarray( buildablesenabledlist, "chalk" ) )
	{
		pencil.hint_grab = level.str_buildables_grab_part;
		pencil.hint_swap = level.str_buildables_swap_part;
		pencil.onspawn = ::piece_spawn_chalk;
		pencil.ondestroy = ::piece_destroy_chalk;
		pencil manage_multiple_pieces( 6, 6 );
		chalk = spawnstruct();
		chalk.name = "chalk";
		chalk.hint_more = &"NULL_EMPTY";
		chalk.hint_wrong = &"NULL_EMPTY";
		chalk add_buildable_piece( pencil );
		chalk.triggerthink = ::chalkbuildable;
		chalk.onuseplantobject = ::onuseplantobject_chalk;
		if ( isDefined( level.buy_random_wallbuys ) && level.buy_random_wallbuys )
		{
			chalk.oncantuse = ::oncantuse_chalk;
		}
		chalk.onbeginuse = ::onbeginuse_chalk;
		chalk.onenduse = ::onenduse_chalk;
		include_buildable( chalk );
	}
	if ( isinarray( buildablesenabledlist, "keys_zm" ) )
	{
		key_chain.onspawn = ::onspawn_keys;
		key_chain manage_multiple_pieces( 2 );
		key_chain.hint_grab = &"ZM_BURIED_KEY_G";
		key_chain.hint_swap = &"ZM_BURIED_KEY_G";
		key = spawnstruct();
		key.name = "keys_zm";
		key add_buildable_piece( key_chain );
		key.triggerthink = ::keysbuildable;
		key.onuseplantobject = ::onuseplantobject_key;
		key.hint_wrong = &"NULL_EMPTY";
		include_buildable( key );
	}
	generate_piece_makers();
	level thread maps/mp/zombies/_zm_buildables_pooled::randomize_pooled_buildables( "buried" );
}

sqcommonbuildable()
{
	level.sq_buildable = maps/mp/zombies/_zm_buildables::buildable_trigger_think( "sq_common_buildable_trigger", "sq_common", "sq_common", "", 1, 0 );
	if ( isDefined( level.sq_buildable ) )
	{
		level.sq_buildable.ignore_open_sesame = 1;
	}
}

sqmtowerbuildable()
{
	level.sq_mtower_buildable = maps/mp/zombies/_zm_buildables::buildable_trigger_think( "sq_m_tower_buildable_trigger", "buried_sq_bt_m_tower", "buried_sq_bt_m_tower", "", 1, 0 );
	level.sq_mtower_buildable.ignore_open_sesame = 1;
}

remove_all_ents( named )
{
	ents = getentarray( named, "targetname" );
	_a516 = ents;
	_k516 = getFirstArrayKey( _a516 );
	while ( isDefined( _k516 ) )
	{
		ent = _a516[ _k516 ];
		ent delete();
		_k516 = getNextArrayKey( _a516, _k516 );
	}
}

remove_maxis_tower()
{
	remove_all_ents( "sq_m_tower_buildable_trigger" );
}

sqrtowerbuildable()
{
	level.sq_rtower_buildable = maps/mp/zombies/_zm_buildables::buildable_trigger_think( "sq_r_tower_buildable_trigger", "buried_sq_bt_r_tower", "buried_sq_bt_r_tower", "", 1, 0 );
	level.sq_rtower_buildable.ignore_open_sesame = 1;
}

remove_ricky_tower()
{
	remove_all_ents( "guillotine_trigger" );
	remove_all_ents( "ricky_tower_col" );
	remove_all_ents( "sq_r_tower_buildable_trigger" );
}

turbinebuildable()
{
	level.turbine_buildable = maps/mp/zombies/_zm_buildables::buildable_trigger_think( "turbine_buildable_trigger", "turbine", "equip_turbine_zm", &"ZOMBIE_EQUIP_TURBINE_PICKUP_HINT_STRING", 1, 1 );
	maps/mp/zombies/_zm_buildables_pooled::add_buildable_to_pool( level.turbine_buildable, "buried" );
}

springpadbuildable()
{
	stub = maps/mp/zombies/_zm_buildables::buildable_trigger_think( "springpad_zm_buildable_trigger", "springpad_zm", "equip_springpad_zm", &"ZM_BURIED_EQ_SP_PHS", 1, 1 );
	maps/mp/zombies/_zm_buildables_pooled::add_buildable_to_pool( stub, "buried" );
}

subwooferbuildable()
{
	stub = maps/mp/zombies/_zm_buildables::buildable_trigger_think( "subwoofer_zm_buildable_trigger", "subwoofer_zm", "equip_subwoofer_zm", &"ZM_BURIED_EQ_SW_PHS", 1, 1 );
	maps/mp/zombies/_zm_buildables_pooled::add_buildable_to_pool( stub, "buried" );
}

headchopperbuildable()
{
	stub = maps/mp/zombies/_zm_buildables::buildable_trigger_think( "headchopper_buildable_trigger", "headchopper_zm", "equip_headchopper_zm", &"ZM_BURIED_EQ_HC_PHS", 1, 1 );
	maps/mp/zombies/_zm_buildables_pooled::add_buildable_to_pool( stub, "buried" );
}

boozebuildable()
{
	booze_builds = maps/mp/zombies/_zm_buildables::buildable_trigger_think_array( "booze_buildable_trigger", "booze", "booze", &"ZM_BURIED_BOOZE_G", 1, 0 );
	_a567 = booze_builds;
	_k567 = getFirstArrayKey( _a567 );
	while ( isDefined( _k567 ) )
	{
		stub = _a567[ _k567 ];
		stub.ignore_open_sesame = 1;
		stub.require_look_at = 0;
		stub bpstub_set_custom_think_callback( ::bptrigger_think_unbuild_no_return );
		_k567 = getNextArrayKey( _a567, _k567 );
	}
}

candybuildable()
{
	candy_builds = maps/mp/zombies/_zm_buildables::buildable_trigger_think_array( "candy_buildable_trigger", "candy", "candy", &"ZM_BURIED_CANDY_G", 1, 0 );
	_a579 = candy_builds;
	_k579 = getFirstArrayKey( _a579 );
	while ( isDefined( _k579 ) )
	{
		stub = _a579[ _k579 ];
		stub.ignore_open_sesame = 1;
		stub.require_look_at = 0;
		stub bpstub_set_custom_think_callback( ::bptrigger_think_unbuild_no_return );
		_k579 = getNextArrayKey( _a579, _k579 );
	}
}

sloth_in_armory_near_bench()
{
	return 1;
}

slothbuildable()
{
}

chalkbuildable()
{
	level.chalk_builds = maps/mp/zombies/_zm_buildables::buildable_trigger_think_array( "chalk_buildable_trigger", "chalk", "chalk", level.str_buildables_grab_part, 1, 0 );
	_a630 = level.chalk_builds;
	_k630 = getFirstArrayKey( _a630 );
	while ( isDefined( _k630 ) )
	{
		stub = _a630[ _k630 ];
		stub.prompt_and_visibility_func = ::chalk_prompt;
		stub.script_length = 16;
		stub.ignore_open_sesame = 1;
		stub.build_weapon = "chalk_draw_zm";
		stub.building_prompt = &"ZM_BURIED_DRAW";
		if ( isDefined( stub.target ) )
		{
			wallbuy = getstruct( stub.target, "targetname" );
			stub.origin = wallbuy.origin;
			stub.angles = wallbuy.angles;
			if ( isDefined( wallbuy.script_location ) )
			{
				stub.location = wallbuy.script_location;
			}
		}
		_k630 = getNextArrayKey( _a630, _k630 );
	}
}

keysbuildable()
{
	door = maps/mp/zombies/_zm_buildables::buildable_trigger_think( "cell_door_trigger", "keys_zm", "keys_zm", "", 1, 3 );
	if ( isDefined( door ) )
	{
		door.ignore_open_sesame = 1;
		door.prompt_and_visibility_func = ::cell_door_key_prompt;
		door.script_unitrigger_type = "unitrigger_radius_use";
		door.radius = 32;
		door.test_radius_sq = ( door.radius + 15 ) * ( door.radius + 15 );
		door.building_prompt = &"ZM_BURIED_UNLOCKING";
		thread watch_cell_open_close( door );
	}
}

safe_place_for_buildable_piece( piece )
{
	if ( self is_jumping() )
	{
		return 0;
	}
	if ( piece.buildablename == "booze" )
	{
		return 0;
	}
	return 1;
}

onuseplantobject_mtower( player )
{
	if ( !isDefined( player player_get_buildable_piece( 2 ) ) )
	{
		return;
	}
	switch( player player_get_buildable_piece( 2 ).modelname )
	{
		case "p6_zm_bu_sq_vaccume_tube":
			level setclientfield( "sq_gl_b_vt", 1 );
			break;
		case "p6_zm_bu_sq_buildable_battery":
			level setclientfield( "sq_gl_b_bb", 1 );
			break;
		case "p6_zm_bu_sq_antenna":
			level setclientfield( "sq_gl_b_a", 1 );
			break;
		case "p6_zm_bu_sq_wire_spool":
			level setclientfield( "sq_gl_b_ws", 1 );
			break;
	}
	level notify( "mtower_object_planted" );
}

onuseplantobject_rtower( player )
{
	if ( !isDefined( player player_get_buildable_piece( 2 ) ) )
	{
		return;
	}
	m_tower = getent( "sq_guillotine", "targetname" );
	switch( player player_get_buildable_piece( 2 ).modelname )
	{
		case "p6_zm_bu_sq_crystal":
			m_tower sq_tower_spawn_attachment( "p6_zm_bu_sq_crystal", "j_crystal_01" );
			break;
		case "p6_zm_bu_sq_satellite_dish":
			m_tower sq_tower_spawn_attachment( "p6_zm_bu_sq_satellite_dish", "j_satellite" );
			break;
		case "p6_zm_bu_sq_antenna":
			m_tower sq_tower_spawn_attachment( "p6_zm_bu_sq_antenna", "j_antenna" );
			break;
		case "p6_zm_bu_sq_wire_spool":
			m_tower sq_tower_spawn_attachment( "p6_zm_bu_sq_wire_spool", "j_spool" );
			break;
	}
	level notify( "rtower_object_planted" );
}

sq_tower_spawn_attachment( str_model, str_tag )
{
	m_part = spawn( "script_model", self gettagorigin( str_tag ) );
	m_part.angles = self gettagangles( str_tag );
	m_part setmodel( str_model );
}

sqoillampbuildable()
{
	level.sq_lamp_generator_unitrig = maps/mp/zombies/_zm_buildables::buildable_trigger_think( "generator_use_trigger", "buried_sq_oillamp", "buried_sq_oillamp", "", 1, 0 );
	if ( isDefined( level.sq_lamp_generator_unitrig ) )
	{
		level.sq_lamp_generator_unitrig.ignore_open_sesame = 1;
		level.sq_lamp_generator_unitrig.buildablestub_reject_func = ::sq_generator_buildablestub_reject_func;
	}
}

sq_generator_buildablestub_reject_func( player )
{
	if ( !flag( "ftl_lantern_charged" ) )
	{
		return 1;
	}
	return 0;
}

ondrop_common( player )
{
/#
	println( "ZM >> Common part callback onDrop()" );
#/
	self.piece_owner = undefined;
}

onpickup_common( player )
{
/#
	println( "ZM >> Common part callback onPickup()" );
#/
	self.piece_owner = player;
	if ( isDefined( self.buildablename ) )
	{
		sound = "zmb_buildable_pickup";
		if ( self.buildablename == "candy" )
		{
			sound = "zmb_candy_pickup";
		}
		if ( self.buildablename == "booze" )
		{
			sound = "zmb_booze_pickup";
		}
		if ( self.buildablename == "chalk" )
		{
			sound = "zmb_chalk_grab";
		}
		player playsound( sound );
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
			if ( isDefined( buildable.pieces[ i ].built ) || buildable.pieces[ i ].built && isDefined( player player_get_buildable_piece( 0 ) ) && player player_get_buildable_piece( 0 ).part_name == first_part )
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
		}
	}
}

watch_player_purchase( name, piece )
{
	level endon( "wait_respawn_" + name );
	level endon( "start_of_round" );
	allow_players_purchase( name, 1 );
	level waittill( "player_purchase_" + name, player );
	allow_players_purchase( name, 0 );
	player player_take_piece( piece );
}

wait_respawn_candy_booze( piece, name )
{
	level notify( "wait_respawn_" + name );
	level endon( "wait_respawn_" + name );
	level endon( "player_purchase_" + name );
	level thread watch_player_purchase( name, piece );
	level waittill( "start_of_round" );
	allow_players_purchase( name, 0 );
	piece piece_spawn_at();
}

wait_respawn_booze_at_start( piece )
{
	wait 4;
	if ( isDefined( level.jail_barricade_down ) && level.jail_barricade_down )
	{
		level thread wait_respawn_candy_booze( piece, "booze" );
	}
	else
	{
		piece piece_spawn_at( piece.start_origin, piece.start_angles );
	}
}

piece_spawn_booze()
{
	self.model setmodel( level.booze_model );
	playfxontag( level._effect[ "booze_candy_spawn" ], self.model, "tag_origin" );
	self.model setclientfield( "buildable_glint_fx", 1 );
}

piece_unspawn_booze()
{
	if ( isDefined( self.model ) )
	{
		piece_model = self.model;
		self.model = undefined;
		piece_model thread destroyglintfx();
	}
}

piece_destroy_booze()
{
	if ( isDefined( level.jail_barricade_down ) && level.jail_barricade_down )
	{
		level thread wait_respawn_candy_booze( self, "booze" );
	}
	else
	{
		level thread wait_respawn_booze_at_start( self );
	}
}

onpickup_booze( player )
{
	level notify( "sloth_pickup" );
	onpickup_common( player );
	if ( isDefined( level.jail_barricade_down ) && !level.jail_barricade_down )
	{
		if ( !isDefined( level.booze_start_origin ) )
		{
			level.booze_start_origin = self.start_origin;
			level.booze_start_angles = self.start_angles;
		}
	}
}

piece_spawn_candy()
{
	self.model setmodel( level.candy_model );
	playfxontag( level._effect[ "booze_candy_spawn" ], self.model, "tag_origin" );
	self.model setclientfield( "buildable_glint_fx", 1 );
}

piece_unspawn_candy()
{
	if ( isDefined( self.model ) )
	{
		piece_model = self.model;
		self.model = undefined;
		piece_model thread destroyglintfx();
	}
}

piece_destroy_candy()
{
	self.built = 0;
	self.building = 0;
	level thread wait_respawn_candy_booze( self, "candy" );
}

onpickup_candy( player )
{
	level notify( "sloth_pickup" );
	onpickup_common( player );
}

ondrop_booze( player )
{
	level notify( "sloth_drop" );
	player notify( "sloth_drop" );
	piece = player player_get_buildable_piece( 1 );
	if ( isDefined( piece ) )
	{
		piece.model setclientfield( "buildable_glint_fx", 1 );
	}
	ondrop_common( player );
	if ( isDefined( level.jail_barricade_down ) && !level.jail_barricade_down )
	{
		thread wait_put_piece_back_in_jail( piece, level.booze_start_origin, level.booze_start_angles );
	}
}

wait_put_piece_back_in_jail( piece, origin, angles )
{
	if ( isDefined( piece ) )
	{
		piece piece_unspawn();
		wait 4;
		piece piece_unspawn();
		piece piece_spawn_at( origin, angles );
	}
}

ondrop_candy( player )
{
	level notify( "sloth_drop" );
	player notify( "sloth_drop" );
	piece = player player_get_buildable_piece( 1 );
	if ( isDefined( piece ) )
	{
		piece.model setclientfield( "buildable_glint_fx", 1 );
	}
	ondrop_common( player );
}

onuseplantobject_booze_and_candy( player )
{
	if ( isDefined( self.script_noteworthy ) )
	{
		switch( self.script_noteworthy )
		{
			case "candy_bench":
				player thread candy_bench( self );
				break;
			return;
		}
	}
}

candy_bench( stub )
{
	wait 0,2;
	level notify( "candy_bench" );
}

onuseplantobject_sloth( player )
{
}

piece_spawn_chalk()
{
	if ( !isDefined( self.first_origin ) )
	{
		self.first_origin = self.start_origin;
		self.first_angles = self.start_angles;
	}
	self thread piece_spawn_chalk_internal();
}

chalk_host_migration()
{
	level endon( "end_game" );
	level notify( "chalk_hostmigration" );
	level endon( "chalk_hostmigration" );
	while ( 1 )
	{
		level waittill( "host_migration_end" );
		while ( !isDefined( level.chalk_pieces ) )
		{
			continue;
		}
		_a1103 = level.chalk_pieces;
		_k1103 = getFirstArrayKey( _a1103 );
		while ( isDefined( _k1103 ) )
		{
			chalk = _a1103[ _k1103 ];
			if ( isDefined( chalk.model ) )
			{
				weapon = chalk.script_noteworthy;
				fx = level._effect[ "m14_zm_fx" ];
				if ( isDefined( level._effect[ weapon + "_chalk_fx" ] ) )
				{
					fx = level._effect[ weapon + "_chalk_fx" ];
				}
				if ( isDefined( level.chalk_buildable_pieces_hide ) && !level.chalk_buildable_pieces_hide )
				{
					playfxontag( fx, chalk.model, "tag_origin" );
				}
			}
			wait_network_frame();
			_k1103 = getNextArrayKey( _a1103, _k1103 );
		}
	}
}

piece_spawn_chalk_internal()
{
	weapon = self.script_noteworthy;
	if ( isDefined( weapon ) )
	{
		if ( !isDefined( level.chalk_pieces ) )
		{
			level.chalk_pieces = [];
		}
		level.chalk_pieces = add_to_array( level.chalk_pieces, self, 0 );
		self.model setmodel( "tag_origin" );
		wait 0,05;
		fx = level._effect[ "m14_zm_fx" ];
		if ( isDefined( level._effect[ weapon + "_chalk_fx" ] ) )
		{
			fx = level._effect[ weapon + "_chalk_fx" ];
		}
		if ( isDefined( level.chalk_buildable_pieces_hide ) && !level.chalk_buildable_pieces_hide )
		{
			playfxontag( fx, self.model, "tag_origin" );
		}
		else
		{
			self.model.origin += vectorScale( ( 0, 0, 0 ), 1000 );
		}
		if ( isDefined( level.monolingustic_prompt_format ) && level.monolingustic_prompt_format )
		{
			self.hint_grab = &"ZM_BURIED_WB";
			self.hint_grab_parm1 = get_weapon_display_name( weapon );
		}
		else
		{
			if ( isDefined( level.buildable_wallbuy_pickup_hints[ weapon ] ) )
			{
				self.hint_grab = level.buildable_wallbuy_pickup_hints[ weapon ];
				self.hint_grab_parm1 = undefined;
			}
			else
			{
				self.hint_grab = &"ZM_BURIED_WALLBUILD";
				self.hint_grab_parm1 = undefined;
			}
		}
		self.hint_swap = self.hint_grab;
		self.hint_swap_parm1 = self.hint_grab_parm1;
		if ( getDvarInt( #"1F0A2129" ) )
		{
			self.cursor_hint = "HINT_WEAPON";
			self.cursor_hint_weapon = weapon;
		}
	}
}

piece_destroy_chalk()
{
	thread wait_unbuild_chalk( self );
}

wait_unbuild_chalk( piece )
{
	wait 0,1;
	piece.built = 0;
}

ondrop_chalk( player )
{
	self piece_unspawn();
	self piece_spawn_at( self.first_origin, self.first_angles );
}

pick_up( thing )
{
	candidate_list = [];
	_a1225 = level.zones;
	_k1225 = getFirstArrayKey( _a1225 );
	while ( isDefined( _k1225 ) )
	{
		zone = _a1225[ _k1225 ];
		if ( isDefined( zone.unitrigger_stubs ) )
		{
			candidate_list = arraycombine( candidate_list, zone.unitrigger_stubs, 1, 0 );
		}
		_k1225 = getNextArrayKey( _a1225, _k1225 );
	}
	candidate_list = array_randomize( candidate_list );
	_a1235 = candidate_list;
	_k1235 = getFirstArrayKey( _a1235 );
	while ( isDefined( _k1235 ) )
	{
		stub = _a1235[ _k1235 ];
		if ( isDefined( stub.piece ) && stub.piece.buildablename == thing )
		{
			stub.piece piece_unspawn();
			return stub.piece;
		}
		_k1235 = getNextArrayKey( _a1235, _k1235 );
	}
	return undefined;
}

chalk_prompt( player )
{
	if ( isDefined( level.buy_random_wallbuys ) && level.buy_random_wallbuys )
	{
		if ( isDefined( self.stub.built ) && !self.stub.built )
		{
			if ( !isDefined( player player_get_buildable_piece( 1 ) ) || !self.stub.buildablezone buildable_has_piece( player player_get_buildable_piece( 1 ) ) )
			{
				self.stub.cost = 1500;
				self.stub.hint_parm1 = 1500;
				self.stub.hint_string = &"ZM_BURIED_RANDOM_WALLBUY";
				self sethintstring( self.stub.hint_string, self.stub.cost );
				return 1;
			}
		}
	}
	can_use = self buildabletrigger_update_prompt( player );
	if ( can_use )
	{
		piece = player player_get_buildable_piece( 1 );
		if ( isDefined( piece ) )
		{
			weapon = piece.script_noteworthy;
			if ( isDefined( weapon ) )
			{
				self.stub.hint_string = level.buildable_wallbuy_weapon_hints[ weapon ];
				self sethintstring( self.stub.hint_string );
			}
		}
	}
	return can_use;
}

buy_random_wallbuy( player, cost )
{
	temp_piece = undefined;
	if ( !is_player_valid( player ) )
	{
		player thread ignore_triggers( 0,5 );
		return temp_piece;
	}
	if ( !player can_buy_weapon() )
	{
		wait 0,1;
		return temp_piece;
	}
	if ( player has_powerup_weapon() )
	{
		wait 0,1;
		return temp_piece;
	}
	if ( player.score >= cost )
	{
		temp_piece = player pick_up( "chalk" );
		if ( !isDefined( temp_piece ) )
		{
			return temp_piece;
		}
		player maps/mp/zombies/_zm_score::minus_to_player_score( cost );
		bbprint( "zombie_uses", "playername %s playerscore %d round %d cost %d name %s x %f y %f z %f type %s", player.name, player.score, level.round_number, cost, self.zombie_weapon_upgrade, self.origin, "weapon" );
		player maps/mp/zombies/_zm_stats::increment_client_stat( "wallbuy_weapons_purchased" );
		player maps/mp/zombies/_zm_stats::increment_player_stat( "wallbuy_weapons_purchased" );
		return temp_piece;
	}
	player play_sound_on_ent( "no_purchase" );
	player maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "no_money_weapon" );
	return temp_piece;
}

onbeginuse_chalk( player )
{
	player thread player_draw_chalk( self );
}

player_draw_chalk( stub )
{
	self endon( "death" );
	self endon( "stop_action" );
	self notify( "end_chalk_dust" );
	self endon( "end_chalk_dust" );
	origin = stub.origin;
	forward = anglesToForward( stub.angles );
	while ( isalive( self ) )
	{
		playfx( level._effect[ "wallbuy_drawing" ], origin, forward );
		wait 0,1;
	}
}

onenduse_chalk( team, player, result )
{
	player notify( "end_chalk_dust" );
}

oncantuse_chalk( player )
{
	if ( self.built )
	{
		return;
	}
	if ( !isDefined( player player_get_buildable_piece( 1 ) ) || !self.buildablezone buildable_has_piece( player player_get_buildable_piece( 1 ) ) )
	{
		self.cost = 1500;
		piece = buy_random_wallbuy( player, self.cost );
		if ( !isDefined( piece ) )
		{
			return;
		}
		weapon = piece.script_noteworthy;
		if ( isDefined( weapon ) )
		{
			origin = self.origin;
			angles = self.angles;
			if ( isDefined( level._effect[ "wallbuy_replace" ] ) )
			{
				playfx( level._effect[ "wallbuy_replace" ], origin, anglesToForward( angles ) );
			}
			add_dynamic_wallbuy( weapon, self.target, 0 );
			if ( is_melee_weapon( weapon ) )
			{
				player maps/mp/zombies/_zm_melee_weapon::give_melee_weapon_by_name( weapon );
			}
			else
			{
				if ( is_lethal_grenade( weapon ) )
				{
					player takeweapon( player get_player_lethal_grenade() );
					player set_player_lethal_grenade( weapon );
				}
				else
				{
					if ( weapon == "claymore_zm" )
					{
						player thread maps/mp/zombies/_zm_weap_claymore::show_claymore_hint( "claymore_purchased" );
					}
				}
				player weapon_give( weapon );
			}
			if ( !isDefined( level.built_wallbuys ) )
			{
				level.built_wallbuys = 0;
			}
			level.built_wallbuys++;
			if ( level.built_wallbuys >= 6 )
			{
				level.built_wallbuys = -100;
			}
		}
		self buildablestub_finish_build( player );
		self buildablestub_remove();
		thread maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( self );
	}
}

onuseplantobject_chalk( entity )
{
	piece = entity player_get_buildable_piece( 1 );
	if ( isDefined( piece ) )
	{
		weapon = piece.script_noteworthy;
		if ( isDefined( weapon ) )
		{
			origin = self.origin;
			angles = self.angles;
			if ( isDefined( level._effect[ "wallbuy_replace" ] ) )
			{
				playfx( level._effect[ "wallbuy_replace" ], origin, anglesToForward( angles ) );
			}
			add_dynamic_wallbuy( weapon, self.target, 1 );
			if ( !isDefined( level.built_wallbuys ) )
			{
				level.built_wallbuys = 0;
			}
			level.built_wallbuys++;
			if ( isplayer( entity ) )
			{
				entity maps/mp/zombies/_zm_stats::increment_client_stat( "buried_wallbuy_placed", 0 );
				entity maps/mp/zombies/_zm_stats::increment_player_stat( "buried_wallbuy_placed" );
				entity maps/mp/zombies/_zm_stats::increment_client_stat( "buried_wallbuy_placed_" + weapon, 0 );
				entity maps/mp/zombies/_zm_stats::increment_player_stat( "buried_wallbuy_placed_" + weapon );
			}
			if ( level.built_wallbuys >= 6 )
			{
				if ( isplayer( entity ) )
				{
					entity maps/mp/zombies/_zm_score::player_add_points( "build_wallbuy", 2000 );
				}
				level.built_wallbuys = -100;
				return;
			}
			else
			{
				if ( isplayer( entity ) )
				{
					entity maps/mp/zombies/_zm_score::player_add_points( "build_wallbuy", 1000 );
				}
			}
		}
	}
}

onspawn_keys()
{
	if ( isDefined( self.unitrigger ) && isDefined( self.start_origin ) && self.model.origin == self.start_origin )
	{
		self.unitrigger.origin_parent = undefined;
		self.unitrigger.origin = self.model.origin + vectorScale( ( 0, 0, 0 ), 12 );
	}
}

onpickup_keys( player )
{
	onpickup_common( player );
	if ( isDefined( level.jail_barricade_down ) && !level.jail_barricade_down )
	{
		if ( !isDefined( level.key_start_origin ) )
		{
			level.key_start_origin = self.start_origin + vectorScale( ( 0, 0, 0 ), 6 );
			level.key_start_angles = self.start_angles;
		}
	}
}

ondrop_keys( player )
{
	piece = player player_get_buildable_piece( 1 );
	ondrop_common( player );
	if ( isDefined( level.jail_barricade_down ) && !level.jail_barricade_down )
	{
		thread wait_put_piece_back_in_jail( piece, level.key_start_origin, level.key_start_angles );
	}
}

cell_door_key_prompt( player )
{
	if ( isDefined( level.cell_open ) && level.cell_open )
	{
		self.stub.hint_string = "";
		self sethintstring( self.stub.hint_string );
		return 0;
	}
	return self buildabletrigger_update_prompt( player );
}

onuseplantobject_key( player )
{
	level notify( "cell_open" );
	player maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "sloth_unlocked" );
}

stub_suspend_buildable( door )
{
	door.buildablezone.pieces[ 0 ] piece_unspawn();
	thread maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( door );
}

stub_resume_buildable( door )
{
	maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( door, ::buildable_place_think );
}

watch_cell_open_close( door )
{
	level.cell_open = 0;
/#
	thread watch_opensesame();
#/
	while ( 1 )
	{
		level waittill( "cell_open" );
		level.cell_open = 1;
		wait 0,05;
		stub_suspend_buildable( door );
		level waittill( "cell_close" );
		level.cell_open = 0;
		stub_resume_buildable( door );
		stub_unbuild_buildable( door, 1 );
	}
}

watch_opensesame()
{
/#
	level waittill( "open_sesame" );
	level notify( "cell_open" );
#/
}

destroyglintfx()
{
	self setclientfield( "buildable_glint_fx", 0 );
	self ghost();
	wait_network_frame();
	wait_network_frame();
	wait_network_frame();
	if ( isDefined( self ) )
	{
		self delete();
	}
}

generate_piece_makers()
{
	level.piece_makers = [];
	level.piece_maker_prompts = [];
	level.piece_maker_prompts[ "booze" ] = &"ZM_BURIED_BOOZE_B";
	level.piece_maker_prompts[ "candy" ] = &"ZM_BURIED_CANDY_B";
	piece_maker_structs = getstructarray( "piece_purchase", "targetname" );
	_a1586 = piece_maker_structs;
	_k1586 = getFirstArrayKey( _a1586 );
	while ( isDefined( _k1586 ) )
	{
		pm = _a1586[ _k1586 ];
		piecename = pm.script_noteworthy;
		if ( isDefined( piecename ) )
		{
			level.piece_makers[ piecename ] = pm piece_maker_unitrigger( "piece_maker", ::piece_maker_update_prompt, ::piece_maker_think );
			level.piece_makers[ piecename ].piecename = piecename;
			level.piece_makers[ piecename ].allow_purchase = 0;
			level.piece_makers[ piecename ].notify_name = "player_purchase_" + piecename;
			if ( isDefined( level.piece_maker_prompts[ piecename ] ) )
			{
				level.piece_makers[ piecename ].buy_prompt = level.piece_maker_prompts[ piecename ];
				break;
			}
			else
			{
				level.piece_makers[ piecename ].buy_prompt = &"ZM_BURIED_BUY_UNKNOWN_STUFF";
			}
		}
		_k1586 = getNextArrayKey( _a1586, _k1586 );
	}
}

allow_players_purchase( name, allow_purchase )
{
	if ( isDefined( level.piece_makers[ name ] ) )
	{
		level.piece_makers[ name ].allow_purchase = allow_purchase;
	}
}

piece_maker_unitrigger( name, prompt_fn, think_fn )
{
	unitrigger_stub = spawnstruct();
	unitrigger_stub.origin = self.origin;
	if ( isDefined( self.script_angles ) )
	{
		unitrigger_stub.angles = self.script_angles;
	}
	else if ( isDefined( self.angles ) )
	{
		unitrigger_stub.angles = self.angles;
	}
	else
	{
		unitrigger_stub.angles = ( 0, 0, 0 );
	}
	unitrigger_stub.script_angles = unitrigger_stub.angles;
	if ( isDefined( self.script_length ) )
	{
		unitrigger_stub.script_length = self.script_length;
	}
	else
	{
		unitrigger_stub.script_length = 32;
	}
	if ( isDefined( self.script_width ) )
	{
		unitrigger_stub.script_width = self.script_width;
	}
	else
	{
		unitrigger_stub.script_width = 32;
	}
	if ( isDefined( self.script_height ) )
	{
		unitrigger_stub.script_height = self.script_height;
	}
	else
	{
		unitrigger_stub.script_height = 64;
	}
	if ( isDefined( self.radius ) )
	{
		unitrigger_stub.radius = self.radius;
	}
	else
	{
		unitrigger_stub.radius = 32;
	}
	if ( isDefined( self.script_unitrigger_type ) )
	{
		unitrigger_stub.script_unitrigger_type = self.script_unitrigger_type;
	}
	else
	{
		unitrigger_stub.script_unitrigger_type = "unitrigger_box_use";
		unitrigger_stub.origin -= anglesToRight( unitrigger_stub.angles ) * ( unitrigger_stub.script_length / 2 );
	}
	unitrigger_stub.cursor_hint = "HINT_NOICON";
	unitrigger_stub.targetname = name;
	maps/mp/zombies/_zm_unitrigger::unitrigger_force_per_player_triggers( unitrigger_stub, 1 );
	unitrigger_stub.prompt_and_visibility_func = prompt_fn;
	maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( unitrigger_stub, think_fn );
	return unitrigger_stub;
}

piece_maker_update_prompt( player )
{
	if ( isDefined( self.stub.allow_purchase ) && !self.stub.allow_purchase )
	{
		self sethintstring( "" );
		return 0;
	}
	if ( player.score < 1000 )
	{
		self sethintstring( "" );
		return 0;
	}
	else
	{
		self sethintstring( self.stub.buy_prompt, 1000 );
	}
	return 1;
}

piece_maker_think()
{
	self endon( "kill_trigger" );
	while ( 1 )
	{
		self waittill( "trigger", player );
		if ( isDefined( self.stub.allow_purchase ) && !self.stub.allow_purchase )
		{
			continue;
		}
		while ( !is_player_valid( player ) )
		{
			continue;
		}
		if ( player.score >= 1000 )
		{
			player.score -= 1000;
			level notify( self.stub.notify_name );
			self sethintstring( "" );
			continue;
		}
		else
		{
			self playsound( "evt_perk_deny" );
			player thread do_player_general_vox( "general", "exert_sigh", 10, 50 );
		}
	}
}
