# Swim AI

A native iOS app, rebuilt from your old web build. Nine Swift files under
`SwimAI/`, plus the files that turn them into a signed build without a Mac
on your end.

## How the pieces fit

- `SwimAI/` holds the actual app: models, screens, HealthKit, and the calls
  out to your backend for coach tips and video analysis.
- `project.yml` is read by a tool called XcodeGen, which turns those Swift
  files into a real Xcode project each time a build runs. You never touch
  this file's output directly.
- `fastlane/` holds the recipe that builds, signs, and uploads the app.
- `.github/workflows/release.yml` is what runs that recipe, on a Mac that
  GitHub provides, each time you trigger it.
- `SETUP.md` is the one time setup, done entirely in a browser and a
  terminal on your own machine. Start there.

## Before any of this works

You still need your own backend running, so the Coach and Video tabs have
something to call. That is the separate `swim-ai-backend` project from
before; deploy that first if you have not already, then set its address in
`SwimAI/Config.swift`.

## Day to day

Once SETUP.md is done once, shipping an update is: change the Swift files,
commit, push to `main` (or run the workflow by hand from the Actions tab),
wait about ten minutes, then finish the listing in App Store Connect from
your browser.
