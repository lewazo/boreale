defmodule Boreale.Tasks.Migrate do
  @moduledoc "Migrates data structure from Boreale beta to v1"

  @domains_dets_file "domains.dets"
  @users_dets_file "users.dets"
  @cert_file "cert.pem"
  @key_file "key.pem"
  @login_html_file "login.html"
  @login_css_file "login.css"

  @files [
    @domains_dets_file,
    @users_dets_file,
    @cert_file,
    @key_file,
    @login_html_file,
    @login_css_file
  ]

  def run([]) do
    Enum.each(@files, &copy_file_to_priv/1)
  end

  defp copy_file_to_priv(filename) do
    source = Path.join(File.cwd!(), "data/#{filename}")
    destination = Path.join(File.cwd!(), "priv/data/#{filename}")

    if File.exists?(source) do
      File.cp!(source, destination)
    end
  end
end
