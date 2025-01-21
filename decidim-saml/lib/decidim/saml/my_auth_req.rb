module Decidim
  module Saml
    class MyAuthReq < OneLogin::RubySaml::Authrequest
      def add_extras(root, _settings)
        org = root.add_element("saml2p:Extensions")
        req_service = org.add_element("egovbga:RequestedService", 'xmlns:egovbga' => "urn:bg:egov:eauth:2.0:saml:ext")
        # req_service.add_element('egovbga:Service').text = '2.16.100.1.1.106.1.9.1.1'
        req_service.add_element('egovbga:Service').text = '2.16.100.1.1.106.1.9.1.2'
        req_service.add_element('egovbga:Provider').text = '2.16.100.1.1.106.1.9'
        req_service.add_element('egovbga:LevelOfAssurance').text = 'LOW'
      end
    end
  end
end