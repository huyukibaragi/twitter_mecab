require './common.rb'
require 'natto'

nat = Natto::MeCab.new
tweets = Tweet.take(10)

tweets.each do |tweet|
  nat.parse(tweet.text) do |word|
    pp word.feature.to_s if word.feature.match(/(感動詞|形容詞)/)
  end  
end
=begin
module TFIDF #TFとかIDFとかするモジュール(名前は適当)
 extend self
 @@nat = Natto::MeCab.new
  def cnt(documents)
    word_hash = Hash.new
    terms_count = 0
    documents.each do |e|
      @@nat.parse(e) do |word|
        if /[^!-@\[-`{-~　「」]/ =~ word.surface
          if (word.feature.match(/(固有名詞|名詞,一般)/)) and (word.surface.length>1)#2文字以上の固有名詞と一般名詞のみ抽出
            word_hash[word.surface]||=0
            word_hash[word.surface]+=1
            terms_count+=1
          end
        end
      end
    end
    word_hash.each{|key,value| word_hash[key] = value.to_f / terms_count }
    return word_hash
  end
end
=end
