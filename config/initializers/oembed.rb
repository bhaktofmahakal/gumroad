require "json"
require "oembed/formatter/json/backends/jsongem"
OEmbed::Formatter::JSON.backend = OEmbed::Formatter::JSON::Backends::JSONGem
