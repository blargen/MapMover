require 'redd'
require 'open-uri'
require 'yaml'

class MapMover
  def create_session
    creds = YAML.load_file('creds.yaml')
    begin
    @session = Redd.it(
        user_agent: creds['user_agent'],
        client_id: creds['client_id'],
        secret: creds['secret'],
        username: creds['username'],
        password: creds['password']
    )
    rescue
      sleep 10
      puts "ahhhh!"
      create_session
    else
      puts 'nope, all good'
    end
  end

  def retrieve_saved_maps
    subreddit_array = ['r/Roll20', 'r/dndmaps', 'r/battlemaps']
    title_image_hash = {}
    my_saved = @session.me.listing("saved", { limit: 100 }).to_ary
    my_saved.each do |submission|
      next unless subreddit_array.include?(submission.subreddit_name_prefixed) && submission.is_video == false && (submission.url.include?('.jpg') || submission.url.include?('.png'))
      puts submission.title
      title_image_hash[submission.title] = submission.url
      save_map(title_image_hash)
      unsave_map(submission)
    end
  end

  def save_map(title_url_hash)
    title_url_hash.each do |title, url|
      fixed_title = title.gsub(/\W+/, '_')[0..50]
      url =~ /.(.png|.jpg)/
      open("C:\\Users\\Eben\\AppData\\Roaming\\SmiteWorks\\Fantasy Grounds\\campaigns\\Prophecy\\images\\r-battlemaps\\#{fixed_title}#{$1}", 'wb') do |file|
        file << open(url).read
      end
    end

    def unsave_map(map_to_unsave)
      map_to_unsave.unsave
    end

  end
end


map_mover = MapMover.new
map_mover.create_session
map_mover.retrieve_saved_maps
