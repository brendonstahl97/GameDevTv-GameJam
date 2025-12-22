extends Label

func _update_price_display(new_price: int) -> void:
	text = "$" + str(new_price)
