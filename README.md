# Turbolinks

[![Hex Version](https://img.shields.io/hexpm/v/turbolinks.svg)](https://hex.pm/packages/turbolinks)

[Docs](https://hexdocs.pm/turbolinks)

## Motive
> When you visit location /one and the server redirects you to location /two, you expect the browser’s address bar to display the redirected URL.

> However, Turbolinks makes requests using XMLHttpRequest, which transparently follows redirects. There’s no way for Turbolinks to tell whether a request resulted in a redirect without additional cooperation from the server.

> To work around this problem, send the Turbolinks-Location header in response to a visit that was redirected, and Turbolinks will replace the browser’s topmost history entry with the value you provide.

[source](https://github.com/turbolinks/turbolinks#following-redirects)

## Installation
Add Turbolinks to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:turbolinks, "~> 0.1.0"}]
end
```

## Usage with Phoenix

in `package.json`
```diff
{
  ...
  "dependencies": {
    "phoenix": "file:deps/phoenix",
    "phoenix_html": "file:deps/phoenix_html",
++  "turbolinks": "^5.0.0"
  }
  ...
}
```

Run `npm install` and update `/web/static/app.js`
```diff
import "phoenix_html"
++ import Turbolinks from 'turbolinks'
++ Turbolinks.start()
```

in `/web/web.ex`
```diff
defmodule MyApp.Web do
  def controller do
    quote do
      use Phoenix.Controller
++    use Turbolinks
      import MyApp.Router.Helpers
      import MyApp.Gettext
    end
  end
end
```

in `/web/router.ex`
```diff
defmodule MyApp.Router
  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
++  plug Turbolinks
  end
end
```

## Redirecting After a Form Submission

Turbolinks module imports a `redirect/2` function with API parity with phoenix's `redirect/2` function. This provides progressive enhancement when we submit a form with XHR.

More details can be found [here](https://github.com/turbolinks/turbolinks#redirecting-after-a-form-submission)

## Unobtrusive JavaScript

in `package.json`
```diff
{
  ...
  "dependencies": {
    "phoenix": "file:deps/phoenix",
    "phoenix_html": "file:deps/phoenix_html",
    "turbolinks": "^5.0.0",
++  "jquery": "^3.1.0",
++  "jquery-ujs": "^1.2.2"
  },
  ...
}
```

in `brunch-config.js`

```diff
{
  ...
  npm: {
    enabled: true,
++  globals: {
++    jQuery: 'jquery',
++    $: 'jquery'
++  }
  },
  ...
}
```

Run `npm install` and update `/web/static/app.js`

```diff
-- import "phoenix_html"
++ import 'jquery-ujs'
import Turbolinks from 'turbolinks'

Turbolinks.start()
```

in `web/templates/layout/app.html.slim`, add these two meta tags

```diff
++ meta name="csrf-token" content="#{get_csrf_token()}"
++ meta name="csrf-param" content="_csrf_token"
```

To submit form remotely set the data-remote html attribute on the form to true, this is an example for phoenix_slim

```slim
= form_for @changeset, @action, [data: [remote: true]], fn f ->
  = text_input f, :title, placeholder: "Post title"
  = text_input f, :body, placeholder: "Post body"
  = submit "Submit", class: "button is-primary"
```
