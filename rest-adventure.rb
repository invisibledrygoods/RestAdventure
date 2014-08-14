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
  verbs = Verbs.where { room_name == player.room_name && name == verb_name }
  verb = verbs.find { |v| inventory.find { |i| i.name == v.item_name } }
  verb ||= verbs.find { |v| v.name == "none" }

  return 404 unless verb

  context = GameContext.new(player)

  $contexts[player_name] = context
  context.script = verb.script
  context.instance_eval context.script
  puts "context finished: #{context.finished}"
  $contexts[player_name] = nil if context.finished

  puts "context saved as #{$contexts[player_name]}"

  return context.result.join "\r\n"
end

get '/next/:player' do |player_name|
  context = $contexts[player_name]

  return 404 unless context

  context.result = nil
  context.iteration += 1
  context.instance_eval context.script
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

  Items.delete_where { 
    puts "#{player_name} == #{player}"
    player_name == player 
  }

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
