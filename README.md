# rbspy Agency

We're gonna find that mole...

This script was created from a need to run `rbspy` inside a sidekiq worker container running on the
[@htdc](https://github.com/htdc) Kubernetes cluster, to try and work out what was causing impacts to performance under
heavy load.

Note: This is a stop-gap / tactical fix. Please consider using other tools to analyse performance long term :)

## Pre-flight (Sanity) Checks

* Correct `kubectl` context (`kubectl config get-contexts`)
* Calls need to be authenticated (e.g. `aws-vault exec production -- ./pod-finder.sh sidekiq-pod-prefix`)
* The `SYS_PTRACE` capability has been added to the container as per the 
  [rbspy docs](https://rbspy.github.io/using-rbspy/#containers)

## Usage

### pod-finder.sh

Returns a list of pods for you to target

### pod-profiler.sh

Example usage:

```bash
./pod-profiler.sh sidekiq-pod-prefix
```

Copies `profiler.sh` to the selected pod, runs it, and downloads the results

### rbspy/profiler.sh

This is the script that runs in the pod - It downloads rbspy, runs it, and saves the output to a file that's downloaded
after execution of this script finishes.
