require 'capybara'
require 'selenium/webdriver'

module BancoDoBrasil
  module WebSession
    include Capybara::DSL

    def setup
      Capybara.register_driver :java_applet_compatible do |app|
        profile = Selenium::WebDriver::Firefox::Profile.new
        profile['extensions.blocklist.enabled'] = false
        profile['plugin.state.java'] = 2
        profile['browser.download.folderList'] = 
        profile['plugin.state.java'] = 2
        Capybara::Selenium::Driver.new(app, browser: :firefox, profile: profile)
      end

      Capybara.current_driver = :java_applet_compatible
      Capybara.default_max_wait_time = 30
    end

    def authenticate
      @authenticate ||= begin
        setup

        visit 'https://www2.bancobrasil.com.br/aapf/login.jsp' and
        page.has_content?('Autoatendimento')
        fill_in 'dependenciaOrigem', with: @branch
        fill_in 'numeroContratoOrigem', with: @account
        fill_in 'senhaConta', with: @password
        click_on 'botaoEntrar'
      end
    end
  end
end
