require 'gosu'

require_relative 'Constants'
require_relative 'ZOrder'

class Enemy

  attr_reader :x, :y, :lives, :score, :angle

  def initialize
    
    @image = Gosu::Image.new(Constants::ENEMY_SPRITE)

    @x = @y = @vel_x = @vel_y = @angle = 0.0
  end

  def warp(x, y)
    @x, @y = x, y
  end

  def move(xp, yp)
    @angle = Gosu.angle(@x, @y, xp, yp)
    @x += Gosu::offset_x(@angle, Constants::ENEMY_SPEED)
    @y += Gosu::offset_y(@angle, Constants::ENEMY_SPEED)
  end

  def die
    w = 0 + rand(Constants::WIDTH + 40)
    self.warp(w, Constants::HEIGHT + 40)
  end

  def draw
    @image.draw_rot(@x, @y, 1, @angle)
  end
  
end