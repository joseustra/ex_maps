






defmodule Test do
  def do_something do
    params = %{
      name: "John",
      email: "john.doe@email.com",
      address:  [
        %{
          type: "main",
          line1: "12, code ave",
          line2: "room 42",
          postal_code: "1234"
        },
        %{
          type: "billing",
          line1: "14, code ave",
          line2: "room 44",
          postal_code: "1234"
        }
      ]
    }
  end
end
