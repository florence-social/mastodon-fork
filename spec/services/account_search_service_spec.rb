require 'rails_helper'

describe AccountSearchService, type: :service do
  describe '.call' do
    describe 'with a query to ignore' do
      it 'returns empty array for missing query' do
        results = subject.call('', nil, limit: 10)

        expect(results).to eq []
      end
      it 'returns empty array for hashtag query' do
        results = subject.call('#tag', nil, limit: 10)

        expect(results).to eq []
      end
      it 'returns empty array for limit zero' do
        Fabricate(:account, username: 'match')
        results = subject.call('match', nil, limit: 0)

        expect(results).to eq []
      end
    end

    describe 'searching for a simple term that is not an exact match' do
      it 'does not return a nil entry in the array for the exact match' do
        match = Fabricate(:account, username: 'matchingusername')

        results = subject.call('match', nil, limit: 5)
        expect(results).to eq [match]
      end
    end

    describe 'searching local and remote users' do
      describe "when only '@'" do
        before do
          allow(Account).to receive(:find_local)
          allow(Account).to receive(:search_for)
          subject.call('@', nil, limit: 10)
        end

        it 'uses find_local with empty query to look for local accounts' do
          expect(Account).to have_received(:find_local).with('')
        end
      end

      describe 'when no domain' do
        before do
          allow(Account).to receive(:find_local)
          allow(Account).to receive(:search_for)
          subject.call('one', nil, limit: 10)
        end

        it 'uses find_local to look for local accounts' do
          expect(Account).to have_received(:find_local).with('one')
        end

        it 'uses search_for to find matches' do
          expect(Account).to have_received(:search_for).with('one', 10, 0)
        end
      end

      describe 'when there is a domain' do
        before do
          allow(Account).to receive(:find_remote)
        end

        it 'uses find_remote to look for remote accounts' do
          subject.call('two@example.com', nil, limit: 10)
          expect(Account).to have_received(:find_remote).with('two', 'example.com')
        end

        describe 'and there is no account provided' do
          it 'uses search_for to find matches' do
            allow(Account).to receive(:search_for)
            subject.call('two@example.com', nil, limit: 10, resolve: false)

            expect(Account).to have_received(:search_for).with('two example.com', 10, 0)
          end
        end

        describe 'and there is an account provided' do
          it 'uses advanced_search_for to find matches' do
            account = Fabricate(:account)
            allow(Account).to receive(:advanced_search_for)
            subject.call('two@example.com', account, limit: 10, resolve: false)

            expect(Account).to have_received(:advanced_search_for).with('two example.com', account, 10, nil, 0)
          end
        end
      end
    end

    describe 'with an exact match' do
      it 'returns exact match first, and does not return duplicates' do
        partial = Fabricate(:account, username: 'exactness')
        exact = Fabricate(:account, username: 'exact')

        results = subject.call('exact', nil, limit: 10)
        expect(results.size).to eq 2
        expect(results).to eq [exact, partial]
      end
    end

    describe 'when there is a local domain' do
      around do |example|
        before = Rails.configuration.x.local_domain
        example.run
        Rails.configuration.x.local_domain = before
      end

      it 'returns exact match first' do
        remote     = Fabricate(:account, username: 'a', domain: 'remote', display_name: 'e')
        remote_too = Fabricate(:account, username: 'b', domain: 'remote', display_name: 'e')
        exact = Fabricate(:account, username: 'e')
        Rails.configuration.x.local_domain = 'example.com'

        results = subject.call('e@example.com', nil, limit: 2)
        expect(results.size).to eq 2
        expect(results).to eq([exact, remote]).or eq([exact, remote_too])
      end
    end

    describe 'when there is a domain but no exact match' do
      it 'follows the remote account when resolve is true' do
        service = double(call: nil)
        allow(ResolveAccountService).to receive(:new).and_return(service)

        results = subject.call('newuser@remote.com', nil, limit: 10, resolve: true)
        expect(service).to have_received(:call).with('newuser@remote.com')
      end

      it 'does not follow the remote account when resolve is false' do
        service = double(call: nil)
        allow(ResolveAccountService).to receive(:new).and_return(service)

        results = subject.call('newuser@remote.com', nil, limit: 10, resolve: false)
        expect(service).not_to have_received(:call)
      end
    end

    describe 'should not include suspended accounts' do
      it 'returns the fuzzy match first, and does not return suspended exacts' do
        partial = Fabricate(:account, username: 'exactness')
        exact = Fabricate(:account, username: 'exact', suspended: true)

        results = subject.call('exact', nil, limit: 10)
        expect(results.size).to eq 1
        expect(results).to eq [partial]
      end

      it "does not return suspended remote accounts" do
        remote = Fabricate(:account, username: 'a', domain: 'remote', display_name: 'e', suspended: true)

        results = subject.call('a@example.com', nil, limit: 2)
        expect(results.size).to eq 0
        expect(results).to eq []
      end
    end
  end
end
