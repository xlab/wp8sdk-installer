# WP8 SDK Installer
# by Maxim Kouprianov <me@kc.vc>

class Payload
  attr_reader :id
  attr_reader :file
  attr_reader :url

  def initialize (id, file, url)
    @id = id
    @file = file
    @url = url
  end
end
