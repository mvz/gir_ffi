$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'gir_ffi'

GirFFI.setup :Clutter
GirFFI.setup :GdkPixbuf

class PhotoWall < Clutter::Stage
  STAGE_WIDTH  = 800
  STAGE_HEIGHT = 600

  THUMBNAIL_SIZE = 200
  ROW_COUNT      = STAGE_HEIGHT / THUMBNAIL_SIZE
  COLUMN_COUNT   = STAGE_WIDTH / THUMBNAIL_SIZE

  FOCUS_DEPTH   = 100.0
  UNFOCUS_DEPTH = 0.0

  def self.create_for path
    stage = PhotoWall.new

    stage.instance_eval do
      @path = path

      @bricks = []
      @images = Dir["#{@path}/**/*.{jpg,png}"]
      @focus = nil

      set_title "A PhotoWall"
      set_size STAGE_WIDTH, STAGE_HEIGHT

      ROW_COUNT.times do |row|
        COLUMN_COUNT.times do |column|
          break unless @images[row*COLUMN_COUNT + column]
          puts "Adding #{@images[row*COLUMN_COUNT + column]}"
          brick = LittleBrick.new_from_file(@images[row*COLUMN_COUNT + column], row, column)
          add_actor brick
          @bricks << brick
        end
      end

      show_all
    end

    GObject.signal_connect(stage, "destroy") { Clutter.main_quit }

    stage
  end

  class LittleBrick < Clutter::Actor
    attr_accessor :row, :col

    def self.new_from_file fname, row = 0, col = 0
      brick = new
      image = Clutter::Image.new
      picture = GdkPixbuf::Pixbuf.new_from_file fname
      image.set_data(picture.get_pixels,
                     picture.has_alpha ? :rgba_8888 : :rgb_888,
                     picture.width,
                     picture.height,
                     picture.rowstride)
      brick.set_content image

      brick.instance_eval do
        @row = row
        @col = col

        set_size THUMBNAIL_SIZE, THUMBNAIL_SIZE
        set_position col * THUMBNAIL_SIZE, row * THUMBNAIL_SIZE
        set_reactive true
      end

      @@focus = nil

      GObject.signal_connect brick, "button-press-event" do |a_brick|
        if @@focus
          @@focus.unfocus
        else
          brick.focus
        end
      end

      brick
    end

    def focus
      @@focus = self
      set_position 0, 0
      set_size STAGE_WIDTH, STAGE_HEIGHT
      raise_top
    end

    def unfocus
      set_position @col * THUMBNAIL_SIZE, @row * THUMBNAIL_SIZE
      set_size THUMBNAIL_SIZE, THUMBNAIL_SIZE
      @@focus = nil
    end
  end
end

Clutter.init []

picture_directory = GLib.get_user_special_dir :directory_pictures

PhotoWall.create_for picture_directory

Clutter.main
