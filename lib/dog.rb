require 'sqlite3'

DB = {:conn => SQLite3::Database.new("db/dogs.db")}

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
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      update
    else
      sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
      DB[:conn].execute(sql, self.name, self.breed)
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
  end

  def self.new_from_db(row)
    id, name, breed = row
    Dog.new(id: id, name: name, breed: breed)
  end

  def self.all
    sql = "SELECT * FROM dogs"
    result = DB[:conn].execute(sql)
    result.map { |row| new_from_db(row) }
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1"
    result = DB[:conn].execute(sql, name)
    new_from_db(result[0]) if result[0]
  end

  def self.find(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    result = DB[:conn].execute(sql, id)
    new_from_db(result[0]) if result[0]
  end
end

