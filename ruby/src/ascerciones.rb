module Ascerciones
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