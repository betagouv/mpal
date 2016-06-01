Rails.application.routes.draw do
  root 'welcome#index'
  scope(path_names: { new: 'nouveau' }) do
    resources :projets, only: [:new, :create, :show], path: 'projets' do
      resources :contacts, only: [:create]
    end
  end
  scope(path_names: { new: 'nouvelle' }) do
    resources :sessions, only: [:new, :create]
  end
end 
