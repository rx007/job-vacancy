require 'spec_helper'

RSpec.describe "UserCompletion" do
  describe "user new record" do
    let(:user) { build(:user)}

    it "encrypts the confirmation code of the user" do
      salt = "$2a$10$y0Stx1HaYV.sZHuxYLb25."
      confirmation_code = "$2a$10$y0Stx1HaYV.sZHuxYLb25.zAi0tu1C5N.oKMoPT6NbjtD/.3cg7Au"
      expected_confirmation_code = "$2a$10$y0Stx1HaYV.sZHuxYLb25.zAi0tu1C5N.oKMoPT6NbjtD.3cg7Au"
      expect(BCrypt::Engine).to receive(:generate_salt).and_return(salt)
      expect(BCrypt::Engine).to receive(:hash_secret).with(user.password, salt).and_return(expected_confirmation_code)
      @user_completion = UserCompletion.new(user, app(JobVacancy::App))
      @user_completion.encrypt_confirmation_code

      expect(@user_completion.user.confirmation_code).to eq expected_confirmation_code
    end

    it "sends registration mail" do
      expect(app).to receive(:deliver).with(:registration, :registration_email, user.name, user.email)

      @user_completion = UserCompletion.new(user, app)
      @user_completion.send_registration_mail
    end

    it "sends confirmation mail" do
      expect(app).to receive(:deliver).with(:confirmation, :confirmation_email, user.name, user.email, user.id, user.confirmation_code)

      @user_completion = UserCompletion.new(user, app)
      @user_completion.send_confirmation_mail
    end
  end
end
