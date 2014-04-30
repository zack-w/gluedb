users = User.all

users.each do |u|
  puts <<-UTEMPLATE
  add_a_user(
    "#{u.email}",
    "#{u.encrypted_password}"
  )
UTEMPLATE
end
