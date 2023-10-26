// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_ambientpackage;
#include clientscripts\mp\_audio;

main()
{
    declareambientroom( "vertigo_outdoor", 1 );
    setambientroomtone( "vertigo_outdoor", "amb_wind_extreior_2d", 0.3, 0.5 );
    setambientroomreverb( "vertigo_outdoor", "vertigo_outdoor", 1, 1 );
    setambientroomcontext( "vertigo_outdoor", "ringoff_plr", "outdoor" );
    declareambientroom( "vertigo_lobby" );
    setambientroomreverb( "vertigo_lobby", "vertigo_mediumroom", 1, 1 );
    setambientroomcontext( "vertigo_lobby", "ringoff_plr", "indoor" );
    declareambientroom( "vertigo_mn_bldg_hall" );
    setambientroomreverb( "vertigo_mn_bldg_hall", "vertigo_largeroom", 1, 1 );
    setambientroomcontext( "vertigo_mn_bldg_hall", "ringoff_plr", "indoor" );
    declareambientroom( "vertigo_display_rm" );
    setambientroomreverb( "vertigo_display_rm", "vertigo_smallroom", 1, 1 );
    setambientroomcontext( "vertigo_display_rm", "ringoff_plr", "indoor" );
    declareambientroom( "vertigo_display_stairs" );
    setambientroomreverb( "vertigo_display_stairs", "vertigo_hallroom", 1, 1 );
    setambientroomcontext( "vertigo_display_stairs", "ringoff_plr", "indoor" );
    declareambientroom( "vertigo_comp_rm" );
    setambientroomreverb( "vertigo_comp_rm", "vertigo_smallroom", 1, 1 );
    setambientroomcontext( "vertigo_comp_rm", "ringoff_plr", "indoor" );
    declareambientroom( "vertigo_bathroom_area" );
    setambientroomreverb( "vertigo_bathroom_area", "vertigo_smallroom", 1, 1 );
    setambientroomcontext( "vertigo_bathroom_area", "ringoff_plr", "indoor" );
    declareambientroom( "vertigo_waiting_rm" );
    setambientroomreverb( "vertigo_waiting_rm", "vertigo_stoneroom", 1, 1 );
    setambientroomcontext( "vertigo_waiting_rm", "ringoff_plr", "indoor" );
    declareambientroom( "vertigo_concrete_rm" );
    setambientroomreverb( "vertigo_concrete_rm", "vertigo_stoneroom", 1, 1 );
    setambientroomcontext( "vertigo_concrete_rm", "ringoff_plr", "indoor" );
    declareambientroom( "vertigo_conf_rm" );
    setambientroomreverb( "vertigo_conf_rm", "vertigo_mediumroom", 1, 1 );
    setambientroomcontext( "vertigo_conf_rm", "ringoff_plr", "indoor" );
    declareambientroom( "vertigo_carpet_rm" );
    setambientroomreverb( "vertigo_carpet_rm", "vertigo_smallroom", 1, 1 );
    setambientroomcontext( "vertigo_carpet_rm", "ringoff_plr", "indoor" );
    thread snd_start_autofx_audio();
    thread snd_play_loopers();
}

snd_play_loopers()
{
    playloopat( "amb_fountain_water_1", ( 877, 1375, 164 ) );
    playloopat( "amb_retina_scanner", ( 1090, 580, 163 ) );
    playloopat( "amb_retina_scanner", ( -238, 604, 73 ) );
    playloopat( "amb_retina_scanner", ( 549, -575, 69 ) );
    playloopat( "amb_ac_fan", ( -192, -2645, 50 ) );
    playloopat( "amb_ac_fan", ( -201, -1796, 74 ) );
    playloopat( "amb_ac_fan", ( -200, -1674, 64 ) );
    playloopat( "amb_ac_fan", ( 1179, -466, 178 ) );
    playloopat( "amb_ac_fan", ( 1032, 700, 329 ) );
    playloopat( "amb_ac_fan", ( 947, 703, 321 ) );
    playloopat( "amb_ac_fan", ( 384, -1255, 78 ) );
    playloopat( "amb_generator_2", ( -1371, 805, 99 ) );
    playloopat( "amb_generator_2", ( -1702, 670, 117 ) );
    playloopat( "amb_door_pad_display", ( 160, 985, 72 ) );
    playloopat( "amb_door_pad_display", ( 160, 985, 72 ) );
    playloopat( "amb_door_pad_display", ( -68, 638, 73 ) );
    playloopat( "amb_door_pad_display", ( 912, -149, 30 ) );
    playloopat( "amb_door_pad_display", ( 338, 583, 72 ) );
    playloopat( "amb_door_pad_display", ( -69, 591, 71 ) );
    playloopat( "amb_tech_display", ( 188, 845, 90 ) );
    playloopat( "amb_tech_display", ( 83, 628, 91 ) );
    playloopat( "amb_tech_display", ( -337, -472, 87 ) );
    playloopat( "amb_tech_display", ( 987, 748, 153 ) );
    playloopat( "amb_tech_display", ( 824, 339, 170 ) );
    playloopat( "amb_tech_display", ( 778, 723, 198 ) );
    playloopat( "amb_tech_display", ( 776, 845, 189 ) );
    playloopat( "amb_tech_display", ( -793, -1895, 63 ) );
    playloopat( "amb_fan_lrg", ( -809, -2318, 40 ) );
    playloopat( "amb_fan_lrg", ( -809, -2146, 50 ) );
    playloopat( "amb_fan_lrg", ( -941, -1732, 180 ) );
    playloopat( "amb_fan_lrg", ( -765, -1732, 183 ) );
    playloopat( "amb_fan_lrg", ( -572, -1734, 187 ) );
    playloopat( "amb_outside_fans", ( -444, -2202, 21 ) );
    playloopat( "amb_outside_fans", ( -443, -2141, 21 ) );
    playloopat( "amb_outside_fans", ( -450, -2044, 24 ) );
    playloopat( "amb_outside_fans", ( -684, -2014, 21 ) );
    playloopat( "amb_outside_fans", ( -683, -2202, 21 ) );
    playloopat( "amb_outside_fans", ( 181, -1188, 39 ) );
    playloopat( "amb_outside_fans", ( 182, -1188, 40 ) );
    playloopat( "amb_metal_rattle_2", ( 365, -1922, 302 ) );
    playloopat( "amb_metal_rattle_2", ( -1750, -604, 352 ) );
    playloopat( "amb_build_ledge", ( -3024, 1869, 917 ) );
    playloopat( "amb_ac_wall_unit", ( -206, 1473, 123 ) );
    playloopat( "amb_ac_wall_unit", ( -34, -1337, 28 ) );
    playloopat( "amb_ribbon_flap", ( -452, -2202, 48 ) );
}

snd_start_autofx_audio()
{
    snd_play_auto_fx( "fx_mp_vertigo_engine_exhaust", "veh_osp_steady_close", 0, 0, 0, 1 );
    snd_play_auto_fx( "fx_mp_vertigo_fountain2", "amb_water_fountain_2", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_mp_vertigo_fountain", "amb_water_fountain_3", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_mp_vertigo_hvac_steam", "amb_hvac_steam", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_light_mag_ceiling_light", "amb_celing_light", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_mp_vertigo_ceiling_light_sm", "amb_celing_light_sml", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_mp_vertigo_ceiling_light", "amb_celing_light_sml", 0, 0, 0, 0 );
}
