Rails.application.routes.draw do
  root 'welcome#index'
  scope(path_names: { new: 'nouveau' }) do
    resources :folders, only: [:new, :create], path: 'dossiers'
  end
end 
