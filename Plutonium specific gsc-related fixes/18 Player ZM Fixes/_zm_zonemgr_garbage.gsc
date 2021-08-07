level.zones tree 
    array zone_name 
        property is_enabled 0
        property is_occupied 0
        property is_active 0
        property is_spawning_allowed 0
        property array spawn_locations
        property array dog_locations
        property array screecher_locations
        property array avogadro_locations
        property array inert_locations
        property array quad_locations
        property array leaper_locations
        property array brutus_locations
        property array mechz_locations
        property array astro_locations
        property array spawn_locations
        property array napalm_locations
        property array zbarriers
        property array magic_boxes
        property array volumes 
            volumes 0
                property target
        property array adjacent_zones
            adjacent_zones key 
                property is_connected 0
                property flags_do_or_check 0
                property array flags

level.newzones tree 
    array zone_name
        property is_active
        property is_occupied

level.zones tree //optimized
    array zone_name 
        property is_enabled 0
        property is_occupied 0
        property is_active 0
        property is_spawning_allowed 0
        property array zbarriers
        property array magic_boxes
        property array volumes 
            volumes 0
                property target
        property array adjacent_zones
            adjacent_zones key 
                property is_connected 0
                property flags_do_or_check 0
                property array flags
        property array ai_location_types 
            array spawn_locations