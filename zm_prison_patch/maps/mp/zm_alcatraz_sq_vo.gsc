#include maps/mp/gametypes_zm/_hud;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zm_alcatraz_utility;
#include maps/mp/zombies/_zm_sidequests;
#include maps/mp/zombies/_zm_craftables;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/zombies/_zm_afterlife;
#include maps/_vehicle;
#include maps/_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

vo_see_map_trigger()
{
	level endon( "someone_completed_quest_cycle" );
	e_triggerer = undefined;
	t_map_vo_trigger = getent( "map_vo_trigger", "targetname" );
	b_has_line_played = 0;
	while ( !b_has_line_played )
	{
		t_map_vo_trigger waittill( "trigger", e_triggerer );
		players = getplayers();
		if ( !e_triggerer.dontspeak && !flag( "story_vo_playing" ) )
		{
			flag_set( "story_vo_playing" );
			e_triggerer do_player_general_vox( "quest", "find_map", undefined, 100 );
			wait 5;
			arrayremovevalue( players, e_triggerer );
			closest_other_player = getclosest( e_triggerer.origin, players );
			if ( isDefined( closest_other_player ) )
			{
				closest_other_player do_player_general_vox( "quest", "response_map", undefined, 100 );
			}
			b_has_line_played = 1;
			wait 5;
			flag_clear( "story_vo_playing" );
		}
	}
}

opening_vo()
{
	load_vo_alias_arrays();
	flag_wait( "afterlife_start_over" );
	wait 1;
	players = getplayers();
	vo_play_four_part_conversation( level.four_part_convos[ "start_1_oh_shit_" + randomintrange( 1, 3 ) ] );
	wait 1;
	if ( players.size == 1 )
	{
		players[ 0 ] vo_play_soliloquy( level.soliloquy_convos[ "solo_intro_" + players[ 0 ].character_name ] );
	}
	else
	{
		if ( is_player_character_present( "Arlington" ) )
		{
			vo_play_four_part_conversation( level.four_part_convos[ "intro_plr_3" ] );
		}
	}
	level thread vo_see_map_trigger();
	wait 10;
	vo_play_four_part_conversation( level.four_part_convos[ "during_1_oh_shit" ] );
	level waittill( "end_of_round" );
	wait 5;
	vo_play_four_part_conversation( level.four_part_convos[ "start_2_oh_shit_" + randomintrange( 1, 3 ) ] );
	wait 4;
	vo_play_four_part_conversation( level.four_part_convos[ "start_3_oh_shit" ] );
	level waittill( "end_of_round" );
	wait 3;
	if ( ( get_players_touching( "zone_library" ) + get_players_touching( "zone_start" ) ) == 4 )
	{
		vo_play_four_part_conversation( level.four_part_convos[ "start_2_oh_shit" ] );
	}
	wait 1;
}

load_vo_alias_arrays()
{
	level.four_part_convos = [];
	level.four_part_convos[ "intro_plr_1" ] = [];
	level.four_part_convos[ "intro_plr_1" ][ 0 ] = "vox_plr_1_start_1_oh_shit1_0";
	level.four_part_convos[ "intro_plr_3" ] = [];
	level.four_part_convos[ "intro_plr_3" ][ 0 ] = "vox_plr_3_chair2_var6_0";
	level.four_part_convos[ "intro_plr_3" ][ 1 ] = "vox_plr_3_chair2_var7_0";
	level.four_part_convos[ "intro_plr_3" ][ 2 ] = "vox_plr_3_chair2_var8_0";
	level.four_part_convos[ "start_1_oh_shit_1" ] = [];
	level.four_part_convos[ "start_1_oh_shit_1" ][ 0 ] = "vox_plr_1_start_1_oh_shit4_0";
	level.four_part_convos[ "start_1_oh_shit_1" ][ 1 ] = "vox_plr_2_start_1_oh_shit5_0";
	level.four_part_convos[ "start_1_oh_shit_1" ][ 2 ] = "vox_plr_0_start_1_oh_shit6_0";
	level.four_part_convos[ "start_1_oh_shit_1" ][ 3 ] = "vox_plr_3_start_1_oh_shit7_0";
	level.four_part_convos[ "start_1_oh_shit_2" ] = [];
	level.four_part_convos[ "start_1_oh_shit_2" ][ 0 ] = "vox_plr_3_start_1_oh_shit8_0";
	level.four_part_convos[ "start_1_oh_shit_2" ][ 1 ] = "vox_plr_2_start_1_oh_shit9_0";
	level.four_part_convos[ "start_1_oh_shit_2" ][ 2 ] = "vox_plr_1_start_1_oh_shit10_0";
	level.four_part_convos[ "start_1_oh_shit_2" ][ 3 ] = "vox_plr_0_start_1_oh_shit11_0";
	level.four_part_convos[ "during_1_oh_shit" ] = [];
	level.four_part_convos[ "during_1_oh_shit" ][ 0 ] = "vox_plr_0_during_1_oh_shit5_0";
	level.four_part_convos[ "during_1_oh_shit" ][ 1 ] = "vox_plr_3_during_1_oh_shit6_0";
	level.four_part_convos[ "during_1_oh_shit" ][ 2 ] = "vox_plr_1_during_1_oh_shit7_0";
	level.four_part_convos[ "during_1_oh_shit" ][ 3 ] = "vox_plr_2_during_1_oh_shit8_0";
	level.four_part_convos[ "start_2_oh_shit_1" ] = [];
	level.four_part_convos[ "start_2_oh_shit_1" ][ 0 ] = "vox_plr_3_start_2_oh_shit12_0";
	level.four_part_convos[ "start_2_oh_shit_1" ][ 1 ] = "vox_plr_0_start_2_oh_shit13_0";
	level.four_part_convos[ "start_2_oh_shit_1" ][ 2 ] = "vox_plr_2_start_2_oh_shit14_0";
	level.four_part_convos[ "start_2_oh_shit_1" ][ 3 ] = "vox_plr_1_start_2_oh_shit15_0";
	level.four_part_convos[ "start_2_oh_shit_2" ] = [];
	level.four_part_convos[ "start_2_oh_shit_2" ][ 0 ] = "vox_plr_0_start_2_oh_shit16_0";
	level.four_part_convos[ "start_2_oh_shit_2" ][ 1 ] = "vox_plr_2_start_2_oh_shit17_0";
	level.four_part_convos[ "start_2_oh_shit_2" ][ 2 ] = "vox_plr_3_start_2_oh_shit18_0";
	level.four_part_convos[ "start_2_oh_shit_2" ][ 3 ] = "vox_plr_1_start_2_oh_shit19_0";
	level.four_part_convos[ "start_3_oh_shit" ] = [];
	level.four_part_convos[ "start_3_oh_shit" ][ 0 ] = "vox_plr_3_start_3_oh_shit13_0";
	level.four_part_convos[ "start_3_oh_shit" ][ 1 ] = "vox_plr_2_start_3_oh_shit14_0";
	level.four_part_convos[ "start_3_oh_shit" ][ 2 ] = "vox_plr_1_start_3_oh_shit15_0";
	level.four_part_convos[ "start_3_oh_shit" ][ 3 ] = "vox_plr_0_start_3_oh_shit16_0";
	level.four_part_convos[ "start_2_oh_shit" ] = [];
	level.four_part_convos[ "start_2_oh_shit" ][ 0 ] = "vox_plr_1_start_2_oh_shit9_0";
	level.four_part_convos[ "start_2_oh_shit" ][ 1 ] = "vox_plr_0_start_2_oh_shit10_0";
	level.four_part_convos[ "start_2_oh_shit" ][ 2 ] = "vox_plr_1_start_2_oh_shit11_0";
	level.four_part_convos[ "start_2_oh_shit" ][ 3 ] = "vox_plr_2_start_2_oh_shit12_0";
	level.four_part_convos[ "chair1" ] = [];
	level.four_part_convos[ "chair1" ][ 0 ] = "vox_plr_1_chair1_var1_0";
	level.four_part_convos[ "chair1" ][ 1 ] = "vox_plr_2_chair1_var2_0";
	level.four_part_convos[ "chair1" ][ 2 ] = "vox_plr_3_chair1_var3_0";
	level.four_part_convos[ "chair1" ][ 3 ] = "vox_plr_1_chair1_var4_0";
	level.four_part_convos[ "chair1" ][ 4 ] = "vox_plr_3_chair1_var5_0";
	level.four_part_convos[ "chair2" ] = [];
	level.four_part_convos[ "chair2" ][ 0 ] = "vox_plr_2_chair2_var1_0";
	level.four_part_convos[ "chair2" ][ 1 ] = "vox_plr_3_chair2_var2_0";
	level.four_part_convos[ "chair2" ][ 1 ] = "vox_plr_0_chair2_var3_0";
	level.four_part_convos[ "chair2" ][ 2 ] = "vox_plr_3_chair2_var5_0";
	level.four_part_convos[ "chair2" ][ 3 ] = "vox_plr_1_chair2_var4_0";
	level.four_part_convos[ "chair_combat_1" ] = [];
	level.four_part_convos[ "chair_combat_1" ][ 0 ] = "vox_plr_3_chair3_var_3_0";
	level.four_part_convos[ "chair_combat_1" ][ 1 ] = "vox_plr_1_chair3_var_3_0";
	level.four_part_convos[ "chair_combat_1" ][ 2 ] = "vox_plr_2_chair3_var_3_0";
	level.four_part_convos[ "chair_combat_1" ][ 3 ] = "vox_plr_0_chair3_var_3_0";
	level.four_part_convos[ "chair_combat_2" ] = [];
	level.four_part_convos[ "chair_combat_2" ][ 0 ] = "vox_plr_0_chair4_var_4_0";
	level.four_part_convos[ "chair_combat_2" ][ 1 ] = "vox_plr_3_chair4_var_4_0";
	level.four_part_convos[ "chair_combat_2" ][ 2 ] = "vox_plr_2_chair4_var_4_0";
	level.four_part_convos[ "chair_combat_2" ][ 3 ] = "vox_plr_1_chair4_var_4_0";
	level.four_part_convos[ "chair_combat_2" ][ 4 ] = "vox_plr_3_chair4_var_4_1";
	level.four_part_convos[ "bridge_visit1_alt1" ] = [];
	level.four_part_convos[ "bridge_visit1_alt1" ][ 0 ] = "vox_plr_3_bridge_var1_1_0";
	level.four_part_convos[ "bridge_visit1_alt1" ][ 1 ] = "vox_plr_2_bridge_var1_2_0";
	level.four_part_convos[ "bridge_visit1_alt1" ][ 2 ] = "vox_plr_0_bridge_var1_3_0";
	level.four_part_convos[ "bridge_visit1_alt1" ][ 3 ] = "vox_plr_1_bridge_var1_4_0";
	level.four_part_convos[ "bridge_visit1_alt2" ] = [];
	level.four_part_convos[ "bridge_visit1_alt2" ][ 0 ] = "vox_plr_1_bridge_var2_1_0";
	level.four_part_convos[ "bridge_visit1_alt2" ][ 1 ] = "vox_plr_0_bridge_var2_2_0";
	level.four_part_convos[ "bridge_visit1_alt2" ][ 2 ] = "vox_plr_1_bridge_var2_3_0";
	level.four_part_convos[ "bridge_visit1_alt2" ][ 3 ] = "vox_plr_2_bridge_var2_4_0";
	level.four_part_convos[ "bridge_visit1_alt2" ][ 4 ] = "vox_plr_3_bridge_var2_5_0";
	level.four_part_convos[ "bridge_visit1_alt3" ] = [];
	level.four_part_convos[ "bridge_visit1_alt3" ][ 0 ] = "vox_plr_0_bridge_var2_6_0";
	level.four_part_convos[ "bridge_visit1_alt3" ][ 1 ] = "vox_plr_2_bridge_var2_7_0";
	level.four_part_convos[ "bridge_visit1_alt3" ][ 2 ] = "vox_plr_3_bridge_var2_8_0";
	level.four_part_convos[ "bridge_visit1_alt3" ][ 3 ] = "vox_plr_1_bridge_var2_9_0";
	level.four_part_convos[ "bridge_visit1_alt4" ] = [];
	level.four_part_convos[ "bridge_visit1_alt4" ][ 0 ] = "vox_plr_1_bridge_var2_10_0";
	level.four_part_convos[ "bridge_visit1_alt4" ][ 1 ] = "vox_plr_2_bridge_var2_11_0";
	level.four_part_convos[ "bridge_visit1_alt4" ][ 2 ] = "vox_plr_0_bridge_var2_12_0";
	level.four_part_convos[ "bridge_visit1_alt4" ][ 3 ] = "vox_plr_3_bridge_var2_13_0";
	level.four_part_convos[ "bridge_visit2_alt1" ] = [];
	level.four_part_convos[ "bridge_visit2_alt1" ][ 0 ] = "vox_plr_0_bridge_var5_1_0";
	level.four_part_convos[ "bridge_visit2_alt1" ][ 1 ] = "vox_plr_3_bridge_var5_2_0";
	level.four_part_convos[ "bridge_visit2_alt1" ][ 2 ] = "vox_plr_0_bridge_var5_3_0";
	level.four_part_convos[ "bridge_visit2_alt1" ][ 3 ] = "vox_plr_3_bridge_var6_1_0";
	level.four_part_convos[ "bridge_visit2_alt1" ][ 4 ] = "vox_plr_2_bridge_var5_5_0";
	level.four_part_convos[ "bridge_visit2_alt1" ][ 5 ] = "vox_plr_3_bridge_var5_4_0";
	level.four_part_convos[ "bridge_visit2_alt2" ] = [];
	level.four_part_convos[ "bridge_visit2_alt2" ][ 0 ] = "vox_plr_3_bridge_var6_3_0";
	level.four_part_convos[ "bridge_visit2_alt2" ][ 1 ] = "vox_plr_1_bridge_var6_4_0";
	level.four_part_convos[ "bridge_visit2_alt2" ][ 2 ] = "vox_plr_3_bridge_var6_5_0";
	level.four_part_convos[ "bridge_visit2_alt2" ][ 3 ] = "vox_plr_2_bridge_var6_2_0";
	level.four_part_convos[ "bridge_visit2_alt2" ][ 4 ] = "vox_plr_3_bridge_var6_6_0";
	level.four_part_convos[ "bridge_visit2_alt2" ][ 5 ] = "vox_plr_0_bridge_var6_7_0";
	level.four_part_convos[ "bridge_visit2_alt3" ] = [];
	level.four_part_convos[ "bridge_visit2_alt3" ][ 0 ] = "vox_plr_3_bridge_var6_8_0";
	level.four_part_convos[ "bridge_visit2_alt3" ][ 1 ] = "vox_plr_2_bridge_var6_9_0";
	level.four_part_convos[ "bridge_visit2_alt3" ][ 2 ] = "vox_plr_3_bridge_var6_10_0";
	level.four_part_convos[ "bridge_visit2_alt3" ][ 3 ] = "vox_plr_2_bridge_var6_11_0";
	level.four_part_convos[ "bridge_visit2_alt3" ][ 3 ] = "vox_plr_3_bridge_var6_12_0";
	level.four_part_convos[ "bridge_visit2_alt4" ] = [];
	level.four_part_convos[ "bridge_visit2_alt4" ][ 0 ] = "vox_plr_0_bridge_var6_13_0";
	level.four_part_convos[ "bridge_visit2_alt4" ][ 1 ] = "vox_plr_2_bridge_var6_14_0";
	level.four_part_convos[ "bridge_visit2_alt4" ][ 2 ] = "vox_plr_1_bridge_var6_15_0";
	level.four_part_convos[ "bridge_visit2_alt4" ][ 3 ] = "vox_plr_3_bridge_var6_16_0";
	level.four_part_convos[ "alcatraz_return_alt1" ] = [];
	level.four_part_convos[ "alcatraz_return_alt1" ][ 0 ] = "vox_plr_0_start_2_4_player_0";
	level.four_part_convos[ "alcatraz_return_alt1" ][ 1 ] = "vox_plr_3_start_2_4_player_0";
	level.four_part_convos[ "alcatraz_return_alt1" ][ 2 ] = "vox_plr_2_start_2_4_player_0";
	level.four_part_convos[ "alcatraz_return_alt1" ][ 3 ] = "vox_plr_1_start_2_4_player_0";
	level.four_part_convos[ "alcatraz_return_alt2" ] = [];
	level.four_part_convos[ "alcatraz_return_alt2" ][ 0 ] = "vox_plr_2_start_2_4_player_1";
	level.four_part_convos[ "alcatraz_return_alt2" ][ 1 ] = "vox_plr_3_start_2_4_player_1";
	level.four_part_convos[ "alcatraz_return_alt2" ][ 2 ] = "vox_plr_0_start_2_4_player_1";
	level.four_part_convos[ "alcatraz_return_alt2" ][ 3 ] = "vox_plr_1_start_2_4_player_1";
	level.four_part_convos[ "alcatraz_return_quest_reset" ] = [];
	level.four_part_convos[ "alcatraz_return_quest_reset" ][ 0 ] = "vox_plr_3_start_2_2_3_players_0";
	level.four_part_convos[ "alcatraz_return_quest_reset" ][ 1 ] = "vox_plr_1_start_2_2_3_players_0";
	level.four_part_convos[ "alcatraz_return_quest_reset" ][ 2 ] = "vox_plr_2_start_2_2_3_players_0";
	level.four_part_convos[ "alcatraz_return_quest_reset" ][ 3 ] = "vox_plr_0_start_2_2_3_players_0";
	level.soliloquy_convos[ "solo_intro_Billy" ] = [];
	level.soliloquy_convos[ "solo_intro_Billy" ][ 0 ] = "vox_plr_2_start_1_billy_0";
	level.soliloquy_convos[ "solo_intro_Billy" ][ 1 ] = "vox_plr_2_start_1_billy_1";
	level.soliloquy_convos[ "solo_intro_Billy" ][ 2 ] = "vox_plr_2_start_1_billy_2";
	level.soliloquy_convos[ "solo_intro_Sal" ] = [];
	level.soliloquy_convos[ "solo_intro_Sal" ][ 0 ] = "vox_plr_1_start_1_sal_0";
	level.soliloquy_convos[ "solo_intro_Sal" ][ 1 ] = "vox_plr_1_start_1_sal_1";
	level.soliloquy_convos[ "solo_intro_Sal" ][ 2 ] = "vox_plr_1_start_1_sal_2";
	level.soliloquy_convos[ "solo_intro_Finn" ] = [];
	level.soliloquy_convos[ "solo_intro_Finn" ][ 0 ] = "vox_plr_0_start_1_finn_0";
	level.soliloquy_convos[ "solo_intro_Finn" ][ 1 ] = "vox_plr_0_start_1_finn_1";
	level.soliloquy_convos[ "solo_intro_Finn" ][ 2 ] = "vox_plr_0_start_1_finn_2";
	level.soliloquy_convos[ "solo_intro_Arlington" ] = [];
	level.soliloquy_convos[ "solo_intro_Arlington" ][ 0 ] = "vox_plr_3_start_1_arlington_0";
	level.soliloquy_convos[ "solo_intro_Arlington" ][ 1 ] = "vox_plr_3_start_1_arlington_1";
	level.soliloquy_convos[ "purgatory_Sal_visit1_alt1" ] = [];
	level.soliloquy_convos[ "purgatory_Sal_visit1_alt1" ][ 0 ] = "vox_plr_1_purgatory_sal_var1_0";
	level.soliloquy_convos[ "purgatory_Sal_visit1_alt1" ][ 1 ] = "vox_plr_1_purgatory_sal_var1_1";
	level.soliloquy_convos[ "purgatory_Sal_visit1_alt1" ][ 2 ] = "vox_plr_1_purgatory_sal_var1_2";
	level.soliloquy_convos[ "purgatory_Sal_visit1_alt1" ][ 3 ] = "vox_plr_1_purgatory_sal_var1_3";
	level.soliloquy_convos[ "purgatory_Sal_visit1_alt1" ][ 4 ] = "vox_plr_1_purgatory_sal_var1_4";
	level.soliloquy_convos[ "purgatory_Sal_visit1_alt2" ] = [];
	level.soliloquy_convos[ "purgatory_Sal_visit1_alt2" ][ 0 ] = "vox_plr_1_purgatory_sal_var2_0";
	level.soliloquy_convos[ "purgatory_Sal_visit1_alt2" ][ 1 ] = "vox_plr_1_purgatory_sal_var2_1";
	level.soliloquy_convos[ "purgatory_Sal_visit1_alt2" ][ 2 ] = "vox_plr_1_purgatory_sal_var2_2";
	level.soliloquy_convos[ "purgatory_Sal_visit1_alt2" ][ 3 ] = "vox_plr_1_purgatory_sal_var2_3";
	level.soliloquy_convos[ "purgatory_Sal_visit2_alt1" ] = [];
	level.soliloquy_convos[ "purgatory_Sal_visit2_alt1" ][ 0 ] = "vox_plr_1_purgatory_sal_var3_0";
	level.soliloquy_convos[ "purgatory_Sal_visit2_alt1" ][ 1 ] = "vox_plr_1_purgatory_sal_var3_1";
	level.soliloquy_convos[ "purgatory_Sal_visit2_alt1" ][ 2 ] = "vox_plr_1_purgatory_sal_var3_2";
	level.soliloquy_convos[ "purgatory_Sal_visit2_alt1" ][ 3 ] = "vox_plr_1_purgatory_sal_var3_3";
	level.soliloquy_convos[ "purgatory_Sal_visit2_alt1" ][ 4 ] = "vox_plr_1_purgatory_sal_var3_4";
	level.soliloquy_convos[ "purgatory_Sal_visit2_alt2" ] = [];
	level.soliloquy_convos[ "purgatory_Sal_visit2_alt2" ][ 0 ] = "vox_plr_1_purgatory_sal_var4_0";
	level.soliloquy_convos[ "purgatory_Sal_visit2_alt2" ][ 1 ] = "vox_plr_1_purgatory_sal_var4_1";
	level.soliloquy_convos[ "purgatory_Sal_visit2_alt2" ][ 2 ] = "vox_plr_1_purgatory_sal_var4_3";
	level.soliloquy_convos[ "purgatory_Sal_visit2_alt2" ][ 3 ] = "vox_plr_1_purgatory_sal_var4_4";
	level.soliloquy_convos[ "purgatory_Sal_visit2_alt2" ][ 4 ] = "vox_plr_1_purgatory_sal_var4_5";
	level.soliloquy_convos[ "purgatory_Billy_visit1_alt1" ] = [];
	level.soliloquy_convos[ "purgatory_Billy_visit1_alt1" ][ 0 ] = "vox_plr_2_purgatory_billy_var1_0";
	level.soliloquy_convos[ "purgatory_Billy_visit1_alt1" ][ 1 ] = "vox_plr_2_purgatory_billy_var1_1";
	level.soliloquy_convos[ "purgatory_Billy_visit1_alt1" ][ 2 ] = "vox_plr_2_purgatory_billy_var1_2";
	level.soliloquy_convos[ "purgatory_Billy_visit1_alt2" ] = [];
	level.soliloquy_convos[ "purgatory_Billy_visit1_alt2" ][ 0 ] = "vox_plr_2_purgatory_billy_var2_0";
	level.soliloquy_convos[ "purgatory_Billy_visit1_alt2" ][ 1 ] = "vox_plr_2_purgatory_billy_var2_1";
	level.soliloquy_convos[ "purgatory_Billy_visit1_alt2" ][ 2 ] = "vox_plr_2_purgatory_billy_var2_2";
	level.soliloquy_convos[ "purgatory_Billy_visit2_alt1" ] = [];
	level.soliloquy_convos[ "purgatory_Billy_visit2_alt1" ][ 0 ] = "vox_plr_2_purgatory_billy_var3_0";
	level.soliloquy_convos[ "purgatory_Billy_visit2_alt1" ][ 1 ] = "vox_plr_2_purgatory_billy_var3_1";
	level.soliloquy_convos[ "purgatory_Billy_visit2_alt1" ][ 2 ] = "vox_plr_2_purgatory_billy_var3_2";
	level.soliloquy_convos[ "purgatory_Billy_visit2_alt1" ][ 3 ] = "vox_plr_2_purgatory_billy_var3_3";
	level.soliloquy_convos[ "purgatory_Billy_visit2_alt2" ] = [];
	level.soliloquy_convos[ "purgatory_Billy_visit2_alt2" ][ 0 ] = "vox_plr_2_purgatory_billy_var4_0";
	level.soliloquy_convos[ "purgatory_Billy_visit2_alt2" ][ 1 ] = "vox_plr_2_purgatory_billy_var4_1";
	level.soliloquy_convos[ "purgatory_Billy_visit2_alt2" ][ 2 ] = "vox_plr_2_purgatory_billy_var4_2";
	level.soliloquy_convos[ "purgatory_Finn_visit1_alt1" ] = [];
	level.soliloquy_convos[ "purgatory_Finn_visit1_alt1" ][ 0 ] = "vox_plr_0_purgatory_finn_var1_0";
	level.soliloquy_convos[ "purgatory_Finn_visit1_alt1" ][ 1 ] = "vox_plr_0_purgatory_finn_var1_1";
	level.soliloquy_convos[ "purgatory_Finn_visit1_alt1" ][ 2 ] = "vox_plr_0_purgatory_finn_var1_2";
	level.soliloquy_convos[ "purgatory_Finn_visit1_alt1" ][ 3 ] = "vox_plr_0_purgatory_finn_var1_3";
	level.soliloquy_convos[ "purgatory_Finn_visit1_alt2" ] = [];
	level.soliloquy_convos[ "purgatory_Finn_visit1_alt2" ][ 0 ] = "vox_plr_0_purgatory_finn_var2_0";
	level.soliloquy_convos[ "purgatory_Finn_visit1_alt2" ][ 1 ] = "vox_plr_0_purgatory_finn_var2_1";
	level.soliloquy_convos[ "purgatory_Finn_visit1_alt2" ][ 2 ] = "vox_plr_0_purgatory_finn_var2_2";
	level.soliloquy_convos[ "purgatory_Finn_visit2_alt1" ] = [];
	level.soliloquy_convos[ "purgatory_Finn_visit2_alt1" ][ 0 ] = "vox_plr_0_purgatory_finn_var3_0";
	level.soliloquy_convos[ "purgatory_Finn_visit2_alt1" ][ 1 ] = "vox_plr_0_purgatory_finn_var3_1";
	level.soliloquy_convos[ "purgatory_Finn_visit2_alt1" ][ 2 ] = "vox_plr_0_purgatory_finn_var3_2";
	level.soliloquy_convos[ "purgatory_Finn_visit2_alt2" ] = [];
	level.soliloquy_convos[ "purgatory_Finn_visit2_alt2" ][ 0 ] = "vox_plr_0_purgatory_finn_var4_0";
	level.soliloquy_convos[ "purgatory_Finn_visit2_alt2" ][ 1 ] = "vox_plr_0_purgatory_finn_var4_1";
	level.soliloquy_convos[ "purgatory_Finn_visit2_alt2" ][ 2 ] = "vox_plr_0_purgatory_finn_var4_2";
	level.soliloquy_convos[ "purgatory_Arlington_visit1_alt1" ] = [];
	level.soliloquy_convos[ "purgatory_Arlington_visit1_alt1" ][ 0 ] = "vox_plr_3_purgatory_arlington_var1_0";
	level.soliloquy_convos[ "purgatory_Arlington_visit1_alt1" ][ 1 ] = "vox_plr_3_purgatory_arlington_var1_1";
	level.soliloquy_convos[ "purgatory_Arlington_visit1_alt1" ][ 2 ] = "vox_plr_3_purgatory_arlington_var1_2";
	level.soliloquy_convos[ "purgatory_Arlington_visit1_alt2" ] = [];
	level.soliloquy_convos[ "purgatory_Arlington_visit1_alt2" ][ 0 ] = "vox_plr_3_purgatory_arlington_var2_0";
	level.soliloquy_convos[ "purgatory_Arlington_visit1_alt2" ][ 1 ] = "vox_plr_3_purgatory_arlington_var2_1";
	level.soliloquy_convos[ "purgatory_Arlington_visit1_alt2" ][ 2 ] = "vox_plr_3_purgatory_arlington_var2_2";
	level.soliloquy_convos[ "purgatory_Arlington_visit2_alt1" ] = [];
	level.soliloquy_convos[ "purgatory_Arlington_visit2_alt1" ][ 0 ] = "vox_plr_3_purgatory_arlington_var3_0";
	level.soliloquy_convos[ "purgatory_Arlington_visit2_alt1" ][ 1 ] = "vox_plr_3_purgatory_arlington_var3_1";
	level.soliloquy_convos[ "purgatory_Arlington_visit2_alt1" ][ 2 ] = "vox_plr_3_purgatory_arlington_var3_2";
	level.soliloquy_convos[ "purgatory_Arlington_visit2_alt2" ] = [];
	level.soliloquy_convos[ "purgatory_Arlington_visit2_alt2" ][ 0 ] = "vox_plr_3_purgatory_arlington_var4_0";
	level.soliloquy_convos[ "purgatory_Arlington_visit2_alt2" ][ 1 ] = "vox_plr_3_purgatory_arlington_var4_1";
	level.soliloquy_convos[ "purgatory_Arlington_visit2_alt2" ][ 2 ] = "vox_plr_3_purgatory_arlington_var4_2";
	level.soliloquy_convos[ "electric_chair_Finn" ] = [];
	level.soliloquy_convos[ "electric_chair_Finn" ][ 0 ] = "vox_plr_0_chair4_var_4_0";
	level.soliloquy_convos[ "electric_chair_Sal" ] = [];
	level.soliloquy_convos[ "electric_chair_Sal" ][ 0 ] = "vox_plr_1_chair1_var1_0";
	level.soliloquy_convos[ "electric_chair_Billy" ] = [];
	level.soliloquy_convos[ "electric_chair_Billy" ][ 0 ] = "vox_plr_2_chair1_var2_0";
	level.soliloquy_convos[ "electric_chair_Arlington" ] = [];
	level.soliloquy_convos[ "electric_chair_Arlington" ][ 0 ] = "vox_plr_3_chair3_var_3_0";
}

vo_bridge_soliloquy()
{
	if ( level.n_quest_iteration_count < 3 )
	{
		convo = level.soliloquy_convos[ "purgatory_" + self.character_name + "_visit" + level.n_quest_iteration_count + "_alt" + randomintrange( 1, 3 ) ];
		if ( isDefined( convo ) )
		{
			self vo_play_soliloquy( convo );
		}
	}
}

vo_bridge_four_part_convo()
{
	if ( level.n_quest_iteration_count < 3 )
	{
		convo = level.four_part_convos[ "bridge_visit" + level.n_quest_iteration_count + "_alt" + randomintrange( 1, 5 ) ];
		if ( isDefined( convo ) )
		{
			vo_play_four_part_conversation( convo );
		}
	}
}

vo_play_soliloquy( convo )
{
	self endon( "disconnect" );
	if ( !isDefined( convo ) )
	{
		return;
	}
	if ( !flag( "story_vo_playing" ) )
	{
		flag_set( "story_vo_playing" );
		self thread vo_play_soliloquy_disconnect_listener();
		self.dontspeak = 1;
		self setclientfieldtoplayer( "isspeaking", 1 );
		i = 0;
		while ( i < convo.size )
		{
			if ( isDefined( self.afterlife ) && self.afterlife )
			{
				self.dontspeak = 0;
				self setclientfieldtoplayer( "isspeaking", 0 );
				flag_clear( "story_vo_playing" );
				self notify( "soliloquy_vo_done" );
				return;
			}
			else
			{
				self playsoundwithnotify( convo[ i ], "sound_done" + convo[ i ] );
				self waittill( "sound_done" + convo[ i ] );
			}
			wait 1;
			i++;
		}
		self.dontspeak = 0;
		self setclientfieldtoplayer( "isspeaking", 0 );
		flag_clear( "story_vo_playing" );
		self notify( "soliloquy_vo_done" );
	}
}

vo_play_soliloquy_disconnect_listener()
{
	self endon( "soliloquy_vo_done" );
	self waittill( "disconnect" );
	flag_clear( "story_vo_playing" );
}

vo_play_four_part_conversation( convo )
{
	if ( !isDefined( convo ) )
	{
		return;
	}
	players = getplayers();
	if ( players.size == 4 && !flag( "story_vo_playing" ) )
	{
		flag_set( "story_vo_playing" );
		old_speaking_player = undefined;
		speaking_player = undefined;
		n_dist = 0;
		n_max_reply_dist = 1500;
		e_arlington = undefined;
		e_sal = undefined;
		e_billy = undefined;
		e_finn = undefined;
		_a513 = players;
		_k513 = getFirstArrayKey( _a513 );
		while ( isDefined( _k513 ) )
		{
			player = _a513[ _k513 ];
			if ( isDefined( player ) )
			{
				switch( player.character_name )
				{
					case "Arlington":
						e_arlington = player;
						break;
					break;
					case "Sal":
						e_sal = player;
						break;
					break;
					case "Billy":
						e_billy = player;
						break;
					break;
					case "Finn":
						e_finn = player;
						break;
					break;
				}
			}
			_k513 = getNextArrayKey( _a513, _k513 );
		}
		if ( isDefined( e_arlington ) && isDefined( e_sal ) || !isDefined( e_billy ) && !isDefined( e_finn ) )
		{
			return;
		}
		else _a542 = players;
		_k542 = getFirstArrayKey( _a542 );
		while ( isDefined( _k542 ) )
		{
			player = _a542[ _k542 ];
			if ( isDefined( player ) )
			{
				player.dontspeak = 1;
				player setclientfieldtoplayer( "isspeaking", 1 );
			}
			_k542 = getNextArrayKey( _a542, _k542 );
		}
		i = 0;
		while ( i < convo.size )
		{
			players = getplayers();
			if ( players.size != 4 )
			{
				_a557 = players;
				_k557 = getFirstArrayKey( _a557 );
				while ( isDefined( _k557 ) )
				{
					player = _a557[ _k557 ];
					if ( isDefined( player ) )
					{
						player.dontspeak = 0;
						player setclientfieldtoplayer( "isspeaking", 0 );
					}
					_k557 = getNextArrayKey( _a557, _k557 );
				}
				flag_clear( "story_vo_playing" );
				return;
			}
			if ( issubstr( convo[ i ], "plr_0" ) )
			{
				speaking_player = e_finn;
			}
			else if ( issubstr( convo[ i ], "plr_1" ) )
			{
				speaking_player = e_sal;
			}
			else if ( issubstr( convo[ i ], "plr_2" ) )
			{
				speaking_player = e_billy;
			}
			else
			{
				if ( issubstr( convo[ i ], "plr_3" ) )
				{
					speaking_player = e_arlington;
				}
			}
			if ( isDefined( old_speaking_player ) )
			{
				n_dist = distance( old_speaking_player.origin, speaking_player.origin );
			}
			if ( speaking_player.afterlife || n_dist > n_max_reply_dist )
			{
				_a593 = players;
				_k593 = getFirstArrayKey( _a593 );
				while ( isDefined( _k593 ) )
				{
					player = _a593[ _k593 ];
					if ( isDefined( player ) )
					{
						player.dontspeak = 0;
						player setclientfieldtoplayer( "isspeaking", 0 );
					}
					_k593 = getNextArrayKey( _a593, _k593 );
				}
				flag_clear( "story_vo_playing" );
				return;
			}
			else
			{
				speaking_player playsoundwithnotify( convo[ i ], "sound_done" + convo[ i ] );
				speaking_player waittill( "sound_done" + convo[ i ] );
				old_speaking_player = speaking_player;
			}
			wait 1;
			i++;
		}
		_a613 = players;
		_k613 = getFirstArrayKey( _a613 );
		while ( isDefined( _k613 ) )
		{
			player = _a613[ _k613 ];
			if ( isDefined( player ) )
			{
				player.dontspeak = 0;
				player setclientfieldtoplayer( "isspeaking", 0 );
			}
			_k613 = getNextArrayKey( _a613, _k613 );
		}
		flag_clear( "story_vo_playing" );
	}
}

electric_chair_vo()
{
	if ( level.n_quest_iteration_count == 1 )
	{
		e_nml_zone = getent( "zone_golden_gate_bridge", "targetname" );
		n_players_on_bridge_count = get_players_touching( "zone_golden_gate_bridge" );
		players = getplayers();
		if ( players.size == 4 && n_players_on_bridge_count == 4 )
		{
			if ( count_zombies_in_zone( "zone_golden_gate_bridge" ) > 0 )
			{
				vo_play_four_part_conversation( level.four_part_convos[ "chair_combat_" + randomintrange( 1, 3 ) ] );
			}
			else
			{
				vo_play_four_part_conversation( level.four_part_convos[ "chair" + randomintrange( 1, 3 ) ] );
			}
			return;
		}
		else
		{
			if ( isDefined( players[ 0 ] ) && players[ 0 ] istouching( e_nml_zone ) )
			{
				character_name = players[ 0 ].character_name;
				players[ 0 ] vo_play_soliloquy( level.soliloquy_convos[ "electric_chair_" + character_name ] );
			}
		}
	}
}

escape_flight_vo()
{
	e_roof_zone = getent( "zone_roof", "targetname" );
	players = getplayers();
	player = players[ randomintrange( 0, players.size ) ];
	if ( isDefined( player ) && player istouching( e_roof_zone ) )
	{
		player thread do_player_general_vox( "quest", "build_plane", undefined, 100 );
	}
	flag_wait( "plane_boarded" );
	if ( level.final_flight_activated )
	{
		return;
	}
	while ( level.characters_in_nml.size == 0 )
	{
		wait 0,1;
	}
	wait 1;
	while ( level.characters_in_nml.size > 0 )
	{
		character_name = level.characters_in_nml[ randomintrange( 0, level.characters_in_nml.size ) ];
		players = getplayers();
		_a687 = players;
		_k687 = getFirstArrayKey( _a687 );
		while ( isDefined( _k687 ) )
		{
			player = _a687[ _k687 ];
			if ( isDefined( player ) && player.character_name == character_name )
			{
				player thread do_player_general_vox( "quest", "plane_takeoff" );
			}
			_k687 = getNextArrayKey( _a687, _k687 );
		}
	}
	flag_wait( "plane_departed" );
	wait 2;
	while ( level.characters_in_nml.size > 0 )
	{
		character_name = level.characters_in_nml[ randomintrange( 0, level.characters_in_nml.size ) ];
		players = getplayers();
		_a703 = players;
		_k703 = getFirstArrayKey( _a703 );
		while ( isDefined( _k703 ) )
		{
			player = _a703[ _k703 ];
			if ( isDefined( player ) && player.character_name == character_name )
			{
				player playsound( "vox_plr_" + player.characterindex + "_plane_flight_0" );
			}
			_k703 = getNextArrayKey( _a703, _k703 );
		}
	}
	flag_wait( "plane_approach_bridge" );
	wait 3,5;
	while ( level.characters_in_nml.size > 0 )
	{
		character_name = level.characters_in_nml[ randomintrange( 0, level.characters_in_nml.size ) ];
		players = getplayers();
		_a719 = players;
		_k719 = getFirstArrayKey( _a719 );
		while ( isDefined( _k719 ) )
		{
			player = _a719[ _k719 ];
			if ( isDefined( player ) && player.character_name == character_name )
			{
				player playsound( "vox_plr_" + player.characterindex + "_plane_crash_0" );
			}
			_k719 = getNextArrayKey( _a719, _k719 );
		}
	}
	flag_wait( "plane_zapped" );
	players = getplayers();
	_a732 = players;
	_k732 = getFirstArrayKey( _a732 );
	while ( isDefined( _k732 ) )
	{
		player = _a732[ _k732 ];
		if ( isDefined( player ) && isinarray( level.characters_in_nml, player.character_name ) )
		{
			player thread player_scream_thread();
		}
		_k732 = getNextArrayKey( _a732, _k732 );
	}
}

player_scream_thread()
{
	self endon( "death" );
	self endon( "disconnect" );
	players = getplayers();
	_a749 = players;
	_k749 = getFirstArrayKey( _a749 );
	while ( isDefined( _k749 ) )
	{
		player = _a749[ _k749 ];
		if ( isDefined( player ) && isinarray( level.characters_in_nml, player.character_name ) )
		{
			player playsoundtoplayer( "vox_plr_" + player.characterindex + "_free_fall_0", self );
		}
		_k749 = getNextArrayKey( _a749, _k749 );
	}
	level flag_wait( "plane_crashed" );
	self stopsounds();
	self.dontspeak = 0;
	player setclientfieldtoplayer( "isspeaking", 0 );
}

sndhitelectrifiedpulley( str_master_key_location )
{
	self endon( "master_key_pulley_" + str_master_key_location );
	while ( 1 )
	{
		self waittill( "trigger", e_triggerer );
		self playsound( "fly_elec_sparks_key" );
		wait 1;
	}
}

is_player_character_present( character_name )
{
	if ( !isDefined( character_name ) )
	{
		return 0;
	}
	players = getplayers();
	_a785 = players;
	_k785 = getFirstArrayKey( _a785 );
	while ( isDefined( _k785 ) )
	{
		player = _a785[ _k785 ];
		if ( isDefined( player.character_name ) && player.character_name == character_name )
		{
			return 1;
		}
		_k785 = getNextArrayKey( _a785, _k785 );
	}
	return 0;
}

get_players_touching( scr_touched_name )
{
	n_touching_count = 0;
	e_touched = getent( scr_touched_name, "targetname" );
/#
	assert( isDefined( e_touched ) );
#/
	a_players = getplayers();
	_a803 = a_players;
	_k803 = getFirstArrayKey( _a803 );
	while ( isDefined( _k803 ) )
	{
		player = _a803[ _k803 ];
		if ( isDefined( player ) && player istouching( e_touched ) )
		{
			n_touching_count++;
		}
		_k803 = getNextArrayKey( _a803, _k803 );
	}
	return n_touching_count;
}

count_zombies_in_zone( volume )
{
	e_zone = getent( volume, "targetname" );
	if ( !isDefined( e_zone ) )
	{
		return;
	}
	n_zombie_count = 0;
	zombies = getaispeciesarray( "axis", "all" );
	i = 0;
	while ( i < zombies.size )
	{
		if ( zombies[ i ] istouching( e_zone ) )
		{
			n_zombie_count++;
		}
		i++;
	}
	return n_zombie_count;
}
