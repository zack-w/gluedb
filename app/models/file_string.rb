class FileString < StringIO
  attr_accessor :filepath

  def initialize(f_name, *args)
    super(*args)
    @filepath = f_name
  end

  def original_filename
    File.basename(@filepath)
  end
end
