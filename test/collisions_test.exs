defmodule NischeebLazertagBackend.CollisionsTest do
  use ExUnit.Case

  alias NischeebLazertagBackend.{Player, Collisions}

  test "should handle collisions" do
    players = %{
      {2, 3, 4, 5} => %Player{x: 1.0, y: 0.0},
      {3, 4, 5, 6} => %Player{x: 0.0, y: 1.0},
      {4, 5, 6, 7} => %Player{x: 1.0, y: 1.0}
    }

    shooter = %Player{x: 0, y: 0, angle: 0.0, direction: 90.0}

    assert Collisions.handle(players, shooter) == %Player{ip: {3, 4, 5, 6}, x: 0.0, y: 1.0}
  end

  test "shouldn't kill anyone if shot anywhere else" do
    players = [
      {2, 3, 4, 5} => %Player{x: 1.0, y: 0.0},
      {3, 4, 5, 6} => %Player{x: 0.0, y: 1.0},
      {4, 5, 6, 7} => %Player{x: 1.0, y: 1.0}
    ]

    shooter = %Player{x: 0, y: 0, angle: 0.0, direction: 0.0}

    assert Collisions.handle(players, shooter) == nil
  end
end