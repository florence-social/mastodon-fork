# Changelog

This changelog will only include differences from upstream Mastodon. [You can find the upstream
changelog here.](https://github.com/tootsuite/mastodon/blob/master/CHANGELOG.md)

Please note that this project doesn't follow semantic versioning— for details please have a look at
our [README file].

[README file]: ./README.md

## Pre-Release 0.1.0 [2019-06-18 / v0.0.1.0]

This release is based off of [Mastodon 2.9.0] plus the commits up to [65efe892cf].

[Mastodon 2.9.0]: https://github.com/tootsuite/mastodon/blob/v2.9.0/CHANGELOG.md
[65efe892cf]: https://github.com/tootsuite/mastodon/compare/c9eeb2e832b5b36a86028bbec7a353c32be510a7..65efe892cf56cd4f998de885bccc36e9231d8144

### Added

* Toot length can now be configured by an admin; default is 500
    * Thanks to glitch.social and many other forks for the original code
    * Thanks to [usbsnowcrash] for the Florence-specific code
    * Thanks to [m4sk1n] for the Polish translation
* Biography length can now be configured by an admin; default is 500
    * Thanks to glitch.social and many other forks for the original code
    * Thanks to [usbsnowcrash] for the Florence-specific code
* Users can choose whether to receive DMs on the home timeline in their settings
    * Thanks to glitch.social and many other forks for the original code
    * Thanks to [usbsnowcrash] for the Florence-specific code

[usbsnowcrash]: https://github.com/usbsnowcrash
[m4sk1n]: https://github.com/m4sk1n

### Special Thanks

* @1011x, @jhaye, @lightdark, @maloki, @skrlet13, @melody, @stolas, @hak, @mecaka: those who've
  been helping with governance, offering advice, and/or been working on this for the past few
  months.
* @woozle: who helped us host both the Wiki and Mattermost.
* Everyone who's been cheerleading us the past year, and helped us have the courage to Fork Off
  from Mastodon, and understanding of that we're working on a different premise than Mastodon did.
  That's kind of why you all joined us in the first place.
