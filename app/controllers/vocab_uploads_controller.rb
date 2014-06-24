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

  def corrected_member_premium(change)
    flash_message(:notice, "#{change[:who]}'s premium_amount has been corrected (from $#{change[:from]} to $#{change[:to]})")
  end

  def corrected_premium_total(change)
    flash_message(:notice, "premium_amount_total has been corrected (from $#{change[:from]} to $#{change[:to]})")
  end

  def corrected_member_responsible_amount(change)
    flash_message(:notice, "total_responsible_amount has been corrected (from $#{change[:from]} to $#{change[:to]})")
  end
end