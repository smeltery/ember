import "./styles.css";

interface AgentLogo {
  name: string;
  src: string;
  mode: "hooks" | "process";
}

const AGENTS: AgentLogo[] = [
  { name: "Claude Code", src: "/agents/agent-claude-code.svg", mode: "hooks" },
  { name: "ChatGPT / Codex", src: "/agents/agent-codex.png", mode: "hooks" },
  { name: "OpenCode", src: "/agents/agent-opencode.png", mode: "hooks" },
  { name: "Gemini CLI", src: "/agents/agent-gemini.svg", mode: "hooks" },
  { name: "Pi", src: "/agents/agent-pi.svg", mode: "hooks" },
  { name: "Copilot CLI", src: "/agents/agent-copilot.svg", mode: "hooks" },
  { name: "Hermes", src: "/agents/agent-hermes.png", mode: "hooks" },
  { name: "Cursor", src: "/agents/agent-cursor-agent.png", mode: "process" },
  { name: "Cline", src: "/agents/agent-cline.png", mode: "process" },
];

const FEATURES = [
  {
    title: "Agent-driven wake lock",
    body: "Holds PreventUserIdleSystemSleep only while a watched agent is mid-task. Idle agents let the Mac sleep again.",
  },
  {
    title: "Lifecycle hooks",
    body: "Claude Code, Codex, OpenCode, Gemini, Pi, Copilot CLI, and Hermes report real Working / Idle state per session.",
  },
  {
    title: "Process detection",
    body: "Cursor and Cline are watched by process name when hooks are not available — still automatic, still hands-off.",
  },
  {
    title: "Pause when you need it",
    body: "One-click pause for 30 minutes or 1 hour from the menu bar, then ember resumes watching on its own.",
  },
];

function agentCells(): string {
  return AGENTS.map(
    (a, i) => `
    <li class="agent" style="--i:${i}">
      <img src="${a.src}" alt="" width="40" height="40" loading="lazy" />
      <div>
        <strong>${a.name}</strong>
        <span>${a.mode === "hooks" ? "lifecycle hooks" : "process detection"}</span>
      </div>
    </li>`,
  ).join("");
}

function featureCells(): string {
  return FEATURES.map(
    (f) => `
    <li class="feature">
      <h3>${f.title}</h3>
      <p>${f.body}</p>
    </li>`,
  ).join("");
}

const app = document.querySelector<HTMLDivElement>("#app");
if (!app) throw new Error("#app missing");

app.innerHTML = `
  <header class="top">
    <a class="brand-mini" href="#top" aria-label="ember home">
      <img src="/icon.png" alt="" width="28" height="28" />
      <span>ember</span>
    </a>
    <nav>
      <a href="#features">Features</a>
      <a href="#agents">Agents</a>
      <a href="#docs">Docs</a>
      <a class="nav-cta" href="#download">Download</a>
    </nav>
  </header>

  <main id="top">
    <section class="hero" aria-label="ember">
      <div class="hero-bg" aria-hidden="true"></div>
      <div class="hero-veil" aria-hidden="true"></div>
      <div class="hero-copy">
        <p class="brand">ember</p>
        <h1>Close the lid. Keep coding.</h1>
        <p class="lede">
          Your agents finish the job with the lid shut — ember holds the Mac awake
          only while they work, then lets sleep return.
        </p>
        <div class="cta">
          <a class="btn primary" href="#download">Download</a>
          <a class="btn ghost" href="#docs">Docs</a>
        </div>
      </div>
    </section>

    <section id="features" class="section">
      <h2>Built for agents, not babysitting</h2>
      <p class="section-lede">
        A menu-bar keep-awake that understands Working versus Idle — so you can
        close the lid and walk away.
      </p>
      <ul class="features">${featureCells()}</ul>
    </section>

    <section id="agents" class="section section-alt">
      <h2>Watches the agents you already use</h2>
      <p class="section-lede">
        Hooks where the tool exposes them. Process detection where it does not.
      </p>
      <ul class="agents">${agentCells()}</ul>
    </section>

    <section id="battery" class="section">
      <h2>Battery guardrails, not runaway drain</h2>
      <p class="section-lede">
        Configurable cut-off (default 15%), optional plugged-in-only mode,
        respect for Low Power Mode, and display-off while agents run.
      </p>
      <ul class="bullets">
        <li>Stops holding wake below your threshold</li>
        <li>Optional: only when charging</li>
        <li>Honors macOS Low Power Mode</li>
        <li>Display can sleep while work continues</li>
      </ul>
    </section>

    <section id="caffeine" class="section section-alt">
      <h2>Not another manual caffeine toggle</h2>
      <p class="section-lede">
        Caffeine and Amphetamine keep the Mac awake while you leave them on or
        while a process exists. ember reads agent lifecycle signals, holds
        PreventUserIdleSystemSleep only mid-task, and releases automatically
        when work finishes — including with the lid closed.
      </p>
    </section>

    <section id="privacy" class="section">
      <h2>Local only. Your code stays yours.</h2>
      <p class="section-lede">
        ember never reads your prompts, terminal output, or source. It only
        receives Working / Idle hook signals and talks to macOS power APIs on
        your machine.
      </p>
    </section>

    <section id="download" class="section section-cta">
      <h2>Stop babysitting your laptop</h2>
      <p class="section-lede">
        Close the lid, walk away, and let your agents finish. ember handles the rest.
      </p>
      <div class="cta">
        <a class="btn primary" href="https://github.com/smeltery/ember/releases">Download for macOS</a>
        <a class="btn ghost" id="docs" href="https://github.com/smeltery/ember">Docs on GitHub</a>
      </div>
    </section>
  </main>

  <footer class="foot">
    <span>ember — open source</span>
    <a href="https://github.com/smeltery/ember">GitHub</a>
  </footer>
`;

requestAnimationFrame(() => {
  document.body.classList.add("ready");
});
