require 'json'
require 'securerandom'
require_relative 'web_session'

module BancoDoBrasil
  class StatementsDashboard
    include WebSession

    CODE_FOR_STATEMENT = {
      'Conta-corrente' => {
        'Conta Corrente' => 3469,
      },
      'Investimentos' => {
        'Fundos de investimento' => 3910,
        'CDB/RDB e BB Reaplic' => 3911,
        'LCA' => 3912,
        'LCI' => 3913,
        'Compromissada BB Aplic' => 3914,
        'Ações na instituição depositária - Quantidade' => 3915,
        'Ações na instituição depositária - Dividendos' => 3916,
        'Tesouro Direto' => 3917,
        'Certificado de Operações Estruturadas' => 4197
      },
      'Poupança' => {
        'Extrato' => 3909
      },
      'Ourocap' => {
        'Extrato' => 3687
      }
    }.freeze

    def initialize(branch, account, password)
      @branch = branch
      @account = account
      @password = password
    end

    def fetch_all
      %i(lci ourocap savings).map do |investment|
        data = send(investment)
        [investment, { 'data' => data }]
      end
    end

    def lci
      authenticate
      click_for('Investimentos', 'LCI') and
        page.has_content?('LCI - Letra de Crédito Imobiliário')
      table_lines = all('.transacao-corpo tr')[1..-2]
      data = table_lines.map do |line|
        line.all('th, td').map(&:text)
      end
      attributes = data[0]
      data[1..-1].map { |values| Hash[attributes.zip(values)] }
    end

    def ourocap
      authenticate
      click_for('Ourocap', 'Extrato') and
        page.has_content?('Extrato de Capitalização Ourocap')

      investments = all('.listaOurocap tr')[2..-1]
      investments.each_with_index.map do |investment, index|
        click_for('Ourocap', 'Extrato') if index > 0

        investment.find('td:nth-child(1) [type="radio"]').click
        find('#botaoContinua').click and
          page.has_content?('Ultimos 12 (doze) meses')

        find('#botaoContinua2').click and
          page.has_content?('Dados do Título')

        attributes = all('.tabelaDescricao .campo span')
                     .map(&:text).each_slice(2).to_a
        table_lines = all('.tabelaExtrato tr')
        data = table_lines.map do |line|
          line.all('th, td').map(&:text)
        end
        statement = data[1..-1].map { |values| Hash[data[0].zip(values)] }
        {
          description: Hash[attributes],
          statement: statement
        }
      end
    end

    def savings
      authenticate
      click_for('Poupança', 'Extrato') and
        page.has_content?('Selecione a variação')

      accounts = all('.elemento-variacao a')

      accounts_data = accounts.each_with_index.map do |account, index|
        if index > 0
          account.click and
          within('.poupanca-lancamentos-corpo') { page.has_content?('Saldo') }
        end

        table_lines = all('.poupanca-lancamentos-cabecalho, .poupanca-lancamentos-corpo > *')[0..-5]
        data = table_lines.map do |line|
          line.all(:xpath, 'div')[1..-1].map(&:text)
        end
        attributes = data[0]
        [account.text, data[1..-1].map { |values| Hash[attributes.zip(values)] }]
      end
      Hash[accounts_data]
    end

    private

    def click_for(category, investment_type)
      find("[nome='#{category}']").click
      find("[codigo='#{code_for(category, investment_type)}']").click
    end

    def parse_savings_table
      table_lines = all('.poupanca-lancamentos-cabecalho, .poupanca-lancamentos-corpo > *')[0..-5]
      data = table_lines.map do |line|
        line.all(:xpath, 'div')[1..-1].map(&:text)
      end
      attributes = data[0]
      data[1..-1].map { |values| Hash[attributes.zip(values)] }
    end

    def code_for(category, type)
      CODE_FOR_STATEMENT[category][type]
    end
  end
end
