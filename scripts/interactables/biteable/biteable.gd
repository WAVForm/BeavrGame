extends CollisionObject2D

class_name Biteable

func bite(player:Player):
	push_error(player.name, " bit ", self.get_parent().name, ", but bite was not implemented.")
