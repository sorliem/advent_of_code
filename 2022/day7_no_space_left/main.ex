defmodule Day7NoSpaceLeft do
  @moduledoc """
  """

  def run(file) do
    pid = self()

    {dir_tree, _pwd} =
      file
      |> File.read!()
      |> String.split("\n", trim: true)
      |> Enum.reduce({%{}, []}, &build_tree/2)
      |> IO.inspect(label: "built tree")

    # Enum.reduce(dir_tree, {%{}, []}, &calculate_dir_size/2)

    paths = Enum.reduce(dir_tree, {["/"], []}, &collect_dir_paths/2)
    |> IO.inspect(label: "paths to calculate")
  end

  defp collect_dir_paths({dirname, tree}, {pwd, paths} = acc) do
    dirs =
      Enum.flat_map(tree, fn
        {{:filename, _}, _} -> []
        {dir, _dir_contents} -> [pwd ++ [dir]]
      end)

    sub_paths =
      Enum.flat_map(dirs, fn dir ->
        sub_tree = get_in(tree, dir)
        {_pwd, sub_paths} = Enum.reduce(tree, {dir, paths}, &collect_dir_paths/2)

        [sub_paths]
      end)

    {pwd ++ [dirname], paths ++ sub_paths}
  end

  defp calculate_dir_size({{:filename, _filename}, filesize}, {dir_size_map, current_dir}) do
    new_dir_size_map =
      Map.update(dir_size_map, current_dir, 0, fn existing_size ->
        existing_size + filesize
      end)

    {new_dir_size_map, current_dir}
  end

  defp calculate_dir_size({dirname, sub_dir_tree}, {dir_size_map, current_dir}) do
    foo = Enum.reduce(sub_dir_tree, {dir_size_map, current_dir ++ [dirname]}, &calculate_dir_size/2)
  end

  defp build_tree("$ cd ..", {tree, pwd}) do
    new_pwd = pwd |> Enum.reverse() |> tl() |> Enum.reverse()

    {tree, new_pwd}
  end

  defp build_tree("$ cd " <> dir, {tree, pwd}) do
    {tree, pwd ++ [dir]}
  end

  defp build_tree("$ ls", {tree, pwd}) do
    {tree, pwd}
  end

  defp build_tree(ls_item, {tree, pwd}) do
    case String.split(ls_item, " ", parts: 2) do
      ["dir", dirname] ->
        dir_items = get_in(tree, pwd) || %{}
        dir_items = Map.put(dir_items, dirname, %{})
        tree = put_in(tree, pwd, dir_items)

        {tree, pwd}

      [filesize, filename] ->
        dir_items = get_in(tree, pwd) || %{}
        filesize = String.to_integer(filesize)
        dir_items = Map.put(dir_items, {:filename, filename}, filesize)
        tree = put_in(tree, pwd, dir_items)

        {tree, pwd}
    end
  end
end

Day7NoSpaceLeft.run("input.test")
