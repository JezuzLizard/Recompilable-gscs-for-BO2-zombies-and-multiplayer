#include maps/mp/killstreaks/_dogs;
#include maps/mp/_challenges;
#include maps/mp/_scoreevents;
#include maps/mp/_heatseekingmissile;
#include maps/mp/_vehicles;
#include maps/mp/killstreaks/_killstreakrules;
#include maps/mp/killstreaks/_killstreaks;
#include maps/mp/gametypes/_battlechatter_mp;
#include maps/mp/killstreaks/_airsupport;
#include common_scripts/utility;
#include maps/mp/_utility;

init()
{
	level.straferunnumrockets = 7;
	level.straferunrocketdelay = 0,35;
	level.straferungunlookahead = 4000;
	level.straferungunoffset = -800;
	level.straferungunradius = 500;
	level.straferunexitunits = 20000;
	level.straferunmaxstrafes = 4;
	level.straferunflaredelay = 2;
	level.straferunshellshockduration = 2,5;
	level.straferunshellshockradius = 512;
	level.straferunkillsbeforeexit = 10;
	level.straferunnumkillcams = 5;
	level.straferunmodel = "veh_t6_air_a10f";
	level.straferunmodelenemy = "veh_t6_air_a10f_alt";
	level.straferunvehicle = "vehicle_straferun_mp";
	level.straferungunweapon = "straferun_gun_mp";
	level.straferungunsound = "wpn_a10_shot_loop_npc";
	level.straferunrocketweapon = "straferun_rockets_mp";
	level.straferunrockettags = [];
	level.straferunrockettags[ 0 ] = "tag_rocket_left";
	level.straferunrockettags[ 1 ] = "tag_rocket_right";
	level.straferuncontrailfx = loadfx( "vehicle/exhaust/fx_exhaust_a10_contrail" );
	level.straferunchafffx = loadfx( "weapon/straferun/fx_straferun_chaf" );
	level.straferunexplodefx = loadfx( "vehicle/vexplosion/fx_vexplode_vtol_mp" );
	level.straferunexplodesound = "evt_helicopter_midair_exp";
	level.straferunshellshock = "straferun";
	precachemodel( level.straferunmodel );
	precachemodel( level.straferunmodelenemy );
	precachevehicle( level.straferunvehicle );
	precacheitem( level.straferungunweapon );
	precacheitem( level.straferunrocketweapon );
	precacheshellshock( level.straferunshellshock );
	maps/mp/killstreaks/_killstreaks::registerkillstreak( "straferun_mp", "straferun_mp", "killstreak_straferun", "straferun_used", ::usekillstreakstraferun, 1 );
	maps/mp/killstreaks/_killstreaks::registerkillstreakstrings( "straferun_mp", &"MP_EARNED_STRAFERUN", &"KILLSTREAK_STRAFERUN_NOT_AVAILABLE", &"MP_WAR_STRAFERUN_INBOUND", &"MP_WAR_STRAFERUN_INBOUND_NEAR_YOUR_POSITION" );
	maps/mp/killstreaks/_killstreaks::registerkillstreakdialog( "straferun_mp", "mpl_killstreak_straferun", "kls_straferun_used", "", "kls_straferun_enemy", "", "kls_straferun_ready" );
	maps/mp/killstreaks/_killstreaks::registerkillstreakdevdvar( "straferun_mp", "scr_givestraferun" );
	maps/mp/killstreaks/_killstreaks::registerkillstreakaltweapon( "straferun_mp", level.straferungunweapon );
	maps/mp/killstreaks/_killstreaks::registerkillstreakaltweapon( "straferun_mp", level.straferunrocketweapon );
	maps/mp/killstreaks/_killstreaks::setkillstreakteamkillpenaltyscale( "straferun_mp", 0 );
	createkillcams( level.straferunnumkillcams, level.straferunnumrockets );
}

playpilotdialog( dialog )
{
	soundalias = level.teamprefix[ self.team ] + self.pilotvoicenumber + "_" + dialog;
	while ( isDefined( self.owner ) )
	{
		while ( self.owner.pilotisspeaking )
		{
			while ( self.owner.pilotisspeaking )
			{
				wait 0,2;
			}
		}
	}
	if ( isDefined( self.owner ) )
	{
		self.owner playlocalsound( soundalias );
		self.owner.pilotisspeaking = 1;
		self.owner thread waitplaybacktime( soundalias );
		self.owner waittill_any( soundalias, "death", "disconnect" );
		if ( isDefined( self.owner ) )
		{
			self.owner.pilotisspeaking = 0;
		}
	}
}

usekillstreakstraferun( hardpointtype )
{
	startnode = getvehiclenode( "warthog_start", "targetname" );
	if ( !isDefined( startnode ) )
	{
/#
		println( "ERROR: Strafe run vehicle spline not found!" );
#/
		return 0;
	}
	killstreak_id = self maps/mp/killstreaks/_killstreakrules::killstreakstart( "straferun_mp", self.team, 0, 1 );
	if ( killstreak_id == -1 )
	{
		return 0;
	}
	plane = spawnvehicle( level.straferunmodel, "straferun", level.straferunvehicle, startnode.origin, ( 0, 0, 0 ) );
	plane.attackers = [];
	plane.attackerdata = [];
	plane.attackerdamage = [];
	plane.flareattackerdamage = [];
	plane setvehicleteam( self.team );
	plane setenemymodel( level.straferunmodelenemy );
	plane.team = self.team;
	plane makevehicleunusable();
	plane thread cleanupondeath();
	plane.health = 999999;
	plane.maxhealth = 999999;
	plane setowner( self );
	plane.owner = self;
	plane.numstrafes = 0;
	plane.killstreak_id = killstreak_id;
	plane.numflares = 2;
	plane.fx_flare = loadfx( "weapon/straferun/fx_straferun_chaf" );
	plane.soundmod = "straferun";
	plane setdrawinfrared( 1 );
	self.straferunkills = 0;
	self.straferunbda = 0;
	self.pilotisspeaking = 0;
	plane.pilotvoicenumber = self.bcvoicenumber + 1;
	if ( plane.pilotvoicenumber > 3 )
	{
		plane.pilotvoicenumber = 0;
	}
	self maps/mp/killstreaks/_killstreaks::playkillstreakstartdialog( "straferun_mp", self.pers[ "team" ] );
	level.globalkillstreakscalled++;
	self addweaponstat( "straferun_mp", "used", 1 );
	plane thread pilotdialogwait( "a10_used", 2,5 );
	target_set( plane, ( 0, 0, 0 ) );
	target_setturretaquire( plane, 0 );
	plane thread playcontrail();
	plane.gunsoundentity = spawn( "script_model", plane gettagorigin( "tag_flash" ) );
	plane.gunsoundentity linkto( plane, "tag_flash", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	plane resetkillcams();
	plane thread watchforotherkillstreaks();
	plane thread watchforkills();
	plane thread watchdamage();
	plane thread dostraferuns();
	plane thread maps/mp/_vehicles::follow_path( startnode );
	plane thread maps/mp/_heatseekingmissile::missiletarget_proximitydetonateincomingmissile( "death" );
	plane thread watchforownerexit( self );
	return 1;
}

playcontrail()
{
	self endon( "death" );
	wait 0,1;
	playfxontag( level.straferuncontrailfx, self, "tag_origin" );
	self playloopsound( "veh_a10_engine_loop", 1 );
}

cleanupondeath()
{
	self waittill( "death" );
	maps/mp/killstreaks/_killstreakrules::killstreakstop( "straferun_mp", self.team, self.killstreak_id );
	if ( isDefined( self.gunsoundentity ) )
	{
		self.gunsoundentity stoploopsound();
		self.gunsoundentity delete();
		self.gunsoundentity = undefined;
	}
}

watchdamage()
{
	self endon( "death" );
	self.maxhealth = 999999;
	self.health = self.maxhealth;
	self.maxhealth = 1000;
	low_health = 0;
	damage_taken = 0;
	for ( ;; )
	{
		self waittill( "damage", damage, attacker, dir, point, mod, model, tag, part, weapon, flags );
		if ( !isDefined( attacker ) || !isplayer( attacker ) )
		{
			continue;
		}
		else
		{
/#
			self.damage_debug = ( damage + " (" ) + weapon + ")";
#/
			if ( mod != "MOD_PROJECTILE" || mod == "MOD_PROJECTILE_SPLASH" && mod == "MOD_EXPLOSIVE" )
			{
				damage += 1000;
			}
			self.attacker = attacker;
			damage_taken += damage;
			if ( damage_taken >= 1000 )
			{
				self thread explode();
				if ( self.owner isenemyplayer( attacker ) )
				{
					maps/mp/_scoreevents::processscoreevent( "destroyed_strafe_run", attacker, self.owner, weapon );
					attacker maps/mp/_challenges::addflyswatterstat( weapon, self );
					break;
				}
				return;
			}
		}
	}
}

watchforotherkillstreaks()
{
	self endon( "death" );
	for ( ;; )
	{
		level waittill( "killstreak_started", hardpointtype, teamname, attacker );
		if ( !isDefined( self.owner ) )
		{
			self thread explode();
			return;
		}
		if ( hardpointtype == "emp_mp" )
		{
			if ( self.owner isenemyplayer( attacker ) )
			{
				self thread explode();
				maps/mp/_scoreevents::processscoreevent( "destroyed_strafe_run", attacker, self.owner, hardpointtype );
				attacker maps/mp/_challenges::addflyswatterstat( hardpointtype, self );
				return;
			}
			continue;
		}
		else
		{
			if ( hardpointtype == "missile_swarm_mp" )
			{
				if ( self.owner isenemyplayer( attacker ) )
				{
					self.leavenexttime = 1;
				}
			}
		}
	}
}

watchforkills()
{
	self endon( "death" );
	for ( ;; )
	{
		self waittill( "killed", player );
		if ( isplayer( player ) )
		{
			break;
		}
	}
}

watchforownerexit( owner )
{
	self endon( "death" );
	owner waittill_any( "disconnect", "joined_team", "joined_spectator" );
	self.leavenexttime = 1;
}

addstraferunkill()
{
	if ( !isDefined( self.straferunkills ) )
	{
		self.straferunkills = 0;
	}
	self.straferunkills++;
}

dostraferuns()
{
	self endon( "death" );
	for ( ;; )
	{
		self waittill( "noteworthy", noteworthy, noteworthynode );
		if ( noteworthy == "strafe_start" )
		{
			self.straferungunlookahead = level.straferungunlookahead;
			self.straferungunradius = level.straferungunradius;
			self.straferungunoffset = level.straferungunoffset;
/#
			self.straferungunlookahead = getdvarintdefault( 3757700558, level.straferungunlookahead );
			self.straferungunradius = getdvarintdefault( 1960308846, level.straferungunradius );
			self.straferungunoffset = getdvarintdefault( 1848914509, level.straferungunoffset );
#/
			if ( isDefined( noteworthynode ) )
			{
				if ( isDefined( noteworthynode.script_parameters ) )
				{
					self.straferungunlookahead = float( noteworthynode.script_parameters );
				}
				if ( isDefined( noteworthynode.script_radius ) )
				{
					self.straferungunradius = float( noteworthynode.script_radius );
				}
				if ( isDefined( noteworthynode.script_float ) )
				{
					self.straferungunoffset = float( noteworthynode.script_float );
				}
			}
			if ( isDefined( self.owner ) )
			{
				self thread startstrafe();
			}
			continue;
		}
		else if ( noteworthy == "strafe_stop" )
		{
			self stopstrafe();
			continue;
		}
		else if ( noteworthy == "strafe_leave" )
		{
			if ( self shouldleavemap() )
			{
				self thread leavemap();
				self thread pilotdialogwait( "a10_leave", 5 );
				break;
			}
			else
			{
				self thread pilotdialogwait( "a10_strafe", 3 );
			}
		}
	}
}

fireflares()
{
	self endon( "death" );
	self endon( "strafe_start" );
	wait 0,1;
	for ( ;; )
	{
		chaff_fx = spawn( "script_model", self.origin );
		chaff_fx.angles = vectorScale( ( 0, 0, 0 ), 180 );
		chaff_fx setmodel( "tag_origin" );
		chaff_fx linkto( self, "tag_origin", ( 0, 0, 0 ), ( 0, 0, 0 ) );
		wait 0,1;
		playfxontag( level.straferunchafffx, chaff_fx, "tag_origin" );
		chaff_fx playsound( "wpn_a10_drop_chaff" );
		chaff_fx thread deleteaftertimethread( level.straferunflaredelay );
		wait level.straferunflaredelay;
	}
}

startstrafe()
{
	self endon( "death" );
	self endon( "strafe_stop" );
	if ( isDefined( self.strafing ) )
	{
		iprintlnbold( "TRYING TO STRAFE WHEN ALREADY STRAFING!\n" );
		return;
	}
	self.strafing = 1;
	self thread pilotdialogwait( "kls_hit", 3,5 );
	if ( self.numstrafes == 0 )
	{
		self firststrafe();
	}
	self thread firerockets();
	self thread startstrafekillcams();
	count = 0;
	weaponshoottime = weaponfiretime( level.straferungunweapon );
	for ( ;; )
	{
		gunorigin = self gettagorigin( "tag_flash" );
		gunorigin += ( 0, 0, self.straferungunoffset );
		forward = anglesToForward( self.angles );
		forwardnoz = vectornormalize( ( forward[ 0 ], forward[ 1 ], 0 ) );
		right = vectorcross( forwardnoz, ( 0, 0, 0 ) );
		perfectattackstartvector = gunorigin + vectorScale( forwardnoz, self.straferungunlookahead );
		attackstartvector = perfectattackstartvector + vectorScale( right, randomfloatrange( 0 - self.straferungunradius, self.straferungunradius ) );
		trace = bullettrace( attackstartvector, ( attackstartvector[ 0 ], attackstartvector[ 1 ], -500 ), 0, self, 0, 1 );
		self setturrettargetvec( trace[ "position" ] );
		self fireweapon( "tag_flash" );
		self.gunsoundentity playloopsound( level.straferungunsound );
		self shellshockplayers( trace[ "position" ] );
/#
		if ( getdvarintdefault( 3044406805, 0 ) )
		{
			time = 300;
			debug_line( attackstartvector, trace[ "position" ] - vectorScale( ( 0, 0, 0 ), 20 ), ( 0, 0, 0 ), time, 0 );
			if ( ( count % 30 ) == 0 )
			{
				trace = bullettrace( perfectattackstartvector, ( perfectattackstartvector[ 0 ], perfectattackstartvector[ 1 ], -100000 ), 0, self, 0, 1 );
				debug_line( trace[ "position" ] + vectorScale( ( 0, 0, 0 ), 20 ), trace[ "position" ] - vectorScale( ( 0, 0, 0 ), 20 ), ( 0, 0, 0 ), time, 0 );
#/
			}
		}
		count++;
		wait weaponshoottime;
	}
}

firststrafe()
{
}

firerockets()
{
	self notify( "firing_rockets" );
	self endon( "death" );
	self endon( "strafe_stop" );
	self endon( "firing_rockets" );
	self.owner endon( "disconnect" );
	forward = anglesToForward( self.angles );
	self.firedrockettargets = [];
	rocketindex = 0;
	while ( rocketindex < level.straferunnumrockets )
	{
		rockettag = level.straferunrockettags[ rocketindex % level.straferunrockettags.size ];
		targets = getvalidtargets();
		rocketorigin = self gettagorigin( rockettag );
		targetorigin = rocketorigin + ( forward * 10000 );
		if ( targets.size > 0 )
		{
			selectedtarget = undefined;
			_a494 = targets;
			_k494 = getFirstArrayKey( _a494 );
			while ( isDefined( _k494 ) )
			{
				target = _a494[ _k494 ];
				alreadyattacked = 0;
				_a497 = self.firedrockettargets;
				_k497 = getFirstArrayKey( _a497 );
				while ( isDefined( _k497 ) )
				{
					oldtarget = _a497[ _k497 ];
					if ( oldtarget == target )
					{
						alreadyattacked = 1;
						break;
					}
					else
					{
						_k497 = getNextArrayKey( _a497, _k497 );
					}
				}
				if ( !alreadyattacked )
				{
					selectedtarget = target;
					break;
				}
				else
				{
					_k494 = getNextArrayKey( _a494, _k494 );
				}
			}
			if ( isDefined( selectedtarget ) )
			{
				self.firedrockettargets[ self.firedrockettargets.size ] = selectedtarget;
				targetorigin = deadrecontargetorigin( rocketorigin, selectedtarget );
			}
		}
		rocketorigin = self gettagorigin( rockettag );
		rocket = magicbullet( level.straferunrocketweapon, rocketorigin, rocketorigin + forward, self.owner );
		if ( isDefined( selectedtarget ) )
		{
			rocket missile_settarget( selectedtarget, ( 0, 0, 0 ) );
		}
		rocket.soundmod = "straferun";
		rocket attachkillcamtorocket( level.straferunkillcams.rockets[ rocketindex ], selectedtarget, targetorigin );
/#
		if ( getdvarintdefault( 2442250922, 0 ) )
		{
			rocket thread debug_draw_bomb_path( undefined, vectorScale( ( 0, 0, 0 ), 0,5 ), 400 );
#/
		}
		wait level.straferunrocketdelay;
		rocketindex++;
	}
}

stopstrafe()
{
	self notify( "strafe_stop" );
	self.strafing = undefined;
	self thread resetkillcams( 3 );
	self clearturrettarget();
	owner = self.owner;
	if ( owner.straferunbda == 0 )
	{
		bdadialog = "kls_killn";
	}
	if ( owner.straferunbda == 1 )
	{
		bdadialog = "kls_kill1";
	}
	if ( owner.straferunbda == 2 )
	{
		bdadialog = "kls_kill2";
	}
	if ( owner.straferunbda == 3 )
	{
		bdadialog = "kls_kill3";
	}
	if ( owner.straferunbda > 3 )
	{
		bdadialog = "kls_killm";
	}
	if ( isDefined( bdadialog ) )
	{
		self thread pilotdialogwait( bdadialog, 3,5 );
	}
	owner.straferunbda = 0;
	self.gunsoundentity stoploopsound();
	self.gunsoundentity playsound( "wpn_a10_shot_decay_npc" );
	self.numstrafes++;
}

pilotdialogwait( dialog, time )
{
	self endon( "death" );
	if ( isDefined( time ) )
	{
		wait time;
	}
	playpilotdialog( dialog );
}

shouldleavemap()
{
	if ( isDefined( self.leavenexttime ) && self.leavenexttime )
	{
		return 1;
	}
	if ( self.numstrafes >= level.straferunmaxstrafes )
	{
		return 1;
	}
	if ( self.owner.straferunkills >= level.straferunkillsbeforeexit )
	{
		return 1;
	}
	return 0;
}

leavemap()
{
	self unlinkkillcams();
	exitorigin = self.origin + vectorScale( anglesToForward( self.angles ), level.straferunexitunits );
	self setyawspeed( 5, 999, 999 );
	self setvehgoalpos( exitorigin, 1 );
	wait 5;
	if ( isDefined( self ) )
	{
		self delete();
	}
}

explode()
{
	self endon( "delete" );
	forward = ( self.origin + vectorScale( ( 0, 0, 0 ), 100 ) ) - self.origin;
	playfx( level.straferunexplodefx, self.origin, forward );
	self playsound( level.straferunexplodesound );
	wait 0,1;
	if ( isDefined( self ) )
	{
		self delete();
	}
}

cantargetentity( entity )
{
	heli_centroid = self.origin + vectorScale( ( 0, 0, 0 ), 160 );
	heli_forward_norm = anglesToForward( self.angles );
	heli_turret_point = heli_centroid + ( 144 * heli_forward_norm );
	visible_amount = entity sightconetrace( heli_turret_point, self );
	if ( visible_amount < level.heli_target_recognition )
	{
		return 0;
	}
	return 1;
}

cantargetplayer( player )
{
	if ( !isalive( player ) || player.sessionstate != "playing" )
	{
		return 0;
	}
	if ( player == self.owner )
	{
		return 0;
	}
	if ( player cantargetplayerwithspecialty() == 0 )
	{
		return 0;
	}
	if ( !isDefined( player.team ) )
	{
		return 0;
	}
	if ( level.teambased && player.team == self.team )
	{
		return 0;
	}
	if ( player.team == "spectator" )
	{
		return 0;
	}
	if ( isDefined( player.spawntime ) && ( ( getTime() - player.spawntime ) / 1000 ) <= level.heli_target_spawnprotection )
	{
		return 0;
	}
	if ( !targetinfrontofplane( player ) )
	{
		return 0;
	}
	if ( player isinmovemode( "noclip" ) )
	{
		return 0;
	}
	return cantargetentity( player );
}

cantargetactor( actor )
{
	if ( !isDefined( actor ) )
	{
		return 0;
	}
	if ( level.teambased && actor.aiteam == self.team )
	{
		return 0;
	}
	if ( isDefined( actor.script_owner ) && self.owner == actor.script_owner )
	{
		return 0;
	}
	if ( !targetinfrontofplane( actor ) )
	{
		return 0;
	}
	return cantargetentity( actor );
}

targetinfrontofplane( target )
{
	forward_dir = anglesToForward( self.angles );
	target_delta = vectornormalize( target.origin - self.origin );
	dot = vectordot( forward_dir, target_delta );
	if ( dot < 0,5 )
	{
		return 1;
	}
	return 1;
}

getvalidtargets()
{
	targets = [];
	_a770 = level.players;
	_k770 = getFirstArrayKey( _a770 );
	while ( isDefined( _k770 ) )
	{
		player = _a770[ _k770 ];
		if ( self cantargetplayer( player ) )
		{
			if ( isDefined( player ) )
			{
				targets[ targets.size ] = player;
			}
		}
		_k770 = getNextArrayKey( _a770, _k770 );
	}
	dogs = maps/mp/killstreaks/_dogs::dog_manager_get_dogs();
	_a782 = dogs;
	_k782 = getFirstArrayKey( _a782 );
	while ( isDefined( _k782 ) )
	{
		dog = _a782[ _k782 ];
		if ( self cantargetactor( dog ) )
		{
			targets[ targets.size ] = dog;
		}
		_k782 = getNextArrayKey( _a782, _k782 );
	}
	tanks = getentarray( "talon", "targetname" );
	_a792 = tanks;
	_k792 = getFirstArrayKey( _a792 );
	while ( isDefined( _k792 ) )
	{
		tank = _a792[ _k792 ];
		if ( self cantargetactor( tank ) )
		{
			targets[ targets.size ] = tank;
		}
		_k792 = getNextArrayKey( _a792, _k792 );
	}
	return targets;
}

deadrecontargetorigin( rocket_start, target )
{
	target_velocity = target getvelocity();
	missile_speed = 7000;
	target_delta = target.origin - rocket_start;
	target_dist = length( target_delta );
	time_to_target = target_dist / missile_speed;
	return target.origin + ( target_velocity * time_to_target );
}

shellshockplayers( origin )
{
	_a821 = level.players;
	_k821 = getFirstArrayKey( _a821 );
	while ( isDefined( _k821 ) )
	{
		player = _a821[ _k821 ];
		if ( !isalive( player ) )
		{
		}
		else if ( player == self.owner )
		{
		}
		else if ( !isDefined( player.team ) )
		{
		}
		else if ( level.teambased && player.team == self.team )
		{
		}
		else
		{
			if ( distancesquared( player.origin, origin ) <= ( level.straferunshellshockradius * level.straferunshellshockradius ) )
			{
				player thread straferunshellshock();
			}
		}
		_k821 = getNextArrayKey( _a821, _k821 );
	}
}

straferunshellshock()
{
	self endon( "disconnect" );
	if ( isDefined( self.beingstraferunshellshocked ) && self.beingstraferunshellshocked )
	{
		return;
	}
	self.beingstraferunshellshocked = 1;
	self shellshock( level.straferunshellshock, level.straferunshellshockduration );
	wait ( level.straferunshellshockduration + 1 );
	self.beingstraferunshellshocked = 0;
}

createkillcams( numkillcams, numrockets )
{
	while ( !isDefined( level.straferunkillcams ) )
	{
		level.straferunkillcams = spawnstruct();
		level.straferunkillcams.rockets = [];
		i = 0;
		while ( i < numrockets )
		{
			level.straferunkillcams.rockets[ level.straferunkillcams.rockets.size ] = createkillcament();
			i++;
		}
		level.straferunkillcams.strafes = [];
		i = 0;
		while ( i < numkillcams )
		{
			level.straferunkillcams.strafes[ level.straferunkillcams.strafes.size ] = createkillcament();
/#
			if ( getdvarintdefault( 2442250922, 0 ) )
			{
				level.straferunkillcams.strafes[ i ] thread debug_draw_bomb_path( undefined, vectorScale( ( 0, 0, 0 ), 0,5 ), 200 );
#/
			}
			i++;
		}
	}
}

resetkillcams( time )
{
	self endon( "death" );
	if ( isDefined( time ) )
	{
		wait time;
	}
	i = 0;
	while ( i < level.straferunkillcams.rockets.size )
	{
		level.straferunkillcams.rockets[ i ] resetrocketkillcament( self, i );
		i++;
	}
	i = 0;
	while ( i < level.straferunkillcams.strafes.size )
	{
		level.straferunkillcams.strafes[ i ] resetkillcament( self );
		i++;
	}
}

unlinkkillcams()
{
	i = 0;
	while ( i < level.straferunkillcams.rockets.size )
	{
		level.straferunkillcams.rockets[ i ] unlink();
		i++;
	}
	i = 0;
	while ( i < level.straferunkillcams.strafes.size )
	{
		level.straferunkillcams.strafes[ i ] unlink();
		i++;
	}
}

createkillcament()
{
	killcament = spawn( "script_model", ( 0, 0, 0 ) );
	killcament setfovforkillcam( 25 );
	return killcament;
}

resetkillcament( parent )
{
	self notify( "reset" );
	parent endon( "death" );
	offset_x = getdvarintdefault( 862326232, -3000 );
	offset_y = getdvarintdefault( 862326233, 0 );
	offset_z = getdvarintdefault( 862326234, 740 );
	self linkto( parent, "tag_origin", ( offset_x, offset_y, offset_z ), vectorScale( ( 0, 0, 0 ), 10 ) );
	self thread unlinkwhenparentdies( parent );
}

resetrocketkillcament( parent, rocketindex )
{
	self notify( "reset" );
	parent endon( "death" );
	offset_x = getdvarintdefault( 862326232, -3000 );
	offset_y = getdvarintdefault( 862326233, 0 );
	offset_z = getdvarintdefault( 862326234, 740 );
	rockettag = level.straferunrockettags[ rocketindex % level.straferunrockettags.size ];
	self linkto( parent, rockettag, ( offset_x, offset_y, offset_z ), vectorScale( ( 0, 0, 0 ), 10 ) );
	self thread unlinkwhenparentdies( parent );
}

deletewhenparentdies( parent )
{
	parent waittill( "death" );
	self delete();
}

unlinkwhenparentdies( parent )
{
	self endon( "reset" );
	self endon( "unlink" );
	parent waittill( "death" );
	self unlink();
}

attachkillcamtorocket( killcament, selectedtarget, targetorigin )
{
	offset_x = getdvarintdefault( 562767152, -400 );
	offset_y = getdvarintdefault( 562767153, 0 );
	offset_z = getdvarintdefault( 562767154, 110 );
	self.killcament = killcament;
	forward = vectorScale( anglesToForward( self.angles ), offset_x );
	right = vectorScale( anglesToRight( self.angles ), offset_y );
	up = vectorScale( anglesToUp( self.angles ), offset_z );
	killcament unlink();
	killcament.angles = ( 0, 0, 0 );
	killcament.origin = self.origin;
	killcament linkto( self, "", ( offset_x, offset_y, offset_z ), vectorScale( ( 0, 0, 0 ), 9 ) );
	killcament thread unlinkwhenclose( selectedtarget, targetorigin, self );
}

unlinkwhenclose( selectedtarget, targetorigin, plane )
{
	plane endon( "death" );
	self notify( "unlink_when_close" );
	self endon( "unlink_when_close" );
	distsqr = 1000000;
	while ( 1 )
	{
		if ( isDefined( selectedtarget ) )
		{
			if ( distancesquared( self.origin, selectedtarget.origin ) < distsqr )
			{
				self unlink();
				self.angles = ( 0, 0, 0 );
				return;
			}
		}
		else
		{
			if ( distancesquared( self.origin, targetorigin ) < distsqr )
			{
				self unlink();
				self.angles = ( 0, 0, 0 );
				return;
			}
		}
		wait 0,1;
	}
}

getlookaheadorigin( previous_origin, next_origin, lookahead )
{
	delta = next_origin - previous_origin;
	forwardnoz = vectornormalize( ( delta[ 0 ], delta[ 1 ], 0 ) );
	origin = next_origin + vectorScale( forwardnoz, lookahead );
	return origin;
}

strafekillcam( parent, node, distance )
{
	parent endon( "death" );
	self endon( "reset" );
	wait 0,05;
	self notify( "unlink" );
	self unlink();
	self.angles = ( 0, 0, 0 );
	accel_time = 0,2;
	speed = 20000;
	start_height_offset = -800;
	stop_height = level.mapcenter[ 2 ] - 500;
	start_origin_struct = getoriginalongstrafepath( node, self.origin, distance );
	start_origin = start_origin_struct.origin;
	node = start_origin_struct.node;
	previous_origin = self.origin;
	start_origin = getlookaheadorigin( previous_origin, start_origin, parent.straferungunlookahead + 1000 );
	trace = bullettrace( ( start_origin[ 0 ], start_origin[ 1 ], start_origin[ 2 ] + start_height_offset ), ( start_origin[ 0 ], start_origin[ 1 ], stop_height ), 0, parent, 0, 1 );
	pathheight = trace[ "position" ][ 2 ];
	self killcammoveto( trace[ "position" ], speed, accel_time, pathheight );
	speed = 500;
	while ( isDefined( node ) )
	{
		previous_origin = node.origin;
		node = getvehiclenode( node.target, "targetname" );
		start_origin = getlookaheadorigin( previous_origin, node.origin, parent.straferungunlookahead + 1000 );
		trace = bullettrace( ( start_origin[ 0 ], start_origin[ 1 ], start_origin[ 2 ] + start_height_offset ), ( start_origin[ 0 ], start_origin[ 1 ], stop_height ), 0, parent, 0, 1 );
		self killcammoveto( trace[ "position" ], speed, 0, pathheight );
	}
}

killcammoveto( goal, speed, accel, pathheight )
{
	self endon( "reset" );
	height_offset = randomintrange( 350, 450 );
	origin = ( goal[ 0 ], goal[ 1 ], goal[ 2 ] + height_offset );
	dist = distance( origin, self.origin );
	time = dist / speed;
	if ( accel > time )
	{
		accel = time;
	}
	self moveto( origin, time, accel, 0 );
	self waittill( "movedone" );
}

startstrafekillcams()
{
	node = getvehiclenode( self.currentnode.target, "targetname" );
	strafe_dist = getstrafedistance( node );
	strafe_increment = strafe_dist / ( level.straferunkillcams.strafes.size + 1 );
	current_dist = 10;
	i = 0;
	while ( i < level.straferunkillcams.strafes.size )
	{
		level.straferunkillcams.strafes[ i ] thread strafekillcam( self, node, current_dist );
		current_dist += strafe_increment;
		i++;
	}
}

getstrafedistance( node )
{
	previous_node = node;
	next_node = getvehiclenode( previous_node.target, "targetname" );
	dist = 0;
	while ( isDefined( previous_node.script_noteworthy ) && previous_node.script_noteworthy != "strafe_stop" && next_node != node )
	{
		dist += distance( ( previous_node.origin[ 0 ], previous_node.origin[ 1 ], 0 ), ( next_node.origin[ 0 ], next_node.origin[ 1 ], 0 ) );
		previous_node = next_node;
		next_node = getvehiclenode( previous_node.target, "targetname" );
	}
	return dist;
}

getoriginalongstrafepath( node, start_origin, distance_along )
{
	origin_node = spawnstruct();
	seg_dist = distance( ( start_origin[ 0 ], start_origin[ 1 ], 0 ), ( node.origin[ 0 ], node.origin[ 1 ], 0 ) );
	dist = 0;
	if ( ( dist + seg_dist ) > distance_along )
	{
		forwardvec = vectornormalize( ( node.origin[ 0 ], node.origin[ 1 ], 0 ) - ( start_origin[ 0 ], start_origin[ 1 ], 0 ) );
		origin_node.origin = start_origin + ( forwardvec * ( distance_along - dist ) );
		origin_node.node = node;
		return origin_node;
	}
	dist = seg_dist;
	previous_node = node;
	next_node = getvehiclenode( previous_node.target, "targetname" );
	while ( isDefined( previous_node.script_noteworthy ) && previous_node.script_noteworthy != "strafe_stop" && next_node != node )
	{
		seg_dist = distance( ( previous_node.origin[ 0 ], previous_node.origin[ 1 ], 0 ), ( next_node.origin[ 0 ], next_node.origin[ 1 ], 0 ) );
		if ( ( dist + seg_dist ) > distance_along )
		{
			forwardvec = vectornormalize( next_node.origin - previous_node.origin );
			origin_node.origin = previous_node.origin + ( forwardvec * ( distance_along - dist ) );
			origin_node.node = previous_node;
			return origin_node;
		}
		dist += seg_dist;
		previous_node = next_node;
		next_node = getvehiclenode( previous_node.target, "targetname" );
	}
}
