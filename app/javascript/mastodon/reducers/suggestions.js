import {
  SUGGESTIONS_FETCH_REQUEST,
  SUGGESTIONS_FETCH_SUCCESS,
  SUGGESTIONS_FETCH_FAIL,
  SUGGESTIONS_DISMISS,
} from '../actions/suggestions';
import { ACCOUNT_BLOCK_SUCCESS, ACCOUNT_MUTE_SUCCESS } from 'mastodon/actions/accounts';
import { DOMAIN_BLOCK_SUCCESS } from 'mastodon/actions/domain_blocks';
import { Map as ImmutableMap, List as ImmutableList, fromJS } from 'immutable';

const initialState = ImmutableMap({
  items: ImmutableList(),
  isLoading: false,
});

export default function suggestionsReducer(state = initialState, action) {
  switch(action.type) {
  case SUGGESTIONS_FETCH_REQUEST:
    return state.set('isLoading', true);
  case SUGGESTIONS_FETCH_SUCCESS:
    return state.withMutations(map => {
      map.set('items', fromJS(action.accounts.map(x => x.id)));
      map.set('isLoading', false);
    });
  case SUGGESTIONS_FETCH_FAIL:
    return state.set('isLoading', false);
  case SUGGESTIONS_DISMISS:
    return state.update('items', list => list.filterNot(id => id === action.id));
  case ACCOUNT_BLOCK_SUCCESS:
  case ACCOUNT_MUTE_SUCCESS:
    return state.update('items', list => list.filterNot(id => id === action.relationship.id));
  case DOMAIN_BLOCK_SUCCESS:
    return state.update('items', list => list.filterNot(id => action.accounts.includes(id)));
  default:
    return state;
  }
};
