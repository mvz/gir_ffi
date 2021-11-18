# Contributing to GirFFI

I welcome all contributions to GirFFI. Below are some guidelines to
help the process of handling issues and pull requests go smoothly.

## Issues

When creating an issue, please provide as much information as possible, and
follow the guidelines below to make it easier for me to figure out what's going
on. If you miss any of these points I will probably ask you to improve the
ticket.

- Include a clear title describing the problem
- Describe what you are trying to achieve
- Describe what you did, preferably including relevant code
- Describe what you expected to happen
- Describe what happened instead, possibly including relevant output
- Use [code blocks](https://github.github.com/gfm/#fenced-code-blocks) to
  format any code and output in your ticket to make it readable.

## Pull requests

If you have an idea for a particular feature, it's probably best to create a
GitHub issue for it before trying to implement it yourself. That way, we can
discuss the feature and whether it makes sense to include in GirFFI itself
before putting in the work to implement it.

To send pull requests or patches, please follow the instructions below.
**If you get stuck, please make a pull request anyway and I'll try to
help out.**

- Make sure `rake test` runs without reporting any failures.
- Add tests for your feature. Otherwise, I can't see if it works or if I
  break it later.
- Create a separate branch for your feature based off of latest master.
- Write [good commit messages][1].
- Do not include changes that are irrelevant to your feature in the same
  commit.
- Keep an eye on the build results in GitHub Actions. If the build fails and it
  seems due to your changes, please update your pull request with a fix.

### The review process

- I will try to review your pull request as soon as possible but I can make no
  guarantees. Feel free to ping me now and again.
- I will probably ask you to rebase your branch on current master at some point
  during the review process.
  If you are unsure how to do this,
  [this in-depth guide](https://git-rebase.io/) should help out.
- I don't do squash merges, so you if you have any unclear commit messages,
  work-in-progress commits, or commits that just fix a mistake in a previous
  commits, I will ask you to clean up the history.
  Again, [the git-rebase guide](https://git-rebase.io/) should help out.
- At the end of the review process I may still choose not to merge your pull
  request. For example, this could happen if I decide the proposed feature
  should not be part of GirFFI, or if the technical implementation does not
  match where I want to go with the architecture the project.
- I will generally not merge any pull requests that make the build fail, unless
  it's very clearly not related to the changes in the pull request.

[1]: https://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html
