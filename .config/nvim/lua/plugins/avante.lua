-- This is a new AI plugin I'm playing with

-- Place the plugin window depending on the aspect ration
local width = vim.o.columns
local height = vim.o.lines
local window_position = (width / height) > 1.5 and 'right' or 'top' -- 'bottom'

-- Configuration for the plugin
return {
  'yetone/avante.nvim',
  event = 'VeryLazy',
  lazy = false,
  version = false, -- set this if you want to always pull the latest change

  opts = {
    -- add any opts here
    provider = 'copilot', -- 'openai',
    auto_suggestions_provider = 'copilot',
    openai = {
      model = 'gpt-4o',
    },
    claude = {
      model = 'claude-3-5-sonnet-20241022',
    },

    behaviour = {
      auto_suggestions = false,
    },

    hints = {
      enabled = false,
    },
    windows = {
      width = 40,
      position = window_position,
    },
  },

  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  build = 'make',

  -- Required plugins to work
  dependencies = {
    'stevearc/dressing.nvim',
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',

    --- The below dependencies are optional,
    'hrsh7th/nvim-cmp', -- autocompletion for avante commands and mentions
    'nvim-tree/nvim-web-devicons', -- or echasnovski/mini.icons

    -- [optional] for providers='copilot'
    -- 'zbirenbaum/copilot.lua',
  },
}
