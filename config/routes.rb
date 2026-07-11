Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  # Invitation activation (public, token-based).
  get   "activate/:token", to: "invitations#edit",   as: :accept_invitation
  patch "activate/:token", to: "invitations#update"

  # --- Student-facing ---
  resources :courses, only: %i[index show] do
    resources :episodes, only: %i[show] do
      resources :chat_messages, only: %i[create]
    end
  end
  resources :quiz_questions, only: [] do
    resources :quiz_answers, only: %i[create]
  end

  # --- Presentations viewer (all signed-in users; ready presentations only) ---
  resources :presentations, only: %i[index show]
  resources :slides, only: [] do
    resource :answer, only: %i[create], controller: "slide_answers"
  end

  # --- Code snippets (all signed-in users share and browse) ---
  resources :snippets, only: %i[index show new create] do
    resources :code_chat_messages, only: %i[create]
  end

  # --- Library (all signed-in users; read-only document viewing + favorites) ---
  get "library", to: "library#index"
  resources :documents, only: %i[show] do
    member { get :raw }
    resource :favorite, only: %i[create destroy]
  end

  # --- Documents API (shared-secret, for agents) ---
  namespace :api do
    namespace :v1 do
      get "doc_types", to: "meta#doc_types"
      resources :projects, param: :slug, only: %i[index create show] do
        # Upsert / read a document by its type.
        get "documents/:doc_type",  to: "documents#show"
        put "documents/:doc_type",  to: "documents#upsert"
      end
    end
  end

  # --- Admin ---
  namespace :admin do
    root to: "dashboard#index"
    resources :users do
      member { post :resend_invitation }
    end
    resources :activities, only: %i[index]
    resources :projects do
      resources :documents, only: %i[show new create edit update destroy]
    end
    resource :brand_theme, only: %i[edit update]
    resources :uploads, only: %i[new create]
    resources :layouts
    resources :presentations do
      member do
        post :generate_audio
        post :export_pdf
        post :export_movie
        post :publish
      end
    end
    resources :courses do
      resources :episodes do
        resources :markdown_docs, only: %i[create destroy]
        resources :quiz_questions, only: %i[create destroy]
        member do
          post :generate_content    # S14 — AI content
          post :generate_audio      # S15 — Hebrew TTS
          post :generate_thumbnail  # S16 — studio
          post :assemble_movie      # S16 — studio
        end
        resource :studio, only: %i[show], controller: :studios # S16
      end
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  root "courses#index"
end
