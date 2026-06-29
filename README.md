# plugins

A collection of my personal [Noctalia V5](https://noctalia.dev) plugins.

## Usage

Add this repo as a source, then enable any plugin you want. See Noctalia docs [Using Plugins](https://docs.noctalia.dev/v5/plugins/) for full details.

**GUI**

Open **Settings → Plugins**, click **Add source**, and enter:

```
https://github.com/yogaeru/noctalia-plugins
```

**Shell**

```sh
# Add this repo as a source
noctalia msg plugins source add yogaeru git https://github.com/yogaeru/noctalia-plugins

# List available plugins
noctalia msg plugins list

# Enable a plugin
noctalia msg plugins enable yogaeru/mango-layout
```

## Plugins List

| Plugin                         | Description                                            |
| ------------------------------ | ------------------------------------------------------ |
| [`mango-layout`](mango_layout) | Bar widget for switching Mango window manager layouts. |
