extends Node

signal host_game_pressed # the initial button to host a game was pressed, display host UI
signal join_game_pressed # the initial button to join a game was pressed, display join UI

signal health_changed(new_health)

signal start_game # the start game button in the host UI was pressed, start the "server" and tell clients to connect
signal join_game # the join game button in the join UI was pressed

signal game_already_started # the client joined after the game has already started
signal back_to_menu # the client wants to go back to menu

signal back_to_lobby # the host wants to return to the lobby (for example after an odd number of players message)

signal server_disconnected # called on the client when the server disconnects
