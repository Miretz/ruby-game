require 'gosu'

require_relative 'Constants'
require_relative 'ZOrder'
require_relative 'Player'
require_relative 'Star'
require_relative 'Explosion'

class GameWindow < Gosu::Window
  def initialize
    super Constants::WIDTH, Constants::HEIGHT
    self.caption = "Gosu Space Game by Miretz"

    @background_image = Gosu::Image.new("media/Space.png", :tileable => true)
  
    @player = Player.new
    @player.warp(Constants::WIDTH / 2.0, Constants::HEIGHT / 2.0)

    @star_anim = Gosu::Image::load_tiles("media/Star.png", 25, 25)
    @stars = Array.new

    @explosion_anim = Explosion.load_animation(self)
    @explosions = []

    @font = Gosu::Font.new(20)

    @running = true

  end

  def update

    if not @running
      return
    end

    if Gosu::button_down? Gosu::KbLeft or Gosu::button_down? Gosu::GpLeft then
      @player.turn_left
    end
    if Gosu::button_down? Gosu::KbRight or Gosu::button_down? Gosu::GpRight then
      @player.turn_right
    end
    if Gosu::button_down? Gosu::KbUp or Gosu::button_down? Gosu::GpButton0 then
      @player.accelerate
    end
    if Gosu::button_down? Gosu::KbDown or Gosu::button_down? Gosu::GpButton1 then
      @player.reverse
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

    @explosions.each do |expl|
      if expl.explosion_peak? and Gosu::distance(@player.x, @player.y, expl.x, expl.y) < 55 then
        @player.die
        @explosions.push(Explosion.new(@explosion_anim, @player.x, @player.y, 33))
        @player.warp(Constants::WIDTH / 2.0, Constants::HEIGHT / 2.0)
        if @player.lives < 1
          @running = false
        end
      end
    end
    @explosions.reject!(&:done?)
    @explosions.map(&:update)
  end

  def draw
  	@background_image.draw(0, 0, ZOrder::Background)
    
    if @running
      @player.draw
  	  @stars.each { |star| star.draw }
      @explosions.map(&:draw)
      @font.draw("Score: #{@player.score}, Lives: #{@player.lives}", 10, 10, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
    else
      @font.draw("GAME OVER! Your score was #{@player.score}", 300, 300, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
      @font.draw("Press Escape to exit the game...", 300, 320, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
    end
  end

  def button_down(id)
    if id == Gosu::KbEscape
      close
    end
  end

end

window = GameWindow.new
window.show
