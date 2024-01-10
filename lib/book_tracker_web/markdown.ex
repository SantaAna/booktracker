defmodule BookTrackerWeb.Markdown do
  @moduledoc """
  Function for styling markdown input provided by users.
  """ 
  alias Earmark.AstTools


  @doc """
  Transforms markdown into styled HTML.

  Uses the processors returned by post_registered_processors
  """
  def transform_markdown(markdown_text) do
    Earmark.as_html!(markdown_text, registered_processors: post_registered_processors())
  end

  @doc """
  Adds styling to HTML tags used in markdown.
  Assumes that tailwind typograph and daisyui 
  are installed.
  """ 
  def post_registered_processors() do
    [
      {"h1", add_classes(~w(text-3xl font-bold my-4))},
      {"h2", add_classes(~w(text-2xl font-bold my-6 ))},
      {"h3", add_classes(~w(text-xl font-bold my-4 ))},
      {"ol", add_classes(~w(list-decimal list-inside))},
      {"ul", add_classes(~w(list-disc list-inside))},
      {"li", add_classes(~w(prose my-1 ml-4))},
      {"hr", add_classes(~w(border-t-2 my-3))},
      {"p", add_classes(~w(prose))},
      {"a", add_classes(~w(link))},
      {"img",add_classes(~w(mx-auto my-3))},
      {"blockquote", add_classes(~w(border-l-4p-4))},
      {"table", add_classes(~w(table))}
      # {"th", add_classes(~w(p-2 border-2))},
      # {"td", add_classes(~w(p-2 border-2))}
    ] 
  end
  
  #convenience function for adding items to the class list
  defp add_classes(class_list) do
    fn node -> AstTools.merge_atts_in_node(node, class: Enum.join(class_list, " ")) end
  end
end
