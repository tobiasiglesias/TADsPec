
class Object
  def deberia(eval)
    eval.call(self)
  end
  def ser(arg)
    if arg.class.equal? Proc
      arg
    else
      wrapper = proc {|objeto_a_evaluar| objeto_a_evaluar.equal? arg}
      wrapper
    end
  end

  #Metodos despues del ser:

  def menor_a(un_numero)
    un_proc = proc {|objeto_a_evaluar| objeto_a_evaluar < un_numero}
  end

  def mayor_a(un_numero)
    un_proc = proc {|objeto_a_evaluar| objeto_a_evaluar > un_numero}
  end

  def uno_de_estos(*args)
    if args.length == 1
      una_lista = args[0]
    else
      una_lista = args.to_ary
    end
    un_proc = proc {|objeto_a_evaluar| una_lista.include? objeto_a_evaluar}
  end

  #Azucar sintactico:


  #Explota
  #TODO Crear clase wrapper q herede de BasicObject e implementar ahi el method missing y el respond to missing


=begin
  private def method_missing(symbol, *args)
    simbolo_a_parsear = symbol.to_s
    if simbolo_a_parsear[0, 3] == "ser"
      mensaje = simbolo_a_parsear[4..-1].concat"?"
      puts mensaje
      send(mensaje.to_sym)
    end

  end
=end




end







# test para ver q onda
leandro = Object.new

def leandro.edad
  22
end


puts "Arrancan los test"
puts 7.deberia ser 7 # pasa
puts true.deberia ser false # falla, obvio
puts leandro.edad.deberia ser 25 #falla (lean tiene 22)
puts leandro.edad.deberia ser menor_a 25
puts leandro.edad.deberia ser uno_de_estos [7, 22, "hola"]
puts leandro.edad.deberia ser uno_de_estos 7, 22, "hola"

puts "Azucar Sintactico"
puts leandro.deberia ser_viejo