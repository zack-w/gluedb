class VocabUploadsController < ApplicationController

  def new
    @vocab_upload = VocabUpload.new(:submitted_by => current_user.email)
  end

  def create
    @vocab_upload = VocabUpload.new(params[:vocab_upload])

    if @vocab_upload.save
      redirect_to new_vocab_upload_path, :flash => { :success => "Upload successful" }
    else
      flash[:error] = '!!!!!! Upload failed !!!!!!!!'
      render :new
    end
  end
end
