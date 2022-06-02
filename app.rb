require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new 'leprosorium.db'
	@db.results_as_hash = true	
end

before do 
	# инициализация БД
	init_db
end

configure do
	init_db

	# создаем таблицу если таблица не существует
	@db.execute 'CREATE TABLE IF NOT EXISTS
	    "Posts" 
	    (
	    	"id"	INTEGER,
			"created_date"	DATE,
			"content"	TEXT,
			PRIMARY KEY("id" AUTOINCREMENT)
		)'
end

# обработчик get-запроса /new
# (браузер получает страницу с сервера)

get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
end

get '/new' do
  	erb :new
end

# обработчик post-запроса /new
# (браузер отправляет данные на сервер)

post '/new' do
    # получаем переменную из post-запроса
	content = params[:content]

	erb "You typed #{content}"
end