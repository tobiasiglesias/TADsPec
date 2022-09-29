require_relative 'ascerciones'
class TADsPec

  def self.testear(*args)
    retorno = nil
    if args == nil
      #todo
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

    #arrancan los logs

    puts "Test corridos: #{test_corridos.length}"
    puts "Test pasados: #{test_pasados.length}"
    puts "Test fallidos: #{test_fallidos.length}"
    puts "Test explotados: #{test_explotados.length}"

    #log de los test con exito
    test_pasados.each {|test| puts "#{test[:mensaje]} corrio con exito en #{test[:suite]}"}

    #test fallidos
    test_fallidos.each {|test| puts "#{test[:mensaje]} fallo en #{test[:suite]}"}

    #test explotados
    test_explotados.each {|test| puts "#{test[:mensaje]} exploto en #{test[:suite]} con la excepecion #{test[:error]}"}

  end
end




# ------------------------------Para testear-------------------------------------

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
    persona = Persona.new("sarasa", "Ernesto")
    persona.deberia ser_viejo
  end

  def testear_que_la_edad_explota_con_un_string
    persona = Persona.new("sarasa", "Ernesto")
    en { persona.viejo?}.deberia explotar_con StandardError
  end

  def las_personas_de_mas_de_29_son_viejas
    persona = Persona.new(30, "Ernesto")
    persona.deberia ser_viejo
  end

end


TADsPec.testear MiSuitDeTest
TADsPec.testear MiSuitDeTest, :la_edad_explota_con_un_string
