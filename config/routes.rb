Jhad::Application.routes.draw do

  

#  authenticated :user do
    # Rails 4 users must specify the 'as' option to give it a unique name
#    root :to => "static_pages#home", :as => "authenticated_root"
#  end 

#  unauthenticated do
#    root 'static_pages#home'
#  end

  root 'dreams#index'

  devise_for :users, path_names: { sign_in: "login", sign_out: "logout" },
                     controllers: { omniauth_callbacks: "omniauth_callbacks", sessions: 'sessions', registrations: 'registrations' }

  devise_scope :user do
    match '/sso',    to: 'discourse_sso#sso',    via: 'get'
  end

  resources :users do
    member do
      get :following, :followers
    end
  end
  resources :dreams do
    resources :comments
    member do
      put 'like', to: "dreams#upvote"
      put "dislike", to: "dreams#downvote"
    end
  end

  resources :articles do
    resources :comments
  end
  
  resources :conversations, only: [:index, :show, :destroy, :new] do
    member do
      post :reply
      post :restore
    end
    collection do
      delete :empty_trash
    end
  end
  resources :messages, only: [:new, :create]
  resources :notifications
  resources :hashtags
  resources :screennames
  resources :relationships, only: [:create, :destroy]
  

  match '/feed',    to: 'static_pages#home',    via: 'get'
  match '/blog',    to: 'articles#index',    via: 'get'
  match '/faq',    to: 'static_pages#faq',    via: 'get'
  match '/resources',    to: 'static_pages#resources',    via: 'get'
  match '/help',    to: 'static_pages#help',    via: 'get'
  match '/about',   to: 'static_pages#about',   via: 'get'
  match '/about2',   to: 'static_pages#about2',   via: 'get'
  match '/contact', to: 'static_pages#contact', via: 'get'
  match '/tos', to: 'static_pages#tos', via: 'get'
  match '/graph', to: 'static_pages#graph', via: 'get'
  match '/test', to: 'static_pages#test', via: 'get'
  match '/search', to: 'static_pages#search', via: 'get'
  match '/sitemap.xml', to: 'static_pages#sitemap', format: 'xml', as: :sitemap, via: 'get'


  

#  match "/users/:id/big", to: 'users#show', impression: 2, via: 'get'
#  match "/users/:id/huge", to: 'users#show', impression: 3, via: 'get'

  

  get 'dreams/new' => 'dreams#new', :as => :new     # For new dream modal
 # get 'dreams/edit' => 'dreams#edit', :as => :edit     # For edit dream modal

  get ':controller(/:action(/:id))'


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
