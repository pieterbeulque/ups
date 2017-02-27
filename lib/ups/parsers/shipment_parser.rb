require 'base64'
require 'tempfile'

module UPS
  module Parsers
    class ShipmentParser < ParserBase
      attr_accessor :graphic_image,
                    :graphic_extension,
                    :html_image,
                    :tracking_number

      def value(value)
        parse_graphic_image(value)
        parse_html_image(value)
        parse_tracking_number(value)
        parse_graphic_extension(value)
        super
      end

      def parse_graphic_image(value)
        return unless switch_active?(:GraphicImage)
        self.graphic_image = base64_to_file(value.as_s)
      end

      def parse_html_image(value)
        return unless switch_active?(:HTMLImage)
        self.html_image = base64_to_file(value.as_s)
      end

      def parse_tracking_number(value)
        return unless switch_active?(:ShipmentIdentificationNumber)
        self.tracking_number = value.as_s
      end

      def parse_graphic_extension(value)
        return unless switch_active?(:LabelImageFormat, :Code)
        self.graphic_extension = ".#{value.as_s.downcase}"
      end

      def base64_to_file(contents)
        file_config = ['ups', graphic_extension]
        Tempfile.new(file_config, nil, encoding: 'ascii-8bit').tap do |file|
          begin
            file.write Base64.decode64(contents)
          ensure
            file.rewind
          end
        end
      end
    end
  end
end
