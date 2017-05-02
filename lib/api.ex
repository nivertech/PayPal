defmodule PayPal.API do
  @moduledoc """
  Documentation for PayPal.API. This module is about the base HTTP functionality
  """
  @base_url_sandbox "https://api.sandbox.paypal.com/v1/"
  @base_url_live "https://api.paypal.com/v1/"

  @doc """
  Requests an OAuth token from PayPal, returns a tuple containing the token and seconds till expiry.

  Possible returns:

  - {:ok, {"XXXXXXXXXXXXXX", 32000}}
  - {:error, :unauthorised}
  - {:error, :bad_network}

  ## Examples

    iex> PayPal.API.get_oauth_token
    {:ok, {"XXXXXXXXXXXXXX", 32000}}

  """
  @spec get_oauth_token :: {atom, {String.t, integer}}
  def get_oauth_token do
    headers = %{"Content-Type" => "application/x-www-form-urlencoded"}
    options = [hackney: [basic_auth: {PayPal.Config.get.client_id, PayPal.Config.get.client_secret}]]
    form = {:form, [grant_type: "client_credentials"]}

    case HTTPoison.post(base_url() <> "oauth2/token", form, headers, options) do
      {:ok, %{status_code: 401}} ->
        {:error, :unauthorised}
      {:ok, %{body: body, status_code: 200}} ->
        %{access_token: access_token, expires_in: expires_in} = Poison.decode!(body, keys: :atoms)
        {:ok, {access_token, expires_in}}
      _->
        {:error, :bad_network}
    end
  end

  @spec base_url :: String.t
  defp base_url do
    case Mix.env do
      :prod ->
        @base_url_live
      _ ->
        @base_url_sandbox
    end
  end
end