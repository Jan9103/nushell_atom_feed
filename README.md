# nushell atom feed parser

This [packer.nu][] package adds some basic [atom-feed][atom] parsing functionality.

## Features

- parse a atom feed from a string
  - title
  - last update
  - [ ] id
  - articles
    - [ ] id
    - title
    - author
    - published (date)
    - last update
    - content (& content_type)
    - [ ] links
    - [ ] tags
- display a article using [w3m][]

## Example

A basic feed reader for the nushell blog:
```
use atom_feed.nu

atom_feed parse (fetch -r 'https://www.nushell.sh/feed.atom')
| where published > ((date now) - 10day )
| sort-by published
| each {|i| atom_feed open_article_in_w3m $i }
```

## Dependencies

Required for `atom_feed open_article_in_w3m`:
- [w3m][] (CLI html viewer)


[packer.nu]: https://github.com/jan9103/packer.nu
[w3m]: https://github.com/tats/w3m
[atom]: https://datatracker.ietf.org/doc/html/rfc4287
