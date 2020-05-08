#include maps/mp/_utility;
#include common_scripts/utility;

bot_conf_think() //checked matches cerberus output
{
	time = getTime();
	if ( time < self.bot.update_objective )
	{
		return;
	}
	self.bot.update_objective = time + randomintrange( 500, 1500 );
	goal = self getgoal( "conf_dogtag" );
	if ( isDefined( goal ) )
	{
		if ( !conf_tag_in_radius( goal, 64 ) )
		{
			self cancelgoal( "conf_dogtag" );
		}
	}
	conf_get_tag_in_sight();
}

conf_get_tag_in_sight() //checked partially changed to match cerberus output did not use foreach see github for more info
{
	angles = self getplayerangles();
	forward = anglesToForward( angles );
	forward = vectornormalize( forward );
	closest = 999999;
	tags = level.dogtags;
	i = 0;
	while ( i < tags.size )
	{
		if ( is_true( tags[ i ].unreachable ) )
		{
			i++;
			continue;
		}
		distsq = distancesquared( tags[ i ].curorigin, self.origin );
		if ( distsq > closest )
		{
			i++;
			continue;
		}
		delta = tags[ i ].curorigin - self.origin;
		delta = vectornormalize( delta );
		dot = vectordot( forward, delta );
		if ( dot < self.bot.fov && distsq > 40000 )
		{ 
			i++;
			continue;
		}
		if ( dot > self.bot.fov && distsq > 1440000 )
		{
			i++;
			continue;
		}
		nearest = getnearestnode( tags[ i ].curorigin );
		if ( !isDefined( nearest ) )
		{
			tags[ i ].unreachable = 1;
			i++;
			continue;
		}
		if ( ( tags[ i ].curorigin[ 2 ] - nearest.origin[ 2 ] ) > 18 )
		{
			tags[ i ].unreachable = 1;
			i++;
			continue;
		}
		if ( !isDefined( tags[ i ].unreachable ) && !findpath( self.origin, tags[ i ].curorigin, tags[ i ], 0, 1 ) )
		{
			tags[ i ].unreachable = 1;
		}
		else
		{
			tags[ i ].unreachable = 0;
		}
		closest = distsq;
		closetag = tags[ i ];
		i++;
	}
	if ( isDefined( closetag ) )
	{
		self addgoal( closetag.curorigin, 16, 3, "conf_dogtag" );
	}
}

conf_tag_in_radius( origin, radius ) //checked changed to match cerberus output
{
	foreach ( tag in level.dogtags )
	{
		if ( distancesquared( origin, tag.curorigin ) < radius * radius )
		{
			return 1;
		}
	}
	return 0;
}


