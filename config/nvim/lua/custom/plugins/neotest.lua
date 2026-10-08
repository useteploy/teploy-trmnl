-- Neotest - Run tests directly in Neovim
return {
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'nvim-neotest/neotest-python',
      'nvim-neotest/neotest-jest',
      'nvim-neotest/neotest-go',
      'rouge8/neotest-rust',
    },
    keys = {
      { '<leader>tr', function() require('neotest').run.run(vim.fn.expand '%:p') end, desc = '[T]est [R]un' },
      { '<leader>tn', function() require('neotest').run.run() end, desc = '[T]est [N]earest' },
      { '<leader>ts', function() require('neotest').summary.toggle() end, desc = '[T]est [S]ummary' },
      { '<leader>tl', function() require('neotest').run.run_last() end, desc = '[T]est [L]ast' },
      { '<leader>tf', function() require('neotest').summary.open() end, desc = '[T]est [F]ailure summary' },
    },
    config = function()
      require('neotest').setup {
        adapters = {
          require 'neotest-python' {
            python = (function()
              local path = vim.fn.exepath 'python3'
              if path == '' then path = 'python' end
              return path
            end)(),
          },
          require 'neotest-jest' {
            jestCommand = 'jest --',
            jestConfigFile = function(file)
              if string.find(file, '/packages/') then
                return string.match(file, '(.-/packages/[^/]+)') .. '/jest.config.js'
              end
              return vim.fn.getcwd() .. '/jest.config.js'
            end,
            env = { CI = true },
            cwd = function(file)
              if string.find(file, '/packages/') then
                return string.match(file, '(.-/packages/[^/]+)')
              end
              return vim.fn.getcwd()
            end,
          },
          require 'neotest-go',
          require 'neotest-rust',
        },
      }
    end,
  },
}
