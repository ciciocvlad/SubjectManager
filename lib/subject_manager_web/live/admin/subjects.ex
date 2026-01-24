defmodule SubjectManagerWeb.Admin.Subjects do
  use SubjectManagerWeb, :live_view

  import SubjectManagerWeb.Components.CoreComponents.FilterForm
  import SubjectManagerWeb.Components.CoreComponents.Subject
  import SubjectManagerWeb.CoreComponents, only: [modal: 1]
  import SubjectManager.Utils.FilterSubjects, only: [filter: 3]
  import SubjectManager.Utils.SortSubjects, only: [sort: 2]

  alias SubjectManager.Subjects

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(page_title: "Subjects admin")
     |> assign(subjects: Subjects.list_subjects())
     |> assign(show_modal: false)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply,
     socket
     |> assign(q: Map.get(params, "q", ""))
     |> assign(position: Map.get(params, "position", ""))
     |> assign(sort_by: Map.get(params, "sort_by", ""))
     |> assign(form: to_form(params))}
  end

  @impl true
  def handle_event("validate", %{"q" => q, "position" => position, "sort_by" => sort_by}, socket) do
    {:noreply,
     push_patch(socket, to: ~p"/admin/subjects?q=#{q}&position=#{position}&sort_by=#{sort_by}")}
  end

  @impl true
  def handle_event("new", _params, socket) do
    {:noreply, push_navigate(socket, to: ~p"/admin/subjects/new")}
  end

  @impl true
  def handle_event("edit", %{"id" => id}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/admin/subjects/#{id}/edit")}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    subject = Subjects.get_by_id(id)
    {:noreply, socket |> assign(subject: subject) |> assign(show_modal: true)}
  end

  @impl true
  def handle_event("confirm_delete", _params, socket) do
    %{assigns: %{subject: subject}} = socket

    case Subjects.delete_subject(subject) do
      {:ok, _} ->
        {:noreply,
         socket
         |> assign(show_modal: false)
         |> assign(subjects: Subjects.list_subjects())
         |> put_flash(:info, "Subject deleted successfully")}

      {:error, _} ->
        {:noreply,
         socket |> assign(show_modal: false) |> put_flash(:error, "An internal error occurred")}
    end
  end

  @impl true
  def handle_event("hide_modal", _params, socket) do
    {:noreply, assign(socket, show_modal: false)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="subject-index">
      <div class="flex justify-around">
        <.filter_form form={@form} page={~p"/admin/subjects"} />
        <button
          phx-click="new"
          class="text-blue-500 w-[100px] border border-blue-500 rounded-2xl hover:bg-blue-500 hover:text-white"
        >
          Add
        </button>
      </div>

      <div class="subjects" id="subjects">
        <div id="empty" class="no-results only:block hidden">
          No subjects found. Try changing your filters
        </div>
        <.subject
          :for={subject <- @subjects |> filter(@q, @position) |> sort(@sort_by)}
          subject={subject}
          dom_id={"subject-#{subject.id}"}
          can_change?={true}
        />
      </div>
      <.modal :if={@show_modal} id="confirm" show={@show_modal} on_cancel={JS.push("hide_modal")}>
        <b>
          <h1 class="text-2xl">Are you sure?</h1>
        </b>
        <p>You are about to delete <b>{@subject.name}</b></p>
        <div class="flex w-1/2 gap-5">
          <button
            phx-click="confirm_delete"
            class="flex-1 border border-red-500 rounded text-red-500 hover:bg-red-500 hover:text-white"
          >
            Delete
          </button>
          <button
            phx-click="hide_modal"
            class="flex-1 border border-zinc-500 rounded text-zinc-500 hover:bg-zinc-500 hover:text-white"
          >
            Cancel
          </button>
        </div>
      </.modal>
    </div>
    """
  end
end
