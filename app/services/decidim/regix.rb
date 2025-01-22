module Decidim
  class Regix
    class << self
      def find_region(egn)
        request = call_regix(egn)

        extract_data(request.body) if request.code == '200'
      end

      def process(current_user)
        update_data = {
          regix_response: nil,
          regix_status: :error,
          regix_retry_date: 15.minutes.since,
          region: nil
        }

        return false unless Egn.validate(current_user.auth_uid.to_s)


        begin
          request = call_regix(current_user.auth_uid)
          update_data[:regix_response] = request.body

          if request.code == '200'
            regix_data = extract_data(request.body)

            update_data[:regix_status] = :error_region

            if regix_data[:region].to_i > 0 && regix_data[:municipality].to_i == 46
              update_data[:region] = regix_data[:region]

              update_data[:regix_status] = :success
            end
          end
        rescue Exception => e
          Sentry.capture_exception(e)
        end

        current_user.update!(update_data)
      end

      private

      def extract_data(xml)
        hash = Hash.from_xml(xml)

        {
          municipality: hash['Envelope']['Body']['ExecuteResponse']['ExecuteResult']['ServiceResultData']['Data']['Response']['TemporaryAddressResponse']['MunicipalityCode'],
          region: hash['Envelope']['Body']['ExecuteResponse']['ExecuteResult']['ServiceResultData']['Data']['Response']['TemporaryAddressResponse']['CityAreaCode']
        }

      rescue
        nil
      end

      def extract_municipality(xml)
        hash = Hash.from_xml(xml)

        hash['Envelope']['Body']['ExecuteResponse']['ExecuteResult']['ServiceResultData']['Data']['Response']['TemporaryAddressResponse']['MunicipalityCode']
      rescue
        nil
      end

      def extract_region(xml)
        hash = Hash.from_xml(xml)

        hash['Envelope']['Body']['ExecuteResponse']['ExecuteResult']['ServiceResultData']['Data']['Response']['TemporaryAddressResponse']['CityAreaCode']
      rescue
        nil
      end

      def call_regix(egn)
        request = Net::HTTP::Get.new("/RegiXEntryPointV2.svc/basic")
        request['SOAPAction'] = 'http://egov.bg/RegiX/IRegiXEntryPointV2/Execute'
        request['Content-Type'] = 'text/xml;charset=UTF-8'
        request.body = build_xml(egn)

        response = Net::HTTP.start("service-regix.egov.bg", 443, http_options) do |http|
          http.request(request)
        end

        response
      end

      def build_xml(egn)
        '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:reg="http://egov.bg/RegiX" xmlns:sig="http://egov.bg/RegiX/SignedData">
           <soapenv:Header/>
           <soapenv:Body>
              <reg:Execute>
                 <reg:request>
                    <sig:ServiceRequestData>
                       <sig:RequestProcessing></sig:RequestProcessing>
                       <sig:ResponseProcessing></sig:ResponseProcessing>
                       <sig:Operation>TechnoLogica.RegiX.GraoPNAAdapter.APIService.IPNAAPI.TemporaryAddressSearch</sig:Operation>
                       <sig:Argument>
                          <TemporaryAddressRequest xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://egov.bg/RegiX/GRAO/PNA/TemporaryAddressRequest">
          <EGN>' + egn + '</EGN>
          <SearchDate>' + Date.today.to_s(:db) +'</SearchDate>
        </TemporaryAddressRequest>
                       </sig:Argument>
                       <SignResult>false</SignResult>
                       <ReturnAccessMatrix>false</ReturnAccessMatrix>
                    </sig:ServiceRequestData>
                 </reg:request>
              </reg:Execute>
           </soapenv:Body>
        </soapenv:Envelope>'
      end
      def http_options
        {
          :use_ssl => true,
          :key => OpenSSL::PKey::RSA.new(File.read(Rails.root + "config/credentials/client.key")),
          :cert => OpenSSL::X509::Certificate.new(File.read(Rails.root + "config/credentials/client.cer")),
          :verify_mode => OpenSSL::SSL::VERIFY_PEER,
          :verify_depth => 5,
        }
      end
    end
  end
end