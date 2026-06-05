Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "dashboard#index"

  resources :resumes, only: %i[index new create show] do
    member do
      get :hh_vacancies
    end
  end

  resources :vacancies, only: %i[index new create show] do
    member do
      post :compute_matches
    end
  end

  resources :match_scores, only: %i[index]

  namespace :api do
    resources :resumes, only: [] do
      member do
        get :hh_vacancies
      end
    end
  end
end
