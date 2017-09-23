require 'spec_helper'
describe 'passbolt' do

  context 'with defaults for all parameters' do
    it { should contain_class('passbolt') }
  end
end
