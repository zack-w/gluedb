module SimpleConverters
  def safe_downcase(val)
    val.blank? ? val : val.downcase.strip
  end

  def date_string(val)
    val.blank? ? "" : val.strftime("%Y%m%d")
  end
end
