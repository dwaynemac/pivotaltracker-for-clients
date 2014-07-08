class StoriesController < ApplicationController
  def show
    @story = Story.find params[:id]
    @comments = @story.comments
  end
end
