extends Node

var TimesOfDay : int = 0
var Number_of_Players : int = 0

func _conditional():
	if Number_of_Players < 0:
		Number_of_Players = 0
	if multiplayer.is_server():
		pass

#useful
signal player_number(conected_players)
signal transfer(gamer)
signal time(light_value)

###useless
signal player_attack(pos, id)
signal give_enemy_damage(player_damage: int, velocity_damage: int)
