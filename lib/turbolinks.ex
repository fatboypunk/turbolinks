defmodule Turbolinks do
  @moduledoc """
  This plug is built on top of works done by @kagux at https://github.com/kagux/turbolinks_plug

  in `web.ex`
  add `use Turbolinks`

  in `router.ex` add a the plug
  plug Turbolinks
  """

  use Plug.Builder
  import Turbolinks.Helpers

  @session_key "_turbolinks_location"
  @location_header "turbolinks-location"
  @referrer_header "turbolinks-referrer"

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      import Phoenix.Controller, except: [redirect: 2]
      import Turbolinks.Helpers
    end
  end

  @doc false
  def init(opts \\ []), do: super(opts)

  @doc false
  def call(conn, opts) do
    conn
    |> super(opts)
    |> register_before_send(&handle_redirect/1)
    |> put_phoenix_format()
  end

  @doc false
  def handle_redirect(%Plug.Conn{status: status} = conn) when status in 301..302 do
    location = get_location_header(conn)
    referrer = get_referrer_header(conn)
    store_location_in_session(conn, location, referrer)
  end
  def handle_redirect(%Plug.Conn{status: status} = conn) when status in 200..299 do
    conn
    |> get_session(@session_key)
    |> set_location_header(conn)
  end
  def handle_redirect(conn), do: conn

  defp store_location_in_session(conn, _location, []), do: conn
  defp store_location_in_session(conn, location, _referrer) do
    put_session(conn, @session_key, location)
  end

  defp set_location_header(nil, conn), do: conn
  defp set_location_header(location, conn) do
    conn
    |> put_resp_header(@location_header, location)
    |> delete_session(@session_key)
  end

  defp get_location_header(conn) do
    conn
    |> get_resp_header("location")
    |> List.first
  end

  defp get_referrer_header(conn) do
    get_req_header(conn, @referrer_header)
  end

  defp put_phoenix_format(conn) do
    if xhr?(conn) do
      Phoenix.Controller.put_format(conn, "js")
    else
      conn
    end
  end
end
