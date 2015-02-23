class BillableList
  attr_reader :clients

  def initialize(entries)
    @entries = entries
    @clients = Client.eager_load(projects: [hours: [:user, :category]]).where(
      "hours.id in (?)", entries.map(&:id)
    ).by_last_updated
  end
end
