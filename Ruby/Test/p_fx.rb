#サイトからFXのデータを取得して出力
#値が変化したら出力します
#gemというライブラリを使いました

#require 'bundler'
#Bundler.require
require 'nokogiri'
require 'open-uri'
require "./zodi-math"

url = 'https://info.finance.yahoo.co.jp/fx/detail/?code=USDJPY=FX'

money = 150000
pay = money/10
f50 = 0
f10 = 0
f50ten = []
f10ten = []
fif = []
flag = 0
save = 0
time = 0
p Time.now

def up(a)
  flag = 0
  (a.size-1).times{|i| flag = 1 if a[i] > a[i+1]}
  if flag == 1
    return 1
  else
    return 0
  end
end

def down(a)
  flag = 0
  (a.size-1).times{|i| flag = 1 if a[i] < a[i+1]}
  if flag == 1
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
  pay = money/10
  if fif.size >= 50 
    f10 = fif[40..49].inject(:+)/10.0 
    f50 = fif.inject(:+)/50.0
    f10ten << f10
    f50ten << f50
    t = Time.now
    if time != 0 && (t.hour==time[0] && t.min-time[1] > 14 || t.hour!=time[0] && t.min+60-time[1] > 14)  && flag != 0
      if flag == 1
        if save < value
          puts "you win!"
          p t
          p value
          p money += pay*2
        else
          puts "you lose..."
          p t
          p value
          p money -= pay
        end
      else
        if save > value
          puts "you win!"
          p t
          p value
          p money += pay*2
        else
          puts "you lose..."
          p t
          p value
          p money -= pay
        end
      end
      flag = 0
    end
    break if money < 1000
    if f10 > f50 && f10ten.size >= 10 && up(f10ten) && up(f50ten) && flag == 0
      puts "buy up"
      p t = Time.now
      p save = value
      p f10ten
      p f50ten
      time = [t.hour,t.min]
      flag = 1
    elsif f10 < f50 && f10ten.size >= 10 && down(f10ten) && down(f50ten) && flag == 0
      puts "buy down"
      p t = Time.now
      p save = value
      p f10ten
      p f50ten
      time = [t.hour,t.min]
      flag = 2
    end
    if f10ten.size >= 10
      f10ten.shift
      f50ten.shift
    end
    fif.shift
  end
  sleep 59
end
