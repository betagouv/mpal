Rails.application.routes.draw do
  root 'welcome#index'
  scope(path_names: { new: 'nouveau', edit: 'edition' }) do
    resources :projets, only: [:show, :edit, :update] do
      resources :contacts, only: [:create]
    end
  end
  scope(path_names: { new: 'nouvelle' }) do
    resources :sessions, only: [:new, :create]
  end
end 
