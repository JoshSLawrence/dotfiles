-- Rex keybindings modelled on ~/.config/herdr/config.toml.
-- Prefix is ctrl+space; each binding is a key sequence "ctrl+space>KEY".
-- Rex's default Cmd shortcuts are left in place alongside these.

local P = "ctrl+space>"

-- ctrl+space starts a sequence, so it no longer reaches the terminal on its
-- own. Press it twice to send one through (zsh set-mark, nvim completion...).
rex.bind(P .. "ctrl+space", "pane.send_key", { key = "ctrl+space" })

-- Help / palette / settings / config
rex.bind(P .. "shift+/", "client.palette.toggle") -- prefix+?
rex.bind(P .. "s", "client.settings")
rex.bind(P .. "shift+r", "client.config.reload")
rex.bind(P .. "b", "client.sidebar.toggle")

-- Sessions (herdr "workspaces")
rex.bind(P .. "w", "session.switch")
rex.bind(P .. "shift+n", "session.new")
rex.bind(P .. "shift+w", "session.rename")
rex.bind(P .. "shift+d", "session.close")

-- Tabs
rex.bind(P .. "c", "client.tab.new")
rex.bind(P .. "shift+t", "client.tab.rename")
rex.bind(P .. "n", "client.tab.next")
rex.bind(P .. "p", "client.tab.previous")
rex.bind(P .. "shift+x", "client.tab.close")
for i = 1, 9 do
  rex.bind(P .. i, "client.tab.goto", { index = i })
end

-- Panes
rex.bind(P .. "h", "pane.focus.left")
rex.bind(P .. "j", "pane.focus.down")
rex.bind(P .. "k", "pane.focus.up")
rex.bind(P .. "l", "pane.focus.right")
rex.bind(P .. "tab", "pane.focus_next")
rex.bind(P .. "shift+tab", "pane.focus_previous")
rex.bind(P .. "v", "pane.split.right")
rex.bind(P .. "-", "pane.split.down")
rex.bind(P .. "x", "pane.close")
rex.bind(P .. "z", "pane.zoom")

-- Resize mode (prefix+r), hjkl or arrows, shift for bigger steps
rex.bind(P .. "r", "client.mode.enter", { name = "resize" })
rex.mode("resize", { exclusive = true })
local dirs = { h = "left", j = "down", k = "up", l = "right" }
for key, dir in pairs(dirs) do
  for _, k in ipairs({ key, dir }) do
    rex.bind("resize/" .. k, "pane.resize", { direction = dir })
    rex.bind("resize/shift+" .. k, "pane.resize", { direction = dir, amount = 15 })
  end
end
rex.bind("resize/=", "pane.balance")
rex.bind("resize/enter", "client.mode.exit")

-- prefix+alt+g: lazygit in a new tab, in the focused pane's directory.
-- The tab closes when lazygit exits, like herdr's type = "pane" command.
rex.action{
  name  = "lazygit",
  title = "Open lazygit",
  run   = function(ctx, args)
    local opts = { command = { "lazygit" } }
    local pwd = rex.block.call("com.superlogical.terminal", "pwd", {})
    if pwd and type(pwd.pwd) == "string" then
      opts.cwd = pwd.pwd:gsub("^file://[^/]*", "")
    end
    local _, err = rex.session.new_window{
      layout = rex.layout.block{
        flavor  = "com.superlogical.terminal.shell",
        options = opts,
      },
    }
    if err ~= nil then error(err, 0) end
  end,
}
rex.bind(P .. "alt+g", "lazygit")
