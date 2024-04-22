require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'sinatra/reloader'
require 'sinatra/flash'

enable :sessions

  
get('/') do
    slim(:'/user/login')
end 

get('/register') do
    slim(:"/user/new")
end

get('/main') do
    id = session[:id].to_i
    db = SQLite3::Database.new('db/database.db')
    db.results_as_hash = true
    @result = db.execute("SELECT * FROM User WHERE user_id = ?",id).first
    slim(:index)
end

post('/login') do
    username = params[:username]
    password = params[:password]
    db = SQLite3::Database.new('db/database.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM User WHERE username = ?",username).first
  
    if result == nil
        flash[:notice] = "Användarnamnet existerar ej"
        redirect('/')
    else
        pwdigest = result["pwdigest"]
        id = result["user_id"]
        if BCrypt::Password.new(pwdigest) == password
        session[:id] = id
        redirect('/main')
        else
            flash[:notice] = "Fel lösenord"
            redirect('/')
        end
    end
end

post('/users/new') do
    username = params[:username]
    password_confirm = params[:password_confirm]
    password = params[:password]
  
    if (password_confirm == password)
      password_digest = BCrypt::Password.create(password)
      db = SQLite3::Database.new('db/database.db')
      db.execute("INSERT INTO User (username,pwdigest) VALUES (?,?)",username,password_digest)
      redirect('/')
    else
       flash[:notice] = "Lösenorden matcher ej"
       redirect('/register')
    end
end



#Schedules
get('/schedules') do
    id = session[:id].to_i
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true
    @result = db.execute("SELECT * FROM Schedule WHERE user_id = ?",id)
    slim(:"schedules/index")
end

get('/schedules/new') do
    slim(:"/schedules/new")
end

post('/schedules/new') do
    name = params[:name]
    user_id = session[:id].to_i
    p name
    p user_id
    db = SQLite3::Database.new("db/database.db")
    db.execute("INSERT INTO Schedule (name,user_id) VALUES (?,?)",name,user_id)
    redirect('/schedules')
end

post('/schedules/:id/delete') do
    id = params[:id].to_i
    db = SQLite3::Database.new("db/database.db")
    db.execute("DELETE FROM Schedule WHERE id = ?",id)
    redirect('/schedules')
end

post('/schedules/:id/update') do
  id = params[:id].to_i
  name = params[:name]
  db = SQLite3::Database.new("db/database.db")
  db.execute("UPDATE Schedule SET name=? WHERE id = ?", name,id)
  redirect('/schedules')
end

get('/schedules/:id/edit') do
  id = params[:id].to_i
  db = SQLite3::Database.new("db/database.db")
  db.results_as_hash = true
  @result = db.execute("SELECT * FROM Schedule WHERE id = ?",id).first
  slim(:"/schedules/edit")
end

get('/schedules/:id') do
    id = params[:id].to_i
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true
    @result = db.execute("SELECT * FROM Schedule WHERE id = ?",id).first
    slim(:"schedules/show")
end





#Exercises
get('/exercises') do
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true
    @result = db.execute("SELECT * FROM Exercises")
    slim(:"exercises/index")
end

get('/exercises/new') do
    slim(:"/exercises/new")
end

post('/exercises/new') do
    exercise_name = params[:exercise_name]
    muscle_id = params[:muscle_id].to_i #Skapa felhantering om man försöker sätta id = 0
    db = SQLite3::Database.new("db/database.db")
    db.execute("INSERT INTO Exercises (exercise_name,muscle_id) VALUES (?,?)",exercise_name,muscle_id)
    redirect('/exercises')
end

post('/exercises/:id/delete') do
    exercise_id = params[:id].to_i
    db = SQLite3::Database.new("db/database.db")
    db.execute("DELETE FROM Exercises WHERE exercise_id = ?",exercise_id)
    redirect('/exercises')
end

post('/exercises/:id/update') do
    exercise_id = params[:id].to_i
    exercise_name = params[:exercise_name]
    muscle_id = params[:muscle_id].to_i
    db = SQLite3::Database.new("db/database.db")
    db.execute("UPDATE Exercises SET exercise_name=?,muscle_id=? WHERE exercise_id = ?", exercise_name,muscle_id,exercise_id)
    redirect('/exercises')
end

get('/exercises/:id/edit') do
    exercise_id = params[:id].to_i
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true
    @result = db.execute("SELECT * FROM Exercises WHERE exercise_id = ?",exercise_id).first
    slim(:"/exercises/edit")
end

get('/exercises/:id') do
    exercise_id = params[:id].to_i
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true
    @result = db.execute("SELECT * FROM Exercises WHERE exercise_id = ?",exercise_id).first
    @result2 = db.execute("SELECT Exercises.exercise_name, MuscleTypes.Name FROM Exercises INNER JOIN MuscleTypes ON Exercises.muscle_id = MuscleTypes.id WHERE Exercises.exercise_id = ?",exercise_id).first
    slim(:"exercises/show")
end



