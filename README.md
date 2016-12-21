# Instascrape

Scrape a users instagram page.

Basic usage:

`Instascrape.start "snoopdogg"`

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `instascrape` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:instascrape, "~> 0.1.0"}]
    end
    ```

  2. Ensure `instascrape` is started before your application:

    ```elixir
    def application do
      [applications: [:instascrape]]
    end
    ```
