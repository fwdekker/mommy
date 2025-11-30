# 🤠 contribution guidelines
thank you for considering contributing to mommy!
below are some guidelines for contributions, but honestly, _any_ contribution is welcome, even if it's broken, because
surely we'll be able to figure something out together~

## 🐐 best practices
the best pull requests do all of the following.
but pull requests that are half-baked or otherwise don't fit the mold are just as welcome, so don't fret!

* add relevant documentation and tests~
* begin every commit message with a relevant emoji, followed by one space~
* ensure that the tests pass (on your machine, at least)~
* describe your changes in `CHANGELOG.md`~
* use a code style similar to its surroundings~
* your pull request should go into `main`~

## 🎯 what to aim for
* mommy is and will always primarily be a posix-compatible shell script~
* to help you understand the scope of this project, see the following list:

  | idea                                                   | in scope? | why?                                                                                                                                         |
  |--------------------------------------------------------|-----------|----------------------------------------------------------------------------------------------------------------------------------------------|
  | add a small feature, fix a bug, or improve performance | yes!      |                                                                                                                                              |
  | add a big feature                                      | yes!      |                                                                                                                                              |
  | reimplement mommy as a powershell script               | no        | hard to maintain two scripts at once. also, most windows users who want to use mommy can run mommy just fine using git bash, cygwin, or wsl~ |
  | reimplement mommy in c or in rust                      | no        | mommy is a program that you use inside a shell. if you can run a shell, you can probably run a posix shell~                                  |
  | add support for a non-posix shell                      | maybe     | if you can add support in a way that doesn't require maintaining two separate implementations of mommy, then yes please!                     |
* if you have motivation but lack inspiration, take a look at [issues labeled `good-first-issue`](https://github.com/fwdekker/mommy/issues?q=is%3Aissue%20state%3Aopen%20label%3Agood-first-issue)~

## 🧑‍🎓 understanding the code
if you want to know what all the different files mean, or how to compile the project, or where to add new tests, then refer to [the development section in the readme](README.md#development)~

## 💖 about acknowledgements
as [noted in the readme](README.md#acknowledgements), all contributions are acknowledged, no matter their size!
if you don't want this, then please explicitly say so.
if i forgot to add you, or if you want your acknowledgement changed or removed, then [open an issue](https://github.com/fwdekker/mommy/issues/new) or
[contact me directly](https://fwdekker.com/about/)~

if you want to contribute but don't have a github account, or don't want your github account associated with this repo, then feel free to [contact me directly](https://fwdekker.com/about/)~

