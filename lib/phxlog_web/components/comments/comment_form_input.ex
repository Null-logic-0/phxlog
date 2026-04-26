defmodule PhxlogWeb.Comments.CommentFormInput do
  use PhxlogWeb, :html

  attr :form, :any, required: true
  attr :submit, :string, required: true
  attr :change, :string, required: true
  attr :cancel, :string, default: nil
  attr :hidden_id, :any, default: nil
  attr :myself, :any, default: nil

  def comment_form_input(assigns) do
    ~H"""
    <.form for={@form} phx-submit={@submit} phx-change={@change} phx-target={@myself}>
      <input :if={@hidden_id} type="hidden" name="comment_id" value={@hidden_id} />
      <div class="rounded-box border border-base-300 bg-base-100 overflow-hidden focus-within:border-primary transition-colors">
        <textarea
          name="comment[content]"
          rows="3"
          placeholder="Write a comment…"
          class="textarea w-full text-sm resize-none focus:outline-none bg-transparent border-none"
        ><%= @form[:content].value %></textarea>
        <div class="flex items-center justify-between px-3 py-2 border-t border-base-300">
          <span class={[
            "text-xs",
            if(String.length(to_string(@form[:content].value)) > 190,
              do: "text-error",
              else: "text-base-content/40"
            )
          ]}>
            {200 - String.length(to_string(@form[:content].value || ""))} chars left
          </span>
          <div class="flex gap-2">
            <button :if={@cancel} type="button" phx-click={@cancel} class="btn btn-sm btn-ghost">
              Cancel
            </button>
            <button type="submit" class="btn btn-sm btn-primary" phx-disable-with="Saving…">
              {if @hidden_id, do: "Save", else: "Post"}
            </button>
          </div>
        </div>
      </div>
    </.form>
    """
  end
end
