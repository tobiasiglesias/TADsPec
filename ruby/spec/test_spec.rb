require 'rspec'
require_relative '../src/main'

describe 'ser' do
  let(:leandro) { leandro = Persona.new 22, "leandrito" }


  it '7 deberia ser 7' do
    expect(7.deberia ser 7).to be_truthy
  end

  it 'true no deberia ser false' do
    expect(true.deberia ser false).to be_falsey
  end

  it 'la edad de leandro no deberia ser 25' do
    expect(leandro.edad.deberia ser 25).to be_falsey
  end

  it 'la edad de leandro deberia ser mayor a 20' do
    expect(leandro.edad.deberia ser mayor_a 20).to be_truthy
  end

  it 'la edad de leandro deberia ser menor a 25' do
    expect(leandro.edad.deberia ser menor_a 25).to be_truthy
  end

  it 'la edad de leandro deberia ser un elemento de un array' do
    expect(leandro.edad.deberia ser uno_de_estos [7, 22, "hola"]).to be_truthy
  end


  it 'la edad de leandro deberia ser un elemento de var args' do
    expect(leandro.edad.deberia ser uno_de_estos 7, 22, "hola").to be_truthy
  end

  it 'ser_algo - azucar sintactica' do
    expect(leandro.deberia ser_viejo).to eq(leandro.viejo?)
  end

end




describe 'Tener' do
  let(:leandro) { leandro = Persona.new 22, "leandrito" }

  it 'leandro deberia tener edad 22' do
    expect(leandro.deberia tener_edad 22).to be_truthy
  end

  it 'leandro no deberia tener nombre Arnoldo' do
    expect(leandro.deberia tener_nombre "Arnoldo").to be_falsey
  end

  it 'leandro deberia tener edad mayor a 20' do
    expect(leandro.deberia tener_edad mayor_a 20).to be_truthy
  end

  it 'leandro deberia tener edad incluida en el array' do
    expect(leandro.deberia tener_edad uno_de_estos [7, 22, "hola"]).to be_truthy
  end

end


describe 'Entender' do
  let(:leandro) { leandro = Persona.new 22, "leandrito" }

  it 'leandro entiende el mensaje viejo?' do
    expect(leandro.deberia entender :viejo?).to be_truthy
  end

  it 'leandro entiende el mensaje ser_viejo' do
    expect(leandro.deberia entender :ser_viejo).to be_truthy
  end

  it 'leandro no entiende el mensaje joven?' do
    expect(leandro.deberia entender :joven?).to be_falsey
  end

  it 'leandro entiende class' do
    expect(leandro.deberia entender :class).to be_truthy
  end

end

describe 'Explotar' do
  let(:leandro) { leandro = Persona.new 22, "leandrito" }

  it 'Division por zero explota bien' do
    expect(en { 7 / 0 }.deberia explotar_con ZeroDivisionError).to be_truthy
  end

  it 'leandro.jugar al tenis explota con NoMethodError' do
    expect(en { leandro.jugar_al_tenis }.deberia explotar_con NoMethodError).to be_truthy
  end

  it 'leandro.jugar al tenis explota con NameError' do
    expect(en { leandro.jugar_al_tenis }.deberia explotar_con NameError).to be_truthy
  end

  it 'leandro.viejo? no explota' do
    expect(en { leandro.viejo?}.deberia explotar_con NoMethodError).to be_falsey
  end

  it 'Division x zero no explota con NoMethodError' do
    expect(en { 7 / 0 }.deberia explotar_con NoMethodError).to be_falsey
  end

end