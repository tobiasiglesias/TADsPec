require_relative 'ascerciones'

class Object
  include Ascerciones
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



leandro = Persona.new 22, "leandro"

=begin Anda!!
puts leandro.edad.deberia ser mayor_a 20
# pasa si el objeto es mayor al parámetroputs
puts leandro.edad.deberia ser menor_a 25
# pasa si el objeto es menor al parámetro
puts leandro.edad.deberia ser uno_de_estos [7, 22, "hola"]
# pasa si el objeto está en la lista recibida por parámetro
puts leandro.edad.deberia ser uno_de_estos 7, 22, "hola"
# debe poder escribirse usando varargs en lugar de un array
puts "godddd"
=end





=begin

leandro.deberia tener_edad 22 # pasa
leandro.deberia tener_nombre "leandro" # pasa: no hay atributo nombre
leandro.deberia tener_nombre nil # falla

leandro.deberia tener_edad mayor_a 27 # falla

leandro.deberia tener_edad menor_a 25 # pasa
leandro.deberia tener_edad uno_de_estos [7, 22, "hola"] # pasa

leandro.deberia tener_edad uno_de_estos 7, 22, "hola"

=end

=begin

puts leandro.deberia entender :viejo? # pasa
puts leandro.deberia entender :class  # pasa: este mensaje se hereda de Object
puts leandro.deberia entender :nombre # falla: leandro no entiende el mensaje
=end


=begin
puts en { 7 / 0 }.deberia explotar_con ZeroDivisionError # pasa
puts en { leandro.nombre }.deberia explotar_con NoMethodError # pasa
puts en { leandro.nombre }.deberia explotar_con StandardError # pasa: NoMethodError < Error
puts en { leandro.viejo?}.deberia explotar_con NoMethodError # falla: No tira error
puts en { 7 / 0 }.deberia explotar_con NoMethodError # falla: Tira otro error
=end
=begin
puts en { 7 / 0 }.deberia explotar_con ZeroDivisionError # pasa
puts en { leandro.nombre }.deberia explotar_con NoMethodError # pasa
puts en { leandro.nombre }.deberia explotar_con StandardError # pasa: NoMethodError < Error
puts en { leandro.viejo?}.deberia explotar_con NoMethodError # falla: No tira error
puts en { 7 / 0 }.deberia explotar_con NoMethodError # falla: Tira otro error
=end

leandro.deberia ser_viejo