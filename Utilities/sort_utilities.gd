class_name SortUtilities
extends Node

static func sort_descending(a, b):
	if a[1]["Money"] > b[1]["Money"]:
		return true
	return false