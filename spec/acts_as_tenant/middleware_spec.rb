require 'spec_helper'
require 'active_record_models'

describe 'Rails middleware testing', type: :request do
  class Receiver
    def self.current_id(id); end

    def self.local_id(id); end
  end

  class AppController < ActionController::Base
    include Rails.application.routes.url_helpers
    def switch
      ActsAsTenant.current_tenant = Account.first
      puts "local is #{ActsAsTenant.local_tenant&.id}"
      test_receiver
      head :ok
    end

    def no_switch
      test_receiver
      head :ok
    end

    private

    def test_receiver
      Receiver.current_id(ActsAsTenant.current_tenant.try(:id))
      Receiver.local_id(ActsAsTenant.local_tenant.try(:id))
    end
  end
  Rails.application.routes.draw do
    get '/switch' => 'app#switch'
    get '/no_switch' => 'app#no_switch'
  end
  # before { ActsAsTenant::Railtie.initializers.each(&:run) }
  let!(:account1) { Account.create }
  let!(:account2) { Account.create }
  after { ActsAsTenant.local_tenant = nil }
  context 'when local_tenant is nil' do
    before { ActsAsTenant.local_tenant = nil }
    it 'should remain nil throughout calling switch' do
      expect(ActsAsTenant.local_tenant).to be_nil
      expect(Receiver).to receive(:current_id).with(account1.id)
      expect(Receiver).to receive(:local_id).with(nil)
      get '/switch'
      expect(response).to have_http_status :ok
      expect(ActsAsTenant.local_tenant).to be_nil
    end

    it 'should remain nil throughout calling no_switch' do
      expect(ActsAsTenant.local_tenant).to be_nil
      expect(Receiver).to receive(:current_id).with(nil)
      expect(Receiver).to receive(:local_id).with(nil)
      get '/no_switch'
      expect(response).to have_http_status :ok
      expect(ActsAsTenant.local_tenant).to be_nil
    end
    context 'when local_tenant is not nil' do
      before { ActsAsTenant.local_tenant = account2 }
      it 'should remain nil throughout calling switch' do
        expect(ActsAsTenant.local_tenant).to eq account2
        # expect(Receiver).to receive(:current_id).with(account1.id)
        # expect(Receiver).not_to receive(:local_id).with(account2.id)
        # expect(Receiver).to receive(:local_id).with(nil)
        get '/switch'
        expect(response).to have_http_status :ok
        expect(ActsAsTenant.local_tenant).to eq account2
      end

      it 'should remain nil throughout calling no_switch' do
        expect(ActsAsTenant.local_tenant).to eq account2
        expect(Receiver).to receive(:current_id).with(nil)
        expect(Receiver).to receive(:local_id).with(nil)
        get '/no_switch'
        expect(response).to have_http_status :ok
        expect(ActsAsTenant.local_tenant).to eq account2
      end
    end
  end
end
