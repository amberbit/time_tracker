require File.dirname(__FILE__) + '/acceptance_helper'

feature "User Registration", %q{
  In order to get access to the systen
  As an anonymous user
  I want to create an account
} do

  scenario "successful" do
    visit homepage
    click_link 'Sign up'

    fill_in 'Email', with: 'john.doe@example.org'
    fill_in 'Password', with: 'foobar'
    fill_in 'Pivotal Tracker API token', with: '12345678901234567890123456789012'
    click_button 'Sign up'

    page.should have_content("You have signed up successfully")
    User.count.should eql(1)
  end
  
  scenario "unsuccessful" do
    visit homepage
    click_link 'Sign up'

    fill_in 'Email', with: 'john.doe@example.org'
    fill_in 'Password', with: 'foobar'
 
    click_button 'Sign up'

    page.should have_content("Pivotal tracker api token can't be blank")
    User.count.should eql(0)
  end
end
