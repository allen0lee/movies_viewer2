create database movie_app;

create table movies(
    id SERIAL PRIMARY KEY,
    title TEXT,
    poster_url TEXT,
    year INTEGER,
    rated TEXT,
    runtime TEXT,
    director TEXT,
    actors TEXT,
    imdb_rating REAL,
    plot TEXT
);