nnoremap <silent><leader>a :lua require("harpoon.mark").add_file()<CR>
nnoremap <silent><C-e> :lua require("harpoon.ui").toggle_quick_menu()<CR>
nnoremap <silent><leader>tc :lua require("harpoon.cmd-ui").toggle_quick_menu()<CR>

nnoremap <silent><A-1> :lua require("harpoon.ui").nav_file(1)<CR>
nnoremap <silent><A-2> :lua require("harpoon.ui").nav_file(2)<CR>
nnoremap <silent><A-3> :lua require("harpoon.ui").nav_file(3)<CR>
nnoremap <silent><A-4> :lua require("harpoon.ui").nav_file(4)<CR>

