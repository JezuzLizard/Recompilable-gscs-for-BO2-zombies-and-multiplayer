#include maps/mp/_visionset_mgr;
#include maps/mp/zombies/_zm_ai_basic;
#include maps/mp/zombies/_zm_score;
#include maps/mp/zombies/_zm_net;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;

init()
{
	level.custom_laststand_func = ::electric_cherry_laststand;
	level._effect[ "electric_cherry_explode" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_electric_cherry_player" );
	level._effect[ "tesla_shock" ] = loadfx( "maps/zombie/fx_zombie_tesla_shock" );
	level._effect[ "tesla_shock_secondary" ] = loadfx( "maps/zombie/fx_zombie_tesla_shock_secondary" );
	set_zombie_var( "tesla_head_gib_chance", 50 );
}

electric_cherry_player_init()
{
}

electric_cherry_laststand()
{
	perk_radius = 500;
	perk_dmg = 1000;
	perk_points = 40;
	perk_delay = 1,5;
	self thread electric_cherry_visionset();
	wait perk_delay;
	visionsetlaststand( "zm_electric_cherry", 1 );
	while ( isDefined( self ) )
	{
		playfx( level._effect[ "electric_cherry_explode" ], self.origin );
		self playsound( "zmb_cherry_explode" );
		a_zombies = get_round_enemy_array();
		a_zombies = get_array_of_closest( self.origin, a_zombies, undefined, undefined, perk_radius );
		i = 0;
		while ( i < a_zombies.size )
		{
			if ( isDefined( self ) && isalive( self ) )
			{
				if ( a_zombies[ i ].health <= perk_dmg )
				{
					a_zombies[ i ] thread electric_cherry_death_fx();
					self maps/mp/zombies/_zm_score::add_to_player_score( perk_points );
				}
				else
				{
					a_zombies[ i ] thread electric_cherry_stun();
					a_zombies[ i ] thread electric_cherry_shock_fx();
				}
				wait 0,1;
				a_zombies[ i ] dodamage( perk_dmg, self.origin, self );
			}
			i++;
		}
	}
}

electric_cherry_death_fx()
{
	self endon( "death" );
	tag = "J_SpineUpper";
	fx = "tesla_shock";
	if ( self.isdog )
	{
		tag = "J_Spine1";
	}
	self playsound( "zmb_elec_jib_zombie" );
	network_safe_play_fx_on_tag( "tesla_death_fx", 2, level._effect[ fx ], self, tag );
	if ( isDefined( self.tesla_head_gib_func ) && !self.head_gibbed )
	{
		[[ self.tesla_head_gib_func ]]();
	}
}

electric_cherry_shock_fx()
{
	self endon( "death" );
	tag = "J_SpineUpper";
	fx = "tesla_shock_secondary";
	if ( self.isdog )
	{
		tag = "J_Spine1";
	}
	self playsound( "zmb_elec_jib_zombie" );
	network_safe_play_fx_on_tag( "tesla_shock_fx", 2, level._effect[ fx ], self, tag );
}

electric_cherry_stun()
{
	self endon( "death" );
	self notify( "stun_zombie" );
	self endon( "stun_zombie" );
	if ( self.health <= 0 )
	{
/#
		iprintln( "trying to stun a dead zombie" );
#/
		return;
	}
	if ( isDefined( self.stun_zombie ) )
	{
		self thread [[ self.stun_zombie ]]();
		return;
	}
	self thread maps/mp/zombies/_zm_ai_basic::start_inert();
}

electric_cherry_visionset()
{
	if ( isDefined( self ) && flag( "solo_game" ) )
	{
		if ( isDefined( level.vsmgr_prio_visionset_zm_electric_cherry ) )
		{
			if ( !isDefined( self.electric_cherry_visionset ) || self.electric_cherry_visionset == 0 )
			{
				maps/mp/_visionset_mgr::vsmgr_activate( "visionset", "zm_electric_cherry", self );
				self.electric_cherry_visionset = 1;
			}
		}
	}
	wait 5;
	if ( isDefined( self ) && isDefined( level.vsmgr_prio_visionset_zm_electric_cherry ) )
	{
		if ( isDefined( self.electric_cherry_visionset ) && self.electric_cherry_visionset )
		{
			maps/mp/_visionset_mgr::vsmgr_deactivate( "visionset", "zm_electric_cherry", self );
			self.electric_cherry_visionset = 0;
			return;
		}
		else
		{
			if ( !flag( "solo_game" ) )
			{
				visionsetlaststand( "zombie_last_stand", 1 );
			}
		}
	}
}
