import React from 'react';
import { connect } from 'react-redux';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { debounce } from 'lodash';
import LoadingIndicator from '../../components/loading_indicator';
import Column from '../ui/components/column';
import ColumnBackButtonSlim from '../../components/column_back_button_slim';
import DomainContainer from '../../containers/domain_container';
import { fetchDomainBlocks, expandDomainBlocks } from '../../actions/domain_blocks';
import ScrollableList from '../../components/scrollable_list';

const messages = defineMessages({
  heading: { id: 'column.domain_blocks', defaultMessage: 'Hidden domains' },
  unblockDomain: { id: 'account.unblock_domain', defaultMessage: 'Unhide {domain}' },
});

const mapStateToProps = state => ({
  domains: state.getIn(['domain_lists', 'blocks', 'items']),
  hasMore: !!state.getIn(['domain_lists', 'blocks', 'next']),
});

export default @connect(mapStateToProps)
@injectIntl
class Blocks extends ImmutablePureComponent {

  static propTypes = {
    params: PropTypes.object.isRequired,
    dispatch: PropTypes.func.isRequired,
    shouldUpdateScroll: PropTypes.func,
    hasMore: PropTypes.bool,
    domains: ImmutablePropTypes.orderedSet,
    intl: PropTypes.object.isRequired,
  };

  componentWillMount () {
    this.props.dispatch(fetchDomainBlocks());
  }

  handleLoadMore = debounce(() => {
    this.props.dispatch(expandDomainBlocks());
  }, 300, { leading: true });

  render () {
    const { intl, domains, shouldUpdateScroll, hasMore } = this.props;

    if (!domains) {
      return (
        <Column>
          <LoadingIndicator />
        </Column>
      );
    }

    const emptyMessage = <FormattedMessage id='empty_column.domain_blocks' defaultMessage='There are no hidden domains yet.' />;

    return (
      <Column icon='minus-circle' heading={intl.formatMessage(messages.heading)}>
        <ColumnBackButtonSlim />
        <ScrollableList
          scrollKey='domain_blocks'
          onLoadMore={this.handleLoadMore}
          hasMore={hasMore}
          shouldUpdateScroll={shouldUpdateScroll}
          emptyMessage={emptyMessage}
        >
          {domains.map(domain =>
            <DomainContainer key={domain} domain={domain} />
          )}
        </ScrollableList>
      </Column>
    );
  }

}
