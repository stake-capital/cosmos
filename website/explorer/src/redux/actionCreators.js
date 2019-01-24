import * as ActionTypes from './actionTypes';
import { call, put, takeEvery, all } from 'redux-saga/effects'

const API = 'https://private-cc47d-cosmosexplorer.apiary-mock.com';
const CHAIN_SIZE = '/chain_size';

function* watchFetchChainSize() {
  yield takeEvery(ActionTypes.REQUEST_CHAIN_SIZE, fetchChainSize)
}

function* fetchChainSize() {
  try {
    const data = yield call(fetch, API + CHAIN_SIZE);
    const json = yield call([data, data.json]);
    yield put({type: ActionTypes.RECEIVE_CHAIN_SIZE, payload: json.chain_size});
  } catch (error) {
    yield put({type: ActionTypes.FAILED_CHAIN_SIZE, payload: error.message});
  }
}

// preparing introduction of other sagas
export function* rootSaga() {
  yield all([
    watchFetchChainSize()
  ]);
}