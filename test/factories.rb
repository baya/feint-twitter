
Factory.define(:user) do |u|
  u.username       'nil'
  u.full_name      { |a| "#{a.username} #{%w(chen fenng jiang zhang li)[rand(5)]}"}
  u.password       '123456'
  u.email          { |a| "#{a.username}@t.com".downcase }
end
