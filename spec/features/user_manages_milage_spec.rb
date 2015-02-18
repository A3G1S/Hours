require "spec_helper"

feature "User manages milage" do
	let(:subdomain) { generate(:subdomain) }
  	let(:user) { build(:user) }

  	before(:each) do
    	create(:account_with_schema, subdomain: subdomain, owner: user)
    	sign_in_user(user, subdomain: subdomain)
    end

	scenario "enters milage with valid data" do

		create(:project, name: "Driving")
		
		
        click_link "register milage"
        
		select "Driving", from: "Project"
		fill_in "Kilometers", with: 20
		fill_in "datepicker", with: "17/02/2015"	

		click_button "create entry"

		expect(page).to have_content("milage added")
	end
	
	scenario "checks his milage" do

	end

	scenario "enters milage with invalid data" do

	end

	scenario "edits milage" do
	end

end