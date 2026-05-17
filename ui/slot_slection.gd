extends Control

@export var slot_card: PackedScene
@onready var slots_container: VBoxContainer = $VBoxContainer
@onready var slot_card_1: SlotCard = $VBoxContainer/SlotCard1

const MAX_SLOTS = 4

func _ready():
	var cards: Array = slots_container.get_children()
	for i in len(cards):
		var meta: MetaRes = GlobalSave.get_slot_meta(i+1)
		var card: SlotCard = cards[i]
		card.setup(i+1, meta)

func slot_on():
	slot_card_1.slot_on()
