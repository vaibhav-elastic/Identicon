defmodule Identicon do
  def main(input) do
    input
    |>hash()
    |>pickcolour()
    |>buildGrid()
    |>filter_odd_squares()
    |>build_pixel_map()
    |>draw_image()
    |>save(input)
  end
  def hash(input) do
    hash= :crypto.hash(:md5 , input)
    |>:binary.bin_to_list()
    %Identicon.Image{hex: hash}
  end
  def pickcolour(image) do
    %Identicon.Image{hex: [r, g, b | _tail]}=image
    %Identicon.Image{image | colour: {r,g,b}}
  end
  def buildGrid(image) do
    %Identicon.Image{hex: hexl}=image
    grid=Enum.chunk_every(hexl,3,3,:discard)
    |>Enum.map(&mirror/1)
    |>List.flatten()
    |>Enum.with_index()
    %Identicon.Image{image | grid: grid}
  end
  def mirror(list) do
    [first,second| _tail]=list
    list ++ [second,first]
  end

  def filter_odd_squares(image) do
    %Identicon.Image{grid: grid }=image
    grid=Enum.filter(grid,fn({square, _index})->rem(square,2)==0 end)
    %Identicon.Image{image | grid: grid}
  end

  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map=Enum.map(grid,fn({_code,index})->
      horizontal=rem(index,5)*50
      vertical=div(index,5)*50

      tl={horizontal,vertical}
      br={horizontal+50,vertical+50}

      {tl,br}
    end)
    # IO.puts(pixel_map)
    %Identicon.Image{image | pixel_map: pixel_map}
  end

  def draw_image(%Identicon.Image{pixel_map: pix, colour: colour}) do
    imageCanavas=:egd.create(250,250)
    fill=:egd.color(colour)

    Enum.each(pix,fn({tl,br})->
        :egd.filledRectangle(imageCanavas,tl,br,fill)
    end)
    :egd.render(imageCanavas)
  end

  def save(image,input) do
    File.write("#{input}.png",image)
  end
end
