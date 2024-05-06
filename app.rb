require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'sinatra/reloader'
require 'sinatra/flash'
require_relative './model.rb'

enable :sessions

include Model

before do
    $db = connect_database()
end

get('/error') do
    slim(:error)
end

# Displays a login form
#
get('/') do
    slim(:'/user/login')
end 

# Displays a register form
#
get('/register') do
    slim(:"/user/new")
end

get('/main') do
    id = session[:id].to_i
    main(id)
    slim(:index)
end

# Attempts login and updates the session
#
# @param [String] username, The username
# @param [String] password, The password
#
# @see Model#login_authentication
post('/login') do
    username = params[:username]
    password = params[:password]
    login_authentication(username, password)
end

post('/logout') do
    session[:id] = nil
    redirect('/')
end

post('/users/new') do
    username = params[:username]
    password_confirm = params[:password_confirm]
    password = params[:password]

    validator(username)
    validator(password)
  
    register_authentication(username,password_confirm,password)
end

# Check if user is logged in before accessing schedules
#
before('/schedules*') do
    if logged_in() == false
        redirect('/error')
    end
end

# Displays a list of all your schedules
#
get('/schedules') do
    id = session[:id].to_i
    schedules_index(id)
    slim(:"schedules/index")
end

# Displays a form for creating a new schedule
#
get('/schedules/new') do
    slim(:"/schedules/new")
end

# Attempts to create a new schedule
#
# @param [String] name, The name of the schedule
# @param [Integer] id, The id of the user
#
# @see Model#new_schedule
post('/schedules') do
    name = params[:name]
    user_id = session[:id].to_i
    new_schedule(name,user_id)
    redirect('/schedules')
end

# Attempts to delete a schedule
#
# @param [Integer] id, The id of the schedule
#
# @see Model#schedule_delete
post('/schedules/:id/delete') do
    id = params[:id].to_i
    schedule_delete(id)
    redirect('/schedules')
end

# Attempts to update a schedule
#
# @param [Integer] id, The id of the schedule
# @param [String] name, The name of the schedule
#
# @see Model#schedule_update
post('/schedules/:id/update') do
  id = params[:id].to_i
  name = params[:name]
  schedule_update(name,id)
  redirect('/schedules')
end

# Displays a form for editing a schedule
#
# @param [Integer] id, The id of the schedule
# @see Model#schedule_edit
get('/schedules/:id/edit') do
  id = params[:id].to_i
  schedule_edit(id)
  slim(:"/schedules/edit")
end

# Displays a specific schedule
#
# @param [Integer] id, The id of the schedule
# @see Model#schedule_show
get('/schedules/:id') do
    id = params[:id].to_i
    schedule_show(id)
    slim(:"schedules/show")
end

get('/schedules/:id/add_exercise') do
    schedule_id = params[:id].to_i
    add_exercise_to_schedule(schedule_id)
    slim(:"schedules/add_exercise")
end

post('/schedules/:id/add_exercise') do
    schedule_id = params[:id].to_i
    exercise_id = params[:exercise_id].to_i
    execute_add_exercise_to_schedule(schedule_id,exercise_id)
    redirect("/schedules/#{schedule_id}")
end
  
post('/schedules/:schedule_id/:exercise_id/delete') do
    schedule_id = params[:schedule_id].to_i
    exercise_id = params[:exercise_id].to_i
    delete_exercise_from_schedule(schedule_id,exercise_id)
    redirect("/schedules/#{schedule_id}")
end

before('/exercises/new') do
    if logged_in() == false
        redirect('/error')
    end
end

before('/exercises/:id/*') do
    if logged_in() == false
        redirect('/error')
    end
end

# Displays a list of all exercises
#
get('/exercises') do
    exercises_index()
    slim(:"exercises/index")
end

# Displays a form for creating a new exercise
#
get('/exercises/new') do
    slim(:"/exercises/new")
end

# Attempts to create a new exercise
#
# @param [String] name, The name of the exercise
# @param [Integer] id, The id of the muscletype
#
# @see Model#exercises_new
post('/exercises') do
    exercise_name = params[:exercise_name]
    exercise_validator(exercise_name)
    muscle_id = params[:muscle_id].to_i 
    password_exercise_validator(muscle_id)
    exercises_new(exercise_name,muscle_id)
    redirect('/exercises')
end

# Attempts to delete a exercise
#
# @param [Integer] id, The id of the exercise
#
# @see Model#exercises_delete
post('/exercises/:id/delete') do
    exercise_id = params[:id].to_i
    exercises_delete(exercise_id)
    redirect('/exercises')
end

# Attempts to update a exercise
#
# @param [Integer] id, The id of the exercise
# @param [String] name, The name of the exercise
# @param [Integer] id, The id of the muscletype
#
# @see Model#exercises_update
post('/exercises/:id/update') do
    exercise_id = params[:id].to_i
    exercise_name = params[:exercise_name]
    muscle_id = params[:muscle_id].to_i
    exercises_update(exercise_name,muscle_id,exercise_id)
    redirect('/exercises')
end

# Displays a form for editing a exercise
#
# @param [Integer] id, The id of the exercise
# @see Model#exercises_edit
get('/exercises/:id/edit') do
    exercise_id = params[:id].to_i
    exercise_edit(exercise_id)
    slim(:"/exercises/edit")
end

# Displays a specific exercise
#
# @param [Integer] id, The id of the exercise
# @see Model#exercises_show
get('/exercises/:id') do
    exercise_id = params[:id].to_i
    exercise_show(exercise_id)
    slim(:"exercises/show")
end



