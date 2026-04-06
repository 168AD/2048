extends Control

@export var slot_card: PackedScene
@onready var slots_container: VBoxContainer = $VBoxContainer

const MAX_SLOTS = 4

func _ready():
	var cards: Array = slots_container.get_children()
	for i in len(cards):
		var meta: MetaRes = GlobalSave.get_slot_meta(i+1)
		var card: SlotCard = cards[i]
		card.setup(i+1, meta)
