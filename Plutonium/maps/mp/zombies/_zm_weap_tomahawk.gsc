#include maps/mp/zombies/_zm_stats;
#include maps/mp/zombies/_zm_score;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_net;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init() //checked matches cerberus output
{
	registerclientfield( "toplayer", "tomahawk_in_use", 9000, 2, "int" );
	registerclientfield( "toplayer", "upgraded_tomahawk_in_use", 9000, 1, "int" );
	registerclientfield( "scriptmover", "play_tomahawk_fx", 9000, 2, "int" );
	registerclientfield( "actor", "play_tomahawk_hit_sound", 9000, 1, "int" );
	onplayerconnect_callback( ::tomahawk_on_player_connect );
	maps/mp/zombies/_zm_weapons::include_zombie_weapon( "bouncing_tomahawk_zm", 0 );
	maps/mp/zombies/_zm_weapons::include_zombie_weapon( "upgraded_tomahawk_zm", 0 );
	maps/mp/zombies/_zm_weapons::include_zombie_weapon( "zombie_tomahawk_flourish", 0 );
	maps/mp/zombies/_zm_weapons::add_zombie_weapon( "bouncing_tomahawk_zm", "zombie_tomahawk_flourish", &"ZOMBIE_WEAPON_SATCHEL_2000", 2000, "wpck_monkey", "", undefined, 1 );
	maps/mp/zombies/_zm_weapons::add_zombie_weapon( "upgraded_tomahawk_zm", "zombie_tomahawk_flourish", &"ZOMBIE_WEAPON_SATCHEL_2000", 2000, "wpck_monkey", "", undefined, 1 );
	level thread tomahawk_pickup();
	level.zombie_weapons_no_max_ammo = [];
	level.zombie_weapons_no_max_ammo[ "bouncing_tomahawk_zm" ] = 1;
	level.zombie_weapons_no_max_ammo[ "upgraded_tomahawk_zm" ] = 1;
	level.a_tomahawk_pickup_funcs = [];
	if ( isDefined ( level.customMap ) && level.customMap != "vanilla" )
	{
		thread modified_location();
		thread modified_hellhound();
	}
}

modified_location()
{
	if ( isDefined ( level.customMap ) && level.customMap == "docks" )
	{
		tomahawk_effect = getstruct( "tomahawk_pickup_pos", "targetname" );
		tomahawk_effect.origin = ( 981.75, 5818.75, 314.125 );
	
		tomahawk_trigger = getstruct( "tomahawk_trigger_pos", "targetname" );
		tomahawk_trigger.origin = ( 981.75, 5818.75, 314.125 );
	
		tomahawk_upgraded = getent( "spinning_tomahawk_pickup", "targetname" );
		tomahawk_upgraded.origin = ( 981.75, 5818.75, 314.125 );
	
		tomahawk_hellhole_trigger = getent( "trig_cellblock_hellhole", "targetname" );
		tomahawk_hellhole_trigger.origin = ( -58.3, 7880.5, -69 );
	}
	 else if ( isDefined ( level.customMap ) && level.customMap == "cellblock" )
    {
        tomahawk_effect = getstruct( "tomahawk_pickup_pos", "targetname" );
        tomahawk_effect.origin = ( 2157.05, 9287.64, 1608.13 );
        
        tomahawk_trigger = getstruct( "tomahawk_trigger_pos", "targetname" );
        tomahawk_trigger.origin = ( 2157.05, 9287.64, 1608.13 );
        
        tomahawk_upgraded = getent( "spinning_tomahawk_pickup", "targetname" );
        tomahawk_upgraded.origin = ( 2157.05, 9287.64, 1608.13 );
    }
    else if ( isDefined ( level.customMap ) && level.customMap == "rooftop" )
    {
        tomahawk_effect = getstruct( "tomahawk_pickup_pos", "targetname" );
        tomahawk_effect.origin = ( 2506.45, 9283.83, 1578.13 );
        
        tomahawk_trigger = getstruct( "tomahawk_trigger_pos", "targetname" );
        tomahawk_trigger.origin = ( 2506.45, 9283.83, 1578.13 );
        
        tomahawk_upgraded = getent( "spinning_tomahawk_pickup", "targetname" );
        tomahawk_upgraded.origin = ( 2506.45, 9283.83, 1578.13 );
        
        tomahawk_hellhole_trigger = getent( "trig_cellblock_hellhole", "targetname" );
        tomahawk_hellhole_trigger.origin = ( 2222.91, 9012.82, 1678.73 );
    }
}

tomahawk_on_player_connect() //checked matches cerberus output
{
	self.current_tomahawk_weapon = "bouncing_tomahawk_zm";
	self.current_tactical_grenade = "bouncing_tomahawk_zm";
	self thread watch_for_tomahawk_throw();
	self thread watch_for_tomahawk_charge();
	if ( isDefined ( level.customMap ) && level.customMap != "vanilla" )
	{
		self thread tomahawk_upgrade_modified();
		self thread toggle_redeemer_modified();
	}
}

watch_for_tomahawk_throw() //checked changed to match cerberus output
{
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "grenade_fire", grenade, weapname );
		if ( !issubstr( weapname, "tomahawk_zm" ) )
		{
			continue;
		}
		grenade.use_grenade_special_bookmark = 1;
		grenade.grenade_multiattack_bookmark_count = 1;
		grenade.low_level_instant_kill_charge = 1;
		grenade.owner = self;
		self notify( "throwing_tomahawk" );
		if ( isDefined( self.n_tomahawk_cooking_time ) )
		{
			grenade.n_cookedtime = grenade.birthtime - self.n_tomahawk_cooking_time;
		}
		else
		{
			grenade.n_cookedtime = 0;
		}
		self thread check_for_time_out( grenade );
		self thread tomahawk_thrown( grenade );
	}
}

watch_for_tomahawk_charge() //checked changed to match cerberus output
{
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "grenade_pullback", weaponname );
		if ( !issubstr( weaponname, "tomahawk_zm" ) )
		{
			continue;
		}
		self thread watch_for_grenade_cancel();
		self thread play_charge_fx();
		self.n_tomahawk_cooking_time = getTime();
		self waittill_either( "grenade_fire", "grenade_throw_cancelled" );
		wait 0.1;
		self.n_tomahawk_cooking_time = undefined;
	}
}

watch_for_grenade_cancel() //checked matches cerberus output
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "grenade_fire" );
	waittillframeend;
	weapon = "none";
	while ( self isthrowinggrenade() && weapon == "none" )
	{
		self waittill( "weapon_change", weapon );
	}
	self notify( "grenade_throw_cancelled" );
}

play_charge_fx() //checked changed to match cerberus output
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "grenade_fire" );
	waittillframeend;
	time_to_pulse = 1000;
	while ( 1 )
	{
		time = getTime() - self.n_tomahawk_cooking_time;
		self.current_tactical_grenade = self get_player_tactical_grenade();
		if ( time >= time_to_pulse )
		{
			if ( self.current_tactical_grenade == "upgraded_tomahawk_zm" )
			{
				playfxontag( level._effect[ "tomahawk_charge_up_ug" ], self, "tag_origin" );
			}
			else
			{
				playfxontag( level._effect[ "tomahawk_charge_up" ], self, "tag_origin" );
			}
			time_to_pulse += 1000;
			self playrumbleonentity( "reload_small" );
		}
		if ( time_to_pulse > 2400 && self.current_tactical_grenade != "upgraded_tomahawk_zm" )
		{
			return;
		}
		if ( time_to_pulse >= 3400 )
		{
			return;
		}
		wait 0.05;
	}
}

get_grenade_charge_power( player ) //checked changed to match cerberus output
{
	player endon( "disconnect" );
	if ( self.n_cookedtime > 1000 && self.n_cookedtime < 2000 )
	{
		if ( player.current_tomahawk_weapon == "upgraded_tomahawk_zm" )
		{
			return 4.5;
		}
		return 1.5;
	}
	else if ( self.n_cookedtime > 2000 && self.n_cookedtime < 3000 )
	{
		if ( player.current_tomahawk_weapon == "upgraded_tomahawk_zm" )
		{
			return 6;
		}
		return 2;
	}
	else if ( self.n_cookedtime >= 3000 && player.current_tomahawk_weapon != "upgraded_tomahawk_zm" )
	{
		return 2;
	}
	else if ( self.n_cookedtime >= 3000 )
	{
		return 3;
	}
	return 1;
}

tomahawk_thrown( grenade ) //checked changed to match cerberus output
{
	self endon( "disconnect" );
	grenade endon( "in_hellhole" );
	grenade_owner = undefined;
	if ( isDefined( grenade.owner ) )
	{
		grenade_owner = grenade.owner;
	}
	playfxontag( level._effect[ "tomahawk_charged_trail" ], grenade, "tag_origin" );
	self setclientfieldtoplayer( "tomahawk_in_use", 2 );
	grenade waittill_either( "death", "time_out" );
	grenade_origin = grenade.origin;
	a_zombies = getaispeciesarray( "axis", "all" );
	n_grenade_charge_power = grenade get_grenade_charge_power( self );
	a_zombies = get_array_of_closest( grenade_origin, a_zombies, undefined, undefined, 200 );
	a_powerups = get_array_of_closest( grenade_origin, level.active_powerups, undefined, undefined, 200 );
	if ( isDefined( level.a_tomahawk_pickup_funcs ) )
	{
		foreach ( tomahawk_func in level.a_tomahawk_pickup_funcs )
		{
			if ( [[ tomahawk_func ]]( grenade, n_grenade_charge_power ) )
			{
				return;
			}
		}
	}
	if ( isDefined( a_powerups ) && a_powerups.size > 0 )
	{
		m_tomahawk = tomahawk_spawn( grenade_origin, n_grenade_charge_power );
		m_tomahawk.n_grenade_charge_power = n_grenade_charge_power;
		foreach ( powerup in a_powerups )
		{
			powerup.origin = grenade_origin;
			powerup linkto( m_tomahawk );
			m_tomahawk.a_has_powerup = a_powerups;
		}
		self thread tomahawk_return_player( m_tomahawk, 0 );
		return;
	}
	if ( !isDefined( a_zombies ) )
	{
		m_tomahawk = tomahawk_spawn( grenade_origin, n_grenade_charge_power );
		m_tomahawk.n_grenade_charge_power = n_grenade_charge_power;
		self thread tomahawk_return_player( m_tomahawk, 0 );
		return;
	}
	foreach ( ai_zombie in a_zombies )
	{
		ai_zombie.hit_by_tomahawk = 0;
	}
	if ( isDefined( a_zombies[ 0 ] ) && isalive( a_zombies[ 0 ] ) )
	{
		v_zombiepos = a_zombies[ 0 ].origin;
		if ( distancesquared( grenade_origin, v_zombiepos ) <= 4900 )
		{
			a_zombies[ 0 ] setclientfield( "play_tomahawk_hit_sound", 1 );
			n_tomahawk_damage = calculate_tomahawk_damage( a_zombies[ 0 ], n_grenade_charge_power, grenade );
			a_zombies[ 0 ] dodamage( n_tomahawk_damage, grenade_origin, self, grenade, "none", "MOD_GRENADE", 0, "bouncing_tomahawk_zm" );
			a_zombies[ 0 ].hit_by_tomahawk = 1;
			self maps/mp/zombies/_zm_score::add_to_player_score( 10 );
			self thread tomahawk_ricochet_attack( grenade_origin, n_grenade_charge_power );
		}
		else
		{
			m_tomahawk = tomahawk_spawn( grenade_origin, n_grenade_charge_power );
			m_tomahawk.n_grenade_charge_power = n_grenade_charge_power;
			self thread tomahawk_return_player( m_tomahawk, 0 );
		}
	}
	else
	{
		m_tomahawk = tomahawk_spawn( grenade_origin, n_grenade_charge_power );
		m_tomahawk.n_grenade_charge_power = n_grenade_charge_power;
		if ( isDefined( grenade ) )
		{
			grenade delete();
		}
		self thread tomahawk_return_player( m_tomahawk, 0 );
	}
}

check_for_time_out( grenade ) //checked matches cerberus output
{
	self endon( "disconnect" );
	grenade endon( "death" );
	wait 0.5;
	grenade notify( "time_out" );
}

tomahawk_ricochet_attack( grenade_origin, tomahawk_charge_power ) //checked matches cerberus output
{
	self endon( "disconnect" );
	a_zombies = getaispeciesarray( "axis", "all" );
	a_zombies = get_array_of_closest( grenade_origin, a_zombies, undefined, undefined, 300 );
	a_zombies = array_reverse( a_zombies );
	if ( !isDefined( a_zombies ) )
	{
		m_tomahawk = tomahawk_spawn( grenade_origin, tomahawk_charge_power );
		m_tomahawk.n_grenade_charge_power = tomahawk_charge_power;
		self thread tomahawk_return_player( m_tomahawk, 0 );
		return;
	}
	m_tomahawk = tomahawk_spawn( grenade_origin, tomahawk_charge_power );
	m_tomahawk.n_grenade_charge_power = tomahawk_charge_power;
	self thread tomahawk_attack_zombies( m_tomahawk, a_zombies );
}

tomahawk_attack_zombies( m_tomahawk, a_zombies ) //checked changed to match cerberus output
{
	self endon( "disconnect" );
	if ( !isDefined( a_zombies ) )
	{
		self thread tomahawk_return_player( m_tomahawk, 0 );
		return;
	}
	if ( a_zombies.size <= 4 )
	{
		n_attack_limit = a_zombies.size;
	}
	else
	{
		n_attack_limit = 4;
	}
	for ( i = 0; i < n_attack_limit; i++ )
	{
		if ( isDefined( a_zombies[ i ] ) && isalive( a_zombies[ i ] ) )
		{
			tag = "J_Head";
			if ( a_zombies[ i ].isdog )
			{
				tag = "J_Spine1";
			}
			if ( isDefined( a_zombies[ i ].hit_by_tomahawk ) && !a_zombies[ i ].hit_by_tomahawk )
			{
				v_target = a_zombies[ i ] gettagorigin( tag );
				m_tomahawk moveto( v_target, 0.3 );
				m_tomahawk waittill( "movedone" );
				if ( isDefined( a_zombies[ i ] ) && isalive( a_zombies[ i ] ) )
				{
					if ( self.current_tactical_grenade == "upgraded_tomahawk_zm" )
					{
						playfxontag( level._effect[ "tomahawk_impact_ug" ], a_zombies[ i ], tag );
					}
					else
					{
						playfxontag( level._effect[ "tomahawk_impact" ], a_zombies[ i ], tag );
					}
					playfxontag( level._effect[ "tomahawk_fire_dot" ], a_zombies[ i ], "j_spineupper" );
					a_zombies[ i ] setclientfield( "play_tomahawk_hit_sound", 1 );
					n_tomahawk_damage = calculate_tomahawk_damage( a_zombies[ i ], m_tomahawk.n_grenade_charge_power, m_tomahawk );
					a_zombies[ i ] dodamage( n_tomahawk_damage, m_tomahawk.origin, self, m_tomahawk, "none", "MOD_GRENADE", 0, "bouncing_tomahawk_zm" );
					a_zombies[ i ].hit_by_tomahawk = 1;
					self maps/mp/zombies/_zm_score::add_to_player_score( 10 );
				}
			}
		}
		wait 0.2;
	}
	self thread tomahawk_return_player( m_tomahawk, n_attack_limit );
}

tomahawk_return_player( m_tomahawk, num_zombie_hit ) //checked changed to match cerberus output
{
	self endon( "disconnect" );
	n_dist = distance2dsquared( m_tomahawk.origin, self.origin );
	if ( !isDefined( num_zombie_hit ) )
	{
		num_zombie_hit = 5;
	}
	while ( n_dist > 4096 )
	{
		m_tomahawk moveto( self geteye(), 0.25 );
		if ( num_zombie_hit < 5 )
		{
			self tomahawk_check_for_zombie( m_tomahawk );
			num_zombie_hit++;
		}
		wait 0.1;
		n_dist = distance2dsquared( m_tomahawk.origin, self geteye() );
	}
	if ( isDefined( m_tomahawk.a_has_powerup ) )
	{
		foreach ( powerup in m_tomahawk.a_has_powerup )
		{
			if ( isDefined( powerup ) )
			{
				powerup.origin = self.origin;
			}
		}
	}
	m_tomahawk delete();
	self playsoundtoplayer( "wpn_tomahawk_catch_plr", self );
	self playsound( "wpn_tomahawk_catch_npc" );
	wait 5;
	self playsoundtoplayer( "wpn_tomahawk_cooldown_done", self );
	self givemaxammo( self.current_tomahawk_weapon );
	a_zombies = getaispeciesarray( "axis", "all" );
	foreach ( ai_zombie in a_zombies )
	{
		ai_zombie.hit_by_tomahawk = 0;
	}
	self setclientfieldtoplayer( "tomahawk_in_use", 3 );
}

tomahawk_check_for_zombie( grenade ) //checked matches cerberus output
{
	self endon( "disconnect" );
	grenade endon( "death" );
	a_zombies = getaispeciesarray( "axis", "all" );
	a_zombies = get_array_of_closest( grenade.origin, a_zombies, undefined, undefined, 100 );
	if ( isDefined( a_zombies[ 0 ] ) && distance2dsquared( grenade.origin, a_zombies[ 0 ].origin ) <= 10000 )
	{
		if ( isDefined( a_zombies[ 0 ].hit_by_tomahawk ) && !a_zombies[ 0 ].hit_by_tomahawk )
		{
			self tomahawk_hit_zombie( a_zombies[ 0 ], grenade );
		}
	}
}

tomahawk_hit_zombie( ai_zombie, grenade ) //checked matches cerberus output
{
	self endon( "disconnect" );
	if ( isDefined( ai_zombie ) && isalive( ai_zombie ) )
	{
		tag = "J_Head";
		if ( ai_zombie.isdog )
		{
			tag = "J_Spine1";
		}
		v_target = ai_zombie gettagorigin( tag );
		grenade moveto( v_target, 0.3 );
		grenade waittill( "movedone" );
		if ( isDefined( ai_zombie ) && isalive( ai_zombie ) )
		{
			if ( self.current_tactical_grenade == "upgraded_tomahawk_zm" )
			{
				playfxontag( level._effect[ "tomahawk_impact_ug" ], ai_zombie, tag );
			}
			else
			{
				playfxontag( level._effect[ "tomahawk_impact" ], ai_zombie, tag );
			}
			ai_zombie setclientfield( "play_tomahawk_hit_sound", 1 );
			n_tomahawk_damage = calculate_tomahawk_damage( ai_zombie, grenade.n_grenade_charge_power, grenade );
			ai_zombie dodamage( n_tomahawk_damage, grenade.origin, self, grenade, "none", "MOD_GRENADE", 0, "bouncing_tomahawk_zm" );
			ai_zombie.hit_by_tomahawk = 1;
			self maps/mp/zombies/_zm_score::add_to_player_score( 10 );
		}
	}
}

tomahawk_spawn( grenade_origin, charged ) //checked matches cerberus output
{
	m_tomahawk = spawn( "script_model", grenade_origin );
	m_tomahawk setmodel( "t6_wpn_zmb_tomahawk_world" );
	m_tomahawk thread tomahawk_spin();
	m_tomahawk playloopsound( "wpn_tomahawk_flying_loop" );
	if ( self.current_tactical_grenade == "upgraded_tomahawk_zm" )
	{
		playfxontag( level._effect[ "tomahawk_trail_ug" ], m_tomahawk, "tag_origin" );
	}
	else
	{
		playfxontag( level._effect[ "tomahawk_trail" ], m_tomahawk, "tag_origin" );
	}
	if ( isDefined( charged ) && charged > 1 )
	{
		playfxontag( level._effect[ "tomahawk_charged_trail" ], m_tomahawk, "tag_origin" );
	}
	m_tomahawk.low_level_instant_kill_charge = 1;
	return m_tomahawk;
}

tomahawk_spin() //checked matches cerberus output
{
	self endon( "death" );
	while ( isDefined( self ) )
	{
		self rotatepitch( 90, 0.2 );
		wait 0.15;
	}
}

tomahawk_pickup() //checked matches cerberus output
{
	flag_wait( "soul_catchers_charged" );
	flag_init( "tomahawk_pickup_complete" );
	door = getent( "tomahawk_room_door", "targetname" );
	door trigger_off();
	door connectpaths();
	s_pos_tomahawk = getstruct( "tomahawk_pickup_pos", "targetname" );
	m_tomahawk = spawn( "script_model", s_pos_tomahawk.origin );
	m_tomahawk.targetname = "spinning_tomahawk_pickup";
	m_tomahawk setmodel( "t6_wpn_zmb_tomahawk_world" );
	m_tomahawk setclientfield( "play_tomahawk_fx", 1 );
	m_tomahawk thread tomahawk_pickup_spin();
	m_tomahawk playloopsound( "amb_tomahawk_swirl" );
	s_pos_trigger = getstruct( "tomahawk_trigger_pos", "targetname" );
	trigger = spawn( "trigger_radius_use", s_pos_trigger.origin, 0, 100, 150 );
	trigger.script_noteworthy = "retriever_pickup_trigger";
	trigger usetriggerrequirelookat();
	trigger triggerignoreteam();
	trigger sethintstring( &"ZM_PRISON_TOMAHAWK_PICKUP" );
	trigger setcursorhint( "HINT_NOICON" );
	trigger_upgraded = spawn( "trigger_radius_use", s_pos_trigger.origin, 0, 100, 150 );
	trigger_upgraded usetriggerrequirelookat();
	trigger_upgraded triggerignoreteam();
	trigger_upgraded.script_noteworthy = "redeemer_pickup_trigger";
	trigger_upgraded sethintstring( &"ZM_PRISON_TOMAHAWK_UPGRADED_PICKUP" );
	trigger_upgraded setcursorhint( "HINT_NOICON" );
	/*
/#
	iprintlnbold( "GO FIND THE TOMAHAWK" );
#/
	*/
	trigger thread tomahawk_pickup_trigger();
	trigger_upgraded thread tomahawk_pickup_trigger();
	flag_set( "tomahawk_pickup_complete" );
}

tomahawk_pickup_trigger() //checked changed to match cerberus output
{
	while ( 1 )
	{
		self waittill( "trigger", player );
		if ( isDefined( player.current_tactical_grenade ) && !issubstr( player.current_tactical_grenade, "tomahawk_zm" ) )
		{
			player takeweapon( player.current_tactical_grenade );
		}
		if ( player.current_tomahawk_weapon == "upgraded_tomahawk_zm" )
		{
			if ( !is_true( player.afterlife ) && isDefined( level.customMap ) && level.customMap == "vanilla" )
			{
				continue;
			}
			else 
			{
				player disable_player_move_states( 1 );
				gun = player getcurrentweapon();
				level notify( "bouncing_tomahawk_zm_aquired" );
				player maps/mp/zombies/_zm_stats::increment_client_stat( "prison_tomahawk_acquired", 0 );
				player giveweapon( "zombie_tomahawk_flourish" );
				if ( isDefined ( level.customMap ) && level.customMap == "vanilla" )
				{
					player thread tomahawk_update_hud_on_last_stand();
				}
				player switchtoweapon( "zombie_tomahawk_flourish" );
				player waittill_any( "player_downed", "weapon_change_complete" );
				if ( self.script_noteworthy == "redeemer_pickup_trigger" )
				{
					player.redeemer_trigger = self;
					player setclientfieldtoplayer( "upgraded_tomahawk_in_use", 1 );
				}
				player switchtoweapon( gun );
				player enable_player_move_states();
				player.loadout.hastomahawk = 1;
				if ( isDefined ( level.customMap ) && level.customMap != "vanilla" )
				{
					self setclientfieldtoplayer( "tomahawk_in_use", 1 );
					player giveweapon( "upgraded_tomahawk_zm" );
					player givemaxammo( "upgraded_tomahawk_zm" );
					player set_player_tactical_grenade( "upgraded_tomahawk_zm" );
				}
				continue;
			}
		}
		if ( !player hasweapon( "bouncing_tomahawk_zm" ) && !player hasweapon( "upgraded_tomahawk_zm" ) )
		{
			player disable_player_move_states( 1 );
			if ( !is_true( player.afterlife ) )
			{
				player giveweapon( player.current_tomahawk_weapon );
				player thread tomahawk_update_hud_on_last_stand();
				player thread tomahawk_tutorial_hint();
				player set_player_tactical_grenade( player.current_tomahawk_weapon );
				if ( self.script_noteworthy == "retriever_pickup_trigger" )
				{
					player.retriever_trigger = self;
				}
				player notify( "tomahawk_picked_up" );
				player setclientfieldtoplayer( "tomahawk_in_use", 1 );
				gun = player getcurrentweapon();
				level notify( "bouncing_tomahawk_zm_aquired" );
				player notify( "player_obtained_tomahawk" );
				player maps/mp/zombies/_zm_stats::increment_client_stat( "prison_tomahawk_acquired", 0 );
				player giveweapon( "zombie_tomahawk_flourish" );
				player switchtoweapon( "zombie_tomahawk_flourish" );
				player waittill_any( "player_downed", "weapon_change_complete" );
				if ( self.script_noteworthy == "redeemer_pickup_trigger" )
				{
					player setclientfieldtoplayer( "upgraded_tomahawk_in_use", 1 );
				}
				player switchtoweapon( gun );
			}
			player enable_player_move_states();
			wait 0.1;
		}
	}
}

tomahawk_pickup_spin() //checked matches cerberus output
{
	self endon( "death" );
	while ( 1 )
	{
		self rotateyaw( 90, 1 );
		wait 0.15;
	}
}

calculate_tomahawk_damage( n_target_zombie, n_tomahawk_power, tomahawk ) //checked changed to match cerberus output
{
	if ( n_tomahawk_power > 2 )
	{
		return n_target_zombie.health + 1;
	}
	else if ( level.round_number >= 10 && level.round_number < 13 && tomahawk.low_level_instant_kill_charge <= 3 )
	{
		tomahawk.low_level_instant_kill_charge += 1;
		return n_target_zombie.health + 1;
	}
	else if ( level.round_number >= 13 && level.round_number < 15 && tomahawk.low_level_instant_kill_charge <= 2 )
	{
		tomahawk.low_level_instant_kill_charge += 1;
		return n_target_zombie.health + 1;
	}
	else
	{
		return 1000 * n_tomahawk_power;
	}
}

setting_tutorial_hud() //checked matches cerberus output
{
	client_hint = newclienthudelem( self );
	client_hint.alignx = "center";
	client_hint.aligny = "middle";
	client_hint.horzalign = "center";
	client_hint.vertalign = "bottom";
	client_hint.y = -120;
	client_hint.foreground = 1;
	client_hint.font = "default";
	client_hint.fontscale = 1.5;
	client_hint.alpha = 1;
	client_hint.color = ( 1, 1, 1 );
	return client_hint;
}

tomahawk_tutorial_hint() //checked matches cerberus output
{
	hud = setting_tutorial_hud();
	hud settext( &"ZM_PRISON_TOMAHAWK_TUTORIAL" );
	self waittill_notify_or_timeout( "throwing_tomahawk", 5 );
	wait 1;
	hud destroy();
}

tomahawk_update_hud_on_last_stand() //checked matches cerberus output
{
	self endon( "disconnect" );
	self endon( "bled_out" );
	self endon( "tomahawk_upgraded_swap" );
	while ( 1 )
	{
		self waittill_either( "entering_last_stand", "fake_death" );
		self setclientfieldtoplayer( "tomahawk_in_use", 0 );
		self waittill( "player_revived" );
		if ( isalive( self ) )
		{
			wait 0.1;
			self setclientfieldtoplayer( "tomahawk_in_use", 1 );
			self giveweapon( self.current_tomahawk_weapon );
			self givemaxammo( self.current_tomahawk_weapon );
			self set_player_tactical_grenade( self.current_tomahawk_weapon );
		}
	}
}

tomahawk_upgrade_modified()
{
	level endon( "end_game");
	self endon( "disconnect" );
	
	level.tomahawkKillsRequired = getDvarIntDefault( "tomahawkKillsRequired", 35 );
	level.zombie_vars[ "tomahawkKillsRequired" ] = level.tomahawkKillsRequired;
	self.tomahawk_upgrade_kills = 0;
	while ( self.tomahawk_upgrade_kills < level.tomahawkKillsRequired )
	{
		self waittill( "got_a_tomahawk_kill" );
		self.tomahawk_upgrade_kills++;
	}
	wait 1;
	level thread maps/mp/zombies/_zm_audio::sndmusicstingerevent( "quest_generic" );
	e_org = spawn( "script_origin", self.origin + vectorScale( ( 0, 0, 1 ), 64 ) );
	e_org playsoundwithnotify( "zmb_easteregg_scream", "easteregg_scream_complete" );
	e_org waittill( "easteregg_scream_complete" );
	e_org delete();
	self notify( "hellhole_time" );
	self waittill( "tomahawk_in_hellhole" );
	if ( isDefined( self.retriever_trigger ) )
	{
		self.retriever_trigger setinvisibletoplayer( self );
	}
	else
	{
		trigger = getent( "retriever_pickup_trigger", "script_noteworthy" );
		self.retriever_trigger = trigger;
		self.retriever_trigger setinvisibletoplayer( self );
	}
	self takeweapon( "bouncing_tomahawk_zm" );
	self set_player_tactical_grenade( "none" );
	self notify( "tomahawk_upgraded_swap" );
	level thread maps/mp/zombies/_zm_audio::sndmusicstingerevent( "quest_generic" );
	e_org = spawn( "script_origin", self.origin + vectorScale( ( 0, 0, 1 ), 64 ) );
	e_org playsoundwithnotify( "zmb_easteregg_scream", "easteregg_scream_complete" );
	e_org waittill( "easteregg_scream_complete" );
	e_org delete();
	level waittill( "end_of_round" );
	self.ilostmytommyhawk = 1;
	tomahawk_pick = getent( "spinning_tomahawk_pickup", "targetname" );
	tomahawk_pick setclientfield( "play_tomahawk_fx", 2 );
	self.current_tomahawk_weapon = "upgraded_tomahawk_zm";
}

toggle_redeemer_modified()
{
	level endon( "end_game");
	self endon( "disconnect" );
	flag_wait( "tomahawk_pickup_complete" );
	upgraded_tomahawk_trigger = getent( "redeemer_pickup_trigger", "script_noteworthy" );
	upgraded_tomahawk_trigger setinvisibletoplayer( self );
	tomahawk_model = getent( "spinning_tomahawk_pickup", "targetname" );
	tomahawk_trigger = getstruct( "tomahawk_trigger_pos", "targetname" );
	while ( 1 )
	{
		if ( isDefined( self.current_tomahawk_weapon ) && self.current_tomahawk_weapon == "upgraded_tomahawk_zm" )
		{
			break;
		}
		else wait 1;
	}
	while ( 1 )
	{
		if ( isDefined( self.ilostmytommyhawk ) && self.ilostmytommyhawk )
		{
			tomahawk_trigger = getstruct( "tomahawk_trigger_pos", "targetname" );
			tomahawk_trigger setinvisibletoplayer( self );
			tomahawk_model setvisibletoplayer( self );
			upgraded_tomahawk_trigger setvisibletoplayer( self );
		}
		else
		{
			tomahawk_trigger = getstruct( "tomahawk_trigger_pos", "targetname" );
			tomahawk_trigger setvisibletoplayer( self );
			tomahawk_model setinvisibletoplayer( self );
		}
		wait 1;
	}
}

modified_hellhound()
{
	wait 3;
	level endon( "end_game");
	level.zombies_required = 0;
	level.zombies_required_total = getDvarIntDefault( "hellhoundKillsRequired", 18 );
	level.zombie_vars[ "hellhoundKillsRequired" ] = level.zombies_required_total;
	for(;;)
	{
		a_wolf_structs = getstructarray( "wolf_position", "targetname" );
		i = 0;
		while ( i < a_wolf_structs.size )
		{
			if ( a_wolf_structs[ i ].souls_received == 1 )
			{
				level.zombies_required++;
			}
			a_wolf_structs[ i ].souls_received = 0;
			i++;
		}
		if ( level.zombies_required == level.zombies_required_total )
		{
			a_wolf_structs = getstructarray( "wolf_position", "targetname" );
			i = 0;
			while ( i < a_wolf_structs.size )
			{
				a_wolf_structs[ i ].souls_received = 6;
				i++;
			}
			flag_set( "soul_catchers_charged" );
			level notify( "soul_catchers_charged" );
			level thread maps/mp/zombies/_zm_audio::sndmusicstingerevent( "quest_generic" );
			return;
		}
		else
		{
			wait 0.25;
		}
	}
}