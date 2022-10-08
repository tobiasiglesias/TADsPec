module Mocking

  def self.clase_mockeada(una_clase)
    @@clase = una_clase
  end

  def self.get_clase_mockeada
    begin
      @@clase
    rescue NameError
      nil
    end
  end

  def mockear(metodo, &block)
    @mockeado = true
    @metodos_mockeados ||= []
    @metodos_mockeados << metodo
    Mocking.clase_mockeada self

    alias_method ("duplicado_" + metodo.to_s).to_sym, metodo
    define_method metodo do
      block.call
    end
  end

  def desmockear(metodo)
    if @mockeado == true
      @mockeado = false
      remove_method(metodo)
      alias_method metodo, ("duplicado_" + metodo.to_s).to_sym
    end
  end

  def desmockear_todo
    if @mockeado == true
      @metodos_mockeados.each {|metodo| desmockear metodo}
    end
  end
end

module Spying
  def espiar(un_objeto)
    Espiador.new(un_objeto)
  end

  def haber_recibido(mensaje)
    WrapperHaberRecibido.new(mensaje)
  end

  def con_argumentos(*args)
    WrapperArgumentos.new(args)
  end
end

class Espiador < BasicObject
  attr_accessor :objeto_espiado, :mensajes_recibidos

  def initialize(*args)
    @objeto_espiado = args[0]
  end

  def method_missing(symbol, *args)
    registrar_mensaje symbol, args.flatten
    objeto_espiado.send symbol, args
  end

  def respond_to_missing?(symbol, include_private = false)
    objeto_espiado.respond_to? symbol
  end

  def registrar_mensaje(mensaje, *args)
    @mensajes_recibidos ||= []
    @mensajes_recibidos << {mensaje: mensaje, argumentos: args.flatten}
  end


end


