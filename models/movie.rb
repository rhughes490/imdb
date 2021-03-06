require_relative('../db/sql_runner')
require_relative('../models/star')

class Movie
    attr_reader :id
    attr_accessor :title, :genre

    def initialize(options)
        @id = options['id'].to_i if options['id']
        @title = options['title']
        @genre = options['genre']
    end

    def save()
        sql = "INSERT INTO movies (title, genre)
            VALUES ($1, $2)
            RETURNING id"
        values = [@title, @genre]
        result = SqlRunner.run(sql, values)
        @id = result[0]["id"].to_i
        return @id
    end

    def delete()
        sql = "DELETE FROM movies WHERE id = $1"
        values = [@id]
        SqlRunner.run(sql, values)
    end

    def Movie.all()
        sql = "SELECT * FROM movies"
        movies = SqlRunner.run(sql)
        return Movie.map_items(movies)
    end

    def Movie.delete_all()
        sql = "DELETE FROM movies"
        movies = SqlRunner.run(sql)
    end

    def Movie.map_items(array)
        return array.map{ |options| Movie.new(options) }
    end

    def stars
        sql = "SELECT stars.* FROM stars 
                INNER JOIN castings
                ON castings.star_id = stars.id
                WHERE castings.movie_id = $1"
        values = [@id]
        movies = SqlRunner.run(sql, values)
        return Star.map_items(movies)
    end
end
