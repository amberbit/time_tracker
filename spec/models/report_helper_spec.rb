require 'spec_helper'

describe Report::Helper do
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
    @project1.users << @other_user
    @project1.owner_emails << @current_user.email
    @project1.save!
    @owner_project = @project1
    @project2 = Project.create! project_attributes
    @project2.users << @current_user
    @project2.users << @other_user
    @member_project = @project2
    @project3 = Project.create! project_attributes
  end

  it "any user, any project" do
    @report = Report::TimeLogEntries.new @options
    conditions = @report.conditions
    conditions.should have(2).items

    conditions[0][:project_id].should == @owner_project.id # as an owner I can see any user's entries

    conditions[1][:project_id].should == @member_project.id # as a regular user I can see only my entires
    conditions[1][:user_id].should ==  @current_user.id
  end

  it "any user, owned project" do
    @report = Report::TimeLogEntries.new @options.merge({
      project_id: @owner_project.id.to_s
    })
    conditions = @report.conditions
    conditions.should have(1).items

    conditions[0][:project_id].should == @owner_project.id # as an owner I can see any user's entries
  end

  it "any user, not owned project" do
    @report = Report::TimeLogEntries.new @options.merge({
      project_id: @member_project.id.to_s
    })
    conditions = @report.conditions
    conditions.should have(1).items

    conditions[0][:project_id].should == @member_project.id # as a regular user I can see only my entires
    conditions[0][:user_id].should ==  @current_user.id
  end

  it "self, any project" do
    @report = Report::TimeLogEntries.new @options.merge({
      user_id: @current_user.id.to_s
    })
    conditions = @report.conditions
    conditions.should have(2).items

    conditions[0][:project_id].should == @owner_project.id # as an owner I can see any user's entries
    conditions[0][:user_id].should ==  @current_user.id

    conditions[1][:project_id].should == @member_project.id # as a regular user I can see only my entires
    conditions[1][:user_id].should ==  @current_user.id
  end

  it "self, owned project" do
    @report = Report::TimeLogEntries.new @options.merge({
      user_id: @current_user.id.to_s,
      project_id: @owner_project.id.to_s
    })
    conditions = @report.conditions
    conditions.should have(1).items

    conditions[0][:project_id].should == @owner_project.id # as a regular user I can see only my entires
    conditions[0][:user_id].should ==  @current_user.id
  end

  it "self, not owned project" do
    @report = Report::TimeLogEntries.new @options.merge({
      user_id: @current_user.id.to_s,
      project_id: @member_project.id.to_s
    })
    conditions = @report.conditions
    conditions.should have(1).items

    conditions[0][:project_id].should == @member_project.id # as a regular user I can see only my entires
    conditions[0][:user_id].should ==  @current_user.id
  end

  it "other user, any project" do
    @report = Report::TimeLogEntries.new @options.merge({
      user_id: @other_user.id.to_s
    })
    conditions = @report.conditions
    conditions.should have(2).items

    conditions[0][:project_id].should == @project1.id # as an owner I can see any user's entries
    conditions[0][:user_id].should == @other_user.id # as an owner I can see any user's entries

    conditions[1][:project_id].should == @project2.id # as an owner I can see any user's entries
    conditions[1][:user_id].should == :forbidden # as an owner I can see any user's entries
  end

  it "other user, owned project" do
    @report = Report::TimeLogEntries.new @options.merge({
      user_id: @other_user.id.to_s,
      project_id: @owner_project.id.to_s
    })
    conditions = @report.conditions
    conditions.should have(1).items

    conditions[0][:project_id].should == @owner_project.id # as a regular user I can see only my entires
    conditions[0][:user_id].should ==  @other_user.id
  end

  it "other user, member project" do
    @report = Report::TimeLogEntries.new @options.merge({
      user_id: @other_user.id.to_s,
      project_id: @member_project.id.to_s
    })
    conditions = @report.conditions
    conditions.should have(1).items

    conditions[0][:project_id].should == @member_project.id # as a regular user I can see only my entires
    conditions[0][:user_id].should ==  :forbidden
  end
end
