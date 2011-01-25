require 'spec_helper'

describe TimeLogEntriesReport do
  before :each do
    @from = '2010-12-01'
    @to = '2010-12-15'
  end

  describe "regular user" do
    before :each do
      @current_user = User.create! user_attributes(email: 'current@e.com')
      @other_user = User.create! user_attributes(email: 'other@e.com')
      @options = {
        from: @from,
        to: @to,
        current_user: @current_user
      }
      @project1 = Project.create! project_attributes
      @project1.users << @current_user
      @project2 = Project.create! project_attributes
      @project2.users << @current_user
      @project3 = Project.create! project_attributes
    end

    describe "project conditions" do
      it "any project" do
        @report = TimeLogEntriesReport.new @options
        @report.project_conditions.should == {project_id: {'$in' => [@project1.id, @project2.id]}}
      end

      it "project where he belongs to" do
        @report = TimeLogEntriesReport.new @options.merge({
          project_id: @project1.id.to_s
        })
        @report.project_conditions.should == {project_id: @project1.id}
      end

      it "project where he doesn't belong to" do
        @report = TimeLogEntriesReport.new @options.merge({
          project_id: @project3.id.to_s
        })
        @report.project_conditions.should == {project_id: :forbidden}
      end
    end

    describe "user conditions" do
      it "any user" do
        @report = TimeLogEntriesReport.new @options
        @report.user_conditions.should == {user_id: @current_user.id}
      end

      it "selects himself" do
        @report = TimeLogEntriesReport.new @options.merge({
          user_id: @current_user.id.to_s
        })
        @report.user_conditions.should == {user_id: @current_user.id}
      end

      it "other user" do
        @report = TimeLogEntriesReport.new @options.merge({
          user_id: @other_user.id.to_s
        })
        @report.user_conditions.should == {user_id: :forbidden}
      end
    end
  end

  describe "owner" do
  end
end


=begin
  describe "user conditions" do
    it "when regular or owner selects himself" do
      @report = TimeLogEntriesReport.new @options.merge({
        user_id: @current_user.id.to_s
      })
      @report.user_conditions.should == {user_id: @current_user.id}
    end

    describe "when regular user selects" do
      it "any user" do
        @report = TimeLogEntriesReport.new @options
        @report.user_conditions.should == {user_id: @current_user.id}
      end

      it "other user" do
        @report = TimeLogEntriesReport.new @options.merge({
          user_id: @other_user.id.to_s
        })
        @report.user_conditions.should == {user_id: @current_user.id}
      end
    end

    describe "when owner selects" do
      it "any user" do

      end

      it "other user" do
      end
    end


  end
end
=end
=begin
describe TimeLogEntriesReport do
  before :each do
    @from = '2010-12-01'
    @to = '2010-12-15'
    @current_user = User.create! user_attributes(email: 'current@e.com')
    @other_user = User.create! user_attributes(email: 'other@e.com')
    @options = {
      from: @from,
      to: @to,
      current_user: @current_user
    }
    @project1 = Project.create! project_attributes
    @project1.users << @current_user
    @project2 = Project.create! project_attributes
    @project2.users << @current_user
    @project3 = Project.create! project_attributes
  end

  it "regular user, any project, any user" do
    @report = TimeLogEntriesReport.new @options
    @report.user_conditions.should == {user_id: @current_user.id}
    @report.project_conditions.should == {project_id: {'$in' => [@project1.id, @project2.id]}}
  end

  it "regular user, any project, current user" do
    @report = TimeLogEntriesReport.new @options.merge({
      user_id: @current_user.id.to_s
    })
    @report.user_conditions.should == {user_id: @current_user.id}
    @report.project_conditions.should == {project_id: {'$in' => [@project1.id, @project2.id]}}
  end

  it "regular user, any project, other user" do
    @report = TimeLogEntriesReport.new @options.merge({
      user_id: @other_user.id.to_s
    })
    @report.user_conditions.should == {user_id: :forbidden}
    @report.project_conditions.should == {project_id: {'$in' => [@project1.id, @project2.id]}}
  end

  it "regular user, project1, any user" do
    @report = TimeLogEntriesReport.new @options.merge({
      project_id: @project1.id.to_s
    })
    @report.user_conditions.should == {user_id: @current_user.id}
    @report.project_conditions.should == {project_id: @project1.id}
  end

  it "regular user, project1, current user" do
    @report = TimeLogEntriesReport.new @options.merge({
      user_id: @current_user.id.to_s,
      project_id: @project1.id.to_s
    })
    @report.user_conditions.should == {user_id: @current_user.id}
    @report.project_conditions.should == {project_id: @project1.id}
  end

  it "regular user, project1, other user" do
    @report = TimeLogEntriesReport.new @options.merge({
      user_id: @other_user.id.to_s,
      project_id: @project1.id.to_s
    })
    @report.user_conditions.should == {user_id: :forbidden}
    @report.project_conditions.should == {project_id: @project1.id}
  end

  it "regular user, project3, any user" do
    @report = TimeLogEntriesReport.new @options.merge({
      project_id: @project3.id.to_s
    })
    @report.user_conditions.should == {user_id: @current_user.id}
    @report.project_conditions.should == {project_id: :forbidden}
  end

  it "regular user, not existing project, any user" do
    lambda {
      @report = TimeLogEntriesReport.new @options.merge({
        project_id: '4ccfba4237bb454de400003b'
      })
    }.should raise_error(Mongoid::Errors::DocumentNotFound)
  end

  it "regular user, any project, not existing user" do
    lambda {
      @report = TimeLogEntriesReport.new @options.merge({
        user_id: '4ccfba4237bb454de4000039'
      })
    }.should raise_error(Mongoid::Errors::DocumentNotFound)
  end
end
=end
