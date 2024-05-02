# Rails Observability Playbook

## What?

A very simple example Rails app with Open Telemetry installed.

The app is vendor agnostic.

Running on Heroku and is set up to send data to Datadog, but that couuld be anything.

## Why?

Installing Otel in Rails is hard.

Setting up telemetry that's production grade and actually useful is even harder.

I've cut my observability teeth in real Rails production apps.

This is my attempt to start again with what I know and build a best practices app from the ground up.

## How?

* Forked the `opentelemetry-ruby-contrib` library
* Added extra attributes that I've found most useful in production

## Want more?

* Check out my [Rails Observability Playbook](https://joyfulprogramming.notion.site/fb1d870b30b547b6b029d5c48ab300a9) in Notion (work in progress)
* Follow me [on LinkedIn](https://www.linkedin.com/in/synapticmishap/)
* Read my [book Software Design Simplified](https://softwaredesignsimplified.com)
* Subscribe to [my newsletter](https://joyfulprogramming.com)

## Setup

```
bin/setup
```

## Test

```
bin/test
```

## Observability

All traces are sent to Datadog.

Want an invite to play around with the data?

DM [John Gallagher on LinkedIn](https://www.linkedin.com/in/synapticmishap/)

## App

[Visit the app deployed to Heroku here](https://rails-observability-playbook-7734a40c8a6f.herokuapp.com/)

### Functionality

* Single page to the app at the root
* There's a "Refresh" link at the top of the page
* Lists TODOs got from a static endpoint
* When Refresh is hit, it triggers a refresh job
* Click Refresh then see the traces in Datadog
