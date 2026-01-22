defmodule SubjectManagerWeb.Admin.Subject do
  use SubjectManagerWeb, :live_view

  import SubjectManagerWeb.Components.CoreComponents.Badge

  alias SubjectManager.Subjects
  alias SubjectManager.Subjects.Subject

  @impl true
  def mount(params, _session, socket) do
    id = params["id"]

    if is_nil(id) do
      {:ok,
       socket
       |> assign(form: Subject.changeset())
       |> assign(uploaded_files: [])
       |> allow_upload(:photo, accept: ~w(.jpg .jpeg .png), max_entries: 1)}
    else
      case Subjects.get_by_id(id) do
        nil ->
          {:ok, push_navigate(socket, to: ~p"/admin/subjects")}

        subject ->
          {:ok,
           socket
           |> assign(subject_id: id)
           |> assign(subject: subject)
           |> assign(form: Subject.changeset(subject))
           |> assign(uploaded_files: [])
           |> allow_upload(:photo, accept: ~w(.jpg .jpeg .png), max_entries: 1)}
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
  def handle_event("save", params, socket) do
    subject_id = socket.assigns[:subject_id]

    uploaded_files =
      consume_uploaded_entries(socket, :photo, fn %{path: path}, _entry ->
        dest =
          Path.join(
            Application.app_dir(:subject_manager, "priv/static/images"),
            Path.basename(path)
          )

        File.cp!(path, dest)
        {:ok, ~p"/images/#{Path.basename(path)}"}
      end)

    {result, action} =
      if subject_id do
        {subject_id
         |> Subjects.get_by_id()
         |> Subjects.update_subject(maybe_update_params(uploaded_files, params["subject"])),
         :update}
      else
        {Subjects.create_subject(maybe_update_params(uploaded_files, params["subject"])), :create}
      end

    case result do
      {:ok, _subject} ->
        {:noreply,
         socket
         |> update(:uploaded_files, &(&1 ++ uploaded_files))
         |> put_flash(:info, get_message(action))
         |> redirect(to: ~p"/admin/subjects")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: changeset)}
    end
  end

  @impl true
  def handle_event("cancel", _params, socket) do
    {:noreply, push_navigate(socket, to: ~p"/admin/subjects/")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <%= case @page do %>
      <% :index -> %>
        <div class="flex gap-10">
          <.link navigate={~p"/admin/subjects"} class="h-10">
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
      <% :edit -> %>
        <.form :let={f} for={@form} id="filter-form" phx-change="validate" phx-submit="save" multipart>
          <.input field={f[:name]} placeholder="Name" autocomplete="off" label="Name" />
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
            label="Position"
          />
          <.input field={f[:team]} placeholder="Team" label="Team" />
          <.input
            type="textarea"
            field={f[:bio]}
            placeholder="Bio"
            class="h-64 resize-none"
            label="Bio"
          />
          <.label for="file-upload">Photo</.label>
          <.live_file_input id="file-upload" upload={@uploads.photo} />
          <section phx-drop-target={@uploads.photo.ref}>
            <article :for={entry <- @uploads.photo.entries} class="upload-entry">
              <figure><.live_img_preview entry={entry} /></figure>
              <progress value={entry.progress} max="100">{entry.progress}%</progress>
            </article>
          </section>
          <div class="flex gap-2">
            <button
              type="submit"
              class="border border-blue-400 bg-blue-400 w-1/6 h-10 rounded-2xl mt-2 hover:bg-white"
            >
              Save
            </button>
            <button
              phx-click="cancel"
              class="border border-zinc-500 bg-zinc-500 w-1/6 h-10 rounded-2xl mt-2 hover:bg-white"
            >
              Cancel
            </button>
          </div>
        </.form>
    <% end %>
    """
  end

  defp get_message(:create), do: "Subject created successfully"
  defp get_message(:update), do: "Subject updated successfully"

  defp maybe_update_params([], params), do: params

  defp maybe_update_params([uploaded_entry], params),
    do: Map.put(params, "image_path", uploaded_entry)
end
