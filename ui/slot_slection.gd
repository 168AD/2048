extends Control

@export var slot_card: PackedScene
@onready var slots_container: VBoxContainer = $VBoxContainer

const MAX_SLOTS = 4

#func _ready():
	#await self.ready
	#for i in range(1, MAX_SLOTS+1):
		#var meta = GlobalSave.get_slot_meta(i)
		#var card = slot_card.instantiate()
		#
		##await card.ready
		#card.setup(i, meta)
		#slots_container.add_child(card)
