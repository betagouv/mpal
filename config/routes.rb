Rails.application.routes.draw do
  root 'welcome#index'
  scope(path_names: { new: 'nouveau' }) do
    resources :projets, only: [:new, :create, :show], path: 'projets'
  end
end 
