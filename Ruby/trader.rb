#サイトからFXのデータを取得して出力
#値が変化したら出力します
#gemというライブラリを使いました

require 'bundler'
Bundler.require
require 'nokogiri'
require 'open-uri'
require "./zodi-math"

url = 'https://info.finance.yahoo.co.jp/fx/detail/?code=EURJPY=FX'
a = Array.new
m10_1 = 0
m50_1 = 0
m10_2 = 0
m50_2 = 0

puts "初期投資(yen):"
@money = gets.to_i
@have = [0, 0]

def fileprint(value, str, kuchi, totalprice, money, money_)
  File.open("trade_log.txt", "a+").puts(p "[#{Time.now}]/#{str}:\n#{value} * #{kuchi}口 = #{totalprice},\n#{money} => #{money_}\n")
end

def golden(ask, bid)
  if @have[1] != 0
    dead(bid)
  end
  @have = [ask, @money.div(ask)]
  fileprint(ask, "買い", @have[1], ask*@have[1], @money, @money-ask*@have[1])
  @money -= ask * @have[1]
end

def dead(bid)
  fileprint(bid, "売り", @have[1], bid*@have[1], @money, @money+@have[1]*bid)
  @money += @have[1] * bid
  @have = [0, 0]
end

loop do
  doc = Nokogiri::HTML(open(url))
  bid = doc.xpath("//*[@id='EURJPY_detail_bid']").text.to_f
  ask = doc.xpath("//*[@id='EURJPY_detail_ask']").text.to_f
  a << ask
  if a.size > 1000
    a.shift
    m10_0 = m10_1
    m50_0 = m50_1
    m10_1 = m10_2
    m50_1 = m50_2
    m10_2 = mean(a[900..999])
    m50_2 = mean(a[500..999])
    if m10_0 < m50_0 && m10_1 > m50_1 && m50_0 < m50_1 && m50_1 < m50_2
      golden(ask, bid) # ホントのゴールデンクロス
    elsif m10_0 > m50_0 && m10_1 < m50_1 && m50_0 > m50_1 && m50_1 > m50_2
      dead(bid) if @have[1] != 0 # ホントのデッドクロス
    elsif ask < twoSigma(a[900..999])[0] && ask < twoSigma(a[500..999])[0]
      golden(ask, bid) # 長期ボリンジャーバンド2と短期ボリンジャーバンド2を下に飛び出た
    elsif bid > twoSigma(a[900..999])[1] && bid > twoSigma(a[500..999])[1]
      dead(bid) if @have[1] != 0 # 長期ボリンジャーバンド2と短期ボリンジャーバンド2を上に飛び出た
    elsif ask < oneSigma(a[90..99])[0] && ask < oneSigma(a[50..99])[0]
      golden(ask, bid) # 長期ボリンジャーバンド1と短期ボリンジャーバンド1を下に飛び出た
    elsif bid > oneSigma(a[90..99])[1] && bid > oneSigma(a[50..99])[1]
      dead(bid) if @have[1] != 0 # 長期ボリンジャーバンド1と短期ボリンジャーバンド1を上に飛び出た
    end
  end
  (puts "Game Over."; break) if @money < 200 && @have[1] == 0
  #sleep 1
end
