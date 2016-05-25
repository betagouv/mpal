Rails.application.routes.draw do
  root 'welcome#index'
  scope(path_names: { new: 'nouveau' }) do
    resources :projects, only: [:new, :create], path: 'projets'
  end
end 
