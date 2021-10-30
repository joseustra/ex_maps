defmodule Test do
  def do_something do
    %{
      name: "John",
      email: "john.doe@email.com",
      address:  [
        %{
          type: "main",
          line1: "12, code ave",
          line2: "room 42",
          zip_code: "1234"
        },
        %{
          type: "billing",
          line1: "14, code ave",
          line2: "room 44",
          zip_code: "1234"
        }
      ]
    }
  end

  def do_otherthing(%{name: name, zip_code: zip_code}) do
  end
end
