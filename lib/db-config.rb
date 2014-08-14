require_relative 'journal'

Players = Journal.new('db/players',
                      name: Journal::String,
                      room_name: Journal::String)

Items = Journal.new('db/items',
                    name: Journal::String,
                    player_name: Journal::String)

Rooms = Journal.new('db/rooms',
                    name: Journal::String,
                    script: Journal::String)

Verbs = Journal.new('db/verbs',
                    name: Journal::String,
                    item_name: Journal::String,
                    room_name: Journal::String,
                    script: Journal::String)
