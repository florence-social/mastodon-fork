import React from 'react';
import Column from '../ui/components/column';
import ColumnLink from '../ui/components/column_link';
import ColumnSubheading from '../ui/components/column_subheading';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { me, invitesEnabled, version, profile_directory, repository, source_url } from '../../initial_state';
import { fetchFollowRequests } from '../../actions/accounts';
import { List as ImmutableList } from 'immutable';
import { Link } from 'react-router-dom';
import NavigationBar from '../compose/components/navigation_bar';
import Icon from 'mastodon/components/icon';

const messages = defineMessages({
  home_timeline: { id: 'tabs_bar.home', defaultMessage: 'Home' },
  notifications: { id: 'tabs_bar.notifications', defaultMessage: 'Notifications' },
  public_timeline: { id: 'navigation_bar.public_timeline', defaultMessage: 'Federated timeline' },
  settings_subheading: { id: 'column_subheading.settings', defaultMessage: 'Settings' },
  community_timeline: { id: 'navigation_bar.community_timeline', defaultMessage: 'Local timeline' },
  direct: { id: 'navigation_bar.direct', defaultMessage: 'Direct messages' },
  preferences: { id: 'navigation_bar.preferences', defaultMessage: 'Preferences' },
  follow_requests: { id: 'navigation_bar.follow_requests', defaultMessage: 'Follow requests' },
  favourites: { id: 'navigation_bar.favourites', defaultMessage: 'Favourites' },
  blocks: { id: 'navigation_bar.blocks', defaultMessage: 'Blocked users' },
  domain_blocks: { id: 'navigation_bar.domain_blocks', defaultMessage: 'Hidden domains' },
  mutes: { id: 'navigation_bar.mutes', defaultMessage: 'Muted users' },
  pins: { id: 'navigation_bar.pins', defaultMessage: 'Pinned toots' },
  lists: { id: 'navigation_bar.lists', defaultMessage: 'Lists' },
  discover: { id: 'navigation_bar.discover', defaultMessage: 'Discover' },
  personal: { id: 'navigation_bar.personal', defaultMessage: 'Personal' },
  security: { id: 'navigation_bar.security', defaultMessage: 'Security' },
  menu: { id: 'getting_started.heading', defaultMessage: 'Getting started' },
  profile_directory: { id: 'getting_started.directory', defaultMessage: 'Profile directory' },
});

const mapStateToProps = state => ({
  myAccount: state.getIn(['accounts', me]),
  unreadFollowRequests: state.getIn(['user_lists', 'follow_requests', 'items'], ImmutableList()).size,
});

const mapDispatchToProps = dispatch => ({
  fetchFollowRequests: () => dispatch(fetchFollowRequests()),
});

const badgeDisplay = (number, limit) => {
  if (number === 0) {
    return undefined;
  } else if (limit && number >= limit) {
    return `${limit}+`;
  } else {
    return number;
  }
};

export default @connect(mapStateToProps, mapDispatchToProps)
@injectIntl
class GettingStarted extends ImmutablePureComponent {

  static propTypes = {
    intl: PropTypes.object.isRequired,
    myAccount: ImmutablePropTypes.map.isRequired,
    columns: ImmutablePropTypes.list,
    multiColumn: PropTypes.bool,
    fetchFollowRequests: PropTypes.func.isRequired,
    unreadFollowRequests: PropTypes.number,
    unreadNotifications: PropTypes.number,
  };

  componentDidMount () {
    const { myAccount, fetchFollowRequests } = this.props;

    if (myAccount.get('locked')) {
      fetchFollowRequests();
    }
  }

  render () {
    const { intl, myAccount, multiColumn, unreadFollowRequests } = this.props;

    const navItems = [];
    let i = 1;
    let height = (multiColumn) ? 0 : 60;

    if (multiColumn) {
      navItems.push(
        <ColumnSubheading key={i++} text={intl.formatMessage(messages.discover)} />,
        <ColumnLink key={i++} icon='users' text={intl.formatMessage(messages.community_timeline)} to='/timelines/public/local' />,
        <ColumnLink key={i++} icon='globe' text={intl.formatMessage(messages.public_timeline)} to='/timelines/public' />,
      );

      height += 34 + 48*2;

      if (profile_directory) {
        navItems.push(
          <ColumnLink key={i++} icon='address-book' text={intl.formatMessage(messages.profile_directory)} href='/explore' />
        );

        height += 48;
      }

      navItems.push(
        <ColumnSubheading key={i++} text={intl.formatMessage(messages.personal)} />
      );

      height += 34;
    } else if (profile_directory) {
      navItems.push(
        <ColumnLink key={i++} icon='address-book' text={intl.formatMessage(messages.profile_directory)} href='/explore' />
      );

      height += 48;
    }

    navItems.push(
      <ColumnLink key={i++} icon='envelope' text={intl.formatMessage(messages.direct)} to='/timelines/direct' />,
      <ColumnLink key={i++} icon='star' text={intl.formatMessage(messages.favourites)} to='/favourites' />,
      <ColumnLink key={i++} icon='list-ul' text={intl.formatMessage(messages.lists)} to='/lists' />
    );

    height += 48*3;

    if (myAccount.get('locked')) {
      navItems.push(<ColumnLink key={i++} icon='users' text={intl.formatMessage(messages.follow_requests)} badge={badgeDisplay(unreadFollowRequests, 40)} to='/follow_requests' />);
      height += 48;
    }

    if (!multiColumn) {
      navItems.push(
        <ColumnSubheading key={i++} text={intl.formatMessage(messages.settings_subheading)} />,
        <ColumnLink key={i++} icon='gears' text={intl.formatMessage(messages.preferences)} href='/settings/preferences' />,
      );

      height += 34 + 48;
    }

    return (
      <Column label={intl.formatMessage(messages.menu)}>
        {multiColumn && <div className='column-header__wrapper'>
          <h1 className='column-header'>
            <button>
              <Icon id='bars' className='column-header__icon' fixedWidth />
              <FormattedMessage id='getting_started.heading' defaultMessage='Getting started' />
            </button>
          </h1>
        </div>}

        <div className='getting-started'>
          <div className='getting-started__wrapper' style={{ height }}>
            {!multiColumn && <NavigationBar account={myAccount} />}
            {navItems}
          </div>

          {!multiColumn && <div className='flex-spacer' />}

          <div className='getting-started__footer'>
            <ul>
              {invitesEnabled && <li><a href='/invites' target='_blank'><FormattedMessage id='getting_started.invite' defaultMessage='Invite people' /></a> · </li>}
              {multiColumn && <li><Link to='/keyboard-shortcuts'><FormattedMessage id='navigation_bar.keyboard_shortcuts' defaultMessage='Hotkeys' /></Link> · </li>}
              <li><a href='/auth/edit'><FormattedMessage id='getting_started.security' defaultMessage='Security' /></a> · </li>
              <li><a href='/about/more' target='_blank'><FormattedMessage id='navigation_bar.info' defaultMessage='About this server' /></a> · </li>
              <li><a href='https://joinmastodon.org/apps' target='_blank'><FormattedMessage id='navigation_bar.apps' defaultMessage='Mobile apps' /></a> · </li>
              <li><a href='/terms' target='_blank'><FormattedMessage id='getting_started.terms' defaultMessage='Terms of service' /></a> · </li>
              <li><a href='/settings/applications' target='_blank'><FormattedMessage id='getting_started.developers' defaultMessage='Developers' /></a> · </li>
              <li><a href='https://docs.joinmastodon.org' target='_blank'><FormattedMessage id='getting_started.documentation' defaultMessage='Documentation' /></a> · </li>
              <li><a href='/auth/sign_out' data-method='delete'><FormattedMessage id='navigation_bar.logout' defaultMessage='Logout' /></a></li>
            </ul>

            <p>
              <FormattedMessage
                id='getting_started.open_source_notice'
                defaultMessage='Mastodon is open source software. You can contribute or report issues on GitHub at {github}.'
                values={{ github: <span><a href={source_url} rel='noopener' target='_blank'>{repository}</a> (v{version})</span> }}
              />
            </p>
          </div>
        </div>
      </Column>
    );
  }

}
