defmodule FirstWeb.Navigation do
  use FirstWeb, :html

  attr :current_scope, :map, default: nil
  slot :inner_content

  def navbar(assigns) do
    ~H"""
    <header class="navbar px-4 sm:px-6 lg:px-8 bg-white border-b border-gray-100 flex items-center h-22">
      <!-- Logo -->
      <div class="flex-1">
        <.link navigate={~p"/"} class="flex items-center gap-2">
          <img src={~p"/images/logo.svg"} class="h-20 w-auto" />
        </.link>
      </div>
      
    <!-- Desktop nav -->
      <div class="hidden sm:flex">
        <ul class="flex items-center space-x-4">
          <%= if @current_scope do %>
            <.nav_link to={~p"/home"}>Home</.nav_link>
            <.nav_link to={~p"/users/settings"}>Invoices</.nav_link>
            <.nav_link to={~p"/users/settings"}>Settings</.nav_link>

            <.link
              href={~p"/users/log-out"}
              method="delete"
              class="font-medium px-6 py-2 rounded-md hover:bg-gray-100"
            >
              Log out
            </.link>
          <% else %>
            <.nav_link to={~p"/users/log-in"}>Sign in</.nav_link>
          <% end %>
        </ul>
      </div>
      
    <!-- Mobile menu button -->
      <button
        class="sm:hidden"
        phx-click={
          JS.toggle(
            to: "#mobile-menu",
            in:
              {"transition transform ease-out duration-300", "scale-y-0 opacity-0",
               "scale-y-100 opacity-100"},
            out:
              {"transition transform ease-in duration-200", "scale-y-100 opacity-100",
               "scale-y-0 opacity-0"}
          )
        }
      >
        <.icon name="hero-bars-3" class="h-7 w-7" />
      </button>
      
    <!-- Mobile menu -->
      <div
        id="mobile-menu"
        class="fixed inset-0 bg-white z-50 flex flex-col px-6 py-8 scale-y-0 opacity-0 origin-top"
      >
        <div class="flex justify-between items-center mb-10">
          <img src={~p"/images/logo.svg"} class="h-20 w-auto" />

          <button
            phx-click={JS.toggle(to: "#mobile-menu")}
            class="text-4xl"
          >
            &times;
          </button>
        </div>

        <nav class="flex flex-col space-y-6 text-lg">
          <%= if @current_scope do %>
            <.link navigate={~p"/home"}>Home</.link>
            <.link navigate={~p"/users/settings"}>Settings</.link>

            <.link
              href={~p"/users/log-out"}
              method="delete"
              class="bg-black text-white rounded-md px-6 py-2 text-center"
            >
              Log out
            </.link>
          <% end %>
        </nav>

        <%= unless @current_scope do %>
          <nav class="flex flex-col space-y-6 text-lg">
            <.link
              navigate={~p"/users/log-in"}
              class="bg-black text-white rounded-md px-6 py-2 text-center"
            >
              Sign in
            </.link>
          </nav>
        <% end %>
      </div>
    </header>

    {render_slot(@inner_block)}
    """
  end

  def nav_link(assigns) do
    ~H"""
    <li>
      <.link
        navigate={@to}
        class="font-medium px-6 py-2 rounded-md hover:bg-gray-100 transition"
      >
        {render_slot(@inner_block)}
      </.link>
    </li>
    """
  end
end
