require_relative 'common.rb'
require 'uri'

class TwitterCrawler
  @agent = nil
  @query = nil
  @data_max_position = nil
  attr_accessor :data_max_position

  def initialize(query)
    agent_array =  ["Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:46.0) Gecko/20100101 Firefox/46.0","Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:46.0) Gecko/20100101 Firefox/45.0","Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:46.0) Gecko/20100101 Firefox/44.0","Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36","Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2924.87 Safari/537.36","Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36","Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2924.87 Safari/537.36","Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.75.14 (KHTML, like Gecko) Version/7.0.3 Safari/7046A194A","Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/536.25 (KHTML, like Gecko) Version/7.0.3 Safari/7046A194A","Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/536.25 (KHTML, like Gecko) Version/7.0.3 Safari/7046A194A"]
    @agent = Mechanize.new
    @agent.user_agent =  agent_array.sample
    @query = query
    @data_max_position = 'TWEET-879372310880206848-883851863191207936-BD1UO2FFu9QAAAAAAAAETAAAAAcAAAASAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
  end

  def get_dom(url)
      Nokogiri::HTML.parse(@agent.get(url).body)
  end
  
  def get＿timeline_json
    url = "https://twitter.com/i/search/timeline?f=tweets&vertical=default&q=#{URI.escape(@query)}&src=typd&include_available_features=1&include_entities=1&max_position=#{@data_max_position}&reset_error_state=false"
    @agent.get(url).body
  end
  
  def crawl
    if @data_max_position.nil?
      ori_url = "https://twitter.com/search?f=tweets&q=#{URI.escape(@query)}&src=typd"
      doc = get_dom(ori_url)
      @data_max_position = doc.css('.stream-container')[0]['data-max-position']
      parse_tweets(doc)
    else
      json  = get＿timeline_json
      @data_max_position = JSON.parse(json)['min_position']
      parse_tweets(Nokogiri::HTML.parse(JSON.parse(json)['items_html']))
    end
  end

  def parse_tweets(doc)
    tweets = []
    wrappers = doc.css(".js-stream-item")
    wrappers.each do |wrapper|
      # フルネーム
      fullname =  wrapper.css(".fullname.show-popup-with-id").text.gsub("Verified account","").gsub("認証済みアカウント","").gsub(/(\r\n|\r|\n|\f)/,"").strip
      # ユーザーネーム
      user_name = wrapper.css(".js-action-profile > .username > b").text.gsub("@","")

      # ユーザーID
      user_id = wrapper.css(".stream-item-header").children[1].attributes["data-user-id"].value
      # ツイート内容
      text = wrapper.css(".js-tweet-text-container").text.strip.gsub(/(\r\n|\r|\n|\f)/,"\u2003")
      # ツイートID
      tweet_id = wrapper.css("div.js-stream-tweet")[0].attributes["data-tweet-id"].value
      tweet_unix_time =  wrapper.css("span._timestamp")[0].attributes["data-time"].value
      tweet_date =  Time.at(tweet_unix_time.to_i)
      #puts "#{tweet_id}:#{fullname}"

      # 返信、良いね、favrorite
      reply = wrapper.css(".ProfileTweet-actionCountForAria").children[0].text.to_i
      retweet =  wrapper.css(".ProfileTweet-actionCountForAria").children[1].text.to_i
      favorite =  wrapper.css(".ProfileTweet-actionCountForAria").children[2].text.to_i

      tweets.push(:name => fullname,:user_name => user_name, :user_id => user_id, :text => text,:tweet_date => tweet_date ,:tweet_id => tweet_id,:fav => favorite,:rt => retweet,:reply => reply,:query => @query,:data_max_position => @data_max_position)
    end
    tweets
  end
end
