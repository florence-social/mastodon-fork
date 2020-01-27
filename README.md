Florence Mastodon
=================

Mastodon is a **free, open-source social network server** based on ActivityPub. This is *not* the
official version of Mastodon; this is a separate version (i.e. a fork) maintained by Florence. For
more information on Mastodon, you can see the [official website] and the [upstream repo].

[official website]: https://joinmastodon.org
[upstream repo]: https://github.com/tootsuite/mastodon

This version of Mastodon will include much-wanted changes by the community that are not included
in the upstream version of Mastodon. Migrating from the latest stable release of Mastodon to
Florence's Mastodon will always be possible, to ensure that everyone can benefit from these
changes.

## Versioning

Florence Mastodon uses a four-numbered versioning system, loosely based upon [semantic
versioning]. The four numbers are:
* **Compatibility**: Increased when federation, app compatibility, etc. are changed in a
  non-compatibile way.
* **Feel**: Increased when user experience is changed strongly enough to feel different, i.e. more
  than just small new features.
* **Features**: Increased when new features are added. Reset to zero when **feel** version is
  bumped.
* **Hotfixes**: Increased when fixes are substantial enough to release a new version without any new
  features. Reset to zero when **feature** version is bumped.

For now, because this versioning system hasn't been strongly adopted, releases will be annotated as
**Pre-Release x.y.z**, which is equivalent to version 0.x.y.z.

[semantic versioning]: https://semver.org

## Release timeline

Pre-release 0.1.0 is mostly equivalent to Mastodon 2.9.0, with some extra changes added in.
Right now, the goal before pre-release 1.0.0 is to incorporate existing, already-developed changes
into the fork so that people have a central version to upgrade to. Once we've finally gotten the
software to the point where we like it, we will release the first official release, which will be
named something special. Stay tuned!

## Contributors

### Code Contributors

This project exists thanks to all the people who contribute. [[Contribute](CONTRIBUTING.md)].
<a href="https://github.com/florence-social/mastodon-fork/graphs/contributors"><img src="https://opencollective.com/florence-social/contributors.svg?width=890&button=false" /></a>

### Financial Contributors

Become a financial contributor and help us sustain our community. [[Contribute](https://opencollective.com/florence-social/contribute)]

#### Individuals

<a href="https://opencollective.com/florence-social"><img src="https://opencollective.com/florence-social/individuals.svg?width=890"></a>

#### Organizations

Support this project with your organization. Your logo will show up here with a link to your website. [[Contribute](https://opencollective.com/florence-social/contribute)]

<a href="https://opencollective.com/florence-social/organization/0/website"><img src="https://opencollective.com/florence-social/organization/0/avatar.svg"></a>
<a href="https://opencollective.com/florence-social/organization/1/website"><img src="https://opencollective.com/florence-social/organization/1/avatar.svg"></a>
<a href="https://opencollective.com/florence-social/organization/2/website"><img src="https://opencollective.com/florence-social/organization/2/avatar.svg"></a>
<a href="https://opencollective.com/florence-social/organization/3/website"><img src="https://opencollective.com/florence-social/organization/3/avatar.svg"></a>
<a href="https://opencollective.com/florence-social/organization/4/website"><img src="https://opencollective.com/florence-social/organization/4/avatar.svg"></a>
<a href="https://opencollective.com/florence-social/organization/5/website"><img src="https://opencollective.com/florence-social/organization/5/avatar.svg"></a>
<a href="https://opencollective.com/florence-social/organization/6/website"><img src="https://opencollective.com/florence-social/organization/6/avatar.svg"></a>
<a href="https://opencollective.com/florence-social/organization/7/website"><img src="https://opencollective.com/florence-social/organization/7/avatar.svg"></a>
<a href="https://opencollective.com/florence-social/organization/8/website"><img src="https://opencollective.com/florence-social/organization/8/avatar.svg"></a>
<a href="https://opencollective.com/florence-social/organization/9/website"><img src="https://opencollective.com/florence-social/organization/9/avatar.svg"></a>

## License

Copyright (C) 2016-2019 Florence, Eugen Rochko, and many other Mastodon contributors; see [AUTHORS.md](AUTHORS.md).

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
