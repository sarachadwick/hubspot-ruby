describe CommunityHubspot::DealProperties do
  describe '.add_default_parameters' do
    let(:opts) { {} }
    subject { CommunityHubspot::DealProperties.add_default_parameters(opts) }
    context 'default parameters' do
      context 'without property parameter' do
        # its([:property]) { should == 'email' }
        it 'has correct properties' do
          expect(subject[:property]).to eq('email')
        end
      end

      context 'with property parameter' do
        let(:opts) { {property: 'dealname' } }
        # its([:property]) { should == 'dealname'}
        it 'has correct properties' do
          expect(subject[:property]).to eq('dealname')
        end
      end
    end
  end

  let(:example_groups) do
    VCR.use_cassette('deal_groups_example') do
      HTTParty.get('https://api.hubapi.com/deals/v1/groups?hapikey=demo').parsed_response
    end
  end

  let(:example_properties) do
    VCR.use_cassette('deal_properties_example') do
      HTTParty.get('https://api.hubapi.com/deals/v1/properties?hapikey=demo').parsed_response
    end
  end

  before { CommunityHubspot.configure(hapikey: 'demo') }

  describe 'Properties' do
    describe '.all' do
      context 'with no filter' do
        cassette 'deal_all_properties'

        it 'should return all properties' do
          expect(CommunityHubspot::DealProperties.all).to eql(example_properties)
        end
      end

      let(:groups) { %w(calltrackinginfo emailinformation) }

      context 'with included groups' do
        cassette 'deal_properties_in_groups'

        it 'should return properties for the specified group[s]' do
          response = CommunityHubspot::DealProperties.all({}, { include: groups })
          response.each { |p| expect(groups.include?(p['groupName'])).to be_truthy }
        end
      end

      context 'with excluded groups' do
        cassette 'deal_properties_not_in_groups'

        it 'should return properties for the non-specified group[s]' do
          response = CommunityHubspot::DealProperties.all({}, { exclude: groups })
          response.each { |p| expect(groups.include?(p['groupName'])).to be_falsey }
        end
      end
    end

    let(:params) { {
      'name'                          => 'my_new_property',
      'label'                         => 'This is my new property',
      'description'                   => 'How much money do you have?',
      'groupName'                     => 'dealinformation',
      'type'                          => 'string',
      'fieldType'                     => 'text',
      'hidden'                        => false,
      'options'                       => [{
                                            'description'  => '',
                                            'value'        => 'Over $50K',
                                            'readOnly'     => false,
                                            'label'        => 'Over $50K',
                                            'displayOrder' => 0,
                                            'hidden'       => false,
                                            'doubleData'   => 0.0
                                          },
                                          {
                                            'description'  => '',
                                            'value'        => 'Under $50K',
                                            'readOnly'     => false,
                                            'label'        => 'Under $50K',
                                            'displayOrder' => 1,
                                            'hidden'       => false,
                                            'doubleData'   => 0.0
                                          }],
      'deleted'                       => false,
      'displayOrder'                  => 0,
      'formField'                     => true,
      'readOnlyValue'                 => false,
      'readOnlyDefinition'            => false,
      'mutableDefinitionNotDeletable' => false,
      'calculated'                    => false,
      'externalOptions'               => false,
      'displayMode'                   => 'current_value'
    } }

    describe '.create!' do
      context 'with no valid parameters' do
        cassette 'deal_fail_to_create_property'

        it 'should return nil' do
          expect(CommunityHubspot::DealProperties.create!({})).to be(nil)
        end
      end

      context 'with all valid parameters' do
        cassette 'deal_create_property'

        it 'should return the valid parameters' do
          response = CommunityHubspot::DealProperties.create!(params)
          expect(CommunityHubspot::DealProperties.same?(params, response)).to be_truthy
        end
      end
    end

    describe '.update!' do
      context 'with no valid parameters' do

        it 'should return nil ' do
          expect(CommunityHubspot::DealProperties.update!(params['name'], {})).to be(nil)
        end
      end

      context 'with mixed parameters' do
        cassette 'deal_update_property'

        it 'should return the valid parameters' do
          params['description'] = 'What is their favorite flavor?'

          response = CommunityHubspot::DealProperties.update!(params['name'], params)
          expect(CommunityHubspot::DealProperties.same?(response, params)).to be_truthy
        end
      end
    end

    describe '.delete!' do
      let(:name) { params['name'] }

      context 'with existing property' do
        cassette 'deal_delete_property'

        it 'should return nil' do
          expect(CommunityHubspot::DealProperties.delete!(name)).to eq(nil)
        end
      end

      context 'with non-existent property' do
        cassette 'deal_delete_non_property'

        it 'should raise an error' do
          expect { CommunityHubspot::DealProperties.delete!(name) }.to raise_error(CommunityHubspot::RequestError)
        end
      end
    end
  end

  describe 'Groups' do
    describe '.groups' do
      context 'with no filter' do
        cassette 'deal_all_groups'

        it 'should return all groups' do
          expect(CommunityHubspot::DealProperties.groups).to eql(example_groups)
        end
      end

      let(:groups) { %w(calltrackinginfo emailinformation) }

      context 'with included groups' do
        cassette 'deal_groups_included'

        it 'should return the specified groups' do
          response = CommunityHubspot::DealProperties.groups({}, { include: groups })
          response.each { |p| expect(groups.include?(p['name'])).to be_truthy }
        end
      end

      context 'with excluded groups' do
        cassette 'deal_groups_not_excluded'

        it 'should return groups that were not excluded' do
          response = CommunityHubspot::DealProperties.groups({}, { exclude: groups })
          response.each { |p| expect(groups.include?(p['name'])).to be_falsey }
        end
      end
    end

    let(:params) { { 'name' => 'ff_group1', 'displayName' => 'Test Group One', 'displayOrder' => 100, 'badParam' => 99 } }

    describe '.create_group!' do
      context 'with no valid parameters' do
        it 'should return nil' do
          expect(CommunityHubspot::DealProperties.create_group!({})).to be(nil)
        end
      end

      context 'with mixed parameters' do
        cassette 'deal_create_group'

        it 'should return the valid parameters' do
          response = CommunityHubspot::DealProperties.create_group!(params)
          expect(CommunityHubspot::DealProperties.same?(response, params)).to be_truthy
        end
      end

      context 'with some valid parameters' do
        cassette 'deal_create_group_some_params'

        let(:sub_params) { params.select { |k, _| k != 'displayName' } }

        it 'should return the valid parameters' do
          params['name'] = 'ff_group234'
          response       = CommunityHubspot::DealProperties.create_group!(sub_params)
          expect(CommunityHubspot::DealProperties.same?(response, sub_params)).to be_truthy
        end
      end
    end

    describe '.update_group!' do
      context 'with no valid parameters' do

        it 'should return nil ' do
          expect(CommunityHubspot::DealProperties.update_group!(params['name'], {})).to be(nil)
        end
      end

      context 'with mixed parameters' do
        cassette 'deal_update_group'

        it 'should return the valid parameters' do
          params['displayName'] = 'Test Group OneA'

          response = CommunityHubspot::DealProperties.update_group!(params['name'], params)
          expect(CommunityHubspot::DealProperties.same?(response, params)).to be_truthy
        end
      end

    end

    describe '.delete_group!' do
      let(:name) { params['name'] }

      context 'with existing group' do
        cassette 'deal_delete_group'

        it 'should return nil' do
          expect(CommunityHubspot::DealProperties.delete_group!(name)).to eq(nil)
        end
      end

      context 'with non-existent group' do
        cassette 'deal_delete_non_group'

        it 'should raise an error' do
          expect { CommunityHubspot::DealProperties.delete_group!(name) }.to raise_error(CommunityHubspot::RequestError)
        end
      end
    end
  end
end
