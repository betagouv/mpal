class FoldersController < ApplicationController
  def new
    @folder = Folder.new
  end

  def create
    @folder = Folder.new(params[:folder])
    @folder.valid? ? render(:create) : render(:new)
  end
end
