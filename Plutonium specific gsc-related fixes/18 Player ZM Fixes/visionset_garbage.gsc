_zm_perks.gsc
    Die Rise Only
        if ( isDefined( level.vsmgr_prio_visionset_zm_whos_who ) )
        {
            vsmgr_register_info( "visionset", "zm_whos_who", 5000, level.vsmgr_prio_visionset_zm_whos_who, 1, 1 );
        }

_zm_turned.gsc
    Turned Gametype Only 
        if ( !isDefined( level.vsmgr_prio_visionset_zombie_turned ) )
        {
            level.vsmgr_prio_visionset_zombie_turned = 123;
        }
        vsmgr_register_info( "visionset", "zm_turned", 3000, level.vsmgr_prio_visionset_zombie_turned, 1, 1 );

zm_buried_sq.gsc
    Buried Only 
        sq_buried_register_visionset()
        {
            vsmgr_register_info( "visionset", "cheat_bw", 12000, 17, 1, 1 );
        }

zm_buried_turned_street.gsc 
    Turned Gametype on map Buried Only 
        vsmgr_register_info( "overlay", "zm_transit_burn", 1, 21, 15, 1, vsmgr_duration_lerp_thread_per_player, 0 );

_zm_perk_vulture.gsc 
    Buried Classic Only 
        vsmgr_register_info( "overlay", "vulture_stink_overlay", 12000, 120, 31, 1 );

_zm_weap_time_bomb.gsc 
    Buried Classic Only 
        vsmgr_register_info( "overlay", "zombie_time_bomb_overlay", 12000, 200, 20, 0, ::time_bomb_overlay_lerp_thread );

_zm_perk_divetonuke.gsc 
    Buried Classic, Mob Grief, and Origins Only 
        vsmgr_register_info( "visionset", "zm_perk_divetonuke", 9000, 400, 5, 1 );

zm_prison.gsc 
    Mob Only 
        vsmgr_register_info( "visionset", "zm_audio_log", 9000, 200, 1, 1 );
	    vsmgr_register_info( "visionset", "zm_electric_cherry", 9000, 121, 1, 1 );

_zm_afterlife.gsc 
    Mob Classic Only 
        vsmgr_register_info( "visionset", "zm_afterlife", 9000, 120, 1, 1 );
	    vsmgr_register_info( "overlay", "zm_afterlife_filter", 9000, 120, 1, 1 );

zm_tomb.gsc 
    Origins Only 
        vsmgr_register_info( "overlay", "zm_transit_burn", 14000, level.vsmgr_prio_overlay_zm_transit_burn, 15, 1, ::vsmgr_duration_lerp_thread_per_player, 0 );

_zm_powerup_zombie_blood.gsc 
    Origins Only 
        vsmgr_register_info( "visionset", "zm_powerup_zombie_blood_visionset", 14000, level.vsmgr_prio_visionset_zm_powerup_zombie_blood, 15, 1 );
	    vsmgr_register_info( "overlay", "zm_powerup_zombie_blood_overlay", 14000, level.vsmgr_prio_overlay_zm_powerup_zombie_blood, 15, 1 );

zm_transit_power.gsc 
    Tranzit Classic Only 
        vsmgr_register_info( "visionset", "zm_power_high_low", 1, level.vsmgr_prio_visionset_zm_transit_power_high_low, 7, 1, ::vsmgr_lerp_power_up_down, 0 );

zm_transit.gsc 
    Tranzit Only 
        vsmgr_register_info( "overlay", "zm_transit_burn", 1, level.vsmgr_prio_overlay_zm_transit_burn, 15, 1, ::vsmgr_duration_lerp_thread_per_player, 0 );

_zm_ai_avogadro.gsc 
    Tranzit Classic Only
        vsmgr_register_info( "overlay", "zm_ai_avogadro_electrified", 1, level.vsmgr_prio_overlay_zm_ai_avogadro_electrified, 15, 1, ::vsmgr_duration_lerp_thread_per_player, 0 );

_zm_ai_screecher.gsc 
    Tranzit Classic Only 
        vsmgr_register_info( "overlay", "zm_ai_screecher_blur", 1, level.vsmgr_prio_overlay_zm_ai_screecher_blur, 1, 1, ::vsmgr_timeout_lerp_thread_per_player, 0 );


Tranzit
level.vsmgr tree 
    array type 
        "overlay"
            property type "overlay"
            property in_use false
            property highest_version 0
            property cf_slot_name "overlay_slot"
            property cf_slot_bit_count
            property cf_lerp_name "overlay_lerp"
            property cf_lerp_bit_count
            property sorted_name_keys
            property sorted_prio_keys
            property array info
                "none" //can be terminated
                    property type 
                    property name 
                    property version 
                    property priority 
                    property lerp_step_count 
                    property lerp_bit_count 
                    property slot_index
                    property state
                        property type 
                        property name 
                        property activate_per_player 
                        property lerp_thread 
                        property ref_count_lerp_thread 
                        property ref_count 
                        property array players
                            players 0 - 17
                                property active 0
                                property lerp 0      
                IF MAP == ZM_TRANSIT && GAMETYPE == ZCLASSIC
                "zm_ai_screecher_blur"
                    property type 
                    property name 
                    property version 
                    property priority 
                    property lerp_step_count 
                    property lerp_bit_count 
                    property slot_index
                    property state
                        property type 
                        property name 
                        property activate_per_player 
                        property lerp_thread 
                        property ref_count_lerp_thread 
                        property ref_count 
                        property array players
                            players 0 - 17
                                property active 0
                                property lerp 0       
                "zm_ai_avogadro_electrified"
                    property type 
                    property name 
                    property version 
                    property priority 
                    property lerp_step_count 
                    property lerp_bit_count 
                    property slot_index
                    property state
                        property type 
                        property name 
                        property activate_per_player 
                        property lerp_thread 
                        property ref_count_lerp_thread 
                        property array players
                        property ref_count
                            players 0 - 17
                                property active 0
                                property lerp 0
                IF MAP == ZM_TRANSIT
                "zm_transit_burn"   
                    property type 
                    property name 
                    property version 
                    property priority 
                    property lerp_step_count 
                    property lerp_bit_count 
                    property slot_index
                    property state
                        property type 
                        property name 
                        property activate_per_player 
                        property lerp_thread 
                        property ref_count_lerp_thread 
                        property ref_count  
                        property array players
                            players 0 - 17
                                property active 0
                                property lerp 0  
        "visionset"
            property type "visionset"
            property in_use false
            property highest_version 0
            property cf_slot_name "visionset_slot"
            property cf_slot_bit_count 
            property cf_lerp_name "visionset_lerp"
            property cf_lerp_bit_count
            property sorted_name_keys
            property sorted_prio_keys
            property array info
                "none" //can be terminated
                    property type 
                    property name 
                    property version 
                    property priority 
                    property lerp_step_count 
                    property lerp_bit_count 
                    property slot_index
                    property state
                        property type 
                        property name 
                        property activate_per_player 
                        property lerp_thread 
                        property ref_count_lerp_thread 
                        property ref_count 
                        property array players
                            players 0 - 17
                                property active 0
                                property lerp 0     
                IF MAP == ZM_TRANSIT && GAMETYPE == ZCLASSIC
                "zm_power_high_low"
                    property type 
                    property name 
                    property version 
                    property priority 
                    property lerp_step_count 
                    property lerp_bit_count 
                    property slot_index
                    property state
                        property type 
                        property name 
                        property activate_per_player 
                        property lerp_thread 
                        property ref_count_lerp_thread 
                        property ref_count 
                        property array players
                            players 0 - 17
                                property active 0
                                property lerp 0    





//global variables that can be terminated after the game starts
level.vsmgr_default_info_name
level.vsmgr_initializing