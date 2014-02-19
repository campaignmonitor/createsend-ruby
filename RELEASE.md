# Releasing createsend-ruby

## Requirements

- You must have a [RubyGems.org](https://rubygems.org/) account and must be an owner of the [createsend](https://rubygems.org/gems/createsend) gem.

  Owners can be added to the `createsend` gem like this:

  ```
  gem owner createsend -a newowner@example.com
  ```

## Prepare the release

- Increment the `VERSION` constant in the `lib/createsend/version.rb` file, ensuring that you use [Semantic Versioning](http://semver.org/).
- Add an entry to `HISTORY.md` which clearly explains the new release.
- Commit your changes:

  ```
  git commit -am "Version X.Y.Z"
  ```

- Tag the new version:

  ```
  git tag -a vX.Y.Z -m "Version X.Y.Z"
  ```

- Push your changes to GitHub, including the tag you just created:

  ```
  git push origin master --tags
  ```

- Ensure that all [tests](https://travis-ci.org/campaignmonitor/createsend-ruby) pass, and that [coverage](https://coveralls.io/r/campaignmonitor/createsend-ruby) is maintained or improved.

- Add a new [GitHub Release](https://github.com/campaignmonitor/createsend-ruby/releases) using the newly created tag.

## Build the gem

```
rake build
```

This builds the gem locally to a file named something like `createsend-X.Y.Z.gem`. You're now ready to release the gem.

## Release the gem

```
rake release
```

This publishes the gem to [RubyGems.org](https://rubygems.org/gems/createsend). You should see the newly published version of the gem there. All done!
