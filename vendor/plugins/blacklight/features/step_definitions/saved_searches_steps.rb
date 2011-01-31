Given /^I am logged in as "([^\"]*)"$/ do |login|
  email = "#{login}@#{login}.com"
  user = User.create(:login => login, :email => email, :password => "password", :password_confirmation => "password")
  visit user_sessions_path(:user_session => {:login => login, :password => "password"}), :post
  User.find(user.id).should_not be_nil
end

Given /^"([^\"]*)" has saved a search with term "([^\"]*)"$/ do |user, term|
  user = User.find_by_login(user)
  Search.create(:user_id => user.id, :query_params => {:q => term})
end



