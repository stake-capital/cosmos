import { fetchChainSize, fetchAPI } from '../../redux/actionCreators';
import { put, call } from 'redux-saga/effects';
import sagaHelper from 'redux-saga-testing';
import * as ActionTypes from '../../redux/actionTypes';

describe('fetchChainSize saga test', () => {
  const json = { chain_size: '256' };
  const CHAIN_SIZE = '/chain_size';

  describe('with a successful fetch', () => {
    const it = sagaHelper(fetchChainSize());

    it('should call fetch API', result => {
      expect(result).toEqual(call(fetchAPI, CHAIN_SIZE));
      return json;
    });

    it('should call the success action', result => {
      expect(result).toEqual(put({
        type: ActionTypes.RECEIVE_CHAIN_SIZE, 
        payload: json.chain_size}));
    });

    it('should perform no further work', result => {
      expect(result).not.toBeDefined();
    });

  });

  describe('with a failed fetch', () => {
    const it = sagaHelper(fetchChainSize());
    const error = new Error("404 Not Found");

    it('should call fetch API', result => {
      expect(result).toEqual(call(fetchAPI, CHAIN_SIZE));
      return error;
    });

    it('should call the failure action', result => {
      expect(result).toEqual(put({
        type: ActionTypes.FAILED_CHAIN_SIZE, 
        payload: error.message}));
    });

    it('should perform no further work', result => {
      expect(result).not.toBeDefined();
    });

  });

});