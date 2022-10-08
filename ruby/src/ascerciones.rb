module Ascerciones
  def deberia(wrapper)
    wrapper.call(self)
    wrapper
  end

  def ser(arg)
    if arg.class < Wrapper or arg.class == Wrapper
      arg
    else
      proc {|objeto_a_evaluar| objeto_a_evaluar.equal? arg}
    end
  end

  def menor_a(un_numero)
    WrapperMenor.new(un_numero)
  end

  def mayor_a(un_numero)
    WrapperMayor.new(un_numero)
  end

  def uno_de_estos(*args)
    WrapperUnoDeEstos.new(args)
  end

  def entender(metodo)
    WrapperEntender.new(metodo)
  end

  def explotar_con(error)
    WrapperExplotar.new(error)
  end

  def en(&block)
    begin block.call
    rescue StandardError => e
      e.class
    else
      nil
    end
  end

  private def method_missing(symbol, *args)
    simbolo_a_parsear = symbol.to_s.split("_",2)

    # Ser_algo -------------------------------------------------------
    if simbolo_a_parsear[0] == "ser"
      mensaje = simbolo_a_parsear[1].concat("?")
      WrapperSerAlgo.new(mensaje)
      #proc {|objeto_a_evaluar| objeto_a_evaluar.send mensaje}

      # Tener ---------------------------------------------------------

    elsif simbolo_a_parsear[0] == "tener"
      atributo = "@".concat(simbolo_a_parsear[1]).to_sym
      WrapperTener.new(args[0], atributo)
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



#-------------------Wrappers-------------------

class Wrapper
  attr_accessor :objeto_esperado, :objeto_encontrado, :resultado, :suite, :nombre_test

  def initialize(*args)
    @objeto_esperado = args[0]
  end

  def call(un_objeto)
    @objeto_encontrado = un_objeto
    @resultado = un_objeto == objeto_esperado
  end
  def imprimir_resultados
    if resultado
      puts "el test #{nombre_test} corrio con exito en la suite #{suite}"
    else
      puts "fallo"
    end
  end

  def agregar_info(suite, nombre_test)
    @suite = suite
    @nombre_test = nombre_test
  end

end

class WrapperMenor < Wrapper
  def call(un_objeto)
    @objeto_encontrado = un_objeto
    @resultado = un_objeto < objeto_esperado
  end
  def imprimir_resultados
    if resultado
      super
    else
      puts "el test #{nombre_test} fallo en la suite #{suite}, se esperaba que #{objeto_esperado} fuera menor que #{objeto_encontrado}"
    end
  end

  def imprimir_tener
    "menor a #{objeto_esperado} pero se obtuvo #{objeto_encontrado}"
  end

end

class WrapperMayor < Wrapper
  def call(un_objeto)
    @objeto_encontrado = un_objeto
    @resultado = un_objeto > objeto_esperado
  end
  def imprimir_resultados
    if resultado
      super
    else
      puts "el test #{nombre_test} fallo en la suite #{suite}, se esperaba que #{objeto_esperado} fuera mayor que #{objeto_encontrado}"
    end
  end

  def imprimir_tener
    "mayor a #{objeto_esperado} pero se obtuvo #{objeto_encontrado}"
  end

end

class WrapperUnoDeEstos < Wrapper

  def initialize(*args)
    @objeto_esperado = args.flatten
  end
  def call(un_objeto)
    @objeto_encontrado = un_objeto
    @resultado = objeto_esperado.include? un_objeto
  end

  def imprimir_resultados
    if resultado
      super
    else
      puts "el test #{nombre_test} fallo en la suite #{suite}, se esperaba que #{objeto_esperado} fuera uno de estos #{objeto_encontrado}"
    end
  end

  def imprimir_tener
    "sea uno de estos #{objeto_esperado} pero se obtuvo #{objeto_encontrado}"
  end

end

class WrapperEntender < Wrapper

  def call(un_objeto)
    @objeto_encontrado = un_objeto
    @resultado = un_objeto.respond_to? objeto_esperado
  end

  def imprimir_resultados
    if resultado
      super
    else
      puts "el test #{nombre_test} fallo en la suite #{suite}, #{objeto_encontrado} no entiende el mensaje #{objeto_esperado}"
    end
  end
end

class WrapperExplotar < Wrapper
  def call(un_objeto)
    @objeto_encontrado = un_objeto

    if objeto_encontrado == nil
      @resultado = false
    else
      @resultado = objeto_encontrado < objeto_esperado or objeto_encontrado == objeto_esperado
    end
  end

  def imprimir_resultados
    if resultado
      super
    elsif objeto_encontrado == nil
      puts "el test #{nombre_test} fallo en la suite #{suite}, se esperaba que explote con #{objeto_esperado} pero exploto con #{objeto_encontrado}"
    else
      puts "el test #{nombre_test} fallo en la suite #{suite}, se esperaba que explote con #{objeto_esperado} pero no exploto"
    end
  end

end

class WrapperSerAlgo < Wrapper

  def call(un_objeto)
    @objeto_encontrado = un_objeto
    @resultado = objeto_encontrado.send objeto_esperado
  end

  def imprimir_resultados
    if resultado
      super
    else
      puts "el test #{nombre_test} fallo en la suite #{suite}, se esperaba que #{objeto_encontrado} sea #{objeto_esperado} pero no lo es"
    end
  end

end
class WrapperTener < Wrapper

  attr_accessor :atributo, :valor_atributo
  def initialize(*args)
    @objeto_esperado = args[0]
    @atributo = args[1]
  end


  def call(un_objeto)
    @objeto_encontrado = un_objeto
    @valor_atributo = objeto_encontrado.send "instance_variable_get", atributo
    if objeto_esperado.class == Wrapper or objeto_esperado.class < Wrapper
      @resultado = objeto_esperado.call(valor_atributo)
    else
      @resultado = valor_atributo == objeto_esperado
    end
  end

  def imprimir_resultados
    if resultado
      super
    elsif objeto_esperado.class == Wrapper or objeto_esperado.class < Wrapper
      puts "el test #{nombre_test} fallo en la suite #{suite}, se esperaba que #{objeto_encontrado} tenga #{atributo} #{objeto_esperado.imprimir_tener}"
    else
      puts "el test #{nombre_test} fallo en la suite #{suite}, se esperaba que #{objeto_encontrado} tenga #{atributo} igual a #{objeto_esperado} pero se obtuvo #{valor_atributo}"
    end
  end
end

class WrapperExplotoElTest < Wrapper
  attr_accessor :error
  def initialize(*args)
    @error = args[0]
  end

  def imprimir_resultados
    puts "el test #{nombre_test} en la suite #{suite},exploto con el error #{error}"
  end

end

class WrapperHaberRecibido < Wrapper
  def initialize(*args)
    super
    @flagveces = false
    @flagargs = false
  end
  def call(un_objeto)
    @objeto_encontrado = un_objeto
    @resultado = objeto_encontrado.mensajes_recibidos.any? {|mensaje| mensaje[:mensaje] == objeto_esperado}
  end

  def imprimir_resultados
    if @flagargs
      callear_con_argumentos
    elsif @flagveces
      callear_veces
    end
    if resultado
      super
    elsif @flagargs
      puts "el test #{nombre_test} fallo en la suite #{suite}, #{objeto_encontrado} recibio el mensaje #{objeto_esperado}, pero no con estos argumentos #{@argumentos}"
    elsif @flagveces
      puts "el test #{nombre_test} fallo en la suite #{suite}, #{objeto_encontrado} recibio el mensaje #{objeto_esperado}, pero #{@veces_mensaje_recibido} veces en vez de #{@veces_mensaje_esperado}"
    else
      puts "el test #{nombre_test} fallo en la suite #{suite}, #{objeto_encontrado} no recibio el mensaje #{objeto_esperado}"
    end
  end

  def con_argumentos(*args)
    @flagargs = true
    @argumentos = args.flatten
    self
  end

  def veces(veces)
    @flagveces = true
    @veces_mensaje_esperado = veces
    self
  end

  def callear_con_argumentos()
    if resultado
      @resultado = objeto_encontrado.mensajes_recibidos.any? {|mensaje| mensaje[:mensaje] == objeto_esperado and mensaje[:argumentos] == @argumentos}
    else
      resultado
    end
  end

  def callear_veces()
    if resultado
      @veces_mensaje_recibido = objeto_encontrado.mensajes_recibidos.select {|mensaje| mensaje[:mensaje] == objeto_esperado}.length
      @resultado = @veces_mensaje_recibido == @veces_mensaje_esperado
    else
      resultado
    end
  end

end