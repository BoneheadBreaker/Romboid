extends Node

signal host_game_pressed # the initial button to host a game was pressed, display host UI
signal join_game_pressed # the initial button to join a game was pressed, display join UI

signal health_changed(new_health)

signal start_game # the start game button in the host UI was pressed, start the "server" and tell clients to connect
signal join_game # the join game button in the join UI was pressed
