module Model

    def connect_database()
        $db = SQLite3::Database.new('db\database.db')
        $db.results_as_hash = true
        return $db
    end

    def logged_in()
        return session["id"] != nil
    end

    def is_admin()
        db = connect_database()
        user_id = session["id"]
        result = db.execute("SELECT admin FROM User WHERE user_id = ?",user_id).first
        return result['admin'] != nil
    end

    def validator(input)
        if input == ""
            flash[:notice] = "You need to write something"
            redirect('/register')
        end
    end

    def register_authentication(username,password_confirm,password)
        if (password_confirm == password)
            password_digest = BCrypt::Password.create(password)
            $db.execute("INSERT INTO User (username,pwdigest) VALUES (?,?)",username,password_digest)
            redirect('/')
        else
            flash[:notice] = "Lösenorden matcher ej"
            redirect('/register')
        end
    end

    def login_authentication(username, password)
        result = $db.execute("SELECT * FROM User WHERE username = ?",username).first
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

    def main(id)
        @result = $db.execute("SELECT * FROM User WHERE user_id = ?",id).first
    end

    def schedules_index(id)
        @schedules = $db.execute("SELECT * FROM Schedule WHERE user_id = ?",id)
    end

    def new_schedule(name,user_id)
        $db.execute("INSERT INTO Schedule (name,user_id) VALUES (?,?)",name,user_id)
    end

    def schedule_delete(id)
        $db.execute("DELETE FROM Schedule WHERE id = ?",id)
        $db.execute("DELETE FROM exe_sch_rel WHERE schedule_id = ?",id)
    end

    def schedule_update(name,id)
        $db.execute("UPDATE Schedule SET name=? WHERE id = ?", name,id)
    end

    def schedule_edit(id)
        @result = $db.execute("SELECT * FROM Schedule WHERE id = ?",id).first
    end

    def schedule_show(id)
        @result = $db.execute("SELECT * FROM Schedule WHERE id = ?",id).first
        @result2 = $db.execute("SELECT Exercises.exercise_name, Exercises.exercise_id FROM Exercises INNER JOIN exe_sch_rel ON Exercises.exercise_id = exe_sch_rel.exercise_id INNER JOIN Schedule ON exe_sch_rel.schedule_id = Schedule.id WHERE Schedule.id = ?",id)
    end

    def add_exercise_to_schedule(schedule_id)
        @schedule_id = schedule_id
        @exercises = $db.execute("SELECT exercise_id, exercise_name FROM Exercises")
    end

    def execute_add_exercise_to_schedule(schedule_id,exercise_id)
        $db.execute("INSERT INTO exe_sch_rel (schedule_id, exercise_id) VALUES (?, ?)", schedule_id, exercise_id)
    end

    def delete_exercise_from_schedule(schedule_id,exercise_id)
        $db.execute("DELETE FROM exe_sch_rel WHERE schedule_id = ? AND exercise_id = ?",schedule_id,exercise_id)
    end

    def exercises_index()
        @exercises = $db.execute("SELECT * FROM Exercises")
    end

    def exercises_new(exercise_name,muscle_id)
        $db.execute("INSERT INTO Exercises (exercise_name,muscle_id) VALUES (?,?)",exercise_name,muscle_id)
    end

    def exercise_validator(input)
        if input == ""
            flash[:notice] = "You need to write something"
            redirect('/exercises/new')
        end
    end
    
    def password_exercise_validator(input)
        if input == 0
            flash[:notice] = "You need to write something"
            redirect('/exercises/new')
        end
        if input <= 0 || input > 11
            flash[:notice] = "The muscletype needs to be inbetween 1 and 11"
            redirect('/exercises/new')
        end
    end

    def exercises_delete(exercise_id)
        $db.execute("DELETE FROM Exercises WHERE exercise_id = ?",exercise_id)
        $db.execute("DELETE FROM exe_sch_rel WHERE exercise_id = ?",exercise_id)
    end 

    def exercises_update(exercise_name,muscle_id,exercise_id)
        $db.execute("UPDATE Exercises SET exercise_name=?,muscle_id=? WHERE exercise_id = ?", exercise_name,muscle_id,exercise_id)
    end 

    def exercise_edit(exercise_id)
        @result = $db.execute("SELECT * FROM Exercises WHERE exercise_id = ?",exercise_id).first
    end

    def exercise_show(exercise_id)
        @result = $db.execute("SELECT * FROM Exercises WHERE exercise_id = ?",exercise_id).first
        @result2 = $db.execute("SELECT Exercises.exercise_name, MuscleTypes.Name FROM Exercises INNER JOIN MuscleTypes ON Exercises.muscle_id = MuscleTypes.id WHERE Exercises.exercise_id = ?",exercise_id).first
    end
end