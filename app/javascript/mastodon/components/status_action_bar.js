import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import IconButton from './icon_button';
import DropdownMenuContainer from '../containers/dropdown_menu_container';
import { defineMessages, injectIntl } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { me, isStaff } from '../initial_state';

const messages = defineMessages({
  delete: { id: 'status.delete', defaultMessage: 'Delete' },
  redraft: { id: 'status.redraft', defaultMessage: 'Delete & re-draft' },
  direct: { id: 'status.direct', defaultMessage: 'Direct message @{name}' },
  mention: { id: 'status.mention', defaultMessage: 'Mention @{name}' },
  mute: { id: 'account.mute', defaultMessage: 'Mute @{name}' },
  block: { id: 'account.block', defaultMessage: 'Block @{name}' },
  reply: { id: 'status.reply', defaultMessage: 'Reply' },
  share: { id: 'status.share', defaultMessage: 'Share' },
  more: { id: 'status.more', defaultMessage: 'More' },
  replyAll: { id: 'status.replyAll', defaultMessage: 'Reply to thread' },
  reblog: { id: 'status.reblog', defaultMessage: 'Boost' },
  reblog_private: { id: 'status.reblog_private', defaultMessage: 'Boost to original audience' },
  cancel_reblog_private: { id: 'status.cancel_reblog_private', defaultMessage: 'Unboost' },
  cannot_reblog: { id: 'status.cannot_reblog', defaultMessage: 'This post cannot be boosted' },
  favourite: { id: 'status.favourite', defaultMessage: 'Favourite' },
  open: { id: 'status.open', defaultMessage: 'Expand this status' },
  report: { id: 'status.report', defaultMessage: 'Report @{name}' },
  muteConversation: { id: 'status.mute_conversation', defaultMessage: 'Mute conversation' },
  unmuteConversation: { id: 'status.unmute_conversation', defaultMessage: 'Unmute conversation' },
  pin: { id: 'status.pin', defaultMessage: 'Pin on profile' },
  unpin: { id: 'status.unpin', defaultMessage: 'Unpin from profile' },
  embed: { id: 'status.embed', defaultMessage: 'Embed' },
  admin_account: { id: 'status.admin_account', defaultMessage: 'Open moderation interface for @{name}' },
  admin_status: { id: 'status.admin_status', defaultMessage: 'Open this status in the moderation interface' },
  copy: { id: 'status.copy', defaultMessage: 'Copy link to status' },
});

const obfuscatedCount = count => {
  if (count < 0) {
    return 0;
  } else if (count <= 1) {
    return count;
  } else {
    return '1+';
  }
};

export default @injectIntl
class StatusActionBar extends ImmutablePureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    status: ImmutablePropTypes.map.isRequired,
    onReply: PropTypes.func,
    onFavourite: PropTypes.func,
    onReblog: PropTypes.func,
    onDelete: PropTypes.func,
    onDirect: PropTypes.func,
    onMention: PropTypes.func,
    onMute: PropTypes.func,
    onBlock: PropTypes.func,
    onReport: PropTypes.func,
    onEmbed: PropTypes.func,
    onMuteConversation: PropTypes.func,
    onPin: PropTypes.func,
    withDismiss: PropTypes.bool,
    intl: PropTypes.object.isRequired,
  };

  // Avoid checking props that are functions (and whose equality will always
  // evaluate to false. See react-immutable-pure-component for usage.
  updateOnProps = [
    'status',
    'withDismiss',
  ]

  handleReplyClick = () => {
    if (me) {
      this.props.onReply(this.props.status, this.context.router.history);
    } else {
      this._openInteractionDialog('reply');
    }
  }

  handleShareClick = () => {
    navigator.share({
      text: this.props.status.get('search_index'),
      url: this.props.status.get('url'),
    }).catch((e) => {
      if (e.name !== 'AbortError') console.error(e);
    });
  }

  handleFavouriteClick = () => {
    if (me) {
      this.props.onFavourite(this.props.status);
    } else {
      this._openInteractionDialog('favourite');
    }
  }

  handleReblogClick = e => {
    if (me) {
      this.props.onReblog(this.props.status, e);
    } else {
      this._openInteractionDialog('reblog');
    }
  }

  _openInteractionDialog = type => {
    window.open(`/interact/${this.props.status.get('id')}?type=${type}`, 'mastodon-intent', 'width=445,height=600,resizable=no,menubar=no,status=no,scrollbars=yes');
  }

  handleDeleteClick = () => {
    this.props.onDelete(this.props.status, this.context.router.history);
  }

  handleRedraftClick = () => {
    this.props.onDelete(this.props.status, this.context.router.history, true);
  }

  handlePinClick = () => {
    this.props.onPin(this.props.status);
  }

  handleMentionClick = () => {
    this.props.onMention(this.props.status.get('account'), this.context.router.history);
  }

  handleDirectClick = () => {
    this.props.onDirect(this.props.status.get('account'), this.context.router.history);
  }

  handleMuteClick = () => {
    this.props.onMute(this.props.status.get('account'));
  }

  handleBlockClick = () => {
    this.props.onBlock(this.props.status.get('account'));
  }

  handleOpen = () => {
    this.context.router.history.push(`/statuses/${this.props.status.get('id')}`);
  }

  handleEmbed = () => {
    this.props.onEmbed(this.props.status);
  }

  handleReport = () => {
    this.props.onReport(this.props.status);
  }

  handleConversationMuteClick = () => {
    this.props.onMuteConversation(this.props.status);
  }

  handleCopy = () => {
    const url      = this.props.status.get('url');
    const textarea = document.createElement('textarea');

    textarea.textContent    = url;
    textarea.style.position = 'fixed';

    document.body.appendChild(textarea);

    try {
      textarea.select();
      document.execCommand('copy');
    } catch (e) {

    } finally {
      document.body.removeChild(textarea);
    }
  }

  render () {
    const { status, intl, withDismiss } = this.props;

    const mutingConversation = status.get('muted');
    const anonymousAccess    = !me;
    const publicStatus       = ['public', 'unlisted'].includes(status.get('visibility'));

    let menu = [];
    let reblogIcon = 'retweet';
    let replyIcon;
    let replyTitle;

    menu.push({ text: intl.formatMessage(messages.open), action: this.handleOpen });

    if (publicStatus) {
      menu.push({ text: intl.formatMessage(messages.copy), action: this.handleCopy });
      menu.push({ text: intl.formatMessage(messages.embed), action: this.handleEmbed });
    }

    menu.push(null);

    if (status.getIn(['account', 'id']) === me || withDismiss) {
      menu.push({ text: intl.formatMessage(mutingConversation ? messages.unmuteConversation : messages.muteConversation), action: this.handleConversationMuteClick });
      menu.push(null);
    }

    if (status.getIn(['account', 'id']) === me) {
      if (publicStatus) {
        menu.push({ text: intl.formatMessage(status.get('pinned') ? messages.unpin : messages.pin), action: this.handlePinClick });
      } else {
        if (status.get('visibility') === 'private') {
          menu.push({ text: intl.formatMessage(status.get('reblogged') ? messages.cancel_reblog_private : messages.reblog_private), action: this.handleReblogClick });
        }
      }

      menu.push({ text: intl.formatMessage(messages.delete), action: this.handleDeleteClick });
      menu.push({ text: intl.formatMessage(messages.redraft), action: this.handleRedraftClick });
    } else {
      menu.push({ text: intl.formatMessage(messages.mention, { name: status.getIn(['account', 'username']) }), action: this.handleMentionClick });
      menu.push({ text: intl.formatMessage(messages.direct, { name: status.getIn(['account', 'username']) }), action: this.handleDirectClick });
      menu.push(null);
      menu.push({ text: intl.formatMessage(messages.mute, { name: status.getIn(['account', 'username']) }), action: this.handleMuteClick });
      menu.push({ text: intl.formatMessage(messages.block, { name: status.getIn(['account', 'username']) }), action: this.handleBlockClick });
      menu.push({ text: intl.formatMessage(messages.report, { name: status.getIn(['account', 'username']) }), action: this.handleReport });

      if (isStaff) {
        menu.push(null);
        menu.push({ text: intl.formatMessage(messages.admin_account, { name: status.getIn(['account', 'username']) }), href: `/admin/accounts/${status.getIn(['account', 'id'])}` });
        menu.push({ text: intl.formatMessage(messages.admin_status), href: `/admin/accounts/${status.getIn(['account', 'id'])}/statuses/${status.get('id')}` });
      }
    }

    if (status.get('visibility') === 'direct') {
      reblogIcon = 'envelope';
    } else if (status.get('visibility') === 'private') {
      reblogIcon = 'lock';
    }

    if (status.get('in_reply_to_id', null) === null) {
      replyIcon = 'reply';
      replyTitle = intl.formatMessage(messages.reply);
    } else {
      replyIcon = 'reply-all';
      replyTitle = intl.formatMessage(messages.replyAll);
    }

    const shareButton = ('share' in navigator) && status.get('visibility') === 'public' && (
      <IconButton className='status__action-bar-button' title={intl.formatMessage(messages.share)} icon='share-alt' onClick={this.handleShareClick} />
    );

    return (
      <div className='status__action-bar'>
        <div className='status__action-bar__counter'><IconButton className='status__action-bar-button' title={replyTitle} icon={status.get('in_reply_to_account_id') === status.getIn(['account', 'id']) ? 'reply' : replyIcon} onClick={this.handleReplyClick} /><span className='status__action-bar__counter__label' >{obfuscatedCount(status.get('replies_count'))}</span></div>
        <IconButton className='status__action-bar-button' disabled={!publicStatus} active={status.get('reblogged')} pressed={status.get('reblogged')} title={!publicStatus ? intl.formatMessage(messages.cannot_reblog) : intl.formatMessage(messages.reblog)} icon={reblogIcon} onClick={this.handleReblogClick} />
        <IconButton className='status__action-bar-button star-icon' animate active={status.get('favourited')} pressed={status.get('favourited')} title={intl.formatMessage(messages.favourite)} icon='star' onClick={this.handleFavouriteClick} />
        {shareButton}

        <div className='status__action-bar-dropdown'>
          <DropdownMenuContainer disabled={anonymousAccess} status={status} items={menu} icon='ellipsis-h' size={18} direction='right' title={intl.formatMessage(messages.more)} />
        </div>
      </div>
    );
  }

}
