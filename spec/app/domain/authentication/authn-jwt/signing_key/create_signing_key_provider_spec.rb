# frozen_string_literal: true

require 'spec_helper'

RSpec.describe('Authentication::AuthnJwt::SigningKey::CreateSigningKeyProvider') do

  let(:log_output) { StringIO.new }
  let(:logger) {
    Logger.new(
      log_output,
      formatter: proc do | severity, time, progname, msg |
        "#{severity},#{msg}\n"
      end)
  }

  let(:authenticator_input) {
    Authentication::AuthenticatorInput.new(
      authenticator_name: "authn-jwt",
      service_id: "my-service",
      account: "my-account",
      username: "dummy_identity",
      credentials: "dummy",
      client_ip: "dummy",
      request: "dummy"
    )
  }

  let(:mocked_signing_key_settings_type_is_wrong) {
    Authentication::AuthnJwt::SigningKey::SigningKeySettings.new(
      uri: "uri",
      type: "type"
    )
  }
  let(:mocked_signing_key_settings_type_jwks_uri) {
    Authentication::AuthnJwt::SigningKey::SigningKeySettings.new(
      uri: "uri",
      type: "jwks-uri"
    )
  }
  let(:mocked_signing_key_settings_type_provider_uri) {
    Authentication::AuthnJwt::SigningKey::SigningKeySettings.new(
      uri: "uri",
      type: "provider-uri"
    )
  }

  let(:mocked_fetch_signing_key_settings_type_is_wrong) { double("MockedFetchSigningKeySettingsTypeIsWrong") }
  let(:mocked_fetch_signing_key_settings_type_jwks_uri) { double("MockedFetchSigningKeySettingsTypeJwksUri") }
  let(:mocked_fetch_signing_key_settings_type_provider_uri) { double("MockedFetchSigningKeySettingsTypeProviderUri") }

  let(:mocked_logger) { double("Mocked logger")  }

  before(:each) do
    allow(mocked_logger).to(
      receive(:debug).and_return(nil)
    )

    allow(mocked_logger).to(
      receive(:info).and_return(nil)
    )

    allow(mocked_fetch_signing_key_settings_type_is_wrong).to(
      receive(:call).and_return(mocked_signing_key_settings_type_is_wrong)
    )

    allow(mocked_fetch_signing_key_settings_type_jwks_uri).to(
      receive(:call).and_return(mocked_signing_key_settings_type_jwks_uri)
    )

    allow(mocked_fetch_signing_key_settings_type_provider_uri).to(
      receive(:call).and_return(mocked_signing_key_settings_type_provider_uri)
    )
  end

  #  ____  _   _  ____    ____  ____  ___  ____  ___
  # (_  _)( )_( )( ___)  (_  _)( ___)/ __)(_  _)/ __)
  #   )(   ) _ (  )__)     )(   )__) \__ \  )(  \__ \
  #  (__) (_) (_)(____)   (__) (____)(___/ (__) (___/

  context "CreateSigningKeyProvider " do
    context "Signing key settings type is jwks-uri" do
      subject do
        ::Authentication::AuthnJwt::SigningKey::CreateSigningKeyProvider.new(
          fetch_signing_key_settings: mocked_fetch_signing_key_settings_type_jwks_uri,
          logger: logger
        ).call(
          authenticator_input: authenticator_input
        )
      end

      it "returns FetchJwksUriSigningKey instance and writes appropriate logs" do
        expect(subject).to be_a(Authentication::AuthnJwt::SigningKey::FetchJwksUriSigningKey)
        expect(log_output.string.split("\n")).to eq([
                                                      "DEBUG,CONJ00075D Selecting signing key interface...",
                                                      "INFO,CONJ00076I Selected signing key interface: 'jwks-uri'"
                                                    ])
      end
    end

    context "Signing key settings type is provider-uri" do
      subject do
        ::Authentication::AuthnJwt::SigningKey::CreateSigningKeyProvider.new(
          fetch_signing_key_settings: mocked_fetch_signing_key_settings_type_provider_uri,
          logger: logger
        ).call(
          authenticator_input: authenticator_input
        )
      end

      it "returns FetchProviderUriSigningKey instance and writes appropriate logs" do
        expect(subject).to be_a(Authentication::AuthnJwt::SigningKey::FetchProviderUriSigningKey)
        expect(log_output.string.split("\n")).to eq([
                                                      "DEBUG,CONJ00075D Selecting signing key interface...",
                                                      "INFO,CONJ00076I Selected signing key interface: 'provider-uri'"
                                                    ])
      end
    end

    context "Signing key settings type is wrong" do
      subject do
        ::Authentication::AuthnJwt::SigningKey::CreateSigningKeyProvider.new(
          fetch_signing_key_settings: mocked_fetch_signing_key_settings_type_is_wrong,
          logger: mocked_logger
        ).call(
          authenticator_input: authenticator_input
        )
      end

      it "returns FetchProviderUriSigningKey instance" do
        expect { subject }.to raise_error(
                                Errors::Authentication::AuthnJwt::InvalidSigningKeyType,
                                "CONJ00121E Signing key type 'type' is invalid"
                              )
      end
    end
  end
end
