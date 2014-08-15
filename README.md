REST adventure
==============

Hi, its a RESTful adventure you can go on.

Basically this is for game engines to interface with locally (unless you wanna
make a game that people play via `curl`, that's cool too).

Set Up
------

Its a sinatra server so you can just run it with `ruby rest-adventure.rb`.

I wrote a really rudamentary flat-file database for it so that you wouldn't
have to mess around with building native extensions for database adapters, but
it's kind of crap so if things get laggy let me know and I'll figure out how to
optimize it a little.

To use it just prop up the server on the same machine as the game client, then
connect to it through your native language's REST client and local loopback.
Any time the player interacts with something adventure game-ish, like a Broken
Elevator, or a Toilet Bowl Scrubber, send related verbs like fix-elevator or
get-scrubber to the story server and use its responses to inform your animation
and GUI state changes.

API
---

| action         | curl                                                                  |
|----------------|-----------------------------------------------------------------------|
| new player     | curl localhost:4567/load/player-name/starting-room                    |
| load player    | curl localhost:4567/load/player-name/starting-room/initial,inventory  |
| save player    | curl localhost:4567/save/player-name                                  |
| send command   | curl localhost:4567/run/player-name/smash-pumpkin                     |
| next page of multi-page response | curl localhost:4567/next/player-name                |

Editing Interface
-----------------

There is a web interface for editing located at http://localhost:4567/edit/rooms

Room and verb scripts are edited through here and all changes are live. You
shouldn't have to modify the source code at all.

'Any' Verbs
-----------

Verbs that act on the 'any' item, or operate in the 'any' room aren't bound to
an item or a specific location but will be overridden by more specific verbs.

Scripting Language
------------------

The scripting language is ruby with a few pre-defined methods

| method               | description                                  |
|----------------------|----------------------------------------------|
| reply(message)       | add the message to the response body         |
| give_item(item_name) | gives the current player the item            |
| take_item(item_name) | removes the item from the player's inventory |
| travel_to(room_name) | travel to another room                       |
| first                | multi-page response, see example below       |

### Multi-Page Responses

`first` begins a multi-page response with subsequent pages delimited by `then` and ending with `the_end`

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

The last page is capped with `-- done --` instead of `-- next --`

    my house is on fire, gtg
    -- done --

In Progress
-----------

 - I'm worn out, I didn't test room entry scripts, but I at least know that
   they don't run on game load when they should, I'm not sure if they run after
   `travel_to` or not.
 - Database scrubbing really needs to be implemented. It fills up with trash
   sooooo fast.
