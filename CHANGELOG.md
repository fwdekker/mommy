# Changelog
## [9.9.9-unreleased] -- 9999-12-31
### added
* 💵 mommy now includes bash completions~ ([#43](https://github.com/fwdekker/mommy/issues/43)) ([#170](https://github.com/fwdekker/mommy/issues/170))
* #️⃣ mommy now supports templates starting with `#` using `%%#%%`~ ([#173](https://github.com/fwdekker/mommy/issues/173)) ([#174](https://github.com/fwdekker/mommy/issues/174))
* 🌞 mommy once again distributes a package for solaris, attached as a `.p5p` file to each github release~ ([#176](https://github.com/fwdekker/mommy/issues/176))


## [1.8.0] -- 2025-12-03
### added
* 🪈 mommy now enables [pipefail](https://stackoverflow.com/q/68465355/) for you when you use `-e`/`--eval` if you also pass the `-p`/`--pipefail` option. if your shell at `/bin/sh` does not support pipefail, you'll receive an error if you do this~ ([#160](https://github.com/fwdekker/mommy/pull/160)) ([#165](https://github.com/fwdekker/mommy/pull/165))
* ✍️ mommy added a package for the haiku operating system~ ([#167](https://github.com/fwdekker/mommy/pull/167))

### changed
* 🦈 mommy updated fish completions for fish v4~ ([#166](https://github.com/fwdekker/mommy/pull/166))
* 📒 mommy improved her manual page~ ([#166](https://github.com/fwdekker/mommy/pull/166))

### fixed
* 🌿 mommy fixed builds on opensuse tumbleweed~ ([#162](https://github.com/fwdekker/mommy/pull/162))
* 🚧 mommy now detects when the new toggle feature (`-t`/`--toggle`) from v1.7.0 fails to (de)activate~ ([#161](https://github.com/fwdekker/mommy/pull/161)) ([#163](https://github.com/fwdekker/mommy/pull/163))
* 👩‍🔬 mommy now keeps config files in unit tests completely separate from real config files~ ([#162](https://github.com/fwdekker/mommy/pull/162))


## [1.7.0] -- 2025-12-01
### added
* 🫥 mommy can now be toggled on or off without changing any configuration files using the `-t` or `--toggle` option. just run `mommy -t` and you'll no longer get any output from mommy, until you run `mommy -t` again. the toggle setting is per user, but carries across shells and even reboots. mommy thanks [amber sprenkels](https://github.com/dsprenkels) for suggesting the feature, and thanks [david scann](https://github.com/fwdekker/mommy/issues/46#issuecomment-2888498320) for additional feedback~ ([#46](https://github.com/fwdekker/mommy/pull/46))

### changed
* ✍️ mommy changed the capitalisation of its maintainer's username~ ([#152](https://github.com/fwdekker/mommy/pull/152))

### security
* 🔧 mommy improved the security of her automated test scripts~ ([#152](https://github.com/fwdekker/mommy/pull/152))


## [1.6.0] -- 2025-03-09
### added
* 📇 mommy now supports independent possessive (`theirs`) and reflexive (`themself`) pronouns. to use these new forms inside a compliment or encouragement, write `%%THEIRS%%` or `%%THEMSELF%%`, respectively. to choose mommy's pronouns, you should now write `MOMMY_PRONOUNS="they them their theirs theirself"` in your config instead of `MOMMY_PRONOUNS="they them their"`. specifying all five pronoun forms is recommended, but only specifying three forms still works and is _not_ deprecated. for more details, see [the list of all settings](https://github.com/fwdekker/mommy/tree/v1.6.0?tab=readme-ov-file#list-of-all-settings) and [how to configure templates](https://github.com/fwdekker/mommy/tree/v1.6.0?tab=readme-ov-file#how-to-configure-templates)~
* ☄️ mommy now supports using whitespace inside pronouns using `%%_%%`~
* 🚀 mommy now explains how to configure [starship](https://starship.rs/)~ ([#135](https://github.com/fwdekker/mommy/pull/135))
* ☕ mommy explains how to use fish completions on macos~

### fixed
* 👹 mommy ensures freebsd builds don't have the target version hardcoded~


## [1.5.1] -- 2024-09-28
### added
* 🤸‍♀️ mommy now supports `-d` as an alias of `--global-config-dirs`~

### changed
* 👤 mommy now refers to the user by their username by default~ ([#131](https://github.com/fwdekker/mommy/issues/131))


## [1.5.0] -- 2024-02-28
### added
* 🦓 mommy now supports templates with literal slashes using `%%S%%`~ ([#107](https://github.com/fwdekker/mommy/issues/107))
* 🐟 mommy added completions for fish and zsh for the new options introduced in v1.4.0~ ([#105](https://github.com/fwdekker/mommy/issues/105))

### changed
* 🙅‍♀️ mommy's `MOMMY_FORBIDDEN_WORDS` setting now interprets each word as a regex~ ([#103](https://github.com/fwdekker/mommy/issues/103))
* 🚀 mommy is now 4 times as fast~ ([#106](https://github.com/fwdekker/mommy/issues/106))


## [1.4.0] -- 2024-02-17
### added
* 🌍 mommy now supports a global config file that applies to all users, stored for example in `/usr/mommy/config.sh`~ ([#95](https://github.com/fwdekker/mommy/issues/95)) ([#96](https://github.com/fwdekker/mommy/issues/96))
* 📏 mommy accepts long command-line options for all options (like `--config=<file>` for `-c <file>`)~

### changed
* 🕳️ mommy now interprets an empty config file path (`-c`) as you not wanting to use a config file~
* ✅ mommy improved her input validation, giving clearer error messages when something is wrong~
* 🏓 mommy improved the links to and from the table of contents in her readme~
* 🏋️‍♀️ mommy made her readme easier to navigate and scroll through~ ([#97](https://github.com/fwdekker/mommy/issues/97))


## [1.3.0] -- 2024-01-10
### added
* 🪹 mommy now supports newlines in templates using `%%N%%`~ ([#58](https://github.com/fwdekker/mommy/issues/58)) ([#82](https://github.com/fwdekker/mommy/issues/82))
* 🛡️ mommy now has a [security policy](https://github.com/fwdekker/mommy/security)~

### fixed
* 🚒 mommy fixes the description url in her manual page~ ([#81](https://github.com/fwdekker/mommy/issues/81)) ([#82](https://github.com/fwdekker/mommy/issues/82))
* 🕰️ mommy uses the correct types of changelogs in the right places ([#83](https://github.com/fwdekker/mommy/issues/83))
* 🏃 mommy no longer crashes when using `\` or `&` in variables~ ([#84](https://github.com/fwdekker/mommy/issues/84)) ([#87](https://github.com/fwdekker/mommy/issues/87))


## [1.2.6] -- 2023-11-29
### fixed
* 🚒 mommy fixes her apt repository release script~ ([#73](https://github.com/fwdekker/mommy/issues/73))


## [1.2.5] -- 2023-11-29
### added
* 📈 mommy now explains how to integrate with nushell, thanks to [aemogie.](https://github.com/aemogie)~ ([#65](https://github.com/fwdekker/mommy/issues/65))

### changed
* 🍳 mommy uses newer github actions, thanks to [zopolis4](https://github.com/Zopolis4)~ ([#68](https://github.com/fwdekker/mommy/pull/68))
* 💨 mommy became much faster at doing her exams~ ([#69](https://github.com/fwdekker/mommy/pull/69))
* 📂 mommy supports specifying a custom directory during `make`~ ([#70](https://github.com/fwdekker/mommy/pull/70))
* 👭 mommy now has an apt repository, see [mommy's readme](https://github.com/fwdekker/mommy/blob/v1.2.5/README.md#%E2%80%8D-with-a-package-manager) for installation instructions~ ([#71](https://github.com/fwdekker/mommy/pull/71))


## [1.2.4] -- 2023-08-28
### added
* ❄️ mommy is now available on nixpkgs, thanks to [ckie](https://github.com/ckiee)~ ([NixOS/nixpkgs#250034](https://github.com/NixOS/nixpkgs/pull/250034))
* ☝️ mommy now mentions the fingerprint of her copr signing key in the readme~ ([c8cde91](https://github.com/fwdekker/mommy/commit/c8cde91d162c9000e0133fdec8d65796ee17bfbf))

### changed
* 🗂️ mommy looks in `XDG_CONFIG_HOME` instead of `$HOME/.config` if the former is configured~ ([#61](https://github.com/fwdekker/mommy/pull/61))
* 🎨 mommy cleaned up her makefile~ ([#63](https://github.com/fwdekker/mommy/pull/63))

### fixed
* 💿 mommy fixed a small issue with tests for netbsd~ ([#62](https://github.com/fwdekker/mommy/pull/62))


## [1.2.3] -- 2023-03-14
### added
* 🎩 mommy is now available for fedora, red hat, and other rpm-based systems via [copr](https://copr.fedorainfracloud.org/)~ ([#39](https://github.com/fwdekker/mommy/issues/39))
* 🪟 mommy is now tested on msys2 for windows~ ([#54](https://github.com/fwdekker/mommy/issues/54))
* 💥 mommy's makefile now has an `uninstall` option~

### changed
* ✍️ mommy rewrote the installation instructions~ ([#51](https://github.com/fwdekker/mommy/issues/51))
* 🐙 mommy links to github if `man` doesn't work~ ([#55](https://github.com/fwdekker/mommy/issues/55)) 

### fixed
* ✏️ mommy fixed some minor errors in the readme~
* ♻️ mommy hopefully fixed automatic synchronous releases for homebrew and aur~


## [1.2.2] -- 2023-03-09
### added
* 🐟 mommy has shell completions for fish and zsh~  
  they are enabled by default on most machines. if you installed mommy with brew, check the [brew documentation on how to enable shell completions](https://docs.brew.sh/Shell-Completion)~ ([#43](https://github.com/fwdekker/mommy/issues/43)) ([#48](https://github.com/fwdekker/mommy/pull/48))

### changed
* 🤖 mommy no longer talks like a robot when unknown options are used~ ([#47](https://github.com/fwdekker/mommy/pull/47))
* ⚗️ mommy's build system has been revamped~ ([#38](https://github.com/fwdekker/mommy/issues/38)) ([#42](https://github.com/fwdekker/mommy/issues/42))
* ⭐ mommy has a bunch more emoji in her readme~ ([#40](https://github.com/fwdekker/mommy/issues/40))

### fixed
* 📁 mommy installs herself into `/usr/bin` instead of `/usr/local/bin` on linux, to comply with the standards of various operating systems~
* 💪 mommy better tolerates missing optional dependencies when installing from aur~


## [1.2.1] -- 2023-02-26
* mommy supports homebrew now~
* mommy supports arch linux aur now~


## [1.2.0] -- 2023-02-24
* mommy can output to stdout without redirection by giving her the `-1` option~
* mommy ignores exit code `130` by default, but you can change this by setting `MOMMY_IGNORED_STATUSES`~
* mommy supports prefixes for her messages, and explains how to use them to get colors in zsh~
* mommy improved her readme a bit~


## [1.1.0] -- 2023-02-24
* _breaking_: mommy supports different pronoun forms.  
  instead of `MOMMY_THEIR="her"` and using variable `%%THEIR%%`, you should now write `MOMMY_PRONOUN="she her her"` and use variables `%%THEY%%`, `%%THEM%%`, and `%%THEIR`~


## [1.0.0] -- 2023-02-23
* _breaking_: mommy no longer supports multi-line templates and variables~
* mommy is even faster now with much simpler code~
* mommy now supports OpenBSD~
* mommy now has installable packages for macOS, FreeBSD, NetBSD, and OpenBSD~
* mommy has a `--version` option now~
* mommy has improved documentation~
* mommy stopped doing the `raw` and `installer` release types because they're redundant~


## [0.0.6] -- 2023-02-18
* mommy is much faster now that she only calculates when needed~
* mommy now works on macOS, *BSD, and probably on Solaris~
* mommy has an installer script for any POSIX system~
* mommy does ci/cd now~


## [0.0.5] -- 2023-02-11
* _breaking_: config variables have been renamed, like from `%%PRONOUN%%` to `%%THEIR%%`, so you can actually read your templates without using too much of your precious brain capacity~
* mommy's output is now vibrant! check the readme to see how to integrate with [lolcat](https://github.com/busyloop/lolcat) for rainbow colors~
* mommy's library of compliments is much larger now~
* the readme now explains how to integrate mommy into your shell, so you two will never have to be apart again~
* you can add comments in between your templates so you don't forget what they mean. just start a line with `#` inside a template~


## [0.0.4] -- 2023-02-07
* mommy supports reading exit codes with `mommy -s <status>`, as in `mommy -s $?` or `mommy -s 0`~
* mommy avoids saying the words listed in `MOMMY_FORBIDDEN_WORDS`~
* mommy's compliments can be disabled with `MOMMY_COMPLIMENTS_ENABLED=0` and mommy's encouragements can be disabled with `MOMMY_ENCOURAGEMENTS_ENABLED=1`~
* mommy trims leading and trailing newlines in compliments and encouragements~
* mommy behaves consistently when options are empty~


## [0.0.3] -- 2023-01-29
* mommy varies the words she chooses~
* mommy can now eval a command so it's easier to make her pipe~
* mommy's docs are much cleaner now~


## [0.0.2] -- 2023-01-25
mommy has documentation now~


## [0.0.1] -- 2023-01-25
mommy's initial release~
