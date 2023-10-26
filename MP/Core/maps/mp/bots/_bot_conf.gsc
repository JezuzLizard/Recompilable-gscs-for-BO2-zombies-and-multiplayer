// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;

bot_conf_think()
{
    time = gettime();

    if ( time < self.bot.update_objective )
        return;

    self.bot.update_objective = time + randomintrange( 500, 1500 );
    goal = self getgoal( "conf_dogtag" );

    if ( isdefined( goal ) )
    {
        if ( !conf_tag_in_radius( goal, 64 ) )
            self cancelgoal( "conf_dogtag" );
    }

    conf_get_tag_in_sight();
}

conf_get_tag_in_sight()
{
    angles = self getplayerangles();
    forward = anglestoforward( angles );
    forward = vectornormalize( forward );
    closest = 999999;

    foreach ( tag in level.dogtags )
    {
        if ( is_true( tag.unreachable ) )
            continue;

        distsq = distancesquared( tag.curorigin, self.origin );

        if ( distsq > closest )
            continue;

        delta = tag.curorigin - self.origin;
        delta = vectornormalize( delta );
        dot = vectordot( forward, delta );

        if ( dot < self.bot.fov && distsq > 40000 )
            continue;

        if ( dot > self.bot.fov && distsq > 1440000 )
            continue;

        nearest = getnearestnode( tag.curorigin );

        if ( !isdefined( nearest ) )
        {
            tag.unreachable = 1;
            continue;
        }

        if ( tag.curorigin[2] - nearest.origin[2] > 18 )
        {
            tag.unreachable = 1;
            continue;
        }

        if ( !isdefined( tag.unreachable ) && !findpath( self.origin, tag.curorigin, tag, 0, 1 ) )
            tag.unreachable = 1;
        else
            tag.unreachable = 0;

        closest = distsq;
        closetag = tag;
    }

    if ( isdefined( closetag ) )
        self addgoal( closetag.curorigin, 16, 3, "conf_dogtag" );
}

conf_tag_in_radius( origin, radius )
{
    foreach ( tag in level.dogtags )
    {
        if ( distancesquared( origin, tag.curorigin ) < radius * radius )
            return true;
    }

    return false;
}
