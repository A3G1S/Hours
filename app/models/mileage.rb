# == Schema Information
#
# Table name: 
#
#  id          :integer          not null, primary key
#  project_id  :integer          not null
#  user_id     :integer          not null
#  hours       :integer          not null
#  date        :date             not null
#  created_at  :datetime
#  updated_at  :datetime
#  description :string(255)
#  billed      :boolean




class Mileage < Entry
	include Twitter::Extractor
	
	audited allow_mass_assignment: true
	has_one :client, through: :project
	belongs_to :user, touch: true
	belongs_to :project, touch: true

	validates :user, :project, :date, presence: true
	validates :value, presence: true,
	                numericality: { greater_than: 0, only_integer: true }

	scope :by_last_created_at, -> { order("created_at DESC") }
	scope :by_date, -> { order("date DESC") }
	scope :billable, -> { where("billable").joins(:project) }
	scope :with_clients, -> { where.not("projects.client_id" => nil).joins(:project) }
end
