defmodule NischeebLazertag.Game do
  alias NischeebLazertag.Player

  require Logger

  def add_player(data, address, state) do
    with {:error, :not_found} <- find_player(address, state),
         {:ok, player} <- Player.new(data, address) do
      Logger.info("Joined", player: inspect(player))
      new_state = put_in(state, [:players, address], player)
      {:ok, player, new_state}
    else
      {:error, :invalid_data} ->
        {:error, :invalid_data, state}

      {:error, :dead, player} ->
        Logger.error("Dead", player: inspect(player))
        {:error, :dead, player, state}

      {:ok, player} ->
        Logger.error("Already exists", player: inspect(player))
        {:error, :exists, player, state}
    end
  end

  def update_position(data, address, state) do
    with {:ok, player} <- find_player(address, state),
         {:ok, player} <- Player.update(data, player) do
      put_in(state, [:players, address], player)
    else
      {:error, :invalid_data} ->
        state

      {:error, :not_found} ->
        state

      {:error, :dead, _player} ->
        state
    end
  end

  def shot(data, address, state) do
    with {:ok, shot_player} <- find_player(address, state),
         {:ok, shot_player} <- Player.update(data, shot_player) do
      new_state = put_in(state, [:players, address], shot_player)
      players = Map.delete(state.players, address)

      victim = NischeebLazertag.Collisions.handle(players, shot_player)

      if victim do
        damage = shot_player.gun.damage
        health_after_shot = victim.health - damage

        if health_after_shot > 0 do
          victim = %{victim | health: health_after_shot}
          new_state = put_in(state, [:players, victim.address], victim)
          {:ok, :hit, {shot_player, victim}, new_state}
        else
          victim = %{victim | health: 0, death_timestamp: DateTime.utc_now()}
          new_state = put_in(state, [:players, victim.address], victim)
          {:ok, :killed, {shot_player, victim}, new_state}
        end
      else
        {:ok, :miss, shot_player, new_state}
      end
    else
      {:error, :not_found} ->
        {:error, :not_found, state}

      {:error, :dead, player} ->
        {:error, :dead, player, state}
    end
  end

  def respawn(address, state) do
    case find_player(address, state) do
      {:error, :dead, player} ->
        put_in(state, [:players, player.address], %{player | health: 100, death_timestamp: nil})

      _ ->
        state
    end
  end

  defp find_player(address, state) do
    data = Enum.find(state.players, fn {addr, _player} -> addr == address end)

    case data do
      nil -> {:error, :not_found}
      {_address, %Player{health: 0} = player} -> {:error, :dead, player}
      {_address, %Player{} = player} -> {:ok, player}
    end
  end
end
