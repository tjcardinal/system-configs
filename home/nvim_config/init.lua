---
--- Leader keys
---
vim.g.mapleader = " "
vim.g.maplocalleader = " "

---
--- Bootstrap mini.nvim
---
local path_package = vim.fn.stdpath("data") .. "/site"
local mini_path = path_package .. "/pack/deps/start/mini.nvim"
if not vim.loop.fs_stat(mini_path) then
	vim.cmd('echo "Installing `mini.nvim`" | redraw')
	local clone_cmd = {
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/echasnovski/mini.nvim",
		mini_path,
	}
	vim.fn.system(clone_cmd)
	vim.cmd("packadd mini.nvim | helptags ALL")
	vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

---
--- Helpers
---
local function keymap(mode, lhs, rhs, desc)
	vim.keymap.set(mode, lhs, rhs, { desc = desc })
end

local function setup(modname, opts)
	require(modname).setup(opts)
end

setup("mini.deps")
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

---
--- Options
---
now(function()
	-- Executed now to show correct appearance on startup
	vim.o.breakindent = true
	vim.o.linebreak = true

	vim.o.cursorcolumn = true
	vim.o.cursorline = true

	vim.o.ignorecase = true
	vim.o.smartcase = true

	vim.o.list = true
	vim.o.listchars = "tab:» ,trail:·,nbsp:␣"

	vim.o.splitbelow = true
	vim.o.splitright = true

	vim.o.inccommand = "split"
	vim.o.mouse = "a"
	vim.o.number = true
	vim.o.scrolloff = 3
	vim.o.showmode = false
	vim.o.undofile = true

	vim.diagnostic.config({ virtual_text = true })
end)

---
--- Keymaps
---
later(function()
	keymap("i", "jk", "<ESC>", "Exit insert mode")

	keymap("n", "j", "gj", "Move down within a wrapped line")
	keymap("n", "k", "gk", "Move up within a wrapped line")

	keymap("n", "<ESC>", "<Cmd>nohlsearch<CR>", "Clear search highlight")
	keymap("n", "<Leader>q", vim.diagnostic.setloclist, "Open diagnostic [Q)uickfix list")
	keymap("t", "<ESC><ESC>", "<C-\\><C-n>", "Exit terminal mode")

	keymap("n", "<C-h>", "<C-w><C-h>", "Move focus to the left window")
	keymap("n", "<C-l>", "<C-w><C-l>", "Move focus to the right window")
	keymap("n", "<C-j>", "<C-w><C-j>", "Move focus to the lower window")
	keymap("n", "<C-k>", "<C-w><C-k>", "Move focus to the upper window")

	keymap("n", "<Leader>y", '"+y', "Copy to system clipboard")
	keymap("n", "<Leader>p", '"+p', "Paste from system clipboard")
end)

---
--- Autocommands
---
later(function()
	vim.api.nvim_create_autocmd("TextYankPost", {
		desc = "Highlight when yanking text",
		group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
		callback = function()
			vim.highlight.on_yank()
		end,
	})
end)

---
--- Appearance Plugins
---
now(function()
	-- Executed now to show correct appearance on startup
	add("catppuccin/nvim")
	vim.cmd.colorscheme("catppuccin-mocha")

	setup("mini.notify")
	vim.notify = require("mini.notify").make_notify()

	setup("mini.cursorword")
	setup("mini.icons")
	setup("mini.statusline")

	setup("mini.indentscope", {
		draw = { animation = require("mini.indentscope").gen_animation.none() },
		options = { try_as_border = true },
	})

	add("tpope/vim-sleuth")

	add("mawkler/hml.nvim")
	setup("hml")

	add("cksidharthan/mentor.nvim")
	setup("mentor")
end)

---
--- Text Editing Plugins
---

-- General
later(function()
	setup("mini.ai")
	setup("mini.comment")
	setup("mini.completion")
	setup("mini.extra")
	setup("mini.misc")
	setup("mini.surround")
end)

-- Formatter
later(function()
	add("stevearc/conform.nvim")
	setup("conform", {
		formatters_by_ft = {
			lua = { "stylua" },
			nix = { "nixfmt" },
			python = { "ruff_organize_imports", "ruff_fix", "ruff_format" },
			rust = { "rustfmt" },
			fennel = { "fnlfmt" },
		},
		format_on_save = { lsp_format = "fallback" },
	})
end)

-- Hardtime
later(function()
	add("m4xshen/hardtime.nvim")
	setup("hardtime")
end)

-- Linter
later(function()
	add("mfussenegger/nvim-lint")
	require("lint").linters_by_ft = {
		c = { "clangtidy" },
		cpp = { "clangtidy" },
		nix = { "nix" },
		python = { "ruff" },
		rust = { "clippy" },
		fennel = { "fennel" },
	}

	vim.api.nvim_create_autocmd("BufWritePost", {
		desc = "Run lint after Buffer write",
		group = vim.api.nvim_create_augroup("lint", { clear = true }),
		callback = function()
			require("lint").try_lint()
		end,
	})
end)

-- LSP
now(function()
	-- Executed now to load lsp when starting neovim with a file
	add("folke/lazydev.nvim")
	setup("lazydev", {
		library = { "${3rd}/luv/library" },
	})

	add("neovim/nvim-lspconfig")
	require("lspconfig").rust_analyzer.setup({})
	require("lspconfig").lua_ls.setup({})
	require("lspconfig").ruff.setup({})

	vim.api.nvim_create_autocmd("LspAttach", {
		desc = "Setup lsp on attach",
		group = vim.api.nvim_create_augroup("lsp", { clear = true }),
		callback = function()
			print("TODO")
		end,
	})
end)

-- Treesitter
later(function()
	add({
		source = "nvim-treesitter/nvim-treesitter",
		hooks = {
			post_checkout = function()
				vim.cmd("TSUpdate")
			end,
		},
	})

	setup("nvim-treesitter.configs", {
		ensure_installed = {
			"bash",
			"c",
			"cpp",
			"diff",
			"fennel",
			"git_config",
			"git_rebase",
			"gitattributes",
			"gitcommit",
			"gitignore",
			"haskell",
			"json",
			"lua",
			"make",
			"nix",
			"python",
			"rust",
			"toml",
			"vim",
			"vimdoc",
		},
		highlight = { enable = true },
		indent = { enable = true },
	})
end)

now(function()
	-- Executed now to load parinfer when starting neovim with a file
	add("gpanders/nvim-parinfer")
end)
---
--- Workflow Plugins
---

-- File manager
later(function()
	setup("mini.files")
	keymap("n", "\\", MiniFiles.open, "Open file navigator")
end)

-- Keybinding hints
later(function()
	add("folke/which-key.nvim")
	require("which-key")
end)

-- Mason
later(function()
	add("mason-org/mason.nvim")
	setup("mason")

	add("WhoIsSethDaniel/mason-tool-installer.nvim")
	setup("mason-tool-installer", {
		ensure_installed = {
			"stylua",
			"lua-language-server",
			"ruff",
		},
	})
end)

-- Picker
later(function()
	setup("mini.pick")
	local mp = MiniPick.builtin
	local me = MiniExtra.pickers

	keymap("n", "<Leader>/", me.buf_lines, "[/] Search fuzzily in current buffer")
	keymap("n", "<Leader><Leader>", mp.buffers, "[ ] Search existing buffers")
	keymap("n", "<Leader>sd", me.diagnostic, "[S]earch [D]iagnostics")
	keymap("n", "<Leader>sf", mp.files, "[S]earch [F]iles")
	keymap("n", "<Leader>sg", mp.grep_live, "[S]earch by [G]rep")
	keymap("n", "<Leader>sh", mp.help, "[S]earch [H]elp")
	keymap("n", "<Leader>sk", me.keymaps, "[S]earch [K]eymaps")
	keymap("n", "<Leader>so", me.oldfiles, "[S]earch [O]ldfiles")
	keymap("n", "<Leader>sr", mp.resume, "[S]earch [R]esume")
	keymap("n", "<Leader>sw", function()
		mp.grep({ pattern = vim.fn.expand("<cword>") })
	end, "[S]earch [W]ord")
end)

-- vim: ts=2 sts=2 sw=2
