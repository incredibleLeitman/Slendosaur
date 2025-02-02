"""
Class: Logger
	A general purpose Logger for use with GDScript.

Copyright:
	Copyright 2018 SpockerDotNet LLC

Remarks:
	The Logger will send a request to an
	Appender to output a log message.

See Also:
	Appender, Layout, Message
"""

extends Node

const CATEGORY_GENERAL = "general"
const CATEGORY_WARN = "warn"
const CATEGORY_ERROR = "error"
const CATEGORY_SYSTEM = "system"
const CATEGORY_INPUT = "input"
const CATEGORY_GUI = "gui"
const CATEGORY_SIGNAL = "signal"
const CATEGORY_BEHAVIOR = "behavior"
const CATEGORY_FSM = "fsm"
const CATEGORY_NETWORK = "network"
const CATEGORY_PHYSICS = "physics"
const CATEGORY_GAME = "game"
const CATEGORY_AUDIO = "audio"
const CATEGORY_CAMERA = "camera"

const LOG_LEVEL_ALL = 999
const LOG_LEVEL_FINE = 700
const LOG_LEVEL_TRACE = 600
const LOG_LEVEL_DEBUG = 500
const LOG_LEVEL_INFO = 400
const LOG_LEVEL_WARN = 200
const LOG_LEVEL_ERROR = 100
const LOG_LEVEL_FATAL = 001
const LOG_LEVEL_NONE = 000


const LOG_FORMAT_SIMPLE = 20
const LOG_FORMAT_DEFAULT = 30
const LOG_FORMAT_MORE = 90
const LOG_FORMAT_FULL = 99
const LOG_FORMAT_NONE = -1


var logger_level = LOG_LEVEL_ALL setget set_logger_level
var logger_line = 0
var logger_appenders = []
var refresh_appenders = false
var version = "3.1-R3"

#	PUBLIC


func add_appender(appender):
	if appender is Appender:
		logger_appenders.append(appender)

	refresh_appenders = true
	return appender


func set_logger_level(level):

	logger_level = level
	print("Logging Level is %s" % [_get_level_name(logger_level)])
	print(" ")

	for appender in logger_appenders:
		appender.logger_level = level


func set_logger_format(format):
	for appender in logger_appenders:
		appender.logger_format = format


static func get_level_name(level):
	match level:
		LOG_LEVEL_ALL:
			return "ALL"
		LOG_LEVEL_FINE:
			return "FINE"
		LOG_LEVEL_TRACE:
			return "TRACE"
		LOG_LEVEL_DEBUG:
			return "DEBUG"
		LOG_LEVEL_INFO:
			return "INFO"
		LOG_LEVEL_WARN:
			return "WARN"
		LOG_LEVEL_ERROR:
			return "ERROR"
		LOG_LEVEL_FATAL:
			return "FATAL"
		_:
			return "NONE"

"""
Function: log
	Log a Message at the Info level.

Remarks:
	This is the Default level of logging.
"""
func info(message, category=CATEGORY_GENERAL):
	_append(LOG_LEVEL_INFO, message, category)


"""
Function: fine
	Log a Message at a Fine level.
"""
func fine(message, category=CATEGORY_GENERAL):
	_append(LOG_LEVEL_FINE, message, category)


"""
Function: trace
	Log a Message at a Trace level.
"""
func trace(message, category=CATEGORY_GENERAL):
	_append(LOG_LEVEL_TRACE, message, category)


"""
Function: debug
	Log a Message at a Trace level.
"""
func debug(message, category=CATEGORY_GENERAL):
	_append(LOG_LEVEL_DEBUG, message, category)


"""
Function: warn
	Log a Warning Message.
"""
func warn(message, category=CATEGORY_GENERAL):
	_append(LOG_LEVEL_WARN, message, category)


"""
Function: error
	Log an Error Message.
"""
func error(message, category=CATEGORY_GENERAL):
	_append(LOG_LEVEL_ERROR, message, category)


"""
Function: fatal
	Log an Error Message.
"""
func fatal(message, category=CATEGORY_GENERAL):
	_append(LOG_LEVEL_FATAL, message, category)

"""
Function: get_formatted_date
	Returns a Date in a Formatted form for an Event.
"""
func get_formatted_date(date):
	return _get_formatted_date(date)


#	PRIVATE


func _get_formatted_date(date):
	return "%02d/%02d/%02d %02d:%02d:%02d" % [date.month, date.day, date.year, date.hour, date.minute, date.second]


func _get_format_name(format):
	match format:
		LOG_FORMAT_FULL:
			return "FULL"
		LOG_FORMAT_MORE:
			return "MORE"
		LOG_FORMAT_DEFAULT:
			return "DEFAULT"
		LOG_FORMAT_SIMPLE:
			return "SIMPLE"
		_:
			return "NONE"


func _get_level_name(level):
	match level:
		LOG_LEVEL_ALL:
			return "ALL"
		LOG_LEVEL_TRACE:
			return "FINE"
		LOG_LEVEL_FINE:
			return "TRACE"
		LOG_LEVEL_DEBUG:
			return "DEBUG"
		LOG_LEVEL_INFO:
			return "INFO"
		LOG_LEVEL_WARN:
			return "WARN"
		LOG_LEVEL_ERROR:
			return "ERROR"
		LOG_LEVEL_FATAL:
			return "FATAL"
		_:
			return "NONE"


func _get_format_by_name(format_name):
	match format_name.to_lower():
		"full":
			return LOG_FORMAT_FULL
		"more":
			return LOG_FORMAT_MORE
		"default":
			return LOG_FORMAT_DEFAULT
		"simple":
			return LOG_FORMAT_SIMPLE
		_:
			return LOG_FORMAT_NONE

func _get_logger_level_by_name(logger_level_name):
	match logger_level_name.to_lower():
		"all": 		return LOG_LEVEL_ALL
		"fine":		return LOG_LEVEL_FINE
		"trace":	return LOG_LEVEL_TRACE
		"debug":	return LOG_LEVEL_DEBUG
		"info":		return LOG_LEVEL_INFO
		"warn":		return LOG_LEVEL_WARN
		"error":	return LOG_LEVEL_ERROR
		"fatal":	return LOG_LEVEL_FATAL
		"none":		return LOG_LEVEL_NONE



func _append(level, message = "", category = CATEGORY_GENERAL):

	if logger_appenders.size() <= 0:
		var ca = ConsoleAppender.new()
		ca.logger_level = logger_level
		logger_appenders.append(ca)

	if refresh_appenders:
		refresh_appenders = false
		for appender in logger_appenders:
			appender.start()
			appender.append_raw(appender.layout.getHeader())

	logger_line += 1

	for appender in logger_appenders:
		if level <= appender.logger_level:
			appender.append(Message.new(level, message, category, logger_line))


func _exit_tree():
	for appender in logger_appenders:
		appender.append_raw(appender.layout.getFooter())
		appender.stop()

	logger_appenders.clear()


func _init():
	print(" ")
	print("godot-stuff Logger")
	print("https://gitlab.com/godot-stuff/gs-logger")
	print("Copyright 2018-2019, SpockerDotNet LLC")
	print("Version " + version)
	print(" ")

	if ProjectSettings.has_setting("logger/level"):
		set_logger_level(_get_logger_level_by_name(ProjectSettings.get_setting("logger/level")))
