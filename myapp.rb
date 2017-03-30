require 'sinatra'
require 'json'
require_relative 'calculator'

get '/' do
  erb :form
end

post '/table' do
  @calculator = Calculator.new(params[:rate], params[:amount], params[:type], params[:term])
  if @calculator.valid?
    status 200
    erb :table, locals: { calculation: @calculator.calculate }
  else
    status 400
    { errors: @calculator.errors }.to_json
  end
end

get '/*' do
  redirect '/'
end