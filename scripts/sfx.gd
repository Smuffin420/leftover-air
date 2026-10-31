extends Node
class_name FactorySfx

var _players: Array[AudioStreamPlayer] = []
var _next := 0
var _streams := {}


func _ready() -> void:
	_streams["pop"] = _pop()
	_streams["twist"] = _crinkle()
	_streams["sweep"] = _paper()
	_streams["paper"] = _paper()
	_streams["whoosh"] = _whoosh()
	_streams["dock"] = _wave(140.0, 0.12, 0.1, 70.0)
	_streams["promote"] = _wave(523.0, 0.18, 0.0, 784.0)
	_streams["click"] = _wave(210.0, 0.045, 0.04, 90.0)
	_streams["clunk"] = _clunk()
	_streams["step"] = _step()
	_streams["buzzer"] = _buzzer()
	_streams["wah"] = _wah()
	for _i in 16:
		var player := AudioStreamPlayer.new()
		player.volume_db = -8.0
		add_child(player)
		_players.append(player)


func play_kind(kind: String, pitch: float = -1.0) -> void:
	if _players.is_empty() or not _streams.has(kind):
		return
	var player := _players[_next]
	_next = (_next + 1) % _players.size()
	player.stream = _streams[kind]
	player.bus = Settings.bus_for(kind)
	if pitch > 0.0:
		player.pitch_scale = pitch
	elif kind == "wah":
		player.pitch_scale = randf_range(0.96, 1.05)
	elif kind == "step":
		player.pitch_scale = randf_range(0.88, 1.14)
	elif kind == "buzzer":
		player.pitch_scale = randf_range(0.98, 1.03)
	else:
		player.pitch_scale = randf_range(0.94, 1.08)
	player.play()


func _wave(freq: float, seconds: float, noise: float, freq2: float) -> AudioStreamWAV:
	var rate := 22050
	var count := int(rate * seconds)
	var data := _blank(count)
	for i in count:
		var t := float(i) / float(rate)
		var env := 1.0 - (float(i) / float(count))
		env *= env
		var sample := sin(TAU * freq * t) * env
		if freq2 > 0.0:
			sample += sin(TAU * freq2 * t) * env * 0.55
		if noise > 0.0:
			sample += (randf() * 2.0 - 1.0) * env * noise
		_write(data, i, sample)
	return _finish(data, rate)


func _pop() -> AudioStreamWAV:
	var rate := 22050
	var count := int(rate * 0.055)
	var data := _blank(count)
	for i in count:
		var t := float(i) / float(rate)
		var tick := sin(TAU * 1680.0 * t) * exp(-t * 95.0)
		var body := sin(TAU * 480.0 * t) * exp(-t * 55.0) * 0.42
		var n := (randf() * 2.0 - 1.0) * exp(-t * 75.0) * 0.38
		_write(data, i, (tick + body + n) * 0.9)
	return _finish(data, rate)


func _crinkle() -> AudioStreamWAV:
	var rate := 22050
	var count := int(rate * 0.11)
	var data := _blank(count)
	var lp := 0.0
	for i in count:
		var t := float(i) / float(rate)
		var env := exp(-t * 18.0)
		var n := randf() * 2.0 - 1.0
		lp = lerpf(lp, n, 0.35)
		var rustle := sin(TAU * lerpf(240.0, 90.0, t / 0.11) * t) * 0.25
		_write(data, i, (lp * 0.85 + rustle) * env * 0.8)
	return _finish(data, rate)


func _paper() -> AudioStreamWAV:
	var rate := 22050
	var count := int(rate * 0.16)
	var data := _blank(count)
	var lp := 0.0
	for i in count:
		var t := float(i) / float(rate)
		var u := t / 0.16
		var env := sin(PI * u) * (1.0 - u)
		var n := randf() * 2.0 - 1.0
		lp = lerpf(lp, n, 0.22)
		_write(data, i, lp * env * 0.85)
	return _finish(data, rate)


func _whoosh() -> AudioStreamWAV:
	var rate := 22050
	var seconds := 0.72
	var count := int(rate * seconds)
	var data := _blank(count)
	var lp := 0.0
	for i in count:
		var t := float(i) / float(rate)
		var u := t / seconds
		var env := sin(PI * u)
		env = pow(env, 0.55)
		var n := randf() * 2.0 - 1.0
		lp = lerpf(lp, n, lerpf(0.06, 0.28, env))
		var rumble := sin(TAU * lerpf(78.0, 36.0, u) * t) * 0.42
		_write(data, i, (lp * 0.95 + rumble) * env * 0.82)
	return _finish(data, rate)


func _clunk() -> AudioStreamWAV:
	var rate := 22050
	var count := int(rate * 0.18)
	var data := _blank(count)
	for i in count:
		var t := float(i) / float(rate)
		var ring := sin(TAU * 96.0 * t) * exp(-t * 28.0)
		ring += sin(TAU * 210.0 * t) * exp(-t * 55.0) * 0.4
		var n := (randf() * 2.0 - 1.0) * exp(-t * 70.0) * 0.55
		var late := maxf(0.0, t - 0.046)
		var tick := sin(TAU * 320.0 * late) * exp(-late * 60.0) * 0.38
		_write(data, i, (ring + n + tick) * 0.9)
	return _finish(data, rate)


func _step() -> AudioStreamWAV:
	var rate := 22050
	var count := int(rate * 0.07)
	var data := _blank(count)
	for i in count:
		var t := float(i) / float(rate)
		var env := exp(-t * 48.0)
		var thud := sin(TAU * 68.0 * t) * env
		var n := (randf() * 2.0 - 1.0) * exp(-t * 36.0) * 0.4
		_write(data, i, (thud + n) * 0.42)
	return _finish(data, rate)


func _buzzer() -> AudioStreamWAV:
	var rate := 22050
	var seconds := 0.62
	var count := int(rate * seconds)
	var data := _blank(count)
	for i in count:
		var t := float(i) / float(rate)
		var on := false
		var u := 0.0
		if t < 0.18:
			on = true
			u = t / 0.18
		elif t > 0.28 and t < 0.56:
			on = true
			u = (t - 0.28) / 0.28
		if not on:
			_write(data, i, 0.0)
			continue
		var env := clampf(u * 12.0, 0.0, 1.0) * (1.0 - smoothstep(0.72, 1.0, u))
		var freq := 148.0 if t < 0.2 else 186.0
		var s := sin(TAU * freq * t)
		s += sin(TAU * freq * 3.0 * t) * 0.45
		s += sin(TAU * freq * 5.0 * t) * 0.22
		_write(data, i, s * env * 0.55)
	return _finish(data, rate)


func _wah() -> AudioStreamWAV:
	var rate := 22050
	var syl := 0.2
	var gap := 0.07
	var notes := 3
	var count := int(rate * float(notes) * (syl + gap))
	var data := _blank(count)
	var bases: Array[float] = [188.0, 164.0, 142.0]
	for i in count:
		var t := float(i) / float(rate)
		var cycle := syl + gap
		var which := int(t / cycle)
		if which >= notes:
			_write(data, i, 0.0)
			continue
		var pos := t - float(which) * cycle
		if pos >= syl:
			_write(data, i, 0.0)
			continue
		var u := pos / syl
		var env := sin(PI * u)
		env = env * env
		var glide := lerpf(bases[which] * 1.06, bases[which] * 0.84, u)
		var s := sin(TAU * glide * pos)
		s += sin(TAU * glide * 2.0 * pos) * 0.48
		s += sin(TAU * glide * 3.0 * pos) * 0.2
		var form := lerpf(460.0, 1040.0, sin(PI * u))
		s += sin(TAU * form * pos) * 0.22
		s += (randf() * 2.0 - 1.0) * 0.05
		_write(data, i, s * env * 0.62)
	return _finish(data, rate)


func _blank(count: int) -> PackedByteArray:
	var data := PackedByteArray()
	data.resize(count * 2)
	return data


func _write(data: PackedByteArray, i: int, sample: float) -> void:
	var value := int(clampf(sample, -1.0, 1.0) * 32000.0)
	if value < 0:
		value += 65536
	data[i * 2] = value & 255
	data[i * 2 + 1] = (value >> 8) & 255


func _finish(data: PackedByteArray, rate: int) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = rate
	stream.stereo = false
	stream.loop_mode = AudioStreamWAV.LOOP_DISABLED
	stream.data = data
	return stream
