extends Resource
class_name Gene

@export var id: String
@export_enum("single", "poly") var type: String
@export var start_position: int
@export var end_position: int # exclusive

