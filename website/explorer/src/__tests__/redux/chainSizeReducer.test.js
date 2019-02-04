import { ChainSize } from '../../redux/chainSizeReducer';
import * as ActionTypes from '../../redux/actionTypes';

describe('chainSize reducer', () => {
  it('should return the initial state', () => {
    expect(ChainSize(undefined, {}))
    .toEqual({
      isLoading: true,
      errMsg: null,
      chainSize: ""
    });
  });

  it('should handle REQUEST_CHAIN_SIZE', () => {
    expect(ChainSize({}, {
      type: ActionTypes.REQUEST_CHAIN_SIZE
    }))
    .toEqual({
      isLoading: true, 
      errMsg: null,
      chainSize: ""
    });
  });

  it('should handle RECEIVE_CHAIN_SIZE', () => {
    expect(ChainSize({}, {
      type: ActionTypes.RECEIVE_CHAIN_SIZE,
      payload: "size of the chain" 
    }))
    .toEqual({
      isLoading: false,
      errMsg: null,
      chainSize: "size of the chain" 
    });
  });

  it('should handle FAILED_CHAIN_SIZE', () => {
    expect(ChainSize({}, {
      type: ActionTypes.FAILED_CHAIN_SIZE,
      payload: "error message"
    }))
    .toEqual({
      isLoading: false,
      errMsg: "error message",
      chainSize: "" 
    });
  });
});