#サイトからFXのデータを取得して出力
#値が変化したら出力します
#gemというライブラリを使いました

require 'bundler'
Bundler.require
require 'nokogiri'
require 'open-uri'
require "./zodi-math"

url = 'https://info.finance.yahoo.co.jp/fx/detail/?code=USDJPY=FX'
a = Array.new
m10_0 = 0
m50_0 = 0
m10_1 = 0
m50_1 = 0

@money = 10000
@have = [0, 0]

def fileprint(value, str, kuchi, totalprice, money, money_)
  File.open("trade_log.txt", "w").puts("#{str}:\n#{value} * #{kuchi}口 = #{totalprice},\n#{money} => #{money_}\n")
end

def golden(ask, bid)
  puts "Ask."
  if @have[1] != 0
    dead(bid)
  end
  p @have = [ask, @money.div(ask)]
  fileprint(ask, "買い", @have[1], ask*@have[1], @money, @money-ask*@have[1])
  @money -= ask * @have[1]
end

def dead(bid)
  fileprint(bid, "売り", @have[1], bid*have[1], @money, @money+@have[1]*bid)
  puts "Bid."
  p @money += @have[1] * bid
  @have = [0, 0]
end

loop do
  doc = Nokogiri::HTML(open(url))
  bid = doc.xpath("//*[@id='USDJPY_detail_bid']").text.to_f
  ask = doc.xpath("//*[@id='USDJPY_detail_ask']").text.to_f
  a << [bid, ask]
  if a.size > 100
    a.shift
    m10_0 = m10_1
    m50_0 = m50_1
    m10_1 = m10_2
    m50_1 = m50_2
    m10_2 = mean(a[90..99])
    m50_2 = mean(a[50..99])
    if m10_0 < m50_0 && m10_1 > m50_1 && m50_0 < m50_1 && m50_1 < m50_2
      golden(ask, bid) # ホントのゴールデンクロス
    elsif m10_0 > m50_0 && m10_1 < m50_1 && m50_0 > m50_1 && m50_1 > m50_2
      dead(bid) if @have[1] != 0# ホントのデッドクロス
    elsif ask < twoSigma(a[90..99])[0] && ask < twoSigma(a[50..99])[0]
      golden(ask, bid)
    elsif bid > twoSigma(a[90..99])[1] && bid > twoSigma(a[50..99])[1]
      dead(bid) if @have[1] != 0
    end
  end
  (puts "Game Over."; break) if @money < 200 && @have[1] == 0
  sleep 3
end
