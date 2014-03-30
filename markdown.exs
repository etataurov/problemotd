defmodule Markdown do
  def parse(filename) do
    {:ok, file} = File.open(filename, [:read, :utf8])
    IO.puts parse_line(IO.read(file, :line), file, [])
  end

  defp parse_line(line, file, list) do
    case line do
      << "## ", rest :: binary >> ->
        parse_line(readline(file), file, ["<h2>"<>String.strip(rest)<>"</h2>" | list])
      << "* ", _ :: binary >> ->
        {new_line, li_list} = parse_list(line, file, [])
        parse_line(new_line, file, ["</ul>"] ++ li_list ++ ["<ul>"] ++ list)
      "\n" ->
        parse_line(readline(file), file, list)
      :eof ->
        Enum.join(Enum.reverse(list), "\n")
      other -> parse_line(readline(file), file, ["<p>"<>String.strip(other)<>"</p>" | list])
    end
  end

  defp parse_list(line, file, list) do
    case line do
      << "* ", rest :: binary >> ->
        parse_list(readline(file), file, ["\t<li>"<>String.strip(rest)<>"</li>" | list])
      _ -> {line, list}
    end
  end

  def readline(file) do
    IO.read(file, :line)
  end
end

Markdown.parse(hd System.argv)
