RSpec.describe NubankSdk::Auth do
  subject(:auth) { described_class.new(cpf: cpf, device_id: '909876543210', connection_adapter: [:test, stubs], api_routes: api_routes) }

  let(:cpf) { '1235678909'}
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:key) { OpenSSL::PKey::RSA.new 2048 }
  let(:dummy_certification) { build :certificate, key: key }
  let(:api_routes) do
    build(:api_routes, paths: {
      app: {
        token: 'https://aa.aa/api/token_teste',
        gen_certificate: 'https://aa.aa/api/login_teste'
      }
    })
  end
  let(:https_connection) { build(:https_connection, connection_adapter: [:test, stubs]) }

  before do
    allow(auth).to receive(:generate_key).and_return(key)
    allow(auth).to receive(:ssl_connection).and_return(https_connection)
    allow(auth).to receive(:update_api_routes)
  end

  describe '#authenticate_with_certificate' do
    it 'returns a valid token' do
      stubs.post('https://aa.aa/api/token_teste') do
        [200, {}, { access_token: '1234567890' }.to_json]
      end

      auth.authenticate_with_certificate('dracarys')
      expect(auth.access_token).to eq('1234567890')
    end
  end

  describe '#request_email_code' do
    it 'returns a valid token' do
      stubs.post('https://aa.aa/api/login_teste') do
        [200, {'WWW-Authenticate': 'sent_to=vi*@e*.*on'}, {}.to_json]
      end

      email = auth.request_email_code('dracarys')
      expect(email).to eq('vi*@e*.*on')
    end
  end

  describe '#exchange_certs' do
    it 'returns a valid token' do
      stubs.post('https://aa.aa/api/login_teste') do
        [200, {}, {certificate: dummy_certification}.to_json]
      end
      allow(auth.certificate).to receive(:save).and_return(true)

      auth.exchange_certs('77', 'dracarys')
      expect(auth.certificate).to have_received(:save).once
    end
  end
end