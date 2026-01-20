defmodule SubjectManagerWeb.Admin.Subject do
  use SubjectManagerWeb, :live_view

  import SubjectManagerWeb.Components.CoreComponents.Badge

  alias SubjectManager.Subjects
  alias SubjectManager.Subjects.Subject

  @impl true
  def mount(params, _session, socket) do
    id = params["id"]

    if is_nil(id) do
      {:ok, assign(socket, form: Subject.changeset())}
    else
      case Subjects.get_by_id(id) do
        nil -> {:ok, push_navigate(socket, to: ~p"/admin/subjects")}

        subject -> {:ok, socket |> assign(subject: subject) |> assign(form: Subject.changeset(subject))}
      end
    end
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    page = socket.assigns.live_action

    {:noreply, assign(socket, page: page)}
  end

  @impl true
  def handle_event("validate", %{"subject" => params}, socket) do
    base_form = socket.assigns.form.data || %Subject{}
    form = base_form |> Subject.changeset(params) |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: form)}
  end

  @impl true
  def handle_event("save", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <%= case @page do %>
      <% :index -> %>
        <div class="flex gap-10">
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
      <% :edit -> %>
        <.form :let={f} for={@form} id="filter-form" phx-change="validate" phx-submit="save">
          <.input field={f[:name]} placeholder="Name" autocomplete="off" />
          <.input
            type="select"
            field={f[:position]}
            prompt="Position"
            options={[
              Forward: "forward",
              Midfielder: "midfielder",
              Winger: "winger",
              Defender: "defender",
              Goalkeeper: "goalkeeper"
            ]}
          />
          <.input field={f[:team]} placeholder="Team" />
          <.input type="textarea" field={f[:bio]} placeholder="Bio" class="h-64 resize-none" />
          <button type="submit" class="bg-blue-400 w-1/6 h-10 rounded-2xl mt-2">Save</button>
        </.form>
    <% end %>
    """
  end
end
