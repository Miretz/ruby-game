require 'gosu'

require_relative 'Constants'
require_relative 'ZOrder'
require_relative 'Player'
require_relative 'Star'
require_relative 'Explosion'
require_relative 'Bullet'

class GameWindow < Gosu::Window
  def initialize
    super Constants::WIDTH, Constants::HEIGHT
    self.caption = Constants::CAPTION

    @background_image = Gosu::Image.new(Constants::BACKGROUND, :tileable => true)
  
    @player = Player.new
    @player.warp(Constants::WIDTH / 2.0, Constants::HEIGHT / 2.0)

    @star_anim = Gosu::Image::load_tiles(Constants::STAR_SPRITE, 25, 25)
    @stars = Array.new

    @explosion_anim = Explosion.load_animation(self)
    @explosions = []
    @bullets = []

    @font = Gosu::Font.new(20)

    @music = Gosu::Song.new(Constants::MUSIC)
    @music.volume = 0.5
    @music.play(true)

    @time = Constants::TIME_LIMIT
    @last_time = Gosu::milliseconds

    @running = true

  end

  def update

    if not @running
      return
    end

    handleTimeLimit
    handlePlayerMove
    handleStarExplosions

    @bullets.each { |bullet| bullet.move }
    @player.collect_stars(@stars)

    generateNewStars
    removeOffscreenBullets
  end

  def removeOffscreenBullets
    @bullets.reject! do |bullet|
      if bullet.x < 0 or bullet.x > Constants::WIDTH then
        true
      elsif bullet.y < 0 or bullet.y > Constants::HEIGHT then
        true
      else
        false
      end
    end
  end

  def generateNewStars
     if rand(100) < 4 and @stars.size < 5 then
      @stars.push(Star.new(@star_anim))
    end
  end

  def handleStarExplosions
    @stars.reject! do |star|
      if star.dead? then
        @player.lose_star()
        @explosions.push(Explosion.new(@explosion_anim, star.x, star.y))
        true
      else
        false
      end
    end

    @explosions.each do |expl|
      if expl.explosion_peak? and Gosu::distance(@player.x, @player.y, expl.x, expl.y) < 65 then
        @player.die
        @explosions.push(Explosion.new(@explosion_anim, @player.x, @player.y, 25))
        @player.warp(Constants::WIDTH / 2.0, Constants::HEIGHT / 2.0)
        if @player.lives < 1
          @running = false
        end
      end
    end
    @explosions.reject!(&:done?)
    @explosions.map(&:update)
  end

  def handleTimeLimit
    if (Gosu::milliseconds - @last_time) > 1000
      @time -= 1
      @last_time = Gosu::milliseconds
    end

    if @time < 0
      @running = false
    end
  end

  def handlePlayerMove
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
  end

  def draw
  	@background_image.draw(0, 0, ZOrder::Background)
    
    if @running
      @bullets.each { |bullet| bullet.draw }
      @player.draw
  	  @stars.each { |star| star.draw }
      @explosions.map(&:draw)
      @font.draw("Score: #{@player.score}, Lives: #{@player.lives}", 10, 10, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
      @font.draw("Time: #{@time}", 720, 10, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
    else
      @font.draw("GAME OVER! Your score was #{@player.score}", 300, 300, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
      @font.draw("Press Escape to exit the game...", 300, 320, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
    end
  end

  def button_down(id)
    if id == Gosu::KbEscape
      close
    end
    if id == Gosu::KbSpace
      if @bullets.size < 10
        @bullets.push(Bullet.new(@player.x, @player.y, @player.angle))
      end
    end
  end

end

window = GameWindow.new
window.show
