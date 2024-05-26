import mysql.connector
import bcrypt
import getpass
import os

# Utility functions for hashing and verifying passwords
def hash_password(password):
    salt = bcrypt.gensalt()
    hashed_password = bcrypt.hashpw(password.encode('utf-8'), salt)
    return hashed_password.decode('utf-8')

def verify_password(stored_hash, provided_password):
    return bcrypt.checkpw(provided_password.encode('utf-8'), stored_hash.encode('utf-8'))

# Connect to MySQL server (not a specific database)
def connect_server():
    host = input("Enter MySQL server host (e.g., '127.0.0.1'): ")
    port = input("Enter MySQL server port (e.g., '3307'): ")
    user = input("Enter MySQL server user (e.g., 'root'): ")
    password = getpass.getpass("Enter MySQL server password: ")
    
    try:
        conn = mysql.connector.connect(
            host=host,
            port=port,
            user=user,
            password=password
        )
        return conn, host, port, user, password
    except mysql.connector.Error as err:
        print(f"Error: {err}")
        exit(1)

# Connect to a specific database
def connect_db(host, port, user, password, database):
    try:
        return mysql.connector.connect(
            host=host,
            port=port,
            user=user,
            password=password,
            database=database
        )
    except mysql.connector.Error as err:
        print(f"Error: {err}")
        exit(1)

# Function to execute DDL and DML from files
def execute_sql_file(cursor, sql_file):
    with open(sql_file, 'r') as file:
        sql_script = file.read()
    
    # Split the script into individual statements
    statements = sql_script.split(';')
    for statement in statements:
        if statement.strip():
            try:
                cursor.execute(statement.strip() + ';')
            except mysql.connector.Error as err:
                print(f"Error executing statement: {statement.strip()};")
                print(f"MySQL Error: {err}")
                break

# Create a new database and execute DDL and DML files
def create_database(conn, host, port, user, password):
    cursor = conn.cursor()
    database_name = input("Enter the name of the new database: ")

    try:
        cursor.execute(f"CREATE DATABASE {database_name}")
        print(f"Database '{database_name}' created successfully!")
    except mysql.connector.Error as err:
        print(f"Failed creating database: {err}")
        exit(1)

    conn.close()

    # Connect to the new database and execute DDL and DML files
    conn = connect_db(host, port, user, password, database_name)
    cursor = conn.cursor()

    ddl_file = 'ddl.sql'  # Assuming the DDL file is named ddl.sql and is in the same directory
    execute_sql_file(cursor, ddl_file)



    dml_file = 'dml.sql'  # Assuming the DML file is named dml.sql and is in the same directory
    execute_sql_file(cursor, dml_file)
    conn.commit()
    print("Tables created and initial data inserted successfully!")

    # Prompt for admin account details
    admin_username = input("Enter admin username: ")
    admin_password = getpass.getpass("Enter admin password: ")
    hashed_password = hash_password(admin_password)

    cursor.execute("INSERT INTO users (username, password, role) VALUES (%s, %s, 'admin')",
                   (admin_username, hashed_password))
    conn.commit()

    print("Admin account created successfully!")

    cursor.close()
    conn.close()
    return database_name

# User authentication
def authenticate_user(host, port, user, password, database, username, user_password):
    conn = connect_db(host, port, user, password, database)
    cursor = conn.cursor(dictionary=True)
    
    cursor.execute("SELECT user_id, password, role FROM users WHERE username = %s", (username,))
    user = cursor.fetchone()
    cursor.close()
    conn.close()
    
    if user and verify_password(user['password'], user_password):
        return user['user_id'], user['role']
    return None, None

# Check if username exists
def check_username_exists(host, port, user, password, database, username):
    conn = connect_db(host, port, user, password, database)
    cursor = conn.cursor()
    
    cursor.execute("SELECT username FROM users WHERE username = %s", (username,))
    user = cursor.fetchone()
    cursor.close()
    conn.close()
    
    return user is not None

# Create a new cook account
def create_cook_account(host, port, user, password, database, phone_number, username, user_password):
    conn = connect_db(host, port, user, password, database)
    cursor = conn.cursor(dictionary=True)
    
    cursor.execute("SELECT cook_id FROM cooks WHERE phone_number = %s", (phone_number,))
    cook = cursor.fetchone()
    
    if not cook:
        cursor.close()
        conn.close()
        return False, "Phone number not found."

    cook_id = cook['cook_id']
    hashed_password = hash_password(user_password)
    
    try:
        cursor.execute("INSERT INTO users (username, password, role) VALUES (%s, %s, 'user')", (username, hashed_password))
        conn.commit()
        user_id = cursor.lastrowid
        cursor.execute("UPDATE cooks SET user_id = %s WHERE cook_id = %s", (user_id, cook_id))
        conn.commit()
        cursor.close()
        conn.close()
        return True, "Account created successfully"
    except mysql.connector.IntegrityError as err:
        cursor.close()
        conn.close()
        return False, f"An error occurred: {err}"

# Add a new recipe
def add_recipe(host, port, user, password, database, user_id, recipe_name, recipe_description, recipe_type, difficulty, prep_time, cooking_time, portions, ingredients_ingredient_id, national_cuisine_national_cuisine_id):
    conn = connect_db(host, port, user, password, database)
    cursor = conn.cursor()
    
    cursor.execute("INSERT INTO recipes (name, description, type, difficulty, prep_time, cooking_time, portions, ingredients_ingredient_id, national_cuisine_national_cuisine_id) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)",
                   (recipe_name, recipe_description, recipe_type, difficulty, prep_time, cooking_time, portions, ingredients_ingredient_id, national_cuisine_national_cuisine_id))
    recipe_id = cursor.lastrowid
    cursor.execute("INSERT INTO recipes_has_cooks (recipes_recipe_id, cooks_cook_id) VALUES (%s, (SELECT cook_id FROM cooks WHERE user_id = %s))", (recipe_id, user_id))
    conn.commit()
    cursor.close()
    conn.close()

# Modify an existing recipe
def modify_recipe(host, port, user, password, database, user_id, role, recipe_id, recipe_name, recipe_description):
    conn = connect_db(host, port, user, password, database)
    cursor = conn.cursor(dictionary=True)

    try:
        # Check if the recipe belongs to the user or if the user is an admin
        if role != 'admin':
            cursor.execute("SELECT cook_id FROM cooks WHERE user_id = %s", (user_id,))
            cook = cursor.fetchone()

            if not cook:
                print("Cook not found.")
                cursor.close()
                conn.close()
                return

            cook_id = cook['cook_id']

            cursor.execute("SELECT cooks_cook_id FROM recipes_has_cooks WHERE recipes_recipe_id = %s AND cooks_cook_id = %s", (recipe_id, cook_id))
            cook_association = cursor.fetchone()

            if not cook_association:
                print("You can't do that. This recipe does not belong to you.")
                cursor.close()
                conn.close()
                return

        cursor.execute("SELECT name, description FROM recipes WHERE recipe_id = %s", (recipe_id,))
        recipe = cursor.fetchone()

        if not recipe:
            print("Recipe not found.")
            cursor.close()
            conn.close()
            return

        # Maintain current values if "no change" is input
        if recipe_name.lower() == "no change":
            recipe_name = recipe['name']
        if recipe_description.lower() == "no change":
            recipe_description = recipe['description']

        cursor.execute("UPDATE recipes SET name = %s, description = %s WHERE recipe_id = %s",
                       (recipe_name, recipe_description, recipe_id))
        conn.commit()
        print("Recipe modified successfully!")
    
    except mysql.connector.Error as err:
        print(f"Error: {err}")
    finally:
        cursor.close()
        conn.close()

# Update cook information
def update_cook_info(host, port, user, password, database, user_id, first_name, last_name, phone_number, date_of_birth, age, role, years_of_experience):
    conn = connect_db(host, port, user, password, database)
    cursor = conn.cursor(dictionary=True)
    
    cursor.execute("SELECT cook_id FROM cooks WHERE user_id = %s", (user_id,))
    cook = cursor.fetchone()
    if not cook:
        print("Cook not found.")
        cursor.close()
        conn.close()
        return

    cook_id = cook['cook_id']
    
    if first_name.lower() == "no change":
        cursor.execute("SELECT first_name FROM cooks WHERE cook_id = %s", (cook_id,))
        first_name = cursor.fetchone()['first_name']
    if last_name.lower() == "no change":
        cursor.execute("SELECT last_name FROM cooks WHERE cook_id = %s", (cook_id,))
        last_name = cursor.fetchone()['last_name']
    if phone_number.lower() == "no change":
        cursor.execute("SELECT phone_number FROM cooks WHERE cook_id = %s", (cook_id,))
        phone_number = cursor.fetchone()['phone_number']
    if date_of_birth.lower() == "no change":
        cursor.execute("SELECT date_of_birth FROM cooks WHERE cook_id = %s", (cook_id,))
        date_of_birth = cursor.fetchone()['date_of_birth']
    if age.lower() == "no change":
        cursor.execute("SELECT age FROM cooks WHERE cook_id = %s", (cook_id,))
        age = cursor.fetchone()['age']
    if role.lower() == "no change":
        cursor.execute("SELECT role FROM cooks WHERE cook_id = %s", (cook_id,))
        role = cursor.fetchone()['role']
    if years_of_experience.lower() == "no change":
        cursor.execute("SELECT years_of_experience FROM cooks WHERE cook_id = %s", (cook_id,))
        years_of_experience = cursor.fetchone()['years_of_experience']

    cursor.execute("UPDATE cooks SET first_name = %s, last_name = %s, phone_number = %s, date_of_birth = %s, age = %s, role = %s, years_of_experience = %s WHERE cook_id = %s",
                   (first_name, last_name, phone_number, date_of_birth, age, role, years_of_experience, cook_id))
    conn.commit()
    print("Cook information updated successfully!")

    cursor.close()
    conn.close()

# User Menu for Custom Queries
def execute_user_query(host, port, user, password, database, user_id, role):
    while True:
        print("\nUser Query Menu:")
        print("1. Add a new recipe")
        print("2. Modify an existing recipe")
        print("3. Update personal information")
        print("4. Exit")
        
        user_query_choice = input("Enter your choice: ").strip()
        
        if user_query_choice == '1':
            recipe_name = input("Enter recipe name: ")
            recipe_description = input("Enter recipe description: ")
            recipe_type = input("Enter recipe type (COOKING/BAKING): ")
            difficulty = input("Enter difficulty (VERY_EASY/EASY/NORMAL/DIFFICULT/VERY_DIFFICULT): ")
            prep_time = input("Enter preparation time (minutes): ")
            cooking_time = input("Enter cooking time (minutes): ")
            portions = input("Enter number of portions: ")
            ingredients_ingredient_id = input("Enter ingredient ID: ")
            national_cuisine_national_cuisine_id = input("Enter national cuisine ID: ")
            
            try:
                prep_time = int(prep_time)
                cooking_time = int(cooking_time)
                portions = int(portions)
                ingredients_ingredient_id = int(ingredients_ingredient_id)
                national_cuisine_national_cuisine_id = int(national_cuisine_national_cuisine_id)
            except ValueError:
                print("Error: Ensure that prep_time, cooking_time, portions, ingredients_ingredient_id, and national_cuisine_national_cuisine_id are integers.")
                continue
            
            add_recipe(host, port, user, password, database, user_id, recipe_name, recipe_description, recipe_type, difficulty, prep_time, cooking_time, portions, ingredients_ingredient_id, national_cuisine_national_cuisine_id)
        
        elif user_query_choice == '2':
            recipe_id = input("Enter recipe ID to modify: ")
            recipe_name = input("Enter new recipe name (or 'no change' to keep current): ")
            recipe_description = input("Enter new recipe description (or 'no change' to keep current): ")
            
            try:
                recipe_id = int(recipe_id)
            except ValueError:
                print("Error: Recipe ID should be an integer.")
                continue
            
            modify_recipe(host, port, user, password, database, user_id, role, recipe_id, recipe_name, recipe_description)
        
        elif user_query_choice == '3':
            first_name = input("Enter new first name (or 'no change' to keep current): ")
            last_name = input("Enter new last name (or 'no change' to keep current): ")
            phone_number = input("Enter new phone number (or 'no change' to keep current): ")
            date_of_birth = input("Enter new date of birth (YYYY-MM-DD or 'no change' to keep current): ")
            age = input("Enter new age (or 'no change' to keep current): ")
            role = input("Enter new role (A/B/C/SOUS_CHEF/CHEF or 'no change' to keep current): ")
            years_of_experience = input("Enter new years of experience (or 'no change' to keep current): ")
            
            update_cook_info(host, port, user, password, database, user_id, first_name, last_name, phone_number, date_of_birth, age, role, years_of_experience)
        
        elif user_query_choice == '4':
            break
        
        else:
            print("Invalid choice, please try again.")

# Admin Menu for Custom Queries
def execute_admin_query(host, port, user, password, database):
    conn = connect_db(host, port, user, password, database)
    cursor = conn.cursor()
    while True:
        query = input("Enter your SQL query (or type 'exit' to log out): ").strip()
        if query.lower() == 'exit':
            break
        
        try:
            cursor.execute(query)
            conn.commit()
            results = cursor.fetchall()
            for row in results:
                print(row)
        except mysql.connector.Error as err:
            print(f"Error: {err}")
    
    cursor.close()
    conn.close()

# Backup the database
def backup_database(host, port, user, password, database):
    backup_file = input("Enter the backup file name (e.g., backup.sql): ")
    command = f"mysqldump -u {user} -p{password} -h {host} --port={port} {database} > {backup_file}"
    os.system(command)
    print("Database backup completed successfully!")

# Restore the database
def restore_database(host, port, user, password, database):
    backup_file = input("Enter the backup file name (e.g., backup.sql): ")
    command = f"mysql -u {user} -p{password} -h {host} --port={port} {database} < {backup_file}"
    os.system(command)
    print("Database restore completed successfully!")

# Main script logic
def main():
    print("--Welcome--")
    
    host = None
    port = None
    user = None
    password = None
    
    while True:
        print("\nMain Menu:")
        print("1. Create a new database")
        print("2. Connect to an existing database")
        print("3. Exit")
        
        choice = input("Enter your choice: ")
        
        if choice == '1':
            conn, host, port, user, password = connect_server()
            database_name = create_database(conn, host, port, user, password)
        elif choice == '2':
            host = input("Enter MySQL server host (e.g., '127.0.0.1'): ")
            port = input("Enter MySQL server port (e.g., '3306'): ")
            user = input("Enter MySQL server user (e.g., 'root'): ")
            password = getpass.getpass("Enter MySQL server password: ")
            database_name = input("Enter the name of the existing database: ")
            conn = connect_db(host, port, user, password, database_name)
            conn.close()
            
            # Prompt for admin credentials
            print("Please enter admin credentials to proceed:")
            admin_username = input("Enter admin username: ")
            admin_password = getpass.getpass("Enter admin password: ")
            admin_id, role = authenticate_user(host, port, user, password, database_name, admin_username, admin_password)
            
            if admin_id and role == 'admin':
                print("Admin authenticated successfully!")
            else:
                print("Authentication failed, please try again.")
                continue

        elif choice == '3':
            print("Goodbye!")
            break
        else:
            print("Invalid choice, please try again.")
            continue

        while True:
            print("\nUser Menu:")
            print("1. Log in as user")
            print("2. Log in as admin")
            print("3. Create an account")
            print("4. Exit")
            
            user_choice = input("Enter your choice: ")
            
            if user_choice == '1':
                username = input("Enter username: ")
                user_password = getpass.getpass("Enter password: ")
                
                user_id, role = authenticate_user(host, port, user, password, database_name, username, user_password)
                
                if user_id:
                    print(f"Welcome, {username}!")
                    
                    while True:
                        execute_user_query(host, port, user, password, database_name, user_id, role)
                        break
                else:
                    print("Authentication failed, please try again.")
            
            elif user_choice == '2':
                username = input("Enter admin username: ")
                user_password = getpass.getpass("Enter admin password: ")
                
                user_id, role = authenticate_user(host, port, user, password, database_name, username, user_password)
                
                if user_id and role == 'admin':
                    print(f"Welcome, {username} (admin)!")
                    
                    while True:
                        print("\nAdmin Menu:")
                        print("1. Backup database")
                        print("2. Restore database")
                        print("3. Execute custom query")
                        print("4. Log out")
                        
                        admin_choice = input("Enter your choice: ")
                        
                        if admin_choice == '1':
                            backup_database(host, port, user, password, database_name)
                        
                        elif admin_choice == '2':
                            restore_database(host, port, user, password, database_name)
                        
                        elif admin_choice == '3':
                            execute_admin_query(host, port, user, password, database_name)
                        
                        elif admin_choice == '4':
                            print("Logging out...")
                            break
                        
                        else:
                            print("Invalid choice, please try again.")
                else:
                    print("Authentication failed or you are not an admin, please try again.")
            
            elif user_choice == '3':
                while True:
                    print("--Creating a cook account--")
                    phone_number = input("Enter phone number: ")
                    username = input("Enter new username: ")
                    user_password = getpass.getpass("Enter new password: ")
                    success, message = create_cook_account(host, port, user, password, database_name, phone_number, username, user_password)
                    print(message)
                    if success:
                        break
            
            elif user_choice == '4':
                print("Goodbye!")
                break
            
            else:
                print("Invalid choice, please try again.")

if __name__ == "__main__":
    main()


