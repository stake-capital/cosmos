import React from 'react';
import Enzyme, { shallow, mount } from 'enzyme';
import Adapter from 'enzyme-adapter-react-16';
import configureStore from 'redux-mock-store';
import ConnectedChainSize, { ChainSize } from '../../components/ChainSizeComponent';
import {Provider} from 'react-redux';
import * as ActionTypes from '../../redux/actionTypes';

beforeAll(() => {
  Enzyme.configure({ adapter: new Adapter() });
});

//******************************************************************************

describe('ChainSize Component - non-connected REACT (shallow rendering)', () => {
  let setup;

  beforeAll(() => {
    
    setup = ({ isLoading, errMsg, chainSize }) => {
      const props = {
        fetchChainSize: jest.fn(),
        chainSize: {
          isLoading: isLoading,
          errMsg: errMsg,
          chainSize: chainSize
        }
      };
    
      const enzymeWrapper = shallow(<ChainSize {...props} />);
    
      return { props, enzymeWrapper };
    }
  });

  describe('when fetching data or at initial state', () => {

    it('renders self and subcomponents', () => {
      const { enzymeWrapper } = setup({
        isLoading: true, 
        errMsg: null,
        chainSize: ""
      });
  
      expect(enzymeWrapper.length).toEqual(1);
      expect(enzymeWrapper.find('p').text()).toBe('Loading...');
  
    });

    it('calls fetchChainSize', () => {
      const { props } = setup({
        isLoading: true, 
        errMsg: null,
        chainSize: ""
      });

      expect(props.fetchChainSize).toHaveBeenCalled();
    });

  });

  describe('when data was successfully fetched', () => {

    it('renders self and subcomponents', () => {
      const { enzymeWrapper } = setup({
        isLoading: false,
        errMsg: null,
        chainSize: "300" 
      });
  
      expect(enzymeWrapper.length).toEqual(1);
      expect(enzymeWrapper.find('p').text()).toBe('The size of this chain is: 300 GiB');
  
    });

  });

  describe('when data failed to be fetched', () => {

    it('renders self and subcomponents', () => {
      const { enzymeWrapper } = setup({
        isLoading: false,
        errMsg: "error while fetching the data",
        chainSize: "" 
      });
  
      expect(enzymeWrapper.length).toEqual(1);
      expect(enzymeWrapper.find('p').text()).toBe('error while fetching the data');
  
    });

  });
});

//******************************************************************************
describe('ChainSize Component - REACT+REDUX REACT-REDUX (Mount + wrapping in <Provider>)', () => {
  
  const initialState = {
    chainSize: {
      isLoading: true,
      errMsg: null,
      chainSize: ""
    }
  };
  const mockStore = configureStore();
  let store, wrapper;

  beforeAll(() => {
    store = mockStore(initialState);
    wrapper = mount(
      <Provider store={store}>
        <ConnectedChainSize />
      </Provider>);
  });

  beforeEach(() => {
    store.clearActions();
  });

  it('renders the connected component', () => {
    expect(wrapper.find(ConnectedChainSize).length).toEqual(1);
  });

  it('has same props as the initial state', () => {
    expect(wrapper.find(ChainSize).prop('chainSize')).toEqual(initialState.chainSize);
  });

  it('sends actions on dispatching ', () => {
    let action
    store.dispatch({type: ActionTypes.REQUEST_CHAIN_SIZE});
    action = store.getActions();
    expect(action[0].type).toBe("REQUEST_CHAIN_SIZE");
});

});
