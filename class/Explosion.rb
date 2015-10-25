require_relative 'Constants'

class Explosion
  attr_reader :x, :y

  def self.load_animation(window)
    Gosu::Image.load_tiles(window, Constants::EXPLOSION_SPRITE, 128, 128, false)
  end

  def initialize(animation, x, y, start_frame = 0)
    @animation = animation
    @x, @y = x, y
    @current_frame = start_frame

    num = 1 + rand(2)
    Gosu::Sample.new("#{Constants::MEDIA_DIR}/Explosion#{num}.wav").play
  end

  def update
    @current_frame += 1 if frame_expired?
  end

  def draw
    return if done?
    image = current_frame
    image.draw(
      @x - image.width / 2.0,
      @y - image.height / 1.5,
      0)
  end

  def done?
    @done ||= @current_frame == @animation.size
  end

  def explosion_peak?
    @current_frame == 24
  end

  private

  def current_frame
    @animation[@current_frame % @animation.size]
  end

  def frame_expired?
    now = Gosu.milliseconds
    @last_frame ||= now
    if(now - @last_frame) > Constants::EXPLOSION_DELAY
      @last_frame = now
    end
  end
end