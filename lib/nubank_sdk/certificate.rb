# frozen_string_literal: true

require 'openssl'

module NubankSdk
  class Certificate
    FILES_PATH = './certificates/'

    def initialize(cpf, key)
      @cpf = cpf
      @key = key
    end

    def process_decoded(certificate)
      encoded = encode certificate

      p12 = create_pkcs12_from encoded
      save p12
    end

    def encoded
      @encoded ||= OpenSSL::PKCS12.new(file.read, 'password')
    end

    private

    def file
      File.open("#{FILES_PATH}#{@cpf}.p12", 'rb')
    end

    def save(p12)
      File.open("#{FILES_PATH}#{@cpf}.p12", 'wb') do |file|
        file.write p12.to_der
      end
    end

    def create_pkcs12_from(certificate)
      OpenSSL::PKCS12.create("password", "key", @key, certificate)
    end

    def encode(certificate)
      OpenSSL::X509::Certificate.new certificate
    end
  end
end