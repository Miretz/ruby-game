require 'gosu'

require_relative 'Player.rb'

class GameWindow < Gosu::Window
  def initialize
    super 640, 480
    self.caption = "Gosu Tutorial Game"

    @background_image = Gosu::Image.new("media/Space.png", :tileable => true)
  
    @player = Player.new
    @player.warp(320, 240)

  end

  def update
    if Gosu::button_down? Gosu::KbLeft or Gosu::button_down? Gosu::GpLeft then
      @player.turn_left
    end
    if Gosu::button_down? Gosu::KbRight or Gosu::button_down? Gosu::GpRight then
      @player.turn_right
    end
    if Gosu::button_down? Gosu::KbUp or Gosu::button_down? Gosu::GpButton0 then
      @player.accelerate
    end
    @player.move
  end

  def draw
  	@player.draw
  	@background_image.draw(0, 0, 0)
  end

  def button_down(id)
    if id == Gosu::KbEscape
      close
    end
  end

end

window = GameWindow.new
window.show
