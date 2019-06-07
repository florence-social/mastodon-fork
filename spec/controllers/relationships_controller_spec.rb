require 'rails_helper'

describe RelationshipsController do
  render_views

  let(:user) { Fabricate(:user) }

  shared_examples 'authenticate user' do
    it 'redirects when not signed in' do
      is_expected.to redirect_to '/auth/sign_in'
    end
  end

  describe 'GET #show' do
    subject { get :show, params: { page: 2, relationship: 'followed_by' } }

    it 'assigns @accounts' do
      Fabricate(:account, domain: 'old').follow!(user.account)
      Fabricate(:account, domain: 'recent').follow!(user.account)

      sign_in user, scope: :user
      subject

      assigned = assigns(:accounts).per(1).to_a
      expect(assigned.size).to eq 1
      expect(assigned[0].domain).to eq 'old'
    end

    it 'returns http success' do
      sign_in user, scope: :user
      subject
      expect(response).to have_http_status(200)
    end

    include_examples 'authenticate user'
  end

  describe 'PATCH #update' do
    let(:poopfeast) { Fabricate(:account, username: 'poopfeast', domain: 'example.com', salmon_url: 'http://example.com/salmon') }

    before do
      stub_request(:post, 'http://example.com/salmon').to_return(status: 200)
    end

    shared_examples 'redirects back to followers page' do
      it 'redirects back to followers page' do
        poopfeast.follow!(user.account)

        sign_in user, scope: :user
        subject

        expect(response).to redirect_to(relationships_path)
      end
    end

    context 'when select parameter is not provided' do
      subject { patch :update }
      include_examples 'redirects back to followers page'
    end

    context 'when select parameter is provided' do
      subject { patch :update, params: { form_account_batch: { account_ids: [poopfeast.id] }, block_domains: '' } }

      it 'soft-blocks followers from selected domains' do
        poopfeast.follow!(user.account)

        sign_in user, scope: :user
        subject

        expect(poopfeast.following?(user.account)).to be false
      end

      include_examples 'authenticate user'
      include_examples 'redirects back to followers page'
    end
  end
end
