require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'sinatra/reloader'

enable :sessions

  
get('/') do
    slim(:login)
end 

get('/register') do
    slim(:register)
end

get('/main') do
    id = session[:id].to_i
    db = SQLite3::Database.new('db/database.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM User WHERE user_id = ?",id).first
    slim(:start,locals:{result:result})
end

post('/login') do
    username = params[:username]
    password = params[:password]
    db = SQLite3::Database.new('db/database.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM User WHERE username = ?",username).first
    pwdigest = result["pwdigest"]
    id = result["user_id"]
  
    if BCrypt::Password.new(pwdigest) == password
      session[:id] = id
      redirect('/main')
    else
      "FEL LÖSENORD"
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
       "Lösenorden matcher ej"
    end
end



#Schedules
get('/schedules') do
    id = session[:id].to_i
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM Schedule WHERE user_id = ?",id)
    slim(:"schedules/index",locals:{schedules:result})
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
  result = db.execute("SELECT * FROM Schedule WHERE id = ?",id).first
  slim(:"/schedules/edit",locals:{result:result})
end

get('/schedules/:id') do
    id = params[:id].to_i
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM Schedule WHERE id = ?",id).first
    slim(:"schedules/show",locals:{result:result})
end





#Exercises
get('/exercises') do
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM Exercises")
    slim(:"exercises/index",locals:{exercises:result})
end

get('/exercises/new') do
    slim(:"/exercises/new")
end

post('/exercises/new') do
    exercise_name = params[:exercise_name]
    muscle1_id = params[:muscle1_id].to_i #Skapa felhantering om man försöker sätta id = 0
    muscle2_id = params[:muscle2_id].to_i
    muscle3_id = params[:muscle3_id].to_i
    db = SQLite3::Database.new("db/database.db")
    db.execute("INSERT INTO Exercises (exercise_name,muscle1_id,muscle2_id,muscle3_id) VALUES (?,?,?,?)",exercise_name,muscle1_id,muscle2_id,muscle3_id)
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
    muscle1_id = params[:muscle1_id].to_i
    muscle2_id = params[:muscle2_id].to_i
    muscle3_id = params[:muscle3_id].to_i
    db = SQLite3::Database.new("db/database.db")
    db.execute("UPDATE Exercises SET exercise_name=?,muscle1_id=?,muscle2_id=?,muscle3_id=? WHERE exercise_id = ?", exercise_name,muscle1_id,muscle2_id,muscle3_id,exercise_id)
    redirect('/exercises')
end

get('/exercises/:id/edit') do
    exercise_id = params[:id].to_i
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM Exercises WHERE exercise_id = ?",exercise_id).first
    slim(:"/exercises/edit",locals:{result:result})
end

get('/exercises/:id') do
    exercise_id = params[:id].to_i
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM Exercises WHERE exercise_id = ?",exercise_id).first
    result2 = db.execute("SELECT Name FROM MuscleTypes INNER JOIN Exercises ON Exercises.muscle1_id = MuscleTypes.id").first
    result3 = db.execute("SELECT Name FROM MuscleTypes INNER JOIN Exercises ON Exercises.muscle2_id = MuscleTypes.id").first
    result4 = db.execute("SELECT Name FROM MuscleTypes INNER JOIN Exercises ON Exercises.muscle3_id = MuscleTypes.id").first
    #result3 = db.execute("SELECT Exercises.muscle1_id, Exercises.secondary_muscle_id, Exercises.third_muscle_id, FROM Exercises INNER JOIN MuscleTypes ON Exercises.id = ?",id)
    slim(:"exercises/show",locals:{result:result, result2:result2, result3:result3, result4:result4})
end
    