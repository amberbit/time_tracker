require File.dirname(__FILE__) + '/acceptance_helper'

feature "User Registration", %q{
  In order to get access to the systen
  As an anonymous user
  I want to create an account
} do

  scenario "successful" do
    visit homepage
    click_link 'sign up'

    fill_in 'Email', with: 'john.doe@example.org'
    fill_in 'Password', with: 'foobar'
    fill_in 'Password confirmation', with: 'foobar'
    fill_in 'Pivotal Tracker API key', with: '12345678901234567890123456789012'
    click_button 'Sign up'

    page.should have_content("Welcome to Time Tracker!")
    User.count.should eql(1)
  end

  scenario "unsuccessful" do
    visit homepage
    click_link 'sign up'

    fill_in 'Email', with: 'john.doe@example.org'
    fill_in 'Pivotal Tracker API key', with: '12345678901234567890123456789012'
    click_button 'Sign up'

    page.should have_content("Password can't be blank")
    User.count.should eql(0)
  end
end
