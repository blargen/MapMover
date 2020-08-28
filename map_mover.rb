require 'redd'
require 'open-uri'
require 'yaml'

class MapMover
  def initialize
    reddit_config_file = File.read('reddit_config.json')
    @reddit_config = JSON.parse(reddit_config_file)
    @local_file_path = @reddit_config['local_save_path']
  end

  def create_session
    puts @reddit_config['user_agent']
    @session = Redd.it(
        user_agent: @reddit_config['user_agent'],
        client_id: @reddit_config['reddit_client_id'],
        secret: @reddit_config['secret'],
        username: @reddit_config['username'],
        password: @reddit_config['password']
    )

  end

  def retrieve_saved_maps
    title_image_hash = {}
    my_saved = @session.me.listing("saved", { limit: 100 }).to_ary
    array_without_video = reject_videos(my_saved)
    array_without_unwanted_subreddits = array_with_selected_subreddits(array_without_video)
    final_form = ensure_only_jpg_png(array_without_unwanted_subreddits)
    puts "After getting rid of the garbage you have #{final_form.count} maps to download!"
    final_form.each do |submission|
      puts "#{submission.title}: #{submission.url}"
      save_map(submission)
      unsave_map(submission)
    end
  end

  def reject_videos(submissions_list)
    submissions_list.reject!{|submission| submission.is_video}
    submissions_list
  end

  def array_with_selected_subreddits(submissions_list)
    subreddit_array = ['r/Roll20', 'r/dndmaps', 'r/battlemaps', 'r/FantasyGrounds']
    submissions_list.reject!{|submission| subreddit_array.include?(submission.subreddit_name_prefixed) == false}
    submissions_list
  end

  def ensure_only_jpg_png(submissions_list)
    puts "only"
    submissions_list.reject!{ |submission| submission.url.include?('.png') == false && submission.url.include?('jpg') == false}
    submissions_list
  end

  def create_save_path(submission)
    directory = sort_maps(submission.title)
    title = submission.title.gsub(/\W+/, '_')[0..50]
    url = submission.url
    url =~ /.(.png|.jpg)/
    file_extension = $1
    "#{@local_file_path}\\#{directory}\\#{title}#{file_extension}"
  end

  def save_map(submission)
    path = create_save_path(submission)
    if File.exists?(path)
      puts 'File already exists! Skipping!'
      return
    else
      open(path, 'wb') { |file| file << open(submission.url).read }
    end

  end

    def unsave_map(map_to_unsave)
      map_to_unsave.unsave
    end

    def sort_maps(file_title)
      sorting_hat = {
          forests_and_jungles: %w[forest jungle borreal tree grove grassland wilderness wood hollow],
          temples: %w[temple graveyard shrine cathedral church tomb altar oracle ritual sanctuary crypt dojo summon ancient aztec cthulu legend],
          taverns: %w[tavern bar inn guild],
          arenas: %w[arenas pit],
          shops: %w[shop store market bazaar emporium],
          cities: %w[cit village town garden library sewer house settlement],
          roads_and_pathways: %w[path alley street road],
          water_and_bridges: %w[bridge river crossing ford creek port dock swamp lake island isle sea ocean],
          boats_and_airships: %w[boat ship sail],
          lairs: %w[lair cave cellar mine ruin],
          camps: %w[camp tent],
          forges: %w[forge crucible],
          castles_and_forts: %w[castle keep fort manor barricade outpost tower post],
          deserts: %w[desert oasis],
          feywilds_and_underdark: %w[fey underdark],
          seasons: %w[spring summer fall autumn snow ice winter],
          mountains_and_cliff: %w[mount cliff canyon volcano crevasse],
          individual_buildings: %w[house home floor farm lodge level barracks cabin],
          statues: %w[statue colossus plinth]
      }
      sorting_hat.each do |folder, array|
        Dir.mkdir("#{@local_file_path}\\#{folder}") unless File.exists?("#{@local_file_path}\\#{folder}")
        array.each {|checker| return folder.to_s if file_title.downcase.include?(checker) }
      end
      'random'
    end

  def sort_battlemaps_directory
    battle_maps_files = Dir.entries(@local_file_path)
    battle_maps_files.delete_if {|file| file == '.' || file == '..'}
    battle_maps_files.each do |file|
      file_path = "#{@local_file_path}\\#{file}"
      next if File.directory?(file_path)
      dir = sort_maps(file)
      new_file_path = "#{@local_file_path}#{dir}\\#{file}"
      puts "New File Path = #{new_file_path}"
      next if File.exists?(new_file_path)
      FileUtils.mv(file_path, new_file_path) unless File.exists?(new_file_path)
    end
  end
end


map_mover = MapMover.new
map_mover.create_session
map_mover.retrieve_saved_maps
map_mover.sort_battlemaps_directory
#map_mover.retrieve_saved_maps
