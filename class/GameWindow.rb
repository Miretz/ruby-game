require 'gosu'

require_relative 'Constants'
require_relative 'ZOrder'
require_relative 'Player'
require_relative 'Star'
require_relative 'Explosion'
require_relative 'Bullet'
require_relative 'Enemy'

class GameWindow < Gosu::Window
  
  def initialize
    super $res_width, $res_height, :fullscreen => true
    self.caption = $caption
    @background_image = Gosu::Image.new($spr_background, :tileable => true)
    @star_anim = Gosu::Image::load_tiles($spr_star, 25, 25)
    @explosion_anim = Explosion.load_animation(self)
    @font = Gosu::Font.new(20)
    @music = Gosu::Song.new($snd_music)
    @music.volume = 0.7
    @music.play(true)
    start
  end

  def start
    @player = Player.new
    @player.warp($res_width / 2.0, $res_height / 2.0)

    @enemy = Enemy.new
    @enemy.warp($res_width / 2.0, $res_height - 40)

    @stars = Array.new

    @explosions = []
    @bullets = []


    @time = $time_limit
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
    handleEnemy
    handleBullets

    @player.collectStars(@stars)

    generateNewStars
    removeOffscreenBullets
  end

  def handleEnemy
    @enemy.move(@player.x, @player.y)
    if Gosu::distance(@enemy.x, @enemy.y, @player.x, @player.y) < 60
      @explosions.push(Explosion.new(@explosion_anim, @enemy.x, @enemy.y))
      @explosions.push(Explosion.new(@explosion_anim, @player.x, @player.y))
      @enemy.die
      @player.die
      @player.warp($res_width / 2.0, $res_height / 2.0)
      if @player.lives < 1
        @running = false
      end
    end
  end

  def handleBullets
    @bullets.each do |bullet|
      bullet.move
      if Gosu::distance(@enemy.x, @enemy.y, bullet.x, bullet.y) < 60
        @explosions.push(Explosion.new(@explosion_anim, @enemy.x, @enemy.y))
        @enemy.die
        @player.killedEnemy
      end
    end
  end

  def removeOffscreenBullets
    @bullets.reject! do |bullet|
      if bullet.x < 0 or bullet.x > $res_width then
        true
      elsif bullet.y < 0 or bullet.y > $res_height then
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
        true
      else
        false
      end
    end

    @explosions.each do |expl|
      if expl.explosion_peak? and Gosu::distance(@player.x, @player.y, expl.x, expl.y) < 45 then
        @player.die
        @explosions.push(Explosion.new(@explosion_anim, @player.x, @player.y, 25))
        @player.warp($res_width / 2.0, $res_height / 2.0)
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
      @bullets.each(&:draw)
      @player.draw
      @enemy.draw
  	  @stars.each(&:draw)
      @explosions.each(&:draw)
      @font.draw("Score: #{@player.score}, Lives: #{@player.lives}", 10, 10, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
      @font.draw("Time: #{@time}", 720, 10, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
    else
      @font.draw("GAME OVER! Your score was #{@player.score}", 300, 300, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
      @font.draw("Press Enter to restart or Escape to exit the game...", 200, 320, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
      
    end
  end

  def button_down(id)
    if id == Gosu::KbEscape
      close
    end
    if id == Gosu::KbReturn
      start
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
