-- ================================================================
--  Neovim Configuration
--  Phase 1: UI       — catppuccin · mini.statusline · mini.tabline · which-key
--  Phase 2: Navigate — mini.files · fzf-lua
--  Phase 3: Syntax   — nvim-treesitter · mini.ai · mini.indentscope · mini.surround
--  Phase 4: Git      — gitsigns
--  Phase 5: LSP      — mason · mason-lspconfig · nvim-lspconfig
--                      LuaSnip · friendly-snippets · blink.cmp · conform.nvim
--  Phase 6: Polish   — terminal · mini.comment · mini.pairs · mini.bufremove · mini.notify
--  Neovim 0.11+
-- ================================================================

-- Leader must be set before any plugin loads
vim.g.mapleader      = " "
vim.g.maplocalleader = "\\"

-- ── OPTIONS ─────────────────────────────────────────────────────
local opt = vim.opt

-- Appearance
opt.number         = true
opt.relativenumber = true
opt.cursorline     = true
opt.signcolumn     = "yes"
opt.termguicolors  = true
opt.showmode       = false       -- statusline shows mode
opt.laststatus     = 3           -- single global statusline
opt.showtabline    = 2           -- always show tabline
opt.pumblend       = 0           -- opaque popup (important for WSL)
opt.winblend       = 0
opt.fillchars      = {
  eob  = " ",                    -- hide ~ at end of buffer
  diff = "╱",
}

-- Indentation
opt.tabstop     = 2
opt.shiftwidth  = 2
opt.softtabstop = -1             -- mirrors shiftwidth automatically
opt.expandtab   = true
opt.smartindent = true

-- Editing
opt.wrap          = false
opt.scrolloff     = 8
opt.sidescrolloff = 8
opt.virtualedit   = "block"      -- free cursor in visual-block mode

-- Folding (treesitter expressions; foldlevel=99 keeps everything open at start)
opt.foldmethod     = "expr"
opt.foldexpr       = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevel      = 99
opt.foldlevelstart = 99
opt.foldenable     = true

-- Search
opt.ignorecase = true
opt.smartcase  = true
opt.hlsearch   = true
opt.inccommand = "split"         -- live :s preview in a split

-- Splits
opt.splitright = true
opt.splitbelow = true

-- Files
opt.undofile = true
opt.swapfile = false
opt.backup   = false

-- Completion & UX
opt.completeopt = { "menu", "menuone", "noselect" }
opt.updatetime  = 250
opt.timeoutlen  = 300
opt.mouse       = "a"
opt.clipboard   = "unnamedplus"
opt.confirm     = true           -- prompt instead of error on unsaved close

-- ── PLUGINS ─────────────────────────────────────────────────────
vim.pack.add({
  -- Phase 1: UI
  { src ="https://github.com/catppuccin/nvim",       name = "catppuccin" },
  { src ="https://github.com/echasnovski/mini.nvim", name = "mini.nvim"  },
  { src ="https://github.com/folke/which-key.nvim",  name = "which-key"  },
  -- Phase 2: Navigate
  { src ="https://github.com/ibhagwan/fzf-lua",      name = "fzf-lua"    },
  -- Phase 3: Syntax
  { src ="https://github.com/nvim-treesitter/nvim-treesitter", name = "nvim-treesitter" },
  -- Phase 4: Git
  { src ="https://github.com/lewis6991/gitsigns.nvim",                   name = "gitsigns"          },
  -- Phase 5: LSP
  { src ="https://github.com/L3MON4D3/LuaSnip",                          name = "LuaSnip"           },
  { src ="https://github.com/saghen/blink.cmp",                          name = "blink.cmp"         },
  { src ="https://github.com/williamboman/mason.nvim",                    name = "mason"             },
  { src ="https://github.com/williamboman/mason-lspconfig.nvim",          name = "mason-lspconfig"   },
  { src ="https://github.com/neovim/nvim-lspconfig",                     name = "nvim-lspconfig"    },
  { src ="https://github.com/stevearc/conform.nvim",                      name = "conform"           },
})

for _, name in ipairs({
  "catppuccin", "mini.nvim", "which-key", "fzf-lua", "nvim-treesitter", "gitsigns",
  "LuaSnip", "blink.cmp", "mason", "mason-lspconfig",
  "nvim-lspconfig", "conform",
}) do
  vim.cmd.packadd(name)
end

-- ── COLORSCHEME ─────────────────────────────────────────────────
require("catppuccin").setup({
  flavour                = "macchiato",
  transparent_background = false,
  show_end_of_buffer     = false,
  integrations = {
    treesitter = true,
    gitsigns   = true,
    blink_cmp  = true,
    mini       = { enabled = true, indentscope_color = "" },
    which_key  = true,
    native_lsp = {
      enabled  = true,
      underlines = {
        errors      = { "underline" },
        hints       = { "underline" },
        warnings    = { "underline" },
        information = { "underline" },
      },
    },
  },
})
vim.cmd.colorscheme("catppuccin")

-- ── STATUSLINE ──────────────────────────────────────────────────
require("mini.statusline").setup({
  use_icons        = false,
  set_vim_settings = true,
})

-- ── TABLINE ─────────────────────────────────────────────────────
require("mini.tabline").setup({
  show_icons = false,
})

-- ── WHICH-KEY ───────────────────────────────────────────────────
local wk = require("which-key")

wk.setup({
  preset = "modern",
  delay  = 300,
  icons  = { mappings = false },
})

-- Group labels (keymaps registered per phase as config grows)
wk.add({
  { "<leader>b", group = "buffer"   },
  { "<leader>c", group = "code"     },
  { "<leader>e", group = "explorer" },
  { "<leader>f", group = "find"     },
  { "<leader>g", group = "git"      },
  { "<leader>h", group = "hunk"     },
  { "<leader>s", group = "split"    },
  { "<leader>u", group = "ui"       },
  -- Surround hints (mini.surround)
  -- sa{motion}{char}  → add     e.g. saiw( → (word)    saiw" → "word"
  -- sd{char}          → delete  e.g. sd(   → word      sd"   → word
  -- sr{old}{new}      → replace e.g. sr"(  → (word)    sr('  → 'word'
  { "s", group = "surround", mode = { "n", "v" } },
})

-- ── MINI.FILES ──────────────────────────────────────────────────
-- File explorer in a floating window. h/l navigate in/out of dirs.
require("mini.files").setup({
  mappings = {
    close       = "q",
    go_in       = "l",
    go_in_plus  = "<CR>",  -- go in and close other windows
    go_out      = "h",
    go_out_plus = "H",
    reset       = "<BS>",
    show_help   = "?",
    synchronize = "=",     -- write renames/deletions to disk
  },
  windows = {
    preview       = true,
    width_focus   = 40,
    width_nofocus = 15,
    width_preview = 60,
  },
  options = {
    use_as_default_explorer = false,
  },
})

-- ── FZF-LUA ─────────────────────────────────────────────────────
-- Requires: fzf (apt install fzf), ripgrep (apt install ripgrep)
-- Optional: bat (apt install bat) for syntax-highlighted previews
require("fzf-lua").setup({
  winopts = {
    height  = 0.85,
    width   = 0.80,
    row     = 0.35,
    col     = 0.50,
    border  = "rounded",
    preview = {
      layout      = "flex",           -- vertical when narrow, horizontal when wide
      flip_columns = 120,
      scrollbar   = false,
    },
  },
  fzf_opts = {
    ["--layout"] = "reverse",
    ["--info"]   = "inline",
  },
  -- No nerd-font icons in any pane
  files   = { git_icons = false, file_icons = false },
  grep    = { git_icons = false, file_icons = false },
  buffers = { git_icons = false, file_icons = false },
  oldfiles = { include_current_session = true },
})

-- ── TREESITTER ──────────────────────────────────────────────────
-- On first launch vim.pack downloads the plugin; it lands on the runtimepath
-- only after a restart.  Guard with pcall so the config survives that first run.
local ts_ok, ts_configs = pcall(require, "nvim-treesitter.configs")

if ts_ok then
  ts_configs.setup({
    ensure_installed = {
      -- Web
      "javascript", "typescript", "tsx",
      "html", "css",
      "php", "phpdoc",
      -- SQL
      "sql",
      -- Systems
      "c", "go", "rust",
      -- Scripting / config
      "lua", "bash",
      "json", "jsonc", "yaml", "toml",
      -- Infra
      "dockerfile",
      -- Neovim internals
      "vimdoc", "query", "regex",
      -- Markdown
      "markdown", "markdown_inline",
    },
    highlight = {
      enable                            = true,
      additional_vim_regex_highlighting = false,
    },
    indent = { enable = true },
  })
else
  -- Fallback: Neovim 0.11+ built-in treesitter for whatever parsers are bundled.
  -- Full highlighting loads automatically after restarting once nvim-treesitter is on the path.
  vim.api.nvim_create_autocmd("FileType", {
    group    = vim.api.nvim_create_augroup("user_ts_builtin", { clear = true }),
    callback = function(ev) pcall(vim.treesitter.start, ev.buf) end,
  })
end

-- ── MINI.AI ─────────────────────────────────────────────────────
-- Enhanced text-objects: af/if (function), ac/ic (class), aa/ia (argument)
-- Also: ab/ib (any bracket), aq/iq (any quote), ad/id (any delimiter)
-- Treesitter-powered f/c objects are only wired up when nvim-treesitter is loaded.
local ai = require("mini.ai")
local ai_opts = { n_lines = 500, custom_textobjects = {} }
if ts_ok then
  ai_opts.custom_textobjects.f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" })
  ai_opts.custom_textobjects.c = ai.gen_spec.treesitter({ a = "@class.outer",    i = "@class.inner"    })
end
ai.setup(ai_opts)

-- ── MINI.INDENTSCOPE ────────────────────────────────────────────
-- Animated │ line that marks the current scope boundary.
require("mini.indentscope").setup({
  symbol  = "│",
  options = { try_as_border = true },
  draw    = { animation = require("mini.indentscope").gen_animation.none() },
})

-- Disable indentscope inside UI/utility buffers
vim.api.nvim_create_autocmd("FileType", {
  group   = vim.api.nvim_create_augroup("user_indentscope_disable", { clear = true }),
  pattern = { "help", "man", "qf", "lspinfo", "checkhealth", "notify", "NvimTree" },
  callback = function() vim.b.miniindentscope_disable = true end,
})

-- ── MINI.SURROUND ───────────────────────────────────────────────
-- sa{motion}{char}  add surrounding     e.g. saiw"  → "word"
-- sd{char}          delete surrounding  e.g. sd"    → word
-- sr{old}{new}      replace surrounding e.g. sr"'   → 'word'
-- sf/sF             find surrounding right/left
require("mini.surround").setup({
  mappings = {
    add            = "sa",
    delete         = "sd",
    replace        = "sr",
    find           = "sf",
    find_left      = "sF",
    highlight      = "sh",
    update_n_lines = "sn",
  },
})

-- ── GITSIGNS ────────────────────────────────────────────────────
-- Keymaps are registered buffer-local inside on_attach.
-- Navigation: ]h / [h   Hunks: <leader>h*   Git: <leader>g*
-- Text object: ih (inner hunk) in operator-pending and visual mode.
require("gitsigns").setup({
  signs = {
    add          = { text = "│" },
    change       = { text = "│" },
    delete       = { text = "_" },
    topdelete    = { text = "‾" },
    changedelete = { text = "~" },
    untracked    = { text = "┆" },
  },
  signs_staged = {
    add          = { text = "│" },
    change       = { text = "│" },
    delete       = { text = "_" },
    topdelete    = { text = "‾" },
    changedelete = { text = "~" },
  },
  signs_staged_enable     = true,
  current_line_blame      = false,
  current_line_blame_opts = {
    virt_text         = true,
    virt_text_pos     = "eol",
    delay             = 500,
    ignore_whitespace = false,
  },

  on_attach = function(bufnr)
    local gs = require("gitsigns")

    local function bmap(mode, lhs, rhs, opts)
      opts = vim.tbl_extend("force", { buffer = bufnr, silent = true }, opts or {})
      vim.keymap.set(mode, lhs, rhs, opts)
    end

    -- ── Hunk navigation ──
    -- Respects vim diff-mode (]c / [c) when in a diff window
    bmap("n", "]h", function()
      if vim.wo.diff then vim.cmd.normal({ "]c", bang = true })
      else gs.nav_hunk("next") end
    end, { desc = "Next hunk" })

    bmap("n", "[h", function()
      if vim.wo.diff then vim.cmd.normal({ "[c", bang = true })
      else gs.nav_hunk("prev") end
    end, { desc = "Prev hunk" })

    bmap("n", "]H", function() gs.nav_hunk("last")  end, { desc = "Last hunk"  })
    bmap("n", "[H", function() gs.nav_hunk("first") end, { desc = "First hunk" })

    -- ── Hunk operations ──
    bmap({ "n", "v" }, "<leader>hs", ":Gitsigns stage_hunk<cr>",  { desc = "Stage hunk"      })
    bmap({ "n", "v" }, "<leader>hr", ":Gitsigns reset_hunk<cr>",  { desc = "Reset hunk"      })
    bmap("n",          "<leader>hS", gs.stage_buffer,             { desc = "Stage buffer"    })
    bmap("n",          "<leader>hR", gs.reset_buffer,             { desc = "Reset buffer"    })
    bmap("n",          "<leader>hu", gs.undo_stage_hunk,          { desc = "Undo stage hunk" })
    bmap("n",          "<leader>hp", gs.preview_hunk,             { desc = "Preview hunk"    })
    bmap("n",          "<leader>hP", gs.preview_hunk_inline,      { desc = "Preview inline"  })

    -- ── Git info ──
    bmap("n", "<leader>gb", function() gs.blame_line({ full = true }) end,
                                                { desc = "Blame line"   })
    bmap("n", "<leader>gB", gs.toggle_current_line_blame,
                                                { desc = "Toggle blame" })
    bmap("n", "<leader>gd", gs.diffthis,        { desc = "Diff this"   })
    bmap("n", "<leader>gD", function() gs.diffthis("~") end,
                                                { desc = "Diff this ~"  })

    -- ── Text object: ih = inner hunk ──
    bmap({ "o", "x" }, "ih", ":<C-u>Gitsigns select_hunk<cr>", { desc = "Inner hunk" })
  end,
})

-- ── LAZYGIT ─────────────────────────────────────────────────────
-- Opens lazygit in a floating terminal — no Neovim plugin required.
-- Only needs the lazygit binary:
--   sudo apt install lazygit
--   go install github.com/jesseduffield/lazygit@latest
local function lazygit_open(extra_args)
  local width  = math.floor(vim.o.columns * 0.95)
  local height = math.floor(vim.o.lines   * 0.92)
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative  = "editor",
    width     = width,
    height    = height,
    row       = math.floor((vim.o.lines   - height) / 2),
    col       = math.floor((vim.o.columns - width)  / 2),
    style     = "minimal",
    border    = "rounded",
    title     = " lazygit ",
    title_pos = "center",
  })
  vim.wo[win].winblend = 0
  local cmd = "lazygit" .. (extra_args and (" " .. extra_args) or "")
  vim.fn.termopen(cmd, {
    on_exit = function()
      if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
      if vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_delete(buf, { force = true }) end
    end,
  })
  vim.cmd.startinsert()
end

-- ── LUASNIP ─────────────────────────────────────────────────────
local luasnip_ok, luasnip = pcall(require, "luasnip")
if luasnip_ok then
  luasnip.config.setup({})
  -- Load VSCode-style snippets from any packages on runtimepath.
  -- Add community snippets: clone rafamans/friendly-snippets into pack dir.
  pcall(function() require("luasnip.loaders.from_vscode").lazy_load() end)
end

-- ── BLINK.CMP ───────────────────────────────────────────────────
-- Rust fuzzy-matching binary — downloads a pre-built binary automatically.
-- Fallback if that fails: cd ~/.local/share/nvim/pack/*/opt/blink.cmp && cargo build --release
local blink_ok, blink = pcall(require, "blink.cmp")
if blink_ok then
  blink.setup({
    keymap = {
      preset        = "default",
      ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
      ["<C-e>"]     = { "hide" },
      ["<Tab>"]     = { "snippet_forward",  "fallback" },
      ["<S-Tab>"]   = { "snippet_backward", "fallback" },
      ["<C-b>"]     = { "scroll_documentation_up",   "fallback" },
      ["<C-f>"]     = { "scroll_documentation_down", "fallback" },
    },
    appearance = {
      nerd_font_variant = "normal",
    },
    sources   = { default = { "lsp", "path", "snippets", "buffer" } },
    snippets  = { preset = "luasnip" },
    signature = { enabled = true },
    completion = {
      documentation = { auto_show = true, auto_show_delay_ms = 200 },
    },
    fuzzy = { prebuilt_binaries = { download = true } },
  })
end

-- ── MASON ───────────────────────────────────────────────────────
local mason_ok = pcall(require("mason").setup, {
  ui = {
    border = "rounded",
    icons  = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" },
  },
})

-- ── LSP ─────────────────────────────────────────────────────────
-- Diagnostic config is always applied (uses only built-in vim.diagnostic).
vim.diagnostic.config({
  severity_sort    = true,
  update_in_insert = false,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "✘",
      [vim.diagnostic.severity.WARN]  = "▲",
      [vim.diagnostic.severity.HINT]  = "⚑",
      [vim.diagnostic.severity.INFO]  = "»",
    },
  },
  virtual_text = { spacing = 4, source = "if_many", prefix = "●" },
  float        = { border = "rounded", source = true },
})

-- Rounded borders on hover / signature-help (avoids deprecated vim.lsp.with)
local _hover = vim.lsp.handlers["textDocument/hover"]
vim.lsp.handlers["textDocument/hover"] = function(err, result, ctx, config)
  config = vim.tbl_extend("force", { border = "rounded" }, config or {})
  _hover(err, result, ctx, config)
end
local _sig = vim.lsp.handlers["textDocument/signatureHelp"]
vim.lsp.handlers["textDocument/signatureHelp"] = function(err, result, ctx, config)
  config = vim.tbl_extend("force", { border = "rounded" }, config or {})
  _sig(err, result, ctx, config)
end

-- Server list ──────────────────────────────────────────────────
-- nvim-lspconfig (v2+) registers vim.lsp.config entries for each server when
-- the plugin loads via packadd.  We only need to call vim.lsp.config() for
-- servers with non-default options, then vim.lsp.enable() to activate them.
local lsp_server_names = {
  "clangd", "rust_analyzer", "gopls",
  "ts_ls", "html", "cssls", "tailwindcss", "emmet_language_server", "intelephense",
  "jsonls", "yamlls", "taplo",
  "dockerls", "docker_compose_language_service",
  "sqls",
  "bashls", "lua_ls",
  "marksman",
}

-- Global capability defaults (blink.cmp if loaded, else Neovim built-in)
local capabilities = blink_ok
  and blink.get_lsp_capabilities()
  or  vim.lsp.protocol.make_client_capabilities()

vim.lsp.config("*", { capabilities = capabilities })

-- Per-server overrides (only for non-default settings)
vim.lsp.config("html", { filetypes = { "html", "templ" } })
vim.lsp.config("docker_compose_language_service", {
  filetypes = { "yaml.docker-compose", "docker-compose" },
})
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime     = { version = "LuaJIT" },
      workspace   = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
      completion  = { callSnippet = "Replace" },
      diagnostics = { globals = { "vim" } },
      telemetry   = { enable = false },
    },
  },
})

-- Activate servers (start on matching FileType; no-op if binary not yet installed)
vim.lsp.enable(lsp_server_names)

-- Mason-lspconfig installs the server binaries via :Mason
if mason_ok then
  pcall(function()
    require("mason-lspconfig").setup({
      automatic_enable = false,
      ensure_installed = lsp_server_names,
    })
  end)
end

-- LSP buffer keymaps (always registered; conform falls back gracefully if not loaded)
vim.api.nvim_create_autocmd("LspAttach", {
  group    = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local bufnr  = ev.buf

    local function bmap(mode, lhs, rhs, opts)
      opts = vim.tbl_extend("force", { buffer = bufnr, silent = true }, opts or {})
      vim.keymap.set(mode, lhs, rhs, opts)
    end

    -- ── Navigation ──
    bmap("n", "gd",    "<cmd>FzfLua lsp_definitions<cr>",    { desc = "Definition"     })
    bmap("n", "gD",    vim.lsp.buf.declaration,               { desc = "Declaration"    })
    bmap("n", "gr",    "<cmd>FzfLua lsp_references<cr>",      { desc = "References"     })
    bmap("n", "gi",    "<cmd>FzfLua lsp_implementations<cr>", { desc = "Implementation" })
    bmap("n", "gy",    "<cmd>FzfLua lsp_typedefs<cr>",        { desc = "Type def"       })
    bmap("n", "K",     vim.lsp.buf.hover,                     { desc = "Hover docs"     })
    bmap("n", "gK",    vim.lsp.buf.signature_help,            { desc = "Signature help" })
    bmap("i", "<C-k>", vim.lsp.buf.signature_help,            { desc = "Signature help" })

    -- ── Code actions ──
    bmap({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action"    })
    bmap("n",          "<leader>cr", vim.lsp.buf.rename,      { desc = "Rename symbol"  })
    bmap("n",          "<leader>cf", function()
      require("conform").format({ async = true, lsp_format = "fallback" })
    end,                                                       { desc = "Format"         })

    -- ── Diagnostics ──
    bmap("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
    bmap("n", "]d", function() vim.diagnostic.jump({ count =  1, float = true }) end,
                                                        { desc = "Next diagnostic"  })
    bmap("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end,
                                                        { desc = "Prev diagnostic"  })
    bmap("n", "]e", function()
      vim.diagnostic.jump({ count = 1,  float = true, severity = vim.diagnostic.severity.ERROR })
    end,                                                { desc = "Next error"       })
    bmap("n", "[e", function()
      vim.diagnostic.jump({ count = -1, float = true, severity = vim.diagnostic.severity.ERROR })
    end,                                                { desc = "Prev error"       })

    -- ── Codelens (only when supported) ──
    if client and client:supports_method("textDocument/codeLens") then
      bmap("n", "<leader>cl", vim.lsp.codelens.run, { desc = "Run codelens" })
      vim.lsp.codelens.enable(true, { bufnr = bufnr })
    end
  end,
})

-- ── CONFORM ─────────────────────────────────────────────────────
-- Formatters installed via :Mason / :MasonInstall
-- stylua · prettier · goimports · rustfmt · clang-format · shfmt · sqlfmt · taplo · pint
vim.g.autoformat = true

local conform_ok, conform = pcall(require, "conform")
if conform_ok then
  conform.setup({
    format_on_save = function(bufnr)
      if not vim.g.autoformat then return end
      if vim.b[bufnr].autoformat == false then return end
      return { timeout_ms = 800, lsp_format = "fallback" }
    end,
    formatters_by_ft = {
      lua             = { "stylua"             },
      javascript      = { "prettier"           },
      typescript      = { "prettier"           },
      javascriptreact = { "prettier"           },
      typescriptreact = { "prettier"           },
      html            = { "prettier"           },
      css             = { "prettier"           },
      scss            = { "prettier"           },
      json            = { "prettier"           },
      jsonc           = { "prettier"           },
      yaml            = { "prettier"           },
      markdown        = { "prettier"           },
      php             = { "pint"               },
      go              = { "goimports", "gofmt" },
      rust            = { "rustfmt"            },
      c               = { "clang_format"       },
      bash            = { "shfmt"              },
      sh              = { "shfmt"              },
      sql             = { "sqlfmt"             },
      toml            = { "taplo"              },
    },
  })
end

-- ── MINI.NOTIFY ─────────────────────────────────────────────────
-- Replaces vim.notify with floating notifications (no nerd-font icons needed).
require("mini.notify").setup({
  window = { config = { border = "rounded" } },
  lsp_progress = { enable = true },
})
vim.notify = require("mini.notify").make_notify()

-- ── MINI.COMMENT ────────────────────────────────────────────────
-- gcc         → toggle comment on line
-- gc{motion}  → toggle comment on motion  (e.g. gcip = comment paragraph)
-- gc          → toggle comment on visual selection
require("mini.comment").setup({})

-- ── MINI.PAIRS ──────────────────────────────────────────────────
-- Auto-closes (, [, {, ', ", ` and handles <BS>/<CR> inside pairs.
require("mini.pairs").setup({
  modes = { insert = true, command = false, terminal = false },
})

-- ── MINI.BUFREMOVE ──────────────────────────────────────────────
-- Smarter buffer deletion: preserves window layout instead of
-- collapsing to a split when you delete the active buffer.
require("mini.bufremove").setup()

-- ── TERMINAL ────────────────────────────────────────────────────
-- Single floating terminal that persists across toggles.
-- <leader>t     → toggle
-- <Esc><Esc>    → exit terminal mode (back to normal)
-- <C-hjkl>      → navigate to adjacent window while in terminal
local _term = { buf = nil, win = nil }

local function term_open()
  local width  = math.floor(vim.o.columns * 0.85)
  local height = math.floor(vim.o.lines   * 0.80)

  if not (_term.buf and vim.api.nvim_buf_is_valid(_term.buf)) then
    _term.buf = vim.api.nvim_create_buf(false, true)
  end

  _term.win = vim.api.nvim_open_win(_term.buf, true, {
    relative  = "editor",
    width     = width,
    height    = height,
    row       = math.floor((vim.o.lines   - height) / 2),
    col       = math.floor((vim.o.columns - width)  / 2),
    style     = "minimal",
    border    = "rounded",
    title     = " Terminal ",
    title_pos = "center",
  })
  vim.wo[_term.win].winblend = 0

  if vim.bo[_term.buf].buftype ~= "terminal" then
    vim.fn.termopen(vim.env.SHELL or "bash", {
      on_exit = function()
        -- Clean up when the shell process exits
        if _term.buf and vim.api.nvim_buf_is_valid(_term.buf) then
          vim.api.nvim_buf_delete(_term.buf, { force = true })
        end
        _term.buf = nil
        _term.win = nil
      end,
    })
  end

  vim.cmd.startinsert()
end

local function term_toggle()
  if _term.win and vim.api.nvim_win_is_valid(_term.win) then
    vim.api.nvim_win_hide(_term.win)
    _term.win = nil
  else
    term_open()
  end
end

-- Terminal-mode keymaps (use vim.keymap.set directly; `map` not yet defined)
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>",       { desc = "Exit terminal mode"  })
vim.keymap.set("t", "<C-h>",      "<cmd>wincmd h<cr>",  { desc = "Window left"         })
vim.keymap.set("t", "<C-j>",      "<cmd>wincmd j<cr>",  { desc = "Window down"         })
vim.keymap.set("t", "<C-k>",      "<cmd>wincmd k<cr>",  { desc = "Window up"           })
vim.keymap.set("t", "<C-l>",      "<cmd>wincmd l<cr>",  { desc = "Window right"        })

-- ── KEYMAPS ─────────────────────────────────────────────────────
local function map(mode, lhs, rhs, opts)
  vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", { silent = true }, opts or {}))
end

-- Terminal
map("n", "<leader>t", term_toggle, { desc = "Toggle terminal" })

-- Explorer (mini.files)
map("n", "<leader>ee", function()
  -- Open at current file; if no file, open cwd
  local path = vim.api.nvim_buf_get_name(0)
  path = path ~= "" and path or vim.uv.cwd()
  require("mini.files").open(path, true)
end, { desc = "Explorer (current file)" })

map("n", "<leader>ew", function()
  require("mini.files").open(vim.uv.cwd(), true)
end, { desc = "Explorer (cwd)" })

-- Find (fzf-lua)
local fzf = require("fzf-lua")

map("n", "<leader>ff", fzf.files,                       { desc = "Find files"            })
map("n", "<leader>fg", fzf.live_grep,                   { desc = "Live grep"             })
map("n", "<leader>fb", fzf.buffers,                     { desc = "Buffers"               })
map("n", "<leader>fr", fzf.oldfiles,                    { desc = "Recent files"          })
map("n", "<leader>fw", fzf.grep_cword,                  { desc = "Grep word under cursor"})
map("n", "<leader>f/", fzf.grep_curbuf,                 { desc = "Grep current buffer"   })
map("n", "<leader>fh", fzf.help_tags,                   { desc = "Help tags"             })
map("n", "<leader>fk", fzf.keymaps,                     { desc = "Keymaps"               })
map("n", "<leader>fc", fzf.commands,                    { desc = "Commands"              })
map("n", "<leader>fd", fzf.diagnostics_document,        { desc = "Document diagnostics"  })
map("n", "<leader>fD", fzf.diagnostics_workspace,       { desc = "Workspace diagnostics" })
map("n", "<leader>fo", fzf.lsp_document_symbols,        { desc = "Buffer outline"        })
map("n", "<leader>fO", fzf.lsp_workspace_symbols,       { desc = "Workspace symbols"     })

-- Also wire up gr/gs for visual grep
map("v", "<leader>fg", fzf.grep_visual,                 { desc = "Grep selection"        })

-- Git (lazygit)
map("n", "<leader>gg", function() lazygit_open() end, { desc = "LazyGit" })
map("n", "<leader>gf", function()
  local file = vim.api.nvim_buf_get_name(0)
  if file ~= "" then lazygit_open("-f " .. vim.fn.shellescape(file))
  else lazygit_open() end
end, { desc = "LazyGit (current file)" })

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Window left"  })
map("n", "<C-j>", "<C-w>j", { desc = "Window down"  })
map("n", "<C-k>", "<C-w>k", { desc = "Window up"    })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- Window resize
map("n", "<C-Up>",    "<cmd>resize +2<cr>",          { desc = "Resize: taller"   })
map("n", "<C-Down>",  "<cmd>resize -2<cr>",          { desc = "Resize: shorter"  })
map("n", "<C-Left>",  "<cmd>vertical resize -2<cr>", { desc = "Resize: narrower" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Resize: wider"    })

-- Splits
map("n", "<leader>sv", "<cmd>vsplit<cr>", { desc = "Vertical split"   })
map("n", "<leader>sh", "<cmd>split<cr>",  { desc = "Horizontal split" })
map("n", "<leader>sc", "<cmd>close<cr>",  { desc = "Close split"      })
map("n", "<leader>se", "<C-w>=",          { desc = "Equal splits"     })

-- Buffer navigation
map("n", "<S-h>",      "<cmd>bprev<cr>",                    { desc = "Prev buffer"          })
map("n", "<S-l>",      "<cmd>bnext<cr>",                    { desc = "Next buffer"          })
map("n", "<leader>bd", function()
  require("mini.bufremove").delete(0, false)                -- preserves window layout
end,                                                         { desc = "Delete buffer"        })
map("n", "<leader>bD", function()
  require("mini.bufremove").delete(0, true)
end,                                                         { desc = "Force delete buffer"  })
map("n", "<leader>bo", "<cmd>%bdelete|edit#|bdelete#<cr>",  { desc = "Delete other buffers" })

-- Editing quality-of-life
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear highlight"        })
map("n", "U",     "<C-r>",               { desc = "Redo"                   })
map("v", "<",     "<gv",                 { desc = "Indent left"            })
map("v", ">",     ">gv",                 { desc = "Indent right"           })
map("n", "J",     "mzJ`z",              { desc = "Join lines (keep cursor)"})
map("n", "<C-d>", "<C-d>zz",            { desc = "Half-page down"         })
map("n", "<C-u>", "<C-u>zz",            { desc = "Half-page up"           })
map("n", "n",     "nzzzv",              { desc = "Next match (centered)"  })
map("n", "N",     "Nzzzv",              { desc = "Prev match (centered)"  })

-- Move selected lines up / down
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move lines down" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move lines up"   })

-- UI toggles
map("n", "<leader>un", function()
  vim.opt.number         = not vim.o.number
  vim.opt.relativenumber = not vim.o.relativenumber
end, { desc = "Toggle line numbers" })

map("n", "<leader>ur", function()
  vim.opt.relativenumber = not vim.o.relativenumber
end, { desc = "Toggle relative numbers" })

map("n", "<leader>uw", function()
  vim.opt.wrap = not vim.o.wrap
end, { desc = "Toggle wrap" })

map("n", "<leader>uc", function()
  vim.opt.cursorline = not vim.o.cursorline
end, { desc = "Toggle cursorline" })

map("n", "<leader>ui", function()
  vim.b.miniindentscope_disable = not vim.b.miniindentscope_disable
end, { desc = "Toggle indent scope" })

map("n", "<leader>uf", function()
  vim.g.autoformat = not vim.g.autoformat
  vim.notify("Autoformat " .. (vim.g.autoformat and "on" or "off"))
end, { desc = "Toggle autoformat" })

map("n", "<leader>uF", function()
  vim.b.autoformat = vim.b.autoformat ~= false   -- per-buffer override
  vim.notify("Buffer autoformat " .. (vim.b.autoformat and "on" or "off"))
end, { desc = "Toggle autoformat (buffer)" })

-- ── AUTOCMDS ────────────────────────────────────────────────────
local function augroup(name)
  return vim.api.nvim_create_augroup("user_" .. name, { clear = true })
end

-- Flash yanked region
vim.api.nvim_create_autocmd("TextYankPost", {
  group    = augroup("yank_highlight"),
  callback = function()
    vim.highlight.on_yank({ higroup = "Visual", timeout = 150 })
  end,
})

-- Restore cursor position on file open
vim.api.nvim_create_autocmd("BufReadPost", {
  group    = augroup("restore_cursor"),
  callback = function(ev)
    local mark    = vim.api.nvim_buf_get_mark(ev.buf, '"')
    local nlines  = vim.api.nvim_buf_line_count(ev.buf)
    if mark[1] > 0 and mark[1] <= nlines then
      vim.api.nvim_win_set_cursor(0, mark)
    end
  end,
})

-- Equalise splits when Neovim is resized
vim.api.nvim_create_autocmd("VimResized", {
  group    = augroup("resize_splits"),
  callback = function() vim.cmd.wincmd("=") end,
})

-- Trim trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
  group    = augroup("trim_whitespace"),
  callback = function()
    local view = vim.fn.winsaveview()
    vim.cmd([[keeppatterns %s/\s\+$//e]])
    vim.fn.winrestview(view)
  end,
})

-- Close utility windows with q
vim.api.nvim_create_autocmd("FileType", {
  group   = augroup("close_with_q"),
  pattern = { "help", "lspinfo", "man", "notify", "qf", "checkhealth" },
  callback = function(ev)
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = ev.buf, silent = true })
  end,
})
