extends Node3D

const UI = preload("res://scripts/ui_build.gd")
const SheetScript = preload("res://scripts/sheet.gd")
const PlayerScript = preload("res://scripts/player.gd")
const SettingsMenu = preload("res://scripts/settings_menu.gd")
const INCINERATOR := preload("res://assets/factory/incinerator.fbx")

const TOOL_HAND := 0
const TOOL_PAIR := 1
const TOOL_HAMMER := 2
const TOOL_TWIST := 3
const TOOL_ROW := 4
const TOOL_LANE := 5
const TOOL_BRAYER := 6
const TOOL_IDS: PackedStringArray = ["", "pair", "hammer", "twist", "row", "lane", "brayer"]
const TOOL_NAMES: PackedStringArray = ["Hand", "Hands", "Hammer", "Twist", "Row", "Lane", "Brayer"]
const BOSS_CHATTER: PackedStringArray = [
	"You're late. The pipe is on the left wall. I am in the office, the good room, because you are not in it.",
	"Back again. The bubbles did not miss you. I didn't either.",
	"The burner is on your right. Arrive with a flat sheet and fewer excuses.",
	"The air in those rolls is leftover on purpose. Don't huff it. I don't do paperwork.",
	"If you can hear a bubble, so can I. I have a gift, and it is annoying.",
	"Walk faster. The floor is not a scenic overlook.",
	"I pay you to pop them, not to name them.",
	"The fumes are a you problem. The sheet is a me problem. Guess which one I fund.",
	"Don't lean on the pipe. It drops rolls, not sympathy.",
	"Every full bubble is a tiny resignation letter.",
	"I can see you from here. That is not a compliment.",
	"The cart is not a pet. Stop visiting it.",
	"If the sheet is quiet, you did it right. If it squeaks, we have a conversation.",
	"I turned the lights on once. Don't make me sentimental.",
	"Your shoes are loud. The bubbles are louder. Fix the bubbles.",
	"A perfect sheet is the bare minimum dressed up as a talent.",
	"I don't want a story. I want a flat rectangle and a walk to the fire.",
	"The office door stays shut. That is the whole benefit package.",
	"Breathe through your mouth if you must. I am not explaining that to a doctor.",
	"You are allowed to be fast. You are not allowed to be interesting.",
	"Extra pay shows up as email. The computer is on this wall, to my right. Don't hover. Hovering is needy.",
	"Drop a roll and I will remember the sound. I remember all the bad sounds.",
	"The far bubbles are not a vacation. They are still bubbles.",
	"I don't do pep talks. This is the closest you get, and it is already over.",
	"If payroll asks, you love it here.",
	"The burner does not need a speech. It needs a sheet.",
	"Stand still too long and I start charging rent for the floor.",
	"Those rolls were full when they arrived. They will be empty when they leave. That is the whole plot.",
	"I hired you because you were nearby. Try to make that sound like a choice.",
	"Don't wave at the intercom. I can already hear you disappointing me.",
	"A slow walk is a long walk. I bill both.",
	"HR is not a lounge. Buy something or keep popping.",
	"I counted the bubbles. Then I stopped, because I trust the sound more than you.",
	"Flat, then fire. If you invent a third step, it will not be paid.",
	"The dark was the tutorial. The light is not a friendship.",
	"You may sprint. You may not narrate the sprint.",
	"I left the good chair in the office. You get the floor and a purpose.",
	"If a bubble survives, it becomes my hobby. I have enough hobbies.",
	"The furnace is hungry in a boring way. Feed it.",
	"Don't thank me. Thanking me implies I did something, and I am off the clock in my heart.",
]
const BOSS_RUN: PackedStringArray = [
	"Clock's on. HR does not stop it. Sweating is allowed.",
	"Your best is on the board. Try to embarrass it.",
	"Same job. Less standing around. The clock is my love language.",
	"Every second you admire a roll is a second I am writing down.",
	"The timer does not care that you are new. Neither do I, but the timer is ruder.",
	"Pause if you must. The clock keeps the part of the day I respect.",
	"A record is just a mistake you have not made yet.",
	"Faster is the only compliment I have in stock.",
	"Don't look at the time. I am looking at it for both of us, and I am not enjoying it.",
	"HR is open. The clock is also open. Choose badly.",
	"If you beat your best, I will nod. The nod will be private.",
	"Standing at the pipe is not a strategy. I checked.",
	"The fumes do not get a time bonus. You might.",
	"I would wish you luck, but luck asks for a raise.",
	"Finish the office and we will see whose number was smaller. I hope it is yours. I will not say that twice.",
]
const BOSS_PERFECT: PackedStringArray = [
	"Flat. I almost said good job. I caught myself.",
	"Quiet sheet. That is the sound of me not calling you.",
	"All of them. I will note it in a tone of mild inconvenience.",
	"Nothing squeaked. I am choosing to be normal about that.",
	"Flat enough. Don't wait for a medal. The medal budget bought the lights.",
	"I heard the last one go. It did not plead. I respect that.",
	"A whole sheet, gone. The burner will pretend it was his idea.",
	"You got them all. I am not proud. I am less annoyed, which is my version.",
	"No leftovers. Ironic, and I will not be explaining the name.",
	"That was complete. Write it down yourself. I am busy not smiling.",
]
const BOSS_MISS: PackedStringArray = [
	"I can hear the plump ones from here. So can payroll.",
	"You left some alive. They are telling on you.",
	"A full bubble in the fire is just a louder mistake.",
	"I counted a survivor. It sounded smug.",
	"Pop them before they meet the burner. The burner is a gossip.",
	"That squeak was a bill. You will see it. You will not like the font.",
	"Missed a few. The sheet is gone anyway. The money is the part that noticed.",
	"I don't need to see the sheet. The sound already filed a complaint.",
	"Those were supposed to be flat. Flat is a simple shape. Even for you.",
	"A plump bubble is a tiny resignation. Stop accepting them.",
]
const BOSS_SLOW: PackedStringArray = [
	"The burner cooled off waiting. I billed you for its time. It does not even own a watch.",
	"You took the scenic route. I charged admission.",
	"The clock was patient. I was not. The clock still won.",
	"Late sheets pay a toll. The toll is boring, like the walk you just took.",
	"I aged during that one. Not much. Enough to invoice.",
	"Speed is an upgrade because you needed the hint.",
	"The fire had time to think. Nothing good comes from a fire with hobbies.",
	"That walk had chapters. I only pay for the ending, and I paid less.",
	"You arrived. The discount arrived with you.",
	"Next time, less tourism.",
]
const BOSS_BONUS_STEP: PackedStringArray = [
	"%d down. %d left. I am not clapping. Clapping is for people with friends.",
	"%d done. %d still owed. The clock did not become your friend.",
	"That's %d. %d remain. Don't look at me like I should be pleased.",
	"%d in the fire. %d still on the hook. I am the hook.",
	"Progress. %d down, %d still out. I said progress, not praise.",
]
const BOSS_BONUS_SKIP: PackedStringArray = [
	"That one does not count. The offer was specific. I was also specific.",
	"Wrong sheet for the offer. I don't do rounding.",
	"I heard it burn. I did not hear it qualify.",
	"Close. Close is another word for no.",
	"The bonus wanted something else. So did I. We agree, which is rare and unpleasant.",
]
const BOSS_BONUS_WIN: PackedStringArray = [
	"Huh. $%d. If you tell the others, I will invent a fine with your name on it.",
	"$%d. Don't frame it. The frame costs more.",
	"You made the clock look bad. Here is $%d. We will not discuss it.",
	"Paid. $%d. If you cheer, I will add a squeaky bubble to the next roll by hand.",
	"$%d for doing the extra thing. The regular thing was already your job.",
]
const BOSS_BONUS_FAIL: PackedStringArray = [
	"Too slow. The offer died of boredom. I did not send flowers.",
	"Time. The bonus left. It did not slam the door. I did.",
	"That's the clock, winning again. It has a perfect record against you today.",
	"Offer expired. I would say better luck, but luck is not on payroll.",
	"You were still walking when the money changed its mind.",
	"Late. The bonus is ash. The sheets can still be ash. Different ash.",
]
const BOSS_OFFER: PackedStringArray = [
	"Bonus incentive. It is in your email. The computer is on this wall, to my right.",
	"I have a number and a clock. They are in an email, because I refuse to hold paper.",
	"Extra money is available. It is embarrassed to be available. Read the mail.",
	"Your inbox is briefly generous. Briefly. The computer is to my right.",
	"An offer is sitting in your email. It will not sit long. Neither do I.",
]
const MAIL_SUBJECTS: PackedStringArray = [
	"RE: your continued existence",
	"ACTION REQUIRED: sheets",
	"Bonus, unfortunately",
	"From the office, with a timer",
	"Please burn the following",
]
const MAIL_JOKES: PackedStringArray = [
	"Corporate noticed you are still employed. This is not a compliment. It is a timed assignment. The sidebar has the part that pays.",
	"The spreadsheet grew a feeling. The feeling is money, and it expires. Do not reply all. Replying all is a resignation.",
	"Please burn the following before the clock files a complaint. The clock has a lawyer. The lawyer is also a clock.",
	"A bonus was approved by someone who does not know your name. Use it before they learn it and change their mind.",
	"HR did not write this. HR writes forms. I write threats with a pay line. The pay line is on the right, where feelings go to die.",
	"Attached: work. Not attached: patience. The left side is personality. Personality does not pay. The right side does.",
	"This message is an incentive. If you print it, I will deny the printer. If you finish it, I will deny I was impressed.",
	"Do the job on the right. The body of this email is legally a sigh. The sigh is not billable.",
]
const BOSS_BUTTON: PackedStringArray = [
	"That button is for when I feel generous. Today is not looking generous.",
	"No offer. No speech. The button is just red, like my calendar.",
	"Pressing it does not summon money. I checked, in case you were magic.",
	"Nothing on the board. Go pop something. The button will survive without you.",
	"I don't have a bonus right now. Try again when I am bored. I am bored often. Not this second.",
]
const BOSS_CLOCK: PackedStringArray = [
	"The clock is running. Talking to me does not pause it. I checked twice.",
	"Still timing you. The button is not a break room.",
	"You can press it again. The seconds will not be impressed.",
	"I am not pausing anything. Ask the clock. It agrees with me, which is why I like it.",
]
const BOSS_PROMO: PackedStringArray = [
	"Promotion. Don't get emotional. Press the red button if you want the speech.",
	"They want to rename you. The red button has the paperwork. I refuse to hold it.",
	"A rank is available. Try not to cry on the intercom. It echoes.",
]
const JANITOR_INTRO := "New shoes. Wrong door for the boss. Right door for me."
const JANITOR_PITCH := "Cash. One use. He writes people up for these. I just sell them."
const JANITOR_LINES: PackedStringArray = [
	"Whatareya buyin?",
	"Knock softer. The intercom has ears. I have a slot.",
	"Back again. The mop is a cover. You knew that.",
	"If you tell the office, I will deny this door exists.",
	"Eyes only. The rest of me is on a break that never ends.",
	"You smell like the sheets. Don't drip on my closet.",
	"The bucket is not a bucket. We'll get there.",
	"I heard the promotion. I am not impressed. I am here.",
	"Keep your hands where the slot can see them.",
	"Most people want a shortcut. You found a slot. Close enough.",
]
const HIRE_SPEECH := "New hire. You get a name because a form asked. You do not get a chair. You pop the sheets. They are full of gas. Pop it out before you burn them, and try not to breathe it. I am the box. I do not walk over. Press the button again. It tells me you were listening."
const RANK_SPEECH: PackedStringArray = [
	"",
	"Pop Associate. Say it once, quietly. The sheets grew. The hammer is on the counter. I am still not proud of you. The tag has your name so I don't have to learn it.",
	"Sheet Tech. The green number just doubled. That was the raise. The fumes did not get worse. They were already enough. Wear the tag. It is the whole celebration.",
	"Floor Lead. You get a cart and a row. People will ask you things. Send them to me. I will not answer. The tag is so they stop calling you by the smell.",
	"Shift Supervisor. You can see the office from here. You cannot have it. The wide tools are unlocked. This is the last tag I wanted to print.",
	"",
]
const BOSS_GRAB: PackedStringArray = [
	"%s. Don't take the scenic route. The clock started out of spite.",
	"%s. The clock noticed. It is not impressed.",
	"%s. Walk it over. I can hear you considering a detour.",
	"Another %s. The floor did not ask for this, and neither did I.",
	"%s. Same job as the last one. Try to look surprised.",
]
const BOSS_PROMO_NO: PackedStringArray = [
	"Suit yourself. The button stays red. So does my opinion of you.",
	"Fine. Stay where you are. The fumes were going to stay anyway.",
	"Declined. Ambitious in the other direction. I will note it nowhere.",
]
# rule: any, perfect, fast, kind, chain. mark is the roll or the chain size.
const INCENTIVES: Array = [
	{"rule": "any", "mark": 0, "need": 1, "seconds": 40, "pay": 22, "weight": 8},
	{"rule": "perfect", "mark": 0, "need": 1, "seconds": 50, "pay": 36, "weight": 7},
	{"rule": "fast", "mark": 0, "need": 1, "seconds": 48, "pay": 32, "weight": 6},
	{"rule": "kind", "mark": 0, "need": 1, "seconds": 45, "pay": 28, "weight": 6},
	{"rule": "chain", "mark": 6, "need": 1, "seconds": 55, "pay": 40, "weight": 5},
	{"rule": "any", "mark": 0, "need": 2, "seconds": 80, "pay": 48, "weight": 6},
	{"rule": "perfect", "mark": 0, "need": 2, "seconds": 100, "pay": 80, "weight": 5},
	{"rule": "kind", "mark": 1, "need": 1, "seconds": 60, "pay": 44, "weight": 5},
	{"rule": "fast", "mark": 0, "need": 2, "seconds": 110, "pay": 90, "weight": 4},
	{"rule": "chain", "mark": 10, "need": 1, "seconds": 70, "pay": 70, "weight": 4},
	{"rule": "any", "mark": 0, "need": 3, "seconds": 140, "pay": 110, "weight": 5},
	{"rule": "perfect", "mark": 0, "need": 3, "seconds": 170, "pay": 180, "weight": 4},
	{"rule": "kind", "mark": 2, "need": 1, "seconds": 75, "pay": 64, "weight": 4},
	{"rule": "kind", "mark": 1, "need": 2, "seconds": 130, "pay": 120, "weight": 4},
	{"rule": "fast", "mark": 0, "need": 3, "seconds": 160, "pay": 160, "weight": 3},
	{"rule": "chain", "mark": 8, "need": 2, "seconds": 150, "pay": 150, "weight": 3},
	{"rule": "any", "mark": 0, "need": 4, "seconds": 200, "pay": 170, "weight": 4},
	{"rule": "perfect", "mark": 0, "need": 4, "seconds": 240, "pay": 280, "weight": 3},
	{"rule": "kind", "mark": 3, "need": 1, "seconds": 85, "pay": 90, "weight": 3},
	{"rule": "kind", "mark": 2, "need": 2, "seconds": 160, "pay": 190, "weight": 3},
	{"rule": "fast", "mark": 0, "need": 4, "seconds": 220, "pay": 240, "weight": 2},
	{"rule": "any", "mark": 0, "need": 5, "seconds": 260, "pay": 230, "weight": 3},
	{"rule": "chain", "mark": 10, "need": 3, "seconds": 220, "pay": 260, "weight": 2},
	{"rule": "any", "mark": 0, "need": 6, "seconds": 340, "pay": 360, "weight": 3},
	{"rule": "perfect", "mark": 0, "need": 5, "seconds": 320, "pay": 460, "weight": 2},
	{"rule": "kind", "mark": 3, "need": 2, "seconds": 180, "pay": 240, "weight": 2},
	{"rule": "fast", "mark": 0, "need": 6, "seconds": 340, "pay": 420, "weight": 2},
	{"rule": "any", "mark": 0, "need": 8, "seconds": 460, "pay": 560, "weight": 2},
	{"rule": "kind", "mark": 2, "need": 4, "seconds": 300, "pay": 480, "weight": 1},
	{"rule": "kind", "mark": 3, "need": 3, "seconds": 260, "pay": 420, "weight": 1},
	{"rule": "perfect", "mark": 0, "need": 6, "seconds": 420, "pay": 640, "weight": 1},
	{"rule": "any", "mark": 0, "need": 10, "seconds": 600, "pay": 820, "weight": 1},
	{"rule": "kind", "mark": 3, "need": 4, "seconds": 360, "pay": 700, "weight": 1},
	{"rule": "perfect", "mark": 0, "need": 8, "seconds": 520, "pay": 900, "weight": 1},
	{"rule": "chain", "mark": 12, "need": 5, "seconds": 400, "pay": 680, "weight": 1},
]

var player: PopWorker
var sheet: BubbleSheet
var sfx: Node
var cam: Camera3D
var work_cam: Camera3D
var hold: int = 0
var _roll_kind: int = 1
var working: bool = false
var table_mode: bool = false
var _work_ready: bool = false
var _fly: float = 1.0
var _fly_back: bool = false
var _fly_from: Transform3D
var _fly_to: Transform3D
var _fov_from: float = 75.0
var _fov_to: float = 42.0
var menu: String = ""
var errand: float = 0.0
var errand_on: bool = false
var _cart: Array = []
var _cart_root: Node3D
var _cart_zone: Area3D
var _pushing: bool = false
var carried_popped: int = 0
var carried_missed: int = 0
var tool: int = TOOL_HAND
var hint_shown: bool = false
var _step_wait: float = 0.0
var settings_back: String = "pause"
var _boss_life: float = 0.0
var _boss_idle: float = 28.0
var _boss_last: String = ""
var _grab_quiet: int = 0
var _mailer_meshes: Array[MeshInstance3D] = []
var _mailer_busy: bool = false
var _mailer_land: Vector3 = Vector3(-27.35, 0.72, 8.0)
var _mailer_path: PackedVector3Array = PackedVector3Array()
var _offer_in: float = 14.0
var _offer_left: float = 0.0
var _bonus_left: float = 0.0
var _bonus_target: String = ""
var _bonus_pay: int = 0
var _bonus_need: int = 0
var _bonus_done: int = 0
var _bonus_rule: String = ""
var _bonus_mark: int = 0
var _mail_rule: String = ""
var _mail_mark: int = 0
var _mail_need: int = 0
var _mail_seconds: float = 0.0
var _mail_pay: int = 0
var _mail_joke: String = ""
var _mail_subject: String = ""
var _desk_mat: StandardMaterial3D
var _voice_time: float = 0.0
var _button: MeshInstance3D
var _button_mat: StandardMaterial3D
var _button_rest: float = 0.0
var _voice: Node3D
var _tube_path: PackedVector3Array = PackedVector3Array()
var _canister: MeshInstance3D
var _badge: Node3D
var _badge_title: Label3D
var _badge_name: Label3D
var _badge_rest: Vector3 = Vector3.ZERO
var _badge_drop: bool = false
var _slot_cover: MeshInstance3D
var _slot_eyes: Node3D
var _slot_rest: float = 0.0
var _janitor_busy: bool = false
var _janitor_last: String = ""
var _zig_bits: Array[MeshInstance3D] = []
var _zig_bases: Array[Vector3] = []
var _rack_pos: Array[Vector3] = []
var _rack_kind: Array[int] = []
var _rack_mesh: Array[MeshInstance3D] = []

var walk_bar: Control
var money_label: Label
var tool_label: Label
var hotbar: Control
var _slot_panels: Array[Panel] = []
var _slot_keys: Array[Label] = []
var _slot_names: Array[Label] = []
var timer_label: Label
var cart_label: Label
var boss_card: HBoxContainer
var boss_label: Label
var boss_name: Label
var _boss_bust: Control
var _boss_bubble: PanelContainer
var prompt_root: PanelContainer
var prompt_label: Label
var pause_money: Label
var pause_detail: Label
var pause_tools: Label
var crosshair: Label
var result_box: VBoxContainer
var pause_root: Control
var shop_root: Control
var shop_list: VBoxContainer
var shop_blurb: Label
var shop_stats: Label
var closet_root: Control
var closet_list: VBoxContainer
var closet_blurb: Label
var closet_stats: Label
var _closet_visit: int = 0
var desk_root: Control
var desk_review: Control
var desk_mail: Control
var desk_custom: Control
var review_face: ReviewFace
var review_caption: Label
var review_fill_bar: ColorRect
var mail_subject: Label
var mail_body: Label
var mail_job: Label
var mail_time: Label
var mail_pay: Label
var mail_take: Button
var desk_name: LineEdit
var desk_name_hint: Label
var _skin_buttons: Array[Button] = []
var _desk_page: String = "review"
var settings_root: Control
var ending_root: Control
var ending_body: Label
var ending_button: Button
var ending_title: Label
var banner: Label
var bonus_label: Label
var promo_root: Control
var promo_body: Label
var ceremony_root: Control
var ceremony_title: Label
var ceremony_who: Label
var ceremony_body: Label
var _ceremony_token: int = 0
var _firing_token: int = 0
var _badge_done: Callable = Callable()
var _promo_quiet: bool = false
var _env: Environment
var _sun: DirectionalLight3D
var _trauma: float = 0.0
var hud_root: Control
var score_label: Label
var streak_label: Label
var chain_label: Label
var run_label: Label
var pb_label: Label
var _combo: int = 0
var _chain_time: float = 0.0
var _sheet_score: int = 0
var _sheet_peak: int = 0
var _shown_score: float = 0.0
var _run_save: float = 0.0
var _gain_labels: Array[Label] = []
var _table_lamp: OmniLight3D
var _incinerator: Node3D
var _door: AnimationPlayer
var _door_open: float = 2.0
var _flames: Array[MeshInstance3D] = []
var _fire_light: OmniLight3D
var _fire_time: float = 0.0
var _fire_kick: float = 0.0
var _spot: SpotLight3D
var _spot_fill: OmniLight3D
var _beam: MeshInstance3D
var _pool: MeshInstance3D
var _spot_pos: Vector3 = Vector3.ZERO
var _spot_aim: Vector3 = Vector3.ZERO
var _spot_snapped: bool = false
var _beam_hold: bool = true
var _spot_quiet: bool = false
var _sheet_lit: bool = false
var _lesson_dark: bool = false
var _tutor_line: int = 0
var _tutor_wait: float = 0.0
var _tutor_need_button: bool = false
var _tutor_button_pass: int = 0
var _tutor_need_tag: bool = false
var _pinning: bool = false
var _worn: Node3D
var _worn_title: Label3D
var _worn_name: Label3D
var _light_i: int = -1
var _light_wait: float = 0.0
var _beat_lights: Array[OmniLight3D] = []
var _beat_mats: Array = []
var _beat_energy: Array[float] = []
var _beat_glow: Array[float] = []


func _ready() -> void:
	_build_world()
	player = PlayerScript.new()
	add_child(player)
	player.set_skin(Game.skin)
	player.global_position = Vector3(0, 1.35, 20)
	_build_cart()
	cam = player.get_node("Camera3D")
	_build_worn_badge()
	work_cam = Camera3D.new()
	work_cam.name = "WorkCamera"
	work_cam.fov = 75.0
	work_cam.current = false
	add_child(work_cam)
	sheet = SheetScript.new()
	sheet.position = Vector3(0, 0.99, 0.15)
	sheet.rotation_degrees = Vector3(-90, 0, 0)
	sheet.visible = false
	add_child(sheet)
	sfx = FactorySfx.new()
	add_child(sfx)
	sheet.did_pop.connect(_on_sheet_pop)
	sheet.did_miss.connect(_on_sheet_miss)
	_build_hud()
	Settings.changed.connect(_apply_presentation)
	_apply_presentation()
	if Game.tutorial < 6:
		_begin_dark()
	if Game.completed:
		_show_ending()
	else:
		_set_menu("")
		_greet()
	_present_badge()


func _process(delta: float) -> void:
	if menu == "":
		if errand_on and Game.break_hold <= 0:
			errand += delta
		if Game.break_hold <= 0:
			for item in _cart:
				item["errand"] = float(item["errand"]) + delta
	_tick_fire(delta)
	_tick_door()
	_tick_steps(delta)
	_tick_incentives(delta)
	_tick_chain(delta)
	_tick_tally(delta)
	_tick_run(delta)
	_refresh_hud()
	_tick_boss(delta)
	_tick_chatter(delta)
	_animate_voice()
	_advance_fly(delta)
	_tick_shake(delta)
	_tick_tutor(delta)
	if menu != "":
		crosshair.hide()
		return
	if table_mode:
		crosshair.hide()
		walk_bar.hide()
		_set_prompt("%s    Roll it up" % _use_name())
		if working and _work_ready:
			var aim: Dictionary = _table_aim()
			var on_sheet: bool = bool(aim.get("hit", false))
			var local_point: Vector2 = aim.get("local", Vector2.ZERO)
			var popping: bool = Settings.pop_held()
			sheet.aim(on_sheet, local_point, popping, delta)
			if aim.has("point") and tool == TOOL_PAIR:
				var pair: Dictionary = sheet.hand_points(local_point)
				player.aim_pair(pair["right"], pair["left"])
			elif aim.has("point"):
				player.aim_table(aim["point"])
	else:
		crosshair.visible = Settings.show_crosshair
		walk_bar.visible = Settings.show_money
		if chain_label != null:
			chain_label.hide()
		_set_prompt(_prompt_for(_aimed_id()))


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	var key: Key = event.keycode
	if key == KEY_ESCAPE:
		_on_escape()
		return
	if menu != "":
		return
	if Settings.pressed(event, "use"):
		_on_interact()
	elif Settings.pressed(event, "throw"):
		if Game.tutorial < 6 and hold != 0:
			_nag("Hold the roll. We are not done, and neither is it.")
			return
		_release_roll(true)
	elif Settings.pressed(event, "cart"):
		_cart_press()
	else:
		for i in TOOL_IDS.size():
			if Settings.pressed(event, "tool%d" % (i + 1)):
				_select_tool(i)
				return


func _on_escape() -> void:
	if menu == "ending" or menu == "intercom":
		return
	if menu == "settings":
		_close_settings()
	elif menu == "shop":
		_set_menu("")
	elif menu == "pause":
		_set_menu("")
	elif menu == "promo":
		_decline_promotion()
	elif menu == "ceremony":
		_end_ceremony()
	elif menu == "firing":
		_skip_firing()
	elif menu == "closet":
		_close_closet()
	elif menu == "desk":
		_set_menu("")
	else:
		_set_menu("pause")


func _on_interact() -> void:
	if menu != "" or Game.completed or _pinning:
		return
	if _tutor_need_tag and _tag_in_reach(_aimed_id()):
		_pickup_tag()
		return
	if working:
		_roll_up()
		return
	if _pushing:
		_pushing = false
		_say("Off. It stays there. I am not pushing it for you.", 3.0)
		return
	var id: String = _aimed_id()
	if id == "Rack" and hold == 0:
		if Game.tutorial == 0:
			_nag("Over here. The rolls are not the light.")
			return
		if Game.tutorial == 5:
			_nag("Buy the sprint. The rolls will still be here. Unfortunately.")
			return
		_take_roll()
	elif id == "Bench" and hold == 1:
		_start_work()
	elif id == "Burner" and hold == 2:
		_burn()
	elif id == "Shop":
		if Game.tutorial < 5:
			_nag("HR is closed. I am not.")
			return
		_open_shop()
	elif id == "Closet":
		_knock_closet()
		return
	elif id == "Desk":
		_open_desk()
		return
	elif id == "Mailer":
		_press_mailer()
		return
	elif id == "Cart":
		if Game.tutorial < 6:
			_nag("The cart can wait. So can you.")
			return
		if Game.cart_slots() <= 0:
			_nag("You have not paid for a cart. Your arms remain the cart.")
			return
		_pushing = true
		_say("Push. Press E when you want off. It will not follow you after that.", 3.6)
		return
	elif id == "Speaker":
		if _tutor_need_button:
			_hire_button()
			return
		if Game.tutorial == 0:
			if _tutor_need_tag:
				_nag("The tag is in the bucket. Press E.")
			elif _tutor_wait > 0.0:
				_nag("I am still talking.")
			else:
				_nag("Almost. Let me finish.")
			return
		if Game.tutorial < 6:
			_nag("The button can wait. Do the thing the light is pointing at.")
			return
		_press_speaker()
	elif hold != 0:
		if Game.tutorial < 6:
			_nag("Hold the roll. Dropping it is not the lesson.")
			return
		_release_roll(false)
	elif hold == 0:
		var loose: RigidBody3D = _aimed_loose()
		if loose != null:
			_pickup_loose(loose)


func _take_roll() -> void:
	if hold != 0:
		return
	_roll_kind = _grab_roll()
	hold = 1
	errand = 0.0
	errand_on = true
	carried_popped = 0
	carried_missed = 0
	player.set_carry(1, Game.roll_color(_roll_kind))
	sfx.play_kind("clunk")
	var roll_name := Game.roll_name(_roll_kind)
	if Game.tutorial < 6:
		_tutor_line = 0
		_tutor_wait = 0.0
		Game.lesson_price = Game.roll_worth(_roll_kind)
		_tutor_to(2)
		_aim_spot(Vector3(0, 1.05, 0.15))
		_say("%s. Bring it to the popping table. Middle of the floor. Press E. The light will get there before you do." % roll_name, 7.0)
	else:
		_grab_chatter(_boss_line(BOSS_GRAB) % roll_name, 4.2)


func _release_roll(thrown: bool) -> void:
	if hold == 0 or working or table_mode or menu != "":
		return
	var forward: Vector3 = -cam.global_transform.basis.z
	forward.y = 0.0
	if forward.length() < 0.01:
		forward = Vector3(0, 0, -1)
	forward = forward.normalized()
	var origin: Vector3 = player.global_position + forward * (1.05 if thrown else 0.72) + Vector3(0, 0.62, 0)
	_spawn_loose(origin, forward, thrown)
	hold = 0
	errand_on = false
	errand = 0.0
	carried_popped = 0
	carried_missed = 0
	player.set_carry(0)
	sfx.play_kind("sweep" if thrown else "click")


func _spawn_loose(origin: Vector3, forward: Vector3, thrown: bool) -> void:
	var body := RigidBody3D.new()
	body.add_to_group("loose_roll")
	body.collision_layer = 8
	body.collision_mask = 9
	body.mass = 0.45
	body.continuous_cd = true
	body.linear_damp = 0.4
	body.angular_damp = 0.65
	body.set_meta("stage", hold)
	body.set_meta("kind", _roll_kind)
	body.set_meta("popped", carried_popped)
	body.set_meta("missed", carried_missed)
	body.set_meta("errand", errand)
	var radius: float = Game.roll_radius(_roll_kind)
	var cyl := CylinderMesh.new()
	cyl.top_radius = radius
	cyl.bottom_radius = radius
	cyl.height = 0.36
	cyl.radial_segments = 16
	var mesh := MeshInstance3D.new()
	mesh.mesh = cyl
	var tint: Color = Game.roll_color(_roll_kind)
	if hold == 2:
		tint = tint.lerp(Color("c4b8a4"), 0.72)
	mesh.material_override = _finish(tint, 0.42, Color(0, 0, 0), 0.0)
	body.add_child(mesh)
	var shape := CylinderShape3D.new()
	shape.radius = radius
	shape.height = 0.36
	var col := CollisionShape3D.new()
	col.shape = shape
	body.add_child(col)
	body.position = origin
	body.rotation = Vector3(0.0, randf() * TAU, PI * 0.5)
	add_child(body)
	if thrown:
		var look: Vector3 = -cam.global_transform.basis.z
		body.linear_velocity = look * 8.0 + Vector3.UP * 2.0
		body.angular_velocity = Vector3(randf_range(-5.0, 5.0), randf_range(-2.0, 2.0), randf_range(-5.0, 5.0))
	else:
		body.linear_velocity = forward * 0.7 + Vector3.DOWN * 0.5


func _aimed_loose() -> RigidBody3D:
	if cam == null or get_world_3d() == null:
		return null
	var from: Vector3 = cam.global_position
	var dir: Vector3 = -cam.global_transform.basis.z
	var query := PhysicsRayQueryParameters3D.create(from, from + dir * 4.2)
	query.collision_mask = 8
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		var collider: Object = hit.get("collider")
		if collider is RigidBody3D and (collider as Node).is_in_group("loose_roll"):
			return collider as RigidBody3D
	var best: RigidBody3D = null
	var best_dist: float = 2.3
	for node in get_tree().get_nodes_in_group("loose_roll"):
		var roll: RigidBody3D = node as RigidBody3D
		if roll == null:
			continue
		var to_roll: Vector3 = roll.global_position - from
		var dist: float = to_roll.length()
		if dist > best_dist or dist < 0.05:
			continue
		if to_roll.normalized().dot(dir) < 0.2:
			continue
		best = roll
		best_dist = dist
	return best


func _pickup_loose(body: RigidBody3D) -> void:
	if hold != 0 or body == null:
		return
	hold = int(body.get_meta("stage"))
	_roll_kind = int(body.get_meta("kind"))
	carried_popped = int(body.get_meta("popped"))
	carried_missed = int(body.get_meta("missed"))
	errand = float(body.get_meta("errand"))
	errand_on = true
	player.set_carry(hold, Game.roll_color(_roll_kind))
	body.queue_free()
	sfx.play_kind("clunk")
	if hold == 2:
		_grab_chatter("Already flat. The burner is that way. Try not to bond with it.", 3.2)
	elif Game.tutorial == 1:
		_tutor_line = 0
		_tutor_wait = 0.0
		Game.lesson_price = Game.roll_worth(_roll_kind)
		_tutor_to(2)
		_aim_spot(Vector3(0, 1.05, 0.15))
		_say("%s. Bring it to the popping table. Middle of the floor. Press E. The light will get there before you do." % Game.roll_name(_roll_kind), 7.0)
	else:
		_grab_chatter("%s. Still full. I can hear it judging both of us." % Game.roll_name(_roll_kind), 3.2)


func _start_work() -> void:
	if hold != 1 or table_mode:
		return
	_combo = 0
	_chain_time = 0.0
	_sheet_score = 0
	_sheet_peak = 0
	var from_xf: Transform3D = cam.global_transform
	work_cam.global_transform = from_xf
	work_cam.fov = cam.fov
	work_cam.current = true
	player.velocity = Vector3.ZERO
	player.global_position = Vector3(0, 1.35, 1.55)
	player.yaw = 0.0
	player.pitch = -0.55
	player.rotation.y = 0.0
	cam.rotation.x = -0.55
	player.block_move = true
	player.block_look = true
	working = true
	table_mode = true
	_work_ready = false
	player.set_working(true)
	player.set_tool(tool)
	player.set_carry(0)
	player.set_table_hands(false)
	player.set_hands_visible(false)
	_set_table_lamp(true)
	if Game.tutorial < 6:
		_show_play_lights()
	var rows: int = Game.roll_rows(_roll_kind)
	var far: int = 0 if Game.tutorial < 6 else Game.far_rows(rows)
	sheet.begin(
		Game.roll_cols(_roll_kind),
		rows,
		far,
		Game.pop_cd(),
		Game.tier_of("knuckle"),
		maxi(Game.tier_of("twist"), 1),
		maxi(Game.tier_of("row"), 1),
		maxi(Game.tier_of("lane"), 1),
		maxi(Game.tier_of("brayer"), 1),
		tool,
		Game.roll_color(_roll_kind),
		Game.roll_paper(_roll_kind)
	)
	var overhead := Transform3D(Basis.IDENTITY.rotated(Vector3.RIGHT, deg_to_rad(-90.0)), Vector3(0, 2.75, 0.15))
	_begin_fly(overhead, false, Settings.table_fov)
	sfx.play_kind("paper")
	if Game.tutorial < 6:
		_tutor_to(3)
		_say("Click every bubble. Every one. Roll it up with one left and I will hear it. E when the sheet is flat.", 7.5)
	elif not hint_shown:
		hint_shown = true
		_say("Click them. Roll it up with E. The crinkled ones are hiding, and so am I.", 5.0)


func _roll_up() -> void:
	if not working:
		return
	if Game.tutorial < 6 and sheet.bubbles_left() > 0:
		_say("You missed a bubble. I can hear it sitting there, smug. Pop it. Then you may roll the sheet up.", 4.6)
		return
	var counts: Vector2i = sheet.end_counts()
	carried_popped = counts.x
	carried_missed = counts.y
	hold = 2
	working = false
	_work_ready = false
	player.set_working(false)
	player.set_table_hands(false)
	player.set_hands_visible(false)
	player.set_carry(2, Game.roll_color(_roll_kind))
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_set_table_lamp(false)
	if Game.tutorial < 6:
		_sheet_lit = false
		_lower_house_lights()
		_paint_dark()
	_begin_fly(cam.global_transform, true, cam.fov)


func _begin_fly(target: Transform3D, back: bool, fov_target: float) -> void:
	_fly_from = work_cam.global_transform
	_fly_to = target
	_fov_from = work_cam.fov
	_fov_to = fov_target
	_fly = 0.0
	_fly_back = back


func _advance_fly(delta: float) -> void:
	if _fly >= 1.0 or menu != "":
		return
	var span: float = maxf(Settings.zoom_time(), 0.12)
	_fly = minf(1.0, _fly + delta / span)
	var blend: float = _fly * _fly * (3.0 - 2.0 * _fly)
	work_cam.global_transform = _fly_from.interpolate_with(_fly_to, blend)
	work_cam.fov = lerpf(_fov_from, _fov_to, blend)
	if _fly < 1.0:
		return
	if _fly_back:
		_finish_table()
	else:
		_open_table_cursor()


func _open_table_cursor() -> void:
	_work_ready = true
	if menu != "":
		return
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	Input.warp_mouse(get_viewport().get_visible_rect().size * 0.5)
	player.set_table_hands(true)
	player.set_hands_visible(true)


func _finish_table() -> void:
	table_mode = false
	_work_ready = false
	work_cam.current = false
	cam.current = true
	player.block_move = false
	player.block_look = false
	player.set_table_hands(false)
	player.set_hands_visible(true)
	crosshair.show()
	sfx.play_kind("paper")
	if menu == "":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_sheet_lit = false
	_spot_quiet = false
	if _lesson_dark:
		_paint_dark()
	if Game.tutorial < 6:
		_tutor_to(4)
		_aim_spot(Vector3(20, 1.4, 18))
		_say("Walk it to the furnace. Right side. Press E.", 5.5)


func _burn() -> void:
	if hold != 2:
		return
	var on_bonus: bool = _bonus_left > 0.0 and _bonus_rule != ""
	var chain_now := _combo
	_sheet_score = 0
	_sheet_peak = 0
	_combo = 0
	_chain_time = 0.0
	var teaching := Game.tutorial < 6
	var missed_now: int = carried_missed
	var pardoned: bool = false
	if not teaching and missed_now > 0 and Game.pardon > 0:
		missed_now -= 1
		Game.pardon = 0
		pardoned = true
	var result: Dictionary = Game.note_burn(errand, missed_now, carried_popped, _roll_kind, chain_now, teaching)
	if pardoned:
		var pardon_lines: Array = result["lines"]
		pardon_lines.append({"text": "1 plump ignored", "good": true})
	if not teaching and Game.quiet_skim > 0:
		Game.quiet_skim = 0
		Game.money += 70
		Game.note_rep(-4)
		var quiet_lines: Array = result["lines"]
		quiet_lines.append({"text": "+$70  quiet", "good": true})
		quiet_lines.append({"text": "-4 rep  quiet", "good": false})
		Game.save_shift()
	if not teaching and Game.break_hold > 0:
		Game.break_hold = 0
		var break_lines: Array = result["lines"]
		break_lines.append({"text": "clock held", "good": true})
		Game.save_shift()
	var bonus_offer: bool = false
	var finished_bonus: bool = false
	var counted: bool = false
	var paid: int = 0
	if on_bonus:
		counted = _bonus_qualifies(chain_now, int(result["missed"]))
		if counted:
			_bonus_done += 1
			finished_bonus = _bonus_done >= _bonus_need
		if finished_bonus:
			paid = _bonus_pay
			var lines: Array = result["lines"]
			lines.append({"text": "+$%d  bonus" % paid, "good": true})
			lines.append({"text": "+3 rep  bonus", "good": true})
			Game.money += paid
			bonus_offer = Game.note_rep(3)
			Game.save_shift()
			_clear_bonus()
			_offer_in = randf_range(90.0, 140.0)
	errand_on = false
	errand = 0.0
	hold = 0
	player.set_carry(0)
	_fire_kick = 1.0
	sfx.play_kind("whoosh")
	_kick(0.85)
	if int(result["miss_dock"]) > 0 or int(result["slow_dock"]) > 0:
		sfx.play_kind("dock")
	_show_lines(result["lines"])
	_burn_talk(result, on_bonus, finished_bonus, paid, bonus_offer, counted)


func _open_shop() -> void:
	if working:
		return
	_fill_shop()
	_set_menu("shop")


func _select_tool(which: int) -> void:
	if which < 0 or which >= TOOL_IDS.size():
		return
	var id: String = TOOL_IDS[which]
	if id != "" and not Game.tool_ready(id):
		return
	tool = which
	player.set_tool(which)
	if working:
		sheet.tool = which
	_refresh_hud()


func _set_menu(next: String) -> void:
	menu = next
	var open: bool = next != ""
	pause_root.visible = next == "pause"
	shop_root.visible = next == "shop"
	if closet_root != null:
		closet_root.visible = next == "closet"
	if desk_root != null:
		desk_root.visible = next == "desk"
	settings_root.visible = next == "settings"
	if promo_root != null:
		promo_root.visible = next == "promo"
	if ceremony_root != null:
		ceremony_root.visible = next == "ceremony"
	if next != "ending" and next != "intercom":
		ending_root.visible = false
	player.block_look = open or table_mode
	player.block_move = open or table_mode
	if Game.profile == "speedrun" and (next == "pause" or next == "settings"):
		Game.save_shift()
	if open:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif table_mode and _work_ready:
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _show_ending() -> void:
	if Game.profile == "speedrun" and ending_title != null:
		ending_title.text = Game.format_time(Game.run_time)
	elif ending_title != null:
		ending_title.text = "You're the boss."
	var story := "Dolores Vetch fired him over the speaker. The tag says Boss. It has your name on it. A new hire is at the pipe. The mean voice is yours now."
	if Game.profile == "speedrun":
		if Game.beat_pb:
			story = "New best. Try not to grin.\n\n" + story
		elif Game.speedrun_pb >= 0.0:
			story = "Best  %s. You can do worse, and you just might have.\n\n%s" % [Game.format_time(Game.speedrun_pb), story]
	ending_body.text = story
	ending_button.text = "Get on the intercom"
	menu = "ending"
	ending_root.show()
	player.block_look = true
	player.block_move = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_ending_button() -> void:
	if menu == "ending":
		ending_body.text = "Order a sheet at the pipe. Burner's across the floor. Pop them flat before you walk them over. I'll be in the office. Try not to be nice. Nice does not pop bubbles."
		sfx.play_kind("wah")
		ending_button.text = "Back to the door"
		menu = "intercom"
		return
	_set_menu("")
	get_tree().change_scene_to_file("res://scenes/home.tscn")


func _exit_home() -> void:
	Game.save_shift()
	_set_menu("")
	get_tree().change_scene_to_file("res://scenes/home.tscn")


func _open_settings(back_to: String) -> void:
	settings_back = back_to
	_set_menu("settings")


func _close_settings() -> void:
	_set_menu(settings_back)


func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _refresh_hud() -> void:
	var rank_name: String = Game.RANK[mini(Game.rank, 5)]
	money_label.text = "$%d    %s" % [Game.money, rank_name]
	if errand_on and Settings.show_timer:
		if Game.break_hold > 0:
			timer_label.text = "%.0fs    break" % errand
			timer_label.add_theme_color_override("font_color", UI.ACCENT)
		else:
			timer_label.text = "%.0fs" % errand
			var late: bool = errand > Game.PAR[mini(Game.rank, 4)]
			var timer_color: Color = UI.MUTED
			if late and Settings.late_flash:
				timer_color = UI.BAD
			timer_label.add_theme_color_override("font_color", timer_color)
		timer_label.show()
	else:
		timer_label.hide()
	if cart_label != null:
		if Game.cart_slots() > 0 and Game.tutorial >= 6:
			cart_label.text = "Cart  %d/%d" % [_cart.size(), Game.cart_slots()]
			cart_label.add_theme_color_override("font_color", UI.MUTED)
			cart_label.show()
		else:
			cart_label.hide()
	if not Settings.show_bonus:
		bonus_label.hide()
	elif _bonus_left > 0.0:
		bonus_label.text = "Bonus  %.0fs    %d/%d %s" % [ceil(_bonus_left), _bonus_done, _bonus_need, _bonus_short()]
		bonus_label.add_theme_color_override("font_color", UI.ACCENT)
		bonus_label.show()
	elif Game.promotion_ready() and not _promo_quiet:
		bonus_label.text = "Promotion available"
		bonus_label.add_theme_color_override("font_color", UI.GOOD)
		bonus_label.show()
	elif _offer_left > 0.0:
		bonus_label.text = "New email"
		bonus_label.add_theme_color_override("font_color", UI.GOOD)
		bonus_label.show()
	else:
		bonus_label.hide()
	var keys: PackedStringArray = _tool_keys()
	if pause_money != null:
		pause_money.text = "$%d    %s" % [Game.money, rank_name]
		pause_detail.text = Game.dossier()
		pause_tools.text = "  ·  ".join(keys)
	_refresh_hotbar()


func _refresh_hotbar() -> void:
	if hotbar == null:
		return
	hotbar.visible = Settings.show_tool and menu == ""
	if not hotbar.visible:
		return
	var slot_w := 86.0 * Settings.hud_scale
	var slot_h := 64.0 * Settings.hud_scale
	var gap := 8.0
	var slots := float(TOOL_NAMES.size())
	var total := slot_w * slots + gap * (slots - 1.0)
	hotbar.offset_left = -total * 0.5
	hotbar.offset_right = total * 0.5
	hotbar.offset_top = -18.0 - slot_h
	hotbar.offset_bottom = -18.0
	for i in TOOL_NAMES.size():
		var owned := i == 0 or Game.tool_ready(TOOL_IDS[i])
		var selected := tool == i
		var panel := _slot_panels[i]
		panel.offset_left = float(i) * (slot_w + gap)
		panel.offset_top = -slot_h
		panel.offset_right = panel.offset_left + slot_w
		panel.offset_bottom = 0.0
		panel.add_theme_stylebox_override("panel", _slot_style(selected, owned))
		var key := _slot_keys[i]
		key.text = Settings.key_label(Settings.bind_key("tool%d" % (i + 1)))
		key.add_theme_font_size_override("font_size", int(round(13.0 * Settings.hud_scale)))
		key.add_theme_color_override("font_color", UI.ACCENT if selected else UI.MUTED)
		var name := _slot_names[i]
		name.text = TOOL_NAMES[i]
		name.add_theme_font_size_override("font_size", int(round(15.0 * Settings.hud_scale)))
		if selected:
			name.add_theme_color_override("font_color", UI.INK)
		elif owned:
			name.add_theme_color_override("font_color", UI.MUTED)
		else:
			name.add_theme_color_override("font_color", UI.DIM)
		panel.modulate.a = 1.0 if owned else 0.45


func _slot_style(selected: bool, owned: bool) -> StyleBoxFlat:
	var bg := Color("1b2622")
	if selected:
		bg = Color("243832")
	elif not owned:
		bg = Color("121816")
	var box := UI.style(bg, 8, true, 4.0)
	if selected:
		box.border_color = UI.ACCENT
		box.set_border_width_all(2)
	return box


func _tool_keys() -> PackedStringArray:
	var keys: PackedStringArray = []
	for i in TOOL_IDS.size():
		if i == 0 or Game.tool_ready(TOOL_IDS[i]):
			keys.append("%s %s" % [_tool_name(i), TOOL_NAMES[i]])
	return keys


func _tool_name(index: int) -> String:
	var action := "tool%d" % (index + 1)
	return Settings.key_label(Settings.bind_key(action))


func _use_name() -> String:
	return Settings.key_label(Settings.bind_key("use"))


func _throw_name() -> String:
	return Settings.key_label(Settings.bind_key("throw"))


func _tick_chain(_delta: float) -> void:
	if chain_label == null:
		return
	if table_mode and _combo >= 1:
		chain_label.text = "x%.1f" % (1.0 + float(_combo) * Game.pop_step())
		chain_label.show()
	elif not table_mode:
		chain_label.hide()


func _tick_tally(_delta: float) -> void:
	if streak_label == null:
		return
	if Game.streak >= 2:
		streak_label.text = "x%.1f  perfect" % (1.0 + 0.1 * float(Game.streak - 1))
		streak_label.show()
	else:
		streak_label.hide()


func _tick_run(delta: float) -> void:
	if run_label == null or pb_label == null:
		return
	var racing := Game.profile == "speedrun"
	run_label.visible = racing
	pb_label.visible = racing
	if not racing:
		return
	var frozen := Game.completed or menu == "pause" or menu == "settings" or menu == "ending" or menu == "intercom" or menu == "ceremony" or menu == "firing"
	if not frozen:
		Game.run_time += delta
		_run_save += delta
		if _run_save >= 10.0:
			_run_save = 0.0
			Game.save_shift()
	run_label.text = Game.format_time(Game.run_time)
	if Game.speedrun_pb < 0.0:
		pb_label.text = "BEST  --"
		run_label.add_theme_color_override("font_color", UI.INK)
	else:
		pb_label.text = "BEST  %s" % Game.format_time(Game.speedrun_pb)
		var ahead := Game.run_time <= Game.speedrun_pb
		run_label.add_theme_color_override("font_color", UI.GOOD if ahead else UI.BAD)


func _on_sheet_pop(kind: String, count: int) -> void:
	_gain_pops(count)
	var pitch := 1.0 + minf(float(_combo), 36.0) * 0.028
	sfx.play_kind(kind, pitch)
	var kick := 0.22
	if kind == "twist":
		kick = 0.4
	elif kind == "sweep":
		kick = 0.32
	_kick(kick + minf(float(_combo) * 0.004, 0.2))


func _on_sheet_miss() -> void:
	if _combo <= 0:
		return
	if Game.chain_save > 0:
		Game.chain_save = 0
		Game.save_shift()
		sfx.play_kind("click", 1.15)
		if chain_label != null:
			chain_label.text = "x%.1f  insured" % (1.0 + float(_combo) * Game.pop_step())
			chain_label.show()
		return
	_combo = 0
	if chain_label != null:
		chain_label.hide()
	sfx.play_kind("click", 0.72)


func _gain_pops(count: int) -> void:
	if count <= 0:
		return
	_combo += 1
	if chain_label == null or _combo < 1:
		return
	chain_label.text = "x%.1f" % (1.0 + float(_combo) * Game.pop_step())
	chain_label.show()
	chain_label.scale = Vector2(1.18, 1.18)
	var tw := create_tween()
	tw.tween_property(chain_label, "scale", Vector2.ONE, 0.12)


func _spawn_gain(amount: int) -> void:
	if hud_root == null or amount <= 0:
		return
	while _gain_labels.size() > 14:
		var old: Label = _gain_labels[0]
		_gain_labels.remove_at(0)
		if is_instance_valid(old):
			old.queue_free()
	var size := 20
	if amount >= 1000:
		size = 28
	if amount >= 10000:
		size = 36
	var lbl: Label = UI.label("+%s" % Game.format_number(amount), size)
	UI.outline(lbl, 4)
	lbl.add_theme_color_override("font_color", UI.ACCENT if amount < 10000 else UI.GOOD)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var start := get_viewport().get_mouse_position() + Vector2(16, -28)
	lbl.position = start
	hud_root.add_child(lbl)
	_gain_labels.append(lbl)
	var tw := create_tween()
	tw.tween_property(lbl, "position", start + Vector2(0, -54), 0.48)
	tw.parallel().tween_property(lbl, "modulate:a", 0.0, 0.48)
	tw.tween_callback(func() -> void:
		_gain_labels.erase(lbl)
		if is_instance_valid(lbl):
			lbl.queue_free()
	)


func _mark_flash(mark: int) -> void:
	if mark <= 0 or banner == null:
		return
	banner.text = Game.format_number(mark)
	banner.add_theme_color_override("font_color", UI.ACCENT)
	banner.modulate.a = 1.0
	banner.scale = Vector2(1.2, 1.2)
	banner.pivot_offset = Vector2(280, 40)
	banner.show()
	sfx.play_kind("promote", 0.9 + minf(float(mark) / 1000000.0, 0.8))
	var tw := create_tween()
	tw.tween_property(banner, "scale", Vector2.ONE, 0.16)
	tw.tween_interval(0.85)
	tw.tween_property(banner, "modulate:a", 0.0, 0.28)
	tw.tween_callback(func() -> void: banner.hide())
	if mark == 10000:
		_say("Ten thousand. I felt that in the floor.", 3.2)
	elif mark == 100000:
		_say("A hundred thousand. Don't smile. It encourages you.", 3.6)
	elif mark == 1000000:
		_say("A million. I am going to pretend I planned that.", 4.0)
	Game.save_shift()


func _kick(amount: float) -> void:
	_trauma = minf(1.0, _trauma + amount * Settings.shake_scale())


func _tick_shake(delta: float) -> void:
	_trauma = move_toward(_trauma, 0.0, delta * 2.4)
	var mag := _trauma * _trauma
	var hx := 0.0
	var vy := 0.0
	if mag > 0.001:
		hx = randf_range(-1.0, 1.0) * mag * 0.14
		vy = randf_range(-1.0, 1.0) * mag * 0.1
	if cam != null:
		cam.h_offset = 0.0 if table_mode else hx
		cam.v_offset = 0.0 if table_mode else vy
	if work_cam != null:
		work_cam.h_offset = hx if table_mode else 0.0
		work_cam.v_offset = vy if table_mode else 0.0


func _apply_presentation() -> void:
	if _env != null:
		_env.fog_enabled = Settings.fog > 0.02
		_env.fog_density = 0.008 * Settings.fog
		_env.adjustment_enabled = true
		_env.adjustment_brightness = Settings.brightness
		_env.adjustment_contrast = 1.0
		_env.adjustment_saturation = 1.0
		_env.glow_enabled = Settings.bloom > 0.01
		_env.glow_intensity = Settings.bloom
		_env.glow_strength = Settings.bloom
	if _sun != null:
		_sun.shadow_enabled = Settings.shadows > 0
		_sun.directional_shadow_max_distance = 90.0 if Settings.shadows >= 2 else 70.0
		_sun.shadow_blur = 1.1 if Settings.shadows >= 2 else 0.35
		if Settings.shadows <= 0:
			pass
		elif Settings.shadows == 1:
			RenderingServer.directional_shadow_atlas_set_size(2048, true)
		else:
			RenderingServer.directional_shadow_atlas_set_size(4096, true)
	if money_label != null:
		money_label.add_theme_font_size_override("font_size", int(round(22.0 * Settings.hud_scale)))
	if score_label != null:
		score_label.add_theme_font_size_override("font_size", int(round(32.0 * Settings.hud_scale)))
	if chain_label != null:
		chain_label.add_theme_font_size_override("font_size", int(round(52.0 * Settings.hud_scale)))
	if run_label != null:
		run_label.add_theme_font_size_override("font_size", int(round(22.0 * Settings.hud_scale)))
	if timer_label != null:
		timer_label.add_theme_font_size_override("font_size", int(round(18.0 * Settings.hud_scale)))
	if tool_label != null:
		tool_label.add_theme_font_size_override("font_size", int(round(15.0 * Settings.hud_scale)))
	if prompt_label != null:
		prompt_label.add_theme_font_size_override("font_size", int(round(16.0 * Settings.hud_scale)))
	if bonus_label != null:
		bonus_label.add_theme_font_size_override("font_size", int(round(16.0 * Settings.hud_scale)))
	if crosshair != null:
		var hair := int(round(18.0 * Settings.hud_scale * Settings.crosshair_scale))
		crosshair.add_theme_font_size_override("font_size", hair)
	_style_boss()
	if not Settings.show_subtitles and boss_label != null:
		boss_label.text = ""
		if boss_card != null:
			boss_card.hide()
		_boss_life = 0.0
	if _sheet_lit:
		_show_play_lights()
	elif _lesson_dark:
		_paint_dark()
	if cam != null:
		cam.fov = Settings.fov
	if table_mode and work_cam != null and _fly >= 1.0 and not _fly_back:
		work_cam.fov = Settings.table_fov


func _style_boss() -> void:
	if boss_label == null or boss_card == null:
		return
	var scale: float = Settings.subtitle_scale
	boss_label.add_theme_font_size_override("font_size", int(round(17.0 * scale)))
	if boss_name != null:
		boss_name.add_theme_font_size_override("font_size", int(round(13.0 * scale)))
	var view: Vector2 = get_viewport().get_visible_rect().size
	var bubble_w: float = clampf(250.0 * scale, 220.0, view.x * 0.42)
	boss_label.custom_minimum_size = Vector2(bubble_w, 0)
	var bust: float = clampf(scale, 0.85, 1.4)
	if _boss_bust != null:
		_boss_bust.custom_minimum_size = Vector2(74.0 * bust, 96.0 * bust)
		_boss_bust.queue_redraw()
	if _boss_bubble != null:
		var at_box: bool = _tutor_need_button or _tutor_need_tag
		if cam != null and _aimed_id() == "Speaker":
			at_box = true
		var edge := Color(1, 1, 1, 0.1)
		if at_box:
			edge = Color("e25b2a")
		var box := UI.style(Color(0.07, 0.098, 0.086, 0.94), 12, false, 14.0)
		box.border_color = edge
		box.set_border_width_all(2 if at_box else 1)
		_boss_bubble.add_theme_stylebox_override("panel", box)
	var need: Vector2 = boss_card.get_combined_minimum_size()
	var w: float = minf(maxf(need.x, 280.0), view.x * 0.5)
	var h: float = minf(maxf(need.y, 112.0), view.y * 0.4)
	boss_card.offset_left = 18.0
	boss_card.offset_top = 70.0
	boss_card.offset_right = 18.0 + w
	boss_card.offset_bottom = 70.0 + h


func _set_prompt(text: String) -> void:
	if not Settings.show_prompts:
		prompt_root.visible = false
		return
	prompt_label.text = text
	prompt_root.visible = text != ""


func _tick_boss(delta: float) -> void:
	if _boss_life <= 0.0:
		return
	_boss_life = maxf(0.0, _boss_life - delta)
	if boss_card == null:
		return
	if _boss_life <= 0.0:
		boss_label.text = ""
		boss_card.hide()
	elif _boss_life < 0.55:
		boss_card.modulate.a = _boss_life / 0.55
	else:
		boss_card.modulate.a = 1.0


func _cart_key() -> String:
	return Settings.key_label(Settings.bind_key("cart"))


func _cart_hint() -> String:
	if Game.tutorial < 6 or not _cart_near():
		return ""
	if hold != 0:
		return "     %s    Load one" % _cart_key()
	if not _cart.is_empty():
		return "     %s    Take one" % _cart_key()
	return ""


func _cart_near() -> bool:
	if _cart_root == null or not _cart_root.visible or player == null:
		return false
	if _pushing:
		return true
	return player.global_position.distance_to(_cart_root.global_position) < 2.4


func _cart_press() -> void:
	if working or table_mode or menu != "" or Game.tutorial < 6:
		return
	if Game.cart_slots() <= 0:
		_nag("You do not own a cart. Your arms are the cart. They are a bad cart.")
		return
	if not _cart_near():
		_nag("Walk to the cart. It does not come to you.")
		return
	if hold != 0:
		if _cart.size() >= Game.cart_slots():
			_nag("The cart is full. I am not buying you a trailer.")
			return
		_cart.append({
			"stage": hold,
			"kind": _roll_kind,
			"popped": carried_popped,
			"missed": carried_missed,
			"errand": errand,
		})
		hold = 0
		errand_on = false
		errand = 0.0
		carried_popped = 0
		carried_missed = 0
		player.set_carry(0)
		sfx.play_kind("clunk")
		_sync_cart()
		_say("In the cart. Full or flat, it does not care. The clock does not pause.", 3.6)
		return
	if _cart.is_empty():
		return
	var item: Dictionary = _cart.pop_front()
	hold = int(item["stage"])
	_roll_kind = int(item["kind"])
	carried_popped = int(item["popped"])
	carried_missed = int(item["missed"])
	errand = float(item["errand"])
	errand_on = true
	player.set_carry(hold, Game.roll_color(_roll_kind))
	sfx.play_kind("clunk")
	_sync_cart()
	if hold == 2:
		_grab_chatter("Out of the cart. Flat. The burner is still that way.", 3.2)
	else:
		_grab_chatter("Out of the cart. Still full. Do not make me wait twice.", 3.2)


func _physics_process(_delta: float) -> void:
	if not _pushing or _cart_root == null or player == null:
		return
	var forward: Vector3 = -player.global_transform.basis.z
	forward.y = 0.0
	if forward.length() < 0.01:
		return
	forward = forward.normalized()
	var spot: Vector3 = player.global_position + forward * 1.25
	spot.y = 0.38
	_cart_root.global_position = spot
	_cart_root.rotation.y = player.rotation.y


func _build_cart() -> void:
	_cart_root = Node3D.new()
	_cart_root.name = "CartRig"
	_cart_root.position = Vector3(-6.0, 0.38, 14.0)
	add_child(_cart_root)
	_cart_zone = Area3D.new()
	_cart_zone.name = "Cart"
	_cart_zone.collision_layer = 0
	_cart_zone.collision_mask = 0
	_cart_zone.add_to_group("station")
	var zone_shape := CollisionShape3D.new()
	var zone_box := BoxShape3D.new()
	zone_box.size = Vector3(1.0, 1.0, 1.2)
	zone_shape.shape = zone_box
	zone_shape.position = Vector3(0, 0.4, 0)
	_cart_zone.add_child(zone_shape)
	_cart_root.add_child(_cart_zone)
	var bed := MeshInstance3D.new()
	var bed_mesh := BoxMesh.new()
	bed_mesh.size = Vector3(0.62, 0.08, 0.96)
	bed.mesh = bed_mesh
	bed.position = Vector3(0, 0.16, 0)
	bed.material_override = _finish(Color("6b4a32"), 0.72, Color(0, 0, 0), 0.0)
	_cart_root.add_child(bed)
	var rail := MeshInstance3D.new()
	var rail_mesh := BoxMesh.new()
	rail_mesh.size = Vector3(0.04, 0.16, 0.96)
	rail.mesh = rail_mesh
	rail.position = Vector3(-0.28, 0.26, 0)
	rail.material_override = _finish(Color("8a6230"), 0.6, Color(0, 0, 0), 0.0)
	_cart_root.add_child(rail)
	var handle := MeshInstance3D.new()
	var handle_mesh := BoxMesh.new()
	handle_mesh.size = Vector3(0.04, 0.42, 0.04)
	handle.mesh = handle_mesh
	handle.position = Vector3(-0.16, 0.42, 0.34)
	handle.material_override = _finish(Color("c4b8a4"), 0.55, Color(0, 0, 0), 0.0)
	_cart_root.add_child(handle)
	_sync_cart()


func _sync_cart() -> void:
	if _cart_root == null:
		return
	var owned: bool = Game.cart_slots() > 0
	_cart_root.visible = owned
	if _cart_zone != null:
		_cart_zone.collision_layer = 2 if owned else 0
	for child in _cart_root.get_children():
		if str(child.name).begins_with("Load"):
			child.queue_free()
	var slot := 0
	for item in _cart:
		var roll := MeshInstance3D.new()
		roll.name = "Load%d" % slot
		var mesh := CylinderMesh.new()
		mesh.top_radius = 0.07
		mesh.bottom_radius = 0.07
		mesh.height = 0.22
		mesh.radial_segments = 12
		roll.mesh = mesh
		roll.rotation_degrees = Vector3(0, 0, 90)
		roll.position = Vector3(0.02, 0.28, -0.24 + float(slot) * 0.16)
		var tint: Color = Game.roll_color(int(item["kind"]))
		if int(item["stage"]) == 2:
			tint = tint.lerp(Color("c4b8a4"), 0.72)
		roll.material_override = _finish(tint, 0.42, Color(0, 0, 0), 0.0)
		_cart_root.add_child(roll)
		slot += 1


func _prompt_for(id: String) -> String:
	var use := _use_name()
	var toss := _throw_name()
	if working:
		return "%s    Roll it up" % use
	if _pushing:
		return "%s    Get off%s" % [use, _cart_hint()]
	if id == "Cart" and Game.cart_slots() > 0 and Game.tutorial >= 6:
		return "%s    Push%s" % [use, _cart_hint()]
	if id == "Rack" and hold == 0:
		var aimed: int = _aimed_roll()
		if aimed >= 0:
			return "%s    %s roll" % [use, Game.roll_name(_rack_kind[aimed])]
		return "%s    Take a roll" % use
	if id == "Bench" and hold == 1:
		if Game.tutorial < 6:
			return "%s    Lay it on the popping table" % use
		return "%s    Lay it on the bench     %s    Throw%s" % [use, toss, _cart_hint()]
	if id == "Burner" and hold == 2:
		if Game.tutorial < 6:
			return "%s    Furnace" % use
		return "%s    Burn it     %s    Throw%s" % [use, toss, _cart_hint()]
	if id == "Burner" and hold == 1:
		if Game.tutorial < 6:
			return "Unroll it at the popping table first"
		return "Unroll it at the bench first     %s    Throw%s" % [toss, _cart_hint()]
	if id == "Shop":
		if Game.tutorial == 5:
			return "%s    Buy sprint" % use
		return "%s    HR" % use
	if id == "Closet":
		if Game.tutorial < 6:
			return "Janitor's closet"
		return "%s    Knock" % use
	if id == "Desk":
		if Game.tutorial < 6:
			return "Computer"
		if _offer_left > 0.0:
			return "%s    New email" % use
		return "%s    Computer" % use
	if id == "Mailer":
		if Game.tutorial == 0:
			return "Wall pipe"
		var kind: int = _mailer_kind()
		if kind < 0:
			return "Pick a color"
		return "%s    %s" % [use, Game.roll_name(kind)]
	if _tutor_need_tag and _tag_in_reach(id):
		return "%s    Pick up your tag" % use
	if id == "Speaker":
		if _tutor_need_button:
			if _tutor_button_pass >= 1:
				return "%s    Press it again" % use
			return "%s    Press the red button" % use
		if Game.tutorial == 0:
			return "Over here"
		if _bonus_left > 0.0:
			return "Clock's running"
		if Game.promotion_ready():
			return "%s    Promotion" % use
		if _offer_left > 0.0:
			return "Check the computer"
		return "%s    Red button" % use
	if hold != 0 and Game.tutorial >= 6:
		return "%s    Drop     %s    Throw%s" % [use, toss, _cart_hint()]
	var loose: RigidBody3D = _aimed_loose()
	if loose != null:
		if int(loose.get_meta("stage")) == 2:
			return "%s    Pick up the worked roll" % use
		return "%s    Pick up the %s roll" % [use, Game.roll_name(int(loose.get_meta("kind")))]
	if hold == 0 and _cart_near() and not _cart.is_empty():
		return "%s    Take one    %d/%d" % [_cart_key(), _cart.size(), Game.cart_slots()]
	if id == "Bench":
		return "Order a roll at the pipe"
	return ""


func _aimed_id() -> String:
	var area: Area3D = _aimed_zone()
	if area == null:
		return ""
	return area.name


func _aimed_zone() -> Area3D:
	var from: Vector3 = cam.global_position
	var forward: Vector3 = -cam.global_transform.basis.z
	var space: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, from + forward * 5.0)
	query.collision_mask = 3
	query.collide_with_areas = true
	query.collide_with_bodies = true
	var hit: Dictionary = space.intersect_ray(query)
	if not hit.is_empty() and hit.collider is Area3D and hit.collider.is_in_group("station"):
		return hit.collider
	var inside := _zone_holding(from)
	if inside != null:
		return inside
	var best: Area3D = null
	var best_dist: float = 3.2
	for node in get_tree().get_nodes_in_group("station"):
		var area: Area3D = node as Area3D
		var to_zone: Vector3 = area.global_position - from
		if to_zone.length() < 0.01:
			continue
		if forward.dot(to_zone.normalized()) < 0.35:
			continue
		var dist: float = from.distance_to(area.global_position)
		if dist < best_dist:
			best_dist = dist
			best = area
	return best


func _zone_holding(point: Vector3) -> Area3D:
	for node in get_tree().get_nodes_in_group("station"):
		var area := node as Area3D
		if area == null:
			continue
		for child in area.get_children():
			var shape_node := child as CollisionShape3D
			if shape_node == null or shape_node.shape == null:
				continue
			var box := shape_node.shape as BoxShape3D
			if box == null:
				continue
			var local: Vector3 = area.global_transform.affine_inverse() * point
			var half: Vector3 = box.size * 0.5
			if absf(local.x) <= half.x and absf(local.y) <= half.y and absf(local.z) <= half.z:
				return area
	return null


func _tag_in_reach(id: String) -> bool:
	if id == "Speaker":
		return true
	if cam == null or _badge == null or not _badge.visible:
		return false
	var from: Vector3 = cam.global_position
	var forward: Vector3 = -cam.global_transform.basis.z
	var to_tag: Vector3 = _badge.global_position - from
	if to_tag.length() > 2.6 or to_tag.length() < 0.05:
		return false
	return forward.dot(to_tag.normalized()) > 0.45


func _table_aim() -> Dictionary:
	var mouse: Vector2 = get_viewport().get_mouse_position()
	var from: Vector3 = work_cam.project_ray_origin(mouse)
	var dir: Vector3 = work_cam.project_ray_normal(mouse)
	var normal: Vector3 = sheet.global_transform.basis.z
	var denom: float = normal.dot(dir)
	if absf(denom) < 0.0001:
		return {"hit": false}
	var t: float = normal.dot(sheet.global_position - from) / denom
	if t < 0.0 or t > 12.0:
		return {"hit": false}
	var point: Vector3 = from + dir * t
	var local: Vector2 = sheet.to_sheet_local(point)
	return {"hit": sheet.contains_local(local), "local": local, "point": point}


func _show_lines(lines: Array) -> void:
	for child in result_box.get_children():
		child.queue_free()
	if not Settings.show_receipts:
		return
	for line in lines:
		var text: String = str(line["text"])
		var size: int = int(round(22.0 * Settings.hud_scale))
		if text.begins_with("x") or text.contains("tally") or text.contains(" rep"):
			size = int(round(30.0 * Settings.hud_scale))
		elif text.begins_with("+") or text.begins_with("-") or text.begins_with("Took"):
			size = int(round(34.0 * Settings.hud_scale))
		var lbl: Label = UI.label(text, size)
		UI.outline(lbl, 6)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var color: Color = UI.INK
		if text.begins_with("x") or text.contains("tally") or text.contains(" rep"):
			color = UI.ACCENT
		elif text.begins_with("+"):
			color = UI.GOOD
		elif text.begins_with("-") or text.contains("missed") or text.contains("too much"):
			color = UI.BAD
		lbl.add_theme_color_override("font_color", color)
		result_box.add_child(lbl)
	result_box.modulate.a = 1.0
	result_box.offset_top = 30.0
	var tw := create_tween()
	tw.tween_property(result_box, "offset_top", -70.0, 1.7)
	tw.parallel().tween_property(result_box, "modulate:a", 0.0, 0.45).set_delay(1.55)


func _grab_chatter(text: String, lock: float) -> void:
	if _boss_life > 0.35:
		return
	if _grab_quiet > 0:
		_grab_quiet -= 1
		return
	_say(text, lock)
	_grab_quiet = randi_range(3, 6)


func _say(text: String, lock: float) -> void:
	if text != "":
		sfx.play_kind("wah")
	if not Settings.show_subtitles or boss_card == null:
		boss_label.text = ""
		if boss_card != null:
			boss_card.hide()
		_boss_life = 0.0
		return
	boss_label.text = text
	if boss_name != null:
		boss_name.text = "BOSS"
		boss_name.add_theme_color_override("font_color", UI.ACCENT)
	boss_card.modulate.a = 1.0
	boss_card.show()
	_boss_life = lock * Settings.subtitle_time
	_style_boss()


func _greet() -> void:
	match Game.tutorial:
		0:
			if player != null:
				player.yaw = PI
				player.rotation.y = PI
			_aim_spot(Vector3(0, 1.75, 31.05))
			if Game.badge_rank >= Game.rank:
				_say_wasd()
			else:
				_tutor_button_pass = 0
				_tutor_need_button = false
				_tutor_need_tag = false
				_tutor_line = 1
				_tutor_wait = 3.4
				_say("Hey newbie! Over here!", 3.4)
		1:
			_aim_spot(Vector3(-28.2, 1.45, 8.0))
			_say("The pipe on the left wall. Press E on a color. It drops on the checker square. Pick it up.", 6.2)
		2:
			_aim_spot(Vector3(0, 1.05, 0.15))
			_say("The popping table is in the middle. Press E. Every bubble. I will be listening.", 6.0)
		3:
			_aim_spot(Vector3(0, 1.05, 0.15))
			_say("Every bubble. Roll it up with one left and I send you back. E when the sheet is flat.", 6.0)
		4:
			_aim_spot(Vector3(20, 1.4, 18))
			_say("The furnace is on your right. Walk the flat roll over and press E.", 5.5)
		5:
			_aim_spot(_hr_aim())
			if Game.tier_of("sprint") > 0:
				_start_house_lights()
			else:
				_say("Sprint. HR. The corner to my left. The window, not the door. It costs the same as that full roll. Buy it.", 6.4)
		_:
			var lines: PackedStringArray = BOSS_CHATTER
			if Game.profile == "speedrun":
				lines = BOSS_RUN
			_say(_boss_line(lines), 5.0)


func _say_wasd() -> void:
	_tutor_line = 2
	_tutor_wait = 8.2
	_say("WASD walks. The mouse is your neck. Esc if you need to stand in the dark and think. The rolls are full of leftover air. Don't breathe it. I don't pay medical.", 8.2)


func _hire_button() -> void:
	_tutor_need_button = false
	_poke_button()
	sfx.play_kind("click")
	if _tutor_button_pass < 1:
		var wait := 9.0
		if Settings.show_subtitles:
			wait *= Settings.subtitle_time
		_tutor_line = 4
		_tutor_wait = wait
		_say(HIRE_SPEECH, 8.8)
		return
	_badge_done = func() -> void:
		_tutor_need_tag = true
		_say("Pick it up. Press E. Try not to look grateful.", 4.2)
	_drop_badge()


func _tutor_to(step: int) -> bool:
	if Game.tutorial >= step:
		return false
	Game.tutorial = step
	Game.save_shift()
	return true


func _nag(text: String) -> void:
	if _boss_life > 0.25:
		return
	_say(text, 3.2)


func _boss_line(lines: PackedStringArray) -> String:
	if lines.is_empty():
		return ""
	var pick: int = randi() % lines.size()
	if lines.size() > 1 and lines[pick] == _boss_last:
		pick = (pick + 1) % lines.size()
	_boss_last = lines[pick]
	return lines[pick]


func _tick_chatter(delta: float) -> void:
	if Game.tutorial < 6 or menu != "" or table_mode or Game.completed:
		return
	if _bonus_left > 0.0 or _offer_left > 0.0 or _boss_life > 0.0:
		return
	_boss_idle -= delta
	if _boss_idle > 0.0:
		return
	_boss_idle = randf_range(46.0, 82.0)
	var lines: PackedStringArray = BOSS_CHATTER
	if Game.profile == "speedrun":
		lines = BOSS_RUN
	_say(_boss_line(lines), 4.6)


func _tick_tutor(delta: float) -> void:
	if Game.tutorial < 6 and not _lesson_dark and _light_i < 0:
		_begin_dark()
		_greet()
	_tick_spot(delta)
	_tick_house_lights(delta)
	if _tutor_line == 0 or menu != "":
		return
	_tutor_wait = maxf(0.0, _tutor_wait - delta)
	if _tutor_wait > 0.0:
		return
	var line := _tutor_line
	_tutor_line = 0
	if Game.tutorial != 0:
		return
	if line == 1:
		_tutor_need_button = true
		_aim_spot(Vector3(0, 1.75, 31.05))
		_tutor_button_pass = 0
		_say("Press the red button. That is me. I do not walk over.", 5.2)
	elif line == 4:
		_tutor_need_button = true
		_tutor_button_pass = 1
		_aim_spot(Vector3(0, 1.75, 31.05))
		_say("Press the red button again.", 3.6)
	elif line == 2:
		_tutor_to(1)
		_aim_spot(Vector3(-28.2, 1.45, 8.0))
		_say("The pipe on the left wall. Press E on a color. It drops on the checker square. Pick it up.", 6.2)


func _begin_dark() -> void:
	_lesson_dark = true
	_spot_snapped = false
	_beam_hold = true
	_spot_quiet = false
	_sheet_lit = false
	_lower_house_lights()
	_paint_dark()


func _paint_dark() -> void:
	if _sheet_lit:
		_show_play_lights()
		return
	if _env != null:
		_env.background_color = Color("121614")
		_env.ambient_light_color = Color("6a736e")
		_env.ambient_light_energy = 0.09
		_env.fog_enabled = true
		_env.fog_light_color = Color("1c2421")
		_env.fog_density = 0.004
	if _sun != null:
		_sun.light_energy = 0.0
		_sun.hide()
	if _spot_quiet:
		_show_beam(false)
	else:
		_show_beam(true)


func _paint_day() -> void:
	if _env != null:
		_env.background_color = Color("1a2220")
		_env.ambient_light_color = Color("9aa8a2")
		_env.ambient_light_energy = 0.38
		_env.fog_light_color = Color("8d9994")
	if _sun != null:
		_sun.light_energy = 0.7
		_sun.show()


func _aim_spot(aim: Vector3) -> void:
	_spot_aim = aim
	_spot_pos = Vector3(aim.x, 5.45, aim.z)


func _tick_spot(delta: float) -> void:
	if _spot == null:
		return
	if _spot_quiet:
		_show_beam(false)
		return
	if not _lesson_dark or not _beam_hold:
		_show_beam(false)
		return
	_show_beam(true)
	if not _spot_snapped:
		_spot.global_position = _spot_pos
		_spot_snapped = true
	else:
		var follow := 1.0 - exp(-4.2 * delta)
		_spot.global_position = _spot.global_position.lerp(_spot_pos, follow)
	if _spot.global_position.distance_to(_spot_aim) > 0.2:
		var up := Vector3(0, 0, 1)
		var flat := Vector2(_spot.global_position.x - _spot_aim.x, _spot.global_position.z - _spot_aim.z)
		if flat.length() > 0.35:
			up = Vector3.UP
		_spot.look_at(_spot_aim, up)
	var dir := -_spot.global_transform.basis.z
	var dist := _spot.global_position.distance_to(_spot_aim)
	if dir.y < -0.05:
		var along := (0.52 - _spot.global_position.y) / dir.y
		if along > 0.4:
			dist = along
	dist = maxf(dist, 0.6)
	if _beam != null:
		_beam.scale = Vector3(dist * 0.42, dist, dist * 0.42)
		_beam.position = Vector3(0, 0, -dist * 0.5)
	if _pool != null:
		var land := _spot.global_position + dir * dist
		_pool.global_position = Vector3(land.x, 0.53, land.z)
	if _spot_fill != null:
		_spot_fill.global_position = _spot_aim + Vector3(0, 0.8, 0)


func _show_beam(on: bool) -> void:
	if _spot != null:
		_spot.visible = on
		if on:
			_spot.light_energy = 16.0
			_spot.spot_attenuation = 0.15
	if _beam != null:
		_beam.visible = on
	if _pool != null:
		_pool.visible = on
	if _spot_fill != null:
		_spot_fill.visible = on
		if on:
			_spot_fill.light_energy = 8.0


func _show_play_lights() -> void:
	_sheet_lit = true
	_spot_quiet = true
	_paint_day()
	_raise_house_lights()
	_show_beam(false)
	if _env != null:
		_env.fog_enabled = Settings.fog > 0.02
		_env.fog_density = 0.008 * Settings.fog
		_env.fog_light_color = Color("8d9994")


func _raise_house_lights() -> void:
	for i in _beat_lights.size():
		var lamp := _beat_lights[i]
		lamp.show()
		lamp.light_energy = _beat_energy[i]
		var mat = _beat_mats[i]
		if mat is StandardMaterial3D:
			var glow_mat := mat as StandardMaterial3D
			glow_mat.emission_enabled = true
			glow_mat.emission_energy_multiplier = _beat_glow[i]


func _lower_house_lights() -> void:
	for i in _beat_lights.size():
		_beat_lights[i].light_energy = 0.0
		_beat_lights[i].hide()
		var mat = _beat_mats[i]
		if mat is StandardMaterial3D:
			(mat as StandardMaterial3D).emission_energy_multiplier = 0.0
	if _sun != null:
		_sun.light_energy = 0.0
		_sun.hide()


func _build_spot() -> void:
	_spot = SpotLight3D.new()
	_spot.name = "LessonSpot"
	_spot.light_color = Color("fff1cc")
	_spot.light_energy = 16.0
	_spot.spot_range = 22.0
	_spot.spot_angle = deg_to_rad(48.0)
	_spot.spot_attenuation = 0.15
	_spot.shadow_enabled = false
	_spot.hide()
	add_child(_spot)
	_beam = MeshInstance3D.new()
	var cone := CylinderMesh.new()
	cone.top_radius = 1.0
	cone.bottom_radius = 0.05
	cone.height = 1.0
	cone.radial_segments = 16
	_beam.mesh = cone
	_beam.rotation.x = -PI * 0.5
	_beam.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var beam_mat := StandardMaterial3D.new()
	beam_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	beam_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	beam_mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	beam_mat.albedo_color = Color(1.0, 0.92, 0.7, 0.28)
	beam_mat.emission_enabled = true
	beam_mat.emission = Color("ffe6b0")
	beam_mat.emission_energy_multiplier = 1.6
	beam_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	beam_mat.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_DISABLED
	_beam.material_override = beam_mat
	_beam.hide()
	_spot.add_child(_beam)
	_pool = MeshInstance3D.new()
	var disc := CylinderMesh.new()
	disc.top_radius = 1.7
	disc.bottom_radius = 1.7
	disc.height = 0.02
	disc.radial_segments = 24
	_pool.mesh = disc
	_pool.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var pool_mat := StandardMaterial3D.new()
	pool_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	pool_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	pool_mat.albedo_color = Color(1.0, 0.86, 0.55, 0.55)
	pool_mat.emission_enabled = true
	pool_mat.emission = Color("ffd27a")
	pool_mat.emission_energy_multiplier = 2.2
	pool_mat.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_DISABLED
	_pool.material_override = pool_mat
	_pool.hide()
	add_child(_pool)
	_spot_fill = OmniLight3D.new()
	_spot_fill.light_color = Color("fff1cc")
	_spot_fill.light_energy = 8.0
	_spot_fill.omni_range = 9.0
	_spot_fill.shadow_enabled = false
	_spot_fill.hide()
	add_child(_spot_fill)


func _set_table_lamp(on: bool) -> void:
	if _table_lamp == null:
		return
	_table_lamp.visible = on


func _build_house_lights() -> void:
	_table_lamp = OmniLight3D.new()
	_table_lamp.name = "TableLamp"
	_table_lamp.light_color = Color("fff6ea")
	_table_lamp.light_energy = 0.9
	_table_lamp.omni_range = 2.8
	_table_lamp.shadow_enabled = false
	_table_lamp.position = Vector3(0, 2.25, 0.15)
	_table_lamp.hide()
	add_child(_table_lamp)
	var xs: Array[float] = [-24.0, -16.0, -8.0, 0.0, 8.0, 16.0]
	for x in xs:
		var tube := _tube(Vector3(x, 5.02, 18.0))
		var light := _omni(Vector3(x, 4.55, 18.0), Color("e7f3ee"), 1.35, 12.0)
		_add_beat(light, tube, 1.35, 1.4)
	var bench_tube := _tube(Vector3(0, 5.02, 2.0))
	var bench := _omni(Vector3(0, 3.4, 1.0), Color("fff4e0"), 1.5, 8.0)
	_add_beat(bench, bench_tube, 1.5, 1.2)
	var burner := _omni(Vector3(20, 2.3, 17.2), Color("e25b2a"), 2.6, 9.0)
	_add_beat(burner, null, 2.6, 0.0)


func _tube(pos: Vector3) -> StandardMaterial3D:
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(2.4, 0.07, 0.32)
	mesh.mesh = box
	mesh.position = pos
	var mat := _finish(Color("d5e6df"), 0.35, Color("e9fff6"), 1.4)
	mesh.material_override = mat
	add_child(mesh)
	return mat


func _add_beat(light: OmniLight3D, mat, energy: float, glow: float) -> void:
	_beat_lights.append(light)
	_beat_mats.append(mat)
	_beat_energy.append(energy)
	_beat_glow.append(glow)


func _start_house_lights() -> void:
	if _light_i >= 0 or _beat_lights.is_empty():
		return
	if menu == "shop":
		_set_menu("")
	_light_i = 0
	_light_wait = 0.65


func _tick_house_lights(delta: float) -> void:
	if _light_i < 0 or _light_i >= _beat_lights.size():
		return
	_light_wait -= delta
	if _light_wait > 0.0:
		return
	_power_beat(_light_i)
	sfx.play_kind("clunk", 0.76 + float(_light_i) * 0.04)
	_light_i += 1
	_light_wait = 0.46
	if _light_i >= _beat_lights.size():
		_light_i = -1
		_end_tutorial()


func _power_beat(index: int) -> void:
	var lamp := _beat_lights[index]
	lamp.show()
	lamp.light_energy = _beat_energy[index]
	var mat = _beat_mats[index]
	if mat is StandardMaterial3D:
		var glow_mat := mat as StandardMaterial3D
		glow_mat.emission_enabled = true
		glow_mat.emission_energy_multiplier = _beat_glow[index]
	_beam_hold = false
	_show_beam(false)


func _end_tutorial() -> void:
	_lesson_dark = false
	Game.tutorial = 6
	Game.lesson_price = 0
	Game.save_shift()
	for i in _beat_lights.size():
		_power_beat(i)
	_paint_day()
	_apply_presentation()
	_show_beam(false)
	if _sun != null:
		_sun.show()
	_say("There. You can see the whole mess. Tutorial's over. Don't make me do that again.", 5.5)


func _tick_steps(delta: float) -> void:
	if player == null or menu != "" or table_mode or not player.is_on_floor():
		_step_wait = 0.18
		return
	var speed := Vector2(player.velocity.x, player.velocity.z).length()
	if speed < 0.7:
		_step_wait = 0.18
		return
	var gap := clampf(1.85 / speed, 0.24, 0.5)
	_step_wait += delta
	if _step_wait < gap:
		return
	_step_wait = 0.0
	sfx.play_kind("step")


func _burn_talk(result: Dictionary, on_bonus: bool, finished_bonus: bool, paid: int, bonus_offer: bool, counted: bool) -> void:
	if Game.tutorial < 6:
		if Game.lesson_price <= 0:
			Game.lesson_price = Game.roll_worth(_roll_kind)
		if Game.tier_of("sprint") == 0 and Game.money < Game.lesson_price:
			Game.money = Game.lesson_price
		_tutor_to(5)
		_aim_spot(_hr_aim())
		if Game.tier_of("sprint") > 0:
			_say("You already bought the legs. Fine. Watch the ceiling.", 3.4)
			_start_house_lights()
			return
		_say("Green is the whole roll. Sprint costs that exact number. HR is lit. The window in the corner, left of me. Buy it. Then you can run.", 7.6)
		return
	if bool(result["offer"]) or bonus_offer:
		_announce_promotion()
		return
	if finished_bonus:
		sfx.play_kind("promote")
		_say(_boss_line(BOSS_BONUS_WIN) % paid, 5.0)
		return
	if on_bonus and not counted:
		_say(_boss_line(BOSS_BONUS_SKIP), 4.2)
		return
	if on_bonus:
		var left := _bonus_need - _bonus_done
		_say(_boss_line(BOSS_BONUS_STEP) % [_bonus_done, left], 4.2)
		return
	if int(result["missed"]) > 2:
		_say(_boss_line(BOSS_MISS), 5.0)
	elif int(result["slow_dock"]) > 0:
		_say(_boss_line(BOSS_SLOW), 5.2)
	elif int(result["missed"]) == 0:
		_say(_boss_line(BOSS_PERFECT), 4.2)


func _tick_incentives(delta: float) -> void:
	_pulse_button(delta)
	if menu != "" or Game.completed or Game.tutorial < 6:
		return
	if _bonus_left > 0.0:
		_bonus_left -= delta
		if _bonus_left <= 0.0:
			_bonus_fail()
		return
	if table_mode:
		return
	if _offer_left > 0.0:
		_offer_left -= delta
		if _offer_left <= 0.0:
			_offer_left = 0.0
			_offer_in = randf_range(70.0, 110.0)
		return
	_offer_in -= delta
	if _offer_in <= 0.0:
		_offer_left = 32.0
		_draft_mail()
		sfx.play_kind("buzzer")
		_say(_boss_line(BOSS_OFFER), 4.5)


func _press_speaker() -> void:
	_poke_button()
	sfx.play_kind("click")
	if _bonus_left > 0.0:
		_say(_boss_line(BOSS_CLOCK), 3.4)
		return
	if Game.promotion_ready():
		_open_promotion()
		return
	if _offer_left > 0.0:
		_say("That offer is an email. The computer is on this wall. My right. I am not walking over.", 4.8)
		return
	_say(_boss_line(BOSS_BUTTON), 4.0)


func _draft_mail() -> void:
	var total: int = 0
	for offer in INCENTIVES:
		total += int(offer["weight"])
	var roll: int = randi() % maxi(total, 1)
	var picked: Dictionary = INCENTIVES[0]
	for offer in INCENTIVES:
		roll -= int(offer["weight"])
		if roll < 0:
			picked = offer
			break
	_mail_rule = str(picked["rule"])
	_mail_mark = int(picked["mark"])
	_mail_need = int(picked["need"])
	_mail_seconds = float(picked["seconds"])
	_mail_pay = int(picked["pay"])
	_mail_subject = MAIL_SUBJECTS[randi() % MAIL_SUBJECTS.size()]
	_mail_joke = MAIL_JOKES[randi() % MAIL_JOKES.size()]


func _accept_mail() -> void:
	if _offer_left <= 0.0 or _mail_rule == "":
		return
	_bonus_target = "job"
	_bonus_rule = _mail_rule
	_bonus_mark = _mail_mark
	_bonus_done = 0
	_bonus_need = _mail_need
	_bonus_left = _mail_seconds
	_bonus_pay = _mail_pay
	_offer_left = 0.0
	_mail_rule = ""
	sfx.play_kind("click")
	_set_menu("")
	_say("Accepted. %.0f seconds. $%d if you burn them. I will be timing you. The clock enjoys this more than I do." % [_bonus_left, _bonus_pay], 7.0)


func _bonus_qualifies(chain_now: int, missed: int) -> bool:
	if _bonus_rule == "perfect":
		return missed == 0
	if _bonus_rule == "fast":
		return errand <= Game.PAR[mini(Game.rank, 4)]
	if _bonus_rule == "kind":
		return _roll_kind == _bonus_mark
	if _bonus_rule == "chain":
		return chain_now >= _bonus_mark
	return true


func _job_phrase(rule: String, need: int, mark: int) -> String:
	if rule == "perfect":
		return "%d perfect" % need
	if rule == "fast":
		return "%d on time" % need
	if rule == "kind":
		return "%d %s" % [need, Game.roll_name(mark)]
	if rule == "chain":
		return "%d with a chain of %d" % [need, mark]
	return "%d rolls" % need


func _bonus_phrase() -> String:
	return _job_phrase(_bonus_rule, _bonus_need, _bonus_mark)


func _bonus_short() -> String:
	if _bonus_rule == "perfect":
		return "perfect"
	if _bonus_rule == "fast":
		return "on time"
	if _bonus_rule == "kind":
		return Game.roll_name(_bonus_mark)
	if _bonus_rule == "chain":
		return "chain %d" % _bonus_mark
	return "rolls"


func _bonus_fail() -> void:
	_clear_bonus()
	_offer_in = randf_range(70.0, 110.0)
	sfx.play_kind("dock")
	_say(_boss_line(BOSS_BONUS_FAIL), 4.2)


func _clear_bonus() -> void:
	_bonus_left = 0.0
	_bonus_target = ""
	_bonus_pay = 0
	_bonus_need = 0
	_bonus_done = 0
	_bonus_rule = ""
	_bonus_mark = 0


func _poke_button() -> void:
	if _button == null:
		return
	var tw := create_tween()
	tw.tween_property(_button, "position:z", _button_rest + 0.06, 0.05)
	tw.tween_property(_button, "position:z", _button_rest, 0.12)


func _pulse_button(delta: float) -> void:
	_voice_time += delta
	if _button_mat == null:
		return
	var hot: bool = _bonus_left > 0.0 or (Game.promotion_ready() and not _promo_quiet)
	var pulse: float = 0.75 + sin(_voice_time * 5.0) * 0.25
	if hot:
		_button_mat.emission_energy_multiplier = pulse * 1.15
	else:
		_button_mat.emission_energy_multiplier = 0.4
	if _desk_mat != null:
		if _offer_left > 0.0:
			_desk_mat.emission_energy_multiplier = 0.7 + sin(_voice_time * 4.0) * 0.35
		else:
			_desk_mat.emission_energy_multiplier = 0.28


func _animate_voice() -> void:
	if _voice == null:
		return
	var talking: bool = _boss_life > 0.05
	_voice.visible = talking
	if not talking:
		return
	var out: float = 0.72 + sin(_voice_time * 9.0) * 0.28
	_voice.scale = Vector3(1.0, 1.0, out)
	for i in _zig_bits.size():
		var base: Vector3 = _zig_bases[i]
		_zig_bits[i].position = base + Vector3(0, sin(_voice_time * 16.0 + float(i) * 0.75) * 0.04, 0)


func _fill_shop() -> void:
	shop_stats.text = "$%d     %s" % [Game.money, Game.status_line()]
	for child in shop_list.get_children():
		child.queue_free()
	var last := ""
	for track in Game.TRACKS:
		var group: String = str(track["group"])
		if group != last:
			last = group
			var header: Label = UI.label(group.to_upper(), 13)
			header.add_theme_color_override("font_color", Color("8ea196"))
			shop_list.add_child(header)
		var id: String = str(track["id"])
		var costs: Array = track["costs"]
		var current: int = Game.tier_of(id)
		var btn: Button = UI.button("", Color("3d4a44"), false)
		btn.custom_minimum_size = Vector2(0, 40)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		var locked: bool = Game.rank < int(track["rank"])
		if locked:
			btn.text = "%s    %s" % [str(track["name"]), Game.RANK[int(track["rank"])]]
			btn.modulate = Color(1, 1, 1, 0.45)
		elif current >= costs.size():
			if id == "compound":
				btn.text = "%s    +%.1f / pop    max" % [str(track["name"]), 0.1 * float(1 + current)]
			elif id == "cart":
				btn.text = "%s    %d rolls    max" % [str(track["name"]), current + 1]
			elif id == "knuckle":
				btn.text = "%s    +%d / hand    max" % [str(track["name"]), current]
			elif id == "nose" or id == "skim":
				btn.text = "%s    +%d%%    max" % [str(track["name"]), current * 20]
			else:
				btn.text = "%s    %d/%d    max" % [str(track["name"]), current, costs.size()]
			btn.modulate = Color(1, 1, 1, 0.5)
		else:
			if id == "compound":
				var have := 0.1 * float(1 + current)
				var nxt := 0.1 * float(2 + current)
				btn.text = "%s    +%.1f → +%.1f    $%d" % [str(track["name"]), have, nxt, Game.next_cost(id)]
			elif id == "cart":
				var now_rolls: int = 2 if current == 0 else current + 1
				var next_rolls: int = now_rolls + 1 if current > 0 else 2
				if current == 0:
					btn.text = "%s    %d rolls    $%d" % [str(track["name"]), next_rolls, Game.next_cost(id)]
				else:
					btn.text = "%s    %d → %d rolls    $%d" % [str(track["name"]), now_rolls, next_rolls, Game.next_cost(id)]
			elif id == "knuckle":
				btn.text = "%s    +%d → +%d    $%d" % [str(track["name"]), current, current + 1, Game.next_cost(id)]
			elif id == "nose" or id == "skim":
				var now_pct := current * 20
				var next_pct := (current + 1) * 20
				if current == 0:
					btn.text = "%s    +%d%%    $%d" % [str(track["name"]), next_pct, Game.next_cost(id)]
				else:
					btn.text = "%s    +%d%% → +%d%%    $%d" % [str(track["name"]), now_pct, next_pct, Game.next_cost(id)]
			else:
				btn.text = "%s    %d/%d    $%d" % [str(track["name"]), current, costs.size(), Game.next_cost(id)]
			btn.modulate = Color(1, 1, 1, 1.0 if Game.can_buy(id) else 0.55)
			if Game.tutorial < 6 and id == "sprint" and current == 0:
				btn.modulate = Color(1.0, 0.72, 0.35, 1.0)
		btn.pressed.connect(_buy.bind(id))
		btn.mouse_entered.connect(_set_blurb.bind(str(track["blurb"])))
		shop_list.add_child(btn)


func _buy(id: String) -> void:
	if Game.tutorial < 6 and id != "sprint":
		_nag("Sprint. I lit the window, not the whole office.")
		return
	if Game.tutorial == 5 and id == "sprint" and not Game.can_buy(id):
		_nag("That number matches the roll. It is already in your pocket.")
		return
	if Game.try_buy(id):
		sfx.play_kind("promote")
		if id == "cart":
			_sync_cart()
		_fill_shop()
		if Game.tutorial == 5 and id == "sprint":
			_start_house_lights()
			return
		_say("Put it on the tab. The tab is your problem. I am the tab.", 3.6)


func _set_blurb(text: String) -> void:
	shop_blurb.text = text


func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var hud := Control.new()
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(hud)
	hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	walk_bar = Control.new()
	walk_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	walk_bar.set_anchors_preset(Control.PRESET_TOP_LEFT)
	walk_bar.offset_left = 28
	walk_bar.offset_top = 22
	walk_bar.offset_right = 420
	walk_bar.offset_bottom = 58
	hud.add_child(walk_bar)
	money_label = UI.label("$0", 22)
	UI.outline(money_label, 4)
	money_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	walk_bar.add_child(money_label)

	streak_label = UI.label("", 16)
	UI.outline(streak_label, 4)
	streak_label.add_theme_color_override("font_color", UI.GOOD)
	streak_label.set_anchors_preset(Control.PRESET_TOP_LEFT)
	streak_label.offset_left = 28
	streak_label.offset_top = 58
	streak_label.offset_right = 360
	streak_label.offset_bottom = 84
	streak_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	streak_label.hide()
	hud.add_child(streak_label)

	chain_label = UI.label("", 52)
	UI.outline(chain_label, 6)
	chain_label.add_theme_color_override("font_color", UI.ACCENT)
	chain_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	chain_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	chain_label.offset_left = -140
	chain_label.offset_top = 78
	chain_label.offset_right = 140
	chain_label.offset_bottom = 150
	chain_label.pivot_offset = Vector2(140, 36)
	chain_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chain_label.hide()
	hud.add_child(chain_label)

	run_label = UI.label("", 22)
	UI.outline(run_label, 4)
	run_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	run_label.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	run_label.offset_left = -280
	run_label.offset_top = 54
	run_label.offset_right = -28
	run_label.offset_bottom = 84
	run_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	run_label.hide()
	hud.add_child(run_label)
	pb_label = UI.label("", 14)
	UI.outline(pb_label, 3)
	pb_label.add_theme_color_override("font_color", UI.MUTED)
	pb_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	pb_label.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	pb_label.offset_left = -280
	pb_label.offset_top = 82
	pb_label.offset_right = -28
	pb_label.offset_bottom = 106
	pb_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pb_label.hide()
	hud.add_child(pb_label)
	hud_root = hud

	timer_label = UI.label("", 18)
	UI.outline(timer_label, 4)
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	timer_label.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	timer_label.offset_left = -160
	timer_label.offset_top = 22
	timer_label.offset_right = -28
	timer_label.offset_bottom = 52
	timer_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	timer_label.hide()
	hud.add_child(timer_label)
	cart_label = UI.label("", 15)
	UI.outline(cart_label, 4)
	cart_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	cart_label.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	cart_label.offset_left = -220
	cart_label.offset_top = 52
	cart_label.offset_right = -28
	cart_label.offset_bottom = 76
	cart_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cart_label.hide()
	hud.add_child(cart_label)

	tool_label = UI.label("", 15)
	UI.outline(tool_label, 4)
	tool_label.add_theme_color_override("font_color", UI.MUTED)
	tool_label.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	tool_label.offset_left = 28
	tool_label.offset_top = -48
	tool_label.offset_right = 220
	tool_label.offset_bottom = -22
	tool_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tool_label.hide()
	hud.add_child(tool_label)

	hotbar = Control.new()
	hotbar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hotbar.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	hotbar.offset_left = -280
	hotbar.offset_top = -92
	hotbar.offset_right = 280
	hotbar.offset_bottom = -16
	hud.add_child(hotbar)
	for i in TOOL_NAMES.size():
		var panel := Panel.new()
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
		hotbar.add_child(panel)
		var key := UI.label("", 13)
		key.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		key.mouse_filter = Control.MOUSE_FILTER_IGNORE
		key.set_anchors_preset(Control.PRESET_TOP_WIDE)
		key.offset_top = 4
		key.offset_bottom = 22
		panel.add_child(key)
		var name := UI.label(TOOL_NAMES[i], 15)
		name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name.mouse_filter = Control.MOUSE_FILTER_IGNORE
		name.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
		name.offset_top = -30
		name.offset_bottom = -6
		panel.add_child(name)
		_slot_panels.append(panel)
		_slot_keys.append(key)
		_slot_names.append(name)

	crosshair = UI.label("+", 18)
	UI.outline(crosshair, 4)
	crosshair.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	crosshair.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	crosshair.set_anchors_preset(Control.PRESET_CENTER)
	crosshair.offset_left = -16
	crosshair.offset_top = -16
	crosshair.offset_right = 16
	crosshair.offset_bottom = 16
	crosshair.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(crosshair)

	prompt_root = PanelContainer.new()
	prompt_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	prompt_root.add_theme_stylebox_override("panel", UI.style(Color(0.07, 0.1, 0.09, 0.78), 14, false, 14.0))
	prompt_root.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	prompt_root.offset_left = -180
	prompt_root.offset_top = -156
	prompt_root.offset_right = 180
	prompt_root.offset_bottom = -108
	prompt_root.hide()
	hud.add_child(prompt_root)
	prompt_label = UI.label("", 16)
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	prompt_root.add_child(prompt_label)

	_build_boss_card(hud)

	bonus_label = UI.label("", 16)
	UI.outline(bonus_label, 4)
	bonus_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bonus_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	bonus_label.offset_left = -360
	bonus_label.offset_top = 22
	bonus_label.offset_right = 360
	bonus_label.offset_bottom = 52
	bonus_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bonus_label.hide()
	hud.add_child(bonus_label)

	result_box = VBoxContainer.new()
	result_box.set_anchors_preset(Control.PRESET_CENTER)
	result_box.offset_left = -200
	result_box.offset_top = -40
	result_box.offset_right = 200
	result_box.offset_bottom = 140
	result_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(result_box)

	banner = UI.label("", 36)
	UI.outline(banner, 6)
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.set_anchors_preset(Control.PRESET_CENTER_TOP)
	banner.offset_left = -280
	banner.offset_top = 90
	banner.offset_right = 280
	banner.offset_bottom = 190
	banner.hide()
	banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(banner)

	_build_pause(hud)
	_build_shop(hud)
	_build_closet_shop(hud)
	_build_desk(hud)
	_build_promotion(hud)
	_build_ceremony(hud)
	_build_ending(hud)


func _card(host: Control) -> VBoxContainer:
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	host.add_child(center)
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", UI.panel_style())
	card.custom_minimum_size = Vector2(440, 0)
	center.add_child(card)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	card.add_child(box)
	return box


func _build_pause(hud: Control) -> void:
	pause_root = ColorRect.new()
	pause_root.color = Color(0.03, 0.05, 0.04, 0.72)
	pause_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pause_root.hide()
	hud.add_child(pause_root)
	var box := _card(pause_root)
	var title: Label = UI.label("Paused", 34)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	pause_money = UI.label("", 22)
	pause_money.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(pause_money)
	pause_detail = UI.label("", 16)
	pause_detail.add_theme_color_override("font_color", UI.MUTED)
	pause_detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(pause_detail)
	pause_tools = UI.label("", 14)
	pause_tools.add_theme_color_override("font_color", UI.DIM)
	pause_tools.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pause_tools.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(pause_tools)
	var resume: Button = UI.button("Resume", UI.ACCENT)
	resume.pressed.connect(func() -> void: _set_menu(""))
	box.add_child(resume)
	var settings_btn: Button = UI.button("Settings", Color("3d4a44"))
	settings_btn.pressed.connect(func() -> void: _open_settings("pause"))
	box.add_child(settings_btn)
	var exit_btn: Button = UI.button("Exit to home", Color("3d4a44"))
	exit_btn.pressed.connect(_exit_home)
	box.add_child(exit_btn)
	var note: Label = UI.label("Leave the roll. It does not come with you, and I am not holding it.", 14)
	note.add_theme_color_override("font_color", UI.DIM)
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(note)

	settings_root = SettingsMenu.build(_close_settings)
	settings_root.hide()
	hud.add_child(settings_root)


func _build_shop(hud: Control) -> void:
	shop_root = Panel.new()
	shop_root.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
	shop_root.offset_left = -440
	shop_root.offset_top = 18
	shop_root.offset_right = -18
	shop_root.offset_bottom = -18
	shop_root.add_theme_stylebox_override("panel", UI.panel_style())
	shop_root.hide()
	hud.add_child(shop_root)
	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	box.offset_left = 8
	box.offset_top = 6
	box.offset_right = -8
	box.offset_bottom = -6
	box.add_theme_constant_override("separation", 10)
	shop_root.add_child(box)
	var title: Label = UI.label("HR", 26)
	box.add_child(title)
	shop_stats = UI.label("", 15)
	shop_stats.add_theme_color_override("font_color", UI.MUTED)
	box.add_child(shop_stats)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	shop_list = VBoxContainer.new()
	shop_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shop_list.add_theme_constant_override("separation", 6)
	scroll.add_child(shop_list)
	shop_blurb = UI.label("Esc closes this. I was not finished talking.", 14)
	shop_blurb.add_theme_color_override("font_color", UI.DIM)
	shop_blurb.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	shop_blurb.custom_minimum_size = Vector2(0, 64)
	box.add_child(shop_blurb)


func _build_closet_shop(hud: Control) -> void:
	closet_root = Panel.new()
	closet_root.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
	closet_root.offset_left = -460
	closet_root.offset_top = 18
	closet_root.offset_right = -18
	closet_root.offset_bottom = -18
	closet_root.add_theme_stylebox_override("panel", UI.style(Color("241c16"), 16, true, 18.0))
	closet_root.hide()
	hud.add_child(closet_root)
	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	box.offset_left = 8
	box.offset_top = 6
	box.offset_right = -8
	box.offset_bottom = -6
	box.add_theme_constant_override("separation", 10)
	closet_root.add_child(box)
	var title: Label = UI.label("Janitor's closet", 26)
	box.add_child(title)
	closet_stats = UI.label("", 15)
	closet_stats.add_theme_color_override("font_color", UI.MUTED)
	box.add_child(closet_stats)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	closet_list = VBoxContainer.new()
	closet_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	closet_list.add_theme_constant_override("separation", 6)
	scroll.add_child(closet_list)
	closet_blurb = UI.label("Esc closes the slot.", 14)
	closet_blurb.add_theme_color_override("font_color", UI.DIM)
	closet_blurb.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	closet_blurb.custom_minimum_size = Vector2(0, 72)
	box.add_child(closet_blurb)


func _fill_closet() -> void:
	closet_stats.text = "$%d" % Game.money
	for child in closet_list.get_children():
		child.queue_free()
	_closet_row("pardon", "Pardon", 85, "Sits in your pocket until a sheet has a plump bubble. Then one of them counts as flat.")
	_closet_row("break", "Union break", 60, "Errand clocks stay stopped until you burn a sheet. Then it is gone.")
	_closet_row("chain", "Insured chain", 175, "Sits in your pocket until an empty click. That click leaves the chain alone.")
	_closet_row("quiet", "Quiet skim", 50, "Sits in your pocket until the next burn. That burn pays an extra $70 and loses 4 reputation.")


func _closet_owned(id: String) -> bool:
	if id == "pardon":
		return Game.pardon > 0
	if id == "break":
		return Game.break_hold > 0
	if id == "chain":
		return Game.chain_save > 0
	if id == "quiet":
		return Game.quiet_skim > 0
	return false


func _closet_row(id: String, item_name: String, cost: int, blurb: String) -> void:
	var btn: Button = UI.button("", Color("3a2c22"), false)
	btn.custom_minimum_size = Vector2(0, 44)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	var owned: bool = _closet_owned(id)
	if owned:
		btn.text = "%s     pocketed" % item_name
		btn.modulate = Color(1, 1, 1, 0.7)
	else:
		btn.text = "%s     $%d" % [item_name, cost]
		btn.modulate = Color(1, 1, 1, 1.0 if Game.money >= cost else 0.55)
	btn.pressed.connect(_buy_closet.bind(id, cost))
	btn.mouse_entered.connect(func() -> void:
		if closet_blurb != null:
			closet_blurb.text = blurb
	)
	closet_list.add_child(btn)


func _buy_closet(id: String, cost: int) -> void:
	if _closet_owned(id):
		_say_janitor("Already in the pocket. It spends itself.", 3.2)
		return
	if Game.money < cost:
		_say_janitor("That is not enough cash. The slot does not do credit.", 3.2)
		return
	Game.money -= cost
	if id == "pardon":
		Game.pardon = 1
	elif id == "break":
		Game.break_hold = 1
	elif id == "chain":
		Game.chain_save = 1
	elif id == "quiet":
		Game.quiet_skim = 1
	Game.save_shift()
	sfx.play_kind("clunk", 1.2)
	_fill_closet()
	_refresh_hud()


func _open_closet() -> void:
	_fill_closet()
	_set_menu("closet")


func _close_closet() -> void:
	if menu == "closet":
		_set_menu("")
	_closet_visit += 1
	_close_slot()


func _build_desk(hud: Control) -> void:
	desk_root = ColorRect.new()
	desk_root.color = Color(0.03, 0.05, 0.04, 0.72)
	desk_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	desk_root.hide()
	hud.add_child(desk_root)
	var frame := Panel.new()
	frame.set_anchors_preset(Control.PRESET_CENTER)
	frame.offset_left = -470
	frame.offset_top = -280
	frame.offset_right = 470
	frame.offset_bottom = 280
	frame.add_theme_stylebox_override("panel", UI.style(Color("14211c"), 16, true, 16.0))
	desk_root.add_child(frame)
	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	box.offset_left = 18
	box.offset_top = 16
	box.offset_right = -18
	box.offset_bottom = -16
	box.add_theme_constant_override("separation", 12)
	frame.add_child(box)
	var title: Label = UI.label("FLOOR TERMINAL", 26)
	box.add_child(title)
	var hint: Label = UI.label("Esc closes it. The boss can still hear you sigh.", 14)
	hint.add_theme_color_override("font_color", UI.DIM)
	box.add_child(hint)
	var row := HBoxContainer.new()
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 14)
	box.add_child(row)
	var nav := VBoxContainer.new()
	nav.custom_minimum_size = Vector2(190, 0)
	nav.add_theme_constant_override("separation", 8)
	row.add_child(nav)
	var review_btn: Button = UI.button("Annual Review", Color("3d4a44"), false)
	review_btn.pressed.connect(_show_desk_page.bind("review"))
	nav.add_child(review_btn)
	var mail_btn: Button = UI.button("Email", Color("3d4a44"), false)
	mail_btn.pressed.connect(_show_desk_page.bind("mail"))
	nav.add_child(mail_btn)
	var custom_btn: Button = UI.button("Customize", Color("3d4a44"), false)
	custom_btn.pressed.connect(_show_desk_page.bind("custom"))
	nav.add_child(custom_btn)
	desk_review = _desk_review_page()
	desk_mail = _desk_mail_page()
	desk_custom = _desk_custom_page()
	row.add_child(desk_review)
	row.add_child(desk_mail)
	row.add_child(desk_custom)


func _desk_review_page() -> Control:
	var page := VBoxContainer.new()
	page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page.add_theme_constant_override("separation", 14)
	var heading: Label = UI.label("Annual Review", 22)
	page.add_child(heading)
	review_face = ReviewFace.new()
	review_face.custom_minimum_size = Vector2(180, 180)
	review_face.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	page.add_child(review_face)
	review_caption = UI.label("", 18)
	review_caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	review_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page.add_child(review_caption)
	var track := ColorRect.new()
	track.custom_minimum_size = Vector2(0, 22)
	track.color = Color("101816")
	page.add_child(track)
	review_fill_bar = ColorRect.new()
	review_fill_bar.color = Color("8dce78")
	review_fill_bar.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	review_fill_bar.anchor_right = 0.4
	review_fill_bar.offset_right = 0
	track.add_child(review_fill_bar)
	var note: Label = UI.label("Corporate does not publish the number. The face is the number.", 14)
	note.add_theme_color_override("font_color", UI.DIM)
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page.add_child(note)
	return page


func _desk_mail_page() -> Control:
	var page := HBoxContainer.new()
	page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page.add_theme_constant_override("separation", 16)
	var letter := VBoxContainer.new()
	letter.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	letter.add_theme_constant_override("separation", 10)
	page.add_child(letter)
	mail_subject = UI.label("Inbox", 20)
	mail_subject.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	letter.add_child(mail_subject)
	mail_body = UI.label("", 16)
	mail_body.add_theme_color_override("font_color", UI.MUTED)
	mail_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	mail_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	letter.add_child(mail_body)
	var side := Panel.new()
	side.custom_minimum_size = Vector2(220, 0)
	side.add_theme_stylebox_override("panel", UI.style(Color("1b2a24"), 12, false, 12.0))
	page.add_child(side)
	var facts := VBoxContainer.new()
	facts.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	facts.offset_left = 12
	facts.offset_top = 12
	facts.offset_right = -12
	facts.offset_bottom = -12
	facts.add_theme_constant_override("separation", 8)
	side.add_child(facts)
	var side_title: Label = UI.label("THE JOB", 14)
	side_title.add_theme_color_override("font_color", UI.DIM)
	facts.add_child(side_title)
	mail_job = UI.label("—", 18)
	mail_job.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	facts.add_child(mail_job)
	mail_time = UI.label("—", 16)
	mail_time.add_theme_color_override("font_color", UI.MUTED)
	facts.add_child(mail_time)
	mail_pay = UI.label("—", 18)
	mail_pay.add_theme_color_override("font_color", UI.GOOD)
	facts.add_child(mail_pay)
	mail_take = UI.button("Take the job", Color("8a3a22"), false)
	mail_take.pressed.connect(_accept_mail)
	facts.add_child(mail_take)
	return page


func _desk_custom_page() -> Control:
	var page := VBoxContainer.new()
	page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page.add_theme_constant_override("separation", 12)
	var heading: Label = UI.label("Customize", 22)
	page.add_child(heading)
	var name_label: Label = UI.label("Name on the tag", 15)
	name_label.add_theme_color_override("font_color", UI.MUTED)
	page.add_child(name_label)
	desk_name = LineEdit.new()
	desk_name.max_length = 18
	desk_name.placeholder_text = "Eighteen letters"
	desk_name.custom_minimum_size = Vector2(0, 44)
	desk_name.add_theme_color_override("font_color", UI.INK)
	desk_name.add_theme_font_size_override("font_size", 18)
	page.add_child(desk_name)
	var rename: Button = UI.button("Print the tag", Color("3d4a44"), false)
	rename.pressed.connect(_rename_worker)
	page.add_child(rename)
	desk_name_hint = UI.label("The tube already printed one. This prints another, on your chest.", 14)
	desk_name_hint.add_theme_color_override("font_color", UI.DIM)
	desk_name_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	page.add_child(desk_name_hint)
	var tone_label: Label = UI.label("Skin", 15)
	tone_label.add_theme_color_override("font_color", UI.MUTED)
	page.add_child(tone_label)
	var tone_row := 0
	var tones := HBoxContainer.new()
	tones.add_theme_constant_override("separation", 8)
	page.add_child(tones)
	for i in Game.SKIN_NAME.size():
		if tone_row == 3:
			tones = HBoxContainer.new()
			tones.add_theme_constant_override("separation", 8)
			page.add_child(tones)
			tone_row = 0
		var swatch := ColorRect.new()
		swatch.color = Game.SKIN_COLOR[i]
		swatch.custom_minimum_size = Vector2(18, 42)
		tones.add_child(swatch)
		var btn: Button = UI.button(Game.SKIN_NAME[i], Color("3d4a44"), false)
		btn.custom_minimum_size = Vector2(120, 42)
		btn.pressed.connect(_pick_skin.bind(i))
		_skin_buttons.append(btn)
		tones.add_child(btn)
		tone_row += 1
	return page


func _open_desk() -> void:
	if Game.tutorial < 6:
		_nag("That computer is not on the tour.")
		return
	if _offer_left > 0.0:
		_desk_page = "mail"
	else:
		_desk_page = "review"
	if desk_name != null:
		desk_name.text = Game.worker_name
	_show_desk_page(_desk_page)
	_set_menu("desk")


func _show_desk_page(which: String) -> void:
	_desk_page = which
	if desk_review != null:
		desk_review.visible = which == "review"
	if desk_mail != null:
		desk_mail.visible = which == "mail"
	if desk_custom != null:
		desk_custom.visible = which == "custom"
	if which == "review":
		_paint_review()
	elif which == "mail":
		_paint_mail()
	elif which == "custom":
		_paint_skins()


func _review_caption(fill: float) -> String:
	if Game.completed or Game.rank >= 5:
		return "Corporate works for you now."
	if Game.promotion_ready():
		return "Corporate wants a meeting. The red button has the paperwork."
	if fill < 0.22:
		return "Corporate is disappointed."
	if fill < 0.45:
		return "Corporate is unimpressed."
	if fill < 0.7:
		return "Corporate is watching."
	if fill < 0.9:
		return "Corporate is pleased."
	return "Corporate is impressed."


func _paint_review() -> void:
	if review_face == null:
		return
	var fill := Game.review_fill()
	review_face.mood = fill
	review_face.queue_redraw()
	review_caption.text = _review_caption(fill)
	review_fill_bar.anchor_right = fill
	review_fill_bar.color = Color("c45b4a").lerp(Color("8dce78"), fill)


func _paint_mail() -> void:
	if mail_body == null:
		return
	if _bonus_left > 0.0 and _bonus_rule != "":
		mail_subject.text = "Already open"
		mail_body.text = "You already took one. The clock is the mean part. It does not care that you came back to read it again."
		mail_job.text = _bonus_phrase()
		mail_time.text = "%.0f seconds left" % ceil(_bonus_left)
		mail_pay.text = "$%d" % _bonus_pay
		mail_take.hide()
		return
	if _offer_left > 0.0 and _mail_rule != "":
		mail_subject.text = _mail_subject
		mail_body.text = "To: %s\n\n%s" % [Game.display_name(), _mail_joke]
		mail_job.text = _job_phrase(_mail_rule, _mail_need, _mail_mark)
		mail_time.text = "%.0f seconds" % _mail_seconds
		mail_pay.text = "$%d" % _mail_pay
		mail_take.show()
		return
	mail_subject.text = "Inbox zero"
	mail_body.text = "No new mail. Corporate will invent a reason. It usually does."
	mail_job.text = "—"
	mail_time.text = "—"
	mail_pay.text = "—"
	mail_take.hide()


func _paint_skins() -> void:
	for i in _skin_buttons.size():
		var mark := ""
		if i == Game.skin:
			mark = "•  "
		_skin_buttons[i].text = mark + Game.SKIN_NAME[i]


func _rename_worker() -> void:
	if desk_name == null:
		return
	var who := Game.clean_name(desk_name.text)
	if who == "":
		desk_name_hint.text = "The tag needs a name."
		return
	Game.worker_name = who
	Game.save_shift()
	_write_badge()
	desk_name.text = who
	desk_name_hint.text = "The tag says %s now." % who
	sfx.play_kind("click")


func _pick_skin(index: int) -> void:
	Game.skin = index
	Game.save_shift()
	player.set_skin(index)
	_paint_skins()
	sfx.play_kind("click")


func _build_promotion(hud: Control) -> void:
	promo_root = ColorRect.new()
	promo_root.color = Color(0.03, 0.05, 0.04, 0.72)
	promo_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	promo_root.hide()
	hud.add_child(promo_root)
	var box := _card(promo_root)
	var title: Label = UI.label("Promotion", 34)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	promo_body = UI.label("", 18)
	promo_body.add_theme_color_override("font_color", UI.MUTED)
	promo_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	promo_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(promo_body)
	var take: Button = UI.button("Take it", UI.ACCENT)
	take.pressed.connect(_accept_promotion)
	box.add_child(take)
	var later: Button = UI.button("Not yet", Color("3d4a44"))
	later.pressed.connect(_decline_promotion)
	box.add_child(later)


func _build_ceremony(hud: Control) -> void:
	ceremony_root = ColorRect.new()
	ceremony_root.color = Color(0.03, 0.05, 0.04, 0.5)
	ceremony_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ceremony_root.hide()
	hud.add_child(ceremony_root)
	var box := _card(ceremony_root)
	box.get_parent().custom_minimum_size = Vector2(480, 0)
	var kicker: Label = UI.label("PROMOTED", 14)
	kicker.add_theme_color_override("font_color", UI.ACCENT)
	kicker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(kicker)
	ceremony_title = UI.label("", 36)
	ceremony_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(ceremony_title)
	ceremony_who = UI.label("", 18)
	ceremony_who.add_theme_color_override("font_color", UI.ACCENT)
	ceremony_who.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(ceremony_who)
	ceremony_body = UI.label("", 16)
	ceremony_body.add_theme_color_override("font_color", UI.MUTED)
	ceremony_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ceremony_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(ceremony_body)
	var hint: Label = UI.label("Esc if you've read it.", 13)
	hint.add_theme_color_override("font_color", UI.DIM)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(hint)


func _announce_promotion() -> void:
	_promo_quiet = false
	_say(_boss_line(BOSS_PROMO), 5.0)


func _open_promotion() -> void:
	var next_rank: int = mini(Game.rank + 1, 5)
	var next_name: String = Game.RANK[next_rank]
	if next_rank >= 5:
		promo_body.text = "They want the tube to say Boss. Take the button. I will be unpleasant about it. The tag can wait until I am done being unpleasant."
	else:
		var gains := "\n".join(Game.rank_pitch(next_rank))
		promo_body.text = "%s.\n\n%s\n\nTake it, or stay %s. I get paid either way." % [next_name, gains, Game.RANK[Game.rank]]
	sfx.play_kind("wah")
	_set_menu("promo")


func _accept_promotion() -> void:
	Game.accept_promotion()
	_promo_quiet = false
	_set_menu("")
	if Game.completed:
		_play_firing()
		return
	_begin_ceremony()


func _begin_ceremony() -> void:
	var rank_now: int = mini(Game.rank, 5)
	ceremony_title.text = Game.RANK[rank_now]
	ceremony_who.text = Game.display_name()
	ceremony_body.text = "\n".join(Game.rank_pitch(rank_now))
	_set_menu("ceremony")
	sfx.play_kind("promote", 0.92)
	_say(RANK_SPEECH[rank_now], 8.4)
	_drop_badge()
	_ceremony_token += 1
	var token: int = _ceremony_token
	var tw := create_tween()
	tw.tween_interval(9.0)
	tw.tween_callback(func() -> void:
		if token == _ceremony_token:
			_end_ceremony()
	)


func _end_ceremony() -> void:
	if menu != "ceremony":
		return
	_ceremony_token += 1
	_set_menu("")


func _decline_promotion() -> void:
	_promo_quiet = true
	_set_menu("")
	_say(_boss_line(BOSS_PROMO_NO), 4.5)


func _build_ending(hud: Control) -> void:
	ending_root = ColorRect.new()
	ending_root.color = Color(0.03, 0.05, 0.04, 0.82)
	ending_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ending_root.hide()
	hud.add_child(ending_root)
	var box := _card(ending_root)
	box.custom_minimum_size = Vector2(520, 0)
	var title: Label = UI.label("You're the boss.", 34)
	ending_title = title
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	ending_body = UI.label("", 18)
	ending_body.add_theme_color_override("font_color", UI.MUTED)
	ending_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ending_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(ending_body)
	ending_button = UI.button("Get on the intercom", UI.ACCENT)
	ending_button.pressed.connect(_on_ending_button)
	box.add_child(ending_button)


func _build_world() -> void:
	var env := WorldEnvironment.new()
	var world := Environment.new()
	_env = world
	world.background_mode = Environment.BG_COLOR
	world.background_color = Color("1a2220")
	world.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	world.ambient_light_color = Color("9aa8a2")
	world.ambient_light_energy = 0.38
	world.fog_enabled = true
	world.fog_light_color = Color("8d9994")
	world.fog_density = 0.008
	env.environment = world
	add_child(env)
	var sun := DirectionalLight3D.new()
	_sun = sun
	sun.rotation_degrees = Vector3(-52, 32, 0)
	sun.light_energy = 0.7
	sun.light_color = Color("f2efe4")
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 70.0
	add_child(sun)
	_build_shell()
	_build_structure()
	_build_stations()
	_build_clutter()
	_zone("Bench", Vector3(0, 1.3, 1.3), Vector3(3.2, 2.4, 2.6))
	_zone("Burner", Vector3(20, 1.3, 18), Vector3(3.4, 2.6, 3.4))
	_zone("Shop", Vector3(-20.4, 1.4, 30.15), Vector3(3.0, 2.2, 1.8))
	_build_speaker()
	_sign("BENCH", Vector3(0, 2.35, -0.9))
	_sign("BURNER", Vector3(20, 2.7, 16.6))
	_build_hr()
	_build_closet()
	_build_computer()
	_build_mailer()
	_build_house_lights()
	_build_spot()


func _build_shell() -> void:
	_box(Vector3(-4.25, 0, 11), Vector3(51.5, 1, 42), Color("6a6f6c"), 0.92)
	_box(Vector3(-4.25, 3, 32), Vector3(53.5, 6, 1), Color("2c3532"), 0.88)
	_box(Vector3(-4.25, 3, -10), Vector3(53.5, 6, 1), Color("2c3532"), 0.88)
	_box(Vector3(21.5, 3, 11), Vector3(1, 6, 42), Color("2c3532"), 0.88)
	_box(Vector3(-30, 3, 11), Vector3(1, 6, 42), Color("2c3532"), 0.88)
	_box(Vector3(-4.25, 6.15, 11), Vector3(51.5, 0.28, 42), Color("1a211f"), 0.95)
	_visual(Vector3(-4.25, 1.15, 31.42), Vector3(49.5, 1.35, 0.1), Color("232b28"), 0.9)
	_visual(Vector3(-4.25, 1.15, -9.42), Vector3(49.5, 1.35, 0.1), Color("232b28"), 0.9)
	_visual(Vector3(20.92, 1.15, 3.6), Vector3(0.1, 1.35, 26.2), Color("232b28"), 0.9)
	_visual(Vector3(20.92, 1.15, 25.4), Vector3(0.1, 1.35, 12.2), Color("232b28"), 0.9)
	_visual(Vector3(-29.42, 1.15, -8.65), Vector3(0.1, 1.35, 0.7), Color("232b28"), 0.9)
	_visual(Vector3(-29.42, 1.15, 12.05), Vector3(0.1, 1.35, 37.9), Color("232b28"), 0.9)
	var seam_x: float = -24.0
	while seam_x <= 18.0:
		_visual(Vector3(seam_x, 0.512, 11), Vector3(0.045, 0.012, 40), Color("555b58"), 0.95)
		seam_x += 6.0
	var seam_z: float = -6.0
	while seam_z <= 28.0:
		_visual(Vector3(-4.25, 0.512, seam_z), Vector3(48, 0.012, 0.045), Color("555b58"), 0.95)
		seam_z += 6.0
	_decal(Vector3(-6, 0.52, 20), Vector3(-20, 0.52, 18))
	_decal(Vector3(-20, 0.52, 18), Vector3(0, 0.52, 1.2))
	_decal(Vector3(0, 0.52, 1.2), Vector3(20, 0.52, 18))
	_decal(Vector3(20, 0.52, 18), Vector3(-20, 0.52, 18))
	_visual(Vector3(0, 0.522, 0.55), Vector3(4.2, 0.015, 3.1), Color("3f463f"), 0.84)


func _build_structure() -> void:
	var posts: Array[Vector2] = [
		Vector2(-24, -6), Vector2(18.6, -6), Vector2(-24, 10), Vector2(18.6, 10),
		Vector2(-24, 24), Vector2(18.6, 24), Vector2(-10, 27), Vector2(10, 27),
	]
	for spot in posts:
		_box(Vector3(spot.x, 3.15, spot.y), Vector3(0.42, 5.3, 0.42), Color("3d4744"), 0.55)
	var truss_z: float = -6.0
	while truss_z <= 26.0:
		_visual(Vector3(-4.25, 5.35, truss_z), Vector3(48, 0.16, 0.22), Color("3a4441"), 0.5)
		truss_z += 8.0
	_visual(Vector3(-24, 5.22, 11), Vector3(0.18, 0.14, 36), Color("3a4441"), 0.5)
	_visual(Vector3(18.2, 5.22, 11), Vector3(0.18, 0.14, 36), Color("3a4441"), 0.5)
	_cyl(Vector3(19.2, 4.7, 11), 0.11, 36.0, Color("4a4038"), 0.48, Vector3(90, 0, 0))
	_cyl(Vector3(-4.25, 4.85, 30.2), 0.1, 46.0, Color("4a4038"), 0.48, Vector3(0, 0, 90))
	var window_x: float = -18.0
	while window_x <= 18.0:
		_visual(Vector3(window_x, 4.15, 31.38), Vector3(3.4, 1.15, 0.06), Color("9ec8cf"), 0.25, Color("c5e7ee"), 0.45)
		_visual(Vector3(window_x, 4.15, -9.48), Vector3(3.4, 1.15, 0.06), Color("9ec8cf"), 0.25, Color("c5e7ee"), 0.35)
		window_x += 9.0


func _build_speaker() -> void:
	_box(Vector3(0, 1.68, 31.24), Vector3(0.92, 1.28, 0.26), Color("1e1917"), 0.72)
	_visual(Vector3(0, 1.98, 31.08), Vector3(0.6, 0.52, 0.05), Color("12100f"), 0.5)
	var slot: int = 0
	while slot < 4:
		_visual(Vector3(0, 2.16 - float(slot) * 0.12, 31.04), Vector3(0.48, 0.018, 0.03), Color("3a3330"), 0.45)
		slot += 1
	var bezel := CylinderMesh.new()
	bezel.top_radius = 0.34
	bezel.bottom_radius = 0.34
	bezel.height = 0.06
	bezel.radial_segments = 24
	var bezel_mesh := MeshInstance3D.new()
	bezel_mesh.mesh = bezel
	bezel_mesh.position = Vector3(0, 1.28, 31.1)
	bezel_mesh.rotation_degrees = Vector3(90, 0, 0)
	bezel_mesh.material_override = _finish(Color("2c2624"), 0.55, Color(0, 0, 0), 0.0)
	add_child(bezel_mesh)
	_button = MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.26
	cyl.bottom_radius = 0.26
	cyl.height = 0.16
	cyl.radial_segments = 24
	_button.mesh = cyl
	_button.position = Vector3(0, 1.28, 31.0)
	_button.rotation_degrees = Vector3(90, 0, 0)
	_button_rest = _button.position.z
	_button_mat = _finish(Color("e25b2a"), 0.42, Color("e25b2a"), 0.7)
	_button.material_override = _button_mat
	add_child(_button)
	_voice = Node3D.new()
	_voice.name = "Voice"
	_voice.position = Vector3(0, 1.98, 31.02)
	add_child(_voice)
	_add_zigzag(-0.16)
	_add_zigzag(0.16)
	_voice.hide()
	_sign("BOSS", Vector3(0, 2.52, 30.85))
	_zone("Speaker", Vector3(0, 1.5, 31.0), Vector3(2.4, 2.2, 1.4))
	_build_tube()


func _build_tube() -> void:
	var brass := Color("c4a15a")
	_cyl(Vector3(1.15, 4.05, 31.22), 0.07, 4.0, brass, 0.28, Vector3.ZERO)
	_cyl(Vector3(1.15, 5.95, 31.22), 0.11, 0.08, Color("8a6a32"), 0.34, Vector3.ZERO)
	var center := Vector3(1.15, 1.95, 30.72)
	var bend: PackedVector3Array = PackedVector3Array()
	bend.append(Vector3(1.15, 2.05, 31.22))
	for i in 7:
		var t := float(i) / 6.0 * PI * 0.5
		bend.append(center + Vector3(0, -sin(t) * 0.5, cos(t) * 0.5))
	for i in range(1, bend.size()):
		_tube_seg(bend[i - 1], bend[i], 0.07, brass)
	var mouth: Vector3 = bend[bend.size() - 1]
	_cyl(mouth + Vector3(0, 0, -0.02), 0.1, 0.06, Color("8a6a32"), 0.34, Vector3(90, 0, 0))
	_badge_rest = Vector3(1.15, 1.2, 30.52)
	_visual(_badge_rest + Vector3(0, -0.07, 0.02), Vector3(0.42, 0.04, 0.26), Color("3a342c"), 0.48)
	_visual(_badge_rest + Vector3(-0.19, 0.0, 0.02), Vector3(0.03, 0.1, 0.26), Color("3a342c"), 0.48)
	_visual(_badge_rest + Vector3(0.19, 0.0, 0.02), Vector3(0.03, 0.1, 0.26), Color("3a342c"), 0.48)
	_tube_path = PackedVector3Array()
	var rise := 4.3
	while rise > 2.05:
		_tube_path.append(Vector3(1.15, rise, 31.22))
		rise -= 0.4
	for point in bend:
		_tube_path.append(point)
	_canister = MeshInstance3D.new()
	var shell := CylinderMesh.new()
	shell.top_radius = 0.05
	shell.bottom_radius = 0.05
	shell.height = 0.16
	shell.radial_segments = 12
	_canister.mesh = shell
	var carrier := _finish(Color("d5c7a4"), 0.4, Color(0, 0, 0), 0.0)
	carrier.metallic = 0.65
	_canister.material_override = carrier
	_canister.hide()
	add_child(_canister)
	_badge = Node3D.new()
	_badge.position = _badge_rest
	_badge.rotation_degrees = Vector3(-20, 180, 0)
	add_child(_badge)
	var card := MeshInstance3D.new()
	var plate := BoxMesh.new()
	plate.size = Vector3(0.36, 0.16, 0.012)
	card.mesh = plate
	card.material_override = _finish(Color("f4efe4"), 0.55, Color(0, 0, 0), 0.0)
	_badge.add_child(card)
	_badge_title = Label3D.new()
	_badge_title.position = Vector3(0, 0.032, 0.01)
	_badge_title.font_size = 32
	_badge_title.pixel_size = 0.00115
	_badge_title.modulate = Color("5c4632")
	_badge_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_badge_title.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	_badge.add_child(_badge_title)
	_badge_name = Label3D.new()
	_badge_name.position = Vector3(0, -0.028, 0.01)
	_badge_name.font_size = 48
	_badge_name.pixel_size = 0.00135
	_badge_name.modulate = Color("1c1916")
	_badge_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_badge_name.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	_badge.add_child(_badge_name)
	_badge.hide()


func _tube_seg(a: Vector3, b: Vector3, radius: float, color: Color) -> void:
	var mesh := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = radius
	cyl.bottom_radius = radius
	cyl.height = a.distance_to(b) + radius * 0.55
	cyl.radial_segments = 12
	mesh.mesh = cyl
	mesh.position = (a + b) * 0.5
	var mat := _finish(color, 0.28, Color(0, 0, 0), 0.0)
	mat.metallic = 0.82
	mesh.material_override = mat
	add_child(mesh)
	var dir := b - a
	var up := Vector3.UP
	if absf(dir.normalized().dot(Vector3.UP)) > 0.92:
		up = Vector3.FORWARD
	mesh.look_at(b, up)
	mesh.rotate_object_local(Vector3.RIGHT, -PI * 0.5)


func _build_worn_badge() -> void:
	if cam == null:
		return
	_worn = Node3D.new()
	_worn.position = Vector3(0.0, -0.3, -0.32)
	_worn.rotation_degrees = Vector3(-52, 0, 0)
	_worn.scale = Vector3(0.5, 0.5, 0.5)
	cam.add_child(_worn)
	var face: Array = _add_badge_face(_worn)
	_worn_title = face[0] as Label3D
	_worn_name = face[1] as Label3D
	_worn.hide()


func _add_badge_face(root: Node3D) -> Array:
	var card := MeshInstance3D.new()
	var plate := BoxMesh.new()
	plate.size = Vector3(0.36, 0.16, 0.012)
	card.mesh = plate
	card.material_override = _finish(Color("f4efe4"), 0.55, Color(0, 0, 0), 0.0)
	root.add_child(card)
	var title := Label3D.new()
	title.position = Vector3(0, 0.032, 0.01)
	title.font_size = 32
	title.pixel_size = 0.00115
	title.modulate = Color("5c4632")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	root.add_child(title)
	var who := Label3D.new()
	who.position = Vector3(0, -0.028, 0.01)
	who.font_size = 48
	who.pixel_size = 0.00135
	who.modulate = Color("1c1916")
	who.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	who.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	root.add_child(who)
	return [title, who]


func _present_badge() -> void:
	if _badge == null:
		return
	if Game.completed or Game.badge_rank >= Game.rank:
		Game.badge_rank = Game.rank
		_wear_badge()
		if Game.rank == 0:
			_park_badge()
		else:
			_seat_badge()
		return
	if Game.tutorial == 0:
		_prop_badge()
		return
	_badge.hide()
	var tw := create_tween()
	tw.tween_interval(0.8)
	tw.tween_callback(_drop_badge)


func _prop_badge() -> void:
	_badge_to_world()
	_write_badge()
	if _canister != null:
		_canister.hide()
	_badge.position = Vector3(0.72, 1.72, 30.55)
	_badge.rotation_degrees = Vector3(-8, 180, 0)
	_badge.show()


func _seat_badge() -> void:
	_badge_to_world()
	_write_badge()
	if _canister != null:
		_canister.hide()
	if _badge == null:
		return
	_badge.position = _badge_rest
	_badge.rotation_degrees = Vector3(-20, 180, 0)
	_badge.show()


func _park_badge() -> void:
	_badge_to_world()
	if _badge == null:
		return
	_badge.position = _badge_rest
	_badge.rotation_degrees = Vector3(-20, 180, 0)
	_badge.hide()


func _badge_to_world() -> void:
	if _badge == null:
		return
	if _badge.get_parent() != self:
		_badge.reparent(self)
	_badge.scale = Vector3.ONE


func _wear_badge() -> void:
	_write_badge()
	if _worn != null:
		_worn.show()


func _write_badge() -> void:
	var title := Game.RANK[mini(Game.rank, 5)].to_upper()
	var who := Game.display_name()
	if _badge_title != null:
		_badge_title.text = title
	if _badge_name != null:
		_badge_name.text = who
	if _worn_title != null:
		_worn_title.text = title
	if _worn_name != null:
		_worn_name.text = who


func _drop_badge() -> void:
	_badge_to_world()
	if _badge_drop or _canister == null or _tube_path.size() < 2:
		_seat_badge()
		_badge_arrived()
		return
	_badge_drop = true
	_write_badge()
	_badge.hide()
	_canister.position = _tube_path[0]
	_canister.show()
	_slide_canister(1)


func _slide_canister(index: int) -> void:
	if index >= _tube_path.size():
		_canister.hide()
		_badge.rotation_degrees = Vector3(-20, 180, 0)
		_badge.position = _badge_rest + Vector3(0, 0.16, 0)
		_badge.show()
		sfx.play_kind("clunk")
		var land := create_tween()
		land.tween_property(_badge, "position", _badge_rest, 0.2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		land.tween_callback(func() -> void:
			_badge_drop = false
			Game.badge_rank = Game.rank
			Game.save_shift()
			_badge_arrived()
		)
		return
	var dest: Vector3 = _tube_path[index]
	var step: Vector3 = dest - _canister.position
	if step.length() > 0.02:
		var up := Vector3.UP
		if absf(step.normalized().dot(Vector3.UP)) > 0.92:
			up = Vector3.FORWARD
		_canister.look_at(dest, up)
		_canister.rotate_object_local(Vector3.RIGHT, -PI * 0.5)
	var tw := create_tween()
	tw.tween_property(_canister, "position", dest, maxf(0.05, step.length() / 3.4))
	tw.tween_callback(func() -> void: _slide_canister(index + 1))


func _pickup_tag() -> void:
	if _pinning or _badge == null or cam == null:
		return
	_tutor_need_tag = false
	_pinning = true
	player.block_look = true
	player.block_move = true
	player.set_hands_visible(false)
	_badge.reparent(cam)
	_badge.position = Vector3(0.0, 0.04, -0.62)
	_badge.rotation_degrees = Vector3(0, 0, 0)
	_badge.scale = Vector3(0.2, 0.2, 0.2)
	_badge.show()
	sfx.play_kind("whoosh", 1.15)
	sfx.play_kind("promote", 0.92)
	var tw := create_tween()
	tw.tween_property(_badge, "scale", Vector3.ONE, 0.26).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(_badge, "rotation_degrees:y", 720.0, 1.05).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(_badge, "position", Vector3(0.0, -0.3, -0.32), 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.parallel().tween_property(_badge, "rotation_degrees", Vector3(-52, 0, 0), 0.5)
	tw.parallel().tween_property(_badge, "scale", Vector3(0.5, 0.5, 0.5), 0.5)
	tw.tween_callback(_finish_pin)


func _finish_pin() -> void:
	_park_badge()
	_wear_badge()
	sfx.play_kind("clunk", 1.4)
	_pinning = false
	if player != null:
		player.block_look = false
		player.block_move = false
		player.set_hands_visible(true)
	Game.badge_rank = Game.rank
	Game.save_shift()
	_say_wasd()


func _badge_arrived() -> void:
	var done := _badge_done
	_badge_done = Callable()
	if done.is_valid():
		done.call()


func _play_firing() -> void:
	_firing_token += 1
	var token: int = _firing_token
	_set_menu("firing")
	_say("You. Boss. I was going to print that tag and throw it away. The chair is mine. You still smell like the sheets.", 6.4)
	_firing_after(token, 6.6, func() -> void:
		sfx.play_kind("clunk", 0.9)
		_firing_after(token, 0.22, func() -> void:
			sfx.play_kind("clunk", 0.74)
			_firing_after(token, 0.55, func() -> void:
				_say_as("BOSS", "Nobody knocks. I told the building not to knock. Who is that.", 3.8, 1.22, UI.ACCENT)
				_firing_after(token, 4.0, func() -> void:
					_say_as("DOLORES", "Dolores Vetch. I can hear you. I have always been able to hear you.", 5.0, 1.46, Color("d5d0e6"))
					_firing_after(token, 5.2, func() -> void:
						_say_as("DOLORES", "You're fired. Leave the headset. Leave the chair. Take the mean little voice with you.", 5.8, 1.46, Color("d5d0e6"))
						_firing_after(token, 6.0, func() -> void:
							_say_as("DOLORES", "%s. You're the boss. The tag is coming down the tube. Try not to become him." % Game.display_name(), 5.4, 1.42, Color("d5d0e6"))
							_badge_done = func() -> void:
								if token != _firing_token:
									return
								_show_ending()
							_drop_badge()
						)
					)
				)
			)
		)
	)


func _firing_after(token: int, delay: float, step: Callable) -> void:
	var wait: float = delay
	if Settings.show_subtitles:
		wait = delay * Settings.subtitle_time
	var tw := create_tween()
	tw.tween_interval(wait)
	tw.tween_callback(func() -> void:
		if token != _firing_token:
			return
		step.call()
	)


func _skip_firing() -> void:
	if menu != "firing":
		return
	_firing_token += 1
	_badge_done = Callable()
	if Game.badge_rank < Game.rank and not _badge_drop:
		_drop_badge()
	_show_ending()


func _say_as(who: String, text: String, lock: float, pitch: float, ink: Color) -> void:
	if text != "":
		sfx.play_kind("wah", pitch)
	if not Settings.show_subtitles or boss_card == null:
		if boss_label != null:
			boss_label.text = ""
		if boss_card != null:
			boss_card.hide()
		_boss_life = lock
		return
	if boss_name != null:
		boss_name.text = who
		boss_name.add_theme_color_override("font_color", ink)
	boss_label.text = text
	boss_card.modulate.a = 1.0
	boss_card.show()
	_boss_life = lock * Settings.subtitle_time
	_style_boss()


func _add_zigzag(side: float) -> void:
	for i in 6:
		var bit := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(0.05, 0.05, 0.22)
		bit.mesh = box
		var flip: float = 1.0 if i % 2 == 0 else -1.0
		bit.position = Vector3(side, flip * 0.1, -0.2 - float(i) * 0.16)
		bit.rotation_degrees = Vector3(flip * 34.0, 0, 0)
		bit.material_override = _finish(Color("f4f1e8"), 0.35, Color("f7f4ec"), 3.0)
		bit.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		_voice.add_child(bit)
		_zig_bits.append(bit)
		_zig_bases.append(bit.position)


func _hr_aim() -> Vector3:
	return Vector3(-20.15, 1.5, 30.15)


func _build_stations() -> void:
	_box(Vector3(0, 0.58, 0.15), Vector3(2.45, 0.72, 1.28), Color("3c4744"), 0.62)
	_box(Vector3(0, 0.94, 0.15), Vector3(3.15, 0.08, 1.95), Color("8a6246"), 0.62)
	_visual(Vector3(1.35, 1.15, -0.55), Vector3(0.08, 0.55, 0.08), Color("3c4744"), 0.5)
	_visual(Vector3(1.35, 1.42, -0.2), Vector3(0.28, 0.06, 0.28), Color("d8d2c4"), 0.4, Color("fff1cf"), 0.8)
	_build_burner()


func _build_hr() -> void:
	var wall := Color("4a453f")
	var trim := Color("c8b89a")
	var slab := Color("6b5344")
	var x0 := -29.45
	var x1 := -21.55
	var z0 := 27.2
	var z1 := 31.42
	var y0 := 0.5
	var y1 := 3.05
	var mid_y := (y0 + y1) * 0.5
	var tall := y1 - y0
	_box(Vector3((x0 + x1) * 0.5, mid_y, z0), Vector3(x1 - x0, tall, 0.16), wall, 0.86)
	var win_z := 30.15
	var win_w := 1.28
	var win_y0 := 1.12
	var win_y1 := 1.9
	_box(Vector3(x1, mid_y, (z0 + (win_z - win_w * 0.5)) * 0.5), Vector3(0.16, tall, (win_z - win_w * 0.5) - z0), wall, 0.86)
	_box(Vector3(x1, mid_y, ((win_z + win_w * 0.5) + z1) * 0.5), Vector3(0.16, tall, z1 - (win_z + win_w * 0.5)), wall, 0.86)
	_box(Vector3(x1, (y0 + win_y0) * 0.5, win_z), Vector3(0.16, win_y0 - y0, win_w), wall, 0.86)
	_box(Vector3(x1, (win_y1 + y1) * 0.5, win_z), Vector3(0.16, y1 - win_y1, win_w), wall, 0.86)
	_visual(Vector3((x0 + x1) * 0.5, y1, (z0 + z1) * 0.5), Vector3(x1 - x0 + 0.2, 0.08, z1 - z0 + 0.1), Color("2c2824"), 0.9)
	_visual(Vector3((x0 + x1) * 0.5 + 0.3, 0.52, (z0 + z1) * 0.5 + 0.15), Vector3(x1 - x0 - 0.7, 0.02, z1 - z0 - 0.5), Color("3a342c"), 0.92)
	_blind_window(Vector3(-27.3, 1.7, z0 - 0.1), 1.35, 0.85, true)
	_blind_window(Vector3(-24.4, 1.7, z0 - 0.1), 1.15, 0.85, true)
	var door_z := 28.35
	_visual(Vector3(x1 + 0.05, 1.42, door_z), Vector3(0.06, 1.9, 0.92), slab, 0.72)
	_visual(Vector3(x1 + 0.09, 1.42, door_z), Vector3(0.02, 1.96, 0.98), trim, 0.55)
	_visual(Vector3(x1 + 0.1, 1.15, door_z + 0.32), Vector3(0.04, 0.08, 0.16), Color("c4a15a"), 0.35)
	var only := Label3D.new()
	only.text = "HR ONLY"
	only.font_size = 48
	only.pixel_size = 0.004
	only.position = Vector3(x1 + 0.12, 2.55, door_z)
	only.rotation_degrees = Vector3(0, 90, 0)
	only.modulate = Color("e6dcc8")
	only.outline_size = 8
	only.outline_modulate = Color(0, 0, 0, 0.75)
	only.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	add_child(only)
	var glass := MeshInstance3D.new()
	var pane := BoxMesh.new()
	pane.size = Vector3(0.02, win_y1 - win_y0, win_w - 0.08)
	glass.mesh = pane
	glass.position = Vector3(x1 + 0.02, (win_y0 + win_y1) * 0.5, win_z)
	var pane_mat := StandardMaterial3D.new()
	pane_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	pane_mat.albedo_color = Color(0.72, 0.84, 0.78, 0.22)
	pane_mat.roughness = 0.06
	pane_mat.metallic = 0.15
	pane_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	glass.material_override = pane_mat
	add_child(glass)
	_visual(Vector3(x1 + 0.04, win_y1, win_z), Vector3(0.05, 0.05, win_w + 0.08), trim, 0.5)
	_visual(Vector3(x1 + 0.04, win_y0, win_z), Vector3(0.05, 0.05, win_w + 0.08), trim, 0.5)
	_visual(Vector3(x1 + 0.04, (win_y0 + win_y1) * 0.5, win_z - win_w * 0.5), Vector3(0.05, win_y1 - win_y0, 0.05), trim, 0.5)
	_visual(Vector3(x1 + 0.04, (win_y0 + win_y1) * 0.5, win_z + win_w * 0.5), Vector3(0.05, win_y1 - win_y0, 0.05), trim, 0.5)
	_visual(Vector3(x1 + 0.1, 1.28, win_z), Vector3(0.1, 0.16, 0.22), Color("8a8074"), 0.4)
	_visual(Vector3(x1 + 0.16, 1.28, win_z), Vector3(0.02, 0.1, 0.1), Color("1a1816"), 0.3)
	_visual(Vector3(x1 + 0.08, 1.02, win_z), Vector3(0.28, 0.06, win_w * 0.7), Color("5c5146"), 0.6)
	var hr_sign := Label3D.new()
	hr_sign.text = "HR"
	hr_sign.font_size = 64
	hr_sign.pixel_size = 0.006
	hr_sign.position = Vector3(x1 + 0.14, 2.35, win_z)
	hr_sign.rotation_degrees = Vector3(0, 90, 0)
	hr_sign.modulate = Color("e7a15a")
	hr_sign.outline_size = 10
	hr_sign.outline_modulate = Color(0, 0, 0, 0.8)
	hr_sign.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	add_child(hr_sign)
	var backdrop := MeshInstance3D.new()
	var back_box := BoxMesh.new()
	back_box.size = Vector3(0.04, 1.15, 1.05)
	backdrop.mesh = back_box
	backdrop.position = Vector3(-22.55, 1.45, win_z)
	backdrop.material_override = _flat_mat(Color("5a4e44"))
	add_child(backdrop)
	_hr_lady(Vector3(-22.15, 0.5, win_z))
	var block := StaticBody3D.new()
	block.position = Vector3(x1, (win_y0 + win_y1) * 0.5, win_z)
	var block_shape := CollisionShape3D.new()
	var block_box := BoxShape3D.new()
	block_box.size = Vector3(0.12, win_y1 - win_y0, win_w)
	block_shape.shape = block_box
	block.add_child(block_shape)
	add_child(block)


func _blind_window(center: Vector3, width: float, height: float, south: bool) -> void:
	var frame := Color("c2b394")
	var slat := Color("1a1714")
	var depth := 0.04
	if south:
		_visual(center + Vector3(0, height * 0.5, 0), Vector3(width, 0.045, depth), frame, 0.55)
		_visual(center + Vector3(0, -height * 0.5, 0), Vector3(width, 0.045, depth), frame, 0.55)
		_visual(center + Vector3(-width * 0.5, 0, 0), Vector3(0.045, height, depth), frame, 0.55)
		_visual(center + Vector3(width * 0.5, 0, 0), Vector3(0.045, height, depth), frame, 0.55)
		_visual(center + Vector3(0, 0, 0.02), Vector3(width - 0.08, height - 0.08, 0.02), Color("12100e"), 0.95)
		var rows := 7
		var span := height - 0.12
		for i in rows:
			var y := center.y - span * 0.5 + span * (float(i) + 0.5) / float(rows)
			_visual(Vector3(center.x, y, center.z - 0.02), Vector3(width - 0.12, 0.025, 0.03), slat, 0.7)
		return
	_visual(center + Vector3(0, height * 0.5, 0), Vector3(depth, 0.045, width), frame, 0.55)
	_visual(center + Vector3(0, -height * 0.5, 0), Vector3(depth, 0.045, width), frame, 0.55)
	_visual(center + Vector3(0, 0, -width * 0.5), Vector3(depth, height, 0.045), frame, 0.55)
	_visual(center + Vector3(0, 0, width * 0.5), Vector3(depth, height, 0.045), frame, 0.55)


func _hr_lady(feet: Vector3) -> void:
	var ink := _flat_mat(Color("0c0b0a"))
	var body := MeshInstance3D.new()
	var torso := BoxMesh.new()
	torso.size = Vector3(0.34, 0.72, 0.22)
	body.mesh = torso
	body.position = feet + Vector3(0.02, 1.05, 0)
	body.material_override = ink
	add_child(body)
	var shoulders := MeshInstance3D.new()
	var yoke := BoxMesh.new()
	yoke.size = Vector3(0.5, 0.16, 0.24)
	shoulders.mesh = yoke
	shoulders.position = feet + Vector3(0.0, 1.38, 0)
	shoulders.material_override = ink
	add_child(shoulders)
	var head := MeshInstance3D.new()
	var skull := SphereMesh.new()
	skull.radius = 0.12
	skull.height = 0.24
	skull.radial_segments = 12
	skull.rings = 8
	head.mesh = skull
	head.position = feet + Vector3(0.04, 1.62, 0)
	head.material_override = ink
	add_child(head)
	var bun := MeshInstance3D.new()
	var knot := SphereMesh.new()
	knot.radius = 0.055
	knot.height = 0.11
	knot.radial_segments = 10
	knot.rings = 6
	bun.mesh = knot
	bun.position = feet + Vector3(-0.06, 1.74, 0)
	bun.material_override = ink
	add_child(bun)


func _build_rack() -> void:
	_box(Vector3(-20, 1.15, 18.15), Vector3(2.15, 2.15, 0.72), Color("3a403c"), 0.7)
	_visual(Vector3(-20.95, 1.2, 17.85), Vector3(0.1, 2.3, 0.1), Color("4d5854"), 0.45)
	_visual(Vector3(-19.05, 1.2, 17.85), Vector3(0.1, 2.3, 0.1), Color("4d5854"), 0.45)
	var shelf_y: float = 0.72
	while shelf_y <= 2.05:
		_visual(Vector3(-20, shelf_y, 17.9), Vector3(2.05, 0.05, 0.7), Color("5c6762"), 0.5)
		var roll_x: float = -20.7
		while roll_x <= -19.3:
			var spot := Vector3(roll_x, shelf_y + 0.16, 17.85)
			var roll := MeshInstance3D.new()
			roll.position = spot
			roll.rotation_degrees = Vector3(0, 0, 90)
			add_child(roll)
			_rack_pos.append(spot)
			_rack_kind.append(_rack_kind.size() % Game.roll_count())
			_rack_mesh.append(roll)
			_apply_rack_roll(_rack_mesh.size() - 1)
			roll_x += 0.42
		shelf_y += 0.66


func _aimed_roll() -> int:
	if cam == null or _rack_pos.is_empty():
		return -1
	var from: Vector3 = cam.global_position
	var forward: Vector3 = -cam.global_transform.basis.z
	var best: int = -1
	var best_d: float = 0.42
	for i in _rack_pos.size():
		var to_roll: Vector3 = _rack_pos[i] - from
		var along: float = forward.dot(to_roll)
		if along < 0.3 or along > 4.2:
			continue
		var lateral: float = (to_roll - forward * along).length()
		if lateral < best_d:
			best_d = lateral
			best = i
	return best


func _grab_roll() -> int:
	var index: int = _aimed_roll()
	if index < 0:
		return randi() % Game.roll_count()
	var kind: int = _rack_kind[index]
	var next: int = (kind + 1 + randi() % maxi(1, Game.roll_count() - 1)) % Game.roll_count()
	_rack_kind[index] = next
	_apply_rack_roll(index)
	return kind


func _apply_rack_roll(index: int) -> void:
	var kind: int = _rack_kind[index]
	var cyl := CylinderMesh.new()
	var radius: float = Game.roll_radius(kind)
	cyl.top_radius = radius
	cyl.bottom_radius = radius
	cyl.height = 0.34
	cyl.radial_segments = 16
	_rack_mesh[index].mesh = cyl
	_rack_mesh[index].material_override = _finish(Game.roll_color(kind), 0.42, Color(0, 0, 0), 0.0)


func _build_burner() -> void:
	_incinerator = INCINERATOR.instantiate()
	_incinerator.name = "Incinerator"
	_incinerator.position = Vector3(20.0, 1.59, 18.0)
	_incinerator.rotation.y = PI
	add_child(_incinerator)
	_prep_incinerator(_incinerator)
	var body := StaticBody3D.new()
	body.position = Vector3(20.0, 1.55, 18.0)
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(2.05, 2.15, 2.05)
	col.shape = shape
	body.add_child(col)
	add_child(body)
	var spots: Array[Vector3] = [
		Vector3(0.42, -0.28, 0.08), Vector3(0.72, -0.02, 0.22), Vector3(0.36, -0.12, 0.4),
		Vector3(0.78, 0.08, 0.48), Vector3(0.5, -0.22, 0.62), Vector3(0.84, 0.02, 0.74),
		Vector3(0.4, -0.16, 0.9), Vector3(0.66, -0.06, 0.34),
	]
	var heights: Array[float] = [0.46, 0.62, 0.78, 0.7, 0.5, 0.58, 0.44, 0.86]
	var radii: Array[float] = [0.1, 0.13, 0.11, 0.14, 0.12, 0.1, 0.09, 0.15]
	var colors: Array[Color] = [
		Color(1.0, 0.32, 0.06, 0.82), Color(1.0, 0.5, 0.12, 0.88), Color(1.0, 0.62, 0.18, 0.9),
		Color(1.0, 0.42, 0.08, 0.86), Color(1.0, 0.28, 0.05, 0.8), Color(1.0, 0.55, 0.16, 0.88),
		Color(1.0, 0.36, 0.07, 0.84), Color(1.0, 0.7, 0.22, 0.92),
	]
	for n in spots.size():
		_flames.append(_make_flame(spots[n], heights[n], radii[n], colors[n]))
	_fire_light = OmniLight3D.new()
	_fire_light.position = spots[1]
	_fire_light.light_color = Color("ff6a2a")
	_fire_light.light_energy = 2.2
	_fire_light.omni_range = 4.2
	_fire_light.shadow_enabled = false
	_incinerator.add_child(_fire_light)


func _prep_incinerator(node: Node) -> void:
	if node is Camera3D:
		var cam_node: Camera3D = node as Camera3D
		cam_node.current = false
		cam_node.hide()
	elif node is Light3D:
		node.hide()
		(node as Light3D).light_energy = 0.0
	elif node is AnimationPlayer:
		var anim_player: AnimationPlayer = node as AnimationPlayer
		if anim_player.has_animation("Scene"):
			var anim: Animation = anim_player.get_animation("Scene")
			anim.loop_mode = Animation.LOOP_NONE
			_door = anim_player
			_door_open = _door_open_time(anim)
			_door.play("Scene")
			_door.seek(0.0, true)
			_door.pause()
	for child in node.get_children():
		_prep_incinerator(child)


func _make_flame(at: Vector3, height: float, radius: float, color: Color) -> MeshInstance3D:
	var flame := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius * 0.15
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 8
	flame.mesh = mesh
	flame.position = at
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	mat.albedo_color = color
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	flame.material_override = mat
	flame.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_incinerator.add_child(flame)
	return flame


func _door_open_time(anim: Animation) -> float:
	var best_t: float = 0.0
	var best: float = 0.0
	for track in anim.get_track_count():
		if anim.track_get_type(track) != Animation.TYPE_ROTATION_3D:
			continue
		for key in anim.track_get_key_count(track):
			var turned: Quaternion = anim.track_get_key_value(track, key)
			var angle: float = turned.angle_to(Quaternion.IDENTITY)
			if angle > best:
				best = angle
				best_t = anim.track_get_key_time(track, key)
	if best_t <= 0.05:
		return anim.length * 0.55
	return best_t


func _tick_door() -> void:
	if _door == null or player == null:
		return
	var flat := Vector2(player.global_position.x - 20.0, player.global_position.z - 18.0)
	var near: bool = flat.length() < 4.6
	var pos: float = _door.current_animation_position
	var goal: float = _door_open if near else 0.0
	if absf(pos - goal) <= 0.03:
		_door.pause()
		_door.seek(goal, true)
		return
	var direction: float = 1.0 if goal > pos else -1.0
	if not _door.is_playing() or absf(_door.speed_scale - direction) > 0.01:
		_door.play("Scene", -1, direction)
		_door.seek(pos, true)


func _tick_fire(delta: float) -> void:
	if _flames.is_empty():
		return
	_fire_time += delta
	_fire_kick = move_toward(_fire_kick, 0.0, delta * 0.45)
	var flare: float = 1.0 + _fire_kick * 0.85
	for i in _flames.size():
		var flicker: float = 0.82 + sin(_fire_time * 13.0 + float(i) * 2.1) * 0.14 + sin(_fire_time * 23.0 + float(i)) * 0.06
		_flames[i].scale = Vector3(flare, flicker * flare, flare)
		_flames[i].rotation.y = _fire_time * 1.4 + float(i)
	if _fire_light != null:
		_fire_light.light_energy = (1.5 + sin(_fire_time * 11.0) * 0.35) * flare


func _build_clutter() -> void:
	_visual(Vector3(-28, 0.58, 14), Vector3(1.3, 0.12, 1.05), Color("8a6246"), 0.8)
	_visual(Vector3(-28, 0.95, 14), Vector3(1.15, 0.62, 0.9), Color("d9d3c6"), 0.75)
	_visual(Vector3(-28, 1.45, 14), Vector3(1.1, 0.38, 0.86), Color("c4bfb2"), 0.78)
	_cyl(Vector3(18.4, 0.72, 23.2), 0.38, 1.15, Color("3d5348"), 0.55, Vector3.ZERO)
	_cyl(Vector3(19.1, 0.62, 24.0), 0.32, 0.95, Color("5c4030"), 0.6, Vector3.ZERO)
	_cyl(Vector3(17.8, 0.55, 24.15), 0.28, 0.8, Color("8a7030"), 0.55, Vector3.ZERO)
	_visual(Vector3(17.8, 0.72, 24.15), Vector3(0.58, 0.1, 0.58), Color("1c1c1c"), 0.7)
	_box(Vector3(13.5, 0.55, 26.2), Vector3(1.7, 0.7, 0.95), Color("c9a227"), 0.62)
	_visual(Vector3(13.5, 1.15, 26.55), Vector3(0.12, 1.1, 0.7), Color("3a3a3a"), 0.5)
	_visual(Vector3(13.15, 0.58, 25.7), Vector3(0.7, 0.05, 0.12), Color("2a2a2a"), 0.6)
	_visual(Vector3(13.85, 0.58, 25.7), Vector3(0.7, 0.05, 0.12), Color("2a2a2a"), 0.6)
	_cyl(Vector3(19.2, 3.3, -4), 0.7, 0.18, Color("3a403c"), 0.5, Vector3(0, 0, 90))


func _box(pos: Vector3, size: Vector3, color: Color, rough: float) -> void:
	var body := StaticBody3D.new()
	body.position = pos
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	mesh.material_override = _finish(color, rough, Color(0, 0, 0), 0.0)
	body.add_child(mesh)
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	col.shape = shape
	body.add_child(col)
	add_child(body)


func _visual(pos: Vector3, size: Vector3, color: Color, rough: float, glow: Color = Color(0, 0, 0), glow_energy: float = 0.0) -> void:
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	mesh.position = pos
	mesh.material_override = _finish(color, rough, glow, glow_energy)
	add_child(mesh)


func _cyl(pos: Vector3, radius: float, height: float, color: Color, rough: float, rot: Vector3, glow: Color = Color(0, 0, 0), glow_energy: float = 0.0) -> void:
	var mesh := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = radius
	cyl.bottom_radius = radius
	cyl.height = height
	cyl.radial_segments = 16
	mesh.mesh = cyl
	mesh.position = pos
	mesh.rotation_degrees = rot
	mesh.material_override = _finish(color, rough, glow, glow_energy)
	add_child(mesh)


func _finish(color: Color, rough: float, glow: Color, glow_energy: float) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = rough
	if glow_energy > 0.0:
		mat.emission_enabled = true
		mat.emission = glow
		mat.emission_energy_multiplier = glow_energy
	return mat


func _omni(pos: Vector3, color: Color, energy: float, reach: float) -> OmniLight3D:
	var light := OmniLight3D.new()
	light.position = pos
	light.light_color = color
	light.light_energy = energy
	light.omni_range = reach
	light.shadow_enabled = false
	add_child(light)
	return light


func _decal(a: Vector3, b: Vector3) -> void:
	var mid: Vector3 = (a + b) * 0.5
	mid.y = 0.53
	var delta: Vector3 = b - a
	delta.y = 0.0
	var length: float = delta.length()
	if length < 0.1:
		return
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(1.7, 0.02, length)
	mesh.mesh = box
	mesh.position = mid
	mesh.rotation.y = atan2(delta.x, delta.z)
	mesh.material_override = _finish(Color("c6a84e"), 0.72, Color(0, 0, 0), 0.0)
	add_child(mesh)


func _zone(zone_name: String, pos: Vector3, size: Vector3) -> void:
	var area := Area3D.new()
	area.name = zone_name
	area.position = pos
	area.collision_layer = 2
	area.collision_mask = 0
	area.add_to_group("station")
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	col.shape = shape
	area.add_child(col)
	add_child(area)


func _build_boss_card(hud: Control) -> void:
	boss_card = HBoxContainer.new()
	boss_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	boss_card.add_theme_constant_override("separation", 0)
	boss_card.set_anchors_preset(Control.PRESET_TOP_LEFT)
	boss_card.hide()
	hud.add_child(boss_card)
	var plate := PanelContainer.new()
	plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plate.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	plate.add_theme_stylebox_override("panel", UI.style(Color("1c2622"), 10, false, 8.0))
	boss_card.add_child(plate)
	var col := VBoxContainer.new()
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 2)
	plate.add_child(col)
	_boss_bust = BossBust.new()
	_boss_bust.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_boss_bust.custom_minimum_size = Vector2(74, 96)
	col.add_child(_boss_bust)
	boss_name = UI.label("BOSS", 13)
	boss_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_name.add_theme_color_override("font_color", UI.ACCENT)
	UI.outline(boss_name, 3)
	col.add_child(boss_name)
	var tail := BossTail.new()
	tail.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tail.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	tail.custom_minimum_size = Vector2(12, 18)
	boss_card.add_child(tail)
	_boss_bubble = PanelContainer.new()
	_boss_bubble.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_boss_bubble.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_boss_bubble.add_theme_stylebox_override("panel", UI.style(Color(0.07, 0.098, 0.086, 0.94), 12, true, 14.0))
	boss_card.add_child(_boss_bubble)
	boss_label = UI.label("", 17)
	boss_label.add_theme_color_override("font_color", UI.INK)
	boss_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	boss_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	boss_label.custom_minimum_size = Vector2(250, 0)
	boss_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_boss_bubble.add_child(boss_label)


func _knock_closet() -> void:
	if Game.tutorial < 6:
		_nag("That closet is not on the tour.")
		return
	if _janitor_busy or _slot_cover == null:
		return
	_janitor_busy = true
	sfx.play_kind("clunk", 1.35)
	var knocks := create_tween()
	knocks.tween_interval(0.16)
	knocks.tween_callback(func() -> void: sfx.play_kind("clunk", 1.12))
	knocks.tween_interval(0.32)
	knocks.tween_callback(_open_slot)


func _open_slot() -> void:
	if _slot_cover == null:
		_janitor_busy = false
		return
	var first: bool = not Game.met_janitor
	if first:
		Game.met_janitor = true
		Game.save_shift()
	if _slot_eyes != null:
		_slot_eyes.show()
	var slide := create_tween()
	slide.tween_property(_slot_cover, "position:z", _slot_rest + 0.52, 0.18)
	slide.tween_callback(func() -> void:
		_closet_visit += 1
		var visit: int = _closet_visit
		if first:
			_say_janitor(JANITOR_INTRO, 4.2)
			_open_closet()
			var follow := create_tween()
			var wait: float = 4.4
			if Settings.show_subtitles:
				wait = 4.4 * Settings.subtitle_time
			follow.tween_interval(wait)
			follow.tween_callback(func() -> void:
				if menu == "closet" and visit == _closet_visit:
					_say_janitor(JANITOR_PITCH, 4.6)
			)
		else:
			_say_janitor(_janitor_line(), 3.6)
			_open_closet()
	)


func _close_slot() -> void:
	if _slot_cover == null:
		_janitor_busy = false
		return
	var slide := create_tween()
	slide.tween_property(_slot_cover, "position:z", _slot_rest, 0.14)
	slide.tween_callback(func() -> void:
		if _slot_eyes != null:
			_slot_eyes.hide()
		_janitor_busy = false
	)


func _janitor_line() -> String:
	if JANITOR_LINES.is_empty():
		return ""
	var pick: int = randi() % JANITOR_LINES.size()
	if JANITOR_LINES.size() > 1 and JANITOR_LINES[pick] == _janitor_last:
		pick = (pick + 1) % JANITOR_LINES.size()
	_janitor_last = JANITOR_LINES[pick]
	return JANITOR_LINES[pick]


func _say_janitor(text: String, lock: float) -> void:
	if text != "":
		sfx.play_kind("wah", 0.68)
	if not Settings.show_subtitles or boss_card == null:
		boss_label.text = ""
		if boss_card != null:
			boss_card.hide()
		_boss_life = lock
		return
	if boss_name != null:
		boss_name.text = "JANITOR"
		boss_name.add_theme_color_override("font_color", Color("c4b06a"))
	boss_label.text = text
	boss_card.modulate.a = 1.0
	boss_card.show()
	_boss_life = lock * Settings.subtitle_time
	_style_boss()


func _build_mailer() -> void:
	var wall_x := -29.42
	var zc := 8.0
	_box(Vector3(wall_x, 1.55, zc), Vector3(0.1, 1.85, 2.55), Color("3e4642"), 0.62)
	_visual(Vector3(wall_x + 0.1, 2.62, zc), Vector3(0.28, 0.62, 1.7), Color("2c3330"), 0.48)
	_visual(Vector3(wall_x + 0.2, 2.62, zc), Vector3(0.06, 0.4, 1.28), Color("101412"), 0.95)
	var slat_z := zc - 0.52
	while slat_z <= zc + 0.52:
		_visual(Vector3(wall_x + 0.24, 2.62, slat_z), Vector3(0.03, 0.4, 0.035), Color("9aa39e"), 0.4)
		slat_z += 0.16
	_cyl(Vector3(wall_x + 0.02, 4.35, zc), 0.16, 3.15, Color("6d7672"), 0.38, Vector3.ZERO)
	_cyl(Vector3(wall_x + 0.02, 5.9, zc), 0.26, 0.08, Color("8a8070"), 0.32, Vector3.ZERO)
	var hose := Color("e7b23a")
	var band := Color("242220")
	var drop := Vector3(-26.2, 0.72, 11.6)
	_mailer_land = drop
	_mailer_path = PackedVector3Array()
	_mailer_path.append(Vector3(wall_x + 0.02, 5.55, zc))
	_mailer_path.append(Vector3(-26.2, 5.35, zc))
	_mailer_path.append(Vector3(-26.2, 5.15, drop.z))
	_mailer_path.append(Vector3(-26.2, 3.5, drop.z))
	_mailer_path.append(Vector3(-26.2, 2.35, drop.z))
	for i in range(1, _mailer_path.size()):
		var fat: bool = i % 2 == 0
		_tube_seg(_mailer_path[i - 1], _mailer_path[i], 0.2 if fat else 0.13, band if fat else hose)
	var mouth: Vector3 = _mailer_path[_mailer_path.size() - 1]
	_cyl(mouth, 0.22, 0.1, Color("c4a15a"), 0.32, Vector3(90, 0, 0))
	_checker(Vector2(drop.x, drop.z), 8, 0.2)
	_mailer_meshes.clear()
	for i in 4:
		var bz := zc - 0.63 + float(i) * 0.42
		_visual(Vector3(-29.38, 1.42, bz), Vector3(0.05, 0.34, 0.34), Color("2c2624"), 0.55)
		var btn := MeshInstance3D.new()
		var cyl := CylinderMesh.new()
		cyl.top_radius = 0.12
		cyl.bottom_radius = 0.12
		cyl.height = 0.08
		cyl.radial_segments = 16
		btn.mesh = cyl
		btn.position = Vector3(-29.3, 1.42, bz)
		btn.rotation_degrees = Vector3(0, 0, 90)
		btn.material_override = _finish(Game.roll_color(i), 0.38, Game.roll_color(i), 0.4)
		add_child(btn)
		_mailer_meshes.append(btn)
	var order := Label3D.new()
	order.text = "ORDER"
	order.font_size = 42
	order.pixel_size = 0.0045
	order.position = Vector3(-29.22, 1.95, zc)
	order.rotation_degrees = Vector3(0, 90, 0)
	order.modulate = Color("e6dcc8")
	order.outline_size = 8
	order.outline_modulate = Color(0, 0, 0, 0.75)
	order.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	add_child(order)
	_zone("Mailer", Vector3(-28.15, 1.45, zc), Vector3(2.0, 2.3, 2.7))


func _checker(center: Vector2, tiles: int, tile: float) -> void:
	var span := tile * float(tiles)
	var origin := center - Vector2(span, span) * 0.5
	for x in tiles:
		for z in tiles:
			var dark: bool = (x + z) % 2 == 0
			var color := Color("2a2e2c") if dark else Color("e7e1d4")
			var pos := Vector3(origin.x + (float(x) + 0.5) * tile, 0.525, origin.y + (float(z) + 0.5) * tile)
			_visual(pos, Vector3(tile * 0.94, 0.012, tile * 0.94), color, 0.82)
	_visual(Vector3(center.x, 0.53, center.y), Vector3(span + 0.08, 0.016, 0.06), Color("e7a15a"), 0.55)
	_visual(Vector3(center.x, 0.53, center.y), Vector3(0.06, 0.016, span + 0.08), Color("e7a15a"), 0.55)


func _mailer_kind() -> int:
	if cam == null:
		return -1
	var from: Vector3 = cam.global_position
	var dir: Vector3 = -cam.global_transform.basis.z
	var best := -1
	var best_lat := 0.22
	for i in _mailer_meshes.size():
		var to_btn: Vector3 = _mailer_meshes[i].global_position - from
		var along: float = dir.dot(to_btn)
		if along < 0.15 or along > 3.4:
			continue
		var lat: float = (to_btn - dir * along).length()
		if lat < best_lat:
			best_lat = lat
			best = i
	return best


func _press_mailer() -> void:
	if Game.tutorial == 0:
		_nag("That pipe is not on the tour.")
		return
	if _mailer_busy:
		_nag("The pipe is still dropping one.")
		return
	var kind: int = _mailer_kind()
	if kind < 0:
		_nag("Pick a color. There are four.")
		return
	_dispense(kind)


func _cart_under_mailer() -> bool:
	if Game.cart_slots() <= 0 or _cart_root == null or not _cart_root.visible:
		return false
	var cart := Vector2(_cart_root.global_position.x, _cart_root.global_position.z)
	var drop := Vector2(_mailer_land.x, _mailer_land.z)
	return cart.distance_to(drop) < 0.9


func _dispense(kind: int) -> void:
	_mailer_busy = true
	sfx.play_kind("click")
	var btn: MeshInstance3D = _mailer_meshes[kind]
	var rest: float = btn.position.x
	var poke := create_tween()
	poke.tween_property(btn, "position:x", rest - 0.04, 0.06)
	poke.tween_property(btn, "position:x", rest, 0.12)
	var roll := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	var radius: float = Game.roll_radius(kind)
	cyl.top_radius = radius
	cyl.bottom_radius = radius
	cyl.height = 0.36
	cyl.radial_segments = 16
	roll.mesh = cyl
	roll.rotation_degrees = Vector3(0, 0, 90)
	roll.material_override = _finish(Game.roll_color(kind), 0.42, Color(0, 0, 0), 0.0)
	roll.position = _mailer_path[0]
	add_child(roll)
	sfx.play_kind("whoosh", 0.85)
	if Game.tutorial == 1:
		_aim_spot(_mailer_land)
	var into_cart: bool = _cart_under_mailer() and _cart.size() < Game.cart_slots()
	var land: Vector3 = _mailer_land
	if into_cart:
		land = _cart_root.global_position + Vector3(0, 0.55, 0)
	_slide_order(roll, kind, 1, land, into_cart)


func _slide_order(roll: MeshInstance3D, kind: int, index: int, land: Vector3, into_cart: bool) -> void:
	var dest: Vector3 = land
	if index < _mailer_path.size():
		dest = _mailer_path[index]
	var step: float = roll.position.distance_to(dest)
	var tw := create_tween()
	tw.tween_property(roll, "position", dest, clampf(step / 6.5, 0.08, 0.34))
	tw.tween_callback(func() -> void:
		if index < _mailer_path.size():
			_slide_order(roll, kind, index + 1, land, into_cart)
		else:
			_finish_order(roll, kind, into_cart)
	)


func _finish_order(roll: MeshInstance3D, kind: int, into_cart: bool) -> void:
	roll.queue_free()
	_mailer_busy = false
	sfx.play_kind("clunk", 0.85)
	var caught: bool = into_cart and _cart_under_mailer() and _cart.size() < Game.cart_slots()
	if caught:
		_cart.append({
			"stage": 1,
			"kind": kind,
			"popped": 0,
			"missed": 0,
			"errand": 0.0,
		})
		_sync_cart()
		return
	if into_cart:
		_nag("The cart moved. Or it is full. Four is the whole trick.")
	_spawn_ordered(kind)


func _spawn_ordered(kind: int) -> void:
	var body := RigidBody3D.new()
	body.add_to_group("loose_roll")
	body.collision_layer = 8
	body.collision_mask = 9
	body.mass = 0.45
	body.linear_damp = 0.6
	body.angular_damp = 0.8
	body.set_meta("stage", 1)
	body.set_meta("kind", kind)
	body.set_meta("popped", 0)
	body.set_meta("missed", 0)
	body.set_meta("errand", 0.0)
	var radius: float = Game.roll_radius(kind)
	var cyl := CylinderMesh.new()
	cyl.top_radius = radius
	cyl.bottom_radius = radius
	cyl.height = 0.36
	cyl.radial_segments = 16
	var mesh := MeshInstance3D.new()
	mesh.mesh = cyl
	mesh.material_override = _finish(Game.roll_color(kind), 0.42, Color(0, 0, 0), 0.0)
	body.add_child(mesh)
	var shape := CylinderShape3D.new()
	shape.radius = radius
	shape.height = 0.36
	var col := CollisionShape3D.new()
	col.shape = shape
	body.add_child(col)
	body.position = _mailer_land + Vector3(0, 0.15, 0)
	body.rotation = Vector3(0.0, 0.0, PI * 0.5)
	add_child(body)
	body.linear_velocity = Vector3.DOWN * 0.4


func _build_closet() -> void:
	var door_x: float = -29.34
	var door_z: float = -7.6
	var slab := Color("4a4036")
	_box(Vector3(door_x, 1.12, door_z), Vector3(0.08, 1.24, 0.96), slab, 0.58)
	_box(Vector3(door_x, 2.34, door_z), Vector3(0.08, 0.64, 0.96), slab, 0.58)
	_box(Vector3(door_x, 1.88, door_z - 0.355), Vector3(0.08, 0.28, 0.25), slab, 0.58)
	_box(Vector3(door_x, 1.88, door_z + 0.355), Vector3(0.08, 0.28, 0.25), slab, 0.58)
	_visual(Vector3(door_x - 0.12, 1.88, door_z), Vector3(0.06, 0.26, 0.42), Color("070605"), 0.95)
	var title := Label3D.new()
	title.text = "JANITOR'S CLOSET"
	title.font_size = 42
	title.pixel_size = 0.0032
	title.position = Vector3(door_x + 0.07, 2.46, door_z)
	title.rotation_degrees = Vector3(0, 90, 0)
	title.modulate = Color("e6dcc8")
	title.outline_size = 8
	title.outline_modulate = Color(0, 0, 0, 0.8)
	title.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	add_child(title)
	_slot_eyes = Node3D.new()
	_slot_eyes.position = Vector3(door_x + 0.01, 1.88, door_z)
	add_child(_slot_eyes)
	var face := MeshInstance3D.new()
	var skull := BoxMesh.new()
	skull.size = Vector3(0.02, 0.16, 0.22)
	face.mesh = skull
	face.position = Vector3(-0.03, 0, 0)
	face.material_override = _flat_mat(Color("1a1612"))
	_slot_eyes.add_child(face)
	_slot_eye(-0.05)
	_slot_eye(0.05)
	_slot_eyes.hide()
	_slot_cover = MeshInstance3D.new()
	var lid := BoxMesh.new()
	lid.size = Vector3(0.03, 0.32, 0.5)
	_slot_cover.mesh = lid
	_slot_rest = door_z
	_slot_cover.position = Vector3(door_x + 0.08, 1.88, _slot_rest)
	_slot_cover.material_override = _finish(Color("5c5146"), 0.5, Color(0, 0, 0), 0.0)
	add_child(_slot_cover)
	_cyl(Vector3(door_x + 0.16, 0.72, door_z + 0.72), 0.16, 0.28, Color("3d4a44"), 0.7, Vector3.ZERO)
	_visual(Vector3(door_x + 0.16, 1.15, door_z + 0.72), Vector3(0.04, 0.9, 0.04), Color("6a5a48"), 0.55)
	_zone("Closet", Vector3(door_x + 0.85, 1.5, door_z), Vector3(2.4, 2.6, 2.2))


func _build_computer() -> void:
	var x := 13.5
	_box(Vector3(x, 0.78, 30.92), Vector3(1.45, 0.7, 0.7), Color("3c4744"), 0.62)
	_visual(Vector3(x, 1.16, 30.9), Vector3(1.55, 0.06, 0.78), Color("5c564c"), 0.45)
	_box(Vector3(x, 1.52, 31.2), Vector3(0.92, 0.64, 0.08), Color("1c2422"), 0.4)
	var screen := MeshInstance3D.new()
	var glass := BoxMesh.new()
	glass.size = Vector3(0.76, 0.48, 0.02)
	screen.mesh = glass
	screen.position = Vector3(x, 1.52, 31.14)
	_desk_mat = _finish(Color("1d3a32"), 0.35, Color("8dce9a"), 0.45)
	_desk_mat.emission_energy_multiplier = 0.28
	screen.material_override = _desk_mat
	add_child(screen)
	_visual(Vector3(x, 1.16, 31.16), Vector3(0.08, 0.16, 0.06), Color("2a3330"), 0.4)
	_visual(Vector3(x - 0.12, 1.22, 30.62), Vector3(0.42, 0.03, 0.16), Color("2a3330"), 0.45)
	_cyl(Vector3(x + 0.22, 1.22, 30.64), 0.035, 0.02, Color("2a3330"), 0.4, Vector3(90, 0, 0))
	_box(Vector3(x + 0.62, 0.95, 31.05), Vector3(0.22, 0.38, 0.42), Color("2c3532"), 0.55)
	_sign("COMPUTER", Vector3(x, 2.05, 30.85))
	_zone("Desk", Vector3(x, 1.35, 30.15), Vector3(1.8, 1.9, 1.2))


func _slot_eye(side: float) -> void:
	var white := MeshInstance3D.new()
	var ball := SphereMesh.new()
	ball.radius = 0.028
	ball.height = 0.056
	ball.radial_segments = 12
	ball.rings = 8
	white.mesh = ball
	white.position = Vector3(0.015, 0.0, side)
	white.material_override = _flat_mat(Color("f7f4ec"))
	_slot_eyes.add_child(white)
	var iris := MeshInstance3D.new()
	var ring := SphereMesh.new()
	ring.radius = 0.015
	ring.height = 0.03
	ring.radial_segments = 10
	ring.rings = 6
	iris.mesh = ring
	iris.position = Vector3(0.028, 0.0, side)
	iris.material_override = _flat_mat(Color("c4b06a"))
	_slot_eyes.add_child(iris)
	var pupil := MeshInstance3D.new()
	var dot := SphereMesh.new()
	dot.radius = 0.008
	dot.height = 0.016
	dot.radial_segments = 8
	dot.rings = 6
	pupil.mesh = dot
	pupil.position = Vector3(0.036, 0.0, side)
	pupil.material_override = _flat_mat(Color("100e0c"))
	_slot_eyes.add_child(pupil)


func _flat_mat(color: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.roughness = 1.0
	return mat


func _sign(text: String, pos: Vector3) -> void:
	var label := Label3D.new()
	label.text = text
	label.font_size = 72
	label.pixel_size = 0.01
	label.position = pos
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.modulate = Color("f4f1e8")
	label.outline_size = 18
	label.outline_modulate = Color(0, 0, 0, 0.85)
	add_child(label)


class ReviewFace extends Control:
	var mood: float = 0.2

	func _notification(what: int) -> void:
		if what == NOTIFICATION_RESIZED:
			queue_redraw()

	func _draw() -> void:
		var center := size * 0.5
		var radius := minf(size.x, size.y) * 0.42
		if radius < 4.0:
			return
		var face := Color("f4d7a8")
		if mood < 0.22:
			face = Color("e7b7a4")
		elif mood > 0.85:
			face = Color("f6e2a8")
		draw_circle(center, radius, face)
		draw_arc(center, radius, 0.0, TAU, 48, Color("2a2420"), 3.0, true)
		var eye_y := center.y - radius * 0.16
		var eye_dx := radius * 0.32
		draw_circle(Vector2(center.x - eye_dx, eye_y), radius * 0.08, Color("2a2420"))
		draw_circle(Vector2(center.x + eye_dx, eye_y), radius * 0.08, Color("2a2420"))
		if mood < 0.45:
			draw_line(Vector2(center.x - eye_dx - radius * 0.12, eye_y - radius * 0.16), Vector2(center.x - eye_dx + radius * 0.1, eye_y - radius * 0.08), Color("2a2420"), 3.0, true)
			draw_line(Vector2(center.x + eye_dx + radius * 0.12, eye_y - radius * 0.16), Vector2(center.x + eye_dx - radius * 0.1, eye_y - radius * 0.08), Color("2a2420"), 3.0, true)
		var mouth := Vector2(center.x, center.y + radius * 0.28)
		var ink := Color("2a2420")
		if mood < 0.28:
			draw_arc(mouth + Vector2(0, radius * 0.16), radius * 0.34, PI, TAU, 18, ink, 4.0, true)
		elif mood < 0.5:
			draw_line(mouth + Vector2(-radius * 0.34, 0), mouth + Vector2(radius * 0.34, 0), ink, 4.0, true)
		elif mood < 0.78:
			draw_arc(mouth + Vector2(0, -radius * 0.02), radius * 0.32, 0.2, PI - 0.2, 18, ink, 4.0, true)
		else:
			draw_arc(mouth + Vector2(0, -radius * 0.08), radius * 0.4, 0.15, PI - 0.15, 22, ink, 5.0, true)


class BossBust extends Control:
	func _notification(what: int) -> void:
		if what == NOTIFICATION_RESIZED:
			queue_redraw()


	func _draw() -> void:
		var c := size.x * 0.5
		var ink := Color("070807")
		var head_r := size.x * 0.2
		var head := Vector2(c, size.y * 0.3)
		draw_circle(head, head_r, ink)
		draw_colored_polygon(PackedVector2Array([
			Vector2(c - head_r * 0.92, head.y - head_r * 0.2),
			Vector2(c + head_r * 0.92, head.y - head_r * 0.2),
			Vector2(c + head_r * 0.72, head.y - head_r * 1.05),
			Vector2(c - head_r * 0.72, head.y - head_r * 1.05),
		]), ink)
		var neck := head.y + head_r * 0.72
		draw_colored_polygon(PackedVector2Array([
			Vector2(c - head_r * 0.42, neck),
			Vector2(c + head_r * 0.42, neck),
			Vector2(c + size.x * 0.46, size.y + 2.0),
			Vector2(c - size.x * 0.46, size.y + 2.0),
		]), ink)
		draw_colored_polygon(PackedVector2Array([
			Vector2(c - head_r * 0.28, neck),
			Vector2(c + head_r * 0.28, neck),
			Vector2(c, neck + head_r * 0.72),
		]), Color("1c2622"))


class BossTail extends Control:
	func _draw() -> void:
		var mid := size.y * 0.5
		draw_colored_polygon(PackedVector2Array([
			Vector2(0, mid - 8),
			Vector2(size.x, mid),
			Vector2(0, mid + 8),
		]), Color(0.07, 0.098, 0.086, 0.94))
