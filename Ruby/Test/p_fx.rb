#サイトからFXのデータを取得して出力
#値が変化したら出力します
#gemというライブラリを使いました

#require 'bundler'
#Bundler.require
require 'nokogiri'
require 'open-uri'
require "./zodi-math"

url = 'https://info.finance.yahoo.co.jp/fx/detail/?code=USDJPY=FX'

money = 10000
f50 = 0
f10 = 0
f50ten = []
f10ten = []
fif = []
flag = 0
save = 0
time = 0

def up(a)
  if (a.size-1).times{|i| break if a[i] > a[i+1]} != nil
    return 1
  else
    return 0
  end
end

def down(a)
  if (a.size-1).times{|i| break if a[i] < a[i+1]} != nil
    return 1
  else
    return 0
  end
end

loop do
  doc = Nokogiri::HTML(open(url))
  bid = doc.xpath("//*[@id='USDJPY_detail_bid']").text.to_f
  ask = doc.xpath("//*[@id='USDJPY_detail_ask']").text.to_f
  value = (bid+ask)/2
  #puts "Bid(売値):#{bid}"
  #puts "Ask(買値):#{ask}"
  fif << value
  if fif.size >= 50 
    f10 = fif[40..49].inject(:+)/10.0 
    f50 = fif.inject(:+)/50.0
    f10ten << f10
    f50ten << f50
    if time != 0 && Time.now - time < 30 && flag != 0
      if flag == 1
        if save < value
          puts "you win!"
          p money += 10000
        else
          puts "you lose..."
          p money -= 10000
        end
      else
        if save > value
          puts "you win!"
          p money += 10000
        else
          puts "you lose..."
          p money -= 10000
        end
      end
      flag = 0
    end
    break if money < 10000
    if f10 > f50 && up(f10ten) && up(f50ten) && flag == 0
      puts "buy up"
      p Time.now
      save = value
      time = Time.now+15*60
      flag = 1
    elsif f10 < f50 && down(f10ten) && down(f50ten) && flag == 0
      puts "buy down"
      p Time.now
      save = value
      time = Time.now+15*60
      flag = 2
    end
    if f10ten.size >= 10
      f10ten.shift
      f50ten.shift
    end
    fif.shift
  end
  sleep 55
end
