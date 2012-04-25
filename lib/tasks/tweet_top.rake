require File.expand_path("../../../config/environment", __FILE__)
require 'oa_model/oa_model'

namespace :oa do

  desc "It discovers the top twitters for each topic"
  task :top_tweeters => :environment do

    Twitter.configure do |config|
      config.consumer_key       = "pYP2rAdkY5Ztw1aipZk5bA"
      config.consumer_secret    = "SwInlV5Lr2cjsoLmvKZnEz2yzAqlMf1iPhgVePVHM"
      config.oauth_token        = "16823784-JE4THd1pFHB2M2D3kL9ekr5WBLyk6dGkJ2lA2g54"
      config.oauth_token_secret = "CBs1lUK1lTW2VNWNbVuEdwIXAtWnoOeje1qfY9a3E"
    end

    @min_allowed_tags = 3
    @max_allowed_tags = 4
    @sleep_time       = 3600/600
    @target_twitters  = 15

    Topic.establish_connection(:adapter => "postgresql", :host => "localhost", :username => "postgres", :password => "postgres", :database => "opinionage")

    begin

      topic_id = ask("start from topic id? (not twitted users will be deleted!")

      if !topic_id.empty?
        p "destroying rows belonging to the topic id: #{topic_id}"
        ContactedUsers.destroy_all("topic_id = #{topic_id} and twitted = 'f'")
      end

      topic_id = 0 if topic_id.empty?
      Topic.where("id >= #{topic_id}").each do |topic|
        @twitters_cache = { }
        topic_node      = Neo4j::Node.load topic.graph_id

        tags = topic_node.outgoing(:tag).inject([]) do |memo, tag_node|
          memo << tag_node[:name]
        end

        if tags.count >= @min_allowed_tags

          sorted_twitters = []
          max_range_tags  = [tags.count, @max_allowed_tags].min
          (@min_allowed_tags..max_range_tags).each do |i|
            tags.combination(max_range_tags-(i-@min_allowed_tags)).each do |tag_combination|
              search_twitters(tag_combination.to_a.join(" ")).each do |twitter|
                sorted_twitters = build_sorted_hash_array sorted_twitters, twitter, :followers
              end
            end
          end

          contacted_twitters = 0
          sorted_twitters.each do |twitter|

            if ContactedUsers.find_by_twitter_name(twitter[:display_name]).nil?

              contacted_user = ContactedUsers.new :twitter_id   => twitter[:twitter_id],
                                                  :twitter_name => twitter[:display_name],
                                                  :followers    => twitter[:followers],
                                                  :search_key   => twitter[:search_string],
                                                  :tweet        => twitter[:tweet],
                                                  :tweet_id     => twitter[:tweet_id],
                                                  :topic_id     => topic.id,
                                                  :topic_title  => topic.question_text,
                                                  :twitted      => false

              contacted_user.save!
              contacted_twitters += 1

            end

            break if contacted_twitters >= @target_twitters

          end

        end

      end

    rescue Exception => e
      puts "#{e.message}"
    end

  end

  desc "It tweets the top tweeters"
  task :invite_twitters => :environment do

    results = ContactedUsers.where("twitted = 'f'")
    (0..results.count-1).to_a.shuffle.each do |index|

      user      = results[index]
      url       = "http://www.opinionage.com/t/#{user.topic_id}"
      avail_len = 140 - "@#{user.twitter_name}  #{url.length}".length

      text       = user.topic_title[0, [avail_len, user.topic_title.length].min]
      tweet_text = "@#{user.twitter_name} #{text} #{url}"
      p tweet_text + " (#{tweet_text.length})"

      user.twitted       = true
      user.mention_tweet = tweet_text
      user.save

    end

  end

  def ask message
    print message +":"
    STDIN.gets.chomp
  end

  def slow_twitter_api
    sleep @sleep_time
  end

  def search_twitters search_string
    slow_twitter_api
    tweets = Twitter.search("#{search_string}")
    p "searching tweets containing: #{search_string} => #{tweets.count}"
    tweets.inject([]) do |memo, tweet|
      user_information = user_info(tweet.from_user)
      memo << { :display_name  => tweet.from_user,
                :followers     => user_information.followers,
                :twitter_id    => user_information.id,
                :tweet         => tweet.text,
                :tweet_id      => tweet.id,
                :search_string => search_string }
    end
  end

  def tweet tweet_text
    slow_twitter_api
#    Twitter.update( tweet_text )
  end

  def user_info display_name

    if @twitters_cache.has_key? display_name
      twitter_user = @twitters_cache[display_name]
    else
      slow_twitter_api
      twitter_user                  = Twitter.user(display_name)
      @twitters_cache[display_name] = twitter_user
    end

    twitter_user
  end

  def build_sorted_hash_array sorted_array, element, attribute, max_size= nil
    index = 0
    while index < sorted_array.size
      break if sorted_array[index][attribute].nil? || sorted_array[index][attribute] < element[attribute]
      index += 1
    end

    ret_array = sorted_array.insert(index, element)
    ret_array = ret_array.take(max_size) if max_size

    ret_array
  end

end