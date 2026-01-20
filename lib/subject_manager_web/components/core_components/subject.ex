defmodule SubjectManagerWeb.Components.CoreComponents.Subject do
  @moduledoc false
  use SubjectManagerWeb, :core_component

  import SubjectManagerWeb.Components.CoreComponents.Badge

  alias SubjectManager.Subjects.Subject

  attr :subject, Subject, required: true
  attr :dom_id, :string, required: true
  attr :can_change?, :boolean, default: false

  def subject(assigns) do
    ~H"""
    <div>
      <.link navigate={get_route(@subject, @can_change?)} id={@dom_id}>
        <div class="card group relative">
          <img src={@subject.image_path} />
          <h2>{@subject.name}</h2>
          <div class="details">
            <div class="team">
              {@subject.team}
            </div>
            <.badge status={@subject.position} />
          </div>
        </div>
      </.link>
      <div :if={@can_change?} class="flex gap-5 mx-10 mt-2">
        <button class="flex-1 text-zinc-600 rounded border border-zinc-600 hover:bg-zinc-600 hover:text-white" phx-click="edit" phx-value-id={@subject.id}>Edit</button>
        <button class="flex-1 text-red-600 rounded border border-red-600 hover:bg-red-600 hover:text-white" phx-click="delete" phx-value-id={@subject.id}>Delete</button>
      </div>
    </div>
    """
  end

  defp get_route(subject, true), do: ~p"/admin/subjects/#{subject}"
  defp get_route(subject, false), do: ~p"/subjects/#{subject}"
end
