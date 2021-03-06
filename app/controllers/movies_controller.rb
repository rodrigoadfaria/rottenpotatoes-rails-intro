class MoviesController < ApplicationController
  
  def initialize
    @all_ratings = Movie.ratings
    super
  end
  
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date, :ratings)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    to_b_redirected = false

    user_ratings = params[:ratings]
    if user_ratings != nil
      if user_ratings.is_a?(Hash)
        user_ratings = user_ratings.keys
        user_ratings.map { |x| x.to_s }
      end
      @selected_ratings = user_ratings
      
    elsif session[:selected_ratings]
      @selected_ratings = session[:selected_ratings]
      to_b_redirected = true
    else
      @selected_ratings = @all_ratings
      to_b_redirected = true
    end
    
    if params[:sort]
      @order = params[:sort]
    elsif
      @order = session[:order]
      to_b_redirected = true
    end
    
    if to_b_redirected
      redirect_to movies_path(:sort => @order, :ratings => @selected_ratings)
    end

    @movies = Movie.where(rating: @selected_ratings)
    if @order != nil
      if @order == 'title'
        @class_title = 'hilite'
        @class_date = 'none' 
      else
        @class_title = 'none'
        @class_date = 'hilite' 
      end
      
      @movies = Movie.where(rating: @selected_ratings).order(@order)
    end
    
    session[:selected_ratings] = @selected_ratings
    session[:order] = @order
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
  
  def to_json
    @movie = Movie.find(params[:id])
    render :json => @movie
  end
end
