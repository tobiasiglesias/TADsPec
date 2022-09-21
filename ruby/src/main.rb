class Object
  def deberia(eval)
    eval.call(self)
  end
  def ser(arg)
    if arg.class.equal? Proc
      arg
    else
      wrapper = proc {|objeto_a_evaluar| objeto_a_evaluar.equal? arg}
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

  private def method_missing(symbol, *args)
    simbolo_a_parsear = symbol.to_s

    # Ser_algo
    if simbolo_a_parsear[0, 3] == "ser"
      mensaje = simbolo_a_parsear[4..-1].concat"?"
      un_proc = proc {|objeto_a_evaluar| objeto_a_evaluar.send mensaje.to_sym}

      # Tener

    elsif simbolo_a_parsear[0, 5] == "tener"
      atributo = "@" + simbolo_a_parsear[6..-1]
      atributo = atributo.to_sym
      un_proc = proc do |objeto_a_evaluar|

        #TODO arreglar esto de tenerlo como string y pasarlo a simbolo, con sibolo directo no anda xd
        if objeto_a_evaluar.send "instance_variable_defined?".to_sym, atributo
          (objeto_a_evaluar.send "instance_variable_get".to_sym, atributo) == args[0]

        else
          #TODO error customizado -> no hay atributo con ese nombre
          raise StandardError

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



# tests para ver q onda
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
puts leandro.deberia ser_viejo #true

puts "Locura"
puts leandro.deberia tener_edad 22
puts leandro.deberia tener_nombre "leandrito"

