extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	Engine.max_fps = 155
	init()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var sun = $Sun
	var p1 = $"Planet"
	var p2 = $"Planet2"
	var p3 = $"Planet3"
	var ship = $"Ship"
	var text = $Camera2D/TextEdit
	var line = $"Planet Tracker"
	var line2 = $"Planet Tracker2"
	var line3 = $"Planet Tracker3"
	
	var planetList = [sun, p1, p2, ship, p3]
	
	ship = shipMovement(ship)


	solarGravity(planetList)
	
	#p2.set_meta("momentum", p2.get_meta("momentum") + gravity(p1,p2))
	#p2.position += p2.get_meta("momentum")


	text.set_text("Ship Momentum = " + str(ship.get_meta("momentum")))
	
	ship.set_meta("momentum", ship.get_meta("momentum") + ship.get_meta("acc"))
	ship.set_meta("acc", Vector2(0,0))
	
	#ship.set_meta("momentum", ship.get_meta("momentum") + (-gravity(ship, p1) + (-gravity(ship, p2))))
	#ship.position += ship.get_meta("momentum")
	
	#ship.position += ship.get_meta("momentum") + gravity(ship, p1) + gravity(ship, p2)
	planetTracking(p3)
	tracking(ship)
	queue_redraw()
	thrustVectoring()
	collisionCheck()
	trackOrbit(line, p1)
	trackOrbit(line2, p2)
	trackOrbit(line3, p3)
	pass
	
func solarGravity(planetList):
	for x in planetList:
		if(x.get_meta("gravity") == true):
			var totalForce = Vector2(0, 0)
			for y in planetList:
				if(x != y):
					totalForce -=  gravity(x, y)
			x.set_meta("momentum", x.get_meta("momentum") + totalForce)
			x.position += x.get_meta("momentum")
	pass

func coursePredicition(object):
	
	pass
	

func degreeCorrection(degree):
	degree = fmod(degree, 360.0)
	if(degree < 0):
		degree += 360
	return degree
	
func findQuadrant(degree):
	degree = abs(degree)
	if degree >= 0.0 and degree < 90.0:
		return Vector2(1, -1)
	elif degree >= 90.0 and degree < 180.0:
		return Vector2(1, 1)
	elif degree >= 180.0 and degree < 270.0:
		return Vector2(-1, 1)
	else:
		return Vector2(-1, -1)
	#else:
	#	print("Error: Invalid degree value", degree)
	
func findAngle(degree, quad):
	if((quad == Vector2(-1, -1) || quad == Vector2(1,1))):
		degree = fmod(degree, 90.0)
		var x = 90-degree
		#returns a thrust vector for rockets in a 2d space
		return(Vector2(x*.01, (90-x)*.01))
	else:
		degree = fmod(degree, 90.0)
		var x = 90-degree
		#returns a thrust vector for rockets in a 2d space
		return(Vector2((90-x)*.01, x*.01))
	
func shipMovement(ship):
	#var ship = $Ship
	var mainThrust = .01
	var sideThrust = .005
	var rearThrust = .005
	var rotationSpeed = 1
	var zoomFactor = Vector2(0.005, 0.005)
	var cam = $Camera2D
	var text2 = $Camera2D/TextEdit2
	var text3 = $Camera2D/TextEdit3
	#print(rad_to_deg(ship.rotation))
	ship.rotation = deg_to_rad(degreeCorrection(rad_to_deg(ship.rotation)))

	#print("Quadrant: ", findQuadrant(rad_to_deg(ship.rotation)))
	#print("Angle: ", findAngle(rad_to_deg(ship.rotation), findQuadrant(rad_to_deg(ship.rotation))))

	text2.set_text("X Thrust: " + str(findAngle(rad_to_deg(ship.rotation), findQuadrant(rad_to_deg(ship.rotation)))) + " Y Thrust: " + str(findAngle(rad_to_deg(ship.rotation), findQuadrant(rad_to_deg(ship.rotation)))))
	#text3.set_text(str(Engine.get_frames_per_second())) #FPS script

	#print(rad_to_deg(ship.rotation))
	if Input.is_action_pressed("ui_left"):
		ship.rotation -=  deg_to_rad(rotationSpeed)
	if Input.is_action_pressed("ui_right"):
		ship.rotation +=  deg_to_rad(rotationSpeed)
	if Input.is_action_pressed("ui_up"):
		var test = findAngle(rad_to_deg(ship.rotation), findQuadrant(rad_to_deg(ship.rotation)))* mainThrust
		ship.set_meta("acc", findQuadrant(rad_to_deg(ship.rotation)) * test)
	if Input.is_action_pressed("ui_s"):
		interia(ship.get_meta("momentum"), rearThrust)
	if Input.is_action_pressed("ui_w"):
		var test = findAngle(rad_to_deg(ship.rotation), findQuadrant(rad_to_deg(ship.rotation)))
		ship.position =  ship.position + 500*findQuadrant(rad_to_deg(ship.rotation)) * test
	if Input.is_action_pressed("ui_q"):
		ship.set_meta("acc", findQuadrant(degreeCorrection(rad_to_deg(ship.rotation)-90)) * findAngle(degreeCorrection(rad_to_deg(ship.rotation)-90), findQuadrant(degreeCorrection(rad_to_deg(ship.rotation)-90)))* sideThrust)
	if Input.is_action_pressed("ui_e"):
		ship.set_meta("acc", findQuadrant(degreeCorrection(rad_to_deg(ship.rotation)+90)) * findAngle(degreeCorrection(rad_to_deg(ship.rotation)+90), findQuadrant(degreeCorrection(rad_to_deg(ship.rotation)+90)))* sideThrust)
	if Input.is_action_pressed("ui_down"):
		ship.set_meta("acc", findQuadrant(degreeCorrection(rad_to_deg(ship.rotation)+180)) * findAngle(degreeCorrection(rad_to_deg(ship.rotation)+180), findQuadrant(degreeCorrection(rad_to_deg(ship.rotation)+180)))* rearThrust)
	if Input.is_action_pressed("ui_page_up"):
		cam.zoom -= zoomFactor
	if Input.is_action_pressed("ui_page_down"):
		cam.zoom += zoomFactor
		
		#ship.set_meta("acc", Vector2(0 , 0))
		#ship.set_meta("momentum", Vector2(0 , 0))
		#ship.set_meta("acc", findQuadrant(rad_to_deg(ship.rotation)) * findAngle(rad_to_deg(ship.rotation))* -mainThrust)
	return ship

func _draw():
	var ship = $"Ship"
	var sun  = $Sun
	var planet = $Planet
	draw_line(ship.position, sun.position, Color(255,0,0), 1)
	draw_line(ship.position, planet.position, Color(255,0,0), 1)
	#draw_line(ship.position, Vector2(ship.position.x, 0) + Vector2(-ship.get_meta("momentum").x, -ship.position.y)/3 ,Color(0,120,255), 5)
	#draw_line(ship.position, Vector2(0, ship.position.y) + Vector2(-ship.position.x, -ship.get_meta("momentum").y)/3 ,Color(120,0,255), 5)
	draw_line(ship.position, ship.position + ship.get_meta("momentum")*10, Color(0, 120, 255), 5)

func thrustVectoring():
	var ship = $"Ship"
	var sun  = $Sun
	#var xVec = $"Ship/xThrust Vector"
	#var yVec = $"Ship/yThrust Vector"

	#xVec.rotation = -(ship.rotation)
	#yVec.rotation = -(ship.rotation)
"""
func interia(ship, rearThrust, matching): #use: 0 = for ship, use: 1 = for matching velocity
	if(ship.get_meta("momentum").x > 0):
		ship.set_meta("momentum", Vector2(ship.get_meta("momentum").x, ship.get_meta("momentum").y) + Vector2(-rearThrust, 0))
	if(ship.get_meta("momentum").y > 0):
		ship.set_meta("momentum", Vector2(ship.get_meta("momentum").x, ship.get_meta("momentum").y) + Vector2(0, -rearThrust))
	if(ship.get_meta("momentum").x < 0):
		ship.set_meta("momentum", Vector2(ship.get_meta("momentum").x, ship.get_meta("momentum").y) + Vector2(rearThrust, 0))
	if(ship.get_meta("momentum").y < 0):
		ship.set_meta("momentum", Vector2(ship.get_meta("momentum").x, ship.get_meta("momentum").y) + Vector2(0, rearThrust))
	pass
"""

func interia(object, rearThrust): #use: 0 = for ship, use: 1 = for matching velocity
	var ship = $Ship
	if(ship.get_meta("momentum").x > object.x):
		ship.set_meta("momentum", Vector2(ship.get_meta("momentum").x, ship.get_meta("momentum").y) + Vector2(-rearThrust, 0))
	if(ship.get_meta("momentum").y > object.y):
		ship.set_meta("momentum", Vector2(ship.get_meta("momentum").x, ship.get_meta("momentum").y) + Vector2(0, -rearThrust))
	if(ship.get_meta("momentum").x < object.x):
		ship.set_meta("momentum", Vector2(ship.get_meta("momentum").x, ship.get_meta("momentum").y) + Vector2(rearThrust, 0))
	if(ship.get_meta("momentum").y < object.y):
		ship.set_meta("momentum", Vector2(ship.get_meta("momentum").x, ship.get_meta("momentum").y) + Vector2(0, rearThrust))
	pass

func tracking(object):
	var cam = $Camera2D
	cam.position = object.position
	pass

func predictMovement(solarListCopy, i):
	print()


func planetTracking(object): #Method for tracking planets Vec's Different
	var ship = $Ship
	var text = $Camera2D/TextEdit3
	var calc = object.get_meta("momentum")#- ship.get_meta("momentum"
	text.set_text(str(calc))
	if Input.is_action_pressed("ui_a"):
		interia(calc, .1)
	pass

func gravity(p1, p2): 
	#var G = 0.0000066743
	var G = .1
	var numerator = G * p1.get_meta("Mass") * p2.get_meta("Mass")
	var rSquared = p1.position.distance_squared_to(p2.position)
	if rSquared == 0:
		return Vector2.ZERO
	var gForce = numerator / rSquared
	#Calculate unit vector (direction) between the two points
	var direction = (p2.position - p1.position).normalized()
	# Calculate gravitational force components along x and y
	var forceX = gForce * direction.x
	var forceY = gForce * direction.y
	return Vector2(-forceX, -forceY)

func trackOrbit(line, planet):
	line.add_point(planet.position, -1)
	if(len(line.get_points()) > 10000):
		line.remove_point(0)

func collisionCheck():
	var sunCollider = $Sun/Area2D
	var shipCollider = $Ship/Area2D
	
	#if(sunCollider.area_entered):


func init():
	
	pass
	
