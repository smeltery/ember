# Getting started

Install ember, run the menu bar app once, then wire agent hooks so Working / Idle
signals reach the app.

## Install from releases

1. Open the [GitHub Releases](https://github.com/smeltery/ember/releases) page.
2. Download the latest macOS build (Apple silicon or Intel as labeled).
3. Open the app (Gatekeeper may ask you to confirm an unsigned or notarized build).
4. Confirm **ember** appears in the menu bar.

> Prefer building from source? See [Development](development.md).

## First run

On launch ember:

- Shows **Idle** until an agent reports Working (or a watched process appears)
- Reads battery via `pmset` and applies default guardrails (15% cut-off)
- Starts `caffeinate -is` only while wake should be held

Menu items:

| Item | Action |
| --- | --- |
| Status | Awake / Idle / Paused |
| Battery note | Percent, plug state, block reason |
| Agents | Summary of working sessions / processes |
| Pause 30 min / 1 hour | Release wake until the timer ends |
| Resume | Clear an active pause |
| Quit | Stop caffeinate and exit |

## Enable hooks

Hook-based agents write JSON under:

`~/Library/Application Support/ember/sessions/<agent>/<session>.json`

Scripts live in [`hooks/`](../hooks/). Make them executable:

```bash
chmod +x hooks/*.sh
```

Point each agent's lifecycle hooks at the matching script (see [Agents](agents.md)).

Minimal smoke test without an agent:

```bash
./hooks/generic-working.sh demo session-1
# menu bar should move toward Awake (battery permitting)
./hooks/generic-idle.sh demo session-1
```

## Next

- [How it works](how-it-works.md)
- [Battery guardrails](battery.md)
