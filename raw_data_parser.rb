module BancoDoBrasil
  class RawDataParser
    def initialize(type, json)
      @type = type
      @json = json
    end

    def as_json
      if %w(lci).include?(@type)
        send(@type)
      else
        {}
      end
    end

    private

    def lci
      attributes = {
        source: :banco_do_brasil,
        type: :lci,
        # name: position['fund']['name'],
        # anbima_code: position['fund']['anbimaCode'],
        # is_thirdy_party: position['fund']['thirdyParty'],
        # is_withdrawal_only: position['fund']['withdrawalOnly'],
        scraped_at: @json['scraped_at'],
        scraping_id: @json['id']
      }

      @json['data'].map do |application|
        attributes.merge(
          source_internal_id: application['Número'],
          maturity: application['Data Vencimento'],
          application: parse_currency(application['Valor de Emissão']),
          gross_value: parse_currency(application['Saldo']),
          fee: parse_currency(application['Taxa']),
          applications: [{
            value: parse_currency(application['Valor de Emissão']),
            confirmed_at: Date.parse(application['Data Aplicação'])
          }]
        )
      end
    end

    def parse_currency(string)
      string.gsub(/[\.,]/, '').to_i
    end
  end
end
