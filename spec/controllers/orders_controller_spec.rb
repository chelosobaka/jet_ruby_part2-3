require 'rails_helper'

RSpec.describe OrdersController, type: :controller do
  describe 'get new' do
    it 'renders new template' do
      get :new
      expect(response).to render_template('new')
    end

    it 'returns successful response' do
      get :new
      expect(response).to be_successful
    end

    it 'assigns @order' do
      get :new
      expect(assigns(:order)).to be_a_new(Order)
    end
  end

  describe 'post create' do
    context 'with valid params' do
      let(:valid_params) do
        {
          order: {
            first_name: 'Test',
            second_name: 'Test',
            patronymic: 'Test',
            phone_number: '1234567890',
            email: 'test@mail.ru',
            weight: 10,
            length: 20,
            width: 30,
            height: 40,
            origins: '55.7504461, 37.6174943',
            destinations: '48.8588897, 2.3200410217200766'
          }
        }
      end

      it 'creates new order' do
        expect { post :create, params: valid_params }.to change(Order, :count).by(1)
      end

      it 'redirect to show' do
        post :create, params: valid_params
        expect(response).to redirect_to(order_path(Order.last))
      end
    end

    context 'with invalid params' do
      let(:invalid_params) do
        {
          order: {
            first_name: '',
            second_name: '',
            patronymic: '',
            phone_number: '',
            email: 'invalid_email',
            weight: -10,
            length: 0,
            width: 0,
            height: 0,
            origins: '',
            destinations: ''
          }
        }
      end

      it 'dont create new order' do
        expect { post :create, params: invalid_params }.not_to change(Order, :count)
      end

      it 'render new template' do
        post :create, params: invalid_params
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'get show' do
    let(:order) do
      Order.create(
        first_name: 'Test',
        second_name: 'Test',
        patronymic: 'Test',
        phone_number: '1234567890',
        email: 'test@mail.ru',
        weight: 10,
        length: 20,
        width: 30,
        height: 40,
        origins: '55.7504461, 37.6174943',
        destinations: '48.8588897, 2.3200410217200766'
      )
    end

    it 'renders show template' do
      get :show, params: { id: order.id }
      expect(response).to render_template(:show)
    end

    it 'assigns @order' do
      get :show, params: { id: order.id }
      expect(assigns(:order)).to eq(order)
    end
  end
end
