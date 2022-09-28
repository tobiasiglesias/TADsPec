$: << 'src'
require 'ascerciones'

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

end

#----------------------------------------------------------------------------------------------------------

class TADsPec

  def self.testear(*args)
    retorno = nil
    if args == nil
      #todo
    elsif args.length == 1
      retorno = testear_una_suite args[0]
    else
      suite = args[0]
      args = args.drop(args.length - 1)
      retorno = args.map{|mensaje| correr_un_test suite, mensaje}
    end
    prettify retorno
  end

  def self.testear_una_suite(suite)
    tests = suite.instance_methods.select {|mensaje| mensaje.to_s.include? "testear_que"}
    tests.map do |mensaje|
      correr_un_test(suite, mensaje)
    end
  end

  def  self.correr_un_test(suite, mensaje)
    instancia = suite.new
    begin
      instancia.send(mensaje.to_s)
    rescue StandardError => e
      {mensaje: mensaje.to_s , valor: "exploto" , error: e, suite: suite}
    else
      if instancia.send(mensaje.to_s)
        {mensaje: mensaje.to_s , valor: "paso" , error: nil, suite: suite}
      else
        {mensaje: mensaje.to_s , valor: "fallo" , error: nil, suite: suite}
      end
    end
  end

  def self.prettify(resultados)
    test_corridos = resultados
    test_pasados = resultados.select {|test| test[:valor] == "paso"}
    test_fallidos = resultados.select {|test| test[:valor] == "fallo"}
    test_explotados = resultados.select {|test| test[:valor] == "exploto"}

    #todo ...

  end




end




# Para testear

class Object
  include Ascerciones
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

class MiSuitDeTest
  def testear_que_las_personas_de_mas_de_29_son_viejas
    persona = Persona.new(30, "Ernesto")
    persona.deberia ser_viejo
  end

  def las_personas_de_mas_de_29_son_viejas
    persona = Persona.new(30, "Ernesto")
    persona.deberia ser_viejo
  end

end

TADsPec.testear MiSuitDeTest
