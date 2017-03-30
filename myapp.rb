require 'sinatra'
require 'json'
require_relative 'calculator'

get '/' do
  erb :index
end

post '/calculate' do
  @calculator = Calculator.new(params[:rate], params[:amount], params[:type], params[:term])
  if @calculator.valid?
    status 200
    erb :calculation, locals: { calculation: @calculator.calculate }
  else
    status 400
    { errors: @calculator.errors }.to_json
  end
end