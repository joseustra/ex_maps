# ExMaps


![ex_maps_logo](https://github.com/joseustra/ex_maps/assets/58203/419f3c3d-5e31-4d2f-863c-e85be5ced6f0)

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

