extends Node

onready var Tabs: TabContainer = $GUI/Tabs

onready var UsernameLine: LineEdit = $GUI/Tabs/Login/UsernameLine
onready var PasswordLine: LineEdit = $GUI/Tabs/Login/PasswordLine
onready var LoginButton: Button = $GUI/Tabs/Login/LoginButton
onready var LoginInfo: Label = $GUI/Tabs/Login/LoginInfo
onready var JustRegisteredInfo: Label = $GUI/Tabs/Login/RegistrationInfo

onready var EmailLine: LineEdit = $GUI/Tabs/Registration/EmailLine
onready var NewPasswordLine: LineEdit = $GUI/Tabs/Registration/PasswordLine
onready var FirstNameLine: LineEdit = $GUI/Tabs/Registration/FirstNameLine
onready var SecondNameLine: LineEdit = $GUI/Tabs/Registration/SecondNameLine
onready var RegistrationButton: Button = $GUI/Tabs/Registration/RegistrationButton
onready var RegistrationInfo: Label = $GUI/Tabs/Registration/RegistrationInfo

func _ready():
	network.connect("register_request_ok", self, "_on_register_request_ok")
	
	network.connect("login_request_error", self, "_on_login_request_error")
	network.connect("register_request_error", self, "_on_register_request_error")

func _on_LoginButton_pressed():
	var username: String = UsernameLine.text
	var password: String = PasswordLine.text
	
	if username.length() == 0 || password.length() == 0:
		return
	
	UsernameLine.editable = false
	PasswordLine.editable = false
	LoginButton.disabled = true
	
	network.login(username, password)

func _on_RegistrationButton_pressed():
	var email: String = EmailLine.text
	var password: String = NewPasswordLine.text
	var first_name: String = FirstNameLine.text
	var second_name: String = SecondNameLine.text
	
	if email.length() == 0 || password.length() == 0 || first_name.length() == 0 || second_name.length() == 0:
		return
	
	EmailLine.editable = false
	NewPasswordLine.editable = false
	FirstNameLine.editable = false
	SecondNameLine.editable = false
	RegistrationButton.disabled = true
	
	network.register(email, password, first_name, second_name)

func _on_register_request_ok(response: Dictionary):
	JustRegisteredInfo.text = "Account successfully created! You may now log in."
	Tabs.current_tab = 0

func _on_login_request_error(error_message: String):
	UsernameLine.editable = true
	PasswordLine.editable = true
	LoginButton.disabled = false
	LoginInfo.text = error_message

func _on_register_request_error(error_message: String):
	EmailLine.editable = true
	NewPasswordLine.editable = true
	FirstNameLine.editable = true
	SecondNameLine.editable = true
	RegistrationButton.disabled = false
	RegistrationInfo.text = error_message
