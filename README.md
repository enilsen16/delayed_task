# DelayedTask

GenStage DelayedTask example from [José's talk](https://www.youtube.com/watch?v=aZuY5-2lwW4) at Elixir London.

## Tags

There are a couple tags that contain different points of his talk.

- `increment_counter` is the example in the beginning of José's talk. All it does is use GenStage to increment a counter.
- `broadcast_increment_to_every_consumer` also increments the a counter but this time each consumer increments independent counters.

## Installation

```bash
git clone https://github.com/enilsen16/delayed_task.git
cd delayed_task
mix deps.get
# To run -
iex -S mix
```
