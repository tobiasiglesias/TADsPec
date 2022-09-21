class Object
  def deberia(eval)
    eval.call(self)
  end
  def ser(arg)
    if arg.class.equal? Proc
      arg
    else
      proc {|objeto_a_evaluar| objeto_a_evaluar.equal? arg}
    end
  end
  def menor_a(un_numero)
    proc {|objeto_a_evaluar| objeto_a_evaluar < un_numero}
  end
  def mayor_a(un_numero)
    proc {|objeto_a_evaluar| objeto_a_evaluar > un_numero}
  end
  def uno_de_estos(*args)
    proc {|objeto_a_evaluar| args.flatten.include? objeto_a_evaluar}
  end
  def entender(metodo) #TODO Nota: No se olviden que el objeto podría tener sobreescrito el method_missing. Contemplen ese caso en su implementación.
    proc {|objeto_a_evaluar| objeto_a_evaluar.methods.include? metodo}
  end
  def explotar_con(error)
    proc {|objeto_a_evaluar| objeto_a_evaluar == error}
  end
  def en(&block)
    begin block.call
    rescue StandardError => e
      e.class
    end
  end


  private def method_missing(symbol, *args)
    simbolo_a_parsear = symbol.to_s.split("_",2)

    # Ser_algo -------------------------------------------------------
    if simbolo_a_parsear[0] == "ser"
      mensaje = simbolo_a_parsear[1].concat("?")
      proc {|objeto_a_evaluar| objeto_a_evaluar.send mensaje}

      # Tener ---------------------------------------------------------

    elsif simbolo_a_parsear[0] == "tener"
      atributo = "@".concat(simbolo_a_parsear[1]).to_sym
      proc do |objeto_a_evaluar|

        #TODO arreglar esto de tenerlo como string y pasarlo a simbolo, con simbolo directo no anda xd
        raise StandardError if not objeto_a_evaluar.send "instance_variable_defined?", atributo
        valor_atributo = objeto_a_evaluar.send "instance_variable_get", atributo
        if args[0].class.equal? Proc
          args[0].call(valor_atributo)
        else
          valor_atributo == args[0]
        end
      end
    else
      super
    end
  end
end

class Persona
  attr_reader :edad
  def initialize(edad, nombre_del_pibe)
    @edad = edad
    @nombre = nombre_del_pibe
  end
  def viejo?
    @edad > 25
  end
end

leandro = Persona.new(22, "leandrito")


#leandro_wrapper = Wrapper.new(leandro)

puts "Arrancan los test"
puts 7.deberia ser 7 # pasa
puts true.deberia ser false # falla, obvio
puts leandro.edad.deberia ser 25 #falla (lean tiene 22)
puts leandro.edad.deberia ser menor_a 25 #true
puts leandro.edad.deberia ser uno_de_estos [7, 22, "hola"] #true
puts leandro.edad.deberia ser uno_de_estos 7, 22, "hola" #true

puts "Azucar Sintactico"
puts leandro.deberia ser_viejo #false

puts "Locura"
puts leandro.deberia tener_edad 22 #true
puts leandro.deberia tener_nombre "leandrito"
puts leandro.deberia tener_edad uno_de_estos [7, 22, "hola"] # pasa
