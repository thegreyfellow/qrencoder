# TODO: Write documentation for `Qrencoder`
require "qrencode"
require "stumpy_png"
require "magickwand-crystal"
include StumpyPNG

module Qrencoder
  VERSION = "0.5.0"
  black = RGBA.from_rgb_n(0, 0, 0, 8)
  white = RGBA.from_rgb_n(255, 255, 255, 8)
  multiplicator = 50
  margin = multiplicator
  input = ARGV[0] || ""
  res = ARGV[1] || 250
  # version = ARGV[2]
  # correction_level = ARGV[3]

  qr = QRencode::QRcode.new(input, 1, QRencode::ECLevel::LOW)
  canvas_width = (qr.width.to_i * multiplicator) + margin * 2

  canvas = Canvas.new(canvas_width, canvas_width, white)

  x = margin
  qr.each_row do |row|
    y = margin
    row.each do |byte|
      if QRencode::Util.black?(byte)
        (0...multiplicator).each do |i|
          (0...multiplicator).each do |j|
            canvas[x + i, y + j] = black
          end
        end
      end
      y += multiplicator
    end
    x += multiplicator
  end

  StumpyPNG.write(canvas, "./result/#{input}.png")

  LibMagick.magickWandGenesis    # lib init
  wand = LibMagick.newMagickWand # lib init
  if LibMagick.magickReadImage(wand, "./result/#{input}.png")
    # File.delete("./result/#{input}.png")
    LibMagick.magickSampleImage wand, res, res
    LibMagick.magickWriteImage wand, "./result/#{input}.png"
    # LibMagick.magickWriteImage wand, "./result/#{input}_#{res}x#{res}.png"
  end
  LibMagick.destroyMagickWand wand # lib deinit
  LibMagick.magickWandTerminus     # lib deinit
end
