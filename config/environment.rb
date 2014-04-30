# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Gluedb::Application.initialize!

# See Semantic Versioning: http://semver.org/
module VERSION #:nodoc:
  MAJOR = 0
  MINOR = 1
  PATCH = 0

  STRING = [MAJOR, MINOR, PATCH].join('.')

  Date::DATE_FORMATS.merge!(:default => "%m-%d-%Y")
end