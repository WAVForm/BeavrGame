extends CollisionObject2D

class_name Interactable

func interact(player:Player):
	push_error(player.name, " interacted with ", self.get_parent().name, ", but interaction was not implemented.")
