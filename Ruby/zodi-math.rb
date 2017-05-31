def mean(*array)
  return array.inject(0.0){|sum, i| sum += i} / array.size
end

def stdDiv(*array)
  return Math::sqrt(array.inject(0.0){|sqSum, i| sqSum += i**(2.0)} / array.size)
end

def oneSigma(*array)
  inf = mean(array) - stdDiv(array)
  sup = mean(array) + stdDiv(array)
  return [inf, sup]
end

def twoSigma(*array)
  inf = mean(array) - stdDiv(array)*2
  sup = mean(array) + stdDiv(array)*2
end
