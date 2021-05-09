defmodule Identixir do
  def generate(username) do
    username
    |> hash_username
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(username)
  end

  def hash_username(username) do
    hex =
      :crypto.hash(:md5, username)
      |> :binary.bin_to_list

    %Identixir.Image{hex: hex}
  end

  def pick_color(%Identixir.Image{hex: [r, g, b | _]} = image) do
    %Identixir.Image{image | color: {r, g, b}}
  end

  def build_grid(%Identixir.Image{hex: hex} = image) do
    grid =
      hex
      |> Enum.chunk_every(3, 3, :discard)
      |> Enum.map(&mirror_row/1)
      |> List.flatten
      |> Enum.with_index

    %Identixir.Image{image | grid: grid}
  end

  def mirror_row([first, second | _] = row) do
    row ++ [second, first]
  end

  def filter_odd_squares(%Identixir.Image{grid: grid} = image) do
    grid =
      Enum.filter grid, fn {code, _} ->
        rem(code, 2) == 0
      end

    %Identixir.Image{image | grid: grid}
  end

  def build_pixel_map(%Identixir.Image{grid: grid} = image) do
    pixel_map =
      Enum.map grid, fn {_, index} ->
        horizontal = rem(index, 5) * 50
        vertical = div(index, 5) * 50

        top_left = {horizontal, vertical}
        bottom_right = {horizontal + 50, vertical + 50}

        {top_left, bottom_right}
      end

    %Identixir.Image{image | pixel_map: pixel_map}
  end

  def draw_image(%Identixir.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each pixel_map, fn {start, stop} ->
      :egd.filledRectangle(image, start, stop, fill)
    end

    :egd.render(image)
  end

  def save_image(image, username) do
    File.mkdir_p!("image")
    File.write("image/#{username}.png", image)
  end
end
