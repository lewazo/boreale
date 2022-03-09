defmodule Boreale.SSL do
  @moduledoc """
  The cert is only used for completing the SSL connection between traefik and the cowboy server
  It does not need to be signed by an authority since the auth server is not meant to be accessed
  directly by an hostname.
  """
  require Logger

  alias Boreale.Storage

  @cert_file_name "cert.pem"
  @key_file_name "key.pem"

  @spec maybe_generate_certificate :: {:error, any()} | :ok
  def maybe_generate_certificate do
    if certificate_exists?() do
      :ok
    else
      generate_certificate()
    end
  end

  defp generate_certificate do
    case run_openssl_command() do
      {_, 0} ->
        :ok

      {stdout, _} ->
        Logger.error(stdout)
        {:error, stdout}
    end
  end

  defp run_openssl_command do
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
      get_key_path(),
      "-out",
      get_certificate_path()
    ])
  end

  defp certificate_exists?, do: File.exists?(get_certificate_path())

  @spec get_certificate_path :: String.t()
  def get_certificate_path do
    Path.join(Storage.user_directory_path(), @cert_file_name)
  end

  @spec get_key_path :: String.t()
  def get_key_path do
    Path.join(Storage.user_directory_path(), @key_file_name)
  end
end
