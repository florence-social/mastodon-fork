require 'rails_helper'

RSpec.describe FeedManager do
  before do |example|
    unless example.metadata[:skip_stub]
      stub_const 'FeedManager::MAX_ITEMS', 10
      stub_const 'FeedManager::REBLOG_FALLOFF', 4
    end
  end

  it 'tracks at least as many statuses as reblogs', skip_stub: true do
    expect(FeedManager::REBLOG_FALLOFF).to be <= FeedManager::MAX_ITEMS
  end

  describe '#key' do
    subject { FeedManager.instance.key(:home, 1) }

    it 'returns a string' do
      expect(subject).to be_a String
    end
  end

  describe '#filter?' do
    let(:alice) { Fabricate(:account, username: 'alice') }
    let(:bob)   { Fabricate(:account, username: 'bob', domain: 'example.com') }
    let(:jeff)  { Fabricate(:account, username: 'jeff') }

    context 'for home feed' do
      it 'returns false for followee\'s status' do
        status = Fabricate(:status, text: 'Hello world', account: alice)
        bob.follow!(alice)
        expect(FeedManager.instance.filter?(:home, status, bob.id)).to be false
      end

      it 'returns false for reblog by followee' do
        status = Fabricate(:status, text: 'Hello world', account: jeff)
        reblog = Fabricate(:status, reblog: status, account: alice)
        bob.follow!(alice)
        expect(FeedManager.instance.filter?(:home, reblog, bob.id)).to be false
      end

      it 'returns true for reblog by followee of blocked account' do
        status = Fabricate(:status, text: 'Hello world', account: jeff)
        reblog = Fabricate(:status, reblog: status, account: alice)
        bob.follow!(alice)
        bob.block!(jeff)
        expect(FeedManager.instance.filter?(:home, reblog, bob.id)).to be true
      end

      it 'returns true for reblog by followee of muted account' do
        status = Fabricate(:status, text: 'Hello world', account: jeff)
        reblog = Fabricate(:status, reblog: status, account: alice)
        bob.follow!(alice)
        bob.mute!(jeff)
        expect(FeedManager.instance.filter?(:home, reblog, bob.id)).to be true
      end

      it 'returns true for reblog by followee of someone who is blocking recipient' do
        status = Fabricate(:status, text: 'Hello world', account: jeff)
        reblog = Fabricate(:status, reblog: status, account: alice)
        bob.follow!(alice)
        jeff.block!(bob)
        expect(FeedManager.instance.filter?(:home, reblog, bob.id)).to be true
      end

      it 'returns true for reblog from account with reblogs disabled' do
        status = Fabricate(:status, text: 'Hello world', account: jeff)
        reblog = Fabricate(:status, reblog: status, account: alice)
        bob.follow!(alice, reblogs: false)
        expect(FeedManager.instance.filter?(:home, reblog, bob.id)).to be true
      end

      it 'returns false for reply by followee to another followee' do
        status = Fabricate(:status, text: 'Hello world', account: jeff)
        reply  = Fabricate(:status, text: 'Nay', thread: status, account: alice)
        bob.follow!(alice)
        bob.follow!(jeff)
        expect(FeedManager.instance.filter?(:home, reply, bob.id)).to be false
      end

      it 'returns false for reply by followee to recipient' do
        status = Fabricate(:status, text: 'Hello world', account: bob)
        reply  = Fabricate(:status, text: 'Nay', thread: status, account: alice)
        bob.follow!(alice)
        expect(FeedManager.instance.filter?(:home, reply, bob.id)).to be false
      end

      it 'returns false for reply by followee to self' do
        status = Fabricate(:status, text: 'Hello world', account: alice)
        reply  = Fabricate(:status, text: 'Nay', thread: status, account: alice)
        bob.follow!(alice)
        expect(FeedManager.instance.filter?(:home, reply, bob.id)).to be false
      end

      it 'returns true for reply by followee to non-followed account' do
        status = Fabricate(:status, text: 'Hello world', account: jeff)
        reply  = Fabricate(:status, text: 'Nay', thread: status, account: alice)
        bob.follow!(alice)
        expect(FeedManager.instance.filter?(:home, reply, bob.id)).to be true
      end

      it 'returns true for the second reply by followee to a non-federated status' do
        reply        = Fabricate(:status, text: 'Reply 1', reply: true, account: alice)
        second_reply = Fabricate(:status, text: 'Reply 2', thread: reply, account: alice)
        bob.follow!(alice)
        expect(FeedManager.instance.filter?(:home, second_reply, bob.id)).to be true
      end

      it 'returns false for status by followee mentioning another account' do
        bob.follow!(alice)
        status = PostStatusService.new.call(alice, text: 'Hey @jeff')
        expect(FeedManager.instance.filter?(:home, status, bob.id)).to be false
      end

      it 'returns true for status by followee mentioning blocked account' do
        bob.block!(jeff)
        bob.follow!(alice)
        status = PostStatusService.new.call(alice, text: 'Hey @jeff')
        expect(FeedManager.instance.filter?(:home, status, bob.id)).to be true
      end

      it 'returns true for reblog of a personally blocked domain' do
        alice.block_domain!('example.com')
        alice.follow!(jeff)
        status = Fabricate(:status, text: 'Hello world', account: bob)
        reblog = Fabricate(:status, reblog: status, account: jeff)
        expect(FeedManager.instance.filter?(:home, reblog, alice.id)).to be true
      end

      context 'for irreversibly muted phrases' do
        it 'considers word boundaries when matching' do
          alice.custom_filters.create!(phrase: 'bob', context: %w(home), irreversible: true)
          alice.follow!(jeff)
          status = Fabricate(:status, text: 'bobcats', account: jeff)
          expect(FeedManager.instance.filter?(:home, status, alice.id)).to be_falsy
        end

        it 'returns true if phrase is contained' do
          alice.custom_filters.create!(phrase: 'farts', context: %w(home public), irreversible: true)
          alice.custom_filters.create!(phrase: 'pop tarts', context: %w(home), irreversible: true)
          alice.follow!(jeff)
          status = Fabricate(:status, text: 'i sure like POP TARts', account: jeff)
          expect(FeedManager.instance.filter?(:home, status, alice.id)).to be true
        end

        it 'matches substrings if whole_word is false' do
          alice.custom_filters.create!(phrase: 'take', context: %w(home), whole_word: false, irreversible: true)
          alice.follow!(jeff)
          status = Fabricate(:status, text: 'shiitake', account: jeff)
          expect(FeedManager.instance.filter?(:home, status, alice.id)).to be true
        end
      end
    end

    context 'for mentions feed' do
      it 'returns true for status that mentions blocked account' do
        bob.block!(jeff)
        status = PostStatusService.new.call(alice, text: 'Hey @jeff')
        expect(FeedManager.instance.filter?(:mentions, status, bob.id)).to be true
      end

      it 'returns true for status that replies to a blocked account' do
        status = Fabricate(:status, text: 'Hello world', account: jeff)
        reply  = Fabricate(:status, text: 'Nay', thread: status, account: alice)
        bob.block!(jeff)
        expect(FeedManager.instance.filter?(:mentions, reply, bob.id)).to be true
      end

      it 'returns true for status by silenced account who recipient is not following' do
        status = Fabricate(:status, text: 'Hello world', account: alice)
        alice.update(silenced: true)
        expect(FeedManager.instance.filter?(:mentions, status, bob.id)).to be true
      end

      it 'returns false for status by followed silenced account' do
        status = Fabricate(:status, text: 'Hello world', account: alice)
        alice.update(silenced: true)
        bob.follow!(alice)
        expect(FeedManager.instance.filter?(:mentions, status, bob.id)).to be false
      end
    end
  end

  describe '#push_to_home' do
    it 'trims timelines if they will have more than FeedManager::MAX_ITEMS' do
      account = Fabricate(:account)
      status = Fabricate(:status)
      members = FeedManager::MAX_ITEMS.times.map { |count| [count, count] }
      Redis.current.zadd("feed:home:#{account.id}", members)

      FeedManager.instance.push_to_home(account, status)

      expect(Redis.current.zcard("feed:home:#{account.id}")).to eq FeedManager::MAX_ITEMS
    end

    context 'reblogs' do
      it 'saves reblogs of unseen statuses' do
        account = Fabricate(:account)
        reblogged = Fabricate(:status)
        reblog = Fabricate(:status, reblog: reblogged)

        expect(FeedManager.instance.push_to_home(account, reblog)).to be true
      end

      it 'does not save a new reblog of a recent status' do
        account = Fabricate(:account)
        reblogged = Fabricate(:status)
        reblog = Fabricate(:status, reblog: reblogged)

        FeedManager.instance.push_to_home(account, reblogged)

        expect(FeedManager.instance.push_to_home(account, reblog)).to be false
      end

      it 'saves a new reblog of an old status' do
        account = Fabricate(:account)
        reblogged = Fabricate(:status)
        reblog = Fabricate(:status, reblog: reblogged)

        FeedManager.instance.push_to_home(account, reblogged)

        # Fill the feed with intervening statuses
        FeedManager::REBLOG_FALLOFF.times do
          FeedManager.instance.push_to_home(account, Fabricate(:status))
        end

        expect(FeedManager.instance.push_to_home(account, reblog)).to be true
      end

      it 'does not save a new reblog of a recently-reblogged status' do
        account = Fabricate(:account)
        reblogged = Fabricate(:status)
        reblogs = 2.times.map { Fabricate(:status, reblog: reblogged) }

        # The first reblog will be accepted
        FeedManager.instance.push_to_home(account, reblogs.first)

        # The second reblog should be ignored
        expect(FeedManager.instance.push_to_home(account, reblogs.last)).to be false
      end

      it 'does not save a new reblog of a multiply-reblogged-then-unreblogged status' do
        account   = Fabricate(:account)
        reblogged = Fabricate(:status)
        reblogs = 3.times.map { Fabricate(:status, reblog: reblogged) }

        # Accept the reblogs
        FeedManager.instance.push_to_home(account, reblogs[0])
        FeedManager.instance.push_to_home(account, reblogs[1])

        # Unreblog the first one
        FeedManager.instance.unpush_from_home(account, reblogs[0])

        # The last reblog should still be ignored
        expect(FeedManager.instance.push_to_home(account, reblogs.last)).to be false
      end

      it 'saves a new reblog of a long-ago-reblogged status' do
        account = Fabricate(:account)
        reblogged = Fabricate(:status)
        reblogs = 2.times.map { Fabricate(:status, reblog: reblogged) }

        # The first reblog will be accepted
        FeedManager.instance.push_to_home(account, reblogs.first)

        # Fill the feed with intervening statuses
        FeedManager::REBLOG_FALLOFF.times do
          FeedManager.instance.push_to_home(account, Fabricate(:status))
        end

        # The second reblog should also be accepted
        expect(FeedManager.instance.push_to_home(account, reblogs.last)).to be true
      end
    end

    it "does not push when the given status's reblog is already inserted" do
      account = Fabricate(:account)
      reblog = Fabricate(:status)
      status = Fabricate(:status, reblog: reblog)
      FeedManager.instance.push_to_home(account, status)

      expect(FeedManager.instance.push_to_home(account, reblog)).to eq false
    end
  end

  describe '#push_to_list' do
    it "does not push when the given status's reblog is already inserted" do
      list = Fabricate(:list)
      reblog = Fabricate(:status)
      status = Fabricate(:status, reblog: reblog)
      FeedManager.instance.push_to_list(list, status)

      expect(FeedManager.instance.push_to_list(list, reblog)).to eq false
    end
  end

  describe '#merge_into_timeline' do
    it "does not push source account's statuses whose reblogs are already inserted" do
      account = Fabricate(:account, id: 0)
      reblog = Fabricate(:status)
      status = Fabricate(:status, reblog: reblog)
      FeedManager.instance.push_to_home(account, status)

      FeedManager.instance.merge_into_timeline(account, reblog.account)

      expect(Redis.current.zscore("feed:home:0", reblog.id)).to eq nil
    end

    it "does not push direct messages into home timeline if the user has home_dms false" do
      status    = Fabricate(:status, visibility: :direct)
      mentioned = Fabricate(:account, id: 1)
      mentioned.user = Fabricate(:user)
      mentioned.user.settings.home_dms = false
      status.mentions.create(account: mentioned)

      FeedManager.instance.merge_into_timeline(status.account, mentioned)
      expect(Redis.current.zscore("feed:home:1",status.id)).to be_nil
    end

    it "pushes direct messages into home timeline if the user has home_dms true" do
      status    = Fabricate(:status, visibility: :direct)
      mentioned = Fabricate(:account, id: 1)
      mentioned.user = Fabricate(:user)
      mentioned.user.settings.home_dms = true
      status.mentions.create(account: mentioned)

      FeedManager.instance.merge_into_timeline(status.account, mentioned)
      expect(Redis.current.zscore("feed:home:1",status.id)).to_not be_nil
    end
  end

  describe '#trim' do
    let(:receiver) { Fabricate(:account) }

    it 'cleans up reblog tracking keys' do
      reblogged      = Fabricate(:status)
      status         = Fabricate(:status, reblog: reblogged)
      another_status = Fabricate(:status, reblog: reblogged)
      reblogs_key    = FeedManager.instance.key('home', receiver.id, 'reblogs')
      reblog_set_key = FeedManager.instance.key('home', receiver.id, "reblogs:#{reblogged.id}")

      FeedManager.instance.push_to_home(receiver, status)
      FeedManager.instance.push_to_home(receiver, another_status)

      # We should have a tracking set and an entry in reblogs.
      expect(Redis.current.exists(reblog_set_key)).to be true
      expect(Redis.current.zrange(reblogs_key, 0, -1)).to eq [reblogged.id.to_s]

      # Push everything off the end of the feed.
      FeedManager::MAX_ITEMS.times do
        FeedManager.instance.push_to_home(receiver, Fabricate(:status))
      end

      # `trim` should be called automatically, but do it anyway, as
      # we're testing `trim`, not side effects of `push`.
      FeedManager.instance.trim('home', receiver.id)

      # We should not have any reblog tracking data.
      expect(Redis.current.exists(reblog_set_key)).to be false
      expect(Redis.current.zrange(reblogs_key, 0, -1)).to be_empty
    end
  end

  describe '#unpush' do
    let(:receiver) { Fabricate(:account) }

    it 'leaves a reblogged status if original was on feed' do
      reblogged = Fabricate(:status)
      status    = Fabricate(:status, reblog: reblogged)

      FeedManager.instance.push_to_home(receiver, reblogged)
      FeedManager::REBLOG_FALLOFF.times { FeedManager.instance.push_to_home(receiver, Fabricate(:status)) }
      FeedManager.instance.push_to_home(receiver, status)

      # The reblogging status should show up under normal conditions.
      expect(Redis.current.zrange("feed:home:#{receiver.id}", 0, -1)).to include(status.id.to_s)

      FeedManager.instance.unpush_from_home(receiver, status)

      # Restore original status
      expect(Redis.current.zrange("feed:home:#{receiver.id}", 0, -1)).to_not include(status.id.to_s)
      expect(Redis.current.zrange("feed:home:#{receiver.id}", 0, -1)).to include(reblogged.id.to_s)
    end

    it 'removes a reblogged status if it was only reblogged once' do
      reblogged = Fabricate(:status)
      status    = Fabricate(:status, reblog: reblogged)

      FeedManager.instance.push_to_home(receiver, status)

      # The reblogging status should show up under normal conditions.
      expect(Redis.current.zrange("feed:home:#{receiver.id}", 0, -1)).to eq [status.id.to_s]

      FeedManager.instance.unpush_from_home(receiver, status)

      expect(Redis.current.zrange("feed:home:#{receiver.id}", 0, -1)).to be_empty
    end

    it 'leaves a multiply-reblogged status if another reblog was in feed' do
      reblogged = Fabricate(:status)
      reblogs   = 3.times.map { Fabricate(:status, reblog: reblogged) }

      reblogs.each do |reblog|
        FeedManager.instance.push_to_home(receiver, reblog)
      end

      # The reblogging status should show up under normal conditions.
      expect(Redis.current.zrange("feed:home:#{receiver.id}", 0, -1)).to eq [reblogs.first.id.to_s]

      reblogs[0...-1].each do |reblog|
        FeedManager.instance.unpush_from_home(receiver, reblog)
      end

      expect(Redis.current.zrange("feed:home:#{receiver.id}", 0, -1)).to eq [reblogs.last.id.to_s]
    end

    it 'sends push updates' do
      status = Fabricate(:status)

      FeedManager.instance.push_to_home(receiver, status)

      allow(Redis.current).to receive_messages(publish: nil)
      FeedManager.instance.unpush_from_home(receiver, status)

      deletion = Oj.dump(event: :delete, payload: status.id.to_s)
      expect(Redis.current).to have_received(:publish).with("timeline:#{receiver.id}", deletion)
    end
  end
end
