module HelperMethods
  # Put helper methods you need to be available in all tests here.
  #
  def sign_in_as(email = "john@doe.com")
    User.create!(user_attributes(email: email)).confirm!

    visit homepage
    click_link 'Sign in'

    fill_in 'Email', with: email
    fill_in 'Password', with: 'asdf1234'
 
    click_button 'Sign in'
  end
end

RSpec.configuration.include HelperMethods, :type => :acceptance
