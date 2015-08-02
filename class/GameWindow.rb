require 'gosu'

require_relative 'Constants'
require_relative 'ZOrder'
require_relative 'Player'
require_relative 'Star'
require_relative 'Explosion'

class GameWindow < Gosu::Window
  def initialize
    super Constants::WIDTH, Constants::HEIGHT
    self.caption = "Gosu Tutorial Game"

    @background_image = Gosu::Image.new("media/Space.png", :tileable => true)
  
    @player = Player.new
    @player.warp(640, 480)

    @star_anim = Gosu::Image::load_tiles("media/Star.png", 25, 25)
    @stars = Array.new

    @explosion_anim = Explosion.load_animation(self)
    @explosions = []

    @font = Gosu::Font.new(20)
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

    @stars.reject! do |star|
      if star.dead? then
        @player.lose_star()
        @explosions.push(Explosion.new(@explosion_anim, star.x, star.y))
        true
      else
        false
      end
    end

    @player.collect_stars(@stars)
    if rand(100) < 4 and @stars.size < 5 then
      @stars.push(Star.new(@star_anim))
    end

    @explosions.reject!(&:done?)
    @explosions.map(&:update)
  end

  def draw
  	@background_image.draw(0, 0, ZOrder::Background)
    @player.draw
  	@stars.each { |star| star.draw }
    @explosions.map(&:draw)
    @font.draw("Score: #{@player.score}", 10, 10, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
  end

  def button_down(id)
    if id == Gosu::KbEscape
      close
    end
  end

end

window = GameWindow.new
window.show
