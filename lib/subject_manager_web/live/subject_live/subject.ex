defmodule SubjectManagerWeb.SubjectLive.Subject do
  use SubjectManagerWeb, :live_view

  import SubjectManagerWeb.Components.CoreComponents.Badge

  alias SubjectManager.Subjects

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    case Subjects.get_by_id(id) do
      nil ->
        {:ok, push_navigate(socket, to: ~p"/subjects")}

      subject ->
        {:ok, assign(socket, subject: subject)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex gap-10">
      <.link navigate={~p"/subjects"} class="h-10">
        <img src="/icons/back.svg" class="w-20" />
      </.link>
      <img src={@subject.image_path} width={400} />
      <div>
        <div class="flex items-center gap-2">
          <h1 class="text-4xl font-semibold text-blue-500">{@subject.name}</h1>
          <.badge status={@subject.position} class="h-fit" />
        </div>
        <div class="team">
          {@subject.team}
        </div>
        <p class="text-zinc-700 mt-3">{@subject.bio}</p>
      </div>
    </div>
    """
  end
end
