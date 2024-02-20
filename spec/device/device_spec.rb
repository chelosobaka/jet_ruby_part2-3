require 'rails_helper'

RSpec.describe 'Device', type: :request do
  describe 'sign_in' do
    it 'get /sign_in' do
      get new_user_session_url
      expect(response).to be_successful
    end

    let!(:user) do
      User.create(
        first_name: 'Test',
        second_name: 'Test',
        patronymic: 'Test',
        phone_number: '1234567890',
        email: 'test@mail.ru',
        password: '123456',
        password_confirmation: '123456'
      )
    end

    it 'sign in success' do
      sign_in user
      get root_path
      expect(response).to be_successful
    end

    it 'sign out success' do
      sign_in user
      get root_path
      expect(response).to be_successful

      sign_out user
      get root_path
      expect(response).to redirect_to(new_user_session_path)

    end
  end

  describe 'sign up' do
    it 'get /sign_up' do
      get new_user_registration_url
      expect(response).to be_successful
    end

    context 'with valid params' do
      let(:valid_params) do
        {
          user: {
            first_name: 'Test',
            second_name: 'Test',
            patronymic: 'Test',
            phone_number: '1234567890',
            email: 'test@mail.ru',
            password: '123456'
          }
        }
      end

      it 'creates new user' do
        expect { post user_registration_url, params: valid_params }.to change(User, :count).by(1)
      end

      it 'redirect to root' do
        post user_registration_url, params: valid_params
        expect(response).to redirect_to(root_path)
      end
    end

    context 'with valid params' do
      let(:invalid_params) do
        {
          user: {
            first_name: '',
            second_name: '',
            patronymic: '',
            phone_number: '1234567890',
            email: 'test@mail.ru',
            password: '123456'
          }
        }
      end

      it 'not creates new user' do
        expect { post user_registration_url, params: invalid_params }.not_to change(User, :count)
      end

      it 'render sign up page' do
        post user_registration_url, params: invalid_params
        expect(response).to render_template("devise/registrations/new")
        expect(response.body).to include('error')
      end
    end
  end
end
