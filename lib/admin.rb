require_relative 'db-config'
require 'sinatra'

class Admin < Sinatra::Base
  get '/edit/rooms' do
    haml :rooms, locals: {
      rooms: Rooms.all
    }
  end

  post '/edit/rooms/new' do
    Rooms.append name: params[:room_name], script: "reply 'you enter #{params[:room_name]}'"
    redirect to "/edit/rooms/#{params[:room_name]}"
  end

  get '/edit/rooms/:room' do |room|
    haml :room, locals: { 
      room: Rooms.where { name == room }.first, 
      verbs: Verbs.where { room_name == room }.group_by { |v| v.name }.keys
    }
  end

  post '/edit/rooms/:room' do |room|
    if params["Delete"]
      Rooms.delete_where { name == room }
      redirect to "/edit/rooms"
    else
      Rooms.update(script: params[:room_script]).where { name == room }
      redirect to "/edit/rooms/#{room}"
    end
  end

  post '/edit/rooms/:room/verbs/new' do |room|
    Verbs.append name: params[:verb_name], room_name: room, item_name: 'any'
    redirect to "/edit/rooms/#{room}/verbs/#{params[:verb_name]}"
  end

  get '/edit/rooms/:room/verbs/:verb' do |room, verb|
    # add item to verb / list items for verb

    haml :verb, locals: {
      room: room,
      verb: verb,
      items: Verbs.where { name == verb && room_name == room }
    }
  end

  post '/edit/rooms/:room/verbs/:verb' do |room, verb|
    if params["Delete"]
      Verbs.delete_where { name == verb && room_name == room }
      redirect_to "/edit/rooms/#{room}"
    else
      redirect_to "/edit/rooms/#{room}/verbs/#{verb}"
    end
  end

  post '/edit/rooms/:room/verbs/:verb/items/new' do |room, verb|
    Verbs.append(name: verb,
                 room_name: room,
                 item_name: params[:item_name],
                 script: "reply 'you #{verb} with #{params[:item_name]}'")

    redirect to "/edit/rooms/#{room}/verbs/#{verb}/items/#{params[:item_name]}"
  end

  get '/edit/rooms/:room/verbs/:verb/items/:item' do |room, verb, item|
    haml :item, locals: {
      room: room,
      verb: Verbs.where { name == verb && room_name == room && item_name == item }.first
    }
  end

  post '/edit/rooms/:room/verbs/:verb/items/:item' do |room, verb, item|
    if params["Delete"]
      Verbs.delete_where { name == verb && room_name == room && item_name == item }
      redirect to "/edit/rooms/#{room}/verbs/#{verb}"
    else
      Verbs.update(script: params[:verb_script]).where { name == verb && room_name == room && item_name == item }
      redirect to "/edit/rooms/#{room}/verbs/#{verb}/items/#{item}"
    end
  end
end
