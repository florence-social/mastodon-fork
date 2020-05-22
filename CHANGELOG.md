# Changelog

This changelog will only include differences from upstream Mastodon. [You can find the upstream
changelog here.](https://github.com/tootsuite/mastodon/blob/master/CHANGELOG.md)

Please note that this project doesn't follow semantic versioning— for details please have a look at
our [README file].
## [2.9.4] - 2020-02-27
### Security

- Fix leak of arbitrary statuses through unfavourite action in REST API ([Gargron](https://github.com/tootsuite/mastodon/pull/13161))

## [2.9.3] - 2019-08-10
### Added

- Add GIF and WebP support for custom emojis ([Gargron](https://github.com/tootsuite/mastodon/pull/11519))
- Add logout link to dropdown menu in web UI ([koyuawsmbrtn](https://github.com/tootsuite/mastodon/pull/11353))
- Add indication that text search is unavailable in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/11112), [ThibG](https://github.com/tootsuite/mastodon/pull/11202))
- Add `suffix` to `Mastodon::Version` to help forks ([clarfon](https://github.com/tootsuite/mastodon/pull/11407))
- Add on-hover animation to animated custom emoji in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/11348), [ThibG](https://github.com/tootsuite/mastodon/pull/11404), [ThibG](https://github.com/tootsuite/mastodon/pull/11522))
- Add custom emoji support in profile metadata labels ([ThibG](https://github.com/tootsuite/mastodon/pull/11350))

### Changed

- Change default interface of web and streaming from 0.0.0.0 to 127.0.0.1 ([Gargron](https://github.com/tootsuite/mastodon/pull/11302), [zunda](https://github.com/tootsuite/mastodon/pull/11378), [Gargron](https://github.com/tootsuite/mastodon/pull/11351), [zunda](https://github.com/tootsuite/mastodon/pull/11326))
- Change the retry limit of web push notifications ([highemerly](https://github.com/tootsuite/mastodon/pull/11292))
- Change ActivityPub deliveries to not retry HTTP 501 errors ([Gargron](https://github.com/tootsuite/mastodon/pull/11233))
- Change language detection to include hashtags as words ([Gargron](https://github.com/tootsuite/mastodon/pull/11341))
- Change terms and privacy policy pages to always be accessible ([Gargron](https://github.com/tootsuite/mastodon/pull/11334))
- Change robots tag to include `noarchive` when user opts out of indexing ([Kjwon15](https://github.com/tootsuite/mastodon/pull/11421))

### Fixed

- Fix account domain block not clearing out notifications ([Gargron](https://github.com/tootsuite/mastodon/pull/11393))
- Fix incorrect locale sometimes being detected for browser ([Gargron](https://github.com/tootsuite/mastodon/pull/8657))
- Fix crash when saving invalid domain name ([Gargron](https://github.com/tootsuite/mastodon/pull/11528))
- Fix pinned statuses REST API returning pagination headers ([Gargron](https://github.com/tootsuite/mastodon/pull/11526))
- Fix "cancel follow request" button having unreadable text in web UI ([Gargron](https://github.com/tootsuite/mastodon/pull/11521))
- Fix image uploads being blank when canvas read access is blocked ([ThibG](https://github.com/tootsuite/mastodon/pull/11499))
- Fix avatars not being animated on hover when not logged in ([ThibG](https://github.com/tootsuite/mastodon/pull/11349))
- Fix overzealous sanitization of HTML lists ([ThibG](https://github.com/tootsuite/mastodon/pull/11354))
- Fix block crashing when a follow request exists ([ThibG](https://github.com/tootsuite/mastodon/pull/11288))
- Fix backup service crashing when an attachment is missing ([ThibG](https://github.com/tootsuite/mastodon/pull/11241))
- Fix account moderation action always sending e-mail notification ([Gargron](https://github.com/tootsuite/mastodon/pull/11242))
- Fix swiping columns on mobile sometimes failing in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/11200))
- Fix wrong actor URI being serialized into poll updates ([ThibG](https://github.com/tootsuite/mastodon/pull/11194))
- Fix statsd UDP sockets not being cleaned up in Sidekiq ([Gargron](https://github.com/tootsuite/mastodon/pull/11230))
- Fix expiration date of filters being set to "never" when editing them ([ThibG](https://github.com/tootsuite/mastodon/pull/11204))
- Fix support for MP4 files that are actually M4V files ([Gargron](https://github.com/tootsuite/mastodon/pull/11210))
- Fix `alerts` not being typecast correctly in push subscription in REST API ([Gargron](https://github.com/tootsuite/mastodon/pull/11343))
- Fix some notices staying on unrelated pages ([ThibG](https://github.com/tootsuite/mastodon/pull/11364))
- Fix unboosting sometimes preventing a boost from reappearing on feed ([ThibG](https://github.com/tootsuite/mastodon/pull/11405), [Gargron](https://github.com/tootsuite/mastodon/pull/11450))
- Fix only one middle dot being recognized in hashtags ([Gargron](https://github.com/tootsuite/mastodon/pull/11345), [ThibG](https://github.com/tootsuite/mastodon/pull/11363))
- Fix unnecessary SQL query performed on unauthenticated requests ([Gargron](https://github.com/tootsuite/mastodon/pull/11179))
- Fix incorrect timestamp displayed on featured tags ([Kjwon15](https://github.com/tootsuite/mastodon/pull/11477))
- Fix privacy dropdown active state when dropdown is placed on top of it ([ThibG](https://github.com/tootsuite/mastodon/pull/11495))
- Fix filters not being applied to poll options ([ThibG](https://github.com/tootsuite/mastodon/pull/11174))
- Fix keyboard navigation on various dropdowns ([ThibG](https://github.com/tootsuite/mastodon/pull/11511), [ThibG](https://github.com/tootsuite/mastodon/pull/11492), [ThibG](https://github.com/tootsuite/mastodon/pull/11491))
- Fix keyboard navigation in modals ([ThibG](https://github.com/tootsuite/mastodon/pull/11493))
- Fix image conversation being non-deterministic due to timestamps ([Gargron](https://github.com/tootsuite/mastodon/pull/11408))
- Fix web UI performance ([ThibG](https://github.com/tootsuite/mastodon/pull/11211), [ThibG](https://github.com/tootsuite/mastodon/pull/11234))
- Fix scrolling to compose form when not necessary in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/11246), [ThibG](https://github.com/tootsuite/mastodon/pull/11182))
- Fix save button being enabled when list title is empty in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/11475))
- Fix poll expiration not being pre-filled on delete & redraft in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/11203))
- Fix content warning sometimes being set when not requested in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/11206))

### Security

- Fix invites not being disabled upon account suspension ([ThibG](https://github.com/tootsuite/mastodon/pull/11412))
- Fix blocked domains still being able to fill database with account records ([Gargron](https://github.com/tootsuite/mastodon/pull/11219))

## [2.9.2] - 2019-06-22
### Added

- Add `short_description` and `approval_required` to `GET /api/v1/instance` ([Gargron](https://github.com/tootsuite/mastodon/pull/11146))

### Changed

- Change camera icon to paperclip icon in upload form ([koyuawsmbrtn](https://github.com/tootsuite/mastodon/pull/11149))

### Fixed

- Fix audio-only OGG and WebM files not being processed as such ([Gargron](https://github.com/tootsuite/mastodon/pull/11151))
- Fix audio not being downloaded from remote servers ([Gargron](https://github.com/tootsuite/mastodon/pull/11145))

## [2.9.1] - 2019-06-22
### Added

- Add moderation API ([Gargron](https://github.com/tootsuite/mastodon/pull/9387))
- Add audio uploads ([Gargron](https://github.com/tootsuite/mastodon/pull/11123), [Gargron](https://github.com/tootsuite/mastodon/pull/11141))

### Changed

- Change domain blocks to automatically support subdomains ([Gargron](https://github.com/tootsuite/mastodon/pull/11138))
- Change Nanobox configuration to bring it up to date ([danhunsaker](https://github.com/tootsuite/mastodon/pull/11083))

### Removed

- Remove expensive counters from federation page in admin UI ([Gargron](https://github.com/tootsuite/mastodon/pull/11139))

### Fixed

- Fix converted media being saved with original extension and mime type ([Gargron](https://github.com/tootsuite/mastodon/pull/11130))
- Fix layout of identity proofs settings ([acid-chicken](https://github.com/tootsuite/mastodon/pull/11126))
- Fix active scope only returning suspended users ([ThibG](https://github.com/tootsuite/mastodon/pull/11111))
- Fix sanitizer making block level elements unreadable ([Gargron](https://github.com/tootsuite/mastodon/pull/10836))
- Fix label for site theme not being translated in admin UI ([palindromordnilap](https://github.com/tootsuite/mastodon/pull/11121))
- Fix statuses not being filtered irreversibly in web UI under some circumstances ([ThibG](https://github.com/tootsuite/mastodon/pull/11113))
- Fix scrolling behaviour in compose form ([ThibG](https://github.com/tootsuite/mastodon/pull/11093))

## [2.9.0] - 2019-06-13
### Added

- **Add single-column mode in web UI** ([Gargron](https://github.com/tootsuite/mastodon/pull/10807), [Gargron](https://github.com/tootsuite/mastodon/pull/10848), [Gargron](https://github.com/tootsuite/mastodon/pull/11003), [Gargron](https://github.com/tootsuite/mastodon/pull/10961), [Hanage999](https://github.com/tootsuite/mastodon/pull/10915), [noellabo](https://github.com/tootsuite/mastodon/pull/10917), [abcang](https://github.com/tootsuite/mastodon/pull/10859), [Gargron](https://github.com/tootsuite/mastodon/pull/10820), [Gargron](https://github.com/tootsuite/mastodon/pull/10835), [Gargron](https://github.com/tootsuite/mastodon/pull/10809), [Gargron](https://github.com/tootsuite/mastodon/pull/10963), [noellabo](https://github.com/tootsuite/mastodon/pull/10883), [Hanage999](https://github.com/tootsuite/mastodon/pull/10839))
- Add waiting time to the list of pending accounts in admin UI ([Gargron](https://github.com/tootsuite/mastodon/pull/10985))
- Add a keyboard shortcut to hide/show media in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/10647), [Gargron](https://github.com/tootsuite/mastodon/pull/10838), [ThibG](https://github.com/tootsuite/mastodon/pull/10872))
- Add `account_id` param to `GET /api/v1/notifications` ([pwoolcoc](https://github.com/tootsuite/mastodon/pull/10796))
- Add confirmation modal for unboosting toots in web UI ([aurelien-reeves](https://github.com/tootsuite/mastodon/pull/10287))
- Add emoji suggestions to content warning and poll option fields in web UI ([ThibG](https://github.com/tootsuite/mastodon/pull/10555))
- Add `source` attribute to response of `DELETE /api/v1/statuses/:id` ([ThibG](https://github.com/tootsuite/mastodon/pull/10669))
- Add some caching for HTML versions of public status pages ([ThibG](https://github.com/tootsuite/mastodon/pull/10701))
- Add button to conveniently copy OAuth code ([ThibG](https://github.com/tootsuite/mastodon/pull/11065))

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
