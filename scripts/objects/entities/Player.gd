extends CharacterBody3D


@export var GroundFriction = 0.08
@export var AirFriction = 0.01
@export var SlideFriction = 0.01
@export var CrouchSpeed = 0.3
@export var WalkSpeed = 0.8
@export var SprintMultiplier = 2.0
@export var AirMultiplier = 0.15
@export var SlideMultiplier = 0.1
@export var JumpForce = 4.0
@export var Gravity = 0.163
@export var StepSmooth = 0.2
@export var Sensitivity = 0.5
@export var Bobset = Vector2()
@export var StandHeight = 0.5
@export var CrouchHeight = -0.5

@onready var MoveSpeed = WalkSpeed
@onready var Camera : Camera3D = $CameraPivot/Camera3D

var NoClip = false

var SensitivityScale = 1.0
var Fov = 75.0
var CameraDirection = Vector2()
var Sprinting = false
var Crouching = false
var Sliding = false
var LastPos = Vector3()
var AirTime = 0.0
var CameraPosition = Vector3(0.0,0.5,-0.2)
var LastCanUnCrouch = true
var JumpBuffer = 0.0
var CameraOffset = Vector2()

signal CanUnCrouch

signal use
signal unuse
signal secondaryuse
signal secondaryunuse
signal sprint
signal unsprint
signal crouch
signal uncrouch

func _ready():
	Inventory.ItemChanged.connect(ChangeHeldItem)
	#var item = load(Global.ItemRegistry.GetValue("test_item")).duplicate()
	#Inventory.AddItem(item)
	CameraDirection = Vector2(rotation_degrees.y,Camera.rotation_degrees.x)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$Sprite3D.hide()

func _physics_process(delta):

	$CanvasLayer/Label.text = str(Vector2(velocity.x,velocity.z).length())
	if LastCanUnCrouch != $CrouchCast.is_colliding():
		if not $CrouchCast.is_colliding():
			emit_signal("CanUnCrouch")
	LastCanUnCrouch = $CrouchCast.is_colliding()
	Camera.h_offset = lerp(Camera.h_offset,Bobset.x,$AnimationPlayer.speed_scale)
	Camera.v_offset = lerp(Camera.v_offset,Bobset.y,$AnimationPlayer.speed_scale * 0.5)
	rotation.y = lerp_angle(rotation.y,deg_to_rad(CameraDirection.x),0.5) + deg_to_rad(CameraOffset.x)
	Camera.rotation.x = lerp(Camera.rotation.x,deg_to_rad(CameraDirection.y),0.5) + deg_to_rad(CameraOffset.y)
	Camera.position = lerp(Camera.position,CameraPosition,StepSmooth)
	Camera.fov = lerp(Camera.fov, Fov,0.1)
	CameraOffset = lerp(CameraOffset,Vector2(),0.2)
	$CanvasLayer/SubViewportContainer/SubViewportContainer/ItemCamera.global_transform= Camera.global_transform
	$CanvasLayer/SubViewportContainer/SubViewportContainer/ItemCamera.h_offset = Camera.h_offset
	$CanvasLayer/SubViewportContainer/SubViewportContainer/ItemCamera.v_offset = Camera.v_offset
	$CanvasLayer/SubViewportContainer/SubViewportContainer/ItemCamera.fov = Camera.fov
	$CameraPivot/Camera3D/Item.rotation.y = lerp_angle($CameraPivot/Camera3D/Item.rotation.y,0.0,0.25)
	$CameraPivot/Camera3D/Item.rotation.x = lerp_angle($CameraPivot/Camera3D/Item.rotation.x,0.0,0.25)
	var inputDir = Input.get_vector("Left","Right","Foreward","Backward")
	var rotInputDir = inputDir.rotated(deg_to_rad(-CameraDirection.x))
	
	if Input.is_action_just_pressed("Sprint"):
		Sprint()
	if Input.is_action_just_released("Sprint"):
		UnSprint()
	if Input.is_action_just_pressed("Crouch"):
		if inputDir != Vector2() and velocity.length() > 10 and is_on_floor():
			Slide()
		else:
			Crouch()
	if Input.is_action_just_released("Crouch"):
		UnCrouch()
	if Input.is_action_just_pressed("Interact"):
		if $CameraPivot/Camera3D/InteractionCast.is_colliding():
			if $CameraPivot/Camera3D/InteractionCast.get_collider().is_in_group("Interactable"):
				$CameraPivot/Camera3D/InteractionCast.get_collider().Interact(self)
	if Input.is_action_just_pressed("Use"):
		use.emit()
	if Input.is_action_just_released("Use"):
		unuse.emit()
	if Input.is_action_just_pressed("SecondaryUse"):
		secondaryuse.emit()
	if Input.is_action_just_released("SecondaryUse"):
		secondaryunuse.emit()
	if not NoClip:
		if is_on_floor():
			if AirTime >0:
				Land(AirTime)
			AirTime = 0.0
			if not Sliding:
				velocity = lerp(velocity,Vector3(0.0,velocity.y,0.0),GroundFriction)
				velocity += Vector3(rotInputDir.x,0.0,rotInputDir.y) * MoveSpeed
			else:
				velocity = lerp(velocity,Vector3(0.0,velocity.y,0.0),SlideFriction)
				velocity += Vector3(rotInputDir.x,0.0,rotInputDir.y) * MoveSpeed * SlideMultiplier
				SetFov(velocity.length() *2)
				if velocity.length() < 5:
					UnSlide()
			if inputDir.length() > 0:
				if not Sliding:
					$AnimationPlayer.speed_scale = (inputDir.length() * 0.5) - (int(Crouching) * 0.2) + (int(Sprinting) * 0.25)
					$AnimationPlayer.play("Walk")
					if Sprinting:
						SetFov(inputDir.length() *15)
				else:
					$AnimationPlayer.stop()
					Bobset = Vector2()
			else:
				$AnimationPlayer.stop(true)
				$AnimationPlayer.speed_scale = 0.1
				Bobset = Vector2()
				if Sprinting:
					SetFov(0)
			if Input.is_action_pressed("Jump"):
				if JumpBuffer <= 0.0:
					Jump()
		else:
			JumpBuffer -= delta
			if Sliding:
				UnSlide()
			AirTime += delta
			$AnimationPlayer.stop(true)
			$AnimationPlayer.speed_scale = 0.1
			Bobset.x = 0.0
			Bobset.y = velocity.y/16
			velocity = lerp(velocity,Vector3(0.0,velocity.y,0.0),AirFriction)
			velocity += Vector3(rotInputDir.x,0.0,rotInputDir.y) * MoveSpeed * AirMultiplier
		velocity.y -= Gravity

	else:
		velocity = lerp(velocity,Vector3(0.0,0.0,0.0),GroundFriction)
		var evenmorerotdir = inputDir
		velocity += evenmorerotdir
	LastPos = position
	move_and_slide()
	if is_on_floor():
		if abs(position.y - LastPos.y)>0.01:
			var dist = position.y - LastPos.y
			
			Camera.position.y -= dist
	$CanvasLayer/SubViewportContainer/SubViewportContainer/ItemCamera.global_transform= Camera.global_transform
func _input(event):
	if event is InputEventMouseMotion:
		MoveCamera(Vector2(-event.relative.x,-event.relative.y))
	elif event.is_action_pressed("Flashlight"):
		$CameraPivot/Camera3D/Flashlight.visible = !$CameraPivot/Camera3D/Flashlight.visible
func EnableNoClip():
	collision_mask = 0
	NoClip = true
func Sprint():
	if not Crouching and not Sliding:
		sprint.emit()
		MoveSpeed = WalkSpeed * SprintMultiplier
		Sprinting = true
func UnSprint():
	if not Crouching:
		unsprint.emit()
		MoveSpeed = WalkSpeed
		Sprinting = false
		SetFov(0)
func Crouch():
	crouch.emit()
	print("crouch")
	if not is_on_floor():
		position.y += 0.5
		Camera.position.y -= 0.5
	UnSprint()
	MoveSpeed = CrouchSpeed
	CameraPosition.y = CrouchHeight
	Crouching = true
	$StandShape.disabled = true
	$CrouchShape.disabled = false
	
func UnCrouch():
	
	if not is_on_floor():
		position.y -= 0.5
		Camera.position.y += 0.5

	if $CrouchCast.is_colliding():
		await CanUnCrouch
	uncrouch.emit()
	SetFov(0)
	MoveSpeed = WalkSpeed
	CameraPosition.y = StandHeight
	if Sliding:
		
		if Sprinting:
			Crouching = false
			Sliding = false
			Sprint()
	Crouching = false
	Sliding = false
	$StandShape.disabled = false
	$CrouchShape.disabled = true
func MoveCamera(vec : Vector2):
	CameraDirection.x += vec.x * Sensitivity * SensitivityScale
	CameraDirection.y += vec.y * Sensitivity * SensitivityScale
	CameraDirection.y = clamp(CameraDirection.y, -90.0,90.0)
	$CameraPivot/Camera3D/Item.rotation.y -= deg_to_rad(vec.x* Sensitivity * SensitivityScale * 0.5)
	$CameraPivot/Camera3D/Item.rotation.x -= deg_to_rad(vec.y* Sensitivity * SensitivityScale* 0.5)
func ChangeHeldItem(item:Item):
	$CameraPivot/Camera3D/ItemAnimations.play("SelectItem")
	if $CameraPivot/Camera3D/Item.get_child_count() > 0:
		for c in $CameraPivot/Camera3D/Item.get_children():
			c.queue_free()
	if item != null:
		var helditem = item.held_scene.instantiate()
		helditem.Hold(self,item)
		$CameraPivot/Camera3D/Item.add_child(helditem)
		
func Jump():
	JumpBuffer = 0.1
	velocity.y += JumpForce
	$JumpSound.play()
func Land(force):
	$LandSound.play()
	if Crouching:
		if velocity.length() > 10 and is_on_floor():
			Slide()
func Slide():
	CameraPosition.y = CrouchHeight
	Sliding = true
	$StandShape.disabled = true
	$CrouchShape.disabled = false
	$LandSound.play()
func UnSlide():
	Crouch()
	SetFov(0)
	Sliding = false


func Pickup(area):
	area.Interact(self)
	
func SetFov(fov):
	Fov = fov + 75.0
func SetMovementSpeed(speed):
	MoveSpeed = WalkSpeed * speed
