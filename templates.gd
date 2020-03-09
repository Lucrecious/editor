extends Reference

class_name EditorTemplates

const PlayerTemplate = 'player'
const GrassTemplate = 'grass'

const TemplateProperty := {
	GrassTemplate : {
		'tileset': Constants.CollisionTexture.Grass,
		'texture': Constants.CollisionTexture.Grass
	}
}

static func get_template(n : String) -> Dictionary:
	return TemplateProperty.get(n, {}) as Dictionary
