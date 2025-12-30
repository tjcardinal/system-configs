--- Leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = " "

--- Bootstrap mini.nvim
local path_package = vim.fn.stdpath("data") .. "/site"
local mini_path = path_package .. "/pack/deps/start/mini.nvim"
if not vim.loop.fs_stat(mini_path) then
	vim.cmd('echo "Installing `mini.nvim`" | redraw')
	local clone_cmd = {
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/nvim-mini/mini.nvim",
		mini_path,
	}
	vim.fn.system(clone_cmd)
	vim.cmd("packadd mini.nvim | helptags ALL")
	vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

--- Helpers
local function keymap(mode, lhs, rhs, desc)
	vim.keymap.set(mode, lhs, rhs, { desc = desc })
end

local function setup(modname, opts)
	require(modname).setup(opts)
end

setup("mini.deps")
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

--- Options. Executed now to show correct appearance on startup
now(function()
	vim.o.breakindent = true
	vim.o.linebreak = true

	vim.o.cursorcolumn = true
	vim.o.cursorline = true

	vim.o.ignorecase = true
	vim.o.smartcase = true

	vim.o.splitbelow = true
	vim.o.splitright = true

	vim.o.inccommand = "split"
	vim.o.list = true
	vim.o.mouse = "a"
	vim.o.number = true
	vim.o.scrolloff = 3
	vim.o.showmode = false
	vim.o.undofile = true

	vim.diagnostic.config({ virtual_text = true })
end)

--- General Keymaps
later(function()
	keymap("n", "j", "gj", "Move down within a wrapped line")
	keymap("n", "k", "gk", "Move up within a wrapped line")

	keymap("n", "<C-h>", "<C-w><C-h>", "Move focus to the left window")
	keymap("n", "<C-l>", "<C-w><C-l>", "Move focus to the right window")
	keymap("n", "<C-j>", "<C-w><C-j>", "Move focus to the lower window")
	keymap("n", "<C-k>", "<C-w><C-k>", "Move focus to the upper window")

	keymap({ "n", "v" }, "<Leader>y", '"+y', "Copy to system clipboard")
	keymap({ "n", "v" }, "<Leader>p", '"+p', "Paste from system clipboard")

	keymap("i", "jk", "<ESC>", "Exit insert mode")
	keymap("n", "<ESC>", "<Cmd>nohlsearch<CR>", "Clear search highlight")
	keymap("n", "<Leader>d", vim.diagnostic.open_float, "Open [D]iagnostic floating window")
	keymap("n", "<Leader>q", vim.diagnostic.setloclist, "Open diagnostic [Q]uickfix list")
	keymap("t", "<ESC><ESC>", "<C-\\><C-n>", "Exit terminal mode")
end)

--- General Autocommands
later(function()
	vim.api.nvim_create_autocmd("TextYankPost", {
		desc = "Highlight when yanking text",
		group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
		callback = function()
			vim.highlight.on_yank()
		end,
	})
end)

--- Appearance Plugins. Executed now to show correct appearance on startup
now(function()
	setup("mini.notify")
	vim.nofify = MiniNotify.make_notify()

	setup("mini.indentscope", {
		draw = { animation = require("mini.indentscope").gen_animation.none() },
		options = { try_as_border = true },
	})

	setup("mini.cursorword")
	setup("mini.icons")
	setup("mini.statusline") -- Depends on mini.icons

	add("mawkler/hml.nvim")
	setup("hml")

	add("tpope/vim-sleuth")
end)

--- Misc Small Plugins
later(function()
	setup("mini.ai")
	setup("mini.bracketed")
	setup("mini.comment")
	setup("mini.completion")
	setup("mini.extra")
	setup("mini.jump2d")
	setup("mini.surround")

	setup("mini.files")
	keymap("n", "\\", MiniFiles.open, "Open file navigator")

	add("folke/which-key.nvim")
	require("which-key")
end)

--- Picker
later(function()
	setup("mini.pick") -- Depends on mini.icons and mini.extra
	local mp = MiniPick.builtin
	local me = MiniExtra.pickers

	keymap("n", "<Leader>/", me.buf_lines, "[/] Search fuzzily in current buffer")
	keymap("n", "<Leader><Leader>", mp.buffers, "[ ] Search existing buffers")
	keymap("n", "<Leader>s'", me.marks, "[S]earch ['] (Marks)")
	keymap("n", '<Leader>s"', me.registers, '[S]earch ["] (Registers)')
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

--- Mason. Executed now to set tool paths needed on startup
now(function()
	add("mason-org/mason.nvim")
	setup("mason")
end)

--- LSP. Executed now to load lsp when starting neovim with a file
now(function()
	add("folke/lazydev.nvim")
	setup("lazydev", {
		library = { "${3rd}/luv/library" },
	})

	add("neovim/nvim-lspconfig")
	vim.lsp.enable("basedpyright")
	vim.lsp.enable("ruff")
	vim.lsp.enable("rust_analyzer")
	vim.lsp.enable("lua_ls")

	vim.api.nvim_create_autocmd("LspAttach", {
		desc = "Setup lsp on attach",
		group = vim.api.nvim_create_augroup("lsp", { clear = true }),
		callback = function()
			print("TODO: LSP specific keybinds, capabilities, ...")
		end,
	})
end)

--- Treesitter
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

---
---
--- NEED TO REVIEW THINGS BELOW. TRY AND MINIMIZE
---
---

--- Formatter
later(function()
	add("stevearc/conform.nvim")
	setup("conform", {
		formatters_by_ft = {
			lua = { "stylua" },
			nix = { "nixfmt" },
			python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
			rust = { "rustfmt" },
			fennel = { "fnlfmt" },
		},
		format_on_save = { lsp_format = "fallback" },
	})
end)

--- Linter
later(function()
	add("mfussenegger/nvim-lint")
	require("lint").linters_by_ft = {
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

-- vim: ts=2 sts=2 sw=2
