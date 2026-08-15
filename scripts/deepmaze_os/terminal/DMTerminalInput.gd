class_name DMTerminalInput
extends Object

var terminal: DMTerminal


func initialize(new_terminal: DMTerminal) -> void:
    self.terminal = new_terminal


func handle_key_event(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed:
        # Input is happening, thus the caret must be visible.
        self.terminal.caret.reset_timer()

        if (event.is_ctrl_pressed() or event.is_shift_pressed() or event.is_alt_pressed()
                or event.is_meta_pressed()):
            match event.keycode:
                Key.KEY_ENTER, Key.KEY_KP_ENTER:
                    if event.is_shift_pressed():
                        # Handle "Shift + Enter": insert a newline without submitting.
                        self.terminal.input_newline()
                        return
                Key.KEY_LEFT:
                    if event.is_ctrl_pressed() or event.is_alt_pressed():
                        _move_caret_word_left()
                        return
                Key.KEY_RIGHT:
                    if event.is_ctrl_pressed() or event.is_alt_pressed():
                        _move_caret_word_right()
                        return
                Key.KEY_C:
                    if event.is_ctrl_pressed() and event.is_shift_pressed():
                        self.terminal.copy_text()
                        return
                Key.KEY_INSERT:
                    if event.is_shift_pressed():
                        self.terminal.copy_text()
                        return
                Key.KEY_V:
                    if event.is_ctrl_pressed() and event.is_shift_pressed():
                        self.terminal.paste_text()
                        return

        # No shortcuts.
        match event.keycode:
            Key.KEY_ENTER, Key.KEY_KP_ENTER:
                self.terminal.run_command()
            Key.KEY_LEFT:
                _key_left()
            Key.KEY_RIGHT:
                _key_right()
            Key.KEY_BACKSPACE:
                _key_backspace()
            Key.KEY_DELETE:
                _key_delete()
            Key.KEY_HOME:
                _jump_to_start()
            Key.KEY_END:
                _jump_to_end()
            Key.KEY_UP:
                self.terminal.navigate_history_up()
            Key.KEY_DOWN:
                self.terminal.navigate_history_down()
            Key.KEY_TAB:
                self.terminal.invoke_autocompletion()
            _:
                _insert_printable_character(event)


func _insert_printable_character(event: InputEvent) -> void:
    if event.unicode != 0:
        self.terminal.clear_selection()
        self.terminal.insert_char_at_caret(char(event.unicode))


func _key_backspace() -> void:
    if self.terminal.caret_logical_index_x > self.terminal.get_prompt_length():
        self.terminal.clear_selection()
        self.terminal.get_active_logical_line().delete_char(self.terminal.caret_logical_index_x - 1)
        self.terminal.caret_logical_index_x -= 1
        self.terminal.recreate_display_lines_since_last_input_only()


func _key_delete() -> void:
    if self.terminal.caret_logical_index_x < self.terminal.get_active_logical_line().length():
        self.terminal.clear_selection()
        self.terminal.get_active_logical_line().delete_char(self.terminal.caret_logical_index_x)
        self.terminal.recreate_display_lines_since_last_input_only()


func _key_left() -> void:
    if self.terminal.caret_logical_index_x > self.terminal.get_prompt_length():
        self.terminal.caret_logical_index_x -= 1
        self.terminal.update_caret_position()


func _key_right() -> void:
    if self.terminal.caret_logical_index_x < self.terminal.get_active_logical_line().length():
        self.terminal.caret_logical_index_x += 1
        self.terminal.update_caret_position()


func _jump_to_start() -> void:
    self.terminal.caret_logical_index_x = self.terminal.get_prompt_length()
    self.terminal.update_caret_position()


func _jump_to_end() -> void:
    self.terminal.caret_logical_index_x = self.terminal.get_active_logical_line().length()
    self.terminal.update_caret_position()


# This uses 'is_valid_unicode_identifier()' as a Unicode-aware approximation of "word characters",
# saving us from implementing full Unicode word rules.
func _is_char_a_word_boundary(ch: String) -> bool:
    assert(ch.length() == 1, "Expected single-character string")

    var is_word_char: bool = false

    # Letters (it's required to manually exclude the underscore).
    if ch.is_valid_unicode_identifier() and ch != "_":
        is_word_char = true
    # Digits.
    elif ch >= "0" and ch <= "9":
        is_word_char = true

    return not is_word_char


func _move_caret_word_left() -> void:
    var line: DMTerminalLogicalLine = self.terminal.get_active_logical_line()
    var idx: int = self.terminal.caret_logical_index_x
    var prompt_len: int = self.terminal.get_prompt_length()

    if idx <= prompt_len:
        self.terminal.caret_logical_index_x = prompt_len
        self.terminal.update_caret_position()
        return

    # If the cursor is sitting on any word boundary characters, skip them.
    while idx > prompt_len and _is_char_a_word_boundary(line.chars[idx - 1]['char']):
        idx -= 1

    # Skip the word itself.
    while idx > prompt_len and not _is_char_a_word_boundary(line.chars[idx - 1]['char']):
        idx -= 1

    self.terminal.caret_logical_index_x = idx
    self.terminal.update_caret_position()


func _move_caret_word_right() -> void:
    var line: DMTerminalLogicalLine = self.terminal.get_active_logical_line()
    var idx: int = self.terminal.caret_logical_index_x
    var length: int = line.length()

    # If already at end, nothing to do.
    if idx >= length:
        self.terminal.caret_logical_index_x = length
        self.terminal.update_caret_position()
        return

    # If the cursor is sitting on any word boundary characters, skip them.
    while idx < length and _is_char_a_word_boundary(line.chars[idx]['char']):
        idx += 1

    # Skip the word itself.
    while idx < length and not _is_char_a_word_boundary(line.chars[idx]['char']):
        idx += 1

    self.terminal.caret_logical_index_x = idx
    self.terminal.update_caret_position()
