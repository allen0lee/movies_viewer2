require 'sinatra'
require 'pry'
require 'sinatra/reloader' if settings.development?
require 'httparty'
require 'active_record'
require_relative 'db_config'
require_relative 'models/movie.rb'

get "/" do
    @popular_movies = Movie.last(5)
    erb(:index)
end

get "/home" do
    @popular_movies = Movie.last(5)
    erb(:index)
end

get '/movie' do  
    title = URI.escape(params['title']) # deal with special character like: Amélie

    #get response back from omdb api in json
    url = "http://www.omdbapi.com/?s=#{title}&apikey=2f6435d9"
    result = HTTParty.get(url) # convert json to ruby hash

    if result["Response"] == "False"
        erb(:not_found)
    else
        @search_list_titles = []
        @movie_list = result["Search"]

        result["Search"].each do |hash|
            @search_list_titles.push(hash["Title"])
        end

        if @search_list_titles.length == 1
            # if movie is not in my db, make new request from omdb
            if Movie.where(title: @search_list_titles.first).empty? == true
                @title = @search_list_titles.first

                new_url = "http://www.omdbapi.com/?t=#{@title}&apikey=2f6435d9"
                new_result = HTTParty.get(new_url)

                @poster = new_result["Poster"]
                @year = new_result["Year"]
                @rated = new_result["Rated"]
                @runtime = new_result["Runtime"]
                @director = new_result["Director"]
                @actors = new_result["Actors"]
                @imdb_rating = new_result["imdbRating"]
                @plot = new_result["Plot"]
    
                # save information to my db
                movie = Movie.new
                movie.title = @title
                movie.poster_url = @poster
                movie.year = @year
                movie.rated = @rated
                movie.runtime = @runtime
                movie.director = @director
                movie.actors = @actors
                movie.imdb_rating = @imdb_rating
                movie.plot = @plot
                movie.save

                erb(:movie)
            else
                redirect "/movie_infor/#{title}"
            end

        elsif @search_list_titles.length > 1
            erb(:search_list_page)
        end
    end
end

# in search list, when click a movie, go to single movie page
get '/movie_infor/:movie_title' do
    # if movie is not in my db, make new request from omdb
    if Movie.where(title: params[:movie_title]).empty? == true
        title = URI.escape(params[:movie_title])

        movie_url = "http://www.omdbapi.com/?t=#{title}&apikey=2f6435d9"
        movie_details = HTTParty.get(movie_url)

        @poster = movie_details["Poster"]
        @title = movie_details["Title"]
        @year = movie_details["Year"]
        @rated = movie_details["Rated"]
        @runtime = movie_details["Runtime"]
        @director = movie_details["Director"]
        @actors = movie_details["Actors"]
        @imdb_rating = movie_details["imdbRating"]
        @plot = movie_details["Plot"]

        # save information to my db
        movie = Movie.new
        movie.title = @title
        movie.poster_url = @poster
        movie.year = @year
        movie.rated = @rated
        movie.runtime = @runtime
        movie.director = @director
        movie.actors = @actors
        movie.imdb_rating = @imdb_rating
        movie.plot = @plot
        movie.save

        erb(:movie)
    else 
        # request data from my db
        movie = Movie.where(title: params[:movie_title]).first
                
        @title = movie.title
        @poster = movie.poster_url
        @year = movie.year
        @rated = movie.rated
        @runtime = movie.runtime
        @director = movie.director
        @actors = movie.actors
        @imdb_rating = movie.imdb_rating
        @plot = movie.plot

        erb(:movie)
    end
end

get '/about' do
    erb(:about) # -> give back string and put it in a file
end


# @ in sinatra is a shortcut to use a variable in template(erb), has nth to do with oop
# params['title'] # title user gives