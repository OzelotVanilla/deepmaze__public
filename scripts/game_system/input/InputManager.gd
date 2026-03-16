@tool
class_name InputManager
extends Node


## The input source changed to another one.
signal input_source_changed(to: InputSource)


enum InputSource
{
    ## Cannot detect input source.
    none,
    ## From a keyboard and mouse.
    keyboard,
    ## From a controller (probably with joystick).
    controller,
    ## From a touch screen (probably mobile platform)
    touch_screen,
}


static var input_source: InputSource = InputSource.none


func _input(event: InputEvent) -> void: self.__onUnhandledInput__(event)


func __onUnhandledInput__(event: InputEvent):
    var old_input_source = InputManager.input_source

    match true:
        _ when event is InputEventKey or event is InputEventMouse:
            InputManager.input_source = InputSource.keyboard
        _ when event is InputEventJoypadButton or event is InputEventJoypadMotion:
            InputManager.input_source = InputSource.controller
        _ when event is InputEventScreenTouch:
            InputManager.input_source = InputSource.touch_screen

    if old_input_source != InputManager.input_source:
        self.input_source_changed.emit(InputManager.input_source)
