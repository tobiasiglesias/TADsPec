require_relative 'ascerciones'
require_relative 'mocking_spying'

module TADsPec
  def self.included(base)
    @suites ||= []
    @suites << base
  end

  def self.testear(*args)
    if args.length == 0
      retorno = @suites.map{|suite| testear_una_suite suite}.flatten
    elsif args.length == 1
      retorno = testear_una_suite args[0]
    else
      suite = args[0]
      args = args.drop(1)
      retorno = args.map{|mensaje| correr_un_test suite, "testear_que_".concat(mensaje.to_s).to_sym}
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
      wrapper = instancia.send(mensaje.to_s)
      wrapper.agregar_info suite, mensaje
    rescue StandardError => e
      wrapper = WrapperExplotoElTest.new(e)
      wrapper.agregar_info suite, mensaje
    end
    #desmoockeamos al terminar cada test
    Mocking.get_clase_mockeada.desmockear_todo
    wrapper
  end

  def self.prettify(resultados)
    test_corridos = resultados
    test_pasados = resultados.select {|test| test.resultado}
    test_fallidos = resultados.select {|test| !test.resultado}
    test_explotados = resultados.select {|test| test.class.equal? WrapperExplotoElTest}

    #arrancan los logs

    puts "Test corridos: #{test_corridos.length}"
    puts "Test pasados: #{test_pasados.length}"
    puts "Test fallidos: #{test_fallidos.length}"
    puts "Test explotados: #{test_explotados.length}"

    #log de los test con exito
    test_pasados.each {|test| test.imprimir_resultados}

    #test fallidos
    test_fallidos.each {|test| test.imprimir_resultados}

    #test explotados
    test_explotados.each {|test| test.imprimir_resultados}

  end
end




# ------------------------------Para testear-------------------------------------

class Object
  include Mocking
  include Spying
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

  def random(*args)
    nil
  end

end

class MiSuitDeTest
  include TADsPec
  def testear_que_las_personas_de_mas_de_29_son_viejas
    persona = Persona.new("sarasa", "Ernesto")
    persona.deberia ser_viejo
  end

  def testear_que_las_personas_deberian_tener_edad_uno_de_estos
    persona = Persona.new(43, "Ernesto")
    persona.deberia tener_edad uno_de_estos 7, 22, "hola"
  end

  def testear_que_la_edad_explota_con_un_string
    persona = Persona.new("sarasa", "Ernesto")
    en { persona.viejo?}.deberia explotar_con StandardError
  end

  def testear_que_andan_los_mocks_las_personas_de_mas_de_29_son_viejas
    Persona.mockear :viejo? do
      true
    end
    persona = Persona.new(30, "Ernesto")
    persona.deberia ser_viejo
  end

end

class PersonaTest
  include TADsPec
  def testear_que_random_recibe_sarasa
    pato = Persona.new(23, "pato")
    pato = espiar(pato)
    pato.random "sarasa"
    pato.deberia haber_recibido(:random).con_argumentos("sarasa")
    # pasa: edad se recibió exactamente 1 vez.
  end

  def testear_que_random_3_veces
    pato = Persona.new(23, "pato")
    pato = espiar(pato)
    pato.random "sarasa"
    pato.random "sarasa"
    pato.random "sarasa"
    pato.deberia haber_recibido(:random).veces 3
    # pasa: edad se recibió exactamente 1 vez.
  end

  def testear_que_random_no_recibe_hola
    pato = Persona.new(23, "pato")
    pato = espiar(pato)
    pato.random "sarasa"
    pato.random "sarasa"
    pato.random "sarasa"
    pato.deberia haber_recibido(:random).con_argumentos "hola"
    # pasa: edad se recibió exactamente 1 vez.
  end



end





TADsPec.testear
#TADsPec.testear MiSuitDeTest, :la_edad_explota_con_un_string
