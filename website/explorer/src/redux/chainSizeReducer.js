import * as ActionTypes from './actionTypes';

export const ChainSize = (state = {
  isLoading: true,
  errMsg: null,
  chainSize: ""
}, action) => {
  switch(action.type) {

    case ActionTypes.REQUEST_CHAIN_SIZE:
      return {...state,
        isLoading: true, 
        errMsg: null,
        chainSize: ""
      };

    case ActionTypes.RECEIVE_CHAIN_SIZE:
      return {...state,
        isLoading: false,
        errMsg: null,
        chainSize: action.payload 
      };

    case ActionTypes.FAILED_CHAIN_SIZE:
      return {...state,
        isLoading: false,
        errMsg: action.payload,
        chainSize: "" 
      };

    default:
      return state;
  }
}