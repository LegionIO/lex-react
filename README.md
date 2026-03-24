# lex-react

Reaction engine for LegionIO. Subscribes to `Legion::Events` and fires configurable reaction chains in response to events, with Synapse autonomy gating and loop prevention.

## Configuration

```yaml
react:
  rules:
    ci_failure:
      enabled: true
      source: "github.check_run.completed"
      condition: "conclusion == 'failure'"
      autonomy: FILTER
      chain:
        - lex-github.runners.fetch_check_logs
        - lex-transformer.runners.analyze
  max_depth: 3
  cooldown_seconds: 60
  max_reactions_per_hour: 100
```

## Usage

lex-react auto-subscribes to `Legion::Events` on extension load. Rules are evaluated against every event. Matching rules dispatch task chains respecting Synapse autonomy levels.

## License

MIT
