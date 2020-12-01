extends Node

var _collectibles: Array


func addCollectible (coll):
	Logger.info("appending new collectible: " + String(coll.get_instance_id()))
	_collectibles.append(coll)
	Logger.info("current collection count: " + String(Collector.getCount()))


func getCount ():
	return _collectibles.size()


func Clear ():
	return _collectibles.clear()