describe CommunityHubspot::Form do
  let(:guid) { '78c2891f-ebdd-44c0-bd94-15c012bbbfbf' } # '561d9ce9-bb4c-45b4-8e32-21cdeaa3a7f0'
  let(:example_form_hash) do
    VCR.use_cassette('form_example') do
      HTTParty.get("https://api.hubapi.com#{CommunityHubspot::Form::FORMS_PATH}/#{guid}/?hapikey=demo").parsed_response
    end
  end

  describe '#initialize' do
    subject { CommunityHubspot::Form.new(example_form_hash) }

    it { should be_an_instance_of CommunityHubspot::Form }
    # its(:guid) { should be_a(String) }
    # its(:properties) { should be_a(Hash) }
    it 'has correct properties' do
      expect(subject.guid).to be_a(String)
      expect(subject.properties).to be_a(Hash)
    end
  end

  before { CommunityHubspot.configure(hapikey: 'demo', portal_id: '62515') }

  describe '.all' do
    cassette 'find_all_forms'

    it 'returns all forms' do
      forms = CommunityHubspot::Form.all
      expect(forms.count).to be > 20

      form = forms.first
      expect(form).to be_a(CommunityHubspot::Form)
    end
  end

  describe '.find' do
    cassette 'form_find'
    subject { CommunityHubspot::Form.find(guid) }

    context 'when the form is found' do
      it { should be_an_instance_of CommunityHubspot::Form }
      # its(:fields) { should_not be_empty }
      it 'has correct properties' do
        expect(subject.fields).not_to be_empty
      end
    end

    context 'when the form is not found' do
      it 'raises an error' do
        expect { CommunityHubspot::Form.find(-1) }.to raise_error(CommunityHubspot::RequestError)
      end
    end
  end

  describe '.create' do
    subject { CommunityHubspot::Form.create!(params) }

    context 'with all required parameters' do
      cassette 'create_form'

      let(:params) do
        {
          name: "Demo Form #{Time.now.to_i}",
          action: '',
          method: 'POST',
          cssClass: 'hs-form stacked',
          redirect: '',
          submitText: 'Sign Up',
          followUpId: '',
          leadNurturingCampaignId: '',
          notifyRecipients: '',
          embeddedCode: ''
        }
      end
      it { should be_an_instance_of CommunityHubspot::Form }
      # its(:guid) { should be_a(String) }
      it 'has correct properties' do
        expect(subject.guid).to be_a(String)
      end
    end

    context 'without all required parameters' do
      cassette 'fail_to_create_form'

      it 'raises an error' do
        expect { CommunityHubspot::Form.create!({}) }.to raise_error(CommunityHubspot::RequestError)
      end
    end
  end

  describe '#fields' do
    context 'returning all the fields' do
      cassette 'fields_among_form'

      let(:form) { CommunityHubspot::Form.new(example_form_hash) }

      it 'returns by default the fields property if present' do
        fields = form.fields
        fields.should_not be_empty
      end

      it 'updates the fields property and returns it' do
        fields = form.fields(bypass_cache: true)
        fields.should_not be_empty
      end
    end

    context 'returning an uniq field' do
      cassette 'field_among_form'

      let(:form) { CommunityHubspot::Form.new(example_form_hash) }
      let(:field_name) { form.fields.first['name'] }

      it 'returns by default the field if present as a property' do
        field = form.fields(only: field_name)
        expect(field).to be_a(Hash)
        expect(field['name']).to be == field_name
      end

      it 'makes an API request if specified' do
        field = form.fields(only: field_name, bypass_cache: true)
        expect(field).to be_a(Hash)
        expect(field['name']).to be == field_name
      end
    end
  end

  describe '#submit' do
    cassette 'form_submit_data'

    let(:form) { CommunityHubspot::Form.find('561d9ce9-bb4c-45b4-8e32-21cdeaa3a7f0') }

    context 'with a valid portal id' do
      before do
        CommunityHubspot.configure(hapikey: 'demo', portal_id: '62515')
      end

      it 'returns true if the form submission is successful' do
        params = {}
        result = form.submit(params)
        result.should be true
      end
    end

    context 'with an invalid portal id' do
      before do
        CommunityHubspot.configure(hapikey: 'demo', portal_id: 'xxxx')
      end

      it 'returns false in case of errors' do
        params = { unknown_field: :bogus_value }
        result = form.submit(params)
        result.should be false
      end
    end

    context 'when initializing CommunityHubspot::Form directly' do
      let(:form) { CommunityHubspot::Form.new('guid' => '561d9ce9-bb4c-45b4-8e32-21cdeaa3a7f0') }

      before { CommunityHubspot.configure(hapikey: 'demo', portal_id: '62515') }

      it 'returns true if the form submission is successful' do
        params = {}
        result = form.submit(params)
        result.should be true
      end
    end
  end

  describe '#update!' do
    cassette 'form_update'

    new_name = 'updated form name 1424709912'
    redirect = 'http://hubspot.com'

    let(:form) { CommunityHubspot::Form.find('561d9ce9-bb4c-45b4-8e32-21cdeaa3a7f0') }
    let(:params) { { name: new_name, redirect: redirect } }
    subject { form.update!(params) }

    it { should be_an_instance_of CommunityHubspot::Form }
    it 'updates properties' do
      subject.properties['name'].should be == new_name
      subject.properties['redirect'].should be == redirect
    end
  end

  describe '#destroy!' do
    cassette 'form_destroy'

    # NOTE: form previous created via the create! method
    let(:form) { CommunityHubspot::Form.find('beb92950-ca65-4daf-87ae-a42c054e429f') }
    subject { form.destroy! }
    it { should be_truthy }

    it 'should be destroyed' do
      subject
      form.destroyed?.should be_truthy
    end
  end
end
