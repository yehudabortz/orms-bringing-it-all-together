class Dog

    attr_accessor :id, :name, :breed

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
            );
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
            DROP TABLE IF EXISTS dogs
        SQL
        DB[:conn].execute(sql)
    end
    
    def save
        if self.id
            self.update
        else
            sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
            SQL
            DB[:conn].execute(sql, self.name , self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end

    def self.new_from_db(from_db_array)
        id = from_db_array[0]
        name = from_db_array[1]
        breed = from_db_array[2]
        new_dog = Dog.new(id: id, name: name, breed: breed)
    end

    def self.create(hash_of_attr)
        Dog.new(hash_of_attr).save
    end

    def self.find_by_id(num_id)
        sql = <<-SQL
            SELECT * 
            FROM dogs
            WHERE dogs.id = ?
        SQL
        result = DB[:conn].execute(sql, num_id)[0]
        Dog.new(id: result[0], name: result[1], breed: result[2])
    end
    
    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * 
            FROM dogs
            WHERE dogs.name = ?
        SQL
        result = DB[:conn].execute(sql, name)[0]
        Dog.new(id: result[0], name: result[1], breed: result[2])
    end

    def self.find_or_create_by(hash_of_attr)
        sql = <<-SQL
            SELECT * 
            FROM dogs
            WHERE name = ? 
            AND breed = ?
        SQL
        result = DB[:conn].execute(sql, hash_of_attr[:name], hash_of_attr[:breed])
            if !result.empty?
                dog_result = result[0]
                dog = Dog.new(id: dog_result[0], name: dog_result[1], breed: dog_result[2])
            else
                dog = Dog.create(hash_of_attr)
            end
        dog

    end

    def update
        sql = <<-SQL
            UPDATE dogs
            SET name = ?, breed = ?
            WHERE id = ?
        SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    
end
