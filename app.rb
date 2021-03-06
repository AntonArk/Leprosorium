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

		# создаем таблицу если таблица не существует
	@db.execute 'CREATE TABLE IF NOT EXISTS
	    "Comments" 
	    (
	    	"id"	INTEGER,
			"created_date"	DATE,
			"content"	TEXT,
			"post_id" INTEGER,
			PRIMARY KEY("id" AUTOINCREMENT)
		)'
end

# обработчик get-запроса /new
# (браузер получает страницу с сервера)

get '/' do
	# выбираем список постов из БД
	@results = @db.execute 'SELECT * FROM POSTS ORDER BY id DESC'
	erb :index
end

get '/new' do
  	erb :new
end

# обработчик post-запроса /new
# (браузер отправляет данные на сервер)

post '/new' do
    # получаем переменную из post-запроса
	content = params[:content]

	if content.length <= 0
		@error = 'Type text'
		return erb :new
	end
    
    #сохранение данных в БД
	@db.execute 'INSERT INTO Posts (content, created_date) VALUES (?,datetime())', [content]

	# перенаправление на главную страницу
	redirect to '/'
	
end

# вывод информации о посте

get '/details/:post_id' do 
	
	# получаем переменную из URL
	post_id = params[:post_id]
	
	# получаем список постов
	# (у нас будет только один пост)
	results = @db.execute 'SELECT * FROM Posts WHERE id = ?', [post_id]
	
	# выбираем этот один пост в глобальную переменную @row
	@row = results[0]

	# выбираем комментарии для нашего поста
	@comments = @db.execute 'SELECT * FROM Comments WHERE post_id = ? ORDER BY id', [post_id] 

	# возвращаем представление details.erb
	erb :details
end

# обработчик post-запроса /details/...
# (браузер отправляет данные на сервер, а мы их принимаем)

post '/details/:post_id' do

	# получаем переменную из URL
	post_id = params[:post_id]

	# получаем переменную из post-запроса
	content = params[:content]

	#сохранение данных в БД
	@db.execute 'INSERT INTO Comments (content, created_date, post_id) VALUES (?,datetime(),?)', [content, post_id]

	# перенаправление на страницу поста
	redirect to('/details/' + post_id)
end



	