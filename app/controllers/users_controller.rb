class UsersController < ApplicationController
  autocomplete :user, :email, :full => true

end
