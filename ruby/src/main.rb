
class Object
  def deberia(eval)
    equal? eval
  end

  def ser(arg)
    arg
  end
end








# test para ver q onda
leandro = Object.new

def leandro.edad
  22
end



puts 7.deberia ser 7 # pasa
puts true.deberia ser false # falla, obvio
puts leandro.edad.deberia ser 22 #falla (lean tiene 22)