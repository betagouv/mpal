class FoldersController < ApplicationController
  def new
    @folder = Folder.new
  end
end
