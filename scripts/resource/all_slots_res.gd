extends Resource
class_name AllSlotsRes

@export var slots: Array[MetaRes]

func get_slot(slot: int) -> MetaRes:
	for s in slots:
		if s.slot == slot:
			return s
	
	return null
	
func update_slot(slot: int, save_res: SaveRes):
	var slot_meta = get_slot(slot)
	if not slot_meta:
		slot_meta = MetaRes.new()
		slot_meta.slot = slot
		slots.append(slot_meta)
	
	slot_meta.create_meta(save_res)
