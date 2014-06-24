class VocabUploadsController < ApplicationController

  def new
    @vocab_upload = VocabUpload.new(:submitted_by => current_user.email)
  end

  def create
    @vocab_upload = VocabUpload.new(params[:vocab_upload])

    if @vocab_upload.save(self)
      flash_message(:success, "Upload successful")
      redirect_to new_vocab_upload_path
    else
      flash_message(:error, "Upload failed")
      render :new
    end
  end

  def incorrect_member_premium
    flash_message(:premium_error, 'An individual\'s premium_amount is incorrect')
  end

  def incorrect_premium_total
    flash_message(:premium_total_error, 'premium_amount_total is incorrect')
  end

  def incorrect_member_responsible_amount
    flash_message(:responsible_amount_error, 'total_responsible_amount is incorrect')
  end
end
