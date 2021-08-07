#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/zombies/_zm_buildables;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

add_buildable_to_pool( stub, poolname )
{
	if ( !isDefined( level.buildablepools ) )
	{
		level.buildablepools = [];
	}
	if ( !isDefined( level.buildablepools[ poolname ] ) )
	{
		level.buildablepools[ poolname ] = spawnstruct();
		level.buildablepools[ poolname ].stubs = [];
	}
	level.buildablepools[ poolname ].stubs[ level.buildablepools[ poolname ].stubs.size ] = stub;
	if ( !isDefined( level.buildablepools[ poolname ].buildable_slot ) )
	{
		level.buildablepools[ poolname ].buildable_slot = stub.buildablestruct.buildable_slot;
	}
	else
	{
/#
		assert( level.buildablepools[ poolname ].buildable_slot == stub.buildablestruct.buildable_slot );
#/
	}
	stub.buildable_pool = level.buildablepools[ poolname ];
	stub.original_prompt_and_visibility_func = stub.prompt_and_visibility_func;
	stub.original_trigger_func = stub.trigger_func;
	stub.prompt_and_visibility_func = ::pooledbuildabletrigger_update_prompt;
	reregister_unitrigger( stub, ::pooled_buildable_place_think );
}

reregister_unitrigger( unitrigger_stub, new_trigger_func )
{
	static = 0;
	if ( isDefined( unitrigger_stub.in_zone ) )
	{
		static = 1;
	}
	unregister_unitrigger( unitrigger_stub );
	unitrigger_stub.trigger_func = new_trigger_func;
	if ( static )
	{
		register_static_unitrigger( unitrigger_stub, new_trigger_func, 0 );
	}
	else
	{
		register_unitrigger( unitrigger_stub, new_trigger_func );
	}
}

randomize_pooled_buildables( poolname )
{
	level waittill( "buildables_setup" );
	while ( isDefined( level.buildablepools[ poolname ] ) )
	{
		count = level.buildablepools[ poolname ].stubs.size;
		while ( count > 1 )
		{
			targets = [];
			i = 0;
			while ( i < count )
			{
				while ( 1 )
				{
					p = randomint( count );
					if ( !isDefined( targets[ p ] ) )
					{
						targets[ p ] = i;
						i++;
						continue;
					}
					else
					{
					}
				}
				i++;
			}
			i = 0;
			while ( i < count )
			{
				if ( isDefined( targets[ i ] ) && targets[ i ] != i )
				{
					swap_buildable_fields( level.buildablepools[ poolname ].stubs[ i ], level.buildablepools[ poolname ].stubs[ targets[ i ] ] );
				}
				i++;
			}
		}
	}
}

pooledbuildable_has_piece( piece )
{
	return isDefined( self pooledbuildable_stub_for_piece( piece ) );
}

pooledbuildable_stub_for_piece( piece )
{
	_a104 = self.stubs;
	_k104 = getFirstArrayKey( _a104 );
	while ( isDefined( _k104 ) )
	{
		stub = _a104[ _k104 ];
		if ( isDefined( stub.bound_to_buildable ) )
		{
		}
		else
		{
			if ( stub.buildablezone buildable_has_piece( piece ) )
			{
				return stub;
			}
		}
		_k104 = getNextArrayKey( _a104, _k104 );
	}
	return undefined;
}

pooledbuildabletrigger_update_prompt( player )
{
	can_use = self.stub pooledbuildablestub_update_prompt( player, self );
	self sethintstring( self.stub.hint_string );
	if ( isDefined( self.stub.cursor_hint ) )
	{
		if ( self.stub.cursor_hint == "HINT_WEAPON" && isDefined( self.stub.cursor_hint_weapon ) )
		{
			self setcursorhint( self.stub.cursor_hint, self.stub.cursor_hint_weapon );
		}
		else
		{
			self setcursorhint( self.stub.cursor_hint );
		}
	}
	return can_use;
}

pooledbuildablestub_update_prompt( player, trigger )
{
	if ( !self anystub_update_prompt( player ) )
	{
		return 0;
	}
	can_use = 1;
	if ( isDefined( self.custom_buildablestub_update_prompt ) && !( self [[ self.custom_buildablestub_update_prompt ]]( player ) ) )
	{
		return 0;
	}
	self.cursor_hint = "HINT_NOICON";
	self.cursor_hint_weapon = undefined;
	if ( isDefined( self.built ) && !self.built )
	{
		slot = self.buildablestruct.buildable_slot;
		if ( !isDefined( player player_get_buildable_piece( slot ) ) )
		{
			if ( isDefined( level.zombie_buildables[ self.equipname ].hint_more ) )
			{
				self.hint_string = level.zombie_buildables[ self.equipname ].hint_more;
			}
			else
			{
				self.hint_string = &"ZOMBIE_BUILD_PIECE_MORE";
			}
			if ( isDefined( level.custom_buildable_need_part_vo ) )
			{
				player thread [[ level.custom_buildable_need_part_vo ]]();
			}
			return 0;
		}
		else
		{
			if ( isDefined( self.bound_to_buildable ) && !self.bound_to_buildable.buildablezone buildable_has_piece( player player_get_buildable_piece( slot ) ) )
			{
				if ( isDefined( level.zombie_buildables[ self.bound_to_buildable.equipname ].hint_wrong ) )
				{
					self.hint_string = level.zombie_buildables[ self.bound_to_buildable.equipname ].hint_wrong;
				}
				else
				{
					self.hint_string = &"ZOMBIE_BUILD_PIECE_WRONG";
				}
				if ( isDefined( level.custom_buildable_wrong_part_vo ) )
				{
					player thread [[ level.custom_buildable_wrong_part_vo ]]();
				}
				return 0;
			}
			else
			{
				if ( !isDefined( self.bound_to_buildable ) && !self.buildable_pool pooledbuildable_has_piece( player player_get_buildable_piece( slot ) ) )
				{
					if ( isDefined( level.zombie_buildables[ self.equipname ].hint_wrong ) )
					{
						self.hint_string = level.zombie_buildables[ self.equipname ].hint_wrong;
					}
					else
					{
						self.hint_string = &"ZOMBIE_BUILD_PIECE_WRONG";
					}
					return 0;
				}
				else
				{
					if ( isDefined( self.bound_to_buildable ) )
					{
/#
						assert( isDefined( level.zombie_buildables[ self.equipname ].hint ), "Missing buildable hint" );
#/
						if ( isDefined( level.zombie_buildables[ self.equipname ].hint ) )
						{
							self.hint_string = level.zombie_buildables[ self.equipname ].hint;
						}
						else
						{
							self.hint_string = "Missing buildable hint";
						}
					}
					else /#
					assert( isDefined( level.zombie_buildables[ self.equipname ].hint ), "Missing buildable hint" );
#/
					if ( isDefined( level.zombie_buildables[ self.equipname ].hint ) )
					{
						self.hint_string = level.zombie_buildables[ self.equipname ].hint;
					}
					else
					{
						self.hint_string = "Missing buildable hint";
					}
				}
			}
		}
	}
	else
	{
		return trigger [[ self.original_prompt_and_visibility_func ]]( player );
	}
	return 1;
}

find_bench( bench_name )
{
	return getent( bench_name, "targetname" );
}

swap_buildable_fields( stub1, stub2 )
{
	tbz = stub2.buildablezone;
	stub2.buildablezone = stub1.buildablezone;
	stub2.buildablezone.stub = stub2;
	stub1.buildablezone = tbz;
	stub1.buildablezone.stub = stub1;
	tbs = stub2.buildablestruct;
	stub2.buildablestruct = stub1.buildablestruct;
	stub1.buildablestruct = tbs;
	te = stub2.equipname;
	stub2.equipname = stub1.equipname;
	stub1.equipname = te;
	th = stub2.hint_string;
	stub2.hint_string = stub1.hint_string;
	stub1.hint_string = th;
	ths = stub2.trigger_hintstring;
	stub2.trigger_hintstring = stub1.trigger_hintstring;
	stub1.trigger_hintstring = ths;
	tp = stub2.persistent;
	stub2.persistent = stub1.persistent;
	stub1.persistent = tp;
	tobu = stub2.onbeginuse;
	stub2.onbeginuse = stub1.onbeginuse;
	stub1.onbeginuse = tobu;
	tocu = stub2.oncantuse;
	stub2.oncantuse = stub1.oncantuse;
	stub1.oncantuse = tocu;
	toeu = stub2.onenduse;
	stub2.onenduse = stub1.onenduse;
	stub1.onenduse = toeu;
	tt = stub2.target;
	stub2.target = stub1.target;
	stub1.target = tt;
	ttn = stub2.targetname;
	stub2.targetname = stub1.targetname;
	stub1.targetname = ttn;
	twn = stub2.weaponname;
	stub2.weaponname = stub1.weaponname;
	stub1.weaponname = twn;
	pav = stub2.original_prompt_and_visibility_func;
	stub2.original_prompt_and_visibility_func = stub1.original_prompt_and_visibility_func;
	stub1.original_prompt_and_visibility_func = pav;
	bench1 = undefined;
	bench2 = undefined;
	transfer_pos_as_is = 1;
	if ( isDefined( stub1.model.target ) && isDefined( stub2.model.target ) )
	{
		bench1 = find_bench( stub1.model.target );
		bench2 = find_bench( stub2.model.target );
		if ( isDefined( bench1 ) && isDefined( bench2 ) )
		{
			transfer_pos_as_is = 0;
			w2lo1 = bench1 worldtolocalcoords( stub1.model.origin );
			w2la1 = stub1.model.angles - bench1.angles;
			w2lo2 = bench2 worldtolocalcoords( stub2.model.origin );
			w2la2 = stub2.model.angles - bench2.angles;
			stub1.model.origin = bench2 localtoworldcoords( w2lo1 );
			stub1.model.angles = bench2.angles + w2la1;
			stub2.model.origin = bench1 localtoworldcoords( w2lo2 );
			stub2.model.angles = bench1.angles + w2la2;
		}
		tmt = stub2.model.target;
		stub2.model.target = stub1.model.target;
		stub1.model.target = tmt;
	}
	tm = stub2.model;
	stub2.model = stub1.model;
	stub1.model = tm;
	if ( transfer_pos_as_is )
	{
		tmo = stub2.model.origin;
		tma = stub2.model.angles;
		stub2.model.origin = stub1.model.origin;
		stub2.model.angles = stub1.model.angles;
		stub1.model.origin = tmo;
		stub1.model.angles = tma;
	}
}

pooled_buildable_place_think()
{
	self endon( "kill_trigger" );
	if ( isDefined( self.stub.built ) && self.stub.built )
	{
		return buildable_place_think();
	}
	player_built = undefined;
	while ( isDefined( self.stub.built ) && !self.stub.built )
	{
		self waittill( "trigger", player );
		while ( player != self.parent_player )
		{
			continue;
		}
		while ( isDefined( player.screecher_weapon ) )
		{
			continue;
		}
		while ( !is_player_valid( player ) )
		{
			player thread ignore_triggers( 0,5 );
		}
		bind_to = self.stub;
		slot = bind_to.buildablestruct.buildable_slot;
		if ( !isDefined( self.stub.bound_to_buildable ) )
		{
			bind_to = self.stub.buildable_pool pooledbuildable_stub_for_piece( player player_get_buildable_piece( slot ) );
		}
		while ( isDefined( bind_to ) && isDefined( self.stub.bound_to_buildable ) || self.stub.bound_to_buildable != bind_to && isDefined( bind_to.bound_to_buildable ) && self.stub != bind_to.bound_to_buildable )
		{
			self.stub.hint_string = "";
			self sethintstring( self.stub.hint_string );
			if ( isDefined( self.stub.oncantuse ) )
			{
				self.stub [[ self.stub.oncantuse ]]( player );
			}
		}
		status = player player_can_build( bind_to.buildablezone );
		if ( !status )
		{
			self.stub.hint_string = "";
			self sethintstring( self.stub.hint_string );
			if ( isDefined( bind_to.oncantuse ) )
			{
				bind_to [[ bind_to.oncantuse ]]( player );
			}
			continue;
		}
		else
		{
			if ( isDefined( bind_to.onbeginuse ) )
			{
				self.stub [[ bind_to.onbeginuse ]]( player );
			}
			result = self buildable_use_hold_think( player, bind_to );
			team = player.pers[ "team" ];
			if ( result )
			{
				if ( isDefined( self.stub.bound_to_buildable ) && self.stub.bound_to_buildable != bind_to )
				{
					result = 0;
				}
				if ( isDefined( bind_to.bound_to_buildable ) && self.stub != bind_to.bound_to_buildable )
				{
					result = 0;
				}
			}
			if ( isDefined( bind_to.onenduse ) )
			{
				self.stub [[ bind_to.onenduse ]]( team, player, result );
			}
			while ( !result )
			{
				continue;
			}
			if ( !isDefined( self.stub.bound_to_buildable ) && isDefined( bind_to ) )
			{
				if ( bind_to != self.stub )
				{
					swap_buildable_fields( self.stub, bind_to );
				}
				self.stub.bound_to_buildable = self.stub;
			}
			if ( isDefined( self.stub.onuse ) )
			{
				self.stub [[ self.stub.onuse ]]( player );
			}
			if ( isDefined( player player_get_buildable_piece( slot ) ) )
			{
				prompt = player player_build( self.stub.buildablezone );
				player_built = player;
				self.stub.hint_string = prompt;
				self sethintstring( self.stub.hint_string );
			}
		}
	}
	switch( self.stub.persistent )
	{
		case 1:
			self bptrigger_think_persistent( player_built );
			break;
		case 0:
			self bptrigger_think_one_time( player_built );
			break;
		case 3:
			self bptrigger_think_unbuild( player_built );
			break;
		case 2:
			self bptrigger_think_one_use_and_fly( player_built );
			break;
		case 4:
			self [[ self.stub.custom_completion_callback ]]( player_built );
			break;
	}
}
