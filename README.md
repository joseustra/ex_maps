# ExMaps

Converts Elixir maps from atom to string and vice versa.

It uses tree-sitter to find the Map.


## Instalation

```lua
use 'ustrajunior/ex_maps'

lua require("ex_maps").setup {
	create_mappings = true,
	mapping = "mtt",
}
```

## How to use

Put the cursor in the line you want to convert and press "mtt".

## demo
![screenshot](./screenshots/ex_maps.gif)

