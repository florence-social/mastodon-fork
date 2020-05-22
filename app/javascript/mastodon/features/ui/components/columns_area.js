import React from 'react';
import PropTypes from 'prop-types';
import { defineMessages, injectIntl } from 'react-intl';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';

import ReactSwipeableViews from 'react-swipeable-views';
import TabsBar, { links, getIndex, getLink } from './tabs_bar';
import { Link } from 'react-router-dom';

import BundleContainer from '../containers/bundle_container';
import ColumnLoading from './column_loading';
import DrawerLoading from './drawer_loading';
import BundleColumnError from './bundle_column_error';
import { Compose, Notifications, HomeTimeline, CommunityTimeline, PublicTimeline, HashtagTimeline, DirectTimeline, FavouritedStatuses, ListTimeline } from '../../ui/util/async-components';
import Icon from 'mastodon/components/icon';
import ComposePanel from './compose_panel';
import NavigationPanel from './navigation_panel';

import detectPassiveEvents from 'detect-passive-events';
import { scrollRight } from '../../../scroll';

const componentMap = {
  'COMPOSE': Compose,
  'HOME': HomeTimeline,
  'NOTIFICATIONS': Notifications,
  'PUBLIC': PublicTimeline,
  'COMMUNITY': CommunityTimeline,
  'HASHTAG': HashtagTimeline,
  'DIRECT': DirectTimeline,
  'FAVOURITES': FavouritedStatuses,
  'LIST': ListTimeline,
};

const messages = defineMessages({
  publish: { id: 'compose_form.publish', defaultMessage: 'Toot' },
});

const shouldHideFAB = path => path.match(/^\/statuses\/|^\/search|^\/getting-started/);

export default @(component => injectIntl(component, { withRef: true }))
class ColumnsArea extends ImmutablePureComponent {

  static contextTypes = {
    router: PropTypes.object.isRequired,
  };

  static propTypes = {
    intl: PropTypes.object.isRequired,
    columns: ImmutablePropTypes.list.isRequired,
    isModalOpen: PropTypes.bool.isRequired,
    singleColumn: PropTypes.bool,
    children: PropTypes.node,
  };

  state = {
    shouldAnimate: false,
  }

  componentWillReceiveProps() {
    this.setState({ shouldAnimate: false });
  }

  componentDidMount() {
    if (!this.props.singleColumn) {
      this.node.addEventListener('wheel', this.handleWheel,  detectPassiveEvents.hasSupport ? { passive: true } : false);
    }

    this.lastIndex   = getIndex(this.context.router.history.location.pathname);
    this.isRtlLayout = document.getElementsByTagName('body')[0].classList.contains('rtl');

    this.setState({ shouldAnimate: true });
  }

  componentWillUpdate(nextProps) {
    if (this.props.singleColumn !== nextProps.singleColumn && nextProps.singleColumn) {
      this.node.removeEventListener('wheel', this.handleWheel);
    }
  }

  componentDidUpdate(prevProps) {
    if (this.props.singleColumn !== prevProps.singleColumn && !this.props.singleColumn) {
      this.node.addEventListener('wheel', this.handleWheel,  detectPassiveEvents.hasSupport ? { passive: true } : false);
    }
    this.lastIndex = getIndex(this.context.router.history.location.pathname);
    this.setState({ shouldAnimate: true });
  }

  componentWillUnmount () {
    if (!this.props.singleColumn) {
      this.node.removeEventListener('wheel', this.handleWheel);
    }
  }

  handleChildrenContentChange() {
    if (!this.props.singleColumn) {
      const modifier = this.isRtlLayout ? -1 : 1;
      this._interruptScrollAnimation = scrollRight(this.node, (this.node.scrollWidth - window.innerWidth) * modifier);
    }
  }

  handleSwipe = (index) => {
    this.pendingIndex = index;

    const nextLinkTranslationId = links[index].props['data-preview-title-id'];
    const currentLinkSelector = '.tabs-bar__link.active';
    const nextLinkSelector = `.tabs-bar__link[data-preview-title-id="${nextLinkTranslationId}"]`;

    // HACK: Remove the active class from the current link and set it to the next one
    // React-router does this for us, but too late, feeling laggy.
    document.querySelector(currentLinkSelector).classList.remove('active');
    document.querySelector(nextLinkSelector).classList.add('active');

    if (!this.state.shouldAnimate && typeof this.pendingIndex === 'number') {
      this.context.router.history.push(getLink(this.pendingIndex));
      this.pendingIndex = null;
    }
  }

  handleAnimationEnd = () => {
    if (typeof this.pendingIndex === 'number') {
      this.context.router.history.push(getLink(this.pendingIndex));
      this.pendingIndex = null;
    }
  }

  handleWheel = () => {
    if (typeof this._interruptScrollAnimation !== 'function') {
      return;
    }

    this._interruptScrollAnimation();
  }

  setRef = (node) => {
    this.node = node;
  }

  renderView = (link, index) => {
    const columnIndex = getIndex(this.context.router.history.location.pathname);
    const title = this.props.intl.formatMessage({ id: link.props['data-preview-title-id'] });
    const icon = link.props['data-preview-icon'];

    const view = (index === columnIndex) ?
      React.cloneElement(this.props.children) :
      <ColumnLoading title={title} icon={icon} />;

    return (
      <div className='columns-area columns-area--mobile' key={index}>
        {view}
      </div>
    );
  }

  renderLoading = columnId => () => {
    return columnId === 'COMPOSE' ? <DrawerLoading /> : <ColumnLoading />;
  }

  renderError = (props) => {
    return <BundleColumnError {...props} />;
  }

  render () {
    const { columns, children, singleColumn, isModalOpen, intl } = this.props;
    const { shouldAnimate } = this.state;

    const columnIndex = getIndex(this.context.router.history.location.pathname);

    if (singleColumn) {
      const floatingActionButton = shouldHideFAB(this.context.router.history.location.pathname) ? null : <Link key='floating-action-button' to='/statuses/new' className='floating-action-button' aria-label={intl.formatMessage(messages.publish)}><Icon id='pencil' /></Link>;

      const content = columnIndex !== -1 ? (
        <ReactSwipeableViews key='content' index={columnIndex} onChangeIndex={this.handleSwipe} onTransitionEnd={this.handleAnimationEnd} animateTransitions={shouldAnimate} springConfig={{ duration: '400ms', delay: '0s', easeFunction: 'ease' }} style={{ height: '100%' }}>
          {links.map(this.renderView)}
        </ReactSwipeableViews>
      ) : (
        <div key='content' className='columns-area columns-area--mobile'>{children}</div>
      );

      return (
        <div className='columns-area__panels'>
          <div className='columns-area__panels__pane columns-area__panels__pane--compositional'>
            <div className='columns-area__panels__pane__inner'>
              <ComposePanel />
            </div>
          </div>

          <div className='columns-area__panels__main'>
            <TabsBar key='tabs' />
            {content}
          </div>

          <div className='columns-area__panels__pane columns-area__panels__pane--start columns-area__panels__pane--navigational'>
            <div className='columns-area__panels__pane__inner'>
              <NavigationPanel />
            </div>
          </div>

          {floatingActionButton}
        </div>
      );
    }

    return (
      <div className={`columns-area ${ isModalOpen ? 'unscrollable' : '' }`} ref={this.setRef}>
        {columns.map(column => {
          const params = column.get('params', null) === null ? null : column.get('params').toJS();
          const other  = params && params.other ? params.other : {};

          return (
            <BundleContainer key={column.get('uuid')} fetchComponent={componentMap[column.get('id')]} loading={this.renderLoading(column.get('id'))} error={this.renderError}>
              {SpecificComponent => <SpecificComponent columnId={column.get('uuid')} params={params} multiColumn {...other} />}
            </BundleContainer>
          );
        })}

        {React.Children.map(children, child => React.cloneElement(child, { multiColumn: true }))}
      </div>
    );
  }

}
