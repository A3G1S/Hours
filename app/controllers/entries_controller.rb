class EntriesController < ApplicationController
  include CSVDownload

  DATE_FORMAT = "%d/%m/%Y".freeze

  def create
    entrytype = entrytype?
    
    if entrytype == "mileages"
      @entry = Mileage.new(entry_params(entrytype))
      return_route = mileage_entry_path
    elsif entrytype == "hours"
      @entry = Hour.new(entry_params(entrytype))
      return_route = root_path
    end
    
    @entry.user = current_user
    
    if @entry.save 
      redirect_to return_route, notice: t("entry_created.#{entrytype}")
    else
      redirect_to return_route, notice: @entry.errors.full_messages.join(" ")
    end
  end

  def index
    @user = User.find_by_slug(params[:user_id])
    @hours_entries = @user.hours.by_date.page(params[:page]).per(20)
    @mileages_entries = @user.mileages.by_date.page(params[:page]).per(20)
    
    respond_to do |format|
      format.html { @hours_entries }
      format.csv { send_csv(name: @user.name, entries: @hours_entries) }
    end
  end

  def update
    entrytype = entrytype?

    if resource(entrytype).update_attributes(entry_params(entrytype))
      redirect_to user_entries_path(current_user), notice: t("entry_saved")
    else
      render "edit", notice: t("entry_failed")
    end
  end

  def edit
    @entry_path = entry_path
    @entrytype = params[:entrytype]
    resource(@entrytype)
  end


  def destroy
    resource(params[:entrytype]).destroy
    redirect_to user_entries_path(current_user), notice: t('entry_deleted')
  end

  private

  def resource(entrytype)
    if entrytype == "hours"
      @hours_entry ||= current_user.hours.find(params[:id])
    elsif entrytype == "mileages"
      @mileages_entry ||= current_user.mileages.find(params[:id])
    end
  end

  def entry_params(entrytype)
    if entrytype == "mileages"
      params.require(:mileage)
        .permit(:project_id, :value, :date)
        .merge(date: parsed_date(:mileage))
    elsif entrytype == "hours"
      params.require(:hour)
        .permit(:project_id, :category_id, :value, :description, :date)
        .merge(date: parsed_date(:hour))
    end
  end

  def parsed_date (entrytype)
    Date.strptime(params[entrytype][:date], DATE_FORMAT)
  end

  def entrytype?
    if params.has_key?(:hour)
      return "hours"
    elsif params.has_key?(:mileage)
      return "mileages"
    end
  end
end
