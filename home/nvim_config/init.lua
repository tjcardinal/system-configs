--
-- Leader keys
-- NOTE: Leader keys must be set before plugins (otherwise wrong Leader will be used)
--
vim.g.mapleader = " "
vim.g.maplocalleader = " "

--
-- Install mini.nvim
-- NOTE: If using nix, it will already be installed
--
local path_package = nil
if not vim.g.is_nix then
	-- Clone 'mini.nvim' manually in a way that it gets managed by 'mini.deps'
	path_package = vim.fn.stdpath("data") .. "/site/"
	local mini_path = path_package .. "pack/deps/start/mini.nvim"
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
end

require("mini.deps").setup({ path = { package = path_package } })

--
-- Helper functions
--
local function nix_or(a, b)
	if vim.g.is_nix then
		return a
	else
		return b
	end
end

local function add(spec, opts)
	if not vim.g.is_nix then
		MiniDeps.add(spec, opts)
	end
end

-- NOTE: Generally: now => used to draw the initial screen, later => otherwise
local now, later = MiniDeps.now, MiniDeps.later

--
-- Options
--
now(function()
	vim.opt.breakindent = true
	vim.opt.linebreak = true

	vim.opt.cursorcolumn = true
	vim.opt.cursorline = true

	vim.opt.ignorecase = true
	vim.opt.smartcase = true

	vim.opt.list = true
	vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

	vim.opt.number = true
	vim.opt.relativenumber = true

	vim.opt.splitbelow = true
	vim.opt.splitright = true

	vim.opt.inccommand = "split"
	vim.opt.mouse = "a"
	vim.opt.scrolloff = 10
	vim.opt.showmode = false
	vim.opt.undofile = true
end)

-- NOTE: Do this later as it can increase startup time
later(function()
	vim.opt.clipboard = "unnamedplus"
end)

--
-- General keymaps
--
later(function()
	vim.keymap.set("i", "jk", "<Esc>", { desc = "Exit insert mode" })

	vim.keymap.set("n", "j", "gj", { desc = "Move down within a wrapped line" })
	vim.keymap.set("n", "k", "gk", { desc = "Move up within a wrapped line" })

	vim.keymap.set("n", "<Esc>", "<Cmd>nohlsearch<CR>", { desc = "Clear search Highlight" })

	vim.keymap.set("n", "<Leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

	vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

	vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
	vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
	vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
	vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

	vim.api.nvim_create_autocmd("TextYankPost", {
		desc = "Highlight when yanking (copying) text",
		group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
		callback = function()
			vim.highlight.on_yank()
		end,
	})
end)

--
-- Display plugins
--
now(function()
	add("catppuccin/nvim")
	vim.cmd.colorscheme("catppuccin-macchiato")

	require("mini.notify").setup()
	vim.notify = require("mini.notify").make_notify()

	require("mini.icons").setup({ style = "ascii" })
	require("mini.indentscope").setup({
		draw = { animation = require("mini.indentscope").gen_animation.none() },
		options = { indent_at_cursor = false },
	})
	-- ERROR: Why can't I use true for statusline w/ ascii icons? It causes weird symbols
	require("mini.statusline").setup({ use_icons = false })

	add("tpope/vim-sleuth")
end)

--
-- Functional plugins
--
later(function()
	require("mini.ai").setup()
	require("mini.comment").setup()
	require("mini.completion").setup()
	require("mini.cursorword").setup()
	-- TODO: Setup diff and git
	require("mini.diff").setup()
	require("mini.extra").setup()
	require("mini.git").setup()
	require("mini.pairs").setup()
	require("mini.surround").setup()
end)

later(function()
	local miniclue = require("mini.clue")
	miniclue.setup({
		triggers = {
			-- Leader triggers
			{ mode = "n", keys = "<Leader>" },
			{ mode = "x", keys = "<Leader>" },

			-- Built-in completion
			{ mode = "i", keys = "<C-x>" },

			-- `g` key
			{ mode = "n", keys = "g" },
			{ mode = "x", keys = "g" },

			-- Marks
			{ mode = "n", keys = "'" },
			{ mode = "n", keys = "`" },
			{ mode = "x", keys = "'" },
			{ mode = "x", keys = "`" },

			-- Registers
			{ mode = "n", keys = '"' },
			{ mode = "x", keys = '"' },
			{ mode = "i", keys = "<C-r>" },
			{ mode = "c", keys = "<C-r>" },

			-- Window commands
			{ mode = "n", keys = "<C-w>" },

			-- `z` key
			{ mode = "n", keys = "z" },
			{ mode = "x", keys = "z" },
			{ mode = "n", keys = "d" },
		},

		clues = {
			-- TODO: Remove unused clue groups
			{ mode = "n", keys = "<Leader>c", desc = "[C]ode" },
			{ mode = "x", keys = "<Leader>c", desc = "[C]ode" },
			{ mode = "n", keys = "<Leader>d", desc = "[D]ocument" },
			{ mode = "n", keys = "<Leader>h", desc = "Git [H]unk" },
			{ mode = "v", keys = "<Leader>h", desc = "Git [H]unk" },
			{ mode = "n", keys = "<Leader>r", desc = "[R]ename" },
			{ mode = "n", keys = "<Leader>s", desc = "[S]earch" },
			{ mode = "n", keys = "<Leader>t", desc = "[T]oggle" },
			{ mode = "n", keys = "<Leader>w", desc = "[W]orkspace" },

			miniclue.gen_clues.builtin_completion(),
			miniclue.gen_clues.g(),
			miniclue.gen_clues.marks(),
			miniclue.gen_clues.registers(),
			miniclue.gen_clues.windows(),
			miniclue.gen_clues.z(),
		},
	})
end)

later(function()
	require("mini.files").setup()
	vim.keymap.set("n", "\\", MiniFiles.open, { desc = "Open file navigator" })
end)

later(function()
	require("mini.pick").setup()
	local mp = MiniPick.builtin
	local me = MiniExtra.pickers

	vim.keymap.set("n", "<Leader>/", me.buf_lines, { desc = "Search [/] Fuzzily in current buffer" })
	vim.keymap.set("n", "<Leader><Leader>", mp.buffers, { desc = "[ ] Find existing buffers" })
	vim.keymap.set("n", "<Leader>sd", me.diagnostic, { desc = "[S]earch [D]iagnostics" })
	vim.keymap.set("n", "<Leader>sf", mp.files, { desc = "[S]earch [F]iles" })
	vim.keymap.set("n", "<Leader>sg", mp.grep_live, { desc = "[S]earch by [G]rep" })
	vim.keymap.set("n", "<Leader>sh", mp.help, { desc = "[S]earch [H]elp" })
	vim.keymap.set("n", "<Leader>sk", me.keymaps, { desc = "[S]earch [K]eymaps" })
	vim.keymap.set("n", "<Leader>so", me.oldfiles, { desc = "[S]earch [O]ldfiles" })
	vim.keymap.set("n", "<Leader>sr", mp.resume, { desc = "[S]earch [R]esume" })
	vim.keymap.set("n", "<Leader>sw", function()
		mp.grep({ pattern = vim.fn.expand("<cword>") })
	end, { desc = "[S]earch [W]ord" })
end)

later(function()
	add("stevearc/conform.nvim")
	require("conform").setup({
		formatters_by_ft = {
			c = { "clang-format" },
			cpp = { "clang-format" },
			lua = { "stylua" },
			nix = { "nixfmt" },
			python = { "ruff_organize_imports", "ruff_fix", "ruff_format" },
			rust = { "rustfmt" },
		},
		format_on_save = {
			lsp_format = "fallback",
		},
	})
end)

later(function()
	add("mfussenegger/nvim-lint")
	require("lint").linters_by_ft = {
		c = { "clangtidy" },
		cpp = { "clangtidy" },
		nix = { "nix" },
		python = { "ruff" },
		rust = { "clippy" },
	}
	vim.api.nvim_create_autocmd("BufWritePost", {
		desc = "Run lint after Buffer write",
		group = vim.api.nvim_create_augroup("lint", { clear = true }),
		callback = function()
			require("lint").try_lint()
		end,
	})
end)

-- NOTE: Load right away so that lsp client can attach when starting nvim with a file
now(function()
	add("folke/lazydev.nvim")
	require("lazydev").setup({
		library = { "${3rd}/luv/library" },
	})

	add("neovim/nvim-lspconfig")
	require("lspconfig").rust_analyzer.setup({})
	require("lspconfig").lua_ls.setup({})

	vim.api.nvim_create_autocmd("LspAttach", {
		desc = "Setup lsp on attach",
		group = vim.api.nvim_create_augroup("lsp", { clear = true }),
		callback = function(event)
			local keymaplsp = function(mode, key, func, desc)
				vim.keymap.set(mode, key, func, { buffer = event.buf, desc = "[L]SP: " .. desc })
			end

			keymaplsp("n", "<Leader>rn", vim.lsp.buf.rename, "[R]e[N]ame")
			keymaplsp("n", "<Leader>ca", vim.lsp.buf.code_action, "[C]ode [A]cton")
			keymaplsp("n", "<Leader>gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

			keymaplsp("n", "<Leader>D", "<Cmd>Pick lsp scope='type_definition'<CR>", "Type [D]efinition")
			keymaplsp("n", "<Leader>ds", "<Cmd>Pick lsp scope='document_symbol'<CR>", "[D]ocument [S]ymbols")
			keymaplsp("n", "<Leader>ws", "<Cmd>Pick lsp scope='workspace_symbol'<CR>", "[W]orkspace [S]ymbols")

			keymaplsp("n", "gD", "<Cmd>Pick lsp scope='declaration'<CR>", "[G]oto [D]eclaration")
			keymaplsp("n", "gI", "<Cmd>Pick lsp scope='implementation'<CR>", "[G]oto [I]mplementation")
			keymaplsp("n", "gd", "<Cmd>Pick lsp scope='definition'<CR>", "[G]oto [D]efinition")
			keymaplsp("n", "gr", "<Cmd>Pick lsp scope='references'<CR>", "[G]oto [R]eferences")

			local client = vim.lsp.get_client_by_id(event.data.client_id)
			if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
				keymaplsp("n", "<Leader>th", function()
					vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
				end, "[T]oggle Inlay [H]ints")
			end
		end,
	})
end)

later(function()
	add({
		source = "nvim-treesitter/nvim-treesitter",
		hooks = {
			post_checkout = function()
				vim.cmd("TSUpdate")
			end,
		},
	})
	---@diagnostic disable-next-line: missing-fields
	require("nvim-treesitter.configs").setup({
		ensure_installed = nix_or(nil, { "c", "cpp", "lua", "nix", "python", "rust", "vimdoc" }),
		highlight = { enable = true },
		indent = { enable = true },
	})
end)

-- vim: ts=2 sts=2 sw=2
