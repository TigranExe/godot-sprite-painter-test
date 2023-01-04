@tool
extends "res://addons/sprite_painter/src/editing_tools/tool_brush.gd"

@export var tilt_preview_scale := 4.0

var shrink := 1.0

var tilt : Vector2
var tilt_length : float


func _ready():
	super._ready()
	add_property("Edge Shrink", shrink * 100,
		func (x): shrink = x * 0.01,
		TOOL_PROP_INT,
		[0, 100]
	)


func mouse_moved(event : InputEventMouseMotion):
	tilt = Vector2(event.tilt.x, -event.tilt.y)
	var joy_tilt = Vector2(Input.get_joy_axis(0, JOY_AXIS_LEFT_X), Input.get_joy_axis(0, JOY_AXIS_LEFT_Y))
	if joy_tilt != Vector2.ZERO:
		tilt = joy_tilt

	tilt_length = tilt.length() * 0.707214
	var tilt_basis = Basis.from_euler(Vector3(tilt.x * PI * 0.499, tilt.y * PI * 0.499, 0.0))
	var normal = Vector3.BACK * tilt_basis
	drawing_color1 = Color(normal.y * 0.5 + 0.5, normal.x * 0.5 + 0.5, normal.z, 1.0)

	super.mouse_moved(event)


func get_new_pixel(on_image, color, stroke_start, stroke_end, cur_pos, radius, solid_radius):
	return super.get_new_pixel(
		on_image, on_image.get_pixelv(cur_pos).blend(Color(color, color.a)), stroke_start, stroke_end, cur_pos,
		radius * (1.0 - tilt_length * shrink), solid_radius * (1.0 - tilt_length * shrink)
	)


func draw_preview(image_view : CanvasItem, mouse_position : Vector2i):
	var circle_center = Vector2(mouse_position + Vector2i.ONE) - brush_offset
	image_view.draw_line(
		circle_center,
		circle_center + tilt * brushsize * tilt_preview_scale,
		crosshair_color,
		1.01
	)
	super.draw_preview(image_view, mouse_position)
