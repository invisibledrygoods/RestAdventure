require './lib/db-config'
require './lib/game-context'
require './lib/admin'
require 'sinatra'
require 'continuation'

$contexts = {}

use Admin
enable :run

get '/run/:player/:verb' do |player_name, verb_name|
  player = Players.where { name == player_name }.first
  inventory = Items.where { player_name == player.name }
  verbs = Verbs.where { name == verb_name && (room_name == 'any' || room_name == player.room_name) }

  # sort into [specific item/specific room, any item/specific room, specific item/any room, any item/any room]
  verbs.sort_by! { |v| (v.room_name == 'any' ? 2 : 0) + (v.item_name == 'any' ? 1 : 0) }

  # then find the first (aka most specific) verb to run
  verb = verbs.find { |v| v.item_name == 'any' || inventory.find { |i| i.name == v.item_name } }

  return 404 unless verb

  context = GameContext.new player, verb.script
  context.run_script
  $contexts[player_name] = context.finished ? nil : context

  return context.result.join "\r\n"
end

get '/next/:player' do |player_name|
  context = $contexts[player_name]

  return 404 unless context

  context.result = nil
  context.iteration += 1
  context.run_script
  $contexts[player_name] = nil if context.finished

  return context.result.join "\r\n"
end

get '/load/:player/:room' do |player, room|
  Players.delete_where { name == player }
  Players.append name: player, room_name: room

  "you find yourself standing naked in #{room}"
end

get '/load/:player/:room/:inventory' do |player, room, inventory|
  Players.delete_where { name == player }
  Players.append name: player, room_name: room

  Items.delete_where { player_name == player }

  inventory.split(',').each do |item|
    Items.append name: item, player_name: player
  end

  "you reclaim [#{inventory}] from your little coffin and return to #{room}"
end

get '/save/:player' do |player|
  room = Players.where { name == player }.first.room_name
  items = Items.where { player_name == player }
  "you store [#{player}/#{room}/#{items.map(&:name).join(',')}] in your little coffin"
end
