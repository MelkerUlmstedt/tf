require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'sinatra/reloader'
require 'sinatra/flash'
require_relative './model.rb'

enable :sessions

include Model # Wat dis?

# Connect to database
#
# @see Model#connect_database
before do
    $db = connect_database()
end

# Displays an error message
#
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

# Displays Landing Page
#
# @see Model#main
get('/main') do
    id = session[:id].to_i
    main(id)
    slim(:index)
end

# Attempts login and updates the session, as well as creating user cooldown
#
# @param [String] username, The username
# @param [String] password, The password
#
# @see Model#login_authentication
post('/login') do
    username = params[:username]
    password = params[:password]
    
    if session[:last_login_attempt] && Time.now - session[:last_login_attempt] < 5
        flash[:notice] = "Please wait for 5 seconds after multiple failed login attempts."
        redirect('/')
    end
    
    user_id = login_authentication(username, password)

    if user_id
        session[:id] = user_id
        session[:login_attempts] = 0
        redirect('/main')
    else
        session[:login_attempts] ||= 0
        session[:login_attempts] += 1
        if session[:login_attempts] >= 3
            session[:last_login_attempt] = Time.now
            flash[:notice] = "Too many failed attempts. Please wait for 5 seconds."
            session[:login_attempts] = 0
        else
            flash[:notice] = "Invalid username or password."
        end
        redirect('/')
    end
end

# Attempts logout and updates the session 
#
post('/logout') do
    session[:id] = nil
    redirect('/')
end

# Attempts login and updates the session
#
# @param [String] username, The username
# @param [String] password, The password
# @param [String] repeat-password, The repeated password
#
# @see Model#register_authentication
post('/users/new') do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]

    validator(username)
    validator(password)
  
    register_authentication(username,password_confirm,password)
end

# Check if user is logged in before accessing schedules
#
# @see Model#logged_in
before('/schedules*') do
    if logged_in() == false
        redirect('/error')
    end
end

# Check if user is logged in before accessing main site
#
# @see Model#logged_in
before('/main') do
    if logged_in() == false
        redirect('/error')
    end
end

# Displays a list of all your schedules
#
# @see Model#schedules_index
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
#
# @see Model#schedule_edit
get('/schedules/:id/edit') do
  id = params[:id].to_i
  schedule_edit(id)
  slim(:"/schedules/edit")
end

# Check if user has permissions to access specific schedules as well as if the route is a schedule
#
# @param [Integer] id, The id of the schedule
#
# @see Model#permission
before('/schedules/:id*') do
    id = params[:id].to_i
    if id != 0
        if permission(id) == false
            redirect('/error')
        end
    end
end

# Displays a specific schedule
#
# @param [Integer] id, The id of the schedule
#
# @see Model#schedule_show
get('/schedules/:id') do
    id = params[:id].to_i
    schedule_show(id)
    slim(:"schedules/show")
end

# Displays a form for adding an exercise to a schedule
#
# @param [Integer] id, The id of the schedule
#
# @see Model#add_exercise_to_schedule
get('/schedules/:id/add_exercise') do
    schedule_id = params[:id].to_i
    add_exercise_to_schedule(schedule_id)
    slim(:"schedules/add_exercise")
end

# Attempts to add a new exercise to a schedule
#
# @param [Integer] id, The id of the schedule
# @param [Integer] id, The id of the exercise
#
# @see Model#execute_add_exercise_to_schedule
post('/schedules/:id/add_exercise') do
    schedule_id = params[:id].to_i
    exercise_id = params[:exercise_id].to_i
    execute_add_exercise_to_schedule(schedule_id,exercise_id)
    redirect("/schedules/#{schedule_id}")
end

# Attempts to delete an exercise from a schedule
#
# @param [Integer] id, The id of the exercise
# @param [Integer] id, The id of the schedule
#
# @see Model#delete_exercise_from_schedule
post('/schedules/:schedule_id/:exercise_id/delete') do
    schedule_id = params[:schedule_id].to_i
    exercise_id = params[:exercise_id].to_i
    delete_exercise_from_schedule(schedule_id,exercise_id)
    redirect("/schedules/#{schedule_id}")
end

# Check if user is logged in before creating new exercise
#
# @see Model#logged_in
before('/exercises/new') do
    if logged_in() == false
        redirect('/error')
    end
end

# Check if user is logged in before updating exercise
#
# @see Model#logged_in
# @see Model#is_admin
before('/exercises/:id/*') do
    if logged_in() == false
        redirect('/error')
    end
    if is_admin() == false
        redirect('/error')
    end
end

# Displays a list of all exercises
#
# @see Model#exercises_index
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
# @see Model#exercise_validator
# @see Model#muscle_exercise_validator
post('/exercises') do
    exercise_name = params[:exercise_name]
    exercise_validator(exercise_name)
    muscle_id = params[:muscle_id].to_i 
    muscle_exercise_validator(muscle_id)
    exercises_new(exercise_name,muscle_id)
    redirect('/exercises')
end

# Attempts to delete an exercise
#
# @param [Integer] id, The id of the exercise
#
# @see Model#exercises_delete
post('/exercises/:id/delete') do
    exercise_id = params[:id].to_i
    exercises_delete(exercise_id)
    redirect('/exercises')
end

# Attempts to update an exercise
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

# Displays a form for editing an exercise
#
# @param [Integer] id, The id of the exercise
#
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



