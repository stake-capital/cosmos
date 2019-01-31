import * as ActionTypes from './actionTypes';
import { call, put, takeEvery, all } from 'redux-saga/effects'
import fetch from 'cross-fetch';

const API = 'https://private-cc47d-cosmosexplorer.apiary-mock.com';
const CHAIN_SIZE = '/chain_size';

function* watchFetchChainSize() {
  yield takeEvery(ActionTypes.REQUEST_CHAIN_SIZE, fetchChainSize)
};

export function* fetchChainSize() {
  try {
    const json = yield call(fetchAPI, CHAIN_SIZE);
    yield put({type: ActionTypes.RECEIVE_CHAIN_SIZE, payload: json.chain_size});
  } catch (error) {
    yield put({type: ActionTypes.FAILED_CHAIN_SIZE, payload: error.message});
  }
};

// preparing introduction of other sagas
export function* rootSaga() {
  yield all([
    watchFetchChainSize()
  ]);
};

export const fetchAPI =  async (endpoint) => {
  const result = await fetch(API + endpoint);
  const json = await result.json();
  return json;
};