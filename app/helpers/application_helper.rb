module ApplicationHelper
  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  #add active class if the path is active, otherwise it's ""
  def is_active?(link_path)
    current_page?(link_path) ? "active" : ""
  end
end
