//checked includes changed to match cerberus output
#include maps/mp/zombies/_zm_blockers;
#include maps/mp/zombies/_zm_audio;
#include character/c_zom_oleary;
#include character/c_zom_handsome;
#include character/c_zom_deluca;
#include character/c_zom_arlington;
#include maps/mp/zm_prison;
#include maps/mp/_visionset_mgr;
#include maps/mp/zm_alcatraz_grief_cellblock;
#include maps/mp/zm_alcatraz_weap_quest;
#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/zombies/_zm_weap_tomahawk;
#include maps/mp/zombies/_zm_weap_blundersplat;
#include maps/mp/zombies/_zm_weap_riotshield_prison;
#include maps/mp/zombies/_zm_weap_claymore;
#include maps/mp/zombies/_zm_ai_basic;
#include maps/mp/zombies/_zm_magicbox_prison;
#include maps/mp/zm_alcatraz_travel;
#include maps/mp/zm_alcatraz_traps;
#include maps/mp/zm_alcatraz_distance_tracking;
#include maps/mp/zm_alcatraz_sq;
#include maps/mp/zm_alcatraz_craftables;
#include maps/mp/zombies/_zm_perk_divetonuke;
#include maps/mp/zombies/_zm_perk_electric_cherry;
#include maps/mp/gametypes_zm/_spawning;
#include maps/mp/zm_prison_achievement;
#include maps/mp/zombies/_load;
#include maps/mp/zm_alcatraz_amb;
#include maps/mp/animscripts/zm_death;
#include maps/mp/zombies/_zm;
#include maps/mp/zm_prison_ffotd;
#include maps/mp/zm_prison_fx;
#include maps/mp/zm_alcatraz_gamemodes;
#include maps/mp/zm_alcatraz_utility;
#include maps/mp/zombies/_zm_craftables;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/zombies/_zm_afterlife;

gamemode_callback_setup() //checked matches cerberus output
{
	maps/mp/zm_alcatraz_gamemodes::init();
}

init_characters() //checked matches cerberus output
{
	level.has_weasel = 0;
	level.givecustomloadout = ::givecustomloadout;
	level.precachecustomcharacters = ::precache_personality_characters;
	level.givecustomcharacters = ::give_personality_characters;
	level.setupcustomcharacterexerts = ::setup_personality_character_exerts;
	flag_wait( "start_zombie_round_logic" );
}

zclassic_preinit() //checked matches cerberus output
{
	init_characters();
}

createfx_callback() //checked changed to match cerberus output
{
	ents = getentarray();
	for ( i = 0; i < ents.size; i++ )
	{
		if ( ents[ i ].classname != "info_player_start" )
		{
			ents[ i ] delete();
		}
	}
}

main() //checked changed to match cerberus output
{
	maps/mp/zm_prison_fx::main();
	level thread maps/mp/zm_prison_ffotd::main_start();
	level thread title_update_main_start();
	precacherumble( "brutus_footsteps" );
	level.default_game_mode = "zclassic";
	level.default_start_location = "prison";
	setup_rex_starts();
	maps/mp/zombies/_zm::init_fx();
	maps/mp/animscripts/zm_death::precache_gib_fx();
	level.zombiemode = 1;
	level._no_water_risers = 1;
	maps/mp/zm_alcatraz_amb::main();
	maps/mp/zombies/_load::main();
	level.level_specific_stats_init = maps/mp/zm_prison_achievement::init_player_achievement_stats;
	if ( getDvar( "createfx" ) == "1" )
	{
		return;
	}
	maps/mp/gametypes_zm/_spawning::level_use_unified_spawning( 1 );
	level.fixed_max_player_use_radius = 72;
	level.custom_player_fake_death = ::zm_player_fake_death;
	level.custom_player_fake_death_cleanup = ::zm_player_fake_death_cleanup;
	level.initial_round_wait_func = ::initial_round_wait_func;
	level.special_weapon_magicbox_check = ::check_for_special_weapon_limit_exist;
	level._door_open_rumble_func = ::door_rumble_on_buy;
	level._zombies_round_spawn_failsafe = ::alcatraz_round_spawn_failsafe;
	level.zombiemode_using_pack_a_punch = 1;
	level.zombiemode_reusing_pack_a_punch = 1;
	level.zombie_init_done = ::zombie_init_done;
	level.zombiemode_using_doubletap_perk = 1;
	level.zombiemode_using_juggernaut_perk = 1;
	level.zombiemode_using_sleightofhand_perk = 1;
	level.zombiemode_using_deadshot_perk = 1;
	
	map = level.customMap;
	if(isDefined(map) && map != "vanilla")
	{
		if(isDefined(map) && map != "rooftop")
		{
			level.zombiemode_using_marathon_perk = 1;
			level.zombiemode_using_revive_perk = 1;
		}
		level.zombiemode_using_additionalprimaryweapon_perk = 1;
		level.zombiemode_using_divetonuke_perk = 1;
		level.phdUsesClientfield = 0;
		maps/mp/zombies/_zm_perk_divetonuke::enable_divetonuke_perk_for_level();
	}
	if ( isDefined(map) && map == "rooftop" )
	{
		level.electric_chair_player_thread_custom_func = ::custom_electric_chair_player_thread;
		level.track_quest_status_thread_custom_func = ::bridge_reset;
	}
	if ( maps/mp/zombies/_zm_utility::is_gametype_active( "zclassic" ) )
	{
		level.zombiemode_using_electric_cherry_perk = 1;
		maps/mp/zombies/_zm_perk_electric_cherry::enable_electric_cherry_perk_for_level();
	}
	else if ( maps/mp/zombies/_zm_utility::is_gametype_active( "zgrief" ) )
	{
		level.zombiemode_using_additionalprimaryweapon_perk = 1;
		level.zombiemode_using_divetonuke_perk = 1;
		maps/mp/zombies/_zm_perk_divetonuke::enable_divetonuke_perk_for_level();
	}
	level._zmbvoxlevelspecific = ::init_level_specific_audio;
	level.random_pandora_box_start = 1;
	if ( is_classic() )
	{
		level._default_door_custom_logic = ::alcatraz_afterlife_doors;
	}
	level.register_offhand_weapons_for_level_defaults_override = ::offhand_weapon_overrride;
	level.zombiemode_offhand_weapon_give_override = ::offhand_weapon_give_override;
	level.max_equipment_attack_range = 72;
	level.min_equipment_attack_range = 25;
	level.vert_equipment_attack_range = 55;
	level._zombie_custom_add_weapons = ::custom_add_weapons;
	level._allow_melee_weapon_switching = 1;
	level._no_vending_machine_bump_trigs = 1;
	level.custom_ai_type = [];
	precachemodel( "p6_zm_al_wall_trap_control_red" );
	precachemodel( "p6_zm_al_gondola_frame_light_red" );
	precachemodel( "p6_zm_al_gondola_frame_light_green" );
	precachemodel( "fxanim_zom_al_gondola_chains_mod" );
	if ( maps/mp/zombies/_zm_utility::is_gametype_active( "zgrief" ) )
	{
		precachemodel( "p6_zm_al_shock_box_on" );
	}
	level.raygun2_included = 1;
	include_weapons();
	include_powerups();
	include_equipment_for_level();
	register_level_specific_client_fields();
	level thread maps/mp/zm_alcatraz_distance_tracking::zombie_tracking_init();
	maps/mp/zm_alcatraz_traps::init_fan_trap_animtree();
	maps/mp/zm_alcatraz_travel::init_gondola_chains_animtree();
	maps/mp/zombies/_zm_magicbox_prison::init();
	maps/mp/zombies/_zm::init();
	maps/mp/zombies/_zm_ai_basic::init_inert_zombies();
	maps/mp/zombies/_zm_weap_claymore::init();
	maps/mp/zombies/_zm_weap_riotshield_prison::init();
	maps/mp/zombies/_zm_weap_blundersplat::init();
	maps/mp/zombies/_zm_weap_tomahawk::init();
	level.calc_closest_player_using_paths = 1;
	level._melee_weapons = [];
	precacheitem( "death_throe_zm" );
	if ( level.splitscreen && getDvarInt( "splitscreen_playerCount" ) > 2 )
	{
		level.optimise_for_splitscreen = 1;
		level.culldist = 4000;
	}
	else
	{
		level.optimise_for_splitscreen = 0;
		level.culldist = 18000;
	}
	setculldist( level.culldist );
	if ( isDefined( level.optimise_for_splitscreen ) && level.optimise_for_splitscreen )
	{
		if ( is_classic() )
		{
			level.zombie_ai_limit = 20;
		}
		setdvar( "fx_marks_draw", 0 );
		setdvar( "disable_rope", 1 );
		setdvar( "cg_disableplayernames", 1 );
		setdvar( "disableLookAtEntityLogic", 1 );
	}
	else
	{
		level.zombie_ai_limit = 24;
	}
	setdvar( "zombiemode_path_minz_bias", 13 );
	setdvar( "waypointMaxDrawDist", 12000 );
	level.zombie_vars[ "zombie_use_failsafe" ] = 0;
	level.zones = [];
	level.zone_manager_init_func = ::working_zone_init;
	init_zones = [];
	if ( is_classic() )
	{
		init_zones[ 0 ] = "zone_start";
		init_zones[ 1 ] = "zone_library";
	}
	else
	{
		init_zones[ 0 ] = "zone_cellblock_east";
		init_zones[ 1 ] = "zone_cellblock_west_warden";
		init_zones[ 2 ] = "zone_cellblock_west_barber";
		init_zones[ 3 ] = "zone_cellblock_west";
	}
	level thread maps/mp/zombies/_zm_zonemgr::manage_zones( init_zones );
	level.speed_change_round = 15;
	level.speed_change_max = 5;
	level thread maps/mp/zm_alcatraz_weap_quest::init();
	onplayerconnect_callback( maps/mp/zm_alcatraz_weap_quest::tomahawk_upgrade_quest );
	onplayerconnect_callback( ::riotshield_tutorial_hint );
	onplayerconnect_callback( ::disable_powerup_if_player_on_bridge );
	level thread enable_powerup_if_no_player_on_bridge();
	onplayerconnect_callback( ::player_lightning_manager );
	onplayerconnect_callback( ::player_shockbox_glowfx );
	onplayerconnect_callback( ::player_portal_clue_vo );
	onplayerconnect_callback( maps/mp/zm_alcatraz_grief_cellblock::magicbox_face_spawn );
	maps/mp/_visionset_mgr::vsmgr_register_info( "visionset", "zm_audio_log", 9000, 200, 1, 1 );
	maps/mp/_visionset_mgr::vsmgr_register_info( "visionset", "zm_electric_cherry", 9000, 121, 1, 1 );

	level thread drop_all_barriers();
	level thread check_solo_status();
	level thread maps/mp/zm_prison_ffotd::main_end();
	level thread title_update_main_end();
	//flag_wait( "start_zombie_round_logic" ); //players can't join if this is uncommented
	//map = getDvar( "customMap" );
	if(isDefined(map) && map == "docks")
	{
		thread acid_bench( map, (751, 6572, 210), (0,191,0) );
	}
	if(isDefined(map) && map != "vanilla")
	{
		level thread onplayerconnect();
		level thread onplayerconnected();
		level thread map_setup();
	}
}

map_setup()
{
	map = level.customMap;
	thread disable_afterlife_boxes();
	if ( level.script == "zm_prison" && isDefined( map ) && map == "docks" )
	{
		thread auto_upgrade_tower();
		thread disable_gondola();
		thread disable_doors_docks();
	}
	else if ( level.script == "zm_prison" && isDefined( map ) && map == "cellblock" )
	{
		thread disable_doors_cellblock();
	}
	else if ( level.script == "zm_prison" && isDefined( map ) && map == "rooftop" )
	{
		thread disable_doors_cellblock();
	}
}

onplayerconnect()
{
	level waittill( "connected", player );
	maps/mp/zombies/_zm_game_module::turn_power_on_and_open_doors();
	wait 1;
	flag_set( "power_on" );
	level setclientfield( "zombie_power_on", 1 );
	level notify( "sleight_on" );
	wait_network_frame();
	level notify( "doubletap_on" );
	wait_network_frame();
	level notify( "juggernog_on" );
	wait_network_frame();
	level notify( "electric_cherry_on" );
	wait_network_frame();
	level notify( "deadshot_on" );
	wait_network_frame();
	level notify( "divetonuke_on" );
	wait_network_frame();
	level notify( "additionalprimaryweapon_on" );
	wait_network_frame();
	level notify( "Pack_A_Punch_on" );
	wait_network_frame();
}
onplayerconnected()
{
	for(;;)
	{
		level waittill("connected", player);
		player thread afterlife_doors_close();
	}
}

acid_bench(map, origin, angles)
{
	//level.soulFX = loadfx("fx_alcatraz_soul_charge");
	level.soulDistance = 400;
	bench = spawn("script_model", origin);
	bench SetModel("p6_zm_work_bench");
	bench.angles = angles;
	bench.souls = 0;
	//do these for every map separately
	if(isDefined(map) && map == "docks")
	{
		col = spawn("script_model", (758, 6589, 242));
		col SetModel("collision_clip_64x64x64");
		col.angles = angles;
		col2 = spawn("script_model", (764, 6554, 242));
		col2 SetModel("collision_clip_64x64x64");
		col2.angles = angles;
	}
	acidGatModel = spawn("script_model", origin + (0,0,45));
	acidGatModel SetModel("p6_anim_zm_al_packasplat");
	acidGatModel.angles = angles;
	trigger = spawn("trigger_radius", origin + (0,0,32), 0, 35, 70);
	trigger.targetname = "acid_gat_trigger";
	trigger.angles = angles;
	trigger SetHintString("This Machine Needs Power");
	trigger SetCursorHint("HINT_NOICON");
	thread watchZombies(bench);
	level waittill("soulsAreDone");
	wait 2;
	trigger SetHintString("Hold ^3&&1^7 to convert Blundergat into Acidgat");
	for(;;)
	{
		trigger waittill("trigger", player);
		if(player UseButtonPressed())
		{
			weap = player GetCurrentWeapon();
			if(weap == "blundergat_zm" || weap == "blundergat_upgraded_zm")
			{
				if(weap == "blundergat_zm")
				{
					player TakeWeapon("blundergat_zm");
				}
				else if(weap == "blundergat_upgraded_zm")
				{
					player TakeWeapon("blundergat_upgraded_zm");
				}
				trigger SetHintString("Converting...");
				wait 5;
				trigger SetHintString("Hold ^3&&1^7 for Acidgat");
				for(;;)
				{
					if(player UseButtonPressed() && Distance(player.origin, trigger.origin) < 65)
					{
						if(weap == "blundergat_zm")
						{
							player GiveWeapon("blundersplat_zm");
							player SwitchToWeapon("blundersplat_zm");
							break;
						}
						else if(weap == "blundergat_upgraded_zm")
						{
							player GiveWeapon("blundersplat_upgraded_zm");
							player SwitchToWeapon("blundersplat_upgraded_zm");
							break;
						}
					}
					wait .1;
				}
			}
		}
		wait .1;
		trigger SetHintString("Hold ^3&&1^7 to convert Blundergat into Acidgat");
	}
}

watchZombies(bench)
{
	level endon("soulsAreDone");
	while(1)
	{
		zombies = GetAiSpeciesArray( "axis", "all" );
		for(i=0;i<zombies.size;i++)
		{
			if(!isdefined(zombies[i].soulChest))
				zombies[i] thread watchMe(bench);
		}
		wait(.05);
	}
}

watchMe(bench)
{
	level endon("soulsAreDone");
	self.soulChest = true;
	//IPrintLn("A zombie has been threaded");
	self waittill("death");
	if(!isdefined(self))
	{
		return;
	}
	start = self.origin + (0,0,45);
	if(!isdefined(start))
	{
		return;
	}
	closest = level.soulDistance;
	newbench = undefined;
	if(Distance(start, bench.origin) < closest )
	{
		closest = Distance(start, bench.origin);
		newbench = bench;
	}
	if(!isDefined(newbench) || !isDefined(newbench.origin))
	{
		return;
	}
	bench.souls++;
	//IPrintLn(bench.souls);
	newbench thread sendSoul(start);
	if(bench.souls >= 15)
	{
		level notify("soulsAreDone");
	}
}

sendSoul(start)
{
	if(isdefined(self))
	{
		end = self.origin + (0,0,45);
	}
	if(!isdefined(start) || !isdefined(end))
	{
		return;
	}
	fxOrg = Spawn("script_model", start);
	fxOrg SetModel("tag_origin");
	fx = PlayFxOnTag( level._effect[ "powerup_on" ], fxOrg, "tag_origin" );
	fxOrg MoveTo(end, 2);
	wait 2;
	fx Delete();
	fxOrg Delete();
}

title_update_main_start() //checked matches cerberus output
{
}

title_update_main_end() //checked changed to match cerberus output
{
	a_nodes = getanynodearray( ( 969, 6708, 239 ), 200 );
	foreach ( node in a_nodes )
	{
		node.no_teleport = 1;
	}
	level.equipment_tu_dead_zone_pos = [];
	level.equipment_tu_dead_zone_rad2 = [];
	level.equipment_tu_dead_zone_pos[ 0 ] = ( 447, 5963, 275 );
	level.equipment_tu_dead_zone_rad2[ 0 ] = 2500;
	level.equipment_tu_dead_zone_pos[ 1 ] = ( 896, 8400, 1544 );
	level.equipment_tu_dead_zone_rad2[ 1 ] = 14400;
}

register_level_specific_client_fields()
{
	registerclientfield( "actor", "fan_trap_blood_fx", 9000, 1, "int" );
	registerclientfield( "actor", "acid_trap_death_fx", 9000, 1, "int" );
	registerclientfield( "toplayer", "toggle_lightning", 9000, 1, "int" );
	registerclientfield( "toplayer", "rumble_electric_chair", 9000, 2, "int" );
	registerclientfield( "toplayer", "effects_escape_flight", 9000, 3, "int" );
	registerclientfield( "toplayer", "rumble_gondola", 9000, 1, "int" );
	registerclientfield( "toplayer", "rumble_fan_trap", 9000, 1, "int" );
	registerclientfield( "toplayer", "rumble_sq_bg", 9000, 1, "int" );
	registerclientfield( "toplayer", "rumble_door_open", 9000, 1, "int" );
	registerclientfield( "world", "toggle_futz", 9000, 1, "int" );
	registerclientfield( "world", "dryer_stage", 9000, 2, "int" );
	registerclientfield( "world", "fog_stage", 9000, 2, "int" );
	registerclientfield( "world", "scripted_lightning_flash", 9000, 1, "int" );
	registerclientfield( "world", "warden_fence_down", 9000, 1, "int" );
	registerclientfield( "world", "master_key_is_lowered", 9000, 1, "int" );
	registerclientfield( "world", "fxanim_pulley_down_start", 9000, 2, "int" );
	registerclientfield( "world", "sq_bg_reward_portal", 9000, 1, "int" );
	registerclientfield( "toplayer", "spoon_visual_state", 9000, 2, "int" );
	registerclientfield( "scriptmover", "afterlife_shockbox_glow", 9000, 1, "int" );
	registerclientfield( "scriptmover", "toggle_perk_machine_power", 9000, 2, "int" );
}

givecustomloadout( takeallweapons, alreadyspawned )
{
	self giveweapon( "knife_zm_alcatraz" );
	self set_player_melee_weapon( "knife_zm_alcatraz" );
	self give_start_weapon( 1 );
}

custom_vending_precaching() //checked changed to match cerberus output
{
	precacheshader( "specialty_electric_cherry_zombie" );
	if ( level._custom_perks.size > 0 )
	{
		a_keys = getarraykeys( level._custom_perks );
		for ( i = 0; i < a_keys.size; i++ )
		{
			if ( isDefined( level._custom_perks[ a_keys[ i ] ].precache_func ) )
			{
				level [[ level._custom_perks[ a_keys[ i ] ].precache_func ]]();
			}
		}
	}
	if ( isDefined( level.zombiemode_using_pack_a_punch ) && level.zombiemode_using_pack_a_punch )
	{
		precacheitem( "zombie_knuckle_crack" );
		precachemodel( "p6_anim_zm_buildable_pap" );
		precachemodel( "p6_anim_zm_buildable_pap_on" );
		precachestring( &"ZOMBIE_PERK_PACKAPUNCH" );
		precachestring( &"ZOMBIE_PERK_PACKAPUNCH_ATT" );
		level._effect[ "packapunch_fx" ] = loadfx( "maps/zombie/fx_zombie_packapunch" );
		level.machine_assets[ "packapunch" ] = spawnstruct();
		level.machine_assets[ "packapunch" ].weapon = "zombie_knuckle_crack";
		level.machine_assets[ "packapunch" ].off_model = "p6_zm_al_vending_pap_on";
		level.machine_assets[ "packapunch" ].on_model = "p6_zm_al_vending_pap_on";
		level.machine_assets[ "packapunch" ].power_on_callback = ::custom_vending_power_on;
		level.machine_assets[ "packapunch" ].power_off_callback = ::custom_vending_power_off;
	}
	if ( isDefined( level.zombiemode_using_additionalprimaryweapon_perk ) && level.zombiemode_using_additionalprimaryweapon_perk )
	{
		precacheitem( "zombie_perk_bottle_additionalprimaryweapon" );
		precacheshader( "specialty_additionalprimaryweapon_zombies" );
		precachemodel( "p6_zm_al_vending_three_gun_on" );
		precachestring( &"ZOMBIE_PERK_ADDITIONALWEAPONPERK" );
		level._effect[ "additionalprimaryweapon_light" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_perk_smk" );
		level.machine_assets[ "additionalprimaryweapon" ] = spawnstruct();
		level.machine_assets[ "additionalprimaryweapon" ].weapon = "zombie_perk_bottle_sleight";
		level.machine_assets[ "additionalprimaryweapon" ].off_model = "p6_zm_al_vending_three_gun_on";
		level.machine_assets[ "additionalprimaryweapon" ].on_model = "p6_zm_al_vending_three_gun_on";
		level.machine_assets[ "additionalprimaryweapon" ].power_on_callback = ::custom_vending_power_on;
		level.machine_assets[ "additionalprimaryweapon" ].power_off_callback = ::custom_vending_power_off;
	}
	if ( isDefined( level.zombiemode_using_deadshot_perk ) && level.zombiemode_using_deadshot_perk )
	{
		precacheitem( "zombie_perk_bottle_deadshot" );
		precacheshader( "specialty_ads_zombies" );
		precachemodel( "p6_zm_al_vending_ads_on" );
		precachestring( &"ZOMBIE_PERK_DEADSHOT" );
		level._effect[ "deadshot_light" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_perk_smk" );
		level.machine_assets[ "deadshot" ] = spawnstruct();
		level.machine_assets[ "deadshot" ].weapon = "zombie_perk_bottle_deadshot";
		level.machine_assets[ "deadshot" ].off_model = "p6_zm_al_vending_ads_on";
		level.machine_assets[ "deadshot" ].on_model = "p6_zm_al_vending_ads_on";
		level.machine_assets[ "deadshot" ].power_on_callback = ::custom_vending_power_on;
		level.machine_assets[ "deadshot" ].power_off_callback = ::custom_vending_power_off;
	}
	if ( isDefined( level.zombiemode_using_divetonuke_perk ) && level.zombiemode_using_divetonuke_perk )
	{
		//precacheitem( "zombie_perk_bottle_nuke" );
		precacheshader( "specialty_divetonuke_zombies" );
		precachemodel( "p6_zm_al_vending_nuke_on" );
		//precachestring( &"ZOMBIE_PERK_DIVETONUKE" );
		//level._effect[ "divetonuke_light" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_perk_smk" );
		level.machine_assets[ "divetonuke" ] = spawnstruct();
		level.machine_assets[ "divetonuke" ].weapon = "zombie_perk_bottle_deadshot";
		level.machine_assets[ "divetonuke" ].off_model = "p6_zm_al_vending_nuke_on";
		level.machine_assets[ "divetonuke" ].on_model = "p6_zm_al_vending_nuke_on";
		level.machine_assets[ "divetonuke" ].power_on_callback = ::custom_vending_power_on;
		level.machine_assets[ "divetonuke" ].power_off_callback = ::custom_vending_power_off;
	}
	if ( isDefined( level.zombiemode_using_doubletap_perk ) && level.zombiemode_using_doubletap_perk )
	{
		precacheitem( "zombie_perk_bottle_doubletap" );
		precacheshader( "specialty_doubletap_zombies" );
		precachemodel( "p6_zm_al_vending_doubletap2_on" );
		precachestring( &"ZOMBIE_PERK_DOUBLETAP" );
		level._effect[ "doubletap_light" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_perk_smk" );
		level.machine_assets[ "doubletap" ] = spawnstruct();
		level.machine_assets[ "doubletap" ].weapon = "zombie_perk_bottle_doubletap";
		level.machine_assets[ "doubletap" ].off_model = "p6_zm_al_vending_doubletap2_on";
		level.machine_assets[ "doubletap" ].on_model = "p6_zm_al_vending_doubletap2_on";
		level.machine_assets[ "doubletap" ].power_on_callback = ::custom_vending_power_on;
		level.machine_assets[ "doubletap" ].power_off_callback = ::custom_vending_power_off;
	}
	if ( isDefined( level.zombiemode_using_juggernaut_perk ) && level.zombiemode_using_juggernaut_perk )
	{
		precacheitem( "zombie_perk_bottle_jugg" );
		precacheshader( "specialty_juggernaut_zombies" );
		precachemodel( "p6_zm_al_vending_jugg_on" );
		precachestring( &"ZOMBIE_PERK_JUGGERNAUT" );
		level._effect[ "jugger_light" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_perk_smk" );
		level.machine_assets[ "juggernog" ] = spawnstruct();
		level.machine_assets[ "juggernog" ].weapon = "zombie_perk_bottle_jugg";
		level.machine_assets[ "juggernog" ].off_model = "p6_zm_al_vending_jugg_on";
		level.machine_assets[ "juggernog" ].on_model = "p6_zm_al_vending_jugg_on";
		level.machine_assets[ "juggernog" ].power_on_callback = ::custom_vending_power_on;
		level.machine_assets[ "juggernog" ].power_off_callback = ::custom_vending_power_off;
	}
	if ( isDefined( level.zombiemode_using_marathon_perk ) && level.zombiemode_using_marathon_perk )
	{
		precachestring( &"ZOMBIE_PERK_MARATHON" );
		precacheshader("specialty_doublepoints_zombies");
		//level._effect[ "marathon_light" ] = loadfx( "maps/zombie/fx_alcatraz_perk_smk" );
		level.machine_assets[ "marathon" ] = spawnstruct();
		level.machine_assets[ "marathon" ].weapon = "zombie_perk_bottle_doubletap";
		level.machine_assets[ "marathon" ].off_model = "p6_zm_al_vending_doubletap2_on";
		level.machine_assets[ "marathon" ].on_model = "p6_zm_al_vending_doubletap2_on";
	}
	if ( isDefined( level.zombiemode_using_revive_perk ) && level.zombiemode_using_revive_perk )
	{
		precacheshader( "specialty_instakill_zombies" );
		//precachemodel( "zombie_vending_revive" );
		//precachemodel( "zombie_vending_revive_on" );
		precachestring( &"ZOMBIE_PERK_QUICKREVIVE" );
		//level._effect[ "revive_light" ] = loadfx( "misc/fx_zombie_cola_revive_on" );
		//level._effect[ "revive_light_flicker" ] = loadfx( "maps/zombie/fx_zmb_cola_revive_flicker" );
		level.machine_assets[ "revive" ] = spawnstruct();
		level.machine_assets[ "revive" ].weapon = "zombie_perk_bottle_cherry";
		level.machine_assets[ "revive" ].off_model = "p6_zm_vending_electric_cherry_off";
		level.machine_assets[ "revive" ].on_model = "p6_zm_vending_electric_cherry_on";
	}
	if ( isDefined( level.zombiemode_using_sleightofhand_perk ) && level.zombiemode_using_sleightofhand_perk )
	{
		precacheitem( "zombie_perk_bottle_sleight" );
		precacheshader( "specialty_fastreload_zombies" );
		precachemodel( "p6_zm_al_vending_sleight_on" );
		precachestring( &"ZOMBIE_PERK_FASTRELOAD" );
		level._effect[ "sleight_light" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_perk_smk" );
		level.machine_assets[ "speedcola" ] = spawnstruct();
		level.machine_assets[ "speedcola" ].weapon = "zombie_perk_bottle_sleight";
		level.machine_assets[ "speedcola" ].off_model = "p6_zm_al_vending_sleight_on";
		level.machine_assets[ "speedcola" ].on_model = "p6_zm_al_vending_sleight_on";
		level.machine_assets[ "speedcola" ].power_on_callback = ::custom_vending_power_on;
		level.machine_assets[ "speedcola" ].power_off_callback = ::custom_vending_power_off;
	}
	if ( isDefined( level.zombiemode_using_tombstone_perk ) && level.zombiemode_using_tombstone_perk )
	{
		precacheitem( "zombie_perk_bottle_tombstone" );
		precacheshader( "specialty_tombstone_zombies" );
		precachemodel( "zombie_vending_tombstone" );
		precachemodel( "zombie_vending_tombstone_on" );
		precachemodel( "ch_tombstone1" );
		precachestring( &"ZOMBIE_PERK_TOMBSTONE" );
		level._effect[ "tombstone_light" ] = loadfx( "misc/fx_zombie_cola_on" );
		level.machine_assets[ "tombstone" ] = spawnstruct();
		level.machine_assets[ "tombstone" ].weapon = "zombie_perk_bottle_tombstone";
		level.machine_assets[ "tombstone" ].off_model = "zombie_vending_tombstone";
		level.machine_assets[ "tombstone" ].on_model = "zombie_vending_tombstone_on";
	}
	if ( isDefined( level.zombiemode_using_chugabud_perk ) && level.zombiemode_using_chugabud_perk )
	{
		precacheitem( "zombie_perk_bottle_whoswho" );
		precacheshader( "specialty_quickrevive_zombies" );
		precachemodel( "p6_zm_vending_chugabud" );
		precachemodel( "p6_zm_vending_chugabud_on" );
		precachemodel( "ch_tombstone1" );
		precachestring( &"ZOMBIE_PERK_TOMBSTONE" );
		level._effect[ "tombstone_light" ] = loadfx( "misc/fx_zombie_cola_on" );
		level.machine_assets[ "whoswho" ] = spawnstruct();
		level.machine_assets[ "whoswho" ].weapon = "zombie_perk_bottle_whoswho";
		level.machine_assets[ "whoswho" ].off_model = "p6_zm_vending_chugabud";
		level.machine_assets[ "whoswho" ].on_model = "p6_zm_vending_chugabud_on";
	}
}

custom_vending_power_on() //checked matches cerberus output
{
	self setclientfield( "toggle_perk_machine_power", 2 );
}

custom_vending_power_off() //checked matches cerberus output
{
	self setclientfield( "toggle_perk_machine_power", 1 );
}

precache_personality_characters() //checked matches cerberus output
{
	character/c_zom_arlington::precache();
	character/c_zom_deluca::precache();
	character/c_zom_handsome::precache();
	character/c_zom_oleary::precache();
	precachemodel( "c_zom_arlington_coat_viewhands" );
	precachemodel( "c_zom_deluca_longsleeve_viewhands" );
	precachemodel( "c_zom_handsome_sleeveless_viewhands" );
	precachemodel( "c_zom_oleary_shortsleeve_viewhands" );
}

give_personality_characters() //checked matches cerberus output
{
	if ( isDefined( level.hotjoin_player_setup ) && [[ level.hotjoin_player_setup ]]( "c_zom_arlington_coat_viewhands" ) )
	{
		return;
	}
	self detachall();
	if ( !isDefined( self.characterindex ) )
	{
		self.characterindex = assign_lowest_unused_character_index();
	}
	self.favorite_wall_weapons_list = [];
	/*
/#
	if ( getDvar( #"40772CF1" ) != "" )
	{
		self.characterindex = getDvarInt( #"40772CF1" );
#/
	}
	*/
	map = level.customMap;
	if(isDefined(map) && map != "vanilla")
	{
		switch(self.characterindex)
		{
			case 0:
				self setmodel( "c_zom_player_oleary_fb" );
				self set_player_is_female( 0 );
				self.voice = "american";
				self.skeleton = "base";
				self setviewmodel( "c_zom_oleary_shortsleeve_viewhands" );
				self.characterindex = 0;
				self.character_name = "Gerard";
				break;
			case 1:
				self setmodel( "c_zom_player_oleary_fb" );
				self set_player_is_female( 0 );
				self.voice = "american";
				self.skeleton = "base";
				self setviewmodel( "c_zom_oleary_shortsleeve_viewhands" );
				self.characterindex = 0;
				self.character_name = "Cahz";
				break;
			case 2:
				self setmodel( "c_zom_player_oleary_fb" );
				self set_player_is_female( 0 );
				self.voice = "american";
				self.skeleton = "base";
				self setviewmodel( "c_zom_oleary_shortsleeve_viewhands" );
				self.characterindex = 0;
				self.character_name = "Jezuz";
			case 3:
				self setmodel( "c_zom_player_oleary_fb" );
				self set_player_is_female( 0 );
				self.voice = "american";
				self.skeleton = "base";
				self setviewmodel( "c_zom_oleary_shortsleeve_viewhands" );
				self.characterindex = 0;
				self.character_name = "Rekti";
		}
	}
	else{
		switch( self.characterindex )
		{
			case 0:
				self character/c_zom_oleary::main();
				self setviewmodel( "c_zom_oleary_shortsleeve_viewhands" );
				level.vox maps/mp/zombies/_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
				self.favorite_wall_weapons_list[ self.favorite_wall_weapons_list.size ] = "judge_zm";
				self set_player_is_female( 0 );
				self.character_name = "Finn";
				break;
			case 1:
				self character/c_zom_deluca::main();
				self setviewmodel( "c_zom_deluca_longsleeve_viewhands" );
				level.vox maps/mp/zombies/_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
				self.favorite_wall_weapons_list[ self.favorite_wall_weapons_list.size ] = "thompson_zm";
				self set_player_is_female( 0 );
				self.character_name = "Sal";
				break;
			case 2:
				self character/c_zom_handsome::main();
				self setviewmodel( "c_zom_handsome_sleeveless_viewhands" );
				level.vox maps/mp/zombies/_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
				self.favorite_wall_weapons_list[ self.favorite_wall_weapons_list.size ] = "blundergat_zm";
				self set_player_is_female( 0 );
				self.character_name = "Billy";
				break;
			case 3:
				self character/c_zom_arlington::main();
				self setviewmodel( "c_zom_arlington_coat_viewhands" );
				level.vox maps/mp/zombies/_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
				self.favorite_wall_weapons_list[ self.favorite_wall_weapons_list.size ] = "ray_gun_zm";
				self set_player_is_female( 0 );
				self.character_name = "Arlington";
				break;
		}
	}
	self setmovespeedscale( 1 );
	self setsprintduration( 4 );
	self setsprintcooldown( 0 );
	self thread set_exert_id();
}

set_exert_id() //checked matches cerberus output
{
	self endon( "disconnect" );
	wait_network_frame();
	wait_network_frame();
	self maps/mp/zombies/_zm_audio::setexertvoice( self.characterindex + 1 );
}

assign_lowest_unused_character_index() //checked changed to match cerberus output
{
	charindexarray = [];
	charindexarray[ 0 ] = 0;
	charindexarray[ 1 ] = 1;
	charindexarray[ 2 ] = 2;
	charindexarray[ 3 ] = 3;
	players = get_players();
	if ( players.size == 1 )
	{
		charindexarray = array_randomize( charindexarray );
		if ( charindexarray[ 0 ] == 3 )
		{
			level.has_weasel = 1;
		}
		return charindexarray[ 0 ];
	}
	else
	{
		n_characters_defined = 0;
		foreach ( player in players )
		{
			if ( isDefined( player.characterindex ) )
			{
				arrayremovevalue( charindexarray, player.characterindex, 0 );
				n_characters_defined++;
			}
		}
		if ( charindexarray.size > 0 )
		{
			if ( n_characters_defined == ( players.size - 1 ) )
			{
				if ( isDefined( level.has_weasel ) && !level.has_weasel )
				{
					level.has_weasel = 1;
					return 3;
				}
			}
			charindexarray = array_randomize( charindexarray );
			if ( charindexarray[ 0 ] == 3 )
			{
				level.has_weasel = 1;
			}
			return charindexarray[ 0 ];
		}
	}
	return 0;
}

initcharacterstartindex() //checked matches cerberus output
{
	level.characterstartindex = randomint( 4 );
}

zombie_init_done() //checked matches cerberus output
{
	self.allowpain = 0;
	self setphysparams( 15, 0, 48 );
}

zm_player_fake_death_cleanup() //checked matches cerberus output
{
	if ( isDefined( self._fall_down_anchor ) )
	{
		self._fall_down_anchor delete();
		self._fall_down_anchor = undefined;
	}
}

zm_player_fake_death( vdir ) //checked matches cerberus output
{
	level notify( "fake_death" );
	self notify( "fake_death" );
	stance = self getstance();
	self.ignoreme = 1;
	self enableinvulnerability();
	self takeallweapons();
	if ( isDefined( self.insta_killed ) && self.insta_killed )
	{
		self maps/mp/zombies/_zm::player_fake_death();
		self allowprone( 1 );
		self allowcrouch( 0 );
		self allowstand( 0 );
		wait 0.25;
		self freezecontrols( 1 );
	}
	else
	{
		self freezecontrols( 1 );
		self thread fall_down( vdir, stance );
		wait 1;
	}
}

fall_down( vdir, stance ) //checked matches cerberus output
{
	self endon( "disconnect" );
	level endon( "game_module_ended" );
	self ghost();
	origin = self.origin;
	xyspeed = ( 0, 0, 0 );
	angles = self getplayerangles();
	angles = ( angles[ 0 ], angles[ 1 ], angles[ 2 ] + randomfloatrange( -5, 5 ) );
	if ( isDefined( vdir ) && length( vdir ) > 0 )
	{
		xyspeedmag = 40 + randomint( 12 ) + randomint( 12 );
		xyspeed = xyspeedmag * vectornormalize( ( vdir[ 0 ], vdir[ 1 ], 0 ) );
	}
	linker = spawn( "script_origin", ( 0, 0, 0 ) );
	linker.origin = origin;
	linker.angles = angles;
	self._fall_down_anchor = linker;
	self playerlinkto( linker );
	self playsoundtoplayer( "zmb_player_death_fall", self );
	falling = stance != "prone";
	if ( falling )
	{
		origin = playerphysicstrace( origin, origin + xyspeed );
		eye = self get_eye();
		floor_height = ( 10 + origin[ 2 ] ) - eye[ 2 ];
		origin += ( 0, 0, floor_height );
		lerptime = 0.5;
		linker moveto( origin, lerptime, lerptime );
		linker rotateto( angles, lerptime, lerptime );
	}
	self freezecontrols( 1 );
	if ( falling )
	{
		linker waittill( "movedone" );
	}
	self giveweapon( "death_throe_zm" );
	self switchtoweapon( "death_throe_zm" );
	if ( falling )
	{
		bounce = randomint( 4 ) + 8;
		origin = ( origin + ( 0, 0, bounce ) ) - ( xyspeed * 0.1 );
		lerptime = bounce / 50;
		linker moveto( origin, lerptime, 0, lerptime );
		linker waittill( "movedone" );
		origin = ( origin + ( 0, 0, bounce * -1 ) ) + ( xyspeed * 0.1 );
		lerptime /= 2;
		linker moveto( origin, lerptime, lerptime );
		linker waittill( "movedone" );
		linker moveto( origin, 5, 0 );
	}
	wait 15;
	linker delete();
}

initial_round_wait_func() //checked matches cerberus output
{
	flag_wait( "initial_blackscreen_passed" );
}

offhand_weapon_overrride() //checked matches cerberus output
{
	register_lethal_grenade_for_level( "frag_grenade_zm" );
	level.zombie_lethal_grenade_player_init = "frag_grenade_zm";
	register_tactical_grenade_for_level( "emp_grenade_zm" );
	register_placeable_mine_for_level( "claymore_zm" );
	register_melee_weapon_for_level( "knife_zm" );
	register_melee_weapon_for_level( "knife_zm_alcatraz" );
	register_melee_weapon_for_level( "spoon_zm_alcatraz" );
	register_melee_weapon_for_level( "spork_zm_alcatraz" );
	register_melee_weapon_for_level( "bowie_knife_zm" );
	level.zombie_melee_weapon_player_init = "knife_zm_alcatraz";
	register_equipment_for_level( "alcatraz_shield_zm" );
	level.zombie_equipment_player_init = undefined;
	level.equipment_safe_to_drop = ::equipment_safe_to_drop;
}

equipment_safe_to_drop( weapon ) //checked changed to match cerberus output
{
	if ( !isDefined( self.origin ) )
	{
		return 1;
	}
	for ( i = 0; i < level.equipment_tu_dead_zone_pos.size; i++ )
	{
		if ( distancesquared( level.equipment_tu_dead_zone_pos[ i ], weapon.origin ) < level.equipment_tu_dead_zone_rad2[ i ] )
		{
			return 0;
		}
	}
	s_check = getstruct( "plane_equipment_safe_check", "targetname" );
	if ( distance2dsquared( self.origin, s_check.origin ) < 65536 && self.origin[ 2 ] > s_check.origin[ 2 ] )
	{
		return 0;
	}
	return 1;
}

offhand_weapon_give_override( str_weapon ) //checked matches cerberus output
{
	self endon( "death" );
	if ( is_tactical_grenade( str_weapon ) && isDefined( self get_player_tactical_grenade() ) && !self is_player_tactical_grenade( str_weapon ) )
	{
		self setweaponammoclip( self get_player_tactical_grenade(), 0 );
		self takeweapon( self get_player_tactical_grenade() );
	}
	return 0;
}

custom_add_weapons() //checked changed to match cerberus output
{
	add_zombie_weapon_prison( "m1911_zm", "m1911_upgraded_zm", &"ZOMBIE_WEAPON_M1911", 50, "wpck_crappy", "", undefined );
	add_zombie_weapon_prison( "judge_zm", "judge_upgraded_zm", &"ZOMBIE_WEAPON_JUDGE", 50, "wpck_pistol", "", undefined, 1 );
	add_zombie_weapon_prison( "fiveseven_zm", "fiveseven_upgraded_zm", &"ZOMBIE_WEAPON_FIVESEVEN", 50, "wpck_pistol", "", undefined, 1 );
	add_zombie_weapon_prison( "beretta93r_zm", "beretta93r_upgraded_zm", &"ZOMBIE_WEAPON_BERETTA93r", 900, "wpck_pistol", "", undefined );
	add_zombie_weapon_prison( "fivesevendw_zm", "fivesevendw_upgraded_zm", &"ZOMBIE_WEAPON_FIVESEVENDW", 50, "wpck_dual", "", undefined, 1 );
	add_zombie_weapon_prison( "uzi_zm", "uzi_upgraded_zm", &"ZOMBIE_WEAPON_UZI", 1500, "wpck_smg", "", undefined );
	add_zombie_weapon_prison( "thompson_zm", "thompson_upgraded_zm", &"ZMWEAPON_THOMPSON_WALLBUY", 1500, "wpck_smg", "", 800 );
	add_zombie_weapon_prison( "mp5k_zm", "mp5k_upgraded_zm", &"ZOMBIE_WEAPON_MP5K", 1000, "wpck_smg", "", 500 );
	add_zombie_weapon_prison( "pdw57_zm", "pdw57_upgraded_zm", &"ZOMBIE_WEAPON_MP5K", 1200, "wpck_crappy", "", undefined, 1 );
	add_zombie_weapon_prison( "870mcs_zm", "870mcs_upgraded_zm", &"ZOMBIE_WEAPON_870MCS", 1200, "wpck_shot", "", undefined );
	add_zombie_weapon_prison( "rottweil72_zm", "rottweil72_upgraded_zm", &"ZOMBIE_WEAPON_ROTTWEIL72", 500, "wpck_shot", "", undefined );
	add_zombie_weapon_prison( "saiga12_zm", "saiga12_upgraded_zm", &"ZOMBIE_WEAPON_SAIGA12", 50, "wpck_shot", "", undefined, 1 );
	add_zombie_weapon_prison( "blundergat_zm", "blundergat_upgraded_zm", &"ZOMBIE_WEAPON_BLUNDERGAT", 500, "wpck_shot", "", undefined, 1 );
	add_zombie_weapon_prison( "blundersplat_zm", "blundersplat_upgraded_zm", &"ZOMBIE_WEAPON_BLUNDERGAT", 500, "wpck_shot", "", undefined );
	add_zombie_weapon_prison( "ak47_zm", "ak47_upgraded_zm", &"ZOMBIE_WEAPON_AK47", 500, "wpck_mg", "", undefined, 1 );
	add_zombie_weapon_prison( "m14_zm", "m14_upgraded_zm", &"ZOMBIE_WEAPON_M14", 500, "wpck_mg", "", undefined );
	add_zombie_weapon_prison( "tar21_zm", "tar21_upgraded_zm", &"ZOMBIE_WEAPON_TAR21", 50, "wpck_mg", "", undefined, 1 );
	add_zombie_weapon_prison( "galil_zm", "galil_upgraded_zm", &"ZOMBIE_WEAPON_GALIL", 50, "wpck_mg", "", undefined, 1 );
	add_zombie_weapon_prison( "fnfal_zm", "fnfal_upgraded_zm", &"ZOMBIE_WEAPON_FNFAL", 50, "wpck_shot", "", undefined, 1 );
	add_zombie_weapon_prison( "dsr50_zm", "dsr50_upgraded_zm", &"ZOMBIE_WEAPON_DR50", 50, "wpck_snipe", "", undefined, 1 );
	add_zombie_weapon_prison( "barretm82_zm", "barretm82_upgraded_zm", &"ZOMBIE_WEAPON_BARRETM82", 50, "wpck_snipe", "", undefined, 1 );
	add_zombie_weapon_prison( "minigun_alcatraz_zm", "minigun_alcatraz_upgraded_zm", &"ZOMBIE_WEAPON_RPD", 50, "wpck_mg", "", undefined, 1 );
	add_zombie_weapon_prison( "lsat_zm", "lsat_upgraded_zm", &"ZOMBIE_WEAPON_RPD", 50, "wpck_mg", "", undefined, 1 );
	add_zombie_weapon_prison( "frag_grenade_zm", undefined, &"ZOMBIE_WEAPON_FRAG_GRENADE", 250, "grenade", "", 250 );
	add_zombie_weapon_prison( "claymore_zm", undefined, &"ZOMBIE_WEAPON_CLAYMORE", 1500, "grenade", "", undefined );
	add_zombie_weapon_prison( "willy_pete_zm", undefined, &"ZOMBIE_WEAPON_SMOKE_GRENADE", 250, "grenade", "", 250 );
	add_zombie_weapon_prison( "usrpg_zm", "usrpg_upgraded_zm", &"ZOMBIE_WEAPON_USRPG", 50, "wpck_rpg", "", undefined, 1 );
	add_zombie_weapon_prison( "bouncing_tomahawk_zm", "upgraded_tomahawk_zm", &"ZOMBIE_WEAPON_SATCHEL_2000", 2000, "", "", undefined, 1 );
	add_zombie_weapon_prison( "ray_gun_zm", "ray_gun_upgraded_zm", &"ZOMBIE_WEAPON_RAYGUN", 10000, "wpck_ray", "", undefined, 1 );
	if ( isdefined( level.raygun2_included ) && level.raygun2_included )
	{
		add_zombie_weapon_prison( "raygun_mark2_zm", "raygun_mark2_upgraded_zm", &"ZOMBIE_WEAPON_RAYGUN_MARK2", 10000, "raygun_mark2", "", undefined );
	}
}

include_weapons() //checked changed to match cerberus output
{
	include_weapon( "knife_zm", 0 );
	include_weapon( "knife_zm_alcatraz", 0 );
	include_weapon( "spoon_zm_alcatraz", 0 );
	include_weapon( "spork_zm_alcatraz", 0 );
	include_weapon( "frag_grenade_zm", 0 );
	include_weapon( "claymore_zm", 0 );
	include_weapon( "willy_pete_zm", 0 );
	include_weapon( "m1911_zm", 0 );
	include_weapon( "m1911_upgraded_zm", 0 );
	include_weapon( "judge_zm" );
	include_weapon( "judge_upgraded_zm", 0 );
	include_weapon( "beretta93r_zm", 0 );
	include_weapon( "beretta93r_upgraded_zm", 0 );
	include_weapon( "fivesevendw_zm" );
	include_weapon( "fivesevendw_upgraded_zm", 0 );
	include_weapon( "fivesevendw_zm" );
	include_weapon( "fivesevendw_upgraded_zm", 0 );
	include_weapon( "uzi_zm", 0 );
	include_weapon( "uzi_upgraded_zm", 0 );
	if ( is_classic() )
	{
		include_weapon( "thompson_zm", 0 );
		include_weapon( "870mcs_zm", 0 );
	}
	else
	{
		include_weapon( "870mcs_zm" );
		include_weapon( "thompson_zm" );
	}
	include_weapon( "thompson_upgraded_zm", 0 );
	include_weapon( "mp5k_zm", 0 );
	include_weapon( "mp5k_upgraded_zm", 0 );
	include_weapon( "pdw57_zm" );
	include_weapon( "pdw57_upgraded_zm", 0 );
	include_weapon( "870mcs_upgraded_zm", 0 );
	include_weapon( "saiga12_zm" );
	include_weapon( "saiga12_upgraded_zm", 0 );
	include_weapon( "rottweil72_zm", 0 );
	include_weapon( "rottweil72_upgraded_zm", 0 );
	include_weapon( "m14_zm", 0 );
	include_weapon( "m14_upgraded_zm", 0 );
	include_weapon( "ak47_zm" );
	include_weapon( "ak47_upgraded_zm", 0 );
	include_weapon( "tar21_zm" );
	include_weapon( "tar21_upgraded_zm", 0 );
	include_weapon( "galil_zm" );
	include_weapon( "galil_upgraded_zm", 0 );
	include_weapon( "fnfal_zm" );
	include_weapon( "fnfal_upgraded_zm", 0 );
	include_weapon( "dsr50_zm" );
	include_weapon( "dsr50_upgraded_zm", 0 );
	include_weapon( "barretm82_zm" );
	include_weapon( "barretm82_upgraded_zm", 0 );
	include_weapon( "minigun_alcatraz_zm" );
	include_weapon( "minigun_alcatraz_upgraded_zm", 0 );
	include_weapon( "lsat_zm" );
	include_weapon( "lsat_upgraded_zm", 0 );
	include_weapon( "usrpg_zm" );
	include_weapon( "usrpg_upgraded_zm", 0 );
	include_weapon( "ray_gun_zm" );
	include_weapon( "ray_gun_upgraded_zm", 0 );
	include_weapon( "bouncing_tomahawk_zm", 0 );
	include_weapon( "upgraded_tomahawk_zm", 0 );
	include_weapon( "blundergat_zm" );
	include_weapon( "blundergat_upgraded_zm", 0 );
	include_weapon( "blundersplat_zm", 0 );
	include_weapon( "blundersplat_upgraded_zm", 0 );
	level._uses_retrievable_ballisitic_knives = 1;
	include_weapon( "alcatraz_shield_zm", 0 );
	add_limited_weapon( "m1911_zm", 4 );
	add_limited_weapon( "minigun_alcatraz_zm", 1 );
	add_limited_weapon( "blundergat_zm", 1 );
	add_limited_weapon( "ray_gun_zm", 4 );
	add_limited_weapon( "ray_gun_upgraded_zm", 4 );
	include_weapon( "tower_trap_zm", 0 );
	include_weapon( "tower_trap_upgraded_zm", 0 );
	if ( isdefined( level.raygun2_included ) && level.raygun2_included )
	{
		include_weapon( "raygun_mark2_zm" );
		include_weapon( "raygun_mark2_upgraded_zm", 0 );
		add_weapon_to_content( "raygun_mark2_zm", "dlc3" );
		add_limited_weapon( "raygun_mark2_zm", 1);
		add_limited_weapon( "raygun_mark2_upgraded_zm", 1 );
	}
}

add_zombie_weapon_prison( weapon_name, upgrade_name, hint, cost, weaponvo, weaponvoresp, ammo_cost, create_vox ) //checked matches cerberus output
{
	if ( isDefined( level.zombie_include_weapons ) && !isDefined( level.zombie_include_weapons[ weapon_name ] ) )
	{
		return;
	}
	table = "mp/zombiemode.csv";
	table_ammo_cost = tablelookup( table, 0, weapon_name, 2 );
	if ( isDefined( table_ammo_cost ) && table_ammo_cost != "" )
	{
		ammo_cost = round_up_to_ten( int( table_ammo_cost ) );
	}
	precachestring( hint );
	struct = spawnstruct();
	if ( !isDefined( level.zombie_weapons ) )
	{
		level.zombie_weapons = [];
	}
	if ( !isDefined( level.zombie_weapons_upgraded ) )
	{
		level.zombie_weapons_upgraded = [];
	}
	if ( isDefined( upgrade_name ) )
	{
		level.zombie_weapons_upgraded[ upgrade_name ] = weapon_name;
	}
	struct.weapon_name = weapon_name;
	struct.upgrade_name = upgrade_name;
	struct.weapon_classname = "weapon_" + weapon_name;
	struct.hint = hint;
	struct.cost = cost;
	struct.vox = weaponvo;
	struct.vox_response = weaponvoresp;
	/*
/#
	println( "ZM >> Looking for weapon - " + weapon_name );
#/
	*/
	struct.is_in_box = level.zombie_include_weapons[ weapon_name ];
	if ( !isDefined( ammo_cost ) )
	{
		ammo_cost = round_up_to_ten( int( cost * 0.5 ) );
	}
	struct.ammo_cost = ammo_cost;
	level.zombie_weapons[ weapon_name ] = struct;
	if ( isDefined( level.zombiemode_reusing_pack_a_punch ) && level.zombiemode_reusing_pack_a_punch && isDefined( upgrade_name ) )
	{
		add_attachments( weapon_name, upgrade_name );
	}
	if ( isDefined( create_vox ) )
	{
		level.vox maps/mp/zombies/_zm_audio::zmbvoxadd( "player", "weapon_pickup", weapon_name, weaponvo, undefined );
	}
	/*
/#
	if ( isDefined( level.devgui_add_weapon ) )
	{
		[[ level.devgui_add_weapon ]]( weapon_name, upgrade_name, hint, cost, weaponvo, weaponvoresp, ammo_cost );
#/
	}
	*/
}

include_powerups() //checked matches cerberus output
{
	include_powerup( "nuke" );
	include_powerup( "insta_kill" );
	include_powerup( "double_points" );
	include_powerup( "full_ammo" );
	include_powerup( "fire_sale" );
}

include_equipment_for_level() //checked matches cerberus output
{
	include_equipment( "alcatraz_shield_zm" );
}

setup_rex_starts() //checked matches cerberus output
{
	add_gametype( "zclassic", ::dummy, "zclassic", ::dummy );
	add_gametype( "zgrief", ::dummy, "zgrief", ::dummy );
	add_gameloc( "prison", ::dummy, "prison", ::dummy );
	add_gameloc( "cellblock", ::dummy, "cellblock", ::dummy );
}

dummy() //checked matches cerberus output
{
}

working_zone_init() //checked changed to match cerberus output
{
	flag_init( "always_on" );
	flag_set( "always_on" );
	if ( maps/mp/zombies/_zm_utility::is_gametype_active( "zgrief" ) )
	{
		a_s_spawner = getstructarray( "zone_cellblock_west_roof_spawner", "targetname" );
		foreach ( spawner in a_s_spawner )
		{
			if ( isDefined( spawner.script_parameters ) && spawner.script_parameters == "zclassic_prison" )
			{
				spawner structdelete();
			}
		}
	}
	if ( is_classic() )
	{
		add_adjacent_zone( "zone_library", "zone_start", "always_on" );
	}
	else
	{
		add_adjacent_zone( "zone_library", "zone_cellblock_west", "activate_cellblock_west" );
		add_adjacent_zone( "zone_library", "zone_start", "activate_cellblock_west" );
		add_adjacent_zone( "zone_cellblock_east", "zone_start", "activate_cellblock_east" );
		add_adjacent_zone( "zone_library", "zone_start", "activate_cellblock_east" );
	}
	add_adjacent_zone( "zone_library", "zone_cellblock_west", "activate_cellblock_west" );
	add_adjacent_zone( "zone_cellblock_west", "zone_cellblock_west_barber", "activate_cellblock_barber" );
	add_adjacent_zone( "zone_cellblock_west_warden", "zone_cellblock_west_barber", "activate_cellblock_barber" );
	add_adjacent_zone( "zone_cellblock_west_warden", "zone_cellblock_west_barber", "activate_cellblock_gondola" );
	add_adjacent_zone( "zone_cellblock_west", "zone_cellblock_west_gondola", "activate_cellblock_gondola" );
	add_adjacent_zone( "zone_cellblock_west_barber", "zone_cellblock_west_gondola", "activate_cellblock_gondola" );
	add_adjacent_zone( "zone_cellblock_west_gondola", "zone_cellblock_west_barber", "activate_cellblock_gondola" );
	add_adjacent_zone( "zone_cellblock_west_gondola", "zone_cellblock_east", "activate_cellblock_gondola" );
	add_adjacent_zone( "zone_cellblock_west_gondola", "zone_infirmary", "activate_cellblock_infirmary" );
	add_adjacent_zone( "zone_infirmary_roof", "zone_infirmary", "activate_cellblock_infirmary" );
	add_adjacent_zone( "zone_cellblock_west_gondola", "zone_cellblock_west_barber", "activate_cellblock_infirmary" );
	add_adjacent_zone( "zone_cellblock_west_gondola", "zone_cellblock_west", "activate_cellblock_infirmary" );
	add_adjacent_zone( "zone_start", "zone_cellblock_east", "activate_cellblock_east" );
	add_adjacent_zone( "zone_cellblock_west_barber", "zone_cellblock_west_warden", "activate_cellblock_infirmary" );
	add_adjacent_zone( "zone_cellblock_west_barber", "zone_cellblock_east", "activate_cellblock_east_west" );
	add_adjacent_zone( "zone_cellblock_west_barber", "zone_cellblock_west_warden", "activate_cellblock_east_west" );
	add_adjacent_zone( "zone_cellblock_west_warden", "zone_warden_office", "activate_warden_office" );
	add_adjacent_zone( "zone_cellblock_west_warden", "zone_citadel_warden", "activate_cellblock_citadel" );
	add_adjacent_zone( "zone_cellblock_west_warden", "zone_cellblock_west_barber", "activate_cellblock_citadel" );
	add_adjacent_zone( "zone_citadel", "zone_citadel_warden", "activate_cellblock_citadel" );
	add_adjacent_zone( "zone_citadel", "zone_citadel_shower", "activate_cellblock_citadel" );
	add_adjacent_zone( "zone_cellblock_east", "zone_cafeteria", "activate_cafeteria" );
	add_adjacent_zone( "zone_cafeteria", "zone_cafeteria_end", "activate_cafeteria" );
	add_adjacent_zone( "zone_cellblock_east", "cellblock_shower", "activate_shower_room" );
	add_adjacent_zone( "cellblock_shower", "zone_citadel_shower", "activate_shower_citadel" );
	add_adjacent_zone( "zone_citadel_shower", "zone_citadel", "activate_shower_citadel" );
	add_adjacent_zone( "zone_citadel", "zone_citadel_warden", "activate_shower_citadel" );
	add_adjacent_zone( "zone_cafeteria", "zone_infirmary", "activate_infirmary" );
	add_adjacent_zone( "zone_cafeteria", "zone_cafeteria_end", "activate_infirmary" );
	add_adjacent_zone( "zone_infirmary_roof", "zone_infirmary", "activate_infirmary" );
	add_adjacent_zone( "zone_roof", "zone_roof_infirmary", "activate_roof" );
	add_adjacent_zone( "zone_roof_infirmary", "zone_infirmary_roof", "activate_roof" );
	add_adjacent_zone( "zone_citadel", "zone_citadel_stairs", "activate_citadel_stair" );
	add_adjacent_zone( "zone_citadel", "zone_citadel_shower", "activate_citadel_stair" );
	add_adjacent_zone( "zone_citadel", "zone_citadel_warden", "activate_citadel_stair" );
	add_adjacent_zone( "zone_citadel_stairs", "zone_citadel_basement", "activate_citadel_basement" );
	add_adjacent_zone( "zone_citadel_basement", "zone_citadel_basement_building", "activate_citadel_basement" );
	add_adjacent_zone( "zone_citadel_basement", "zone_citadel_basement_building", "activate_basement_building" );
	add_adjacent_zone( "zone_citadel_basement_building", "zone_studio", "activate_basement_building" );
	add_adjacent_zone( "zone_citadel_basement", "zone_studio", "activate_basement_building" );
	add_adjacent_zone( "zone_citadel_basement_building", "zone_dock_gondola", "activate_basement_gondola" );
	add_adjacent_zone( "zone_citadel_basement", "zone_citadel_basement_building", "activate_basement_gondola" );
	add_adjacent_zone( "zone_dock", "zone_dock_gondola", "activate_basement_gondola" );
	add_adjacent_zone( "zone_studio", "zone_dock", "activate_dock_sally" );
	add_adjacent_zone( "zone_dock_gondola", "zone_dock", "activate_dock_sally" );
	add_adjacent_zone( "zone_dock", "zone_dock_gondola", "gondola_roof_to_dock" );
	add_adjacent_zone( "zone_cellblock_west", "zone_cellblock_west_gondola", "gondola_dock_to_roof" );
	add_adjacent_zone( "zone_cellblock_west_barber", "zone_cellblock_west_gondola", "gondola_dock_to_roof" );
	add_adjacent_zone( "zone_cellblock_west_barber", "zone_cellblock_west_warden", "gondola_dock_to_roof" );
	add_adjacent_zone( "zone_cellblock_west_gondola", "zone_cellblock_east", "gondola_dock_to_roof" );
	if ( is_classic() )
	{
		add_adjacent_zone( "zone_gondola_ride", "zone_gondola_ride", "gondola_ride_zone_enabled" );
	}
	if ( is_classic() )
	{
		add_adjacent_zone( "zone_cellblock_west_gondola", "zone_cellblock_west_gondola_dock", "activate_cellblock_infirmary" );
		add_adjacent_zone( "zone_cellblock_west_gondola", "zone_cellblock_west_gondola_dock", "activate_cellblock_gondola" );
		add_adjacent_zone( "zone_cellblock_west_gondola", "zone_cellblock_west_gondola_dock", "gondola_dock_to_roof" );
	}
	if ( maps/mp/zombies/_zm_utility::is_gametype_active( "zgrief" ) )
	{
		playable_area = getentarray( "player_volume", "script_noteworthy" );
		foreach ( area in playable_area )
		{
			if ( isDefined( area.script_parameters ) && area.script_parameters == "classic_only" )
			{
				area delete();
			}
		}
	}
	add_adjacent_zone( "zone_golden_gate_bridge", "zone_golden_gate_bridge", "activate_player_zone_bridge" );
	if ( is_classic() )
	{
		add_adjacent_zone( "zone_dock_puzzle", "zone_dock_puzzle", "always_on" );
	}
}

alcatraz_afterlife_doors() //checked changed to match cerberus output
{
	wait 0.05;
	if ( !isDefined( level.shockbox_anim ) )
	{
		level.shockbox_anim[ "on" ] = %fxanim_zom_al_shock_box_on_anim;
		level.shockbox_anim[ "off" ] = %fxanim_zom_al_shock_box_off_anim;
	}
	if ( isDefined( self.script_noteworthy ) && self.script_noteworthy == "afterlife_door" )
	{
		self sethintstring( &"ZM_PRISON_AFTERLIFE_DOOR" );
		if ( isDefined ( level.customMap ) && level.customMap == "cellblock" || isDefined ( level.customMap ) && level.customMap == "rooftop" )
		{
			if ( self.origin != ( 2138, 9210, 1375 ) )
			{
				self maps/mp/zombies/_zm_blockers::door_opened( 0 );
			}
		}
		/*
/#
		self thread afterlife_door_open_sesame();
#/
		*/
		s_struct = getstruct( self.target, "targetname" );
		if ( !isDefined( s_struct ) )
		{
			/*
/#
			iprintln( "Afterlife Door was not targeting a valid struct" );
#/
			*/
			return;
		}
		m_shockbox = getent( s_struct.target, "targetname" );
		m_shockbox.health = 5000;
		m_shockbox setcandamage( 1 );
		m_shockbox useanimtree( -1 );
		t_bump = spawn( "trigger_radius", m_shockbox.origin, 0, 28, 64 );
		t_bump.origin = ( ( m_shockbox.origin + ( anglesToForward( m_shockbox.angles ) * 0 ) ) + ( anglesToRight( m_shockbox.angles ) * 28 ) ) + ( anglesToUp( m_shockbox.angles ) * 0 );
		if ( isDefined( t_bump ) )
		{
			t_bump setcursorhint( "HINT_NOICON" );
			t_bump sethintstring( &"ZM_PRISON_AFTERLIFE_INTERACT" );
		}
		while ( 1 )
		{
			m_shockbox waittill( "damage", amount, attacker );
			if ( isplayer( attacker ) && attacker getcurrentweapon() == "lightning_hands_zm" )
			{
				if ( isDefined( level.afterlife_interact_dist ) )
				{
					if ( distance2d( attacker.origin, m_shockbox.origin ) < level.afterlife_interact_dist )
					{
						t_bump delete();
						m_shockbox playsound( "zmb_powerpanel_activate" );
						playfxontag( level._effect[ "box_activated" ], m_shockbox, "tag_origin" );
						m_shockbox setmodel( "p6_zm_al_shock_box_on" );
						m_shockbox setanim( level.shockbox_anim[ "on" ] );
						if ( ( m_shockbox.script_string == "wires_shower_door" || m_shockbox.script_string == "wires_admin_door" ) && isDefined( m_shockbox.script_string ) )
						{
							array_delete( getentarray( m_shockbox.script_string, "script_noteworthy" ) );
						}
						attacker notify( "player_opened_afterlife_door" );
						break;
					}
				}
			}
		}
	}
	while ( 1 )
	{
		if ( !self maps/mp/zombies/_zm_blockers::door_buy() )
		{
			wait 0.05;
			continue;
		}
		break;
	}
}

afterlife_door_open_sesame() //checked matches cerberus output
{
	/*
/#
	level waittill( "open_sesame" );
	self maps/mp/zombies/_zm_blockers::door_opened( 0 );
#/
	*/
}

delete_perk_machine_clip() //checked changed to match cerberus output
{
	perk_machines = getentarray( "zombie_vending", "targetname" );
	foreach ( perk_machine in perk_machines )
	{
		if ( isDefined( perk_machine.clip ) )
		{
			perk_machine.clip delete();
		}
	}
}

alcatraz_round_spawn_failsafe() //checked changed to match cerberus output
{
	self endon( "death" );
	prevorigin = self.origin;
	while ( 1 )
	{
		if ( isDefined( self.ignore_round_spawn_failsafe ) && self.ignore_round_spawn_failsafe )
		{
			return;
		}
		wait 15;
		if ( isDefined( self.is_inert ) && self.is_inert )
		{
			continue;
		}
		if ( isDefined( self.lastchunk_destroy_time ) )
		{
			if ( ( getTime() - self.lastchunk_destroy_time ) < 8000 )
			{
				continue;
			}
		}
		if ( self.origin[ 2 ] < -15000 )
		{
			if ( isDefined( level.put_timed_out_zombies_back_in_queue ) && level.put_timed_out_zombies_back_in_queue && !flag( "dog_round" ) && isDefined( self.isscreecher ) && !self.isscreecher )
			{
				level.zombie_total++;
				level.zombie_total_subtract++;
			}
			self dodamage( self.health + 100, ( 0, 0, 0 ) );
			break;
		}
		if ( distancesquared( self.origin, prevorigin ) < 576 )
		{
			if ( isDefined( level.put_timed_out_zombies_back_in_queue ) && level.put_timed_out_zombies_back_in_queue && !flag( "dog_round" ) )
			{
				if ( isDefined( self.nuked ) && !self.nuked && isDefined( self.marked_for_death ) && !self.marked_for_death && isDefined( self.isscreecher ) && !self.isscreecher && isDefined( self.has_legs ) && self.has_legs && isDefined( self.is_brutus ) && !self.is_brutus )
				{
					level.zombie_total++;
					level.zombie_total_subtract++;
				}
			}
			level.zombies_timeout_playspace++;
			if ( isDefined( self.is_brutus ) && self.is_brutus )
			{
				self.suppress_brutus_powerup_drop = 1;
				self.brutus_round_spawn_failsafe = 1;
			}
			self dodamage( self.health + 100, ( 0, 0, 0 ) );
			return;
		}
		prevorigin = self.origin;
	}
}

player_shockbox_glowfx()
{
	self endon( "disconnect" );
	a_afterlife_interacts = getentarray( "afterlife_interact", "targetname" );
	a_afterlife_door_interacts = getentarray( "afterlife_door_shock_box", "script_noteworthy" );
	a_combine = arraycombine( a_afterlife_interacts, a_afterlife_door_interacts, 0, 0 );
	foreach ( shockbox in a_combine )
	{
		if ( issubstr( shockbox.model, "shock_box" ) )
		{
			shockbox setclientfield( "afterlife_shockbox_glow", 1 );
		}
	}
}

/*
is_gametype_active( a_gametypes ) //not in cerberus output 
{
	is_gametype_active = 0;
	if ( !isarray( a_gametypes ) )
	{
		a_gametypes = array( a_gametypes );
	}
	i = 0;
	while ( i < a_gametypes.size )
	{
		if ( getDvar( "g_gametype" ) == a_gametypes[ i ] )
		{
			is_gametype_active = 1;
		}
		i++;
	}
	return is_gametype_active;
}
*/

custom_electric_chair_player_thread( m_linkpoint, chair_number, n_effects_duration )
{
	self endon( "death_or_disconnect" );
	e_home_telepoint = getstruct( "home_telepoint_" + chair_number, "targetname" );
	e_corpse_location = getstruct( "corpse_starting_point_" + chair_number, "targetname" );
	self disableweapons();
	self enableinvulnerability();
	self setstance( "stand" );
	self playerlinktodelta( m_linkpoint, "tag_origin", 1, 20, 20, 20, 20 );
	self setplayerangles( m_linkpoint.angles );
	self playsoundtoplayer( "zmb_electric_chair_2d", self );
	self do_player_general_vox( "quest", "chair_electrocution", undefined, 100 );
	self ghost();
	self.ignoreme = 1;
	self.dontspeak = 1;
	self setclientfieldtoplayer( "isspeaking", 1 );
	wait ( n_effects_duration - 2 );
	switch( self.character_name )
	{
		case "Arlington":
			self playsoundontag( "vox_plr_3_arlington_electrocution_0", "J_Head" );
			break;
		case "Sal":
			self playsoundontag( "vox_plr_1_sal_electrocution_0", "J_Head" );
			break;
		case "Billy":
			self playsoundontag( "vox_plr_2_billy_electrocution_0", "J_Head" );
			break;
		case "Finn":
			self playsoundontag( "vox_plr_0_finn_electrocution_0", "J_Head" );
			break;
	}
	wait 2;
	level.zones[ "zone_golden_gate_bridge" ].is_enabled = 1;
	level.zones[ "zone_golden_gate_bridge" ].is_spawning_allowed = 1;
	self unlink();
	self setstance( "stand" );
	if ( chair_number == 0 )
	{
		self setorigin( ( 2282.9, 9557.3, 1792 ) );
	}
	else if ( chair_number == 1 )
	{
		self setorigin( ( 2304.65, 10019, 1792 ) );
	}
	else if ( chair_number == 2 )
	{
		self setorigin( ( 2642.4, 10023.6, 1792 ) );
	}
	else if ( chair_number == 3 )
	{
		self setorigin( ( 2290.6, 9444.3, 1792 ) );
	}
	else if ( chair_number == 4 )
	{
		self setorigin( ( 2436.5, 9394.1, 1792 ) );
	}
	else if ( chair_number == 5 )
	{
		self setorigin( ( 2540.81, 9263.64, 1792 ) );
	}
	self enableweapons();
	self setclientfieldtoplayer( "rumble_electric_chair", 0 );
	wait 1.5;
	//level thread bridge_reset();
	self disableinvulnerability();
	self Show();
	self.ignoreme = 0;
	self.dontspeak = 0;
}

bridge_reset()
{
	while(1)
	{
		while( level.characters_in_nml.size == 0)
		{
			wait 1;
		}
		while (level.characters_in_nml.size > 0)
		{
			wait 1;
		}
		if( flag( "plane_trip_to_nml_successful" ) )
		{
			flag_clear( "plane_trip_to_nml_successful" );
		}
		/*
		level.players_on_bridge = 0;
		foreach ( player in level.players )
		{
			player.zone = player get_current_zone();
			if( maps/mp/zombies/_zm_utility::is_player_valid( player ) && player.zone == "zone_golden_gate_bridge" )
			{
				level.players_on_bridge++;
			}
		}*/
		//if ( level.players_on_bridge == 0 )
		//{
			level notify( "bridge_empty" );
			level waittill( "start_of_round" );
			prep_for_new_quest();
			waittill_crafted( "refuelable_plane" );
			maps/mp/zombies/_zm_ai_brutus::transfer_plane_trigger( "fuel", "fly" );
			t_plane_fly = getent( "plane_fly_trigger", "targetname" );
			t_plane_fly trigger_on();
		//}
	}
}

auto_upgrade_tower()
{
	level endon( "end_game");
	level endon( "tower_disabled" );
	
	level.enableTowerUpgrade = getDvarIntDefault( "enableTowerUpgrade", 0 );
	level.zombie_vars[ "enableTowerUpgrade" ] = level.enableTowerUpgrade;
	
	if ( !level.enableTowerUpgrade )
	{
		level notify ( "tower_disabled" );
	}
	while ( 1 )
	{
		level waittill( "trap_activated" );
		wait 2;
		level notify( "tower_trap_upgraded" );
	}
}

disable_gondola()
{
	wait 7;
	level notify( "gondola_powered_on_roof" );
	t_call_triggers = getentarray( "gondola_call_trigger", "targetname" );
	call_triggers = getFirstArrayKey( t_call_triggers );
	while ( isDefined( call_triggers ) )
	{
		trigger = t_call_triggers[ call_triggers ];
		trigger.origin = ( 0, 0, 0 );
		return;
	}
}

disable_doors_docks()
{
	zm_doors = getentarray( "zombie_door", "targetname" );
	i = 0;
	while ( i < zm_doors.size )
	{
		if ( zm_doors[ i ].origin == ( 101, 8124, 311 ) )
		{
			zm_doors[ i ].origin = ( 0, 0, 0 );
		}
		i++;
	}
}

disable_doors_cellblock()
{
	zm_doors = getentarray( "zombie_door", "targetname" );
	i = 0;
	while ( i < zm_doors.size )
	{
		if ( zm_doors[ i ].origin == ( 2429, 9793, 1374 ) || zm_doors[ i ].origin == ( 2281, 9484, 1564 ) || zm_doors[ i ].origin == ( -149, 8679, 1166 ) )
		{
			zm_doors[ i ].origin = ( 0, 0, 0 );
		}
		i++;
	}
}

disable_afterlife_boxes()
{
	a_afterlife_triggers = getstructarray( "afterlife_trigger", "targetname" );
	_a87 = a_afterlife_triggers;
	_k87 = getFirstArrayKey( _a87 );
	while ( isDefined( _k87 ) )
	{
		struct = _a87[ _k87 ];
		struct.unitrigger_stub.origin = ( 0, 0, 0 );
		_k87 = getNextArrayKey( _a87, _k87 );
	}
}
