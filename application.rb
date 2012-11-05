#!/usr/bin/env ruby

# WP8 SDK Installer
# by Maxim Kouprianov <me@kc.vc>

require 'open-uri'
require 'nokogiri'
require 'fileutils'
require_relative 'payload'

def download (url, file)
  File.open(file, "wb+") do |local_file|
    open(url, 'rb') do |remote_file|
      local_file.write(remote_file.read)
    end
  end
end

def unpack (path_to_exe)
  `dark.exe /x . #{path_to_exe}`
end

def get_payloads (xml)
  spec = Nokogiri::XML(open(xml))
  spec.remove_namespaces!

  spec.xpath('//Payload').map do |payload|
    unless payload['DownloadUrl'].nil?
      Payload.new payload['Id'], payload['FilePath'], payload['DownloadUrl']
    end
  end.compact!
end

def create_dirs (path)
  base = '.'
  path.split('\\').each do |part|
    base += '\\%s' % part
    FileUtils.mkdir base unless (File.exist? base or
                                 part.include? '.exe' or
                                 part.include? '.msi' or
                                 part.include? '.msp' or
                                 part.include? '.cab')
  end
end

def download_payloads (payloads)
  payloads.each_with_index do |payload, index|
    # puts "%s => %s" % [payload.id, payload.file]
    puts "%d/%d #{payload.file}" % [index + 1, payloads.count]
    create_dirs payload.file
    download payload.url, payload.file
  end
end

# main routine
def main
  begin
    puts 'Please, specify the original WP8 SDK Installer .exe file path.'
    puts 'Usage: wp8sdk.exe C:\\Smth\\WPexpress_full.exe'
    puts '============================================='
    puts 'Author: Maxim Kouprianov <me@kc.vc> (c) 2012'
    exit
  end if ARGV.count < 1

  unpack ARGV.shift()

  payloads = get_payloads 'UX\\manifest.xml'
  puts "Welcome to the WP8 SDK Installer!"
  puts "Got %d payloads to download" % payloads.count

  FileUtils.rm_rf 'packages'
  download_payloads (payloads)

  puts "Installation has been started"

  require_relative 'chain'
  chain(payloads)

  puts "Done! Have a nice day :3"
  system 'pause'
end

main()
