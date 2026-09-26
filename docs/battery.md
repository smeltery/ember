# Battery guardrails

ember refuses to hold wake when power policy says no — even if agents are
Working. Defaults match the TypeScript and Swift cores.

## Defaults

| Setting | Default | Effect |
| --- | --- | --- |
| Cut-off percent | `15` | Below this %, wake is not held |
| Only when plugged in | `false` | When `true`, battery power blocks wake |
| Respect Low Power Mode | `true` | macOS LPM blocks wake |
| Display off while working | `false` | Preference for display sleep (app may use later) |

The menu bar app stores **batteryCutoff** and **onlyWhenPluggedIn** in
`UserDefaults`.

## Decision order

1. Active **pause** (30 min / 1 hour) → no wake
2. Battery policy fails → no wake (mode may still show Working)
3. No working sessions/processes → Idle, no wake
4. Otherwise → hold wake (`caffeinate -is`)

## Tips

- On long flights, raise the cut-off or enable plugged-in-only
- Low Power Mode always wins when respect is enabled
- Pause from the menu when you want sleep regardless of agents

See also [How it works](how-it-works.md).
