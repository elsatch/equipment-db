# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  name                   :text             not null
#  email                  :text             not null
#  active                 :boolean          default(TRUE), not null
#  password_digest        :text             default(""), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string(255)
#

require 'spec_helper'

describe User do
  before { @user = FactoryGirl.create(:user) }

  subject { @user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:active) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:authenticate) }
  it { should be_valid }

  it "should be marked active" do
    @user.active.should be_true
  end

  it "should have a default password" do
    @user.password.should_not be_nil
    @user.password_confirmation.should_not be_nil
    @user.password.should == @user.password_confirmation
  end

  it "should have a default password of a good length" do
    @user.password.length.should > 20
    @user.password_confirmation.length.should > 20
  end

  it "should require password confirmation" do
    @user.password = 'somethingElse'
    @user.save.should be_false
  end

  it "should not have password 'foo'" do
    @user.authenticate('foo').should be_false
  end

  describe "when name is blank" do
    before { @user.name = " " }
    it { should_not be_valid }
  end

  describe "when email is blank" do
    before { @user.email = " " }
    it { should_not be_valid }
  end

  describe "when email is not unique" do
    let(:user_with_same_email) { @user.dup }

    subject { user_with_same_email }

    it { should_not be_valid }
  end

  describe "when email is valid" do
    it "should be valid" do
      addresses = %w[ foo@example.com local_part@example.com
                      adddress+tag@example.com
                      local.part-with-punctuation@example.com ]
      addresses.each do |valid_address|
        @user.email = valid_address
        @user.should be_valid
      end
    end
  end

  describe "when email is invalid" do
    it "should be invalid" do
      addresses = %w[ foo-at-example.com local_part@ @example.com ]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        @user.should_not be_valid
      end
    end
  end

  describe "email address with mixed case" do
    let(:mixed_case_email) { "Foo@Example.com" }

    it "should be saved as lower case" do
      @user.email = mixed_case_email
      @user.save
      @user.confirm!
      @user.reload.email.should == mixed_case_email.downcase
    end
  end  

  describe "when password is too short" do
    before do
      @user.password = @user.password_confirmation = 'foo'
    end

    it { should_not be_valid }
  end
end

describe "a user with password 'foobar'" do
  before { @user = FactoryGirl.create(:user_with_password_foobar) }
  subject { @user }

  it "has password 'foobar'" do
    @user.authenticate('foobar').should be_true
  end

  it "does not have password 'barfoo'" do
    @user.authenticate('barfoo').should be_false
  end

  it "does not have a blank password" do
    @user.authenticate('').should be_false
  end

  describe "after changing it to 'buzzquux'" do
    before do
      @user.password = 'buzzquux'
      @user.password_confirmation = 'buzzquux'
      @user.save
    end

    it "has password 'buzzquux'" do
      @user.authenticate('buzzquux').should be_true
    end

    it "does not have password 'foobar'" do
      @user.authenticate('foobar').should be_false
    end
  end

  describe "can be looked up by email" do
    let(:found_user) { User.find_by_email('joe_example@example.com') }

    it { should == found_user }

    specify { found_user.authenticate('foobar').should be_true }
    specify { found_user.authenticate('barfoo').should be_false }
  end
end
