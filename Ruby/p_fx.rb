#サイトからFXのデータを取得して出力
#値が変化したら出力します
#gemというライブラリを使いました

#require 'bundler'
#Bundler.require
require 'nokogiri'
require 'open-uri'
require "./zodi-math"

url = 'https://info.finance.yahoo.co.jp/fx/detail/?code=USDJPY=FX'

f50 = 0
f10 = 0

loop do
  doc = Nokogiri::HTML(open(url))
  bid = doc.xpath("//*[@id='USDJPY_detail_bid']").text.to_f
  ask = doc.xpath("//*[@id='USDJPY_detail_ask']").text.to_f
  puts "Bid(売値):#{bid}"
  puts "Ask(買値):#{ask}"
  sleep 1
  end
end
