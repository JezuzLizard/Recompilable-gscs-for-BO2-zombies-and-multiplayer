#include maps/mp/gametypes/_globallogic_player;

init() //checked matches cerberus output
{
	precacheshader( "overlay_low_health" );
	level.healthoverlaycutoff = 0.55;
	regentime = level.playerhealthregentime;
	level.playerhealth_regularregendelay = regentime * 1000;
	level.healthregendisabled = level.playerhealth_regularregendelay <= 0;
	level thread onplayerconnect();
}

onplayerconnect() //checked matches cerberus output
{
	for ( ;; )
	{
		level waittill( "connecting", player );
		player thread onplayerspawned();
		player thread onplayerkilled();
		player thread onjoinedteam();
		player thread onjoinedspectators();
		player thread onplayerdisconnect();
	}
}

onjoinedteam() //checked matches cerberus output
{
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "joined_team" );
		self notify( "end_healthregen" );
	}
}

onjoinedspectators() //checked matches cerberus output
{
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "joined_spectators" );
		self notify( "end_healthregen" );
	}
}

onplayerspawned() //checked matches cerberus output
{
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "spawned_player" );
		self thread playerhealthregen();
	}
}

onplayerkilled() //checked matches cerberus output
{
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "killed_player" );
		self notify( "end_healthregen" );
	}
}

onplayerdisconnect() //checked matches cerberus output
{
	self waittill( "disconnect" );
	self notify( "end_healthregen" );
}

playerhealthregen() //checked changed to match cerberus output
{
	self endon( "end_healthregen" );
	if ( self.health <= 0 )
	{
		/*
/#
		assert( !isalive( self ) );
#/
		*/
		return;
	}
	maxhealth = self.health;
	oldhealth = maxhealth;
	player = self;
	health_add = 0;
	regenrate = 0.1;
	usetrueregen = 0;
	veryhurt = 0;
	player.breathingstoptime = -10000;
	thread playerbreathingsound( maxhealth * 0.35 );
	thread playerheartbeatsound( maxhealth * 0.35 );
	lastsoundtime_recover = 0;
	hurttime = 0;
	newhealth = 0;
	for ( ;; )
	{
		wait 0.05;
		if ( isDefined( player.regenrate ) )
		{
			regenrate = player.regenrate;
			usetrueregen = 1;
		}
		if ( player.health == maxhealth )
		{
			veryhurt = 0;
			self.atbrinkofdeath = 0;
			continue;
		}
		if ( player.health <= 0 )
		{
			return;
		}
		if ( isDefined( player.laststand ) && player.laststand )
		{
			continue;
		}
		wasveryhurt = veryhurt;
		ratio = player.health / maxhealth;
		if ( ratio <= level.healthoverlaycutoff )
		{
			veryhurt = 1;
			self.atbrinkofdeath = 1;
			if ( !wasveryhurt )
			{
				hurttime = getTime();
			}
		}
		if ( player.health >= oldhealth )
		{
			regentime = level.playerhealth_regularregendelay;
			if ( player hasperk( "specialty_healthregen" ) )
			{
				regentime = int( regentime / getDvarFloat( "perk_healthRegenMultiplier" ) );
			}
			if ( ( getTime() - hurttime ) < regentime )
			{
				continue;
			}
			else if ( level.healthregendisabled )
			{
				continue;
			}
			else if ( ( getTime() - lastsoundtime_recover ) > regentime )
			{
				lastsoundtime_recover = getTime();
				self notify( "snd_breathing_better" );
			}
			if ( veryhurt )
			{
				newhealth = ratio;
				veryhurttime = 3000;
				if ( player hasperk( "specialty_healthregen" ) )
				{
					veryhurttime = int( veryhurttime / getDvarFloat( "perk_healthRegenMultiplier" ) );
				}
				if ( getTime() > ( hurttime + veryhurttime ) )
				{
					newhealth += regenrate;
				}
			}
			else if ( usetrueregen )
			{
				newhealth = ratio + regenrate;
			}
			else
			{
				newhealth = 1;
			}
			if ( newhealth >= 1 )
			{
				self maps/mp/gametypes/_globallogic_player::resetattackerlist();
				newhealth = 1;
			}
			if ( newhealth <= 0 )
			{
				return;
			}
			player setnormalhealth( newhealth );
			change = player.health - oldhealth;
			if ( change > 0 )
			{
				player decayplayerdamages( change );
			}
			oldhealth = player.health;
			continue;
		}
		oldhealth = player.health;
		health_add = 0;
		hurttime = getTime();
		player.breathingstoptime = hurttime + 6000;
	}
}

decayplayerdamages( decay ) //checked partially changed to match cerberus output //continues in for loops bad see github for more info
{
	if ( !isDefined( self.attackerdamage ) )
	{
		return;
	}
	i = 0;
	while ( i < self.attackerdamage.size )
	{
		if ( !isDefined( self.attackerdamage[ i ] ) || !isDefined( self.attackerdamage[ i ].damage ) )
		{
			i++;
			continue;
		}
		self.attackerdamage[ i ].damage -= decay;
		if ( self.attackerdamage[ i ].damage < 0 )
		{
			self.attackerdamage[ i ].damage = 0;
		}
		i++;
	}
}

playerbreathingsound( healthcap ) //checked changed to match cerberus output
{
	self endon( "end_healthregen" );
	wait 2;
	player = self;
	for ( ;; )
	{
		wait 0.2;
		if ( player.health <= 0 )
		{
			return;
		}
		if ( player.health >= healthcap )
		{
			continue;
		}
		else if ( level.healthregendisabled && getTime() > player.breathingstoptime )
		{
			continue;
		}
		player notify( "snd_breathing_hurt" );
		wait 0.784;
		wait ( 0.1 + randomfloat( 0.8 ) );
	}
}

playerheartbeatsound( healthcap ) //checked changed to match cerberus output
{
	self endon( "end_healthregen" );
	self.hearbeatwait = 0.2;
	wait 2;
	player = self;
	for ( ;; )
	{
		wait 0.2;
		if ( player.health <= 0 )
		{
			return;
		}
		if ( player.health >= healthcap )
		{
			self.hearbeatwait = 0.3;
			continue;
		}
		else if ( level.healthregendisabled && getTime() > player.breathingstoptime )
		{
			self.hearbeatwait = 0.3;
			continue;
		}
		player playlocalsound( "mpl_player_heartbeat" );
		wait self.hearbeatwait;
		if ( self.hearbeatwait <= 0.6 )
		{
			self.hearbeatwait += 0.1;
		}
	}
}

