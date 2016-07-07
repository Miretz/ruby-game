require 'gosu'

require_relative 'Constants'
require_relative 'ZOrder'

class Bullet

  attr_reader :x, :y
  
  @@speed = 11

  def initialize(x, y, angle)
    @image = Gosu::Image.new($spr_bullet)
    @x, @y = x, y
    @angle = angle
    
    # move forward a bit, so it appears in the front of the ship
    2.times { move } 
  end

  def move
    @x += Gosu::offset_x(@angle, @@speed)
    @y += Gosu::offset_y(@angle, @@speed)
  end

  def draw
    @image.draw_rot(@x, @y, ZOrder::Bullet, @angle)
  end

end
