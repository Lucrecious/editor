extends Node

class_name EditorObjectTypes

const Unknown = 0
const Spawner = 1
const PlayerSpawner = 2

const Properties := {
	Unknown : {},
	Spawner : { EditorObjProp.Spawn : CharSpawner.Character.GoldenSpider },
	PlayerSpawner : { EditorObjProp.Spawn : CharSpawner.Character.Player }
}
