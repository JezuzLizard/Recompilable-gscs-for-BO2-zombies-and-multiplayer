#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

mechz_init_start()
{
}

mechz_init_end()
{
}

spawn_start()
{
	self.not_interruptable = 1;
}

spawn_end()
{
	self.not_interruptable = 0;
}

mechz_round_tracker_start()
{
}

mechz_round_tracker_loop_start()
{
}

mechz_round_tracker_loop_end()
{
}
