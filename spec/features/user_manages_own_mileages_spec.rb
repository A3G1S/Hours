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
		fill_in (I18n.t("entries.index.mileages")), with: 20
		fill_in "datepicker", with: "17/02/2015"	

		click_button (I18n.t("helpers.submit.mileage.create"))

		expect(page).to have_content(I18n.t("entry_created.mileages"))
	end
	
	scenario "checks his mileage" do

	end

	scenario "enters mileage with invalid data" do

		create(:project, name: "Driving")
		
		
    click_link (I18n.t("entries.index.new_mileage"))
        
		select "Driving", from: "Project"
		fill_in (I18n.t("entries.index.mileages")), with: ""
		fill_in "datepicker", with: "17/02/2015"	

		click_button (I18n.t("helpers.submit.mileage.create"))

		expect(page).to have_content("Value can't be blank. Value is not a number")
	end

  scenario "views their mileages overview" do
    2.times { create_mileages_entry }
    click_link "My Hours"

    expect(page).to have_content(user.mileages.last.project.name)
  end

  scenario "deletes an entry" do
    create_mileages_entry
    click_link "My Hours"

    click_link "delete"
    expect(page).to have_content(I18n.t("entry_deleted"))
  end

  scenario "edits an entry" do
    new_project = create(:project)
    new_value = rand(1..100)
    new_date = Date.current.strftime("%d/%m/%Y")

    edit_entry(new_project, new_value, new_date)

    click_link "edit"

    expect(page).to have_select("mileage_project_id", selected: new_project.name)
    expect(find_field("mileage_value").value).to eq(new_value.to_s)
    expect(find_field("datepicker").value).to eq(new_date.to_s)
  end

  scenario "can not edit someone elses entries" do
    other_user = create(:user)
    project = create(:project)
    date = Date.current.strftime("%d/%m/%Y")
    value = rand(1..100)
    create(:mileage, user: other_user, project: project, date: date, value: value)

    visit user_entries_url(other_user, subdomain: subdomain)
    expect(page).to_not have_content("edit")
  end

  scenario "can not delete someone elses entries" do
    other_user = create(:user)
    project = create(:project)
    date = Date.current.strftime("%d/%m/%Y")
    value = rand(1..100)
    create(:mileage, user: other_user, project: project, date: date, value: value)

    visit user_entries_url(other_user, subdomain: subdomain)
    expect(page).to_not have_content("delete")
  end

  #  doesnt work yet
  # let(:new_mileages) { "Not a number" }

  # scenario "edits entry with wrong data" do
  #   new_project = create(:project)
  #   new_mileages = "these are not valid kilometers"
  #   new_date = Date.current.strftime("%d/%m/%Y")

  #   edit_entry(new_project, new_mileages, new_date)

  #   expect(page).to have_content("Something went wrong saving your entry")
  # end

  private

  def edit_entry(new_project, new_mileages, new_date)
    create_mileages_entry
    click_link "My Hours"
    click_link "edit"

    select(new_project.name, from: "mileage_project_id")
    fill_in "mileage_value", with: new_mileages
    fill_in "datepicker", with: new_date

    click_button (I18n.t("helpers.submit.mileage.update"))
  end

  def create_mileages_entry()
    project = create(:project)
    date = Date.current.strftime("%d/%m/%Y")
    value = rand(1..100)
    return create(:mileage, user: user, project: project, date: date, value: value)
  end
end
