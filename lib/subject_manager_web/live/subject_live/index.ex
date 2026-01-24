defmodule SubjectManagerWeb.SubjectLive.Index do
  use SubjectManagerWeb, :live_view

  import SubjectManagerWeb.Components.CoreComponents.FilterForm
  import SubjectManagerWeb.Components.CoreComponents.Subject
  import SubjectManager.Utils.FilterSubjects, only: [filter: 3]
  import SubjectManager.Utils.SortSubjects, only: [sort: 2]

  alias SubjectManager.Subjects

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(page_title: "Subjects")
     |> assign(subjects: Subjects.list_subjects())}
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
     push_patch(socket, to: ~p"/subjects?q=#{q}&position=#{position}&sort_by=#{sort_by}")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="subject-index">
      <.filter_form form={@form} page={~p"/subjects"} />

      <div class="subjects" id="subjects">
        <div id="empty" class="no-results only:block hidden">
          No subjects found. Try changing your filters.
        </div>
        <.subject
          :for={subject <- @subjects |> filter(@q, @position) |> sort(@sort_by)}
          subject={subject}
          dom_id={"subject-#{subject.id}"}
        />
      </div>
    </div>
    """
  end
end
