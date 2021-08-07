#include maps/mp/gametypes_zm/_globallogic_score;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;

init()
{
	level.achievement_sound_func = ::achievement_sound_func;
	onplayerconnect_callback( ::onplayerconnect );
}

achievement_sound_func( achievement_name_lower )
{
	self thread do_player_general_vox( "general", "achievement" );
}

init_player_achievement_stats()
{
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "zm_dlc1_polyarmory", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "zm_dlc1_monkey_see_monkey_doom", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "zm_dlc1_i_see_live_people", 0 );
}

onplayerconnect()
{
	if ( gamemodeismode( level.gamemode_public_match ) )
	{
		self thread achievement_polyarmory();
		self thread achievement_monkey_see_monkey_doom();
		self thread achievement_i_see_live_people();
	}
}

achievement_polyarmory()
{
	level endon( "end_game" );
	self endon( "disconnect" );
	self waittill( "gun_game_achievement" );
/#
#/
	self giveachievement_wrapper( "ZM_DLC1_POLYARMORY" );
}

achievement_monkey_see_monkey_doom()
{
	level endon( "end_game" );
	self endon( "disconnect" );
	self waittill( "powerup_blue_monkey" );
/#
#/
	self giveachievement_wrapper( "ZM_DLC1_MONKEY_SEE_MONKEY_DOOM" );
}

achievement_i_see_live_people()
{
	level endon( "end_game" );
	self endon( "disconnect" );
	self waittill( "invisible_player_killed" );
/#
#/
	self giveachievement_wrapper( "ZM_DLC1_I_SEE_LIVE_PEOPLE" );
}
