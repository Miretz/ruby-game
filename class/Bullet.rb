require 'gosu'

require_relative 'Constants'
require_relative 'ZOrder'

class Bullet

  attr_reader :x, :y

  def initialize(x, y, angle)
    @image = Gosu::Image.new(Constants::BULLET_SPRITE)
    @x, @y = x, y
    @angle = angle

    2.times { move }
  end

  def move
    @x += Gosu::offset_x(@angle, Constants::BULLET_SPEED)
    @y += Gosu::offset_y(@angle, Constants::BULLET_SPEED)
  end

  def draw
    @image.draw_rot(@x, @y, ZOrder::Bullet, @angle)
  end

end