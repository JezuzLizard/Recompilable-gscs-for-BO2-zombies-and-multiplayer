#include maps/mp/gametypes_zm/_spawnlogic;
#include maps/mp/animscripts/traverse/shared;
#include maps/mp/animscripts/utility;
#include maps/mp/zombies/_load;
#include maps/mp/_createfx;
#include maps/mp/_music;
#include maps/mp/_busing;
#include maps/mp/_script_gen;
#include maps/mp/_utility;
#include common_scripts/utility;

main( bscriptgened, bcsvgened, bsgenabled )
{
	if ( !isDefined( level.script_gen_dump_reasons ) )
	{
		level.script_gen_dump_reasons = [];
	}
	if ( !isDefined( bsgenabled ) )
	{
		level.script_gen_dump_reasons[ level.script_gen_dump_reasons.size ] = "First run";
	}
	if ( !isDefined( bcsvgened ) )
	{
		bcsvgened = 0;
	}
	level.bcsvgened = bcsvgened;
	if ( !isDefined( bscriptgened ) )
	{
		bscriptgened = 0;
	}
	else
	{
		bscriptgened = 1;
	}
	level.bscriptgened = bscriptgened;
	level._loadstarted = 1;
	struct_class_init();
	level.clientscripts = getDvar( "cg_usingClientScripts" ) != "";
	level._client_exploders = [];
	level._client_exploder_ids = [];
	if ( !isDefined( level.flag ) )
	{
		level.flag = [];
		level.flags_lock = [];
	}
	if ( !isDefined( level.timeofday ) )
	{
		level.timeofday = "day";
	}
	flag_init( "scriptgen_done" );
	level.script_gen_dump_reasons = [];
	if ( !isDefined( level.script_gen_dump ) )
	{
		level.script_gen_dump = [];
		level.script_gen_dump_reasons[ 0 ] = "First run";
	}
	if ( !isDefined( level.script_gen_dump2 ) )
	{
		level.script_gen_dump2 = [];
	}
	if ( isDefined( level.createfxent ) && isDefined( level.script ) )
	{
		script_gen_dump_addline( "maps\\mp\\createfx\\" + level.script + "_fx::main();", level.script + "_fx" );
	}
	while ( isDefined( level.script_gen_dump_preload ) )
	{
		i = 0;
		while ( i < level.script_gen_dump_preload.size )
		{
			script_gen_dump_addline( level.script_gen_dump_preload[ i ].string, level.script_gen_dump_preload[ i ].signature );
			i++;
		}
	}
	if ( getDvar( "scr_RequiredMapAspectratio" ) == "" )
	{
		setdvar( "scr_RequiredMapAspectratio", "1" );
	}
	setdvar( "r_waterFogTest", 0 );
	precacherumble( "reload_small" );
	precacherumble( "reload_medium" );
	precacherumble( "reload_large" );
	precacherumble( "reload_clipin" );
	precacherumble( "reload_clipout" );
	precacherumble( "reload_rechamber" );
	precacherumble( "pullout_small" );
	precacherumble( "buzz_high" );
	precacherumble( "riotshield_impact" );
	registerclientsys( "levelNotify" );
	level.aitriggerspawnflags = getaitriggerflags();
	level.vehicletriggerspawnflags = getvehicletriggerflags();
	level.physicstracemaskphysics = 1;
	level.physicstracemaskvehicle = 2;
	level.physicstracemaskwater = 4;
	level.createfx_enabled = getDvar( "createfx" ) != "";
	level thread start_intro_screen_zm();
	thread maps/mp/_interactive_objects::init();
	maps/mp/_audio::init();
	thread maps/mp/_busing::businit();
	thread maps/mp/_music::music_init();
	thread maps/mp/_fxanim::init();
	thread maps/mp/_serverfaceanim_mp::init();
	if ( level.createfx_enabled )
	{
		setinitialplayersconnected();
	}
	visionsetnight( "default_night" );
	setup_traversals();
	maps/mp/_art::main();
	setupexploders();
	parse_structs();
	thread footsteps();
/#
	level thread level_notify_listener();
	level thread client_notify_listener();
#/
	thread maps/mp/_createfx::fx_init();
	if ( level.createfx_enabled )
	{
		calculate_map_center();
		maps/mp/_createfx::createfx();
	}
	if ( getDvar( #"F7B30924" ) == "1" )
	{
		maps/mp/_global_fx::main();
		level waittill( "eternity" );
	}
	thread maps/mp/_global_fx::main();
	maps/mp/_demo::init();
	p = 0;
	while ( p < 6 )
	{
		switch( p )
		{
			case 0:
				triggertype = "trigger_multiple";
				break;
			case 1:
				triggertype = "trigger_once";
				break;
			case 2:
				triggertype = "trigger_use";
				break;
			case 3:
				triggertype = "trigger_radius";
				break;
			case 4:
				triggertype = "trigger_lookat";
				break;
			default:
/#
				assert( p == 5 );
#/
				triggertype = "trigger_damage";
				break;
		}
		triggers = getentarray( triggertype, "classname" );
		i = 0;
		while ( i < triggers.size )
		{
			if ( isDefined( triggers[ i ].script_prefab_exploder ) )
			{
				triggers[ i ].script_exploder = triggers[ i ].script_prefab_exploder;
			}
			if ( isDefined( triggers[ i ].script_exploder ) )
			{
				level thread maps/mp/zombies/_load::exploder_load( triggers[ i ] );
			}
			i++;
		}
		p++;
	}
}

level_notify_listener()
{
	while ( 1 )
	{
		val = getDvar( "level_notify" );
		if ( val != "" )
		{
			level notify( val );
			setdvar( "level_notify", "" );
		}
		wait 0,2;
	}
}

client_notify_listener()
{
	while ( 1 )
	{
		val = getDvar( "client_notify" );
		if ( val != "" )
		{
			clientnotify( val );
			setdvar( "client_notify", "" );
		}
		wait 0,2;
	}
}

footsteps()
{
	maps/mp/animscripts/utility::setfootstepeffect( "asphalt", loadfx( "bio/player/fx_footstep_dust" ) );
	maps/mp/animscripts/utility::setfootstepeffect( "brick", loadfx( "bio/player/fx_footstep_dust" ) );
	maps/mp/animscripts/utility::setfootstepeffect( "carpet", loadfx( "bio/player/fx_footstep_dust" ) );
	maps/mp/animscripts/utility::setfootstepeffect( "cloth", loadfx( "bio/player/fx_footstep_dust" ) );
	maps/mp/animscripts/utility::setfootstepeffect( "concrete", loadfx( "bio/player/fx_footstep_dust" ) );
	maps/mp/animscripts/utility::setfootstepeffect( "dirt", loadfx( "bio/player/fx_footstep_sand" ) );
	maps/mp/animscripts/utility::setfootstepeffect( "foliage", loadfx( "bio/player/fx_footstep_sand" ) );
	maps/mp/animscripts/utility::setfootstepeffect( "gravel", loadfx( "bio/player/fx_footstep_dust" ) );
	maps/mp/animscripts/utility::setfootstepeffect( "grass", loadfx( "bio/player/fx_footstep_dust" ) );
	maps/mp/animscripts/utility::setfootstepeffect( "metal", loadfx( "bio/player/fx_footstep_dust" ) );
	maps/mp/animscripts/utility::setfootstepeffect( "mud", loadfx( "bio/player/fx_footstep_mud" ) );
	maps/mp/animscripts/utility::setfootstepeffect( "paper", loadfx( "bio/player/fx_footstep_dust" ) );
	maps/mp/animscripts/utility::setfootstepeffect( "plaster", loadfx( "bio/player/fx_footstep_dust" ) );
	maps/mp/animscripts/utility::setfootstepeffect( "rock", loadfx( "bio/player/fx_footstep_dust" ) );
	maps/mp/animscripts/utility::setfootstepeffect( "sand", loadfx( "bio/player/fx_footstep_sand" ) );
	maps/mp/animscripts/utility::setfootstepeffect( "water", loadfx( "bio/player/fx_footstep_water" ) );
	maps/mp/animscripts/utility::setfootstepeffect( "wood", loadfx( "bio/player/fx_footstep_dust" ) );
}

parse_structs()
{
	i = 0;
	while ( i < level.struct.size )
	{
		if ( isDefined( level.struct[ i ].targetname ) )
		{
			if ( level.struct[ i ].targetname == "flak_fire_fx" )
			{
				level._effect[ "flak20_fire_fx" ] = loadfx( "weapon/tracer/fx_tracer_flak_single_noExp" );
				level._effect[ "flak38_fire_fx" ] = loadfx( "weapon/tracer/fx_tracer_quad_20mm_Flak38_noExp" );
				level._effect[ "flak_cloudflash_night" ] = loadfx( "weapon/flak/fx_flak_cloudflash_night" );
				level._effect[ "flak_burst_single" ] = loadfx( "weapon/flak/fx_flak_single_day_dist" );
			}
			if ( level.struct[ i ].targetname == "fake_fire_fx" )
			{
				level._effect[ "distant_muzzleflash" ] = loadfx( "weapon/muzzleflashes/heavy" );
			}
			if ( level.struct[ i ].targetname == "spotlight_fx" )
			{
				level._effect[ "spotlight_beam" ] = loadfx( "env/light/fx_ray_spotlight_md" );
			}
		}
		i++;
	}
}

exploder_load( trigger )
{
	level endon( "killexplodertridgers" + trigger.script_exploder );
	trigger waittill( "trigger" );
	if ( isDefined( trigger.script_chance ) && randomfloat( 1 ) > trigger.script_chance )
	{
		if ( isDefined( trigger.script_delay ) )
		{
			wait trigger.script_delay;
		}
		else
		{
			wait 4;
		}
		level thread exploder_load( trigger );
		return;
	}
	maps/mp/_utility::exploder( trigger.script_exploder );
	level notify( "killexplodertridgers" + trigger.script_exploder );
}

setupexploders()
{
	ents = getentarray( "script_brushmodel", "classname" );
	smodels = getentarray( "script_model", "classname" );
	i = 0;
	while ( i < smodels.size )
	{
		ents[ ents.size ] = smodels[ i ];
		i++;
	}
	i = 0;
	while ( i < ents.size )
	{
		if ( isDefined( ents[ i ].script_prefab_exploder ) )
		{
			ents[ i ].script_exploder = ents[ i ].script_prefab_exploder;
		}
		if ( isDefined( ents[ i ].script_exploder ) )
		{
			if ( ents[ i ].model == "fx" || !isDefined( ents[ i ].targetname ) && ents[ i ].targetname != "exploderchunk" )
			{
				ents[ i ] hide();
				i++;
				continue;
			}
			else
			{
				if ( isDefined( ents[ i ].targetname ) && ents[ i ].targetname == "exploder" )
				{
					ents[ i ] hide();
					ents[ i ] notsolid();
					i++;
					continue;
				}
				else
				{
					if ( isDefined( ents[ i ].targetname ) && ents[ i ].targetname == "exploderchunk" )
					{
						ents[ i ] hide();
						ents[ i ] notsolid();
					}
				}
			}
		}
		i++;
	}
	script_exploders = [];
	potentialexploders = getentarray( "script_brushmodel", "classname" );
	i = 0;
	while ( i < potentialexploders.size )
	{
		if ( isDefined( potentialexploders[ i ].script_prefab_exploder ) )
		{
			potentialexploders[ i ].script_exploder = potentialexploders[ i ].script_prefab_exploder;
		}
		if ( isDefined( potentialexploders[ i ].script_exploder ) )
		{
			script_exploders[ script_exploders.size ] = potentialexploders[ i ];
		}
		i++;
	}
	potentialexploders = getentarray( "script_model", "classname" );
	i = 0;
	while ( i < potentialexploders.size )
	{
		if ( isDefined( potentialexploders[ i ].script_prefab_exploder ) )
		{
			potentialexploders[ i ].script_exploder = potentialexploders[ i ].script_prefab_exploder;
		}
		if ( isDefined( potentialexploders[ i ].script_exploder ) )
		{
			script_exploders[ script_exploders.size ] = potentialexploders[ i ];
		}
		i++;
	}
	potentialexploders = getentarray( "item_health", "classname" );
	i = 0;
	while ( i < potentialexploders.size )
	{
		if ( isDefined( potentialexploders[ i ].script_prefab_exploder ) )
		{
			potentialexploders[ i ].script_exploder = potentialexploders[ i ].script_prefab_exploder;
		}
		if ( isDefined( potentialexploders[ i ].script_exploder ) )
		{
			script_exploders[ script_exploders.size ] = potentialexploders[ i ];
		}
		i++;
	}
	if ( !isDefined( level.createfxent ) )
	{
		level.createfxent = [];
	}
	acceptabletargetnames = [];
	acceptabletargetnames[ "exploderchunk visible" ] = 1;
	acceptabletargetnames[ "exploderchunk" ] = 1;
	acceptabletargetnames[ "exploder" ] = 1;
	i = 0;
	while ( i < script_exploders.size )
	{
		exploder = script_exploders[ i ];
		ent = createexploder( exploder.script_fxid );
		ent.v = [];
		ent.v[ "origin" ] = exploder.origin;
		ent.v[ "angles" ] = exploder.angles;
		ent.v[ "delay" ] = exploder.script_delay;
		ent.v[ "firefx" ] = exploder.script_firefx;
		ent.v[ "firefxdelay" ] = exploder.script_firefxdelay;
		ent.v[ "firefxsound" ] = exploder.script_firefxsound;
		ent.v[ "firefxtimeout" ] = exploder.script_firefxtimeout;
		ent.v[ "earthquake" ] = exploder.script_earthquake;
		ent.v[ "damage" ] = exploder.script_damage;
		ent.v[ "damage_radius" ] = exploder.script_radius;
		ent.v[ "soundalias" ] = exploder.script_soundalias;
		ent.v[ "repeat" ] = exploder.script_repeat;
		ent.v[ "delay_min" ] = exploder.script_delay_min;
		ent.v[ "delay_max" ] = exploder.script_delay_max;
		ent.v[ "target" ] = exploder.target;
		ent.v[ "ender" ] = exploder.script_ender;
		ent.v[ "type" ] = "exploder";
		if ( !isDefined( exploder.script_fxid ) )
		{
			ent.v[ "fxid" ] = "No FX";
		}
		else
		{
			ent.v[ "fxid" ] = exploder.script_fxid;
		}
		ent.v[ "exploder" ] = exploder.script_exploder;
/#
		assert( isDefined( exploder.script_exploder ), "Exploder at origin " + exploder.origin + " has no script_exploder" );
#/
		if ( !isDefined( ent.v[ "delay" ] ) )
		{
			ent.v[ "delay" ] = 0;
		}
		if ( isDefined( exploder.target ) )
		{
			org = getent( ent.v[ "target" ], "targetname" ).origin;
			ent.v[ "angles" ] = vectorToAngle( org - ent.v[ "origin" ] );
		}
		if ( exploder.classname == "script_brushmodel" || isDefined( exploder.model ) )
		{
			ent.model = exploder;
			ent.model.disconnect_paths = exploder.script_disconnectpaths;
		}
		if ( isDefined( exploder.targetname ) && isDefined( acceptabletargetnames[ exploder.targetname ] ) )
		{
			ent.v[ "exploder_type" ] = exploder.targetname;
		}
		else
		{
			ent.v[ "exploder_type" ] = "normal";
		}
		ent maps/mp/_createfx::post_entity_creation_function();
		i++;
	}
	level.createfxexploders = [];
	i = 0;
	while ( i < level.createfxent.size )
	{
		ent = level.createfxent[ i ];
		if ( ent.v[ "type" ] != "exploder" )
		{
			i++;
			continue;
		}
		else
		{
			ent.v[ "exploder_id" ] = getexploderid( ent );
			if ( !isDefined( level.createfxexploders[ ent.v[ "exploder" ] ] ) )
			{
				level.createfxexploders[ ent.v[ "exploder" ] ] = [];
			}
			level.createfxexploders[ ent.v[ "exploder" ] ][ level.createfxexploders[ ent.v[ "exploder" ] ].size ] = ent;
		}
		i++;
	}
}

setup_traversals()
{
	potential_traverse_nodes = getallnodes();
	i = 0;
	while ( i < potential_traverse_nodes.size )
	{
		node = potential_traverse_nodes[ i ];
		if ( node.type == "Begin" )
		{
			node maps/mp/animscripts/traverse/shared::init_traverse();
		}
		i++;
	}
}

calculate_map_center()
{
	if ( !isDefined( level.mapcenter ) )
	{
		level.nodesmins = ( 0, 0, 0 );
		level.nodesmaxs = ( 0, 0, 0 );
		level.mapcenter = maps/mp/gametypes_zm/_spawnlogic::findboxcenter( level.nodesmins, level.nodesmaxs );
/#
		println( "map center: ", level.mapcenter );
#/
		setmapcenter( level.mapcenter );
	}
}

start_intro_screen_zm()
{
	if ( level.createfx_enabled )
	{
		return;
	}
	if ( !isDefined( level.introscreen ) )
	{
		level.introscreen = newhudelem();
		level.introscreen.x = 0;
		level.introscreen.y = 0;
		level.introscreen.horzalign = "fullscreen";
		level.introscreen.vertalign = "fullscreen";
		level.introscreen.foreground = 0;
		level.introscreen setshader( "black", 640, 480 );
		wait 0,05;
	}
	level.introscreen.alpha = 1;
	players = get_players();
	i = 0;
	while ( i < players.size )
	{
		players[ i ] freezecontrols( 1 );
		i++;
	}
	wait 1;
}
