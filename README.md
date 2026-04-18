# Romboid

###### Work in progress fast pace skill based video game
###### My first multiplayer project in godot (outside of tests)

###### Check back later!

## Quick Todo Checklist (MVP + a few extras)

- [x] Make bullets
    - [x] Spawn bullets for all clients on click
    - [x] Make bullets do damage (server changes damage to prevent cheating)

- [ ] Add players to teams
    - [x] prevent starting the match if their is an odd number of players (may changed in future)
    - [x] Sort the even number of players into a random team (may allow host picking teams in future)
    - [ ] Add each player in a team to a group
    - [ ] make spawnpoints teamed (example only team 1 can spawn at these spawn points)

- [ ] Lose/Win conditions
    - [ ] Make a condition where a team loses
    - [ ] Make a condition where a team wins
    - [ ] Make a tie condition (optional)

# Extra checklist (features I want to add but are not very important right now)

- [ ] Make clients handle server disconnects better
    - [ ] Make it so when the host quits (or the server disconnects) the clients dont just "break"

- [ ] Polish!!!!
    - [ ] Add animations
    - [ ] Add effects
    - [ ] Improve UI
    - [ ] etc

- [ ] Add game assets for everything
    - [ ] Add player assets
    - [ ] Actual maps
    - [ ] etc

- [ ] Improve map system to allow multiple maps, and load maps in a way that custom maps can be made
    - [ ] Add support for different maps
    - [ ] Make an ingame map editor (hopefully)
    - [ ] Make maps beable to be customly imported (maybe host imports it and can send map to clients, or all clients need the map locally etc)
