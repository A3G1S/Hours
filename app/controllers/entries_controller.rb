class EntriesController < ApplicationController
  include CSVDownload

  DATE_FORMAT = "%d/%m/%Y".freeze

  def create
    @hours_entry = Hour.new(entry_params)
    @hours_entry.user = current_user
    if @hours_entry.save
      redirect_to root_path, notice: t("entry_created.hours")
    else
      redirect_to root_path, notice: @hours_entry.errors.full_messages.join(" ")
    end
  end

  def index
    @user = User.find_by_slug(params[:user_id])
    @hours_entries = @user.hours.by_date.page(params[:page]).per(20)

    respond_to do |format|
      format.html { @hours_entries }
      format.csv { send_csv(name: @user.name, entries: @hours_entries) }
    end
  end

  def update
    if resource.update_attributes(entry_params)
      redirect_to user_entries_path(current_user), notice: t("entry_saved")
    else
      render "edit", notice: t("entry_failed")
    end
  end

  def edit
    resource
  end


  def destroy
    resource.destroy
    redirect_to user_entries_path(current_user), notice: t('entry_deleted')
  end

  private

  def resource
    @hours_entry ||= current_user.hours.find(params[:id])
  end

  def entry_params
    params.require(:hour)
      .permit(:project_id, :category_id, :value, :description, :date)
      .merge(date: parsed_date)
  end

  def parsed_date
    Date.strptime(params[:hour][:date], DATE_FORMAT)
  end
end
