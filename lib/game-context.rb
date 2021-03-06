require_relative 'db-config.rb'

class GameContext
  attr_accessor :player, :result, :iteration, :finished, :script

  def initialize(player, script)
    @finished = true
    @iteration = 0
    @player = player
    @script = script
  end

  def run_script
    instance_eval @script
  end

  def give_item(item_name)
    give_item item_name if Items.where { name == item_name && player_id == @player }.empty?
  end

  def take_item(item_name)
    Items.delete_where { player_id == @player && name == item_name }
    reply "you lost #{item_name}"
  end

  def travel_to(room_id)
    Players.update(room_id: room_id).where { id == @player.id }
    room = Rooms.where { id == room_id }.first
    reply "you are now in [#{room_id}]#{room.name}"
    instance_eval room.script
  end

  def reply(message)
    @result ||= []
    @result << message
  end

  def first(&block)
    @finished = false
    MultiPage.new self, @iteration, &block
  end

  class MultiPage
    def initialize(parent, run_in, &block)
      @parent = parent
      @run_in = run_in
      block.call if run_in == 0
      parent.reply "-- next --" if run_in == -1
    end

    def then(&block)
      MultiPage.new @parent, @run_in - 1, &block
    end

    def the_end
      if @run_in == 0
        @parent.reply "-- done --"
        @parent.finished = true
      end
    end
  end
end
