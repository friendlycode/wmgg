class SearchController < ApplicationController
  def index
    query =  params[:q].strip 
    return redirect_to root_path if params[:q].blank? 
    @query = query

    # remove puntuation and plurals.
    query = query.downcase.gsub(/[^\w]/, ' ').gsub(/ . /, ' ')

    # spell check the query.  if no correction has taken place, this is nil.
    @query_corrected = Article.spell_check query

    # remove stop words
    query = Article.remove_stop_words query

    # Searchify can't handle requests longer than this (because of query expansion + Tanker inefficencies.  >10 can result in >8000 byte request strings)
    if query.split.size > 10 || query.blank?
      @query_corrected = query
      @results = []
      return
    end

    # expand the query
    query_final = Article.expand_query( query )
    
    # perform the search
    @results = Article.search_tank( query_final)#, :conditions => { :is_published => true } )

    # Log the search results
    puts "search-request: IP:#{request.env['REMOTE_ADDR']}, params[:query]:#{query}, QUERY:#{query_final}, FIRST_RESULT:#{@results.first.title unless @results.empty?}, RESULTS_N:#{@results.size}" 

  end
  
end
