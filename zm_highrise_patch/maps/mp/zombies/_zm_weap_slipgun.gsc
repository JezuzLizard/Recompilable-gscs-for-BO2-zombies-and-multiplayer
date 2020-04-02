#include maps/mp/zombies/_zm_audio;
#include maps/mp/zombies/_zm_powerups;
#include maps/mp/zombies/_zm_ai_basic;
#include maps/mp/animscripts/zm_shared;
#include maps/mp/animscripts/zm_utility;
#include maps/mp/zombies/_zm;
#include maps/mp/zombies/_zm_spawner;
#include maps/mp/gametypes_zm/_weaponobjects;
#include maps/mp/zombies/_zm_equipment;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

set_zombie_var_once( var, value, is_float, column, is_team_based )
{
	if ( !isDefined( level.zombie_vars ) || !isDefined( level.zombie_vars[ var ] ) )
	{
		set_zombie_var( var, value, is_float, column, is_team_based );
	}
}

init()
{
	if ( !maps/mp/zombies/_zm_weapons::is_weapon_included( "slipgun_zm" ) )
	{
		return;
	}
	precachemodel( "t5_weapon_crossbow_bolt" );
	precacheitem( "slip_bolt_zm" );
	precacheitem( "slip_bolt_upgraded_zm" );
	if ( is_true( level.slipgun_as_equipment ) )
	{
		maps/mp/zombies/_zm_equipment::register_equipment( "slipgun_zm", &"ZM_HIGHRISE_EQUIP_SLIPGUN_PICKUP_HINT_STRING", &"ZM_HIGHRISE_EQUIP_SLIPGUN_HOWTO", "jetgun_zm_icon", "slipgun", ::slipgun_activation_watcher_thread, ::transferslipgun, ::dropslipgun, ::pickupslipgun );
		maps/mp/zombies/_zm_equipment::enemies_ignore_equipment( "slipgun_zm" );
		maps/mp/gametypes_zm/_weaponobjects::createretrievablehint( "slipgun", &"ZM_HIGHRISE_EQUIP_SLIPGUN_PICKUP_HINT_STRING" );
	}
	set_zombie_var_once( "slipgun_reslip_max_spots", 8 );
	set_zombie_var_once( "slipgun_reslip_rate", 6 );
	set_zombie_var_once( "slipgun_max_kill_chain_depth", 16 );
	set_zombie_var_once( "slipgun_max_kill_round", 100 );
	set_zombie_var_once( "slipgun_chain_radius", 120 );
	set_zombie_var_once( "slipgun_chain_wait_min", 0.75, 1 );
	set_zombie_var_once( "slipgun_chain_wait_max", 1.5, 1 );
	level.slippery_spot_count = 0;
	level.sliquifier_distance_checks = 0;
	maps/mp/zombies/_zm_spawner::register_zombie_damage_callback( ::slipgun_zombie_damage_response );
	maps/mp/zombies/_zm_spawner::register_zombie_death_animscript_callback( ::slipgun_zombie_death_response );
	level._effect[ "slipgun_explode" ] = loadfx( "weapon/liquifier/fx_liquifier_goo_explo" );
	level._effect[ "slipgun_splatter" ] = loadfx( "maps/zombie/fx_zmb_goo_splat" );
	level._effect[ "slipgun_simmer" ] = loadfx( "weapon/liquifier/fx_liquifier_goo_sizzle" );
	level._effect[ "slipgun_viewmodel_eject" ] = loadfx( "weapon/liquifier/fx_liquifier_clip_eject" );
	level._effect[ "slipgun_viewmodel_reload" ] = loadfx( "weapon/liquifier/fx_liquifier_reload_steam" );
	onplayerconnect_callback( ::slipgun_player_connect );
	thread wait_init_damage();
}

wait_init_damage()
{
	while ( !isDefined( level.zombie_vars ) || !isDefined( level.zombie_vars[ "zombie_health_start" ] ) )
	{
		wait 1;
	}
	wait 1;
	level.slipgun_damage = maps/mp/zombies/_zm::ai_zombie_health( level.zombie_vars[ "slipgun_max_kill_round" ] );
	level.slipgun_damage_mod = "MOD_PROJECTILE_SPLASH";
}

slipgun_player_connect()
{
	self thread watch_for_slip_bolt();
}

watch_for_slip_bolt()
{
	self endon( "death" );
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "grenade_fire", grenade, weaponname, parent );
		self.num_sliquifier_kills = 0;
		switch( weaponname )
		{
			case "slip_bolt_zm":
				grenade thread slip_bolt( self, 0 );
				break;
			continue;
			case "slip_bolt_upgraded_zm":
				grenade thread slip_bolt( self, 1 );
				break;
			continue;
		}
	}
}

slip_bolt( player, upgraded )
{
	startpos = player getweaponmuzzlepoint();
	self waittill( "explode", position );
	duration = 24;
	if ( upgraded )
	{
		duration = 36;
	}
	thread add_slippery_spot( position, duration, startpos );
}

dropslipgun()
{
	item = self maps/mp/zombies/_zm_equipment::placed_equipment_think( "t6_wpn_zmb_slipgun_world", "slipgun_zm", self.origin + vectorScale( ( 0, 0, 1 ), 30 ), self.angles );
	if ( isDefined( item ) )
	{
		item.original_owner = self;
		item.owner = undefined;
		item.name = "slipgun_zm";
		item.requires_pickup = 1;
		item.clipammo = self getweaponammoclip( item.name );
		item.stockammo = self getweaponammostock( item.name );
	}
	self takeweapon( "slipgun_zm" );
	return item;
}

pickupslipgun( item )
{
	item.owner = self;
	self giveweapon( item.name );
	if ( isDefined( item.clipammo ) && isDefined( item.stockammo ) )
	{
		self setweaponammoclip( item.name, item.clipammo );
		self setweaponammostock( item.name, item.stockammo );
		item.clipammo = undefined;
		item.stockammo = undefined;
	}
}

transferslipgun( fromplayer, toplayer )
{
	toplayer notify( "slipgun_zm_taken" );
	fromplayer notify( "slipgun_zm_taken" );
}

slipgun_activation_watcher_thread()
{
	self endon( "zombified" );
	self endon( "disconnect" );
	self endon( "slipgun_zm_taken" );
	while ( 1 )
	{
		self waittill_either( "slipgun_zm_activate", "slipgun_zm_deactivate" );
	}
}

slipgun_debug_circle( origin, radius, seconds, onslope, parent, start )
{
/*
/#
	if ( getDvarInt( #"6136A815" ) )
	{
		frames = int( 20 * seconds );
		if ( isDefined( parent ) )
		{
			time = seconds;
			frames = 1;
			while ( time > 0 )
			{
				morigin = origin + ( parent.origin - start );
				if ( isDefined( onslope ) && onslope )
				{
					circle( morigin, radius, ( 0, 0, 1 ), 0, 1, frames );
				}
				else
				{
					circle( morigin, radius, ( 0, 0, 1 ), 0, 1, frames );
				}
				time -= 0,05;
				wait 0,05;
			}
		}
		else if ( isDefined( onslope ) && onslope )
		{
			circle( origin, radius, ( 0, 0, 1 ), 0, 1, frames );
			return;
		}
		else
		{
			circle( origin, radius, ( 0, 0, 1 ), 0, 1, frames );
#/
		}
	}
*/
}

slipgun_debug_line( start, end, color, seconds )
{
/*
/#
	if ( getDvarInt( #"6136A815" ) )
	{
		frames = int( 20 * seconds );
		line( start, end, color, 1, 0, frames );
#/
	}
*/
}

canzombieongoofall()
{
	if ( is_true( self.is_inert ) )
	{
		return 0;
	}
	if ( is_true( self.is_traversing ) )
	{
		return 0;
	}
	if ( is_true( self.barricade_enter ) )
	{
		return 0;
	}
	if ( randomint( 100 ) < 20 )
	{
		trace = groundtrace( self.origin + vectorScale( ( 0, 0, 1 ), 5 ), self.origin + vectorScale( ( 0, 0, 1 ), 300 ), 0, undefined );
		origin = trace[ "position" ];
		groundnormal = trace[ "normal" ];
		if ( distancesquared( self.origin, origin ) > 256 )
		{
			return 0;
		}
		dot = vectordot( ( 0, 0, 1 ), groundnormal );
		if ( dot < 0.9 )
		{
			return 0;
		}
		trace_origin = self.origin + vectorScale( anglesToForward( self.angles ), 200 );
		trace = groundtrace( trace_origin + vectorScale( ( 0, 0, 1 ), 5 ), self.origin + vectorScale( ( 0, 0, 1 ), 300 ), 0, undefined );
		origin = trace[ "position" ];
		groundnormal = trace[ "normal" ];
		if ( distancesquared( trace_origin, origin ) > 256 )
		{
			return 0;
		}
		dot = vectordot( ( 0, 0, 1 ), groundnormal );
		if ( dot < 0.9 )
		{
			return 0;
		}
		return 1;
	}
	return 0;
}

zombiemoveongoo()
{
	self endon( "death" );
	self endon( "removed" );
	level endon( "intermission" );
	if ( is_true( self.sliding_on_goo ) )
	{
		return;
	}
	self notify( "endOnGoo" );
	self endon( "endOnGoo" );
	self notify( "stop_zombie_goto_entrance" );
	self notify( "stop_find_flesh" );
	self notify( "zombie_acquire_enemy" );
	self.goo_last_vel = self getvelocity();
	self.goo_last_pos = self.origin;
	slide_direction = anglesToForward( self.angles );
	self animmode( "slide" );
	self orientmode( "face enemy" );
	self.forcemovementscriptstate = 1;
	self.ai_state = "zombieMoveOnGoo";
	self maps/mp/zombies/_zm_spawner::zombie_history( "zombieMoveOnGoo " + getTime() );
	self.sliding_on_goo = 0;
	self thread zombiemoveongoo_on_killanimscript();
	for ( ;; )
	{
		while ( 1 )
		{
			if ( isDefined( self.is_on_goo ) )
			{
				self_on_goo = self.is_on_goo;
			}
			velocity = self getvelocity();
			velocitylength = length( self getvelocity() );
			if ( isDefined( self.has_legs ) )
			{
				iscrawler = !self.has_legs;
			}
			isleaper = self is_leaper();
			while ( is_true( self.is_leaping ) )
			{
				wait 0.1;
			}
			if ( !self_on_goo )
			{
				self animcustom( ::zombie_moveongoo_animcustom_recover );
				self waittill( "zombie_MoveOnGoo_animCustom_recover_done" );
				break;
			}
			else
			{
				if ( velocitylength <= 0.2 )
				{
					self animmode( "normal" );
					wait 0.1;
					self animmode( "slide" );
				}
				if ( !self.sliding_on_goo || !issubstr( self.zombie_move_speed, "slide" ) )
				{
					if ( !iscrawler && !isleaper && !isDefined( self.fell_while_sliding ) && canzombieongoofall() )
					{
						self animcustom( ::zombie_moveongoo_animcustom_fall );
						self waittill( "zombie_MoveOnGoo_animCustom_fall_done" );
					}
				}
				else self.sliding_on_goo = 1;
				if ( velocitylength <= 0.2 )
				{
					wait 0.1;
				}
				self animmode( "slide" );
				self orientmode( "face enemy" );
				if ( self.zombie_move_speed == "sprint" )
				{
					if ( !isDefined( self.zombie_move_speed ) || isDefined( self.zombie_move_speed ) && self.zombie_move_speed != "sprint_slide" )
					{
						animstatedef = self maps/mp/animscripts/zm_utility::append_missing_legs_suffix( "sprint_slide" );
						self set_zombie_run_cycle( animstatedef );
					}
					break;
				}
				else if ( self.zombie_move_speed == "run" )
				{
					if ( !isDefined( self.zombie_move_speed ) || isDefined( self.zombie_move_speed ) && self.zombie_move_speed != "run_slide" )
					{
						animstatedef = self maps/mp/animscripts/zm_utility::append_missing_legs_suffix( "run_slide" );
						self set_zombie_run_cycle( animstatedef );
					}
					break;
				}
				else
				{
					if ( !isDefined( self.zombie_move_speed ) || isDefined( self.zombie_move_speed ) && self.zombie_move_speed != "walk_slide" )
					{
						animstatedef = self maps/mp/animscripts/zm_utility::append_missing_legs_suffix( "walk_slide" );
						self set_zombie_run_cycle( animstatedef );
					}
				}
			}
			wait 0.05;
		}
	}
	zombiemoveongoo_gobacktonormal();
}

zombie_moveongoo_animcustom_fall()
{
	self endon( "death" );
	self endon( "removed" );
	level endon( "intermission" );
	self.fell_while_sliding = 1;
	self animmode( "normal" );
	self orientmode( "face angle", self.angles[ 1 ] );
	fallanimstatedef = "zm_move_slide_fall";
	self setanimstatefromasd( fallanimstatedef );
	maps/mp/animscripts/zm_shared::donotetracks( "slide_fall_anim" );
	self notify( "zombie_MoveOnGoo_animCustom_fall_done" );
}

zombie_moveongoo_animcustom_recover()
{
	self endon( "death" );
	self endon( "removed" );
	level endon( "intermission" );
	self.recovering_from_goo = 1;
	if ( randomint( 100 ) < 50 )
	{
		animstatedef = maps/mp/animscripts/zm_utility::append_missing_legs_suffix( "zm_move_slide_recover" );
		self setanimstatefromasd( animstatedef );
		maps/mp/animscripts/zm_shared::donotetracks( "slide_recover_anim" );
	}
	self.recovering_from_goo = 0;
	zombiemoveongoo_gobacktonormal();
	self notify( "zombie_MoveOnGoo_animCustom_recover_done" );
}

zombiemoveongoo_on_killanimscript()
{
	self endon( "death" );
	self endon( "removed" );
	level endon( "intermission" );
	self notify( "zombieMoveOnGoo_on_killAnimScript_thread" );
	self endon( "zombieMoveOnGoo_on_killAnimScript_thread" );
	self waittill_any( "endOnGoo", "killanimscript" );
	zombiemoveongoo_gobacktonormal();
}

zombiemoveongoo_gobacktonormal()
{
	self animmode( "normal" );
	self set_zombie_run_cycle();
	self.sliding_on_goo = 0;
	self.fell_while_sliding = undefined;
	self notify( "zombieMoveOnGoo_on_killAnimScript_thread" );
	self notify( "endOnGoo" );
	self.forcemovementscriptstate = 0;
	if ( !is_true( self.completed_emerging_into_playable_area ) )
	{
	/*
/#
		assert( isDefined( self.first_node ) );
#/
	*/
		self maps/mp/zombies/_zm_spawner::reset_attack_spot();
		self orientmode( "face default" );
		self thread maps/mp/zombies/_zm_spawner::zombie_goto_entrance( self.first_node );
	}
	else
	{
		self orientmode( "face enemy" );
		self thread maps/mp/zombies/_zm_ai_basic::find_flesh();
	}
}

zombie_can_slip()
{
	if ( is_true( self.barricade_enter ) )
	{
		return 0;
	}
	if ( is_true( self.is_traversing ) )
	{
		return 0;
	}
	if ( !is_true( self.completed_emerging_into_playable_area ) && !isDefined( self.first_node ) )
	{
		return 0;
	}
	if ( is_true( self.is_leaping ) )
	{
		return 0;
	}
	return 1;
}

zombie_set_slipping( onoff )
{
	if ( isDefined( self ) )
	{
		self.is_on_goo = onoff;
		if ( onoff )
		{
			self thread zombiemoveongoo();
		}
	}
}

slippery_spot_choke( lifetime )
{
	level.sliquifier_distance_checks++;
	if ( level.sliquifier_distance_checks >= 32 )
	{
		level.sliquifier_distance_checks = 0;
		lifetime -= 0.05;
		wait 0.05;
	}
	return lifetime;
}

add_slippery_spot( origin, duration, startpos )
{
	wait 0.5;
	level.slippery_spot_count++;
	hit_norm = vectornormalize( startpos - origin );
	hit_from = 6 * hit_norm;
	trace_height = 120;
	trace = bullettrace( origin + hit_from, origin + hit_from + ( 0, 0, trace_height * -1 ), 0, undefined );
	if ( isDefined( trace[ "entity" ] ) )
	{
		parent = trace[ "entity" ];
		if ( is_true( parent.can_move ) )
		{
			return;
		}
	}
	fxorigin = origin + hit_from;
	/*
/#
	red = ( 0, 0, 1 );
	green = ( 0, 0, 1 );
	dkgreen = vectorScale( ( 0, 0, 1 ), 0,15 );
	blue = ( 0, 0, 1 );
	grey = vectorScale( ( 0, 0, 1 ), 0,3 );
	black = ( 0, 0, 1 );
	slipgun_debug_line( origin, origin + hit_from, red, duration );
	if ( trace[ "fraction" ] == 1 )
	{
		slipgun_debug_line( origin + hit_from, origin + hit_from + ( 0, 0, trace_height * -1 ), grey, duration );
	}
	else
	{
		slipgun_debug_line( origin + hit_from, trace[ "position" ], green, duration );
		slipgun_debug_line( trace[ "position" ], origin + hit_from + ( 0, 0, trace_height * -1 ), dkgreen, duration );
#/
	}
	*/
	if ( trace[ "fraction" ] == 1 )
	{
		return;
	}
	moving_parent = undefined;
	moving_parent_start = ( 0, 0, 1 );
	if ( isDefined( trace[ "entity" ] ) )
	{
		parent = trace[ "entity" ];
		if ( is_true( parent.can_move ) )
		{
			return;
		}
	}
	origin = trace[ "position" ];
	thread pool_of_goo( fxorigin, duration );
	if ( !isDefined( level.slippery_spots ) )
	{
		level.slippery_spots = [];
	}
	level.slippery_spots[ level.slippery_spots.size ] = origin;
	radius = 60;
	height = 48;
	/*
/#
	thread slipgun_debug_circle( origin, radius, duration, 0, moving_parent, moving_parent_start );
#/
	*/
	slicked_players = [];
	slicked_zombies = [];
	lifetime = duration;
	radius2 = radius * radius;
	while ( lifetime > 0 )
	{
		oldlifetime = lifetime;
		_a612 = get_players();
		_k612 = getFirstArrayKey( _a612 );
		while ( isDefined( _k612 ) )
		{
			player = _a612[ _k612 ];
			num = player getentitynumber();
			morigin = origin;
			if ( isDefined( moving_parent ) )
			{
				morigin = origin + ( moving_parent.origin - moving_parent_start );
			}
			if ( distance2dsquared( player.origin, morigin ) < radius2 )
			{
				should_be_slick = abs( player.origin[ 2 ] - morigin[ 2 ] ) < height;
			}
			is_slick = isDefined( slicked_players[ num ] );
			if ( should_be_slick != is_slick )
			{
				if ( !isDefined( player.slick_count ) )
				{
					player.slick_count = 0;
				}
				if ( should_be_slick )
				{
					player.slick_count++;
					slicked_players[ num ] = player;
				}
				else
				{
					player.slick_count--;
/*
/#
					assert( player.slick_count >= 0 );
#/
*/
				}
				player forceslick( player.slick_count );
			}
			lifetime = slippery_spot_choke( lifetime );
			_k612 = getNextArrayKey( _a612, _k612 );
		}
		zombies = get_round_enemy_array();
		while ( isDefined( zombies ) )
		{
			_a645 = zombies;
			_k645 = getFirstArrayKey( _a645 );
			while ( isDefined( _k645 ) )
			{
				zombie = _a645[ _k645 ];
				if ( isDefined( zombie ) )
				{
					num = zombie getentitynumber();
					morigin = origin;
					if ( isDefined( moving_parent ) )
					{
						morigin = origin + ( moving_parent.origin - moving_parent_start );
					}
					if ( distance2dsquared( zombie.origin, morigin ) < radius2 )
					{
						should_be_slick = abs( zombie.origin[ 2 ] - morigin[ 2 ] ) < height;
					}
					if ( should_be_slick && !zombie zombie_can_slip() )
					{
						should_be_slick = 0;
					}
					is_slick = isDefined( slicked_zombies[ num ] );
					if ( should_be_slick != is_slick )
					{
						if ( !isDefined( zombie.slick_count ) )
						{
							zombie.slick_count = 0;
						}
						if ( should_be_slick )
						{
							zombie.slick_count++;
							slicked_zombies[ num ] = zombie;
						}
						else
						{
							if ( zombie.slick_count > 0 )
							{
								zombie.slick_count--;

							}
						}
						zombie zombie_set_slipping( zombie.slick_count > 0 );
					}
					lifetime = slippery_spot_choke( lifetime );
				}
				_k645 = getNextArrayKey( _a645, _k645 );
			}
		}
		if ( oldlifetime == lifetime )
		{
			lifetime -= 0.05;
			wait 0.05;
		}
	}
	_a684 = slicked_players;
	_k684 = getFirstArrayKey( _a684 );
	while ( isDefined( _k684 ) )
	{
		player = _a684[ _k684 ];
		player.slick_count--;
		/*

/#
		assert( player.slick_count >= 0 );
#/
	*/
		player forceslick( player.slick_count );
		_k684 = getNextArrayKey( _a684, _k684 );
	}
	_a690 = slicked_zombies;
	_k690 = getFirstArrayKey( _a690 );
	while ( isDefined( _k690 ) )
	{
		zombie = _a690[ _k690 ];
		if ( isDefined( zombie ) )
		{
			if ( zombie.slick_count > 0 )
			{
				zombie.slick_count--;

			}
			zombie zombie_set_slipping( zombie.slick_count > 0 );
		}
		_k690 = getNextArrayKey( _a690, _k690 );
	}
	arrayremovevalue( level.slippery_spots, origin, 0 );
	level.slippery_spot_count--;

}

pool_of_goo( origin, duration )
{
	effect_life = 24;
	if ( duration > effect_life )
	{
		pool_of_goo( origin, duration - effect_life );
		duration = effect_life;
	}
	if ( isDefined( level._effect[ "slipgun_splatter" ] ) )
	{
		playfx( level._effect[ "slipgun_splatter" ], origin );
	}
	wait duration;
}

explode_into_goo( player, chain_depth )
{
	if ( isDefined( self.marked_for_insta_upgraded_death ) )
	{
		return;
	}
	tag = "J_SpineLower";
	if ( is_true( self.isdog ) )
	{
		tag = "tag_origin";
	}
	self.guts_explosion = 1;
	self playsound( "wpn_slipgun_zombie_explode" );
	if ( isDefined( level._effect[ "slipgun_explode" ] ) )
	{
		playfx( level._effect[ "slipgun_explode" ], self gettagorigin( tag ) );
	}
	if ( !is_true( self.isdog ) )
	{
		wait 0.1;
	}
	self ghost();
	if ( !isDefined( self.goo_chain_depth ) )
	{
		self.goo_chain_depth = chain_depth;
	}
	chain_radius = level.zombie_vars[ "slipgun_chain_radius" ];
	level thread explode_to_near_zombies( player, self.origin, chain_radius, self.goo_chain_depth );
}

explode_to_near_zombies( player, origin, radius, chain_depth )
{
	if ( level.zombie_vars[ "slipgun_max_kill_chain_depth" ] > 0 && chain_depth > level.zombie_vars[ "slipgun_max_kill_chain_depth" ] )
	{
		return;
	}
	enemies = get_round_enemy_array();
	enemies = get_array_of_closest( origin, enemies );
	minchainwait = level.zombie_vars[ "slipgun_chain_wait_min" ];
	maxchainwait = level.zombie_vars[ "slipgun_chain_wait_max" ];
	rsquared = radius * radius;
	tag = "J_Head";
	marked_zombies = [];
	while ( isDefined( enemies ) && enemies.size )
	{
		index = 0;
		enemy = enemies[ index ];
		while ( distancesquared( enemy.origin, origin ) < rsquared )
		{
			if ( isalive( enemy ) && !is_true( enemy.guts_explosion ) && !is_true( enemy.nuked ) && !isDefined( enemy.slipgun_sizzle ) )
			{
				trace = bullettrace( origin + vectorScale( ( 0, 0, 1 ), 50 ), enemy.origin + vectorScale( ( 0, 0, 1 ), 50 ), 0, undefined, 1 );
				if ( isDefined( trace[ "fraction" ] ) && trace[ "fraction" ] == 1 )
				{
					enemy.slipgun_sizzle = playfxontag( level._effect[ "slipgun_simmer" ], enemy, tag );
					marked_zombies[ marked_zombies.size ] = enemy;
				}
			}
			index++;
			if ( index >= enemies.size )
			{
				break;
			}
			else
			{
				enemy = enemies[ index ];
			}
		}
	}
	while ( isDefined( marked_zombies ) && marked_zombies.size )
	{
		_a799 = marked_zombies;
		_k799 = getFirstArrayKey( _a799 );
		while ( isDefined( _k799 ) )
		{
			enemy = _a799[ _k799 ];
			if ( isalive( enemy ) && !is_true( enemy.guts_explosion ) && !is_true( enemy.nuked ) )
			{
				wait randomfloatrange( minchainwait, maxchainwait );
				if ( isalive( enemy ) && !is_true( enemy.guts_explosion ) && !is_true( enemy.nuked ) )
				{
					if ( !isDefined( enemy.goo_chain_depth ) )
					{
						enemy.goo_chain_depth = chain_depth;
					}
					if ( enemy.health > 0 )
					{
						if ( player maps/mp/zombies/_zm_powerups::is_insta_kill_active() )
						{
							enemy.health = 1;
						}
						enemy dodamage( level.slipgun_damage, origin, player, player, "none", level.slipgun_damage_mod, 0, "slip_goo_zm" );
					}
					if ( level.slippery_spot_count < level.zombie_vars[ "slipgun_reslip_max_spots" ] )
					{
						if ( isDefined( enemy.slick_count ) && enemy.slick_count == 0 && enemy.health <= 0 )
						{
							if ( level.zombie_vars[ "slipgun_reslip_rate" ] > 0 && randomint( level.zombie_vars[ "slipgun_reslip_rate" ] ) == 0 )
							{
								startpos = origin;
								duration = 24;
								thread add_slippery_spot( enemy.origin, duration, startpos );
							}
						}
					}
				}
			}
			_k799 = getNextArrayKey( _a799, _k799 );
		}
	}
}

slipgun_zombie_1st_hit_response( upgraded, player )
{
	self notify( "stop_find_flesh" );
	self notify( "zombie_acquire_enemy" );
	self orientmode( "face default" );
	self.ignoreall = 1;
	self.gibbed = 1;
	if ( isalive( self ) )
	{
		if ( !isDefined( self.goo_chain_depth ) )
		{
			self.goo_chain_depth = 0;
		}
		if ( self.health > 0 )
		{
			if ( player maps/mp/zombies/_zm_powerups::is_insta_kill_active() )
			{
				self.health = 1;
			}
			self dodamage( level.slipgun_damage, self.origin, player, player, "none", level.slipgun_damage_mod, 0, "slip_goo_zm" );
		}
	}
}

slipgun_zombie_hit_response_internal( mod, damageweapon, player )
{
	if ( !self is_slipgun_damage( mod, damageweapon ) && !is_slipgun_explosive_damage( mod, damageweapon ) )
	{
		return 0;
	}
	self playsound( "wpn_slipgun_zombie_impact" );
	upgraded = damageweapon == "slipgun_upgraded_zm";
	self thread slipgun_zombie_1st_hit_response( upgraded, player );
	if ( isDefined( player ) && isplayer( player ) )
	{
		player thread slipgun_play_zombie_hit_vox();
	}
	return 1;
}

slipgun_zombie_damage_response( mod, hit_location, hit_origin, player, amount )
{
	return slipgun_zombie_hit_response_internal( mod, self.damageweapon, player );
}

slipgun_zombie_death_response()
{
	if ( !self is_slipgun_damage( self.damagemod, self.damageweapon ) && !is_slipgun_explosive_damage( self.damagemod, self.damageweapon ) )
	{
		return 0;
	}
	level maps/mp/zombies/_zm_spawner::zombie_death_points( self.origin, self.damagemod, self.damagelocation, self.attacker, self );
	self explode_into_goo( self.attacker, 0 );
	return 1;
}

is_slipgun_explosive_damage( mod, weapon )
{
	if ( isDefined( weapon ) )
	{
		if ( weapon != "slip_goo_zm" && weapon != "slip_bolt_zm" )
		{
			return weapon == "slip_bolt_upgraded_zm";
		}
	}
}

is_slipgun_damage( mod, weapon )
{
	if ( isDefined( weapon ) )
	{
		if ( weapon != "slipgun_zm" )
		{
			return weapon == "slipgun_upgraded_zm";
		}
	}
}

slipgun_play_zombie_hit_vox()
{
	rand = randomintrange( 0, 101 );
	if ( rand >= 20 )
	{
		self maps/mp/zombies/_zm_audio::create_and_play_dialog( "kill", "human" );
	}
}

