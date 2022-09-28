

class Object

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

leandro = Persona.new(22, "leandrito")

