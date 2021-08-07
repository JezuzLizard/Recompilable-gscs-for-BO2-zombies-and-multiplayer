#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/zombies/_zm_magicbox_lock;
#include maps/mp/zombies/_zm_magicbox;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init()
{
	precachemodel( "p6_anim_strongbox_lock" );
	level.locked_magic_box_cost = 2000;
	level.custom_magicbox_state_handler = ::set_locked_magicbox_state;
	add_zombie_hint( "locked_magic_box_cost", &"ZOMBIE_LOCKED_BOX_COST" );
}

watch_for_lock()
{
	self endon( "user_grabbed_weapon" );
	self endon( "chest_accessed" );
	self waittill( "box_locked" );
	self notify( "kill_chest_think" );
	self.grab_weapon_hint = 0;
	wait 0,1;
	self thread maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( self.unitrigger_stub, ::magicbox_unitrigger_think );
	self.unitrigger_stub run_visibility_function_for_all_triggers();
	self thread treasure_chest_think();
}

clean_up_locked_box()
{
	self endon( "box_spin_done" );
	self.owner waittill( "box_locked" );
	if ( isDefined( self.weapon_model ) )
	{
		self.weapon_model delete();
		self.weapon_model = undefined;
	}
	if ( isDefined( self.weapon_model_dw ) )
	{
		self.weapon_model_dw delete();
		self.weapon_model_dw = undefined;
	}
	self hidezbarrierpiece( 3 );
	self hidezbarrierpiece( 4 );
	self setzbarrierpiecestate( 3, "closed" );
	self setzbarrierpiecestate( 4, "closed" );
}

magic_box_locks()
{
	self.owner.is_locked = 1;
	self.owner notify( "box_locked" );
	if ( !isDefined( self.angles ) )
	{
		self.angles = ( 0, 0, 1 );
	}
	forward = anglesToRight( self.angles );
	self.lock_model = spawn( "script_model", self.origin + ( -15 * forward ) + vectorScale( ( 0, 0, 1 ), 8 ) );
	self.lock_model.angles = self.angles;
	self.lock_model setmodel( "p6_anim_strongbox_lock" );
}

magic_box_unlocks()
{
	self.owner.is_locked = 0;
	self.lock_model delete();
}

set_locked_magicbox_state( state )
{
	switch( state )
	{
		case "locking":
			self showzbarrierpiece( 1 );
			self thread magic_box_locks();
			self.state = "locking";
			break;
		case "unlocking":
			self showzbarrierpiece( 1 );
			self thread magic_box_unlocks();
			self.state = "close";
			break;
	}
}
