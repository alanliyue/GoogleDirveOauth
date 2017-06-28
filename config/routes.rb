Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'documents#list_google_docs'
  get 'oauth2callback' => 'documents#set_google_drive_token' # user return to this after login
  get 'list_google_doc'  => 'documents#list_google_docs', :as => :list_google_doc #for listing the 
  get 'download_google_doc'  => 'documents#download_google_docs', :as => :download_google_doc #download                                                                                #google docs
end
