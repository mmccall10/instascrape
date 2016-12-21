defmodule Instascrape do
    use Hound.Helpers
    @host "https://www.instagram.com"

    def start user do
        IO.puts "scraping #{user}"
        Hound.start_session
        Enum.join([@host, "/", user]) |> navigate_to()
        current_window_handle |> maximize_window
        take_screenshot("media/#{user}.png")
        make_user_dir(user)
        page_source()
        |> Instascrape.get_posts
        |> Instascrape.save_post_data(user)

    end

    def make_user_dir user do
      File.mkdir("media/images/#{user}")
      File.mkdir("media/snapshots/#{user}")
      File.mkdir("media/videos/#{user}")
    end

    def get_posts page do
        page
        |> Floki.find("a[href^='/p/']")
        |> Floki.attribute("href")
    end

    def download %{src: src, image_path: path} do
        body = HTTPoison.get!(src).body
        File.write!(path, body)
        IO.puts "Downloaded #{src} => #{path}"
        :ok
    end

    def download %{src: src, video_path: path} do
        body = HTTPoison.get!(src).body
        File.write!(path, body)
        IO.puts "Downloaded #{src} => #{path}"
        :ok
    end

    def download , do: :ok

    def save_post_data list, user do

        Enum.all? list, fn post ->
            post_id = URI.path_to_segments(post) |> Enum.at(1)
            in_browser_session post_id, fn ->
                navigate_to(@host<>post)
                page_source()
                |> Instascrape.save_post_media(post_id, user)
                |> Instascrape.save_post_video(post_id, user)
                current_window_handle |> maximize_window
                take_screenshot("media/snapshots/#{user}/#{post_id}.png")
            end
         end

    end

    def save_post_video page, post_id, user do
        video =
            page
            |> Floki.find("video")
            |> Floki.attribute("src")
            |> Enum.at(0)

        if  !is_nil(video) do
            IO.inspect(video)
            Instascrape.download(%{src: video, video_path: "media/videos/#{user}/#{post_id}.mp4"})
        end
        page
    end

    def save_post_media page, post_id, user do
        image =
            page
            |> Floki.find("img")
            |> Floki.attribute("src")
            |> Enum.at(1)
            Instascrape.download(%{src: image, image_path: "media/images/#{user}/#{post_id}.png"})
        page
    end

end
