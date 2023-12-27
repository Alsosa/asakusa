extends CharacterBody2D

@onready var floorArea = $floorArea
@onready var floorAreaCollision = $floorArea/CollisionShape2D
@onready var shadow = $shadow
@onready var coyoteTimer = $Timer/coyoteTimer
@onready var timer = $Timer
@onready var zTimer = $Timer/zTimer
@onready var saveStandCollision = $saveStandArea/CollisionShape2D
@onready var frontArea = $frontArea
@onready var sprite = $sprite
@onready var camera = $sprite/playerCamera

var playerCanMove = true
var jumping = false
var falling = false
var softCheck = false
var fallSpeed = .25
var coyoteTime = true
var canBuffer = false
var activeJumping
var speed = 100
var acting = false

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_jump = false
var attacking = false
var lets_begin = 0

func _physics_process(delta):
	if (!floorArea.has_overlapping_bodies() and !floorArea.has_overlapping_areas() and jumping == false and falling == false and lets_begin > 0):
		falling = true
	if floorArea.get_overlapping_bodies().size() == 0 and floorArea.get_overlapping_areas().size() == 0 and jumping == false and falling == false:
		if coyoteTimer.time_left == 0 and falling == false and coyoteTime == true:
			printerr('empezo')
			coyoteTimer.start()
		elif coyoteTime == false:
			printerr('euuuu')
			if frontArea.get_overlapping_bodies().size() > 0:
				self.z_index = -3
			else:
				self.z_index = 0
			saveStandCollision.disabled = true
			falling = true
			softCheck = true
			zTimer.start()
			timer.start()
	elif floorArea.get_overlapping_bodies().size() > 0 or floorArea.get_overlapping_areas().size() > 0 and jumping == false:
		coyoteTime = true
	elif jumping == true:
		coyoteTime = false
	
	if falling == true:
		printerr('caiste')
		self.z_index = -3
		shadow.visible = false
		jumping = false
		self.global_position.y += fallSpeed
		fallSpeed += 10 * delta
	else:
		shadow.visible = true
	
	if playerCanMove == true and jumping == false:
		var accelleration = speed *4
		var friction = speed * 7
		velocity.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		velocity.y = (Input.get_action_strength("move_down") - Input.get_action_strength("move_up"))/2
		velocity = velocity.normalized() * SPEED
		
		if velocity != Vector2.ZERO:
			if jumping == false and attacking == false:
				sprite.play("walk")
			velocity = velocity.move_toward(velocity * speed, accelleration * delta)
		elif velocity == Vector2.ZERO and !attacking:
			velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
			sprite.play("idle")
		
		if Input.is_action_just_pressed("jump"):
			print("jump")
			is_jump = true
			_normalJump()
			is_jump = false
			
		if Input.is_action_just_pressed("Attack"):
			# _attack()
			attacking = true
			await _attack()
			attacking = false

	set_velocity(velocity)
	lets_begin += 1
	move_and_slide()
	velocity = velocity

func _attack():
	print('attack')
	sprite.play("attack")
	await sprite.animation_finished
	if sprite.animation_finished:
		attacking = false

func _normalJump():
	if falling == false:
		canBuffer = true
		speed += 120
		activeJumping = true
		jumping = true
		var tween = create_tween()
		sprite.play("jump_up")
		tween.tween_property(sprite,"position:y", -200, .6)
		if activeJumping == true:
			sprite.play("jump_down")
			tween.tween_property(sprite,"position:y", 0, .6)
			await tween.finished
			if activeJumping == true:
				jumping = false
				acting = false


func _on_coyoteTimer_timeout() -> void:
	coyoteTime = false


func _on_zTimer_timeout() -> void:
	self.z_index =-3


func _on_timer_timeout():
	camera._clearZoom()
	velocity = Vector2.ZERO
	
	playerCanMove = false
	falling = false
	acting = false
	self.z_index = 0
	saveStandCollision.disabled = false
	await get_tree().create_timer(.2).timeout
	playerCanMove = true
	softCheck = false
	fallSpeed = .25
