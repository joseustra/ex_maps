fun! ExMaps()
	lua for k in pairs(package.loaded) do if k:match("^ex%_maps") then package.loaded[k] = nil end end
	lua require("ex_maps").printName()
endfun

augroup ExMaps
	autocmd!
augroup END
