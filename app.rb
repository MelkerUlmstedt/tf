require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'sinatra/reloader'

enable :sessions

get('/')  do
    slim(:start)
end 

#Schedules
get('/schedules') do
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM Schedule")
    slim(:"schedules/index",locals:{schedules:result})
end

get('/schedules/new') do
    slim(:"/schedules/new")
end

post('/schedules/new') do
    name = params[:name]
    db = SQLite3::Database.new("db/database.db")
    db.execute("INSERT INTO Schedule (name) VALUES (?)",name)
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
  exercise = params[:exercise]
  primary_muscle_id = params[:primary_muscle_id].to_i- #Får inte vara noll, ta reda på hur man gör detta
  secondary_muscle_id = params[:secondary_muscle_id].to_i
  third_muscle_id = params[:third_muscle_id].to_i
  db = SQLite3::Database.new("db/database.db")
  db.execute("INSERT INTO Exercises (exercise,primary_muscle_id,secondary_muscle_id,third_muscle_id) VALUES (?,?,?,?)",exercise,primary_muscle_id,secondary_muscle_id,third_muscle_id)
  redirect('/exercises')
end

post('/exercises/:id/delete') do
  id = params[:id].to_i
  db = SQLite3::Database.new("db/database.db")
  db.execute("DELETE FROM Exercises WHERE id = ?",id)
  redirect('/exercises')
end

post('/exercises/:id/update') do
  id = params[:id].to_i
  exercise = params[:exercise]
  primary_muscle_id = params[:primary_muscle_id].to_i
  secondary_muscle_id = params[:secondary_muscle_id].to_i
  third_muscle_id = params[:third_muscle_id].to_i
  db = SQLite3::Database.new("db/database.db")
  db.execute("UPDATE Exercises SET exercise=?,primary_muscle_id=?,secondary_muscle_id=?,third_muscle_id=? WHERE id = ?", exercise,primary_muscle_id,secondary_muscle_id,third_muscle_id,id)
  redirect('/exercises')
end

get('/exercises/:id/edit') do
  id = params[:id].to_i
  db = SQLite3::Database.new("db/database.db")
  db.results_as_hash = true
  result = db.execute("SELECT * FROM Exercises WHERE id = ?",id).first
  slim(:"/exercises/edit",locals:{result:result})
end

get('/exercises/:id') do
  id = params[:id].to_i
  db = SQLite3::Database.new("db/database.db")
  db.results_as_hash = true
  result = db.execute("SELECT * FROM Exercises WHERE id = ?",id).first
  result2 = db.execute("SELECT Name FROM MuscleTypes WHERE id IN (SELECT id FROM Exercises WHERE id = ?)",id).first
  slim(:"exercises/show",locals:{result:result,result2:result2})
end
    