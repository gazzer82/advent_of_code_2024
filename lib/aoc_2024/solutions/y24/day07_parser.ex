defmodule Aoc2024.Solutions.Y24.Day07.Parser do
  import NimbleParsec

  # Define the parser
  defparsec(
    :parse_line,
    integer(min: 1)
    |> ignore(string(":"))
    |> ignore(ascii_char([?\s]))
    |> repeat(
      choice([
        integer(min: 1),
        ignore(ascii_char([?\s]))
      ])
    )
  )
end
