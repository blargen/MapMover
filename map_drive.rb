require 'google_drive'
require 'json'

class MapDrive

  def initialize
    reddit_config_file = File.read('reddit_config.json')
    @reddit_config = JSON.parse(reddit_config_file)
    @local_file_path = @reddit_config['local_save_path']
  end

  def retrieve_collections
    root_folder = @session.root_collection
    battlemaps_collection = @session.root_collection.subcollection_by_title('Dungeons_and_Dragons').subcollection_by_title('maps').subcollection_by_title('battlemaps')
    puts battlemaps_collection.properties
    puts battlemaps_collection.drive_id
    puts battlemaps_collection.id
    puts battlemaps_collection.parents
    puts battlemaps_collection.subcollections[0]
    battlemaps_collection.files.each do |sub|
      puts sub.class
    end
    taverns = battlemaps_collection.subcollection_by_title('taverns_and_bars')
    puts "Taverns: #{taverns.inspect}"
    puts battlemaps_collection.inspect
    puts battlemaps_collection.files.count
  end

  def retrieve_file_list
    @session.files
  end

  def create_session
    @session = GoogleDrive::Session.from_config("config.json")
  end

  def check_for_file(file_title)
    files = retrieve_file_list
    files.each do |file|
      return true if file.title.include?(file_title)
    end
    puts 'File not found on google drive!'
    false
  end

  def retrieve_local_file_list
    puts "retrieving"
    files = Dir.entries(@local_file_path)
    files.delete_if {|file| file == '.' || file == '..'}
    files
  end

  def upload_files(local_file_array)

    local_file_array.each do |file|
      if check_for_file(file)
        puts "#{file} already exists on Google Drive: Skip this bitch!"
        next
      else
        puts "Uploading #{@local_file_path}\\blargen.txt to Google Drive! Enjoy your new map!"
        @session.upload_from_file("#{@local_file_path}\\#{file}", "#{file}", {convert: false})
        add_to_correct_folder(file)
      end
    end
  end

  def add_to_correct_folder(file)
    battlemaps_collection = @session.collection_by_id('1QqPlGfjRgf48jmmaHivtyC_5wryHkwOf')
    case file.downcase
    when file.include?('tavern')
    end
    battlemaps_collection.add(file)
  end

end
map_drive = MapDrive.new
map_drive.create_session
#local_file_array = map_drive.retrieve_local_file_list
map_drive.retrieve_collections
#map_drive.upload_files(local_file_array)