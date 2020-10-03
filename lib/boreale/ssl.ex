defmodule Boreale.SSL do
  @moduledoc """
  The cert is only used for completing the SSL connection between traefik and the cowboy server
  It does not need to be signed by an authority since the auth server is not meant to be accessed
  directly by an hostname.
  """

  require Logger

  @spec generate_cert :: {:error, any()} | :ok
  def generate_cert do
    File.mkdir(data_folder())

    if cert_exists?() do
      :ok
    else
      case openssl_generate() do
        {_, 0} ->
          :ok

        {stdout, _} ->
          Logger.error(stdout)
          {:error, stdout}
      end
    end
  end

  defp openssl_generate do
    System.cmd("openssl", [
      "req",
      "-new",
      "-newkey",
      "rsa:4096",
      "-days",
      "365",
      "-nodes",
      "-x509",
      "-subj",
      "/C=US/ST=Denial/L=Springfield/O=Dis/CN=localhost",
      "-keyout",
      key_file(),
      "-out",
      cert_file()
    ])
  end

  defp cert_exists?, do: File.exists?(cert_file())

  @root_folder "data"
  defp data_folder, do: Path.join(File.cwd!(), @root_folder)

  defp data_file(file_name), do: Path.join(data_folder(), file_name)

  @cert_file_name "cert.pem"
  @spec cert_file :: String.t()
  def cert_file, do: data_file(@cert_file_name)

  @key_file_name "key.pem"
  @spec key_file :: String.t()
  def key_file, do: data_file(@key_file_name)
end
