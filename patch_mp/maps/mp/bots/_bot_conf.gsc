#include maps/mp/_utility;
#include common_scripts/utility;

bot_conf_think()
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

conf_get_tag_in_sight()
{
	angles = self getplayerangles();
	forward = anglesToForward( angles );
	forward = vectornormalize( forward );
	closest = 999999;
	_a41 = level.dogtags;
	_k41 = getFirstArrayKey( _a41 );
	while ( isDefined( _k41 ) )
	{
		tag = _a41[ _k41 ];
		if ( is_true( tag.unreachable ) )
		{
		}
		else distsq = distancesquared( tag.curorigin, self.origin );
		if ( distsq > closest )
		{
		}
		else delta = tag.curorigin - self.origin;
		delta = vectornormalize( delta );
		dot = vectordot( forward, delta );
		if ( dot < self.bot.fov && distsq > 40000 )
		{
		}
		else
		{
			if ( dot > self.bot.fov && distsq > 1440000 )
			{
				break;
			}
			else
			{
				nearest = getnearestnode( tag.curorigin );
				if ( !isDefined( nearest ) )
				{
					tag.unreachable = 1;
					break;
				}
				else if ( ( tag.curorigin[ 2 ] - nearest.origin[ 2 ] ) > 18 )
				{
					tag.unreachable = 1;
					break;
				}
				else
				{
					if ( !isDefined( tag.unreachable ) && !findpath( self.origin, tag.curorigin, tag, 0, 1 ) )
					{
						tag.unreachable = 1;
					}
					else
					{
						tag.unreachable = 0;
					}
					closest = distsq;
					closetag = tag;
				}
			}
		}
		_k41 = getNextArrayKey( _a41, _k41 );
	}
	if ( isDefined( closetag ) )
	{
		self addgoal( closetag.curorigin, 16, 3, "conf_dogtag" );
	}
}

conf_tag_in_radius( origin, radius )
{
	_a106 = level.dogtags;
	_k106 = getFirstArrayKey( _a106 );
	while ( isDefined( _k106 ) )
	{
		tag = _a106[ _k106 ];
		if ( distancesquared( origin, tag.curorigin ) < ( radius * radius ) )
		{
			return 1;
		}
		_k106 = getNextArrayKey( _a106, _k106 );
	}
	return 0;
}
