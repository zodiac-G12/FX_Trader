def sum(array)
  return array.inject(0.0){|sum, i| sum += i}
end

def mean(array)
  return sum(array) / array.size
end

def stdDiv(array)
  mean_i = mean(array)
  return Math::sqrt(array.inject(0.0){|sqSum, i| sqSum += (i - mean_i)**(2.0)} / array.size)
end

def oneSigma(array)
  inf = mean(array) - stdDiv(array)
  sup = mean(array) + stdDiv(array)
  return [inf, sup]
end

def twoSigma(array)
  inf = mean(array) - stdDiv(array)*2
  sup = mean(array) + stdDiv(array)*2
  return [inf, sup]
end
