class ProjectsController < ApplicationController
  def new
    @project = Project.new
  end

  def create
    @project = Project.new(params[:project])
    @project.valid? ? render(:create) : render(:new)
  end
end
