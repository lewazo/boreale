defmodule Boreale.Assets do
  alias Boreale.Storage

  @login_css_file "login.css"
  @login_js_file "login.js"

  @user_assets [@login_css_file]
  @immutable_assets [@login_js_file]

  def prepare_static_assets do
    Enum.each(@user_assets, &copy_user_asset_to_hosted_directory/1)
    Enum.each(@immutable_assets, &copy_immutable_asset_to_hosted_directory/1)
  end

  defp copy_user_asset_to_hosted_directory(filename) do
    source = get_source(filename)
    destination = get_destination(filename)

    File.cp!(source, destination)
  end

  defp copy_immutable_asset_to_hosted_directory(filename) do
    source = default_asset_filepath(filename)
    destination = get_destination(filename)

    File.cp!(source, destination)
  end

  defp get_source(filename) do
    source = user_asset_filepath(filename)

    if File.exists?(source) do
      source
    else
      default_asset_filepath(filename)
    end
  end

  defp get_destination(filename) do
    Path.join(Storage.hosted_directory_path(), filename)
  end

  defp default_asset_filepath(filename) do
    Path.join(Storage.priv_directory_path(), filename)
  end

  defp user_asset_filepath(filename) do
    Path.join(Storage.user_directory_path(), filename)
  end
end
