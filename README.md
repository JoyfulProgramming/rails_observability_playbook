# Rails Observability Playbook

## What?

A very simple example Rails app with Open Telemetry installed.

Accompanies my [Rails Observability Playbook](https://joyfulprogramming.notion.site/fb1d870b30b547b6b029d5c48ab300a9) in Notion.

Running on Heroku and is set up to send data to Datadog, but the app is vendor agnostic.

## Why?

Installing Otel in Rails is hard.

Setting up telemetry that's production grade and actually useful is even harder.

I do the hard work of figuring out Open Telemetry in Rails so you don't have to.

I'll be deploying this to production sites when it's stable enough.

### Functionality

* Single page to the app at the root
* There's a "Refresh" link at the top of the page
* Lists TODOs got from a static endpoint
* When Refresh is hit, it triggers a refresh job
* Click Refresh then see the traces in Datadog
* All traces are sent to Datadog.
* Want an invite to play around with the data?  [DM John Gallagher on LinkedIn](https://www.linkedin.com/in/synapticmishap/)

## Setup

```
bin/setup
```

## Test

```
bin/test
```

## Want more?

* Check out my [Rails Observability Playbook](https://joyfulprogramming.notion.site/fb1d870b30b547b6b029d5c48ab300a9) in Notion (work in progress)
* Follow me [on LinkedIn](https://www.linkedin.com/in/synapticmishap/)
* Read my [book Software Design Simplified](https://softwaredesignsimplified.com)
* Subscribe to [my newsletter](https://joyfulprogramming.com)
