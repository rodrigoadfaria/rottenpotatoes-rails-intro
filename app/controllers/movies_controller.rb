class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date, :ratings)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.ratings
    
    @selected_ratings = params[:ratings]
    if @selected_ratings != nil
      @selected_ratings = @selected_ratings.keys
      @selected_ratings.map { |x| x.to_s }
    else
      @selected_ratings = Movie.ratings
    end
    
    if params[:sort] == "title"
      order = :title
      @class_title_hilite = "hilite"
    elsif params[:sort] == "date" 
      order = :release_date
      @class_date_hilite = "hilite"
    end
    
    @movies = Movie.where(rating: @selected_ratings)
    if order
      @movies = Movie.where(rating: @selected_ratings).order(order)
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end
end
