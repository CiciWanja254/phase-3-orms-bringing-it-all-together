require_relative '../lib/dog'

DB = { conn: SQLite3::Database.new("db/dogs.db") }

Dog.create_table
