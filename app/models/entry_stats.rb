class EntryStats
  def initialize(hour_entries, subject = nil)
    @hour_entries = hour_entries
    @subject = subject
  end

  def percentage_for_subject
    (hours_for_subject.to_f / total_hours.to_f * 100).round
  end

  def hours_for_subject
    hour_entries_for_subject.sum(:value)
  end

  def total_hours
    @hour_entries.sum(:value)
  end

  def hours_for_subject_collection(collection)
    collection.map do |subject|
      @subject = subject
      {
        value: hours_for_subject,
        color: subject.label.pastel_color,
        label: subject.label,
        highlight: "gray"
      }
    end
  end

  private

  def hour_entries_for_subject
    if @subject.instance_of?(RemainingCategory)
      @hour_entries.where("category_id in (?)", @subject.ids)
    else
      @hour_entries.where("#{@subject.class.name.downcase}_id = (?)", @subject.id)
    end
  end
end
