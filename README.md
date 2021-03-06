# conventional

[![Gem Version](https://badge.fury.io/rb/conventional.svg)](https://badge.fury.io/rb/conventional)
[![Gem Version](https://github.com/dabarrell/conventional/workflows/Verify/badge.svg)](https://github.com/dabarrell/conventional/actions?query=workflow%3AVerify)
[![Coverage Status](https://coveralls.io/repos/github/dabarrell/conventional/badge.svg?branch=master)](https://coveralls.io/github/dabarrell/conventional?branch=master)

> Note: Under active development - expect breaking changes.

`conventional` bridges the gap in automating version management for Ruby gems from start to finish. Using
[Conventional Commits](https://conventionalcommits.org), it allows you to automate the process from commit to release.

## Install

Add this line to your Gemfile:

```ruby
gem 'conventional'
```

and run `bundle install` from your shell.

To install the gem manually, run:

```
gem install conventional
```

## Usage

### Bump

Bumps gem according to conventional commits

```
Usage:
  conventional bump

Options:
  --level=VALUE                   	# The level of bump to execute (determined automatically if not provided): (patch/minor/major)
  --[no-]tag                      	# Create and push git tag, default: true
  --message=VALUE                 	# Commit message template, default: "chore: Release v%{version} [skip ci]"
  --[no-]push                     	# Push changes to git remote, default: true
  --[no-]dry-run                  	# Completes a dry run without making any changes, default: false
  --help, -h                      	# Print this help
```

### Recommended Bump

Returns the recommended bump level according to conventional commits

```
Usage:
  conventional recommended-bump

Options:
  --help, -h                      	# Print this help
```

## See also

Check out these similar projects, which served as inspiration for `conventional`.

- [`conventional-changelog`](https://github.com/conventional-changelog) (JS)
- [`lerna`](https://github.com/lerna/lerna) (JS)
- [`github-changelog-generator`](https://github.com/github-changelog-generator/github-changelog-generator) (Ruby)
- [`gem-release`](https://github.com/svenfuchs/gem-release) (Ruby)

## License

`conventional` is distributed under the [MIT License](LICENSE.txt).

## Author

- David Barrell ([@dabarrell](https://github.com/dabarrell), [davidbarrell.me](https://davidbarrell.me))
