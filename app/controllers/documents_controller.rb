require 'google_drive/google_docs'
class DocumentsController < ApplicationController

 before_filter :google_drive_login, :only => [:list_google_docs]



 GOOGLE_CLIENT_ID = "72742964223-khlqe5uhmbnq92ehbgc623cm0f5m6i9j.apps.googleusercontent.com"
 GOOGLE_CLIENT_SECRET = "NbpwRlvnwCCtegH1igV4CBdL"
 GOOGLE_CLIENT_REDIRECT_URI = "http://localhost:3000/oauth2callback"
  # you better put constant like above in environments file, I have put it just for simplicity
  def list_google_docs
    google_doc = GoogleDrive::GoogleDocs.new(GOOGLE_CLIENT_ID,GOOGLE_CLIENT_SECRET,
                GOOGLE_CLIENT_REDIRECT_URI)
    auth_client = google_doc.create_google_client
    auth_token = OAuth2::AccessToken.from_hash(auth_client, session[:google_token])
    google_session = GoogleDrive.login_with_oauth(auth_token)
    @google_docs = []
    begin
      for file in google_session.files
        @google_docs  << file.title     
      end
      rescue Exception => e
        refreshed_token = auth_token.refresh!
        session[:google_token] = refreshed_token.to_hash

    end   
  end

  def download_google_docs
    file_name = params[:doc_upload]
    file_name_session = GoogleDrive.login_with_oauth(session[:google_token])
    file_path = Rails.root.join('tmp', "doc_#{file_name_session}")
    file = google_session.file_by_title(file_name)
    file.download_to_file(file_path)
    redirect_to list_google_doc_path
  end

  def set_google_drive_token
    google_doc = GoogleDrive::GoogleDocs.new(GOOGLE_CLIENT_ID,GOOGLE_CLIENT_SECRET,
                GOOGLE_CLIENT_REDIRECT_URI)
    oauth_client = google_doc.create_google_client
    auth_token = oauth_client.auth_code.get_token(params[:code], 
                 :redirect_uri => GOOGLE_CLIENT_REDIRECT_URI)

    
    session[:google_token] = auth_token.to_hash if auth_token
    redirect_to list_google_doc_path
  end

  def google_drive_login
    unless session[:google_token].present?
      google_drive = GoogleDrive::GoogleDocs.new(GOOGLE_CLIENT_ID,GOOGLE_CLIENT_SECRET,
                     GOOGLE_CLIENT_REDIRECT_URI)
      auth_url = google_drive.set_google_authorize_url
      redirect_to auth_url
    end


  end


end
