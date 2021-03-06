defmodule CanvasAPI.CanvasView do
  use CanvasAPI.Web, :view

  alias CanvasAPI.{Canvas, Endpoint, UserView}
  alias CanvasAPI.Canvas.Formatter, as: CanvasFormatter

  def render("index.json", %{canvases: canvases}) do
    %{
      data: render_many(canvases, __MODULE__, "canvas.json"),
      included: canvases
                |> Enum.map(&(&1.creator))
                |> Enum.uniq
                |> Enum.map(fn user ->
                  render_one(user, UserView, "user.json")
                end)
    }
  end

  def render("show.json", %{canvas: canvas}) do
    %{
      data: render_one(canvas, __MODULE__, "canvas.json"),
      included: [render_one(canvas.creator, UserView, "user.json")]
    }
  end

  def render("canvas.json", %{canvas: canvas, json_api: false}) do
    %{
      id: canvas.id,
      blocks: canvas.blocks,
      is_template: canvas.is_template,
      link_access: canvas.link_access,
      native_version: canvas.native_version,
      slack_channel_ids: canvas.slack_channel_ids,
      type: canvas.type,
      version: canvas.version,
      edited_at: canvas.edited_at,
      inserted_at: canvas.inserted_at,
      updated_at: canvas.updated_at,
      team_id: canvas.team_id,
      type: "canvas"
    }
  end

  @lint {Credo.Check.Refactor.ABCSize, false}
  def render("canvas.json", %{canvas: canvas}) do
    %{
      id: canvas.id,
      attributes: %{
        blocks: canvas.blocks,
        is_template: canvas.is_template,
        link_access: canvas.link_access,
        native_version: canvas.native_version,
        slack_channel_ids: canvas.slack_channel_ids,
        type: canvas.type,
        version: canvas.version,
        edited_at: canvas.edited_at,
        inserted_at: canvas.inserted_at,
        updated_at: canvas.updated_at
      },
      relationships: relationships(canvas),
      type: "canvas"
    }
  end

  def render("canvas.md", %{canvas: canvas}) do
    CanvasFormatter.to_markdown(canvas)
  end

  @spec relationships(Canvas.t) :: map
  defp relationships(canvas) do
    %{
      comments: %{
        links: %{
          related: comment_path(Endpoint, :index,
                                filter: %{"canvas.id" => canvas.id})
        }
      },
      creator: %{
        data: %{id: canvas.creator_id, type: "user"}
      },
      ops: %{
        links: %{
          related: team_canvas_op_path(
            Endpoint, :index, canvas.team_id, canvas.id)
        }
      },
      pulse_events: %{
        links: %{
          related: team_canvas_pulse_event_path(
            Endpoint, :index, canvas.team_id, canvas.id)
        }
      },
      team: %{
        data: %{id: canvas.team_id, type: "team"},
        links: %{
          related: team_path(Endpoint, :show, canvas.team_id)
        }
      }
    }
    |> add_template(canvas)
  end

  @spec add_template(map, Canvas.t) :: map
  defp add_template(rels, canvas = %Canvas{template_id: template_id})
       when is_binary(template_id) do
    rels
    |> Map.put(:template, %{
      data: %{id: canvas.template_id, type: "canvas"},
      links: %{
        related: team_canvas_path(Endpoint,
                                  :show,
                                  canvas.team_id,
                                  canvas.template_id)
      }
    })
  end

  defp add_template(rels, _), do: rels
end
