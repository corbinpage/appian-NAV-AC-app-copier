require 'json'
require 'csv'
require 'capybara'
require 'capybara/dsl'

Capybara.run_server = false
Capybara.current_driver = :selenium
# Capybara.app_host = 'https://www.google.com'
Capybara.app_host = 'https://navlabsdev.appiancloud.com/suite'

module MyCapybaraTest
	class Test
		include Capybara::DSL

		def log_objects(app_name)
			visit('/design')

			sign_in
			page.has_css?("table.GN55TI2M1")
			click_link app_name
			page.has_css?("body div.aui-DataGrid-Table.GN55TI2LUC")

			CSV.open('./app-objects.csv', 'w+') do |csv|
				csv << ["Name","Type"]
				save_objects(csv)

			end

		end

		def sign_in
			fill_in 'un', :with => 'cpage'
			fill_in 'pw', :with => ''
			find('.button_box .btn.primary').click
		end

		def save_objects(csv)
			all('body div.aui-DataGrid-Table.GN55TI2LUC tbody tr').each_with_index do |tr, i|
				puts i+1
				puts first('body div.aui-DataGrid-Table.GN55TI2LUC tr:nth-child('+(i+1).to_s+') td:nth-child(3) a').text

				name = first('body div.aui-DataGrid-Table.GN55TI2LUC tr:nth-child('+(i+1).to_s+') td:nth-child(3) a').text
				type = first('body div.aui-DataGrid-Table.GN55TI2LUC tr:nth-child('+(i+1).to_s+') td:nth-child(2) img')['alt']

				object_data = [
					name,
					type
				]
				csv << object_data
			end

			next_page_button = first('body div.GN55TI2KX.GN55TI2MX div.aui-DataGridPager-Container > table > tbody > tr > td:nth-child(4) > img')
			if(next_page_button && next_page_button['aria-disabled'] == 'false')
				current_page_text = first('body div.GN55TI2KX.GN55TI2MX div.aui-DataGridPager-Container > table > tbody > tr > td.GN55TI2H2B > div').text

				next_page_button.click
				page.has_no_text?(current_page_text)
				save_objects(csv)
			end

		end
	end
end

t = MyCapybaraTest::Test.new
# t.log_objects('NAV_SA Starter Application')
t.log_objects('NAV_TM Task Metric Utilities')





