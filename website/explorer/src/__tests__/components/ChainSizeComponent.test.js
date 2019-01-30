import React from 'react'
import Enzyme, { shallow } from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import connectedChainSize, { ChainSize } from '../../components/ChainSizeComponent';

Enzyme.configure({ adapter: new Adapter() });

function setup({ isLoading, errMsg, chainSize }) {
  const props = {
    fetchChainSize: jest.fn(),
    chainSize: {
      isLoading: isLoading,
      errMsg: errMsg,
      chainSize: chainSize
    }
  }

  const enzymeWrapper = shallow(<ChainSize {...props} />);

  return { props, enzymeWrapper };
}

describe('ChainSize Component - non-connected', () => {

  it('renders self and subcomponents when loading', () => {
    const {props, enzymeWrapper } = setup({
      isLoading: true, 
      errMsg: null,
      chainSize: ""
    });

    expect(enzymeWrapper.length).toEqual(1);
    expect(enzymeWrapper.find('p').text()).toBe('Loading...');

  });

  it('renders self and subcomponents when data successfully fetched', () => {
    const {props, enzymeWrapper } = setup({
      isLoading: false,
      errMsg: null,
      chainSize: "300" 
    });

    expect(enzymeWrapper.length).toEqual(1);
    expect(enzymeWrapper.find('p').text()).toBe('The size of this chain is: 300 GiB');

  });

  it('renders self and subcomponents when data fetch failed', () => {
    const {props, enzymeWrapper } = setup({
      isLoading: false,
      errMsg: "error while fetching the data",
      chainSize: "" 
    });

    expect(enzymeWrapper.length).toEqual(1);
    expect(enzymeWrapper.find('p').text()).toBe('error while fetching the data');

  });
   


});