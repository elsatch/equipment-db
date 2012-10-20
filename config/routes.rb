EquipmentDb::Application.routes.draw do
  devise_for :users

  root      :to => 'home#show'

  resources :devices, :only => [:create, :edit, :new, :show, :update] do
    resources :maintainers, :only => [:create, :destroy, :new]
    resources :owners, :only => [:create, :destroy, :new]
  end

  resources :owners, :only => [:create, :destroy, :index, :new]

  resources :users, :only => [:index, :update]
end
