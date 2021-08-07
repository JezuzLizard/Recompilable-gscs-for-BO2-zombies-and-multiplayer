#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init_sidequests()
{
	level._sidequest_icons_base_x = -225;
	level._zombie_sidequests = [];
/#
	level thread sidequest_debug();
#/
}

sidequest_debug()
{
/#
	if ( getDvar( #"A7AC338D" ) != "1" )
	{
		return;
	}
	while ( 1 )
	{
		wait 1;
#/
	}
}

damager_trigger_thread( dam_types, trigger_func )
{
	while ( 1 )
	{
		self waittill( "damage", amount, attacker, dir, point, type );
		self.dam_amount = amount;
		self.attacker = attacker;
		self.dam_dir = dir;
		self.dam_point = point;
		self.dam_type = type;
		i = 0;
		while ( i < dam_types.size )
		{
			if ( type == dam_types[ i ] )
			{
				break;
			}
			else
			{
				i++;
			}
		}
	}
	if ( isDefined( trigger_func ) )
	{
		self [[ trigger_func ]]();
	}
	self notify( "triggered" );
}

damage_trigger_thread()
{
	self endon( "death" );
	while ( 1 )
	{
		self waittill( "damage" );
		self.owner_ent notify( "triggered" );
	}
}

sidequest_uses_teleportation( name )
{
	level._zombie_sidequests[ name ].uses_teleportation = 1;
}

declare_sidequest_icon( sidequest_name, icon_name, shader_name )
{
	sidequest = level._zombie_sidequests[ sidequest_name ];
	sidequest.icons[ icon_name ] = shader_name;
}

create_icon( shader_name, x )
{
	icon = create_simple_hud( self );
	icon.foreground = 1;
	icon.sort = 2;
	icon.hidewheninmenu = 0;
	icon.alignx = "center";
	icon.aligny = "bottom";
	icon.horzalign = "user_right";
	icon.vertalign = "user_bottom";
	icon.x = x;
	icon.y = 0;
	icon.alpha = 1;
	icon setshader( shader_name, 32, 32 );
	return icon;
}

add_sidequest_icon( sidequest_name, icon_name )
{
	if ( !isDefined( self.sidequest_icons ) )
	{
		self.sidequest_icons = [];
	}
	if ( isDefined( self.sidequest_icons[ icon_name ] ) )
	{
		return;
	}
	sq = level._zombie_sidequests[ sidequest_name ];
	base_x = level._sidequest_icons_base_x;
	if ( isDefined( level._zombiemode_sidequest_icon_offset ) )
	{
		base_x += level._zombiemode_sidequest_icon_offset;
	}
	self.sidequest_icons[ icon_name ] = self create_icon( sq.icons[ icon_name ], base_x + ( self.sidequest_icons.size * 34 ) );
}

remove_sidequest_icon( sidequest_name, icon_name )
{
	if ( !isDefined( self.sidequest_icons ) )
	{
		return;
	}
	if ( !isDefined( self.sidequest_icons[ icon_name ] ) )
	{
		return;
	}
	icon = self.sidequest_icons[ icon_name ];
	new_array = [];
	keys = getarraykeys( self.sidequest_icons );
	i = 0;
	while ( i < keys.size )
	{
		if ( keys[ i ] != icon_name )
		{
			new_array[ keys[ i ] ] = self.sidequest_icons[ keys[ i ] ];
		}
		i++;
	}
	self.sidequest_icons = new_array;
	icon destroy();
	keys = getarraykeys( self.sidequest_icons );
	base_x = level._sidequest_icons_base_x;
	if ( isDefined( level._zombiemode_sidequest_icon_offset ) )
	{
		base_x += level._zombiemode_sidequest_icon_offset;
	}
	i = 0;
	while ( i < keys.size )
	{
		self.sidequest_icons[ keys[ i ] ].x = base_x + ( i * 34 );
		i++;
	}
}

declare_sidequest( name, init_func, logic_func, complete_func, generic_stage_start_func, generic_stage_end_func )
{
	if ( !isDefined( level._zombie_sidequests ) )
	{
		init_sidequests();
	}
/#
	if ( isDefined( level._zombie_sidequests[ name ] ) )
	{
		println( "*** ERROR: Attempt to re-declare sidequest with name " + name );
		return;
#/
	}
	sq = spawnstruct();
	sq.name = name;
	sq.stages = [];
	sq.last_completed_stage = -1;
	sq.active_stage = -1;
	sq.sidequest_complete = 0;
	sq.init_func = init_func;
	sq.logic_func = logic_func;
	sq.complete_func = complete_func;
	sq.generic_stage_start_func = generic_stage_start_func;
	sq.generic_stage_end_func = generic_stage_end_func;
	sq.assets = [];
	sq.uses_teleportation = 0;
	sq.active_assets = [];
	sq.icons = [];
	sq.num_reps = 0;
	level._zombie_sidequests[ name ] = sq;
}

declare_sidequest_stage( sidequest_name, stage_name, init_func, logic_func, exit_func )
{
/#
	if ( !isDefined( level._zombie_sidequests ) )
	{
		println( "*** ERROR:  Attempt to declare a side quest stage before sidequests declared." );
		return;
	}
	if ( !isDefined( level._zombie_sidequests[ sidequest_name ] ) )
	{
		println( "*** ERROR:  Attempt to add stage " + stage_name + " to side quest " + sidequest_name + " but no such side quest exists." );
		return;
	}
	if ( isDefined( level._zombie_sidequests[ sidequest_name ].stages[ stage_name ] ) )
	{
		println( "*** ERROR: Sidequest " + sidequest_name + " already has a stage called " + stage_name );
		return;
#/
	}
	stage = spawnstruct();
	stage.name = stage_name;
	stage.stage_number = level._zombie_sidequests[ sidequest_name ].stages.size;
	stage.assets = [];
	stage.active_assets = [];
	stage.logic_func = logic_func;
	stage.init_func = init_func;
	stage.exit_func = exit_func;
	stage.completed = 0;
	stage.time_limit = 0;
	level._zombie_sidequests[ sidequest_name ].stages[ stage_name ] = stage;
}

set_stage_time_limit( sidequest_name, stage_name, time_limit, timer_func )
{
/#
	if ( !isDefined( level._zombie_sidequests ) )
	{
		println( "*** ERROR:  Attempt to set a side quest stage time limit before sidequests declared." );
		return;
	}
	if ( !isDefined( level._zombie_sidequests[ sidequest_name ] ) )
	{
		println( "*** ERROR:  Attempt to add timelimit to stage " + stage_name + " in side quest " + sidequest_name + " but no such side quest exists." );
		return;
	}
	if ( !isDefined( level._zombie_sidequests[ sidequest_name ].stages[ stage_name ] ) )
	{
		println( "*** ERROR: Attempt to add timelimit to stage " + stage_name + " in Sidequest " + sidequest_name + " but stage does not exist." );
		return;
#/
	}
	level._zombie_sidequests[ sidequest_name ].stages[ stage_name ].time_limit = time_limit;
	level._zombie_sidequests[ sidequest_name ].stages[ stage_name ].time_limit_func = timer_func;
}

declare_stage_asset_from_struct( sidequest_name, stage_name, target_name, thread_func, trigger_thread_func )
{
	structs = getstructarray( target_name, "targetname" );
/#
	if ( !isDefined( level._zombie_sidequests ) )
	{
		println( "*** ERROR:  Attempt to declare a side quest asset " + target_name + " before sidequests declared." );
		return;
	}
	if ( !isDefined( level._zombie_sidequests[ sidequest_name ] ) )
	{
		println( "*** ERROR:  Attempt to add asset " + target_name + " to side quest " + sidequest_name + " but no such side quest exists." );
		return;
	}
	if ( !isDefined( level._zombie_sidequests[ sidequest_name ].stages[ stage_name ] ) )
	{
		println( "*** ERROR:  Attempt to add asset " + target_name + " to side quest " + sidequest_name + " : " + stage_name + " but no such stage exists." );
		return;
	}
	if ( !structs.size )
	{
		println( "*** ERROR: No Structs with " + target_name + " not found." );
		return;
#/
	}
	i = 0;
	while ( i < structs.size )
	{
		asset = spawnstruct();
		asset.type = "struct";
		asset.struct = structs[ i ];
		asset.thread_func = thread_func;
		asset.trigger_thread_func = trigger_thread_func;
		level._zombie_sidequests[ sidequest_name ].stages[ stage_name ].assets[ level._zombie_sidequests[ sidequest_name ].stages[ stage_name ].assets.size ] = asset;
		i++;
	}
}

declare_stage_title( sidequest_name, stage_name, title )
{
/#
	if ( !isDefined( level._zombie_sidequests ) )
	{
		println( "*** ERROR:  Attempt to declare a stage title " + title + " before sidequests declared." );
		return;
	}
	if ( !isDefined( level._zombie_sidequests[ sidequest_name ] ) )
	{
		println( "*** ERROR:  Attempt to declare a stage title " + title + " to side quest " + sidequest_name + " but no such side quest exists." );
		return;
	}
	if ( !isDefined( level._zombie_sidequests[ sidequest_name ].stages[ stage_name ] ) )
	{
		println( "*** ERROR:  Attempt to declare stage title " + title + " to side quest " + sidequest_name + " : " + stage_name + " but no such stage exists." );
		return;
#/
	}
	level._zombie_sidequests[ sidequest_name ].stages[ stage_name ].title = title;
}

declare_stage_asset( sidequest_name, stage_name, target_name, thread_func, trigger_thread_func )
{
	ents = getentarray( target_name, "targetname" );
/#
	if ( !isDefined( level._zombie_sidequests ) )
	{
		println( "*** ERROR:  Attempt to declare a side quest asset " + target_name + " before sidequests declared." );
		return;
	}
	if ( !isDefined( level._zombie_sidequests[ sidequest_name ] ) )
	{
		println( "*** ERROR:  Attempt to add asset " + target_name + " to side quest " + sidequest_name + " but no such side quest exists." );
		return;
	}
	if ( !isDefined( level._zombie_sidequests[ sidequest_name ].stages[ stage_name ] ) )
	{
		println( "*** ERROR:  Attempt to add asset " + target_name + " to side quest " + sidequest_name + " : " + stage_name + " but no such stage exists." );
		return;
	}
	if ( !ents.size )
	{
		println( "*** ERROR: No Ents with " + target_name + " not found." );
		return;
#/
	}
	i = 0;
	while ( i < ents.size )
	{
		asset = spawnstruct();
		asset.type = "entity";
		asset.ent = ents[ i ];
		asset.thread_func = thread_func;
		asset.trigger_thread_func = trigger_thread_func;
		level._zombie_sidequests[ sidequest_name ].stages[ stage_name ].assets[ level._zombie_sidequests[ sidequest_name ].stages[ stage_name ].assets.size ] = asset;
		i++;
	}
}

declare_sidequest_asset( sidequest_name, target_name, thread_func, trigger_thread_func )
{
	ents = getentarray( target_name, "targetname" );
/#
	if ( !isDefined( level._zombie_sidequests ) )
	{
		println( "*** ERROR:  Attempt to declare a side quest asset " + target_name + " before sidequests declared." );
		return;
	}
	if ( !isDefined( level._zombie_sidequests[ sidequest_name ] ) )
	{
		println( "*** ERROR:  Attempt to add asset " + target_name + " to side quest " + sidequest_name + " but no such side quest exists." );
		return;
	}
	if ( !ents.size )
	{
		println( "*** ERROR: No Ents with " + target_name + " not found." );
		return;
#/
	}
	i = 0;
	while ( i < ents.size )
	{
		asset = spawnstruct();
		asset.type = "entity";
		asset.ent = ents[ i ];
		asset.thread_func = thread_func;
		asset.trigger_thread_func = trigger_thread_func;
		asset.ent.thread_func = thread_func;
		asset.ent.trigger_thread_func = trigger_thread_func;
		level._zombie_sidequests[ sidequest_name ].assets[ level._zombie_sidequests[ sidequest_name ].assets.size ] = asset;
		i++;
	}
}

declare_sidequest_asset_from_struct( sidequest_name, target_name, thread_func, trigger_thread_func )
{
	structs = getstructarray( target_name, "targetname" );
/#
	if ( !isDefined( level._zombie_sidequests ) )
	{
		println( "*** ERROR:  Attempt to declare a side quest asset " + target_name + " before sidequests declared." );
		return;
	}
	if ( !isDefined( level._zombie_sidequests[ sidequest_name ] ) )
	{
		println( "*** ERROR:  Attempt to add asset " + target_name + " to side quest " + sidequest_name + " but no such side quest exists." );
		return;
	}
	if ( !structs.size )
	{
		println( "*** ERROR: No Structs with " + target_name + " not found." );
		return;
#/
	}
	i = 0;
	while ( i < structs.size )
	{
		asset = spawnstruct();
		asset.type = "struct";
		asset.struct = structs[ i ];
		asset.thread_func = thread_func;
		asset.trigger_thread_func = trigger_thread_func;
		level._zombie_sidequests[ sidequest_name ].assets[ level._zombie_sidequests[ sidequest_name ].assets.size ] = asset;
		i++;
	}
}

build_asset_from_struct( asset, parent_struct )
{
	ent = spawn( "script_model", asset.origin );
	if ( isDefined( asset.model ) )
	{
		ent setmodel( asset.model );
	}
	if ( isDefined( asset.angles ) )
	{
		ent.angles = asset.angles;
	}
	ent.script_noteworthy = asset.script_noteworthy;
	ent.type = "struct";
	ent.radius = asset.radius;
	ent.thread_func = parent_struct.thread_func;
	ent.trigger_thread_func = parent_struct.trigger_thread_func;
	ent.script_vector = parent_struct.script_vector;
	asset.trigger_thread_func = parent_struct.trigger_thread_func;
	asset.script_vector = parent_struct.script_vector;
	ent.target = asset.target;
	ent.script_float = asset.script_float;
	ent.script_int = asset.script_int;
	ent.script_trigger_spawnflags = asset.script_trigger_spawnflags;
	ent.targetname = asset.targetname;
	return ent;
}

delete_stage_assets()
{
	i = 0;
	while ( i < self.active_assets.size )
	{
		asset = self.active_assets[ i ];
		switch( asset.type )
		{
			case "struct":
				if ( isDefined( asset.trigger ) )
				{
/#
					println( "Deleting trigger from struct type asset." );
#/
					asset.trigger delete();
					asset.trigger = undefined;
				}
				asset delete();
				break;
			i++;
			continue;
			case "entity":
				if ( isDefined( asset.trigger ) )
				{
/#
					println( "Deleting trigger from ent type asset." );
#/
					asset.trigger delete();
					asset.trigger = undefined;
				}
				break;
			i++;
			continue;
		}
		i++;
	}
	remaining_assets = [];
	i = 0;
	while ( i < self.active_assets.size )
	{
		if ( isDefined( self.active_assets[ i ] ) )
		{
			remaining_assets[ remaining_assets.size ] = self.active_assets[ i ];
		}
		i++;
	}
	self.active_assets = remaining_assets;
}

build_assets()
{
	i = 0;
	while ( i < self.assets.size )
	{
		asset = undefined;
		switch( self.assets[ i ].type )
		{
			case "struct":
				asset = self.assets[ i ].struct;
				self.active_assets[ self.active_assets.size ] = build_asset_from_struct( asset, self.assets[ i ] );
				break;
			case "entity":
				j = 0;
				while ( j < self.active_assets.size )
				{
					if ( self.active_assets[ j ] == self.assets[ i ].ent )
					{
						asset = self.active_assets[ j ];
						break;
					}
					else
					{
						j++;
					}
				}
				asset = self.assets[ i ].ent;
				asset.type = "entity";
				self.active_assets[ self.active_assets.size ] = asset;
				break;
			default:
/#
				println( "*** ERROR: Don't know how to build asset of type " + self.assets.type );
#/
				break;
		}
		if ( isDefined( asset.script_noteworthy ) && self.assets[ i ].type == "entity" || !isDefined( asset.trigger ) && isDefined( asset.script_noteworthy ) )
		{
			trigger_radius = 15;
			trigger_height = 72;
			if ( isDefined( asset.radius ) )
			{
				trigger_radius = asset.radius;
			}
			if ( isDefined( asset.height ) )
			{
				trigger_height = asset.height;
			}
			trigger_spawnflags = 0;
			if ( isDefined( asset.script_trigger_spawnflags ) )
			{
				trigger_spawnflags = asset.script_trigger_spawnflags;
			}
			trigger_offset = ( 0, 1, 0 );
			if ( isDefined( asset.script_vector ) )
			{
				trigger_offset = asset.script_vector;
			}
			switch( asset.script_noteworthy )
			{
				case "trigger_radius_use":
					use_trigger = spawn( "trigger_radius_use", asset.origin + trigger_offset, trigger_spawnflags, trigger_radius, trigger_height );
					use_trigger setcursorhint( "HINT_NOICON" );
					if ( isDefined( asset.radius ) )
					{
						use_trigger.radius = asset.radius;
					}
					use_trigger.owner_ent = self.active_assets[ self.active_assets.size - 1 ];
					if ( isDefined( asset.trigger_thread_func ) )
					{
						use_trigger thread [[ asset.trigger_thread_func ]]();
					}
					else
					{
						use_trigger thread use_trigger_thread();
					}
					self.active_assets[ self.active_assets.size - 1 ].trigger = use_trigger;
					break;
				break;
				case "trigger_radius_damage":
					damage_trigger = spawn( "trigger_damage", asset.origin + trigger_offset, trigger_spawnflags, trigger_radius, trigger_height );
					if ( isDefined( asset.radius ) )
					{
						damage_trigger.radius = asset.radius;
					}
					damage_trigger.owner_ent = self.active_assets[ self.active_assets.size - 1 ];
					if ( isDefined( asset.trigger_thread_func ) )
					{
						damage_trigger thread [[ asset.trigger_thread_func ]]();
					}
					else
					{
						damage_trigger thread damage_trigger_thread();
					}
					self.active_assets[ self.active_assets.size - 1 ].trigger = damage_trigger;
					break;
				break;
				case "trigger_radius":
					radius_trigger = spawn( "trigger_radius", asset.origin + trigger_offset, trigger_spawnflags, trigger_radius, trigger_height );
					if ( isDefined( asset.radius ) )
					{
						radius_trigger.radius = asset.radius;
					}
					radius_trigger.owner_ent = self.active_assets[ self.active_assets.size - 1 ];
					if ( isDefined( asset.trigger_thread_func ) )
					{
						radius_trigger thread [[ asset.trigger_thread_func ]]();
					}
					else
					{
						radius_trigger thread radius_trigger_thread();
					}
					self.active_assets[ self.active_assets.size - 1 ].trigger = radius_trigger;
					break;
				break;
			}
		}
		if ( isDefined( self.assets[ i ].thread_func ) && !isDefined( self.active_assets[ self.active_assets.size - 1 ].dont_rethread ) )
		{
			self.active_assets[ self.active_assets.size - 1 ] thread [[ self.assets[ i ].thread_func ]]();
		}
		if ( ( i % 2 ) == 0 )
		{
			wait_network_frame();
		}
		i++;
	}
}

radius_trigger_thread()
{
	self endon( "death" );
	while ( 1 )
	{
		self waittill( "trigger", player );
		while ( !isplayer( player ) )
		{
			continue;
		}
		self.owner_ent notify( "triggered" );
		while ( player istouching( self ) )
		{
			wait 0,05;
		}
		self.owner_ent notify( "untriggered" );
	}
}

thread_on_assets( target_name, thread_func )
{
	i = 0;
	while ( i < self.active_assets.size )
	{
		if ( self.active_assets[ i ].targetname == target_name )
		{
			self.active_assets[ i ] thread [[ thread_func ]]();
		}
		i++;
	}
}

stage_logic_func_wrapper( sidequest, stage )
{
	if ( isDefined( stage.logic_func ) )
	{
		level endon( ( sidequest.name + "_" ) + stage.name + "_over" );
		stage [[ stage.logic_func ]]();
	}
}

sidequest_start( sidequest_name )
{
/#
	if ( !isDefined( level._zombie_sidequests ) )
	{
		println( "*** ERROR:  Attempt start a side quest asset " + sidequest_name + " before sidequests declared." );
		return;
	}
	if ( !isDefined( level._zombie_sidequests[ sidequest_name ] ) )
	{
		println( "*** ERROR:  Attempt to start " + sidequest_name + " but no such side quest exists." );
		return;
#/
	}
	sidequest = level._zombie_sidequests[ sidequest_name ];
	sidequest build_assets();
	if ( isDefined( sidequest.init_func ) )
	{
		sidequest [[ sidequest.init_func ]]();
	}
	if ( isDefined( sidequest.logic_func ) )
	{
		sidequest thread [[ sidequest.logic_func ]]();
	}
}

stage_start( sidequest, stage )
{
	if ( isstring( sidequest ) )
	{
		sidequest = level._zombie_sidequests[ sidequest ];
	}
	if ( isstring( stage ) )
	{
		stage = sidequest.stages[ stage ];
	}
	stage build_assets();
	sidequest.active_stage = stage.stage_number;
	level notify( ( sidequest.name + "_" ) + stage.name + "_started" );
	stage.completed = 0;
	if ( isDefined( sidequest.generic_stage_start_func ) )
	{
		stage [[ sidequest.generic_stage_start_func ]]();
	}
	if ( isDefined( stage.init_func ) )
	{
		stage [[ stage.init_func ]]();
	}
	level._last_stage_started = stage.name;
	level thread stage_logic_func_wrapper( sidequest, stage );
	if ( stage.time_limit > 0 )
	{
		stage thread time_limited_stage( sidequest );
	}
	if ( isDefined( stage.title ) )
	{
		stage thread display_stage_title( sidequest.uses_teleportation );
	}
}

display_stage_title( wait_for_teleport_done_notify )
{
	if ( wait_for_teleport_done_notify )
	{
		level waittill( "teleport_done" );
		wait 2;
	}
	stage_text = newhudelem();
	stage_text.location = 0;
	stage_text.alignx = "center";
	stage_text.aligny = "middle";
	stage_text.foreground = 1;
	stage_text.fontscale = 1,6;
	stage_text.sort = 20;
	stage_text.x = 320;
	stage_text.y = 300;
	stage_text.og_scale = 1;
	stage_text.color = vectorScale( ( 0, 1, 0 ), 128 );
	stage_text.alpha = 0;
	stage_text.fontstyle3d = "shadowedmore";
	stage_text settext( self.title );
	stage_text fadeovertime( 0,5 );
	stage_text.alpha = 1;
	wait 5;
	stage_text fadeovertime( 1 );
	stage_text.alpha = 0;
	wait 1;
	stage_text destroy();
}

time_limited_stage( sidequest )
{
/#
	println( "*** Starting timer for sidequest " + sidequest.name + " stage " + self.name + " : " + self.time_limit + " seconds." );
#/
	level endon( ( sidequest.name + "_" ) + self.name + "_over" );
	level endon( "suspend_timer" );
	level endon( "end_game" );
	time_limit = undefined;
	if ( isDefined( self.time_limit_func ) )
	{
		time_limit = [[ self.time_limit_func ]]() * 0,25;
	}
	else
	{
		time_limit = self.time_limit * 0,25;
	}
	wait time_limit;
	level notify( "timed_stage_75_percent" );
	wait time_limit;
	level notify( "timed_stage_50_percent" );
	wait time_limit;
	level notify( "timed_stage_25_percent" );
	wait ( time_limit - 10 );
	level notify( "timed_stage_10_seconds_to_go" );
	wait 10;
	stage_failed( sidequest, self );
}

sidequest_println( str )
{
/#
	if ( getDvar( #"A7AC338D" ) != "1" )
	{
		return;
	}
	println( str );
#/
}

precache_sidequest_assets()
{
	sidequest_names = getarraykeys( level._zombie_sidequests );
	i = 0;
	while ( i < sidequest_names.size )
	{
		sq = level._zombie_sidequests[ sidequest_names[ i ] ];
		icon_keys = getarraykeys( sq.icons );
		j = 0;
		while ( j < icon_keys.size )
		{
			precacheshader( sq.icons[ icon_keys[ j ] ] );
			j++;
		}
		stage_names = getarraykeys( sq.stages );
		j = 0;
		while ( j < stage_names.size )
		{
			stage = sq.stages[ stage_names[ j ] ];
			k = 0;
			while ( k < stage.assets.size )
			{
				asset = stage.assets[ k ];
				if ( isDefined( asset.type ) && asset.type == "struct" )
				{
					if ( isDefined( asset.model ) )
					{
						precachemodel( asset.model );
					}
				}
				k++;
			}
			j++;
		}
		i++;
	}
}

sidequest_complete( sidequest_name )
{
/#
	if ( !isDefined( level._zombie_sidequests ) )
	{
		println( "*** ERROR:  Attempt to call sidequest_complete for sidequest " + sidequest_name + " before sidequests declared." );
		return;
	}
	if ( !isDefined( level._zombie_sidequests[ sidequest_name ] ) )
	{
		println( "*** ERROR:  Attempt to call sidequest_complete for sidequest " + sidequest_name + " but no such side quest exists." );
		return;
#/
	}
	return level._zombie_sidequests[ sidequest_name ].sidequest_complete;
}

stage_completed( sidequest_name, stage_name )
{
/#
	if ( !isDefined( level._zombie_sidequests ) )
	{
		println( "*** ERROR:  Attempt to call stage_complete for sidequest " + sidequest_name + " before sidequests declared." );
		return;
	}
	if ( !isDefined( level._zombie_sidequests[ sidequest_name ] ) )
	{
		println( "*** ERROR:  Attempt to call stage_complete for sidequest " + sidequest_name + " but no such side quest exists." );
		return;
	}
	if ( !isDefined( level._zombie_sidequests[ sidequest_name ].stages[ stage_name ] ) )
	{
		println( "*** ERROR:  Attempt to call stage_complete in sq " + sidequest_name + " : " + stage_name + " but no such stage exists." );
		return;
	}
	println( "*** stage completed called." );
#/
	sidequest = level._zombie_sidequests[ sidequest_name ];
	stage = sidequest.stages[ stage_name ];
	level thread stage_completed_internal( sidequest, stage );
}

stage_completed_internal( sidequest, stage )
{
	level notify( ( sidequest.name + "_" ) + stage.name + "_over" );
	level notify( ( sidequest.name + "_" ) + stage.name + "_completed" );
	if ( isDefined( sidequest.generic_stage_end_func ) )
	{
/#
		println( "Calling generic end func." );
#/
		stage [[ sidequest.generic_stage_end_func ]]();
	}
	if ( isDefined( stage.exit_func ) )
	{
/#
		println( "Calling stage end func." );
#/
		stage [[ stage.exit_func ]]( 1 );
	}
	stage.completed = 1;
	sidequest.last_completed_stage = sidequest.active_stage;
	sidequest.active_stage = -1;
	stage delete_stage_assets();
	all_complete = 1;
	stage_names = getarraykeys( sidequest.stages );
	i = 0;
	while ( i < stage_names.size )
	{
		if ( sidequest.stages[ stage_names[ i ] ].completed == 0 )
		{
			all_complete = 0;
			break;
		}
		else
		{
			i++;
		}
	}
	if ( all_complete == 1 )
	{
		if ( isDefined( sidequest.complete_func ) )
		{
			sidequest thread [[ sidequest.complete_func ]]();
		}
		level notify( "sidequest_" + sidequest.name + "_complete" );
		sidequest.sidequest_completed = 1;
	}
}

stage_failed_internal( sidequest, stage )
{
	level notify( ( sidequest.name + "_" ) + stage.name + "_over" );
	level notify( ( sidequest.name + "_" ) + stage.name + "_failed" );
	if ( isDefined( sidequest.generic_stage_end_func ) )
	{
		stage [[ sidequest.generic_stage_end_func ]]();
	}
	if ( isDefined( stage.exit_func ) )
	{
		stage [[ stage.exit_func ]]( 0 );
	}
	sidequest.active_stage = -1;
	stage delete_stage_assets();
}

stage_failed( sidequest, stage )
{
/#
	println( "*** Stage failed called." );
#/
	if ( isstring( sidequest ) )
	{
		sidequest = level._zombie_sidequests[ sidequest ];
	}
	if ( isstring( stage ) )
	{
		stage = sidequest.stages[ stage ];
	}
	level thread stage_failed_internal( sidequest, stage );
}

get_sidequest_stage( sidequest, stage_number )
{
	stage = undefined;
	stage_names = getarraykeys( sidequest.stages );
	i = 0;
	while ( i < stage_names.size )
	{
		if ( sidequest.stages[ stage_names[ i ] ].stage_number == stage_number )
		{
			stage = sidequest.stages[ stage_names[ i ] ];
			break;
		}
		else
		{
			i++;
		}
	}
	return stage;
}

get_damage_trigger( radius, origin, damage_types )
{
	trig = spawn( "trigger_damage", origin, 0, radius, 72 );
	trig thread dam_trigger_thread( damage_types );
	return trig;
}

dam_trigger_thread( damage_types )
{
	self endon( "death" );
	damage_type = "NONE";
	while ( 1 )
	{
		self waittill( "damage", amount, attacker, dir, point, mod );
		i = 0;
		while ( i < damage_types.size )
		{
			if ( mod == damage_types[ i ] )
			{
				self notify( "triggered" );
			}
			i++;
		}
	}
}

use_trigger_thread()
{
	self endon( "death" );
	while ( 1 )
	{
		self waittill( "trigger", player );
		self.owner_ent notify( "triggered" );
		wait 0,1;
	}
}

sidequest_stage_active( sidequest_name, stage_name )
{
	sidequest = level._zombie_sidequests[ sidequest_name ];
	stage = sidequest.stages[ stage_name ];
	if ( sidequest.active_stage == stage.stage_number )
	{
		return 1;
	}
	else
	{
		return 0;
	}
}

sidequest_start_next_stage( sidequest_name )
{
/#
	if ( !isDefined( level._zombie_sidequests ) )
	{
		println( "*** ERROR:  Attempt start next stage in side quest asset " + sidequest_name + " before sidequests declared." );
		return;
	}
	if ( !isDefined( level._zombie_sidequests[ sidequest_name ] ) )
	{
		println( "*** ERROR:  Attempt to start next sidequest in sidequest " + sidequest_name + " but no such side quest exists." );
		return;
#/
	}
	sidequest = level._zombie_sidequests[ sidequest_name ];
	if ( sidequest.sidequest_complete == 1 )
	{
		return;
	}
	last_completed = sidequest.last_completed_stage;
	if ( last_completed == -1 )
	{
		last_completed = 0;
	}
	else
	{
		last_completed++;
	}
	stage = get_sidequest_stage( sidequest, last_completed );
	if ( !isDefined( stage ) )
	{
/#
		println( "*** ERROR:  Sidequest " + sidequest_name + " has no stage number " + last_completed );
#/
		return;
	}
	stage_start( sidequest, stage );
	return stage;
}

main()
{
}

is_facing( facee )
{
	orientation = self getplayerangles();
	forwardvec = anglesToForward( orientation );
	forwardvec2d = ( forwardvec[ 0 ], forwardvec[ 1 ], 0 );
	unitforwardvec2d = vectornormalize( forwardvec2d );
	tofaceevec = facee.origin - self.origin;
	tofaceevec2d = ( tofaceevec[ 0 ], tofaceevec[ 1 ], 0 );
	unittofaceevec2d = vectornormalize( tofaceevec2d );
	dotproduct = vectordot( unitforwardvec2d, unittofaceevec2d );
	return dotproduct > 0,9;
}

fake_use( notify_string, qualifier_func )
{
	waittillframeend;
	while ( 1 )
	{
		if ( !isDefined( self ) )
		{
			return;
		}
/#
		print3d( self.origin, "+", vectorScale( ( 0, 1, 0 ), 255 ), 1 );
#/
		players = get_players();
		i = 0;
		while ( i < players.size )
		{
			qualifier_passed = 1;
			if ( isDefined( qualifier_func ) )
			{
				qualifier_passed = players[ i ] [[ qualifier_func ]]();
			}
			if ( qualifier_passed && distancesquared( self.origin, players[ i ].origin ) < 4096 )
			{
				if ( players[ i ] is_facing( self ) )
				{
					if ( players[ i ] usebuttonpressed() )
					{
						self notify( notify_string );
						return;
					}
				}
			}
			i++;
		}
		wait 0,1;
	}
}
