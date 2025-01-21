Rails.application.routes.draw do
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end


  mount Decidim::Core::Engine => '/'


  match '/account/regix', to: 'decidim/account#regix', via: 'get', as: :regix_account

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
