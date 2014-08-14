require_relative 'db-config.rb'

class GameContext
  attr_accessor :player, :result, :iteration, :finished, :script

  def initialize(player)
    @finished = true
    @iteration = 0
    @player = player
  end

  def give_item(item_name)
    give_item item_name if Items.where { name == item_name && player_id == @player }.empty?
  end

  def remove_item(item_name)
    Items.delete_where { player_id == @player && name == item_name }
    reply "you lost #{item_name}"
  end

  def move_to(room_id)
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
      if run_in == 0
        block.call
      end

      if run_in == -1
        parent.reply "-- next --"
      end
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
