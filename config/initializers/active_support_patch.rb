module ActiveSupport
  module JSON
    module Encoding
      class << self
        def escape(string)
          string = string.dup.force_encoding(::Encoding::BINARY) if string.respond_to?(:force_encoding)
          json = string.
            gsub(escape_regex) { |s| ESCAPED_CHARS[s] }.
            gsub(/([\xC2-\xDF][\x80-\xBF]|
                   [\xE0-\xEF][\x80-\xBF]{2}|
                   [\xF0-\xF7][\x80-\xBF]{3})+/nx) { |s|
            s.unpack("U*").pack("n*").unpack("H*")[0].gsub(/.{4}/n, '\\\\u\&')
          }
          %("#{json}")
        end
      end
    end
  end
end
