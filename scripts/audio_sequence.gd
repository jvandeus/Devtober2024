class_name AudioStreamSequence
extends AudioStreamPlayer

@export var streams: Array[AudioStreamWAV] = [] # The queue of sounds to play.
var index: int = 0

func play_next(pos: float = 0.0):
	if streams.size() <= 0:
		return
	if self.is_playing:
		self.stop()
	self.set_stream(streams[index])
	self.play(pos)
	index += 1
	index = index % streams.size()

func reset():
	index = 0;
