# Changelog

This changelog will only include differences from upstream Mastodon. [You can find the upstream
changelog here.](https://github.com/tootsuite/mastodon/blob/master/CHANGELOG.md)

Please note that this project doesn't follow semantic versioning— for details please have a look at
our [README file].

[README file]: ./README.md

## Pre-Release 0.1.2 [2019-08-18 / v0.0.1.2]

This release fixes a bug from 0.1.1 before the 0.2.0 release.

It doesn't add any upstream changes, and is still based off of [Mastodon 2.9.0] plus the commits
up to [65efe892cf].

### Fixed

* Toot and biography lengths are offered as integers in the API instead of strings
    * Thanks to [mthld] and [DagAgren] for finding the bug
    * Thanks to [1011X] for the fix

[mthld]: https://github.com/mthld
[DagAgren]: https://github.com/DagAgren

## Pre-Release 0.1.1 [2019-07-28 / v0.0.1.1]

This release fixes a few bugs from 0.1.0 before the 0.2.0 release.

It doesn't add any upstream changes, and is still based off of [Mastodon 2.9.0] plus the commits
up to [65efe892cf].

### Fixed

* Toot and biography lengths are now on /api/v1/instance API, for better app integration
    * Thanks to [ElliotBerriot] for testing 0.1.0 and finding the bug
    * Thanks to [1011X] for the fix
* Toot and biography lengths can actually be saved in the admin UI
    * Thanks to [ElliotBerriot] for testing 0.1.0 and finding the bug
    * Thanks to [clarfon] for the fix
* All of the code has been fixed to include the proper project URL and docker image
    * Thanks to [ElliotBerriot] for debugging 0.1.0 and finding the errors with the Docker files
    * Thanks to [clarfon] for the fix
* Broadcasted version has been reverted to the Mastodon version, so that mastodon.py and other
  libraries work until we find a better solution
    * Thanks to [Frinkel] for testing 0.1.0 and finding the bug
    * Thanks to [halcy] for providing insight into how mastodon.py works
    * Thanks to [1011X] for the fix
* Blocking entire instance domains now gives a less judgmental message in the English locale
    * Thanks to [TrechNex] for the fix
    * Thanks to [mal0ki] and [clarfon] for reviewing the wording
* Florence-specific settings have been translated into Dutch
    * Thanks to [rscmbbng] for the translations
* The [lastest typo] in the README was corrected
    * Thanks to [ciderpunx] for the fix
* A few dependencies were updated to fix various security issues
    * Prototype pollution vulnerabilities were fixed for handlebars and lodash
    * Thanks to [1011X] for future-proofing CVE-2015-9284 (OAuth vulnerability)

[lastest typo]: https://github.com/florence-social/mastodon-fork/pull/106/files

[ciderpunx]: https://github.com/ciderpunx
[ElliotBerriot]: https://github.com/ElliotBerriot
[Frinkel]: https://github.com/Frinkel
[halcy]: https://github.com/halcy
[mal0ki]: https://github.com/mal0ki
[rscmbbng]: https://github.com/rscmbbng
[TrechNex]: https://github.com/TrechNex

### Special Thanks

* Thank you to everyone who jumped on the Florence train and set up their own instances! We'll try
  and compile a list of Florence Mastodon instances some time before the next release.
* Thank you to @TrechNex for helping set up [installation instructions] on his website!

[installation instructions]: https://bobbymoss.com/index.html#install-florence-prerelease

## Pre-Release 0.1.0 [2019-06-18 / v0.0.1.0]

This release is based off of [Mastodon 2.9.0] plus the commits up to [65efe892cf].

[Mastodon 2.9.0]: https://github.com/tootsuite/mastodon/blob/v2.9.0/CHANGELOG.md
[65efe892cf]: https://github.com/tootsuite/mastodon/compare/c9eeb2e832b5b36a86028bbec7a353c32be510a7..65efe892cf56cd4f998de885bccc36e9231d8144

### Added

* Toot length can now be configured by an admin; default is 500
    * Thanks to glitch.social and many other forks for the original code
    * Thanks to [usbsnowcrash] for the Florence-specific code
    * Thanks to [m4sk1n] for the Polish translation
    * Thanks to [clarfon] and [Feufochmar] for the French translation
    * Thanks to [1011X] and [skrlet13] for the Spanish translation
* Biography length can now be configured by an admin; default is 500
    * Thanks to glitch.social and many other forks for the original code
    * Thanks to [usbsnowcrash] for the Florence-specific code
    * Thanks to [clarfon] and [Feufochmar] for the French translation
    * Thanks to [1011X] and [skrlet13] for the Spanish translation
* Users can choose whether to receive DMs on the home timeline in their settings
    * Thanks to glitch.social and many other forks for the original code
    * Thanks to [usbsnowcrash] for the Florence-specific code
    * Thanks to [clarfon] and [Feufochmar] for the French translation
    * Thanks to [1011X] and [skrlet13] for the Spanish translation
* Spanish translations were updated to be more formal
    * Thanks to [1011X] for the inital changes
    * Thanks to [skrlet13] for offering feedback and further changes

[1011X]: https://github.com/1011X
[clarfon]: https://github.com/clarfon
[Feufochmar]: https://github.com/Feufochmar
[m4sk1n]: https://github.com/m4sk1n
[skrlet13]: https://github.com/skrlet13
[usbsnowcrash]: https://github.com/usbsnowcrash

### Special Thanks

* Thank you to @1011x, @jhaye, @lightdark, @maloki, @skrlet13, @melody, @stolas, @hak, @mecaka:
  those who've been helping with governance, offering advice, and/or been working on this for the
  past few months.
* Thank you to @woozle for hosting both the Wiki and Mattermost for us on their servers.
* Thank you to all the forkers out there who are providing us both with inspiration, actual code,
  and conversation about how we can make the Fediverse a little bit better.
* Thank you to everyone that has been cheerleading us for the past year, helped us have the courage
  to "Fork Off" from Mastodon, and also understood that we are working towards different
  objectives. That is after all why you all joined us in the first place!
* Thank you to @mecaka who joined the team while @maloki was getting diagnosed, who helped push
  through that time and bring us to where we are now.
* An additional thank you to those that joined the Mattermost server to keep the conversation alive
  with us after we moved on from Discord!
