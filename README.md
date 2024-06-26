# countdown.fish
Print a colorful countdown, to remind you about your deadlines

<!-- ![image](https://github.com/kpbaks/countdown.fish/assets/57013304/04de8edb-77cd-4557-b5f4-1de40e27c411) -->

![image](https://github.com/kpbaks/countdown.fish/assets/57013304/885785dd-3bf6-4dc5-a0e1-4f3282779065)


## Requirements


<!-- todo: install automatically on install if not already -->

- [`peopletime`](https://github.com/kpbaks/peopletime) needed to pretty print durations.

## Installation

Using [fisher](https://github.com/jorgebucaran/fisher)

```sh
fisher install kpbaks/countdown.fish
```

## Usage

![image](https://github.com/kpbaks/countdown.fish/assets/57013304/0334a781-6baa-47b1-96cb-dfb191ce4bb9)

## Customization

By default `countdown` will use a color gradient from `#00ff00` (green) to `#ff0000` (red). The list of colors
is generated by the awesome tool [`pastel`](https://github.com/sharkdp/pastel) using:

```sh
pastel gradient '#00ff00' '#ff0000'  -s HSL -n 20 | pastel format hex
```

> [!NOTE]
> You do not need to have `pastel` installed in order to use this plugin.

If you want to use another list of colors you can set a **universal** variable `COUNTDOWN_COLORS` to a list of 
1 or more hex colors:

```sh
set -U COUNTDOWN_COLORS "#ff0000" "#00ff00" "#0000ff" # horrible choice of colors, btw
# or with pastel
set -U COUNTDOWN_COLORS (pastel gradient cyan magenta  -s HSL -n 20 | pastel format hex)
```
