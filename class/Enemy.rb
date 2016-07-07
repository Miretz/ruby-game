require 'gosu'

require_relative 'Constants'
require_relative 'ZOrder'

class Enemy

  attr_reader :x, :y, :lives, :score, :angle

  @@speed = 3

  def initialize
    @image = Gosu::Image.new($spr_enemy)
    @x = @y = @vel_x = @vel_y = @angle = 0.0
  end

  def warp(x, y)
    @x, @y = x, y
  end

  def move(xp, yp)
    @angle = Gosu.angle(@x, @y, xp, yp)
    @x += Gosu::offset_x(@angle, @@speed)
    @y += Gosu::offset_y(@angle, @@speed)
  end

  def die
    w = 0 + rand($res_width + 40)
    self.warp(w, $res_height + 40)
  end

  def draw
    @image.draw_rot(@x, @y, 1, @angle)
  end
  
end
