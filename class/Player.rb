require 'gosu'

require_relative 'Constants'
require_relative 'ZOrder'

class Player

  attr_reader :x, :y, :lives, :score

  def initialize
    
    @image = Gosu::Image.new(Constants::STARFIGHTER_SPRITE)
    @beep = Gosu::Sample.new(Constants::BEEP_SOUND)

    @x = @y = @vel_x = @vel_y = @angle = 0.0
    @score = 0
    @lives = 5
  end

  def warp(x, y)
    @x, @y = x, y
  end

  def turn_left
    @angle -= 4.5
  end

  def turn_right
    @angle += 4.5
  end

  def accelerate
    @vel_x += Gosu::offset_x(@angle, 0.5)
    @vel_y += Gosu::offset_y(@angle, 0.5)
  end

  def reverse
    @vel_x -= Gosu::offset_x(@angle, 0.5)
    @vel_y -= Gosu::offset_y(@angle, 0.5)
  end

  def move
    @x += @vel_x
    @y += @vel_y
    @x %= Constants::WIDTH
    @y %= Constants::HEIGHT

    @vel_x *= 0.95
    @vel_y *= 0.95
  end

  def draw
    @image.draw_rot(@x, @y, 1, @angle)
  end

  def die
    @lives -= 1
  end

  def lose_star
    if @score > 0
      @score -= 10
    end
  end

  def collect_stars(stars)
    stars.reject! do |star|
      if Gosu::distance(@x, @y, star.x, star.y) < 35 then
        @score += 10
        @beep.play
        true
      else
        false
      end
    end
  end
end