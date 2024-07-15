-- leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- set to true if nerdfont is installed
vim.g.have_nerd_font = true

-- options
require 'config.options'

-- keymaps
require 'config.keymaps'

-- lazy plugin manager
require 'config.lazy'
