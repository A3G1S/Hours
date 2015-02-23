require "spec_helper"

feature "User manages mileage" do
	let(:subdomain) { generate(:subdomain) }
  	let(:user) { build(:user) }

  	before(:each) do
    	create(:account_with_schema, subdomain: subdomain, owner: user)
    	sign_in_user(user, subdomain: subdomain)
    end

	scenario "enters mileage with valid data" do

		create(:project, name: "Driving")
		
		
        click_link (I18n.t("entries.index.new_mileage"))
        
		select "Driving", from: "Project"
		fill_in (I18n.t("entries.index.mileage")), with: 20
		fill_in "datepicker", with: "17/02/2015"	

		click_button "Create Entry"

		expect(page).to have_content(I18n.t("entries_created.mileage"))
	end
	
	scenario "checks his mileage" do

	end

	scenario "enters mileage with invalid data" do

	end

	scenario "edits mileage" do
	end

end