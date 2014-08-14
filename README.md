REST adventure
==============

API
---

| action         | curl                                                                  |
|----------------|-----------------------------------------------------------------------|
| new player     | curl localhost:4567/load/player-name/starting-room                    |
| load player    | curl localhost:4567/load/player-name/starting-room/initial,inventory  |
| save player    | curl localhost:4567/save/player-name                                  |
| send command   | curl localhost:4567/run/player-name/smash-pumpkin                     |
| next page of multiplage command | curl localhost:4567/next/player-name               |

Editing Interface
-----------------

There is a web interface for editing located at http://localhost:4567/edit/rooms

Scripting Language
------------------

The scripting language is ruby with a few pre-defined methods

| method               | description                                  |
|----------------------|----------------------------------------------|
| reply(message)       | add the message to the response body         |
| give_item(item_name) | gives the current player the item            |
| take_item(item_name) | removes the item from the player's inventory |
| travel_to(room_name) | travel to another room                       |
| first                | multi-page block, see example below          |

### Multi-Page Blocks

`first` begins a multi-page block with subsequent pages delimited by `then` and ending with `the_end`

    first {
      reply "This is the story all about how"
    }.then {
      reply "My life got flipped turned upside down"
    }.then {
      reply "I'd like to take a"
    }.then {
      reply "my house is on fire, gtg"
    }.the_end

This produces the output...

    This is the story all about how
    -- next --

and when /next/player-name is retreived...

    My life got flipped turned upside down
    -- next --

The last block is capped with `-- done --` instead of `-- next --`

    my house is on fire, gtg
    -- done --
