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

		def sign_in
			fill_in 'un', :with => 'cpage'
			fill_in 'pw', :with => 'testtest'
			find('.button_box .btn.primary').click
		end

		def log_objects(app_name)

			visit('/design')

			sign_in
			page.has_css?("div.aui-DataGrid-Table table")
			click_link app_name

			CSV.open('./app-objects.csv', 'w+') do |csv|
				csv << ["Name","Type"]
				save_objects(csv)

			end

		end

		def save_objects(csv)
			puts page.has_css?("body div.aui-DataGrid-Table table tbody")
			page.has_css?("body div.aui-DataGrid-Table table tbody")
			all('body div.aui-DataGrid-Table table tbody tr').each_with_index do |tr, i|
				puts i+1
				puts first('body div.aui-DataGrid-Table table tbody tr:nth-child('+(i+1).to_s+') td:nth-child(3) a').text

				name = first('body div.aui-DataGrid-Table table tbody tr:nth-child('+(i+1).to_s+') td:nth-child(3) a').text
				type = first('body div.aui-DataGrid-Table table tbody tr:nth-child('+(i+1).to_s+') td:nth-child(2) img')['alt']

				object_data = [
					name,
					type
				]
				csv << object_data
			end

			next_page_button = first('body div.aui-DataGridPager-Container table > tbody > tr > td:nth-child(4) > img')
			if(next_page_button && next_page_button['aria-disabled'] == 'false')
				current_page_text = first('body div.aui-DataGridPager-Container table > tbody > tr > td:nth-child(3) > div').text

				next_page_button.click
				page.has_no_text?(current_page_text)
				save_objects(csv)
			end

		end

		def create_new_app(app_name)
			click_button "New Application"
			page.has_text?("Create New Application")

			fill_in 'gwt-uid-100', :with => app_name
			find_button('Create').click
			page.has_css?("body div.aui-DataGrid-Table table")

		end

		def create_copied_app(csv, old_prefix, new_prefix)
			visit('/design')

			sign_in
			page.has_css?("div.aui-DataGrid-Table table")

			create_new_app(new_prefix)

			inputs = CSV.read(csv)
			inputs.reverse.each_with_index do |data,i|

				copy_object(data)

			end

		end

		def copy_object(data)
			click_link 'New'

			if page.has_text? data[1]
				click_link data[1]
				page.has_no_text?("Create from Scratch")
				click_button 'Cancel'
				puts "Found: " + data[1]
			else
				puts "Not found: " + data[1]
			end


			# Data Type
			# Data Store
			# Record Type

			# Process Model
			# Process Report

			# Interface
			# Report
			# Site

			# Expression Rule
			# Constant
			# Query Rule
			# Web API

			# Document
			# Group
			# Group Type
			# Feed
			# Folder

		end

# inputs = inputs[1...-1]

# CSV.open('./input-sites.csv', 'w+') do |csv|
# 	csv << ["Id","Links","Center","City","State"]

		# end

		# def create_app(new_prefix)
		# 	find('body div.GKACFQNDFOB.GKACFQNDGOB div.content_toolbar button:nth-child(1)').click
		# 	# find('New Application').click
		# 	page.has_text?('Create New Application')

		# 	fill_in 'gwt-uid-100', :with => new_prefix

		# 	find('Create').click
		# 	page.has_text?('Create New Application')

		# 	return new_prefix
		# end

	end
end

t = MyCapybaraTest::Test.new
# t.log_objects('NAV_SA Starter Application')
# t.log_objects('NAV_TM Task Metric Utilities')
t.create_copied_app('app-objects.csv', 'NAV_TM', 'ZZ_TEST')






