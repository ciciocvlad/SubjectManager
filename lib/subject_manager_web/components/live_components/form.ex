defmodule SubjectManagerWeb.Components.LiveComponents.FormLive do
  @moduledoc false
  use SubjectManagerWeb, :live_component

  @impl true
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end
end
