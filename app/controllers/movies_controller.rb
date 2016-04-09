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
    if params[:ratings] != nil
      redirect_to by_rating_movies_path(ratings: params[:ratings])
    elsif params[:sort] != nil
      redirect_to reordered_movies_path(sort: params[:sort])
    else
      retrieve_page_data
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

  def by_rating
    @selected_ratings = session[:selected_ratings]
    if @selected_ratings == nil # we have a new session
      @selected_ratings = Movie.ratings
    end

    user_ratings = params[:ratings]
    if user_ratings != nil
      user_ratings = user_ratings.keys
      user_ratings.map { |x| x.to_s }
      @selected_ratings = user_ratings
    end
    
    session[:selected_ratings] = @selected_ratings
    
    retrieve_page_data
    render 'index'
  end
  
  def reordered
    order = session[:order]
    class_date_hilite = session[:class_date_hilite]
    class_title_hilite = session[:class_title_hilite]
    if params[:sort] == "title"
      order = :title
      class_title_hilite = "hilite"
      class_date_hilite = 'none'
    elsif params[:sort] == "date" 
      order = :release_date
      class_date_hilite = "hilite"
      class_title_hilite = 'none'
    end
    
    session[:order] = order
    session[:class_date_hilite] = class_date_hilite
    session[:class_title_hilite] = class_title_hilite
    
    retrieve_page_data
    render 'index'
  end
  
  def retrieve_page_data
    @all_ratings = Movie.ratings
    @selected_ratings = session[:selected_ratings] == nil ? @all_ratings : session[:selected_ratings]
    @class_title_hilite = session[:class_title_hilite] == nil ? 'none' : session[:class_title_hilite]
    @class_date_hilite = session[:class_date_hilite] == nil ? 'none' : session[:class_date_hilite]
    
    order = session[:order]
    if order != nil
      @movies = Movie.where(rating: @selected_ratings).order(order)
    else
      @movies = Movie.where(rating: @selected_ratings)
    end
  end
  
  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end
end
