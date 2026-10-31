extends Node

# A flat on-time roll is worth 6 reputation before Brownnoser. At roughly one roll a minute,
# the office offers the next rank near 30 minutes, then 70 minutes, 2 hours,
# 3.5 hours, and 5 hours. Taking it is optional.
const RANK: PackedStringArray = ["Intern", "Pop Associate", "Sheet Tech", "Floor Lead", "Shift Supervisor", "Boss"]
const PAY: Array[int] = [1, 1, 2, 2, 3]
const ROLL_NAME: PackedStringArray = ["Fine", "House", "Mailer", "Crate"]
const ROLL_COLOR: PackedStringArray = ["c5e7f2", "8fd0ea", "e2b84a", "6fbf86"]
const ROLL_PAPER: PackedStringArray = ["f7f4ea", "e4dece", "f0e2c0", "dce8df"]
const ROLL_COLS: Array[int] = [12, 10, 8, 6]
const ROLL_ROWS: Array[int] = [8, 7, 5, 4]
const ROLL_WORTH: Array[int] = [18, 26, 40, 56]
const ROLL_RADIUS: Array[float] = [0.085, 0.1, 0.115, 0.135]
const REP_NEED: Array[int] = [180, 380, 680, 1100, 1650]
const PAR: Array[float] = [75.0, 68.0, 62.0, 58.0, 54.0]
const SLOW_RATE: Array[int] = [1, 1, 2, 2, 3]

const TRACKS: Array = [
	{"id": "speed", "name": "Speed", "group": "Body", "rank": 0, "blurb": "Longer strides. The floor is still too big, and that is your problem.", "costs": [90, 160, 280, 450, 700, 1100, 1700, 2500, 3600, 5000]},
	{"id": "sprint", "name": "Sprint", "group": "Body", "rank": 0, "blurb": "Hold Shift. You may run. The roll will still punish you for trying.", "costs": [18, 240, 520, 980, 1700]},
	{"id": "grip", "name": "Grip", "group": "Body", "rank": 0, "blurb": "Stop sliding. This is a factory, not a rink, even if you treat it like one.", "costs": [70, 140, 250, 420, 700, 1100, 1700, 2500]},
	{"id": "carry", "name": "Carry", "group": "Body", "rank": 0, "blurb": "The roll drags you less. It is still a roll, and you are still you.", "costs": [100, 200, 380, 640, 1000, 1600]},
	{"id": "callus", "name": "Callus", "group": "Pop", "rank": 0, "blurb": "The hand stops flinching. Same poke. Slightly less waiting.", "costs": [80, 150, 260, 420, 680, 1000, 1500, 2200]},
	{"id": "reach", "name": "Reach", "group": "Pop", "rank": 0, "blurb": "The far bubbles stop being a personal failing. Some of them.", "costs": [140, 280, 500, 850, 1400]},
	{"id": "pair", "name": "Hands", "group": "Pop", "rank": 0, "blurb": "Buy it, then equip it on the bar. Pop one side and the match across the middle pops too. Hand stays on the bar when you want the bigger multiplier.", "costs": [320]},
	{"id": "hammer", "name": "Hammer", "group": "Pop", "rank": 1, "blurb": "A small hammer. One click flattens a square of four. Still one step on the multiplier. The row tools come later.", "costs": [480]},
	{"id": "knuckle", "name": "Knuckle", "group": "Pop", "rank": 1, "blurb": "Each tier shortens the wait between pokes. Hand still pops one bubble. Hands still pops only the match across the row.", "costs": [360, 820, 1600]},
	{"id": "twist", "name": "The Twist", "group": "Pop", "rank": 2, "blurb": "Grab and twist. A lot die. Some hide in the crinkle. I will still find them.", "costs": [900, 1600, 2800, 4500]},
	{"id": "thimble", "name": "Thimble", "group": "Pop", "rank": 2, "blurb": "A rubber tip. The hands get ruder. They do not get wider.", "costs": [750, 1300, 2100, 3200, 4800]},
	{"id": "row", "name": "Row drag", "group": "Pop", "rank": 3, "blurb": "Now you may drag a whole row. You waited. I noticed. Higher tiers get greedy.", "costs": [1800, 3200, 5200]},
	{"id": "lane", "name": "Lane sweep", "group": "Pop", "rank": 4, "blurb": "A wider straight pull. The sheet stays honest, which is more than I can say.", "costs": [3000, 5200, 8000]},
	{"id": "cart", "name": "Cart", "group": "Gear", "rank": 3, "blurb": "It stays where you leave it. E to push, E again to get off. It holds four rolls. Park it under the wall pipe and a button loads one. Higher tiers drag less.", "costs": [1500, 2600, 4200, 6500]},
	{"id": "brayer", "name": "Brayer", "group": "Pop", "rank": 4, "blurb": "A roller. Wide and flat. You still cover the whole sheet. I will know.", "costs": [4500, 7200, 11000]},
	{"id": "nose", "name": "Brownnoser", "group": "Office", "rank": 0, "blurb": "Each tier adds 20% reputation on a roll that earned any. Compliments are not included. I would notice.", "costs": [500, 1100, 2200, 4000, 7000]},
	{"id": "skim", "name": "The Skim", "group": "Office", "rank": 0, "blurb": "Each tier adds 20% of the green, on top of the green. You pay me for the right to pay you. Frame it.", "costs": [550, 1200, 2400, 4200, 7500]},
	{"id": "compound", "name": "Compound", "group": "Office", "rank": 0, "blurb": "Each tier adds another 0.1 per click. A wide tool still pays less than poking. The roll pays it at the fire.", "costs": [1200, 2600, 4800, 8000]},
]

var money: int = 0
var rank: int = 0
var reputation: int = 42
var sheets_this_rank: int = 0
var completed: bool = false
var tutorial: int = 0
var dev_mode: bool = false
var _dev_session: bool = false
var tiers: Dictionary = {}
var times: Array[float] = []
var profile: String = "shift"
var score: int = 0
var streak: int = 0
var run_time: float = 0.0
var next_mark: int = 1000
var pb_locked: bool = false
var speedrun_pb: float = -1.0
var beat_pb: bool = false
var lesson_price: int = 0
var worker_name: String = ""
var skin: int = 0
const SKIN_NAME: PackedStringArray = ["Factory", "Pale", "Fair", "Tan", "Brown", "Deep"]
const SKIN_COLOR: Array[Color] = [
	Color("e7b896"),
	Color("f6d2b4"),
	Color("e4b48c"),
	Color("c4895e"),
	Color("8d5a3b"),
	Color("5c3b2a"),
]
var badge_rank: int = -1
var met_janitor: bool = false
var pardon: int = 0
var break_hold: int = 0
var chain_save: int = 0
var quiet_skim: int = 0


func _ready() -> void:
	_load_records()
	load_shift()


func has_save() -> bool:
	return FileAccess.file_exists("user://shift.cfg")


func has_speedrun() -> bool:
	return FileAccess.file_exists("user://speedrun.cfg")


func speedrun_active() -> bool:
	if not has_speedrun():
		return false
	var cfg := ConfigFile.new()
	if cfg.load("user://speedrun.cfg") != OK:
		return false
	return not bool(cfg.get_value("p", "done", false))


func speedrun_clock() -> float:
	var cfg := ConfigFile.new()
	if cfg.load("user://speedrun.cfg") != OK:
		return -1.0
	return float(cfg.get_value("p", "run", -1.0))


func continue_shift() -> void:
	_keep_current()
	_dev_session = false
	profile = "shift"
	_wipe_run()
	load_shift()
	_open_dev_session()


func continue_speedrun() -> void:
	_keep_current()
	_dev_session = false
	profile = "speedrun"
	_wipe_run()
	load_shift()
	_open_dev_session()


func new_shift() -> void:
	_keep_current()
	_dev_session = false
	profile = "shift"
	_wipe_run()
	tutorial = 0
	if dev_mode:
		_grant_dev()
	save_shift()


func new_speedrun() -> void:
	_keep_current()
	_dev_session = false
	profile = "speedrun"
	_wipe_run()
	tutorial = 6
	if dev_mode:
		_grant_dev()
	save_shift()


func _open_dev_session() -> void:
	if not dev_mode:
		return
	_grant_dev()
	_dev_session = true


func _grant_dev() -> void:
	completed = false
	rank = 4
	if reputation >= REP_NEED[4]:
		reputation = REP_NEED[4] - 1
	tutorial = 6
	for track in TRACKS:
		var costs: Array = track["costs"]
		tiers[str(track["id"])] = costs.size()


func _keep_current() -> void:
	if FileAccess.file_exists(_file()):
		save_shift()


func _wipe_run() -> void:
	money = 0
	rank = 0
	reputation = 42
	sheets_this_rank = 0
	completed = false
	tutorial = 0
	tiers.clear()
	times.clear()
	score = 0
	streak = 0
	run_time = 0.0
	next_mark = 1000
	pb_locked = false
	beat_pb = false
	lesson_price = 0
	worker_name = ""
	skin = 0
	badge_rank = -1
	met_janitor = false
	pardon = 0
	break_hold = 0
	chain_save = 0
	quiet_skim = 0


func _file() -> String:
	if profile == "speedrun":
		return "user://speedrun.cfg"
	return "user://shift.cfg"


func load_shift() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(_file()) != OK:
		return
	money = int(cfg.get_value("p", "money", 0))
	rank = int(cfg.get_value("p", "rank", 0))
	reputation = int(cfg.get_value("p", "rep", 42))
	sheets_this_rank = int(cfg.get_value("p", "sheets", 0))
	completed = bool(cfg.get_value("p", "done", false))
	tutorial = int(cfg.get_value("p", "tutor", 0))
	lesson_price = int(cfg.get_value("p", "lesson", 0))
	worker_name = str(cfg.get_value("p", "name", ""))
	skin = clampi(int(cfg.get_value("p", "skin", 0)), 0, SKIN_NAME.size() - 1)
	met_janitor = bool(cfg.get_value("p", "janitor", false))
	pardon = mini(1, int(cfg.get_value("p", "pardon", 0)))
	break_hold = int(cfg.get_value("p", "break_n", -1))
	if break_hold < 0:
		var old_break: float = float(cfg.get_value("p", "break", 0.0))
		break_hold = 1 if old_break > 0.0 else 0
	break_hold = mini(1, break_hold)
	chain_save = mini(1, int(cfg.get_value("p", "insure", 0)))
	quiet_skim = mini(1, int(cfg.get_value("p", "quiet", 0)))
	if cfg.has_section_key("p", "badge"):
		badge_rank = int(cfg.get_value("p", "badge", rank))
	else:
		badge_rank = rank
	var tutor_version := int(cfg.get_value("p", "tutor_v", 0))
	var migrated := false
	if tutor_version < 2:
		migrated = true
		if tutorial == 1:
			tutorial = 2
		elif tutorial == 2:
			tutorial = 3
		elif tutorial == 3:
			tutorial = 4
		elif tutorial >= 4:
			tutorial = 6
	score = int(cfg.get_value("p", "score", 0))
	streak = int(cfg.get_value("p", "streak", 0))
	run_time = float(cfg.get_value("p", "run", 0.0))
	next_mark = int(cfg.get_value("p", "mark", 1000))
	pb_locked = bool(cfg.get_value("p", "pb_lock", false))
	beat_pb = bool(cfg.get_value("p", "beat", false))
	tiers.clear()
	var packed := str(cfg.get_value("p", "tiers", ""))
	if packed != "":
		for piece in packed.split(",", false):
			var bits: PackedStringArray = piece.split(":", false)
			if bits.size() == 2:
				tiers[bits[0]] = int(bits[1])
	times.clear()
	var packed_times := str(cfg.get_value("p", "times", ""))
	if packed_times != "":
		for piece in packed_times.split(",", false):
			times.append(float(piece))
	if next_mark < 1000:
		next_mark = 1000
	while score >= next_mark:
		next_mark = _mark_after(next_mark)
	if migrated:
		save_shift()


func save_shift() -> void:
	if _dev_session:
		return
	var cfg := ConfigFile.new()
	cfg.set_value("p", "money", money)
	cfg.set_value("p", "rank", rank)
	cfg.set_value("p", "rep", reputation)
	cfg.set_value("p", "sheets", sheets_this_rank)
	cfg.set_value("p", "done", completed)
	cfg.set_value("p", "tutor", tutorial)
	cfg.set_value("p", "tutor_v", 2)
	cfg.set_value("p", "lesson", lesson_price)
	cfg.set_value("p", "name", worker_name)
	cfg.set_value("p", "skin", skin)
	cfg.set_value("p", "badge", badge_rank)
	cfg.set_value("p", "janitor", met_janitor)
	cfg.set_value("p", "pardon", pardon)
	cfg.set_value("p", "break_n", break_hold)
	cfg.set_value("p", "insure", chain_save)
	cfg.set_value("p", "quiet", quiet_skim)
	cfg.set_value("p", "score", score)
	cfg.set_value("p", "streak", streak)
	cfg.set_value("p", "run", run_time)
	cfg.set_value("p", "mark", next_mark)
	cfg.set_value("p", "pb_lock", pb_locked)
	cfg.set_value("p", "beat", beat_pb)
	var tier_bits: PackedStringArray = []
	for key in tiers.keys():
		tier_bits.append("%s:%d" % [str(key), int(tiers[key])])
	cfg.set_value("p", "tiers", ",".join(tier_bits))
	var time_bits: PackedStringArray = []
	for sample in times:
		time_bits.append("%.2f" % sample)
	cfg.set_value("p", "times", ",".join(time_bits))
	cfg.save(_file())


func tier_of(id: String) -> int:
	return int(tiers.get(id, 0))


func track_def(id: String) -> Dictionary:
	for track in TRACKS:
		if str(track["id"]) == id:
			return track
	return {}


func next_cost(id: String) -> int:
	var track: Dictionary = track_def(id)
	if track.is_empty():
		return 0
	var costs: Array = track["costs"]
	var current: int = tier_of(id)
	if current >= costs.size():
		return 0
	if id == "sprint" and current == 0 and lesson_price > 0:
		return lesson_price
	return int(costs[current])


func can_buy(id: String) -> bool:
	if completed:
		return false
	var track: Dictionary = track_def(id)
	if track.is_empty():
		return false
	if rank < int(track["rank"]):
		return false
	var costs: Array = track["costs"]
	var current: int = tier_of(id)
	if current >= costs.size():
		return false
	return money >= int(costs[current])


func try_buy(id: String) -> bool:
	if not can_buy(id):
		return false
	money -= next_cost(id)
	tiers[id] = tier_of(id) + 1
	save_shift()
	return true


func move_speed() -> float:
	return 4.2 + float(tier_of("speed")) * 0.42


func sprint_mult() -> float:
	var tier: int = tier_of("sprint")
	if tier <= 0:
		return 1.0
	return 1.45 + float(tier - 1) * 0.12


func grip_accel() -> float:
	return 22.0 + float(tier_of("grip")) * 4.0


func cart_slots() -> int:
	if tier_of("cart") <= 0:
		return 0
	return 4


func carry_mult() -> float:
	var scale: float = 0.55 + float(tier_of("carry")) * 0.06 + float(tier_of("cart")) * 0.08
	return minf(scale, 1.0)


func pop_cd() -> float:
	var cd: float = 0.26 - float(tier_of("callus")) * 0.02 - float(tier_of("knuckle")) * 0.012
	var thimble: int = tier_of("thimble")
	if thimble > 0:
		cd *= 1.0 - float(thimble) * 0.08
	return maxf(cd, 0.045)


func far_rows(row_count: int) -> int:
	var base: int = 1 if row_count < 7 else 2
	return maxi(0, base - int(tier_of("reach") / 2))


func tool_ready(id: String) -> bool:
	return tier_of(id) > 0


func note_burn(seconds: float, missed: int, popped: int, kind: int, chain: int = 0, lesson: bool = false) -> Dictionary:
	var safe_kind: int = clampi(kind, 0, ROLL_NAME.size() - 1)
	var total: int = maxi(1, popped + missed)
	var worth: int = roll_worth(safe_kind)
	var gross: int = int(floor(float(popped) * float(worth) / float(total)))
	var miss_dock: int = int(floor(float(missed) * float(worth) / float(total)))
	if missed == 0:
		gross = worth
		miss_dock = 0
	elif popped == 0:
		gross = 0
		miss_dock = worth
	var over: float = maxf(0.0, seconds - PAR[mini(rank, 4)])
	var slow_dock: int = int(floor(over * float(SLOW_RATE[mini(rank, 4)])))
	if not lesson:
		if missed == 0:
			streak += 1
		else:
			streak = 0
	if lesson:
		gross = worth
		miss_dock = 0
		slow_dock = 0
	var pop_m := 1.0
	var sheet_m := 1.0
	if not lesson and chain > 0:
		pop_m = 1.0 + float(chain) * pop_step()
	if not lesson and streak >= 2:
		sheet_m = 1.0 + 0.1 * float(streak - 1)
	var multiplied: int = gross
	if not lesson:
		multiplied = int(floor(float(gross) * pop_m * sheet_m))
	var skim_pay := 0
	var nose_extra := 0
	if not lesson:
		skim_pay = int(floor(float(gross) * float(tier_of("skim")) * 0.2))
	var take: int = maxi(0, multiplied - miss_dock - slow_dock + skim_pay)
	money += take
	var rep_delta: int = _rep_change(missed, seconds)
	if not lesson and rep_delta > 0:
		nose_extra = int(ceili(float(rep_delta) * float(tier_of("nose")) * 0.2))
	var offer: bool = note_rep(rep_delta + nose_extra)
	times.append(seconds)
	while times.size() > 8:
		times.pop_front()
	sheets_this_rank += 1
	save_shift()
	var lines: Array = []
	lines.append({"text": "+$%d" % gross, "good": true})
	if pop_m > 1.05:
		lines.append({"text": "x%.1f  pops" % pop_m, "good": true})
	if sheet_m > 1.05:
		lines.append({"text": "x%.1f  perfect" % sheet_m, "good": true})
	if skim_pay > 0:
		lines.append({"text": "+$%d  skim" % skim_pay, "good": true})
	lines.append({"text": roll_name(safe_kind), "good": true})
	if missed > 0:
		if miss_dock > 0:
			lines.append({"text": "-$%d  missed pops" % miss_dock, "good": false})
		else:
			lines.append({"text": "%d missed pops" % missed, "good": false})
	if slow_dock > 0:
		lines.append({"text": "-$%d  too much time" % slow_dock, "good": false})
	lines.append({"text": "Took home $%d" % take, "good": take > 0 and missed == 0})
	if rep_delta > 0:
		lines.append({"text": "+%d rep" % rep_delta, "good": true})
	elif rep_delta < 0:
		lines.append({"text": "%d rep" % rep_delta, "good": false})
	else:
		lines.append({"text": "0 rep", "good": false})
	if nose_extra > 0:
		lines.append({"text": "+%d rep  brownnoser" % nose_extra, "good": true})
	return {
		"gross": gross,
		"miss_dock": miss_dock,
		"slow_dock": slow_dock,
		"take": take,
		"missed": missed,
		"offer": offer,
		"lines": lines,
	}


func _rep_change(missed: int, seconds: float) -> int:
	if missed == 0 and seconds <= PAR[mini(rank, 4)]:
		return 6
	if missed == 0:
		return 3
	if missed <= 2:
		return 0
	return -mini(15, missed - 2)


func note_rep(amount: int) -> bool:
	var before: int = reputation
	reputation = maxi(0, reputation + amount)
	if completed or rank >= 5:
		return false
	var need: int = REP_NEED[rank]
	return before < need and reputation >= need


func promotion_ready() -> bool:
	if completed or rank >= 5:
		return false
	return reputation >= REP_NEED[rank]


func accept_promotion() -> void:
	if not promotion_ready():
		return
	rank += 1
	if rank >= 5:
		completed = true
		if profile == "speedrun" and not pb_locked:
			pb_locked = true
			beat_pb = speedrun_pb < 0.0 or run_time < speedrun_pb
			if beat_pb:
				speedrun_pb = run_time
				_save_records()
	save_shift()


func rank_pitch(next_rank: int) -> PackedStringArray:
	var lines: PackedStringArray = []
	if next_rank >= 5:
		lines.append("The office. The headset. The last tag.")
		return lines
	lines.append("Every sheet gains a row and a column.")
	var before: int = PAY[mini(next_rank - 1, 4)]
	var after: int = PAY[mini(next_rank, 4)]
	if after > before:
		lines.append("The green number goes from x%d to x%d." % [before, after])
	else:
		lines.append("Pay stays x%d. The sheets are the raise." % after)
	var tools: PackedStringArray = []
	for track in TRACKS:
		if int(track["rank"]) == next_rank:
			tools.append(str(track["name"]))
	if tools.size() > 0:
		lines.append("The counter unlocks %s." % ", ".join(tools))
	return lines


func clean_name(raw: String) -> String:
	var out := ""
	for i in raw.length():
		var ch := raw[i]
		var ok := ch == " " or ch == "-" or ch == "'"
		if not ok and ch >= "A" and ch <= "Z":
			ok = true
		if not ok and ch >= "a" and ch <= "z":
			ok = true
		if not ok and ch >= "0" and ch <= "9":
			ok = true
		if ok:
			out += ch
	out = out.strip_edges()
	while out.contains("  "):
		out = out.replace("  ", " ")
	if out.length() > 18:
		out = out.substr(0, 18).strip_edges()
	return out


func display_name() -> String:
	var who := worker_name.strip_edges()
	if who == "":
		return "Worker"
	return who


func review_fill() -> float:
	if completed or rank >= 5:
		return 1.0
	var floor_rep := 0
	if rank > 0:
		floor_rep = REP_NEED[rank - 1]
	var ceil_rep: int = REP_NEED[mini(rank, 4)]
	var span := maxi(1, ceil_rep - floor_rep)
	return clampf(float(reputation - floor_rep) / float(span), 0.0, 1.0)


func status_line() -> String:
	if completed or rank >= 5:
		return "The office is yours. Don't redecorate."
	if promotion_ready():
		return "%s   ·   promotion ready" % RANK[rank]
	return RANK[rank]


func dossier() -> String:
	if completed or rank >= 5:
		var done := "The office is yours. The headset still smells."
		if profile == "speedrun":
			var best_done := "none yet" if speedrun_pb < 0.0 else format_time(speedrun_pb)
			return _with_office("%s\nTime   %s\nBest   %s" % [done, format_time(run_time), best_done])
		return _with_office(done)
	if profile == "speedrun":
		var best := "none yet" if speedrun_pb < 0.0 else format_time(speedrun_pb)
		return _with_office("Time   %s\nBest   %s" % [format_time(run_time), best])
	if promotion_ready():
		return _with_office("Next   %s\nThe red button will take you, if you want the headache." % RANK[rank + 1])
	return _with_office("Next   %s\nAnnual Review is on the computer." % RANK[rank + 1])


func office_line() -> String:
	var bits: PackedStringArray = []
	var nose := tier_of("nose")
	var skim := tier_of("skim")
	if nose > 0:
		bits.append("Brownnoser +%d%%" % (nose * 20))
	if skim > 0:
		bits.append("Skim +%d%%" % (skim * 20))
	var compound := tier_of("compound")
	if compound > 0:
		bits.append("Compound +%.1f" % (0.1 * float(1 + compound)))
	return "   ".join(bits)


func _with_office(text: String) -> String:
	var extra := office_line()
	if extra == "":
		return text
	return "%s\n%s" % [text, extra]


func pop_step() -> float:
	return 0.1 * float(1 + tier_of("compound"))


func roll_count() -> int:
	return ROLL_NAME.size()


func roll_cols(kind: int) -> int:
	return ROLL_COLS[clampi(kind, 0, ROLL_COLS.size() - 1)] + rank


func roll_rows(kind: int) -> int:
	return ROLL_ROWS[clampi(kind, 0, ROLL_ROWS.size() - 1)] + rank


func roll_worth(kind: int) -> int:
	return ROLL_WORTH[clampi(kind, 0, ROLL_WORTH.size() - 1)] * PAY[mini(rank, 4)]


func roll_color(kind: int) -> Color:
	return Color(ROLL_COLOR[clampi(kind, 0, ROLL_COLOR.size() - 1)])


func roll_paper(kind: int) -> Color:
	return Color(ROLL_PAPER[clampi(kind, 0, ROLL_PAPER.size() - 1)])


func roll_name(kind: int) -> String:
	return ROLL_NAME[clampi(kind, 0, ROLL_NAME.size() - 1)]


func roll_radius(kind: int) -> float:
	return ROLL_RADIUS[clampi(kind, 0, ROLL_RADIUS.size() - 1)]


func add_score(amount: int) -> int:
	if amount <= 0:
		return 0
	score += amount
	var hit := 0
	while score >= next_mark:
		hit = next_mark
		next_mark = _mark_after(next_mark)
	return hit


func _mark_after(mark: int) -> int:
	var steps: Array[int] = [1000, 5000, 10000, 25000, 50000, 100000, 250000, 500000, 1000000]
	for step in steps:
		if step > mark:
			return step
	return mark + 1000000


func format_number(value: int) -> String:
	var negative := value < 0
	var digits := str(absi(value))
	var grouped := ""
	while digits.length() > 3:
		grouped = "," + digits.substr(digits.length() - 3, 3) + grouped
		digits = digits.substr(0, digits.length() - 3)
	grouped = digits + grouped
	if negative:
		return "-" + grouped
	return grouped


func format_time(seconds: float) -> String:
	var cs := int(floor(maxf(0.0, seconds) * 100.0))
	var hours := int(cs / 360000)
	var mins := int(cs / 6000) % 60
	var secs := int(cs / 100) % 60
	var frac := cs % 100
	if hours > 0:
		return "%d:%02d:%02d.%02d" % [hours, mins, secs, frac]
	return "%02d:%02d.%02d" % [mins, secs, frac]


func _load_records() -> void:
	var cfg := ConfigFile.new()
	if cfg.load("user://records.cfg") != OK:
		return
	speedrun_pb = float(cfg.get_value("r", "pb", -1.0))


func _save_records() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("r", "pb", speedrun_pb)
	cfg.save("user://records.cfg")
