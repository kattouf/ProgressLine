## ProgressLine

![](https://img.shields.io/badge/Platform-macOS-6464aa)
![](https://img.shields.io/badge/Platform-Linux-6464aa)
[![Latest Release](https://img.shields.io/github/release/kattouf/ProgressLine.svg)](https://github.com/kattouf/ProgressLine/releases/latest)
![](https://github.com/kattouf/ProgressLine/actions/workflows/checks.yml/badge.svg?branch=main)

Track commands progress in a compact one-line format.

| ⏳ `progressline` output |
|:--:|
| ![](./.github/progressline_output.gif) |

| 📝 standard output |
|:--:|
| ![](./.github/standard_output.gif) |

[Usage](#usage) • [Features](#features) • [Installation](#installation)

## Usage

Simply pipe your command output into `progressline` to start tracking:

```sh
long-running-command | progressline
```

If the command you are executing also writes data to `stderr`, then you should probably use ["redirection"](https://www.gnu.org/software/bash/manual/html_node/Redirections.html) and send `stderr` messages to `stdout` so that they also go through the `progressline`:

``` sh
long-running-command 2>&1 | progressline
```

## Features

### Change activity indicator styles

ProgressLine offers different styles to represent activity, they can be changed using `-s, --activity-style` option:

``` sh
long-running-command | progressline --activity-style snake
```

Available styles:

<table>
  <tr>
    <td align="center">dots (Default)</td>
    <td align="center">snake</td>
    <td align="center"><a href="https://en.wikipedia.org/wiki/KITT">kitt</a></td>
  </tr>
  <tr>
    <td><img src="./.github/activity_style_dots.gif" alt="dots" width="300"></td>
    <td><img src="./.github/activity_style_snake.gif" alt="snake" width="300"></td>
    <td><img src="./.github/activity_style_kitt.gif" alt="kitt" width="300"></td>
  </tr>
  <tr>
    <td align="center">spinner</td>
  </tr>
  <tr>
    <td><img src="./.github/activity_style_spinner.gif" alt="spinner" width="300"></td>
  </tr>
</table>

### Replace log output with custom text

If you don't need to see the log output during execution, even in a single line, you can replace it with your own text using the `-t, --static-text` option.

``` sh
long-running-command | progressline --static-text "Updating sources..."
```

### Highlight important lines

Log specific stdin lines above the progress line using the `-m, --log-matches` option:

``` sh
long-running-command | progressline --log-matches "regex-1" --log-matches "regex-2"
```

### Use progress line as an addition to standard output

Log all stdin data above the progress line using the `-a, --log-all` option:

```sh
long-running-command | progressline --log-all
```

### Save original log

You have two options for saving the full original log:

1. Using [tee](https://en.wikipedia.org/wiki/Tee_(command))

``` sh
long-running-command | tee original-log.txt | progressline
```

2. Using `-l, --original-log-path` option:

``` sh
long-running-command | progressline --original-log-path original-log.txt
```

## Installation

### [Homebrew](https://brew.sh) (macOS / Linux)

``` sh
brew install progressline
```

<details>
  <summary>If you have macOS version older than Sonoma</summary>
  
  ``` sh
  brew install kattouf/progressline/progressline
  ```
  
</details>

### [Mint](https://github.com/yonaskolb/Mint) (macOS)

``` sh
mint install kattouf/ProgressLine
```

### [Mise](https://mise.jdx.dev) (macOS)

``` sh
mise use -g spm:kattouf/ProgressLine
```

### Manual Installation (macOS / Linux)

Download the binary for your platform from the [releases page](https://github.com/kattouf/ProgressLine/releases), and place it in your executable path.

## Contributing

Feel free to open a pull request or a discussion.
