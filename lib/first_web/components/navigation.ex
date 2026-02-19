defmodule FirstWeb.Navigation do
  @moduledoc """
  Reusable UI components for application navigation.
  """

  use FirstWeb, :html
  attr :current_scope, :map, default: nil
  slot :inner_content

  def navbar(assigns) do
    ~H"""
    <%= if @current_scope do %>
      <div class="hidden lg:w-20 lg:pl-20 px-2 justify-center"></div>
      <div class="min-h-screen bg-blue-50/60">
        <div class="flex min-h-screen">
          <aside id="desktop-sidebar" class="hidden lg:flex lg:w-50 lg:fixed lg:inset-y-0 lg:z-40">
            <div
              id="desktop-sidebar-inner"
              class="flex grow flex-col overflow-y-auto  bg-red-700 px-5 py-6 transition-all duration-300"
            >
              <.link navigate={~p"/home"} class="mb-8 flex items-center gap-3 px-1">
                <img
                  src={~p"/images/logo.webp"}
                  class="h-15 w-auto rounded-full"
                  alt="swiftly logo"
                  width="80"
                  height="80"
                  fetchpriority="high"
                  oncontextmenu="return false;"
                />
                <div></div>
              </.link>

              <nav class="space-y-1" aria-label="Sidebar">
                <.link
                  navigate={~p"/home"}
                  class="desktop-nav-link group flex items-center justify-start gap-3 rounded-xl px-3 py-2.5 text-sm font-semibold text-white transition duration-200 hover:bg-white/10 hover:text-white"
                >
                  <.icon name="hero-home" class="size-5 text-white group-hover:text-white" />
                  <span class="desktop-sidebar-label">Dashboard</span>
                </.link>

                <.link
                  navigate={~p"/expenses"}
                  class="desktop-nav-link group flex items-center justify-start gap-3 rounded-xl px-3 py-2.5 text-sm font-semibold text-white transition duration-200 hover:bg-white/10 hover:text-white"
                >
                  <.icon
                    name="hero-archive-box"
                    class="size-5 text-white group-hover:text-white"
                  /> <span class="desktop-sidebar-label">Expenses</span>
                </.link>

                <.link
                  navigate={~p"/invoices"}
                  class="desktop-nav-link group flex items-center justify-start gap-3 rounded-xl px-3 py-2.5 text-sm font-semibold text-white transition duration-200 hover:bg-white/10 hover:text-white"
                >
                  <.icon
                    name="hero-plus-circle"
                    class="size-5 text-white group-hover:text-white"
                  /> <span class="desktop-sidebar-label">New Invoice</span>
                </.link>

                <.link
                  navigate={~p"/users/settings"}
                  class="desktop-nav-link group flex items-center justify-start gap-3 rounded-xl px-3 py-2.5 text-sm font-semibold text-white transition duration-200 hover:bg-white/10 hover:text-white"
                >
                  <.icon
                    name="hero-cog-6-tooth"
                    class="size-5 text-white group-hover:text-white"
                  /> <span class="desktop-sidebar-label">Reports</span>
                </.link>
              </nav>

              <div class="mt-auto border-t border-white/20 pt-4">
                <.link
                  href={~p"/users/log-out"}
                  method="delete"
                  class="desktop-nav-link group flex items-center justify-start gap-3 rounded-xl px-3 py-2.5 text-sm font-semibold text-white transition duration-200 hover:bg-white/10 hover:text-white"
                >
                  <.icon
                    name="hero-arrow-right-on-rectangle"
                    class="size-5 text-white group-hover:text-white"
                  /> <span class="desktop-sidebar-label">Log out</span>
                </.link>
              </div>
            </div>
          </aside>

          <div id="desktop-main" class="flex flex-1 flex-col lg:pl-50 transition-all duration-300">
            <header class="sticky top-0 z-30 border-b border-blue-100 bg-white/95 backdrop-blur">
              <div class="flex h-14 items-center justify-between gap-4 px-4 sm:px-6 lg:px-8">
                <button
                  class="inline-flex items-center justify-center rounded-lg border border-blue-200 p-2 text-blue-700 transition hover:bg-blue-50 lg:hidden"
                  aria-label="Open menu"
                  phx-click={
                    JS.show(
                      to: "#mobile-sidebar-shell",
                      transition:
                        {"transition-opacity ease-out duration-200", "opacity-0", "opacity-100"}
                    )
                    |> JS.show(
                      to: "#mobile-sidebar-panel",
                      transition:
                        {"transition ease-out duration-200", "-translate-x-full", "translate-x-0"}
                    )
                  }
                >
                  <.icon name="hero-bars-3" class="size-6" />
                </button>

                <button
                  type="button"
                  class="hidden lg:inline-flex items-center justify-center rounded-md bg-white shadow-lg outline-1 outline-black/5 transition hover:bg-blue-50"
                  aria-label="Toggle sidebar"
                  phx-click={
                    JS.toggle_class("lg:w-50", to: "#desktop-sidebar")
                    |> JS.toggle_class("lg:w-20", to: "#desktop-sidebar")
                    |> JS.toggle_class("lg:pl-50", to: "#desktop-main")
                    |> JS.toggle_class("lg:pl-20", to: "#desktop-main")
                    |> JS.toggle_class("px-5", to: "#desktop-sidebar-inner")
                    |> JS.toggle_class("px-2", to: "#desktop-sidebar-inner")
                    |> JS.toggle_class("hidden", to: ".desktop-sidebar-label")
                    |> JS.toggle_class("justify-start", to: ".desktop-nav-link")
                    |> JS.toggle_class("justify-center", to: ".desktop-nav-link")
                  }
                >
                  <.icon name="hero-bars-3" class="size-5" />
                </button>

                <div class="ml-auto">
                  <el-dropdown class="inline-block">
                    <button class="inline-flex w-full justify-center gap-x-1.5 rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-xs inset-ring-1 inset-ring-gray-300 hover:bg-gray-50">
                      {@current_scope.user.email}
                      <svg
                        viewBox="0 0 20 20"
                        fill="currentColor"
                        data-slot="icon"
                        aria-hidden="true"
                        class="-mr-1 size-5 text-gray-400"
                      >
                        <path
                          d="M5.22 8.22a.75.75 0 0 1 1.06 0L10 11.94l3.72-3.72a.75.75 0 1 1 1.06 1.06l-4.25 4.25a.75.75 0 0 1-1.06 0L5.22 9.28a.75.75 0 0 1 0-1.06Z"
                          clip-rule="evenodd"
                          fill-rule="evenodd"
                        />
                      </svg>
                    </button>

                    <el-menu
                      anchor="bottom end"
                      popover
                      class="w-56 origin-top-right rounded-md bg-white shadow-lg outline-1 outline-black/5 transition transition-discrete [--anchor-gap:--spacing(2)] data-closed:scale-95 data-closed:transform data-closed:opacity-0 data-enter:duration-100 data-enter:ease-out data-leave:duration-75 data-leave:ease-in"
                    >
                      <div class="py-1">
                        <a
                          href={~p"/profile?tab=personal"}
                          class="block px-4 py-2 text-sm text-gray-700 focus:bg-gray-100 focus:text-gray-900 focus:outline-hidden"
                        >
                          Profile
                        </a>

                        <a
                          href={~p"/profile?tab=license"}
                          class="block px-4 py-2 text-sm text-gray-700 focus:bg-gray-100 focus:text-gray-900 focus:outline-hidden"
                        >
                          License
                        </a>

                        <.link
                          href={~p"/users/log-out"}
                          method="delete"
                          class="block px-4 py-2 text-sm text-gray-700 focus:bg-gray-100 focus:text-gray-900 focus:outline-hidden"
                        >
                          Sign out
                        </.link>
                      </div>
                    </el-menu>
                  </el-dropdown>
                </div>
              </div>
            </header>

            <main class="flex-1 px-2 py-4 sm:px-4 sm:py-6 lg:px-2 lg:py-4 bg-white">
              {render_slot(@inner_block)}
            </main>
          </div>
        </div>

        <div id="mobile-sidebar-shell" class="fixed inset-0 z-50 hidden lg:hidden" aria-hidden="true">
          <button
            type="button"
            class="absolute inset-0 bg-transparent"
            aria-label="Close menu"
            phx-click={
              JS.hide(
                to: "#mobile-sidebar-panel",
                transition: {"transition ease-in duration-150", "translate-x-0", "-translate-x-full"}
              )
              |> JS.hide(
                to: "#mobile-sidebar-shell",
                transition: {"transition-opacity ease-in duration-150", "opacity-100", "opacity-0"}
              )
            }
          >
          </button>

          <div
            id="mobile-sidebar-panel"
            class="relative flex h-full w-72 max-w-[85vw] -translate-x-full flex-col  bg-red-700 px-5 py-6"
          >
            <div class="mb-8 flex items-center justify-between">
              <.link navigate={~p"/home"} class="flex items-center gap-3">
                <img
                  src={~p"/images/Logo.jpg"}
                  class="h-10 w-auto rounded-full"
                  alt="swiftly logo"
                  width="80"
                  height="80"
                  fetchpriority="high"
                  oncontextmenu="return false;"
                />
              </.link>

              <button
                type="button"
                class="rounded-lg p-2 text-blue-100 hover:bg-white/10"
                aria-label="Close menu"
                phx-click={
                  JS.hide(
                    to: "#mobile-sidebar-panel",
                    transition:
                      {"transition ease-in duration-150", "translate-x-0", "-translate-x-full"}
                  )
                  |> JS.hide(
                    to: "#mobile-sidebar-shell",
                    transition:
                      {"transition-opacity ease-in duration-150", "opacity-100", "opacity-0"}
                  )
                }
              >
                <.icon name="hero-x-mark" class="size-6" />
              </button>
            </div>

            <nav class="space-y-1" aria-label="Mobile sidebar">
              <.link
                navigate={~p"/home"}
                class="flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-medium text-white hover:bg-white/10"
              >
                <.icon name="hero-home" class="size-5 text-blue-100" /> Dashboard
              </.link>
              <.link
                navigate={~p"/expenses"}
                class="flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-medium text-white hover:bg-white/10"
              >
                <.icon name="hero-archive-box" class="size-5 text-blue-100" /> Parcels
              </.link>
              <.link
                navigate={~p"/users/settings"}
                class="flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-medium text-white hover:bg-white/10"
              >
                <.icon name="hero-user-circle" class="size-5 text-blue-100" /> Settings
              </.link>
            </nav>
          </div>
        </div>
      </div>
    <% else %>
      <header class="navbar px-4 sm:px-6 lg:px-8 bg-white border-b border-gray-100 flex items-center h-20">
        <div class="flex-1">
          <.link navigate={~p"/"} class="flex items-center gap-2">
            <img
              src={~p"/images/logo.webp"}
              class="h-10 w-auto m-4"
              alt="swiftly logo"
              width="80"
              height="80"
              fetchpriority="high"
              oncontextmenu="return false;"
            />
            <span class="sr-only">Home</span>
          </.link>
        </div>

        <div class="hidden sm:flex">
          <ul class="menu menu-horizontal w-full relative z-10 flex items-center gap-4 px-4 py-2 sm:px-6 lg:px-8 justify-end">
            <li>
              <.link
                navigate={~p"/users/log-in"}
                class="inline-flex  justify-center gap-x-1.5 rounded-md border border-gray-300 bg-white px-6 py-2 text-base font-medium text-gray-900  hover:bg-gray-50"
              >
                Sign In
              </.link>
            </li>
          </ul>
        </div>

        <button
          class="sm:hidden"
          aria-label="Open menu"
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

        <div
          id="mobile-menu"
          class="fixed inset-0 bg-white z-50 flex flex-col px-6 py-8 scale-y-0 opacity-0 origin-top"
        >
          <div class="flex justify-between items-center mb-10">
            <img
              src={~p"/images/logo.svg"}
              class="h-10 w-auto"
              alt="swiftly logo"
              width="80"
              height="80"
              fetchpriority="high"
            />

            <button
              phx-click={JS.toggle(to: "#mobile-menu")}
              class="text-4xl"
              aria-label="Close menu"
            >
              &times;
            </button>
          </div>

          <nav class="flex flex-col space-y-6 text-lg">
            <.link
              navigate={~p"/users/log-in"}
              class="bg-black text-white rounded-md px-6 py-2 text-center"
            >
              Sign in
            </.link>
          </nav>
        </div>
      </header>

      {render_slot(@inner_block)}
    <% end %>
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
