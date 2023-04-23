class CategoriesController < ApplicationController
  before_action :authenticate_user!
  def index
    ActiveStorage::Current.url_options = { host: request.base_url }

    @msg_bool = true
    @user = current_user
    @categories = @user.groups.order('created_at DESC')
    @total = []
    @categories.includes(:group_dealings).each do |item|
      arr = []
      next unless item.group_dealings.includes(:dealing)

      item.group_dealings.includes(:dealing).each do |el|
        arr << el.dealing[:amount]
      end
      item.total = arr.reduce(:+)
      item.save
      @total << if arr.empty?
                  0
                else
                  arr.reduce(:+)
                end
      @msg_bool = false
    end
  end

  def show
    @user = current_user
    @category_dealings = []
    @user.groups.includes(:group_dealings).each do |group|
      group.group_dealings.includes(:dealing).each do |el|
        @category_dealings << el.dealing
      end
    end
  end

  def new
    @category = Group.new
  end

  # def create
  #   new_category = Group.new(name: category_params[:name], icon: category_params[:icon], author_id: current_user.id)

  #   if category_params[:icon].present?
  #     icon_filename = SecureRandom.hex + File.extname(category_params[:icon].original_filename)
  #     icon_path = Rails.root.join('public', 'uploads', 'icons', icon_filename)

  #     File.binwrite(icon_path, category_params[:icon].read)

  #     new_category.icon = "/uploads/icons/#{icon_filename}"
  #   end

  #   if new_category.save
  #     flash[:success] = 'Category has been created'
  #     redirect_to categories_path
  #   else
  #     flash.now[:error] = 'Category could not be savedd'
  #     render new
  #   end
  # end
  def create
    new_category = Group.new(name: category_params[:name], author_id: current_user.id)

    new_category.icon.attach(category_params[:icon]) if category_params[:icon].present?

    if new_category.save
      flash[:success] = 'Category has been created'
      redirect_to categories_path
    else
      flash.now[:error] = 'Category could not be savedd'
      render new
    end
  end

  private

  def category_params
    params.require(:group).permit(:name, :icon)
  end
end
