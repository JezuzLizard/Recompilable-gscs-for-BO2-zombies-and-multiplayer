#include maps/mp/animscripts/dog_flashed;
#include maps/mp/_scrambler;
#include maps/mp/killstreaks/_remote_weapons;
#include maps/mp/gametypes/_weaponobjects;
#include maps/mp/gametypes/_globallogic_audio;
#include maps/mp/_challenges;
#include maps/mp/_scoreevents;
#include maps/mp/gametypes/_damagefeedback;
#include maps/mp/gametypes/_globallogic_player;
#include maps/mp/gametypes/_spawning;
#include maps/mp/_hacker_tool;
#include maps/mp/_entityheadicons;
#include maps/mp/killstreaks/_killstreakrules;
#include maps/mp/killstreaks/_supplydrop;
#include maps/mp/killstreaks/_killstreaks;
#include maps/mp/gametypes/_tweakables;
#include maps/mp/_mgturret;
#include maps/mp/gametypes/_weapons;
#include maps/mp/gametypes/_hud_util;
#include common_scripts/utility;
#include maps/mp/_utility;

#using_animtree( "mp_microwaveturret" );

init()
{
	precacheturret( "auto_gun_turret_mp" );
	precacheturret( "microwave_turret_mp" );
	precachemodel( "t6_wpn_turret_sentry_gun" );
	precachemodel( "t6_wpn_turret_sentry_gun_yellow" );
	precachemodel( "t6_wpn_turret_sentry_gun_red" );
	precachemodel( "t6_wpn_turret_ads_world" );
	precachemodel( "t6_wpn_turret_ads_carry" );
	precachemodel( "t6_wpn_turret_ads_carry_animate" );
	precachemodel( "t6_wpn_turret_ads_carry_animate_red" );
	precachemodel( "t6_wpn_turret_ads_carry_red" );
	precachemodel( "tag_microwavefx" );
	precacheshellshock( "mp_radiation_high" );
	precacheshellshock( "mp_radiation_med" );
	precacheshellshock( "mp_radiation_low" );
	precacheitem( "killstreak_remote_turret_mp" );
	thread maps/mp/_mgturret::init_turret_difficulty_settings();
	level.auto_turret_timeout = 240;
	level.microwave_radius = 750;
	level.microwave_turret_cone_dot = cos( 45 );
	level.microwave_turret_angle = 90;
	level.microwave_turret_damage = 10;
	level.microwave_fx_size = 150;
	flag_init( "end_target_confirm" );
	level.auto_turret_settings = [];
	level.microwaveopenanim = %o_hpm_open;
	level.microwavecloseanim = %o_hpm_close;
	level.microwavedestroyedanim = %o_hpm_destroyed;
	level.auto_turret_settings[ "sentry" ] = spawnstruct();
	level.auto_turret_settings[ "sentry" ].hintstring = &"KILLSTREAK_SENTRY_TURRET_PICKUP";
	level.auto_turret_settings[ "sentry" ].hackerhintstring = &"KILLSTREAK_TURRET_HACKING";
	level.auto_turret_settings[ "sentry" ].disablehintstring = &"KILLSTREAK_TURRET_SENTRY_DISABLE";
	level.auto_turret_settings[ "sentry" ].hinticon = "hud_ks_auto_turret";
	level.auto_turret_settings[ "sentry" ].modelbase = "t6_wpn_turret_sentry_gun";
	level.auto_turret_settings[ "sentry" ].modelgoodplacement = "t6_wpn_turret_sentry_gun_yellow";
	level.auto_turret_settings[ "sentry" ].modelbadplacement = "t6_wpn_turret_sentry_gun_red";
	level.auto_turret_settings[ "sentry" ].stunfx = loadfx( "weapon/sentry_gun/fx_sentry_gun_emp_stun" );
	level.auto_turret_settings[ "sentry" ].stunfxtag = "tag_origin";
	level.auto_turret_settings[ "sentry" ].damagefx = loadfx( "weapon/sentry_gun/fx_sentry_gun_damage_state" );
	level.auto_turret_settings[ "sentry" ].disablefx = loadfx( "weapon/sentry_gun/fx_sentry_gun_death_state" );
	level.auto_turret_settings[ "sentry" ].explodefx = loadfx( "weapon/sentry_gun/fx_sentry_gun_exp" );
	level.auto_turret_settings[ "sentry" ].stunfxfrequencymin = 0,1;
	level.auto_turret_settings[ "sentry" ].stunfxfrequencymax = 0,75;
	level.auto_turret_settings[ "sentry" ].turretinitdelay = 1,6;
	level.auto_turret_settings[ "sentry" ].hackertoolradius = level.sentryhackertoolradius;
	level.auto_turret_settings[ "sentry" ].hackertooltimems = level.sentryhackertooltimems;
	level.auto_turret_settings[ "tow" ] = spawnstruct();
	level.auto_turret_settings[ "tow" ].hintstring = &"KILLSTREAK_TOW_TURRET_PICKUP";
	level.auto_turret_settings[ "tow" ].hackerhintstring = &"KILLSTREAK_TURRET_HACKING";
	level.auto_turret_settings[ "tow" ].hinticon = "hud_ks_sam_turret";
	level.auto_turret_settings[ "tow" ].modelbase = "t6_wpn_turret_sam";
	level.auto_turret_settings[ "tow" ].modelgoodplacement = "t6_wpn_turret_sam_yellow";
	level.auto_turret_settings[ "tow" ].modelbadplacement = "t6_wpn_turret_sam_red";
	level.auto_turret_settings[ "tow" ].stunfx = loadfx( "weapon/grenade/fx_spark_disabled_weapon_lg" );
	level.auto_turret_settings[ "tow" ].stunfxtag = "TAG_aim";
	level.auto_turret_settings[ "tow" ].stunfxfrequencymin = 0,1;
	level.auto_turret_settings[ "tow" ].stunfxfrequencymax = 0,75;
	level.auto_turret_settings[ "tow" ].turretinitdelay = 3;
	level.auto_turret_settings[ "tow" ].turretfiredelay = 5;
	level.auto_turret_settings[ "microwave" ] = spawnstruct();
	level.auto_turret_settings[ "microwave" ].hintstring = &"KILLSTREAK_MICROWAVE_TURRET_PICKUP";
	level.auto_turret_settings[ "microwave" ].hackerhintstring = &"KILLSTREAK_TURRET_MICROWAVE_HACKING";
	level.auto_turret_settings[ "microwave" ].disablehintstring = &"KILLSTREAK_TURRET_MICROWAVE_DISABLE";
	level.auto_turret_settings[ "microwave" ].hinticon = "hud_ks_microwave_turret";
	level.auto_turret_settings[ "microwave" ].modelbase = "t6_wpn_turret_ads_world";
	level.auto_turret_settings[ "microwave" ].modelgoodplacement = "t6_wpn_turret_ads_carry";
	level.auto_turret_settings[ "microwave" ].modelgoodplacementanimate = "t6_wpn_turret_ads_carry_animate";
	level.auto_turret_settings[ "microwave" ].modelbadplacementanimate = "t6_wpn_turret_ads_carry_animate_red";
	level.auto_turret_settings[ "microwave" ].modelbadplacement = "t6_wpn_turret_ads_carry_red";
	level.auto_turret_settings[ "microwave" ].stunfx = loadfx( "weapon/silent_gaurdian/fx_sg_emp_stun" );
	level.auto_turret_settings[ "microwave" ].loopsoundfx = "wpn_sguard_beam";
	level.auto_turret_settings[ "microwave" ].stunfxtag = "tag_origin";
	level.auto_turret_settings[ "microwave" ].damagefx = loadfx( "weapon/silent_gaurdian/fx_sg_damage_state" );
	level.auto_turret_settings[ "microwave" ].disablefx = loadfx( "weapon/silent_gaurdian/fx_sg_death_state" );
	level.auto_turret_settings[ "microwave" ].explodefx = loadfx( "weapon/silent_gaurdian/fx_sg_exp" );
	level.auto_turret_settings[ "microwave" ].stunfxfrequencymin = 0,1;
	level.auto_turret_settings[ "microwave" ].stunfxfrequencymax = 0,75;
	level.auto_turret_settings[ "microwave" ].turretinitdelay = 1;
	level.auto_turret_settings[ "microwave" ].timeout = 240;
	level.auto_turret_settings[ "microwave" ].fxchecktime = 5;
	level.auto_turret_settings[ "microwave" ].hackertoolradius = level.microwavehackertoolradius;
	level.auto_turret_settings[ "microwave" ].hackertooltimems = level.microwavehackertooltimems;
	level.auto_turret_settings[ "microwave" ].microwave_radius_1 = int( level.microwave_radius / 8 );
	level.auto_turret_settings[ "microwave" ].microwave_radius_2 = int( level.microwave_radius / 2 );
	level.auto_turret_settings[ "microwave" ].microwave_radius_3 = int( ( level.microwave_radius * 3 ) / 4 );
	level.auto_turret_settings[ "microwave" ].microwave_radius_4 = int( level.microwave_radius );
	level.auto_turret_settings[ "microwave" ].fx = loadfx( "weapon/silent_gaurdian/fx_sg_distortion_cone_ash" );
	level._turret_explode_fx = loadfx( "explosions/fx_exp_equipment_lg" );
	minefields = getentarray( "minefield", "targetname" );
	hurt_triggers = getentarray( "trigger_hurt", "classname" );
	level.fatal_triggers = arraycombine( minefields, hurt_triggers, 1, 0 );
	level.noturretplacementtriggers = getentarray( "no_turret_placement", "targetname" );
	level notify( "no_turret_trigger_created" );
	if ( maps/mp/gametypes/_tweakables::gettweakablevalue( "killstreak", "allowauto_turret" ) )
	{
		maps/mp/killstreaks/_killstreaks::registerkillstreak( "autoturret_mp", "autoturret_mp", "killstreak_auto_turret", "auto_turret_used", ::usesentryturretkillstreak );
		maps/mp/killstreaks/_killstreaks::registerkillstreakaltweapon( "autoturret_mp", "auto_gun_turret_mp" );
		maps/mp/killstreaks/_killstreaks::registerkillstreakremoteoverrideweapon( "autoturret_mp", "killstreak_remote_turret_mp" );
		maps/mp/killstreaks/_killstreaks::registerkillstreakstrings( "autoturret_mp", &"KILLSTREAK_EARNED_AUTO_TURRET", &"KILLSTREAK_AUTO_TURRET_NOT_AVAILABLE" );
		maps/mp/killstreaks/_killstreaks::registerkillstreakdialog( "autoturret_mp", "mpl_killstreak_auto_turret", "kls_turret_used", "", "kls_turret_enemy", "", "kls_turret_ready" );
		maps/mp/killstreaks/_killstreaks::registerkillstreakdevdvar( "autoturret_mp", "scr_giveautoturret" );
		maps/mp/killstreaks/_killstreaks::registerkillstreak( "turret_drop_mp", "turret_drop_mp", "killstreak_auto_turret_drop", "auto_turret_used", ::usekillstreakturretdrop, undefined, 1 );
		maps/mp/killstreaks/_killstreaks::registerkillstreakremoteoverrideweapon( "turret_drop_mp", "killstreak_remote_turret_mp" );
		maps/mp/killstreaks/_killstreaks::registerkillstreakstrings( "turret_drop_mp", &"KILLSTREAK_EARNED_AUTO_TURRET", &"KILLSTREAK_AIRSPACE_FULL" );
		maps/mp/killstreaks/_killstreaks::registerkillstreakdialog( "turret_drop_mp", "mpl_killstreak_turret", "kls_turret_used", "", "kls_turret_enemy", "", "kls_turret_ready" );
		maps/mp/killstreaks/_killstreaks::registerkillstreakdevdvar( "turret_drop_mp", "scr_giveautoturretdrop" );
		maps/mp/killstreaks/_supplydrop::registercratetype( "turret_drop_mp", "killstreak", "autoturret_mp", 1, &"KILLSTREAK_AUTO_TURRET_CRATE", undefined, "MEDAL_SHARE_PACKAGE_AUTO_TURRET", ::maps/mp/killstreaks/_supplydrop::givecratekillstreak );
		level.killstreakicons[ "autoturret_mp" ] = "hud_ks_auto_turret";
		maps/mp/killstreaks/_killstreaks::registerkillstreak( "microwaveturret_mp", "microwaveturret_mp", "killstreak_microwave_turret", "microwave_turret_used", ::usemicrowaveturretkillstreak );
		maps/mp/killstreaks/_killstreaks::registerkillstreakaltweapon( "microwaveturret_mp", "microwave_turret_mp" );
		maps/mp/killstreaks/_killstreaks::registerkillstreakaltweapon( "microwaveturret_mp", "microwave_turret_damage_mp" );
		maps/mp/killstreaks/_killstreaks::registerkillstreakstrings( "microwaveturret_mp", &"KILLSTREAK_EARNED_MICROWAVE_TURRET", &"KILLSTREAK_MICROWAVE_TURRET_NOT_AVAILABLE" );
		maps/mp/killstreaks/_killstreaks::registerkillstreakdialog( "microwaveturret_mp", "mpl_killstreak_auto_turret", "kls_microwave_used", "", "kls_microwave_enemy", "", "kls_microwave_ready" );
		maps/mp/killstreaks/_killstreaks::registerkillstreakdevdvar( "microwaveturret_mp", "scr_givemicrowaveturret" );
		maps/mp/killstreaks/_killstreaks::setkillstreakteamkillpenaltyscale( "microwaveturret_mp", level.teamkillreducedpenalty );
		maps/mp/killstreaks/_killstreaks::registerkillstreak( "microwaveturret_drop_mp", "microwaveturret_drop_mp", "killstreak_microwave_turret_drop", "microwave_turret_used", ::usekillstreakturretdrop, undefined, 1 );
		maps/mp/killstreaks/_killstreaks::registerkillstreakstrings( "microwaveturret_drop_mp", &"KILLSTREAK_EARNED_MICROWAVE_TURRET", &"KILLSTREAK_AIRSPACE_FULL" );
		maps/mp/killstreaks/_killstreaks::registerkillstreakdialog( "microwaveturret_drop_mp", "mpl_killstreak_turret", "kls_microwave_used", "", "kls_microwave_enemy", "", "kls_microwave_ready" );
		maps/mp/killstreaks/_killstreaks::registerkillstreakdevdvar( "microwaveturret_drop_mp", "scr_givemicrowaveturretdrop" );
		maps/mp/killstreaks/_supplydrop::registercratetype( "microwaveturret_drop_mp", "killstreak", "microwaveturret_mp", 1, &"KILLSTREAK_MICROWAVE_TURRET_CRATE", undefined, "MEDAL_SHARE_PACKAGE_MICROWAVE_TURRET", ::maps/mp/killstreaks/_supplydrop::givecratekillstreak );
		level.killstreakicons[ "microwaveturret_mp" ] = "hud_ks_microwave_turret";
	}
	level.turrets_headicon_offset = [];
	level.turrets_headicon_offset[ "default" ] = vectorScale( ( 0, 0, 0 ), 70 );
	level.turrets_headicon_offset[ "sentry" ] = vectorScale( ( 0, 0, 0 ), 70 );
	level.turrets_headicon_offset[ "tow" ] = vectorScale( ( 0, 0, 0 ), 65 );
	level.turrets_headicon_offset[ "microwave" ] = vectorScale( ( 0, 0, 0 ), 80 );
	level.turrets_hacker_trigger_width = 72;
	level.turrets_hacker_trigger_height = 96;
	setdvar( "scr_turret_no_timeout", 0 );
	setdvar( "turret_sentryTargetTime", 1500 );
	setdvar( "turret_TargetLeadBias", 1,5 );
	registerclientfield( "turret", "turret_microwave_sounds", 1000, 1, "int" );
}

usekillstreakturretdrop( hardpointtype )
{
	if ( self maps/mp/killstreaks/_supplydrop::issupplydropgrenadeallowed( hardpointtype ) == 0 )
	{
		return 0;
	}
	result = self maps/mp/killstreaks/_supplydrop::usesupplydropmarker();
	self notify( "supply_drop_marker_done" );
	if ( !isDefined( result ) || !result )
	{
		return 0;
	}
	return result;
}

usesentryturretkillstreak( hardpointtype )
{
	if ( self maps/mp/killstreaks/_killstreaks::isinteractingwithobject() )
	{
		return 0;
	}
	if ( self maps/mp/killstreaks/_killstreakrules::iskillstreakallowed( hardpointtype, self.team ) == 0 )
	{
		return 0;
	}
	killstreak_id = self maps/mp/killstreaks/_killstreakrules::killstreakstart( hardpointtype, self.team );
	if ( killstreak_id == -1 )
	{
		return 0;
	}
	turret = self usesentryturret( hardpointtype );
	turret.killstreak_id = killstreak_id;
	event = turret waittill_any_return( "turret_placed", "destroy_turret", "death", "turret_emped" );
	if ( event == "turret_placed" )
	{
		level.globalkillstreakscalled++;
		self addweaponstat( hardpointtype, "used", 1 );
		return 1;
	}
	if ( event == "death" )
	{
		returnturrettoinventory( turret );
		return 0;
	}
	if ( event == "turret_emped" )
	{
		level.globalkillstreakscalled++;
		self addweaponstat( hardpointtype, "used", 1 );
		turret notify( "destroy_turret" );
		return 1;
	}
	return 0;
}

usetowturretkillstreak( hardpointtype )
{
	if ( self maps/mp/killstreaks/_killstreakrules::iskillstreakallowed( hardpointtype, self.team ) == 0 )
	{
		return 0;
	}
	killstreak_id = self maps/mp/killstreaks/_killstreakrules::killstreakstart( hardpointtype, self.team );
	if ( killstreak_id == -1 )
	{
		return 0;
	}
	turret = self usetowturret( hardpointtype );
	turret.killstreak_id = killstreak_id;
	event = turret waittill_any_return( "turret_placed", "destroy_turret", "death", "turret_emped" );
	if ( event == "turret_placed" )
	{
		return 1;
	}
	if ( event == "death" )
	{
		returnturrettoinventory( turret );
		return 0;
	}
	if ( event == "turret_emped" )
	{
		turret notify( "destroy_turret" );
		return 1;
	}
	return 0;
}

usemicrowaveturretkillstreak( hardpointtype )
{
	if ( self maps/mp/killstreaks/_killstreakrules::iskillstreakallowed( hardpointtype, self.team ) == 0 )
	{
		return 0;
	}
	if ( self maps/mp/killstreaks/_killstreaks::isinteractingwithobject() )
	{
		return 0;
	}
	killstreak_id = self maps/mp/killstreaks/_killstreakrules::killstreakstart( hardpointtype, self.team );
	if ( killstreak_id == -1 )
	{
		return 0;
	}
	turret = self usemicrowaveturret( hardpointtype );
	turret.killstreak_id = killstreak_id;
	event = turret waittill_any_return( "turret_placed", "destroy_turret", "death", "turret_emped" );
	if ( event == "turret_placed" )
	{
		level.globalkillstreakscalled++;
		self addweaponstat( hardpointtype, "used", 1 );
		return 1;
	}
	if ( event == "death" )
	{
		returnturrettoinventory( turret );
		return 0;
	}
	if ( event == "turret_emped" )
	{
		level.globalkillstreakscalled++;
		self addweaponstat( hardpointtype, "used", 1 );
		turret notify( "destroy_turret" );
		return 1;
	}
	return 0;
}

usesentryturret( hardpointtype )
{
	self maps/mp/killstreaks/_killstreaks::switchtolastnonkillstreakweapon();
	if ( isDefined( level.usingmomentum ) && !level.usingmomentum && !self maps/mp/killstreaks/_killstreaks::getiftopkillstreakhasbeenused() )
	{
		level.globalkillstreakscalled++;
		self addweaponstat( hardpointtype, "used", 1 );
	}
	turret = spawnturret( "auto_turret", self.origin, "auto_gun_turret_mp" );
	turret.turrettype = "sentry";
	turret setturrettype( turret.turrettype );
	turret setmodel( level.auto_turret_settings[ turret.turrettype ].modelgoodplacement );
	turret.angles = self.angles;
	turret.hardpointweapon = hardpointtype;
	turret.hasbeenplanted = 0;
	turret.waitfortargettobeginlifespan = 0;
	self.turret_active = 0;
	self.curr_time = -1;
	turret.stunnedbytacticalgrenade = 0;
	turret.stuntime = 0;
	turret setturretowner( self );
	turret setturretminimapvisible( 1 );
	turret.isfrominventory = self.usingkillstreakfrominventory;
	turret setdrawinfrared( 1 );
	target_set( turret, vectorScale( ( 0, 0, 0 ), 40 ) );
	turret.controlled = 0;
	if ( !isDefined( self.numturrets ) )
	{
		self.numturrets = 1;
	}
	else
	{
		self.numturrets++;
	}
	turret.ownernumber = self.numturrets;
	if ( level.teambased )
	{
		turret setturretteam( self.team );
		turret.team = self.team;
	}
	else
	{
		turret setturretteam( "free" );
		turret.team = "free";
	}
	setupturrethealth( turret );
	turret.carried = 1;
	turret.curr_time = 0;
	turret.stunduration = 5;
	turret.remotecontrolled = 0;
	turret thread watchturretlifespan();
	self thread watchownerdisconnect( turret );
	self thread watchownerteamkillkicked( turret );
	turret thread destroyturret();
	turret thread turret_target_aquired_watch( self );
	turret thread turret_target_lost_watch( self );
	self thread startcarryturret( turret );
	return turret;
}

usetowturret( hardpointtype )
{
	self maps/mp/killstreaks/_killstreaks::switchtolastnonkillstreakweapon();
	if ( isDefined( level.usingmomentum ) && !level.usingmomentum && !self maps/mp/killstreaks/_killstreaks::getiftopkillstreakhasbeenused() )
	{
		level.globalkillstreakscalled++;
		self addweaponstat( hardpointtype, "used", 1 );
	}
	turret = spawnturret( "auto_turret", self.origin, "tow_turret_mp" );
	turret.turrettype = "tow";
	turret setturrettype( turret.turrettype );
	turret setmodel( level.auto_turret_settings[ turret.turrettype ].modelgoodplacement );
	turret.angles = self.angles;
	turret.hardpointweapon = hardpointtype;
	turret.hasbeenplanted = 0;
	turret.waitfortargettobeginlifespan = 0;
	turret.firetime = level.auto_turret_settings[ "tow" ].turretfiredelay;
	self.turret_active = 0;
	turret.stunnedbytacticalgrenade = 0;
	turret.stuntime = 0;
	turret setturretowner( self );
	turret setturretminimapvisible( 1 );
	turret.isfrominventory = self.usingkillstreakfrominventory;
	if ( level.teambased )
	{
		turret setturretteam( self.team );
		turret.team = self.team;
	}
	else
	{
		turret setturretteam( "free" );
		turret.team = "free";
	}
	setupturrethealth( turret );
	turret.carried = 1;
	turret.curr_time = 0;
	turret.stunduration = 5;
	turret setscanningpitch( -35 );
	turret thread watchturretlifespan();
	self thread watchownerdisconnect( turret );
	self thread watchownerteamkillkicked( turret );
	turret thread destroyturret();
	self thread startcarryturret( turret );
	return turret;
}

usemicrowaveturret( hardpointtype )
{
	self maps/mp/killstreaks/_killstreaks::switchtolastnonkillstreakweapon();
	if ( isDefined( level.usingmomentum ) && !level.usingmomentum && !self maps/mp/killstreaks/_killstreaks::getiftopkillstreakhasbeenused() )
	{
		level.globalkillstreakscalled++;
		self addweaponstat( hardpointtype, "used", 1 );
	}
	turret = spawnturret( "auto_turret", self.origin, "microwave_turret_mp" );
	turret.turrettype = "microwave";
	turret setturrettype( turret.turrettype );
	turret setmodel( level.auto_turret_settings[ turret.turrettype ].modelgoodplacement );
	turret.angles = self.angles;
	turret.hardpointweapon = hardpointtype;
	turret.hasbeenplanted = 0;
	turret.waitfortargettobeginlifespan = 0;
	self.turret_active = 0;
	self.curr_time = -1;
	turret.stunnedbytacticalgrenade = 0;
	turret.stuntime = 0;
	turret setturretowner( self );
	turret setturretminimapvisible( 1 );
	turret.isfrominventory = self.usingkillstreakfrominventory;
	turret setdrawinfrared( 1 );
	turret.controlled = 0;
	turret.soundmod = "hpm";
	target_set( turret, vectorScale( ( 0, 0, 0 ), 30 ) );
	if ( level.teambased )
	{
		turret setturretteam( self.team );
		turret.team = self.team;
	}
	else
	{
		turret setturretteam( "free" );
		turret.team = "free";
	}
	setupturrethealth( turret );
	turret.carried = 1;
	turret.curr_time = 0;
	turret.stunduration = 5;
	turret thread watchturretlifespan();
	self thread watchownerdisconnect( turret );
	turret thread destroyturret();
	self thread startcarryturret( turret );
	return turret;
}

watchroundandgameend( turret )
{
	self endon( "disconnect" );
	turret notify( "watchRoundAndGameEnd" );
	turret endon( "watchRoundAndGameEnd" );
	turret endon( "destroy_turret" );
	turret endon( "hacked" );
	turret endon( "death" );
	level waittill( "game_ended" );
	self stopcarryturret( turret );
	turret notify( "destroy_turret" );
}

giveturretback( turret )
{
	if ( isDefined( level.usingmomentum ) || !level.usingmomentum && isDefined( turret.isfrominventory ) && turret.isfrominventory )
	{
		maps/mp/killstreaks/_killstreaks::givekillstreak( turret.hardpointweapon, undefined, undefined, 1 );
	}
}

watchownerdeath( turret )
{
	self endon( "disconnect" );
	turret endon( "turret_placed" );
	turret endon( "destroy_turret" );
	turret endon( "hacked" );
	self waittill( "death" );
	if ( !turret.hasbeenplanted )
	{
		self returnturrettoinventory( turret );
	}
	else if ( turret.canbeplaced && turret.carried )
	{
		if ( level.teambased && self.team != turret.team )
		{
			self stopcarryturret( turret );
			turret notify( "destroy_turret" );
		}
		else
		{
			placement = self canplayerplaceturret( turret );
			if ( placement[ "result" ] )
			{
				turret.origin = placement[ "origin" ];
				turret.angles = placement[ "angles" ];
				self placeturret( turret );
			}
			else
			{
				if ( isDefined( turret ) )
				{
					self stopcarryturret( turret );
					turret notify( "destroy_turret" );
				}
			}
		}
	}
	else
	{
		if ( isDefined( turret ) )
		{
			self stopcarryturret( turret );
			turret notify( "destroy_turret" );
		}
	}
}

returnturrettoinventory( turret )
{
	if ( level.teambased && self.team != turret.team )
	{
		if ( isDefined( turret ) )
		{
			self stopcarryturret( turret );
			turret notify( "destroy_turret" );
		}
	}
	else
	{
		if ( isDefined( turret ) )
		{
			turret setturretcarried( 0 );
			self stopcarryturret( turret );
			turret notify( "destroy_turret" );
		}
		self _enableweapon();
	}
}

watchowneremp( turret )
{
	self endon( "disconnect" );
	self endon( "death" );
	turret endon( "turret_placed" );
	turret endon( "destroy_turret" );
	turret endon( "hacked" );
	while ( 1 )
	{
		self waittill( "emp_jammed" );
		if ( !turret.hasbeenplanted )
		{
			turret setturretcarried( 0 );
			self stopcarryturret( turret );
			self _enableweapon();
			self takeweapon( turret.hardpointweapon );
			turret notify( "turret_emped" );
			continue;
		}
		else if ( turret.canbeplaced && turret.carried )
		{
			self placeturret( turret );
			continue;
		}
		else
		{
			if ( isDefined( turret ) )
			{
				self stopcarryturret( turret );
				turret notify( "turret_emped" );
			}
		}
	}
}

watchownerteamkillkicked( turret )
{
	turret endon( "turret_deactivated" );
	turret endon( "hacked" );
	turret endon( "destroy_turret" );
	self waittill( "teamKillKicked" );
	if ( isDefined( turret ) )
	{
		turret notify( "destroy_turret" );
	}
}

watchownerdisconnect( turret )
{
	turret endon( "turret_deactivated" );
	turret endon( "hacked" );
	self waittill_any( "disconnect", "joined_team" );
	if ( isDefined( turret ) )
	{
		turret notify( "destroy_turret" );
	}
}

startcarryturret( turret )
{
	turret maketurretunusable();
	turret setturretcarried( 1 );
	self _disableweapon();
	turret stoploopsound();
	turret setmode( "auto_ai" );
	if ( turret.turrettype == "sentry" )
	{
		turret notify( "stop_burst_fire_unmanned" );
	}
	else if ( turret.turrettype == "tow" )
	{
		turret notify( "target_lost" );
	}
	else
	{
		if ( turret.turrettype == "microwave" )
		{
			turret notify( "stop_microwave" );
		}
	}
	turret.carried = 1;
	if ( turret.hasbeenplanted )
	{
		level notify( "drop_objects_to_ground" );
	}
	self carryturret( turret, vectorScale( ( 0, 0, 0 ), 40 ), ( 0, 0, 0 ) );
	self thread watchownerdeath( turret );
	self thread watchowneremp( turret );
	self thread watchroundandgameend( turret );
	turret maps/mp/_entityheadicons::destroyentityheadicons();
	turret setturretowner( self );
	turret setdefaultdroppitch( -90 );
	if ( !turret.hasbeenplanted )
	{
		self thread watchreturnturrettoinventory( turret );
	}
	self thread updateturretplacement( turret );
	self thread watchturretplacement( turret );
	if ( turret.turrettype == "microwave" )
	{
		turret clearclientflag( 2 );
		turret setclientflag( 3 );
		self playsoundtoplayer( "mpl_turret_micro_startup", self );
	}
	turret notify( "turret_carried" );
	turret notify( "turret_target_lost" );
}

watchreturnturrettoinventory( turret )
{
	self endon( "death" );
	self endon( "entering_last_stand" );
	self endon( "disconnect" );
	turret endon( "turret_placed" );
	turret endon( "turret_deactivated" );
	wait 0,05;
	while ( 1 )
	{
		if ( self actionslotfourbuttonpressed() )
		{
			returnturrettoinventory( turret );
			return;
		}
		wait 0,05;
	}
}

updateturretplacement( turret )
{
	self endon( "death" );
	self endon( "entering_last_stand" );
	self endon( "disconnect" );
	turret endon( "turret_placed" );
	turret endon( "turret_deactivated" );
	lastplacedturret = -1;
	turret.canbeplaced = 0;
	firstmodel = 1;
	while ( 1 )
	{
		placement = self canplayerplaceturret( turret );
		turret.origin = placement[ "origin" ];
		turret.angles = placement[ "angles" ];
		good_spot_check = placement[ "result" ] & !turret turretinhurttrigger() & !turret turretinnoturretplacementtrigger();
		turret.canbeplaced = good_spot_check;
		if ( turret.canbeplaced != lastplacedturret && turret.turrettype == "microwave" && firstmodel != 1 )
		{
			if ( good_spot_check )
			{
				turret setmodel( level.auto_turret_settings[ turret.turrettype ].modelgoodplacement );
			}
			else
			{
				turret setmodel( level.auto_turret_settings[ turret.turrettype ].modelbadplacement );
			}
			lastplacedturret = turret.canbeplaced;
		}
		if ( turret.turrettype == "microwave" && firstmodel == 1 )
		{
			if ( turret.canbeplaced )
			{
				turret setmodel( level.auto_turret_settings[ turret.turrettype ].modelgoodplacementanimate );
			}
			else
			{
				turret setmodel( level.auto_turret_settings[ turret.turrettype ].modelbadplacementanimate );
			}
			firstmodel = 0;
			lastplacedturret = turret.canbeplaced;
		}
		wait 0,05;
	}
}

turretinhurttrigger()
{
	i = 0;
	while ( i < level.fatal_triggers.size )
	{
		if ( self istouching( level.fatal_triggers[ i ] ) )
		{
			return 1;
		}
		i++;
	}
	return 0;
}

turretinnoturretplacementtrigger()
{
	i = 0;
	while ( i < level.noturretplacementtriggers.size )
	{
		if ( self istouching( level.noturretplacementtriggers[ i ] ) )
		{
			return 1;
		}
		i++;
	}
	return 0;
}

watchturretplacement( turret )
{
	self endon( "disconnect" );
	self endon( "death" );
	self endon( "entering_last_stand" );
	turret endon( "turret_placed" );
	turret endon( "turret_deactivated" );
	while ( self attackbuttonpressed() )
	{
		wait 0,05;
	}
	while ( 1 )
	{
		if ( self attackbuttonpressed() && turret.canbeplaced )
		{
			placement = self canplayerplaceturret( turret );
			if ( placement[ "result" ] )
			{
				turret.origin = placement[ "origin" ];
				turret.angles = placement[ "angles" ];
				self placeturret( turret );
			}
		}
		wait 0,05;
	}
}

placeturret( turret )
{
	if ( !turret.carried || !turret.canbeplaced )
	{
		return;
	}
	turret setturretcarried( 0 );
	self stopcarryturret( turret, turret.origin, turret.angles );
	turret spawnturretpickuptrigger( self );
	turret maps/mp/_hacker_tool::registerwithhackertool( level.auto_turret_settings[ turret.turrettype ].hackertoolradius, level.auto_turret_settings[ turret.turrettype ].hackertooltimems );
	self thread initturret( turret );
	self _enableweapon();
	turret.carried = 0;
	turret.hasbeenplanted = 1;
	if ( turret.stunnedbytacticalgrenade )
	{
		turret thread stunturrettacticalgrenade( turret.stunduration );
	}
	if ( isDefined( level.auto_turret_settings[ turret.turrettype ].loopsoundfx ) )
	{
		turret playloopsound( level.auto_turret_settings[ turret.turrettype ].loopsoundfx );
	}
	self playrumbleonentity( "damage_heavy" );
	turret notify( "turret_placed" );
}

initturret( turret )
{
	maps/mp/_mgturret::turret_set_difficulty( turret, "fu" );
	turret setmodel( level.auto_turret_settings[ turret.turrettype ].modelbase );
	if ( turret.turrettype == "microwave" )
	{
		turret clearclientflag( 3 );
		turret setclientflag( 2 );
	}
	turret setforcenocull();
	turret playsound( "mpl_turret_startup" );
	if ( level.teambased )
	{
		offset = level.turrets_headicon_offset[ "default" ];
		if ( isDefined( level.turrets_headicon_offset[ turret.turrettype ] ) )
		{
			offset = level.turrets_headicon_offset[ turret.turrettype ];
		}
		turret maps/mp/_entityheadicons::setentityheadicon( self.pers[ "team" ], self, offset );
	}
	turret maketurretunusable();
	turret setmode( "auto_nonai" );
	turret setturretowner( self );
	turret.owner = self;
	turret setdefaultdroppitch( 45 );
	turret.dangerous_nodes = [];
	if ( turret.turrettype == "sentry" )
	{
		turret thread turret_sentry_think( self );
	}
	else if ( turret.turrettype == "tow" )
	{
		turret thread turret_tow_think( self );
	}
	else
	{
		if ( turret.turrettype == "microwave" )
		{
			turret thread turret_microwave_think( self );
		}
	}
	turret.turret_active = 1;
	turret.spawninfluencerid = maps/mp/gametypes/_spawning::create_auto_turret_influencer( turret.origin, turret.team, turret.angles );
	turret.spawninfluencercloseid = maps/mp/gametypes/_spawning::create_auto_turret_influencer_close( turret.origin, turret.team, turret.angles );
	turret thread watchdamage();
	turret thread checkforstundamage();
	wait 1;
	flag_set( "end_target_confirm" );
}

setupturrethealth( turret )
{
	turret.health = 100000;
	turret.maxhealth = 650;
	turret.bulletdamagereduction = 0,6;
	turret.explosivedamagereduction = 2;
}

watchdamage()
{
	self endon( "turret_deactivated" );
	medalgiven = 0;
	if ( !isDefined( self.damagetaken ) )
	{
		self.damagetaken = 0;
	}
	low_health = 0;
	if ( self.damagetaken > ( self.maxhealth / 1,8 ) )
	{
		playfxontag( level.auto_turret_settings[ self.turrettype ].damagefx, self, level.auto_turret_settings[ self.turrettype ].stunfxtag );
		low_health = 1;
	}
	for ( ;; )
	{
		self waittill( "damage", damage, attacker, direction, point, type, tagname, modelname, partname, weaponname );
		if ( type == "MOD_CRUSH" )
		{
			self.skipfutz = 1;
			self notify( "destroy_turret" );
			return;
		}
		if ( !isDefined( attacker ) )
		{
			continue;
		}
		else allowperks = 1;
		if ( !isplayer( attacker ) )
		{
			if ( isDefined( attacker.owner ) && isplayer( attacker.owner ) )
			{
				attacker = attacker.owner;
				allowperks = 0;
			}
		}
		if ( isplayer( attacker ) && level.teambased && isDefined( attacker.team ) && self.team == attacker.team && level.friendlyfire == 0 )
		{
			continue;
		}
		else
		{
			if ( !level.teambased && !level.hardcoremode )
			{
				if ( self.owner == attacker )
				{
					break;
				}
			}
			else if ( self.turrettype == "microwave" && partname == "tag_shield" )
			{
				self.health += damage;
				break;
			}
			else damagetakenbefore = self.damagetaken;
			if ( type != "MOD_PISTOL_BULLET" || type == "MOD_RIFLE_BULLET" && type == "MOD_PROJECTILE_SPLASH" && isexplosivebulletweapon( weaponname ) )
			{
				if ( allowperks && attacker hasperk( "specialty_armorpiercing" ) )
				{
					damage += int( damage * level.cac_armorpiercing_data );
				}
				if ( weaponclass( weaponname ) == "spread" )
				{
					damage *= 5;
				}
				self.damagetaken += self.bulletdamagereduction * damage;
			}
			else
			{
				if ( weaponname != "remote_missile_missile_mp" || weaponname == "remote_mortar_mp" && weaponname == "missile_drone_projectile_mp" )
				{
					self.damagetaken += damage * 10;
					break;
				}
				else
				{
					if ( type == "MOD_PROJECTILE" || weaponname == "smaw_mp" && weaponname == "fhj18_mp" )
					{
						self.damagetaken += 200 * self.explosivedamagereduction;
						break;
					}
					else
					{
						if ( type != "MOD_PROJECTILE" && type != "MOD_GRENADE_SPLASH" && type == "MOD_PROJECTILE_SPLASH" && damage != 0 && weaponname != "emp_grenade_mp" && !isexplosivebulletweapon( weaponname ) )
						{
							self.damagetaken += self.explosivedamagereduction * damage;
							break;
						}
						else
						{
							if ( type == "MOD_MELEE" )
							{
								if ( isplayer( attacker ) )
								{
									attacker playlocalsound( "fly_riotshield_impact_knife" );
								}
								break;
							}
							else if ( isDefined( weaponname ) && weaponname == "emp_grenade_mp" && type == "MOD_GRENADE_SPLASH" )
							{
								self.damagetaken += self.maxhealth;
								break;
							}
							else
							{
								self.damagetaken += damage;
							}
						}
					}
				}
			}
			damagedealt = self.damagetaken - damagetakenbefore;
			if ( damagedealt > 0 && isDefined( self.controlled ) && self.controlled )
			{
				self.owner sendkillstreakdamageevent( int( damagedealt ) );
			}
			if ( isDefined( weaponname ) && type == "MOD_GRENADE_SPLASH" )
			{
				switch( weaponname )
				{
					case "emp_grenade_mp":
						if ( !self.stunnedbytacticalgrenade )
						{
							self thread stunturrettacticalgrenade( self.stunduration );
						}
						if ( level.teambased && self.owner.team != attacker.team )
						{
							if ( maps/mp/gametypes/_globallogic_player::dodamagefeedback( weaponname, attacker ) )
							{
								attacker maps/mp/gametypes/_damagefeedback::updatedamagefeedback( type );
							}
						}
						else
						{
							if ( !level.teambased && self.owner != attacker )
							{
								if ( maps/mp/gametypes/_globallogic_player::dodamagefeedback( weaponname, attacker ) )
								{
									attacker maps/mp/gametypes/_damagefeedback::updatedamagefeedback( type );
								}
							}
						}
						break;
					default:
						if ( maps/mp/gametypes/_globallogic_player::dodamagefeedback( weaponname, attacker ) )
						{
							attacker maps/mp/gametypes/_damagefeedback::updatedamagefeedback( type );
						}
						break;
				}
			}
			else
			{
				if ( isDefined( weaponname ) )
				{
					if ( maps/mp/gametypes/_globallogic_player::dodamagefeedback( weaponname, attacker ) )
					{
						attacker maps/mp/gametypes/_damagefeedback::updatedamagefeedback( type );
					}
				}
			}
			if ( self.damagetaken >= self.maxhealth )
			{
				if ( self isenemyplayer( attacker ) && self.owner != attacker )
				{
					if ( self.turrettype == "sentry" )
					{
						maps/mp/_scoreevents::processscoreevent( "destroyed_sentry_gun", attacker, self, weaponname );
					}
					else
					{
						if ( self.turrettype == "microwave" )
						{
							maps/mp/_scoreevents::processscoreevent( "destroyed_microwave_turret", attacker, self, weaponname );
						}
					}
					attacker maps/mp/_challenges::destroyedturret( weaponname );
					if ( isDefined( self.hardpointweapon ) )
					{
						level.globalkillstreaksdestroyed++;
						attacker addweaponstat( self.hardpointweapon, "destroyed", 1 );
					}
					if ( isDefined( self.controlled ) && self.controlled )
					{
						attacker addweaponstat( weaponname, "destroyed_controlled_killstreak", 1 );
					}
				}
				owner = self.owner;
				if ( self.turrettype == "sentry" )
				{
					owner maps/mp/gametypes/_globallogic_audio::leaderdialogonplayer( "sentry_destroyed", "item_destroyed" );
				}
				else
				{
					if ( self.turrettype == "microwave" )
					{
						owner maps/mp/gametypes/_globallogic_audio::leaderdialogonplayer( "microwave_destroyed", "item_destroyed" );
					}
				}
				owner stopcarryturret( self );
				self.damagetaken = self.health;
				self.dead = 1;
				self notify( "destroy_turret" );
			}
			if ( !low_health && self.damagetaken > ( self.maxhealth / 1,8 ) )
			{
				playfxontag( level.auto_turret_settings[ self.turrettype ].damagefx, self, level.auto_turret_settings[ self.turrettype ].stunfxtag );
				low_health = 1;
			}
		}
	}
}

watchturretlifespan( turret )
{
	self endon( "turret_deactivated" );
	self endon( "death" );
	while ( 1 )
	{
		timeout = level.auto_turret_timeout;
		if ( isDefined( turret ) && isDefined( level.auto_turret_settings[ turret.turrettype ].timeout ) )
		{
			timeout = level.auto_turret_settings[ turret.turrettype ].timeout;
		}
		if ( self.curr_time > timeout )
		{
			break;
		}
		else
		{
			while ( self.waitfortargettobeginlifespan )
			{
				wait 0,1;
			}
			if ( ( self.curr_time + 2 ) > level.auto_turret_timeout )
			{
				self deleteturretusetrigger();
			}
			if ( !self.carried )
			{
				self.curr_time += 1;
			}
			wait 1;
		}
	}
	shouldtimeout = getDvar( "scr_turret_no_timeout" );
	if ( shouldtimeout == "1" )
	{
		return;
	}
	self notify( "destroy_turret" );
}

checkforstundamage()
{
	self endon( "turret_deactivated" );
	while ( 1 )
	{
		self waittill( "damage_caused_by", weapon );
		if ( isstunweapon( weapon ) && !self.stunnedbytacticalgrenade )
		{
			self thread stunturrettacticalgrenade( self.stunduration );
		}
	}
}

stunturrettacticalgrenade( duration )
{
	self endon( "turret_deactivated" );
	self setmode( "auto_ai" );
	self notify( "stop_burst_fire_unmanned" );
	if ( self maps/mp/gametypes/_weaponobjects::isstunned() )
	{
		return;
	}
	self.stunnedbytacticalgrenade = 1;
	self thread stunturretfx( duration, 0, 1 );
	if ( self.turrettype == "microwave" )
	{
		self clearclientflag( 2 );
		self setclientflag( 3 );
		self notify( "microwave_end_fx" );
	}
	if ( isDefined( self.controlled ) && self.controlled )
	{
		self.owner freezecontrols( 1 );
	}
	if ( isDefined( self.owner.fullscreen_static ) )
	{
		self.owner thread maps/mp/killstreaks/_remote_weapons::stunstaticfx( duration );
	}
	while ( self.stunnedbytacticalgrenade )
	{
		while ( 1 )
		{
			if ( self.stuntime >= duration )
			{
				break;
			}
			else
			{
				if ( self.carried )
				{
					return;
				}
				self.stuntime += 0,1;
				wait 0,1;
			}
		}
	}
	self.stunnedbytacticalgrenade = 0;
	self.stuntime = 0;
	if ( isDefined( self.controlled ) && self.controlled )
	{
		self.owner freezecontrols( 0 );
	}
	if ( !self.carried )
	{
		self setmode( "auto_nonai" );
	}
	if ( self.turrettype != "tow" && !self.carried && !self.controlled )
	{
		self thread maps/mp/_mgturret::burst_fire_unmanned();
	}
	if ( self.turrettype == "microwave" && !self.carried )
	{
		self clearclientflag( 3 );
		self setclientflag( 2 );
		wait 0,5;
		self thread microwave_fx();
	}
	self notify( "turret_stun_ended" );
}

stunturret( duration, isdead, isemp )
{
	self endon( "turret_deactivated" );
	self setmode( "auto_ai" );
	self notify( "stop_burst_fire_unmanned" );
	self thread stunturretfx( duration, isdead, isemp );
	if ( isDefined( self.controlled ) && self.controlled && isDefined( self.owner ) )
	{
		self.owner freezecontrols( 1 );
	}
	if ( self.turrettype == "microwave" )
	{
		self clearclientflag( 2 );
		self setclientflag( 4 );
	}
	if ( isDefined( duration ) )
	{
		wait duration;
	}
	else
	{
		return;
	}
	if ( isDefined( self.controlled ) && self.controlled && isDefined( self.owner ) )
	{
		self.owner freezecontrols( 0 );
	}
	if ( !self.carried )
	{
		self setmode( "auto_nonai" );
	}
	if ( self.turrettype != "tow" && !self.carried && !self.controlled )
	{
		self thread maps/mp/_mgturret::burst_fire_unmanned();
	}
	self notify( "turret_stun_ended" );
	level notify( "turret_stun_ended" );
}

stunfxthink( fx )
{
	fx endon( "death" );
	self stoploopsound();
	self waittill_any( "death", "turret_stun_ended", "turret_deactivated", "hacked", "turret_carried" );
	if ( isDefined( self ) )
	{
		if ( isDefined( level.auto_turret_settings[ self.turrettype ].loopsoundfx ) )
		{
			self playloopsound( level.auto_turret_settings[ self.turrettype ].loopsoundfx );
		}
	}
	fx delete();
}

stunturretfx( duration, isdead, isemp )
{
	self endon( "turret_deactivated" );
	self endon( "death" );
	self endon( "turret_stun_ended" );
	origin = self gettagorigin( level.auto_turret_settings[ self.turrettype ].stunfxtag );
	self.stun_fx = spawn( "script_model", origin );
	self.stun_fx setmodel( "tag_origin" );
	self thread stunfxthink( self.stun_fx );
	wait 0,1;
	self.stun_fx playsound( "dst_disable_spark" );
	time = 0;
	while ( time < duration )
	{
		if ( ( int( time * 10 ) % 20 ) == 0 )
		{
			if ( isDefined( isdead ) && isdead )
			{
				playfxontag( level.auto_turret_settings[ self.turrettype ].disablefx, self.stun_fx, "tag_origin" );
			}
			if ( isDefined( isemp ) && isemp )
			{
				playfxontag( level.auto_turret_settings[ self.turrettype ].stunfx, self.stun_fx, "tag_origin" );
			}
		}
		wait 0,25;
		time += 0,25;
	}
}

isstunweapon( weapon )
{
	switch( weapon )
	{
		case "emp_grenade_mp":
			return 1;
		default:
			return 0;
	}
}

scramblerstun( stun )
{
	if ( stun )
	{
		self thread stunturret( 0, 1 );
	}
	else
	{
		self setmode( "auto_nonai" );
		if ( self.turrettype != "tow" && !self.controlled )
		{
			self thread maps/mp/_mgturret::burst_fire_unmanned();
		}
		self notify( "turret_stun_ended" );
		level notify( "turret_stun_ended" );
	}
}

watchscramble()
{
	self endon( "death" );
	self endon( "turret_deactivated" );
	self endon( "turret_carried" );
	if ( self maps/mp/_scrambler::checkscramblerstun() )
	{
		self thread scramblerstun( 1 );
	}
	for ( ;; )
	{
		level waittill_any( "scrambler_spawn", "scrambler_death", "hacked", "turret_stun_ended" );
		wait 0,05;
		if ( self maps/mp/_scrambler::checkscramblerstun() )
		{
			self thread scramblerstun( 1 );
			continue;
		}
		else
		{
			self scramblerstun( 0 );
		}
	}
}

destroyturret()
{
	self waittill( "destroy_turret", playdeathanim );
	self remove_turret_dangerous_nodes();
	if ( self.turrettype == "sentry" )
	{
		maps/mp/killstreaks/_killstreakrules::killstreakstop( "autoturret_mp", self.team, self.killstreak_id );
		if ( isDefined( self.owner ) && isDefined( self.owner.remoteweapon ) )
		{
			if ( self == self.owner.remoteweapon )
			{
				self notify( "removed_on_death" );
				self.owner notify( "remove_remote_weapon" );
			}
		}
		else
		{
			if ( isDefined( self.owner ) && !isDefined( self.owner.remoteweapon ) )
			{
				self.owner notify( "find_remote_weapon" );
			}
		}
	}
	else if ( self.turrettype == "tow" )
	{
		maps/mp/killstreaks/_killstreakrules::killstreakstop( "auto_tow_mp", self.team, self.killstreak_id );
	}
	else
	{
		if ( self.turrettype == "microwave" )
		{
			self notify( "microwave_end_fx" );
			maps/mp/killstreaks/_killstreakrules::killstreakstop( "microwaveturret_mp", self.team, self.killstreak_id );
		}
	}
	if ( isDefined( self.controlled ) && self.controlled == 1 && isDefined( self.owner ) )
	{
		self.owner sendkillstreakdamageevent( 600 );
		self.owner destroy_remote_hud();
	}
	self.turret_active = 0;
	self.curr_time = -1;
	self setmode( "auto_ai" );
	self notify( "stop_burst_fire_unmanned" );
	self notify( "turret_deactivated" );
	self deleteturretusetrigger();
	if ( isDefined( playdeathanim ) && playdeathanim && !self.carried )
	{
		self playsound( "dst_equipment_destroy" );
		self stunturret( self.stunduration, 1, self.stunnedbytacticalgrenade );
	}
	level notify( "drop_objects_to_ground" );
	if ( isDefined( self.spawninfluencerid ) )
	{
		removeinfluencer( self.spawninfluencerid );
		self.spawninfluencerid = undefined;
	}
	if ( isDefined( self.spawninfluencercloseid ) )
	{
		removeinfluencer( self.spawninfluencercloseid );
		self.spawninfluencercloseid = undefined;
	}
	self setturretminimapvisible( 0 );
	self laseroff();
	wait 0,1;
	if ( isDefined( self ) )
	{
		if ( self.hasbeenplanted )
		{
			playfx( level.auto_turret_settings[ self.turrettype ].explodefx, self.origin, self.angles );
			self playsound( "mpl_turret_exp" );
		}
		if ( self.carried && isDefined( self.owner ) )
		{
			self.owner stopcarryturret( self );
			self.owner _enableweapon();
		}
		self delete();
	}
}

deleteturretusetrigger()
{
	self remove_turret_dangerous_nodes();
	if ( isDefined( self.pickuptrigger ) )
	{
		self.pickuptrigger delete();
	}
	if ( isDefined( self.hackertrigger ) )
	{
		if ( isDefined( self.hackertrigger.progressbar ) )
		{
			self.hackertrigger.progressbar destroyelem();
			self.hackertrigger.progresstext destroyelem();
		}
		self.hackertrigger delete();
	}
	if ( isDefined( self.disabletrigger ) )
	{
		if ( isDefined( self.disabletrigger.progressbar ) )
		{
			self.disabletrigger.progressbar destroyelem();
			self.disabletrigger.progresstext destroyelem();
		}
		self.disabletrigger delete();
	}
}

spawnturretpickuptrigger( player )
{
	pos = self.origin + vectorScale( ( 0, 0, 0 ), 15 );
	self.pickuptrigger = spawn( "trigger_radius_use", pos );
	self.pickuptrigger setcursorhint( "HINT_NOICON", self );
	if ( isDefined( level.auto_turret_settings[ self.turrettype ].hintstring ) )
	{
		self.pickuptrigger sethintstring( level.auto_turret_settings[ self.turrettype ].hintstring );
	}
	else
	{
		self.pickuptrigger sethintstring( &"MP_GENERIC_PICKUP" );
	}
	if ( level.teambased )
	{
		self.pickuptrigger setteamfortrigger( player.team );
	}
	player clientclaimtrigger( self.pickuptrigger );
	self thread watchturretuse( self.pickuptrigger );
}

watchturretuse( trigger )
{
	self endon( "delete" );
	self endon( "turret_deactivated" );
	self endon( "turret_carried" );
	while ( 1 )
	{
		trigger waittill( "trigger", player );
		while ( !isalive( player ) )
		{
			continue;
		}
		while ( player isusingoffhand() )
		{
			continue;
		}
		while ( !player isonground() )
		{
			continue;
		}
		if ( isDefined( trigger.triggerteam ) && player.team != trigger.triggerteam )
		{
			continue;
		}
		if ( isDefined( trigger.claimedby ) && player != trigger.claimedby )
		{
			continue;
		}
		if ( player usebuttonpressed() && !player.throwinggrenade && !player meleebuttonpressed() && !player attackbuttonpressed() && !player maps/mp/killstreaks/_killstreaks::isinteractingwithobject() && !player isremotecontrolling() )
		{
			if ( isDefined( self.spawninfluencerid ) )
			{
				removeinfluencer( self.spawninfluencerid );
				self.spawninfluencerid = undefined;
			}
			if ( isDefined( self.spawninfluencercloseid ) )
			{
				removeinfluencer( self.spawninfluencercloseid );
				self.spawninfluencercloseid = undefined;
			}
			player playrumbleonentity( "damage_heavy" );
			self playsound( "mpl_turret_down" );
			self deleteturretusetrigger();
			if ( self.turrettype == "microwave" )
			{
				self notify( "microwave_end_fx" );
			}
			if ( isDefined( player.remoteweapon ) && player.remoteweapon == self )
			{
				player notify( "remove_remote_weapon" );
			}
			player thread startcarryturret( self );
			self deleteturretusetrigger();
		}
	}
}

turret_target_aquired_watch( player )
{
	level endon( "game_ended" );
	self endon( "death" );
	self endon( "destroy_turret" );
	player endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "turret_target_aquired" );
		if ( !self.remotecontrolled )
		{
			self laseron();
		}
	}
}

turret_target_lost_watch( player )
{
	level endon( "game_ended" );
	self endon( "death" );
	self endon( "destroy_turret" );
	player endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "turret_target_lost" );
		if ( !self.remotecontrolled )
		{
			self laseroff();
		}
	}
}

turret_sentry_think( player )
{
	self endon( "destroy_turret" );
	self.pickuptrigger endon( "trigger" );
	player maps/mp/killstreaks/_remote_weapons::initremoteweapon( self, "killstreak_remote_turret_mp" );
	wait level.auto_turret_settings[ self.turrettype ].turretinitdelay;
	self thread maps/mp/_mgturret::burst_fire_unmanned();
}

turret_tow_think( player )
{
	self endon( "turret_deactivated" );
	self endon( "death" );
	player endon( "disconnect" );
	level endon( "game_ended" );
	turretstate = "started";
	self thread missile_fired_notify();
	wait level.auto_turret_settings[ self.turrettype ].turretinitdelay;
	while ( 1 )
	{
		if ( self isfiringturret() && turretstate != "firing" )
		{
			turretstate = "firing";
			self playsound( "mpl_turret_alert" );
			self thread do_tow_shoot( player );
		}
		else
		{
			self notify( "target_lost" );
			turretstate = "scanning";
		}
		self waittill( "turretstatechange" );
		self notify( "target_lost" );
	}
}

deletetriggeronparentdeath( trigger )
{
	self waittill( "death" );
	if ( isDefined( trigger ) )
	{
		trigger delete();
	}
}

doesmicrowaveturretaffectentity( entity )
{
	if ( !isalive( entity ) )
	{
		return 0;
	}
	if ( !isplayer( entity ) && !isai( entity ) )
	{
		return 0;
	}
	if ( isDefined( self.carried ) && self.carried )
	{
		return 0;
	}
	if ( self maps/mp/gametypes/_weaponobjects::isstunned() )
	{
		return 0;
	}
	if ( isDefined( self.owner ) && entity == self.owner )
	{
		return 0;
	}
	if ( !maps/mp/gametypes/_weaponobjects::friendlyfirecheck( self.owner, entity, 0 ) )
	{
		return 0;
	}
	if ( distancesquared( entity.origin, self.origin ) > ( level.microwave_radius * level.microwave_radius ) )
	{
		return 0;
	}
	entdirection = vectornormalize( entity.origin - self.origin );
	forward = anglesToForward( self.angles );
	dot = vectordot( entdirection, forward );
	if ( dot < level.microwave_turret_cone_dot )
	{
		return 0;
	}
	pitchdifference = int( abs( vectorToAngle( entdirection )[ 0 ] - self.angles[ 0 ] ) ) % 360;
	if ( pitchdifference > 15 && pitchdifference < 345 )
	{
		return 0;
	}
	if ( entity damageconetrace( self.origin + vectorScale( ( 0, 0, 0 ), 40 ), self ) <= 0 )
	{
		return 0;
	}
	return 1;
}

microwaveentity( entity )
{
	entity endon( "disconnect" );
	entity.beingmicrowaved = 1;
	entity.beingmicrowavedby = self.owner;
	entity.microwaveeffect = 0;
	for ( ;; )
	{
		if ( !isDefined( self ) || !self doesmicrowaveturretaffectentity( entity ) )
		{
			if ( !isDefined( entity ) )
			{
				return;
			}
			entity.beingmicrowaved = 0;
			entity.beingmicrowavedby = undefined;
			if ( isDefined( entity.microwavepoisoning ) && entity.microwavepoisoning )
			{
				entity.microwavepoisoning = 0;
			}
			return;
		}
		damage = level.microwave_turret_damage;
		if ( level.hardcoremode )
		{
			damage /= 2;
		}
		if ( !isai( entity ) && entity mayapplyscreeneffect() )
		{
			if ( !isDefined( entity.microwavepoisoning ) || !entity.microwavepoisoning )
			{
				entity.microwavepoisoning = 1;
				entity.microwaveeffect = 0;
			}
		}
		entity dodamage( damage, self.origin, self.owner, self, 0, "MOD_TRIGGER_HURT", 0, "microwave_turret_mp" );
		entity.microwaveeffect++;
		if ( isplayer( entity ) && !entity isremotecontrolling() )
		{
			if ( ( entity.microwaveeffect % 2 ) == 1 )
			{
				if ( distancesquared( entity.origin, self.origin ) > ( ( ( level.microwave_radius * 2 ) / 3 ) * ( ( level.microwave_radius * 2 ) / 3 ) ) )
				{
					entity shellshock( "mp_radiation_low", 1,5 );
					entity viewkick( 25, self.origin );
					break;
				}
				else if ( distancesquared( entity.origin, self.origin ) > ( ( ( level.microwave_radius * 1 ) / 3 ) * ( ( level.microwave_radius * 1 ) / 3 ) ) )
				{
					entity shellshock( "mp_radiation_med", 1,5 );
					entity viewkick( 50, self.origin );
					break;
				}
				else
				{
					entity shellshock( "mp_radiation_high", 1,5 );
					entity viewkick( 75, self.origin );
				}
			}
			if ( ( entity.microwaveeffect % 3 ) == 2 )
			{
				maps/mp/_scoreevents::processscoreevent( "hpm_suppress", self.owner, entity );
			}
		}
		wait 0,5;
	}
}

turret_microwave_think( player )
{
	self endon( "death" );
	level endon( "game_ended" );
	self endon( "stop_microwave" );
	self endon( "destroy_turret" );
	wait level.auto_turret_settings[ self.turrettype ].turretinitdelay;
	trigger = spawn( "trigger_radius", self.origin + ( 0, 0, level.microwave_radius * -1 ), level.aitriggerspawnflags | level.vehicletriggerspawnflags, level.microwave_radius, level.microwave_radius * 2 );
	trigger enablelinkto();
	trigger linkto( self );
	self thread deletetriggeronparentdeath( trigger );
	self thread microwave_fx();
	self thread turret_microwave_watchfordogs( trigger, player );
	for ( ;; )
	{
		trigger waittill( "trigger", ent );
		if ( !isDefined( ent.beingmicrowaved ) || !ent.beingmicrowaved )
		{
			self thread microwaveentity( ent );
		}
	}
}

turret_microwave_watchfordogs( trigger, player )
{
	self endon( "death" );
	level endon( "game_ended" );
	self endon( "stop_microwave" );
	self endon( "destroy_turret" );
	damage = level.microwave_turret_damage;
	for ( ;; )
	{
		dogs = getentarray( "attack_dog", "targetname" );
		_a1893 = dogs;
		_k1893 = getFirstArrayKey( _a1893 );
		while ( isDefined( _k1893 ) )
		{
			dog = _a1893[ _k1893 ];
			if ( dog.aiteam == player.team )
			{
			}
			else if ( dog istouching( trigger ) == 0 )
			{
			}
			else if ( self doesmicrowaveturretaffectdog( dog ) == 0 )
			{
			}
			else
			{
				dog.flashduration = 1000;
				dog thread maps/mp/animscripts/dog_flashed::main();
				dog dodamage( damage, self.origin, self.owner, self, 0, "MOD_TRIGGER_HURT", 0, "microwave_turret_mp" );
			}
			_k1893 = getNextArrayKey( _a1893, _k1893 );
		}
		wait 0,5;
	}
}

doesmicrowaveturretaffectdog( entity )
{
	if ( !isalive( entity ) )
	{
		return 0;
	}
	if ( !isplayer( entity ) && !isai( entity ) )
	{
		return 0;
	}
	if ( isDefined( self.carried ) && self.carried )
	{
		return 0;
	}
	if ( self maps/mp/gametypes/_weaponobjects::isstunned() )
	{
		return 0;
	}
	if ( isDefined( self.owner ) && entity == self.owner )
	{
		return 0;
	}
	if ( distancesquared( entity.origin, self.origin ) > ( level.microwave_radius * level.microwave_radius ) )
	{
		return 0;
	}
	entdirection = vectornormalize( entity.origin - self.origin );
	forward = anglesToForward( self.angles );
	dot = vectordot( entdirection, forward );
	if ( dot < level.microwave_turret_cone_dot )
	{
		return 0;
	}
	pitchdifference = int( abs( vectorToAngle( entdirection )[ 0 ] - self.angles[ 0 ] ) ) % 360;
	if ( pitchdifference > 15 && pitchdifference < 345 )
	{
		return 0;
	}
	if ( entity damageconetrace( self.origin + vectorScale( ( 0, 0, 0 ), 40 ), self ) <= 0 )
	{
		return 0;
	}
	return 1;
}

microwave_fx()
{
	self endon( "death" );
	self endon( "microwave_end_fx" );
	self thread waittillendfx();
	waitamount = level.auto_turret_settings[ "microwave" ].fxchecktime;
	for ( ;; )
	{
		update_microwave_fx();
		wait waitamount;
	}
}

waittillendfx()
{
	self endon( "death" );
	self waittill( "microwave_end_fx" );
	self setclientfield( "turret_microwave_sounds", 0 );
}

update_microwave_fx()
{
	angles = self gettagangles( "tag_flash" );
	origin = self gettagorigin( "tag_flash" );
	forward = anglesToForward( angles );
	forward = vectorScale( forward, level.microwave_radius );
	forwardright = anglesToForward( angles - ( 0, level.microwave_turret_angle / 3, 0 ) );
	forwardright = vectorScale( forwardright, level.microwave_radius );
	forwardleft = anglesToForward( angles + ( 0, level.microwave_turret_angle / 3, 0 ) );
	forwardleft = vectorScale( forwardleft, level.microwave_radius );
	trace = bullettrace( origin, origin + forward, 0, self );
	traceright = bullettrace( origin, origin + forwardright, 0, self );
	traceleft = bullettrace( origin, origin + forwardleft, 0, self );
	fxhash = self microwave_fx_hash( trace, origin );
	fxhashright = self microwave_fx_hash( traceright, origin );
	fxhashleft = self microwave_fx_hash( traceleft, origin );
	if ( isDefined( self.microwavefxhash ) && self.microwavefxhash == fxhash && isDefined( self.microwavefxhashright ) && self.microwavefxhashright == fxhashright && isDefined( self.microwavefxhashleft ) && self.microwavefxhashleft == fxhashleft )
	{
		return;
	}
	if ( isDefined( self.microwavefxent ) )
	{
		self.microwavefxent deleteaftertime( 0,1 );
	}
	self.microwavefxent = spawn( "script_model", origin );
	self.microwavefxent setmodel( "tag_microwavefx" );
	self.microwavefxent.angles = angles;
	self thread deleteonendfx();
	self.microwavefxhash = fxhash;
	self.microwavefxhashright = fxhashright;
	self.microwavefxhashleft = fxhashleft;
	wait 0,1;
	self.microwavefxent microwave_play_fx( trace, traceright, traceleft, origin );
	self setclientfield( "turret_microwave_sounds", 1 );
}

deleteonendfx()
{
	self.microwavefxent endon( "death" );
	self waittill( "microwave_end_fx" );
	self.microwavefxhash = undefined;
	self.microwavefxhashright = undefined;
	self.microwavefxhashleft = undefined;
	if ( isDefined( self.microwavefxent ) )
	{
		self.microwavefxent delete();
	}
}

microwave_fx_hash( trace, origin )
{
	hash = 0;
	counter = 1;
	i = 0;
	while ( i < 5 )
	{
		distsq = ( i * level.microwave_fx_size ) * ( i * level.microwave_fx_size );
		if ( distancesquared( origin, trace[ "position" ] ) >= distsq )
		{
			hash += counter;
		}
		counter *= 2;
		i++;
	}
	return hash;
}

microwave_play_fx( trace, traceright, traceleft, origin )
{
	rows = 5;
	i = 0;
	while ( i < rows )
	{
		distsq = ( i * level.microwave_fx_size ) * ( i * level.microwave_fx_size );
		if ( distancesquared( origin, trace[ "position" ] ) >= distsq )
		{
			switch( i )
			{
				case 0:
					playfxontag( level.auto_turret_settings[ "microwave" ].fx, self, "tag_fx11" );
					wait 0,05;
					break;
				break;
				case 1:
					case 2:
						playfxontag( level.auto_turret_settings[ "microwave" ].fx, self, "tag_fx32" );
						wait 0,05;
						break;
					break;
					case 3:
						playfxontag( level.auto_turret_settings[ "microwave" ].fx, self, "tag_fx42" );
						wait 0,05;
						playfxontag( level.auto_turret_settings[ "microwave" ].fx, self, "tag_fx43" );
						wait 0,05;
						break;
					break;
					case 4:
						playfxontag( level.auto_turret_settings[ "microwave" ].fx, self, "tag_fx53" );
						wait 0,05;
						break;
					break;
				}
			}
			if ( distancesquared( origin, traceleft[ "position" ] ) >= distsq )
			{
				switch( i )
				{
					case 0:
						break;
					break;
					case 1:
						playfxontag( level.auto_turret_settings[ "microwave" ].fx, self, "tag_fx22" );
						wait 0,05;
						break;
					break;
					case 2:
						playfxontag( level.auto_turret_settings[ "microwave" ].fx, self, "tag_fx33" );
						wait 0,05;
						break;
					break;
					case 3:
						playfxontag( level.auto_turret_settings[ "microwave" ].fx, self, "tag_fx44" );
						wait 0,05;
						break;
					break;
					case 4:
						playfxontag( level.auto_turret_settings[ "microwave" ].fx, self, "tag_fx54" );
						wait 0,05;
						playfxontag( level.auto_turret_settings[ "microwave" ].fx, self, "tag_fx55" );
						wait 0,05;
						break;
					break;
				}
			}
			if ( distancesquared( origin, traceright[ "position" ] ) >= distsq )
			{
				switch( i )
				{
					case 0:
						break;
					i++;
					continue;
					case 1:
						playfxontag( level.auto_turret_settings[ "microwave" ].fx, self, "tag_fx21" );
						wait 0,05;
						break;
					i++;
					continue;
					case 2:
						playfxontag( level.auto_turret_settings[ "microwave" ].fx, self, "tag_fx31" );
						wait 0,05;
						break;
					i++;
					continue;
					case 3:
						playfxontag( level.auto_turret_settings[ "microwave" ].fx, self, "tag_fx41" );
						wait 0,05;
						break;
					i++;
					continue;
					case 4:
						playfxontag( level.auto_turret_settings[ "microwave" ].fx, self, "tag_fx51" );
						wait 0,05;
						playfxontag( level.auto_turret_settings[ "microwave" ].fx, self, "tag_fx52" );
						wait 0,05;
						break;
					i++;
					continue;
				}
			}
			i++;
		}
	}
}

do_tow_shoot( player )
{
	self endon( "turret_deactivated" );
	self endon( "death" );
	player endon( "disconnect" );
	self endon( "target_lost" );
	level endon( "game_ended" );
	while ( 1 )
	{
		while ( self.firetime < level.auto_turret_settings[ "tow" ].turretfiredelay )
		{
			wait 0,1;
			self.firetime += 0,1;
		}
		self playsound( "wpn_sam_launcher_rocket_npc" );
		self shootturret();
		self.firetime = 0;
	}
}

missile_fired_notify()
{
	self endon( "turret_deactivated" );
	self endon( "death" );
	level endon( "game_ended" );
	if ( isDefined( self.owner ) )
	{
		self.owner endon( "disconnect" );
	}
	while ( 1 )
	{
		self waittill( "missile_fire", missile, weap, target );
		if ( isDefined( target ) )
		{
			target notify( "stinger_fired_at_me" );
		}
		level notify( "missile_fired" );
	}
}

spawnturrethackertrigger( player )
{
	triggerorigin = self.origin + vectorScale( ( 0, 0, 0 ), 10 );
	self.hackertrigger = spawn( "trigger_radius_use", triggerorigin, level.weaponobjects_hacker_trigger_width, level.weaponobjects_hacker_trigger_height );
/#
#/
	self.hackertrigger setcursorhint( "HINT_NOICON", self );
	self.hackertrigger setignoreentfortrigger( self );
	self.hackertrigger sethintstring( level.auto_turret_settings[ self.turrettype ].hackerhintstring );
	self.hackertrigger setperkfortrigger( "specialty_disarmexplosive" );
	self.hackertrigger thread maps/mp/gametypes/_weaponobjects::hackertriggersetvisibility( player );
	self thread hackerthink( self.hackertrigger, player );
}

hackerthink( trigger, owner )
{
	self endon( "death" );
	for ( ;; )
	{
		trigger waittill( "trigger", player, instant );
		if ( !isDefined( instant ) && !trigger maps/mp/gametypes/_weaponobjects::hackerresult( player, owner ) )
		{
			continue;
		}
		else
		{
			if ( self.turrettype == "sentry" )
			{
				maps/mp/killstreaks/_killstreakrules::killstreakstop( "autoturret_mp", self.team, self.killstreak_id );
				killstreak_id = player maps/mp/killstreaks/_killstreakrules::killstreakstart( "autoturret_mp", player.team, 1 );
				self.killstreak_id = killstreak_id;
			}
			else if ( self.turrettype == "tow" )
			{
				maps/mp/killstreaks/_killstreakrules::killstreakstop( "auto_tow_mp", self.team, self.killstreak_id );
				killstreak_id = player maps/mp/killstreaks/_killstreakrules::killstreakstart( "auto_tow_mp", player.team, 1 );
				self.killstreak_id = killstreak_id;
			}
			else
			{
				if ( self.turrettype == "microwave" )
				{
					maps/mp/killstreaks/_killstreakrules::killstreakstop( "microwaveturret_mp", self.team, self.killstreak_id );
					killstreak_id = player maps/mp/killstreaks/_killstreakrules::killstreakstart( "microwaveturret_mp", player.team, 1 );
					self.killstreak_id = killstreak_id;
				}
			}
			maps/mp/_scoreevents::processscoreevent( "hacked", player, self );
			if ( self.turrettype == "sentry" )
			{
				owner maps/mp/gametypes/_globallogic_audio::leaderdialogonplayer( "sentry_hacked", "item_destroyed" );
			}
			if ( self.turrettype == "microwave" )
			{
				owner maps/mp/gametypes/_globallogic_audio::leaderdialogonplayer( "microwave_hacked", "item_destroyed" );
			}
			if ( level.teambased )
			{
				self setturretteam( player.team );
				self.team = player.team;
			}
			else
			{
				self setturretteam( "free" );
				self.team = "free";
			}
			if ( isDefined( self.owner ) && isDefined( self.owner.remoteweapon ) )
			{
				if ( self.owner.remoteweapon == self )
				{
					self.owner notify( "remove_remote_weapon" );
				}
			}
			self.hacked = 1;
			self setturretowner( player );
			self.owner = player;
			self notify( "hacked" );
			level notify( "hacked" );
			self deleteturretusetrigger();
			wait 0,1;
			self thread stunturrettacticalgrenade( 1,5 );
			wait 1,5;
			if ( isDefined( player ) && player.sessionstate == "playing" )
			{
				player thread watchownerdisconnect( self );
				player thread watchownerteamkillkicked( self );
			}
			offset = level.turrets_headicon_offset[ "default" ];
			if ( isDefined( level.turrets_headicon_offset[ self.turrettype ] ) )
			{
				offset = level.turrets_headicon_offset[ self.turrettype ];
			}
			self maps/mp/_entityheadicons::setentityheadicon( player.pers[ "team" ], player, offset );
			self spawnturrethackertrigger( player );
			if ( self.turrettype == "sentry" )
			{
				player maps/mp/killstreaks/_remote_weapons::initremoteweapon( self, "killstreak_remote_turret_mp" );
			}
			return;
		}
	}
}

spawnturretdisabletrigger( player )
{
	triggerorigin = self.origin + vectorScale( ( 0, 0, 0 ), 10 );
	self.disabletrigger = spawn( "trigger_radius_use", triggerorigin, level.weaponobjects_hacker_trigger_width, level.weaponobjects_hacker_trigger_height );
	self.disabletrigger setcursorhint( "HINT_NOICON", self );
	self.disabletrigger setignoreentfortrigger( self );
	self.disabletrigger sethintstring( level.auto_turret_settings[ self.turrettype ].disablehintstring );
	self.disabletrigger thread maps/mp/gametypes/_weaponobjects::hackertriggersetvisibility( player );
	self thread disabletriggerthink( self.disabletrigger, player );
}

disabletriggerthink( trigger, owner )
{
	self endon( "death" );
	for ( ;; )
	{
		trigger waittill( "trigger", attacker );
		if ( !trigger disableresult( attacker, owner ) )
		{
			continue;
		}
		else
		{
			if ( self isenemyplayer( attacker ) )
			{
				if ( self.turrettype == "sentry" )
				{
					maps/mp/_scoreevents::processscoreevent( "destroyed_sentry_gun", attacker, self, "knife_mp" );
				}
				else
				{
					if ( self.turrettype == "microwave" )
					{
						maps/mp/_scoreevents::processscoreevent( "destroyed_microwave_turret", attacker, self, "knife_mp" );
					}
				}
				if ( isDefined( self.hardpointweapon ) )
				{
					level.globalkillstreaksdestroyed++;
					attacker addweaponstat( self.hardpointweapon, "destroyed", 1 );
				}
			}
			if ( isDefined( self.owner ) && isplayer( self.owner ) )
			{
				owner = self.owner;
				if ( self.turrettype == "sentry" )
				{
					owner maps/mp/gametypes/_globallogic_audio::leaderdialogonplayer( "sentry_destroyed", "item_destroyed" );
				}
			}
			self notify( "destroy_turret" );
		}
	}
}

disableresult( player, owner )
{
	success = 1;
	time = getTime();
	hacktime = getDvarFloat( "perk_disarmExplosiveTime" );
	if ( !candisable( player, owner, 1 ) )
	{
		return 0;
	}
	self thread hackerunfreezeplayer( player );
	while ( ( time + ( hacktime * 1000 ) ) > getTime() )
	{
		if ( !candisable( player, owner, 0 ) )
		{
			success = 0;
			break;
		}
		else if ( !player usebuttonpressed() )
		{
			success = 0;
			break;
		}
		else if ( !isDefined( self ) )
		{
			success = 0;
			break;
		}
		else
		{
			player freeze_player_controls( 1 );
			player disableweapons();
			if ( !isDefined( self.progressbar ) )
			{
				self.progressbar = player createprimaryprogressbar();
				self.progressbar.lastuserate = -1;
				self.progressbar showelem();
				self.progressbar updatebar( 0,01, 1 / hacktime );
				self.progresstext = player createprimaryprogressbartext();
				self.progresstext settext( &"MP_DISABLING" );
				self.progresstext showelem();
				player playlocalsound( "evt_hacker_hacking" );
			}
			wait 0,05;
		}
	}
	if ( isDefined( player ) )
	{
		player freeze_player_controls( 0 );
		player enableweapons();
	}
	if ( isDefined( self.progressbar ) )
	{
		self.progressbar destroyelem();
		self.progresstext destroyelem();
	}
	if ( isDefined( self ) )
	{
		self notify( "hack_done" );
	}
	return success;
}

candisable( player, owner, weapon_check )
{
	if ( !isDefined( player ) )
	{
		return 0;
	}
	if ( !isplayer( player ) )
	{
		return 0;
	}
	if ( !isalive( player ) )
	{
		return 0;
	}
	if ( !isDefined( owner ) )
	{
		return 0;
	}
	if ( owner == player )
	{
		return 0;
	}
	if ( level.teambased && player.team == owner.team )
	{
		return 0;
	}
	if ( isDefined( player.isdefusing ) && player.isdefusing )
	{
		return 0;
	}
	if ( isDefined( player.isplanting ) && player.isplanting )
	{
		return 0;
	}
	if ( isDefined( player.proxbar ) && !player.proxbar.hidden )
	{
		return 0;
	}
	if ( isDefined( player.revivingteammate ) && player.revivingteammate == 1 )
	{
		return 0;
	}
	if ( !player isonground() )
	{
		return 0;
	}
	if ( player isinvehicle() )
	{
		return 0;
	}
	if ( player isweaponviewonlylinked() )
	{
		return 0;
	}
	if ( player hasperk( "specialty_disarmexplosive" ) )
	{
		return 0;
	}
	if ( isDefined( player.laststand ) && player.laststand )
	{
		return 0;
	}
	if ( weapon_check )
	{
		if ( player isthrowinggrenade() )
		{
			return 0;
		}
		if ( player isswitchingweapons() )
		{
			return 0;
		}
		if ( player ismeleeing() )
		{
			return 0;
		}
		weapon = player getcurrentweapon();
		if ( !isDefined( weapon ) )
		{
			return 0;
		}
		if ( weapon == "none" )
		{
			return 0;
		}
		if ( isweaponequipment( weapon ) && player isfiring() )
		{
			return 0;
		}
		if ( isweaponspecificuse( weapon ) )
		{
			return 0;
		}
	}
	return 1;
}

turretscanstartwaiter()
{
	self endon( "turret_deactivated" );
	self endon( "death" );
	self endon( "turret_carried" );
	level endon( "game_ended" );
	turret_scan_start_sound_ent = spawn( "script_origin", self.origin );
	turret_scan_start_sound_ent linkto( self, "tag_origin", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	self thread turretscanstopwaiter( turret_scan_start_sound_ent );
	self thread turretscanstopwaitercleanup( turret_scan_start_sound_ent );
	while ( 1 )
	{
		self waittill( "turret_scan_start" );
		wait 0,5;
	}
}

turretscanstopwaiter( ent )
{
	self endon( "turret_sound_cleanup" );
	level endon( "game_ended" );
	while ( 1 )
	{
		self waittill( "turret_scan_stop" );
		wait 0,5;
	}
}

turretscanstopwaitercleanup( ent )
{
	level endon( "game_ended" );
	self waittill_any( "death", "disconnect", "turret_deactivated" );
	self notify( "turret_sound_cleanup" );
	wait 0,1;
/#
	println( "snd scan delete" );
#/
	if ( isDefined( ent ) )
	{
		ent delete();
	}
}

turretscanstopnotify()
{
}

startturretremotecontrol( turret )
{
	self.killstreak_waitamount = level.auto_turret_timeout * 1000;
	turret maketurretusable();
	arc_limits = turret getturretarclimits();
	self playerlinkweaponviewtodelta( turret, "tag_player", 0, arc_limits[ "arc_max_yaw" ], arc_limits[ "arc_min_yaw" ] * -1, arc_limits[ "arc_min_pitch" ] * -1, arc_limits[ "arc_max_pitch" ] );
	self playerlinkedsetusebaseangleforviewclamp( 1 );
	self remotecontrolturret( turret );
	turret laseron();
	turret.remotecontrolled = 1;
	turret setmode( "manual" );
	self thread watchremotesentryfire( turret );
}

watchremotesentryfire( turret )
{
	self endon( "stopped_using_remote" );
	turret endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	while ( 1 )
	{
		if ( self attackbuttonpressed() && turret.stunnedbytacticalgrenade == 0 )
		{
			firetime = weaponfiretime( "auto_gun_turret_mp" );
			earthquake( 0,15, 0,2, turret.origin, 200 );
			wait firetime;
			continue;
		}
		else
		{
			wait 0,05;
		}
	}
}

endremoteturret( turret, isdead )
{
	if ( isDefined( self ) && isDefined( turret ) && turret.remotecontrolled )
	{
		self remotecontrolturretoff( turret );
		self remove_turret_hint_hud();
	}
	turret maketurretunusable();
	turret laseroff();
	turret.remotecontrolled = 0;
	turret setmode( "auto_nonai" );
	if ( !isdead )
	{
		turret thread maps/mp/_mgturret::burst_fire_unmanned();
	}
}

stop_remote()
{
	if ( !isDefined( self ) )
	{
		return;
	}
	self clearusingremote();
	self.killstreak_waitamount = undefined;
	self maps/mp/killstreaks/_ai_tank::destroy_remote_hud();
	self remove_turret_hint_hud();
}

create_remote_turret_hud( remote )
{
	self.fire_turret_hud = newclienthudelem( self );
	self.fire_turret_hud.alignx = "left";
	self.fire_turret_hud.aligny = "bottom";
	self.fire_turret_hud.horzalign = "user_left";
	self.fire_turret_hud.vertalign = "user_bottom";
	self.fire_turret_hud.font = "small";
	self.fire_turret_hud settext( &"MP_FIRE_SENTRY_GUN" );
	self.fire_turret_hud.hidewheninmenu = 1;
	self.fire_turret_hud.hidewhenindemo = 1;
	self.fire_turret_hud.archived = 0;
	self.fire_turret_hud.x = 25;
	self.fire_turret_hud.y = -25;
	self.fire_turret_hud.fontscale = 1,25;
	self.zoom_turret_hud = newclienthudelem( self );
	self.zoom_turret_hud.alignx = "left";
	self.zoom_turret_hud.aligny = "bottom";
	self.zoom_turret_hud.horzalign = "user_left";
	self.zoom_turret_hud.vertalign = "user_bottom";
	self.zoom_turret_hud.font = "small";
	self.zoom_turret_hud settext( &"KILLSTREAK_INCREASE_ZOOM" );
	self.zoom_turret_hud.hidewheninmenu = 1;
	self.zoom_turret_hud.hidewhenindemo = 1;
	self.zoom_turret_hud.archived = 0;
	self.zoom_turret_hud.x = 25;
	self.zoom_turret_hud.y = -40;
	self.zoom_turret_hud.fontscale = 1,25;
	self thread fade_out_hint_hud();
}

fade_out_hint_hud()
{
	wait 8;
	time = 0;
	while ( time < 2 )
	{
		if ( !isDefined( self.fire_turret_hud ) )
		{
			return;
		}
		self.fire_turret_hud.alpha -= 0,025;
		self.zoom_turret_hud.alpha -= 0,025;
		time += 0,05;
		wait 0,05;
	}
	self.fire_turret_hud.alpha = 0;
	self.zoom_turret_hud.alpha = 0;
}

remove_turret_hint_hud()
{
	if ( isDefined( self.fire_turret_hud ) )
	{
		self.fire_turret_hud destroy();
	}
	if ( isDefined( self.zoom_turret_hud ) )
	{
		self.zoom_turret_hud destroy();
	}
}

remove_turret_dangerous_nodes()
{
	while ( isDefined( self.dangerous_nodes ) )
	{
		_a2744 = self.dangerous_nodes;
		_k2744 = getFirstArrayKey( _a2744 );
		while ( isDefined( _k2744 ) )
		{
			node = _a2744[ _k2744 ];
			_a2746 = level.teams;
			_k2746 = getFirstArrayKey( _a2746 );
			while ( isDefined( _k2746 ) )
			{
				team = _a2746[ _k2746 ];
				node setdangerous( team, 0 );
				_k2746 = getNextArrayKey( _a2746, _k2746 );
			}
			_k2744 = getNextArrayKey( _a2744, _k2744 );
		}
	}
	self.dangerous_nodes = [];
}

addnoturrettrigger( position, radius, height )
{
	level waittill( "no_turret_trigger_created" );
	trigger = spawn( "trigger_radius", position, 0, radius, height );
	level.noturretplacementtriggers[ level.noturretplacementtriggers.size ] = trigger;
}

turret_debug_box( origin, mins, maxs, color )
{
/#
	debug_turret = getDvar( #"94A738D1" );
	if ( debug_turret == "1" )
	{
		box( origin, mins, maxs, 0, color, 1, 1, 300 );
#/
	}
}

turret_debug_line( start, end, color )
{
/#
	debug_turret = getDvar( #"94A738D1" );
	if ( debug_turret == "1" )
	{
		line( start, end, color, 1, 1, 300 );
#/
	}
}
