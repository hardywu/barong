# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  context 'User model basic syntax' do
    ## Test of validations
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:password) }
    it { should have_many(:documents).dependent(:destroy) }

    ## Test of relationships
    it { should have_one(:profile).dependent(:destroy) }

    it do
      usr = create(:user)
      payload = usr.as_payload
      expect(payload['email']).to eq(usr.email)
    end
  end

  let(:uploaded_file) { fixture_file_upload('/files/documents_test.jpg', 'image/jpg') }

  context 'User with 2 or more documents' do
    it do
      user = User.create!(email: 'test@gmail.com', password: 'ZahSh8ei')
      expect(User.count).to eq 1
      document1 = user.documents.create!(upload: uploaded_file,
                                            doc_type: 'Passport',
                                            doc_number: 'MyString',
                                            doc_expire: '01-01-2020')
      document2 = user.documents.create!(upload: uploaded_file,
                                            doc_type: 'Passport',
                                            doc_number: 'MyString',
                                            doc_expire: '01-02-2020')
      expect(user.reload.documents).to eq([document1, document2])
    end

    after(:all) { User.destroy_all }
  end

  describe 'Iso8601TimeFormat' do
    let!(:user) { create(:user) }
    around(:each) { |example| Time.use_zone('Pacific/Midway') { example.run } }

    it 'parses time in utc and iso8601' do
      expect(user.format_iso8601_time(user.created_at)).to \
        eq user.created_at.utc.iso8601
    end

    it 'skips nil' do
      expect(user.format_iso8601_time(nil)).to eq nil
    end

    it 'parses date to iso8601' do
      expect(user.format_iso8601_time(user.created_at.to_date)).to \
        eq user.created_at.to_date.iso8601
    end
  end
end
