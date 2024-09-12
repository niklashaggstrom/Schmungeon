extends Node
class_name Character

# name is inherited 

var _max_health : int
var _initiative : int 
var _damage : int = 0

var max_health : int : 
	get : return _max_health

var initiative : int : 
	get : return _initiative

var damage : int :  
	get : return _damage

var health : int :
	get : return max_health - damage

var is_dead : bool : 
	get : return (_damage >= max_health)
	
var is_alive : bool : 
	get : return !is_dead

signal damage_taken(character, amount)
signal healed(character, amount)
signal died(character)
signal resurrected(character)

func _init(name : String, max_health : int, initiative : int): 
	self.name = name
	self._max_health = max_health
	self._initiative = initiative

func take_damage(amount : int) : 
	var was_dead = is_dead
	
	_damage += amount
	
	if _damage == max_health:
		_damage = max_health
	
	damage_taken.emit(self, amount)
	
	if !was_dead and is_dead:
		died.emit(self)

func heal(amount : int) : 
	var was_dead = is_dead
	
	_damage -= amount
	
	if _damage > 0:
		_damage = 0
	
	healed.emit(self, amount)
	
	if was_dead and !is_dead:
		resurrected.emit(self)








