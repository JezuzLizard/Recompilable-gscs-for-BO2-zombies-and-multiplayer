#include maps/mp/gametypes_zm/_globallogic_score;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;

init()
{
	if ( is_classic() )
	{
		level thread achievement_transit_sidequest();
		level thread achievement_undead_mans_party_bus();
	}
	level.achievement_sound_func = ::achievement_sound_func;
	onplayerconnect_callback( ::onplayerconnect );
}

init_player_achievement_stats()
{
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "zm_dont_fire_until_you_see", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "zm_the_lights_of_their_eyes", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "zm_dance_on_my_grave", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "zm_standard_equipment_may_vary", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "zm_you_have_no_power_over_me", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "zm_i_dont_think_they_exist", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "zm_fuel_efficient", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "zm_happy_hour", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "zm_transit_sidequest", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "zm_undead_mans_party_bus", 0 );
}

onplayerconnect()
{
	self thread achievement_the_lights_of_their_eyes();
	self thread achievement_dance_on_my_grave();
	if ( is_classic() )
	{
		self thread achievement_dont_fire_until_you_see();
		self thread achievement_standard_equipment_may_vary();
		self thread achievement_you_have_no_power_over_me();
		self thread achievement_i_dont_think_they_exist();
		self thread achievement_fuel_efficient();
		self thread achievement_zm_happy_hour();
	}
}

achievement_transit_sidequest()
{
	level endon( "end_game" );
	level waittill( "transit_sidequest_achieved" );
	level giveachievement_wrapper( "ZM_TRANSIT_SIDEQUEST", 1 );
}

achievement_undead_mans_party_bus()
{
	level endon( "end_game" );
	flag_wait( "start_zombie_round_logic" );
	wait 0,05;
	flag_wait( "ladder_attached" );
	flag_wait( "catcher_attached" );
	flag_wait( "hatch_attached" );
/#
#/
	level giveachievement_wrapper( "ZM_UNDEAD_MANS_PARTY_BUS", 1 );
}

achievement_dont_fire_until_you_see()
{
	level endon( "end_game" );
	self endon( "burned" );
	zombie_doors = getentarray( "zombie_door", "targetname" );
	while ( 1 )
	{
		level waittill( "door_opened" );
		num_left = 0;
		all_opened = 1;
		_a92 = zombie_doors;
		_k92 = getFirstArrayKey( _a92 );
		while ( isDefined( _k92 ) )
		{
			door = _a92[ _k92 ];
			if ( isDefined( door.has_been_opened ) && !door.has_been_opened )
			{
				num_left++;
				all_opened = 0;
			}
			_k92 = getNextArrayKey( _a92, _k92 );
		}
		if ( all_opened )
		{
			break;
		}
		else
		{
/#
#/
		}
	}
/#
#/
	self giveachievement_wrapper( "ZM_DONT_FIRE_UNTIL_YOU_SEE" );
}

achievement_the_lights_of_their_eyes()
{
	level endon( "end_game" );
	self waittill( "the_lights_of_their_eyes" );
/#
#/
	self giveachievement_wrapper( "ZM_THE_LIGHTS_OF_THEIR_EYES" );
}

achievement_dance_on_my_grave()
{
	level endon( "end_game" );
	self waittill( "dance_on_my_grave" );
/#
#/
	self giveachievement_wrapper( "ZM_DANCE_ON_MY_GRAVE" );
}

achievement_standard_equipment_may_vary()
{
	level endon( "end_game" );
	self waittill_subset( 4, "equip_electrictrap_zm_given", "riotshield_zm_given", "equip_turbine_zm_given", "equip_turret_zm_given", "jetgun_zm_given" );
/#
#/
	self giveachievement_wrapper( "ZM_STANDARD_EQUIPMENT_MAY_VARY" );
}

achievement_you_have_no_power_over_me()
{
	level endon( "end_game" );
	self endon( "avogadro_damage_taken" );
	level waittill( "avogadro_defeated" );
/#
#/
	self giveachievement_wrapper( "ZM_YOU_HAVE_NO_POWER_OVER_ME" );
}

achievement_i_dont_think_they_exist()
{
	level endon( "end_game" );
	self waittill( "i_dont_think_they_exist" );
/#
#/
	self giveachievement_wrapper( "ZM_I_DONT_THINK_THEY_EXIST" );
}

achievement_fuel_efficient()
{
	level endon( "end_game" );
	self waittill( "used_screecher_hole" );
/#
#/
	self giveachievement_wrapper( "ZM_FUEL_EFFICIENT" );
}

achievement_zm_happy_hour()
{
	level endon( "end_game" );
	level endon( "power_on" );
	while ( 1 )
	{
		self waittill( "perk_acquired" );
		if ( isDefined( self.perk_history ) && self.perk_history.size >= 2 )
		{
			break;
		}
		else
		{
		}
	}
/#
#/
	self giveachievement_wrapper( "ZM_HAPPY_HOUR" );
}

achievement_sound_func( achievement_name_lower )
{
	self thread do_player_general_vox( "general", "achievement" );
}
