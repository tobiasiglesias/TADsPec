class Validacion_test
  def es_test?(test_symbol)
    test_symbol.to_s.include? "testear_que"
  end
  def validar_test(mensaje, instancia)
    begin instancia.send(mensaje.to_s)
    rescue StandardError => e
      {mensaje: mensaje.to_s , valor: "exploto" , error: e}
    else
      if instancia.send(mensaje.to_s)
      {mensaje: mensaje.to_s , valor: "paso" , error: nil}
      else
      {mensaje: mensaje.to_s , valor: "fallo" , error: instancia.send(mensaje.to_s)}
      end
    end
  end
  def buscar_metodos_test_suite(suite,metodos)
    metodos_a_comparar = metodos.map{|metodo| metodo.to_s}
    metodos_test = suite.public_instance_methods.select{|metodo| self.es_test?(metodo)}
    metodos_test.select{|metodo| metodos_a_comparar.include? metodo.to_s.split("testear_que_")[1]}
  end
end

module Para_los_test
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
  def entender(metodo)
    proc {|objeto_a_evaluar| objeto_a_evaluar.respond_to? metodo}
  end
  def explotar_con(error)
    proc {|objeto_a_evaluar|
      if objeto_a_evaluar == nil
        false
      else
        objeto_a_evaluar <= error
      end}
  end
  def en(&block)
    begin block.call
    rescue StandardError => e
      e.class
    else
      nil
    end
  end

  def testear(*args)
    validar = Validacion_test.new
    if args.length == 0 #Este caso no estaría andando, nose bien como hacer para ejecutar los test sin una instancia ni nada
      # Correr todas las suites que se hayan importado al contexto
      metodos = self.methods.select{|metodo| validar.es_test?(metodo)}
      resultados_tests = metodos.map{|metodo| validar.validar_test(metodo,self)}
    elsif args.length == 1
      # Correr una suite de tests en particular
      metodos = args[0].public_instance_methods.select{|metodo| validar.es_test?(metodo)}
      instancia_suite = args[0].new(26,"jorge") #Esto lo puse como instancia ejemplo, pero en verdad no tendria que ir, nose como hacer bien
      resultados_tests = metodos.map{|metodo| validar.validar_test(metodo,instancia_suite)}
    else
      # Correr un test/varios test específicos de una suite
      metodos = validar.buscar_metodos_test_suite(args[0],args[1..-1])
      instancia_suite = args[0].new(26,"jorge") #Esto lo puse como instancia ejemplo, pero en verdad no tendria que ir, nose como hacer bien
      resultados_tests = metodos.map{|metodo| validar.validar_test(metodo,instancia_suite)}
    end

    tests_que_pasaron = resultados_tests.select{|resultado| resultado[:valor] == "paso"}
    tests_que_fallaron = resultados_tests.select{|resultado| resultado[:valor] == "fallo"}
    tests_que_explotaron = resultados_tests.select{|resultado| resultado[:valor] == "exploto"}
    {
     cantidad_test_totales: metodos.length,
     cantidad_test_que_pasaron: tests_que_pasaron.length,
     test_que_pasaron: tests_que_pasaron.map{|test| test[:mensaje]},
     cantidad_test_que_fallaron: tests_que_fallaron.length,
     test_que_fallaron: tests_que_fallaron.map{|test| test[:mensaje]}.zip(tests_que_fallaron.map{|test| "Expected: True, but got: " + test[:error].to_s}),
     cantidad_test_que_explotaron: tests_que_explotaron.length,
     test_que_explotaron: tests_que_explotaron.map{|test| test[:mensaje]}.zip(tests_que_explotaron.map{|test| "Throw Exception: " + test[:error].class.to_s + " Slack: " + "nose que es"}),
    }
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
        raise StandardError unless objeto_a_evaluar.send "instance_variable_defined?", atributo
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

  def respond_to_missing?(symbol, include_private = false)
    simbolo_a_parsear = symbol.to_s.split("_",2)
    if simbolo_a_parsear[0] == "ser" or simbolo_a_parsear[0] == "tener"
      true
    else
      super
    end
  end

end

class Object
  include Para_los_test

  def deberia(eval)
    eval.call(self)
  end

  def mockear(metodo,&block)
    self.define_singleton_method metodo do
      block.call
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

  def testear_que_pasa_algo
    pepe = Persona.new(30,"pepe")
    pepe.deberia ser_viejo
  end

end