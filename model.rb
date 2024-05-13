module Model

    # Connects to the database
    #
    # @return [SQLite3::Database] The database
    def connect_database()
        $db = SQLite3::Database.new('db\database.db')
        $db.results_as_hash = true
        return $db
    end
    
    # Finds if user is logged in
    #
    # @return [Boolean] If the user is logged in
    def logged_in()
        return session["id"] != nil
    end

    # Finds if user is admin
    #
    # @return [Boolean] If the user is admin
    def is_admin()
        db = connect_database()
        user_id = session["id"]
        result = db.execute("SELECT admin FROM User WHERE user_id = ?",user_id).first
        return result['admin'] != nil
    end

    # Validates the input for being non-empty
    #
    # @param input [String] The input to validate
    #
    # @return [void] Redirects if input is empty
    #   * :message [String] the error message if input is empty
    def validator(input)
        if input == ""
            flash[:notice] = "You need to write something"
            redirect('/register')
        end
    end

    # Authenticates registration with password confirmation
    #
    # @param username [String] The username for registration
    # @param password_confirm [String] The confirmed password for registration
    # @param password [String] The intended password for registration
    #
    # @return [void] Redirects based on success or failure
    #   * :message [String] the error message if password does not match
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

    # Authenticates a user's login
    #
    # @param username [String] The username of the user trying to log in
    # @param password [String] The password of the user trying to log in
    #
    # @return [void] Redirects based on login success or failure
    def login_authentication(username, password)
        result = $db.execute("SELECT * FROM User WHERE username = ?", username).first
        return nil if result.nil?

        pwdigest = result["pwdigest"]
        if BCrypt::Password.new(pwdigest) == password
            return result["user_id"]
        end

        nil 
    end

    # Attempts to retrieve the main user details
    #
    # @param id [Integer] The user's ID to retrieve details
    #
    # @return [Void] User details as hash
    def main(id)
        @result = $db.execute("SELECT * FROM User WHERE user_id = ?",id).first
    end

    # Attempts to retrieve all schedules for a specific user
    #
    # @param id [Integer] The user's ID whose schedules to retrieve
    #
    # @return [Void] List of schedules as array
    def schedules_index(id)
        @schedules = $db.execute("SELECT * FROM Schedule WHERE user_id = ?",id)
    end

    # Attempts to creates a new schedule for a user
    #
    # @param name [String] The name of the new schedule
    # @param user_id [Integer] The user's ID for who the schedule is created
    #
    # @return [Void] Inserts a new schedule into the database
    def new_schedule(name,user_id)
        $db.execute("INSERT INTO Schedule (name,user_id) VALUES (?,?)",name,user_id)
    end

    # Attempts to deletes a specific schedule by its ID
    #
    # @param id [Integer] The schedule's ID to delete
    #
    # @return [Void] Deletes the schedule and related entries from the database
    def schedule_delete(id)
        $db.execute("DELETE FROM Schedule WHERE id = ?",id)
        $db.execute("DELETE FROM exe_sch_rel WHERE schedule_id = ?",id)
    end

    # Attempts to update the name of an existing schedule
    #
    # @param name [String] The new name for the schedule
    # @param id [Integer] The ID of the schedule to update
    #
    # @return [Void] Updates the schedule's name in the database
    def schedule_update(name,id)
        $db.execute("UPDATE Schedule SET name=? WHERE id = ?", name,id)
    end

    # Attempts to retrieves schedule details for editing
    #
    # @param id [Integer] The schedule's ID to retrieve for editing
    #
    # @return [Void] Schedule details as hash
    def schedule_edit(id)
        @result = $db.execute("SELECT * FROM Schedule WHERE id = ?",id).first
    end

    # Attempts to display information for a specific schedule, including associated exercises
    #
    # @param id [Integer] The schedule's ID to display
    #
    # @return [Void] Information about the schedule and its exercises as hash and array
    def schedule_show(id)
        @result = $db.execute("SELECT * FROM Schedule WHERE id = ?",id).first
        @result2 = $db.execute("SELECT Exercises.exercise_name, Exercises.exercise_id FROM Exercises INNER JOIN exe_sch_rel ON Exercises.exercise_id = exe_sch_rel.exercise_id INNER JOIN Schedule ON exe_sch_rel.schedule_id = Schedule.id WHERE Schedule.id = ?",id)
    end

    # Attempts to prepare a list of exercises that can be added to a schedule
    #
    # @param schedule_id [Integer] The schedule's ID for which exercises are listed
    #
    # @return [Void] List of available exercises as array
    def add_exercise_to_schedule(schedule_id)
        @schedule_id = schedule_id
        @exercises = $db.execute("SELECT exercise_id, exercise_name FROM Exercises")
    end

    # Attempts to add a selected exercise to a schedule
    #
    # @param schedule_id [Integer] The schedule's ID to add an exercise
    # @param exercise_id [Integer] The exercise's ID to add to the schedule
    #
    # @return [Void] Inserts a new entry linking an exercise to a schedule in the database
    def execute_add_exercise_to_schedule(schedule_id,exercise_id)
        $db.execute("INSERT INTO exe_sch_rel (schedule_id, exercise_id) VALUES (?, ?)", schedule_id, exercise_id)
    end

    # Attempts to delete an exercise from a schedule
    #
    # @param schedule_id [Integer] The schedule's ID from which an exercise is deleted
    # @param exercise_id [Integer] The exercise's ID to be deleted from the schedule
    #
    # @return [Void] Deletes the relationship between an exercise and a schedule from the database
    def delete_exercise_from_schedule(schedule_id,exercise_id)
        $db.execute("DELETE FROM exe_sch_rel WHERE schedule_id = ? AND exercise_id = ?",schedule_id,exercise_id)
    end

    # Attempts to retrieve all exercises
    #
    # @return [Void] List of all exercises as array
    def exercises_index()
        @exercises = $db.execute("SELECT * FROM Exercises")
    end

    # Attempts to create a new exercise to the database
    #
    # @param exercise_name [String] The name of the new exercise
    # @param muscle_id [Integer] The ID of the muscle group associated with the new exercise
    #
    # @return [Void] Inserts the new exercise into the database
    def exercises_new(exercise_name,muscle_id)
        $db.execute("INSERT INTO Exercises (exercise_name,muscle_id) VALUES (?,?)",exercise_name,muscle_id)
    end

    # Validates the input for the exercise
    #
    # @param input [String] The input to validate
    #
    # @return [Void] Redirects if input is empty
    #   * :message [String] the error message if input is empty
    def exercise_validator(input)
        if input == ""
            flash[:notice] = "You need to write something"
            redirect('/exercises/new')
        end
    end
    
    # Validates the muscle type id for an exercise within a specified range
    #
    # @param input [Integer] The muscle type id  to validate
    #
    # @return [Void] Redirects if input is not within the valid range
    #   * :message [String] the error message if input is invalid 
    def muscle_exercise_validator(input)
        if input == 0
            flash[:notice] = "You need to write something"
            redirect('/exercises/new')
        end
        if input <= 0 || input > 11
            flash[:notice] = "The muscletype needs to be inbetween 1 and 11"
            redirect('/exercises/new')
        end
    end

    # Attempts to deletes an exercise from the database
    #
    # @param exercise_id [Integer] The ID of the exercise to delete
    #
    # @return [Void] Removes the exercise and related entries from the database
    def exercises_delete(exercise_id)
        $db.execute("DELETE FROM Exercises WHERE exercise_id = ?",exercise_id)
        $db.execute("DELETE FROM exe_sch_rel WHERE exercise_id = ?",exercise_id)
    end 

    # Attempts to update detalis of an existing exercise
    #
    # @param exercise_name [String] The new name of the exercise
    # @param muscle_id [Integer] The new muscle ID of the exercise
    # @param exercise_id [Integer] The ID of the exercise to update
    #
    # @return [Void] Updates the exercise details in the database
    def exercises_update(exercise_name,muscle_id,exercise_id)
        $db.execute("UPDATE Exercises SET exercise_name=?,muscle_id=? WHERE exercise_id = ?", exercise_name,muscle_id,exercise_id)
    end 

    # Attempts to retrieves exercise details for editing
    #
    # @param exercise_id [Integer] The ID of the exercise to edit
    #
    # @return [Void] The exercise details as hash
    def exercise_edit(exercise_id)
        @result = $db.execute("SELECT * FROM Exercises WHERE exercise_id = ?",exercise_id).first
    end

    #Attempts to display information for a specific exercise
    #
    # @param exercise_id [Integer] The ID of the exercise to display
    #
    # @return [Void] Detailed exercise information and associated muscle type as hash
    def exercise_show(exercise_id)
        @result = $db.execute("SELECT * FROM Exercises WHERE exercise_id = ?",exercise_id).first
        @result2 = $db.execute("SELECT Exercises.exercise_name, MuscleTypes.Name FROM Exercises INNER JOIN MuscleTypes ON Exercises.muscle_id = MuscleTypes.id WHERE Exercises.exercise_id = ?",exercise_id).first
    end

    # Finds if user has permissions to view a schedule
    #
    # @return [Boolean] If the user is the owner of a schedule
    def permission(id)
        user = session["id"]
        @result = $db.execute("SELECT user_id FROM Schedule WHERE id = ?",id).first
        return @result["user_id"] == user
    end
    
    
end