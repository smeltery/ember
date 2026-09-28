import "./styles.css";

const COPY =
  "gh release download -R smeltery/ember -p ember-macos-arm64";

const DEMO_MS = 2400;

const DEMO_STEPS = [
  {
    key: "working",
    lidOpen: true,
    awake: true,
    agent: "working",
    title: "Your agent is working",
    sub: "Claude Code is mid-task, lid open.",
  },
  {
    key: "closed",
    lidOpen: false,
    awake: true,
    agent: "working",
    title: "You close the lid",
    sub: "Laptop goes in the bag.",
  },
  {
    key: "held",
    lidOpen: false,
    awake: true,
    agent: "working",
    emphasize: true,
    title: "Mac stays awake",
    sub: "ember holds the wake assertions.",
  },
  {
    key: "done",
    lidOpen: false,
    awake: true,
    agent: "idle",
    title: "Agent finishes",
    sub: "Idle for 30 seconds…",
  },
  {
    key: "sleep",
    lidOpen: false,
    awake: false,
    agent: "idle",
    title: "Mac sleeps",
    sub: "Assertions released. Battery saved.",
  },
] as const;

function reveal() {
  const nodes = document.querySelectorAll<HTMLElement>(".reveal, .reveal-hero");
  const markDone = (node: HTMLElement) => {
    node.classList.add("is-in", "is-done");
  };
  const io = new IntersectionObserver(
    (entries) => {
      for (const entry of entries) {
        if (!entry.isIntersecting) continue;
        const node = entry.target as HTMLElement;
        node.classList.add("is-in");
        const finish = () => markDone(node);
        node.addEventListener("transitionend", finish, { once: true });
        // Fallback if transitionend never fires (already visible / reduced motion).
        window.setTimeout(finish, 800);
        io.unobserve(node);
      }
    },
    { rootMargin: "0px 0px -8% 0px", threshold: 0.12 },
  );
  for (const node of nodes) io.observe(node);
  requestAnimationFrame(() => {
    for (const node of document.querySelectorAll<HTMLElement>(
      ".reveal, .reveal-hero",
    )) {
      if (node.getBoundingClientRect().top < window.innerHeight * 0.92) {
        node.classList.add("is-in");
        window.setTimeout(() => markDone(node), 800);
      }
    }
  });
}

function wireCopy() {
  for (const btn of document.querySelectorAll<HTMLButtonElement>(
    'button[aria-label="Copy install command"]',
  )) {
    btn.addEventListener("click", async () => {
      try {
        await navigator.clipboard.writeText(COPY);
        btn.dataset.copied = "1";
        setTimeout(() => {
          delete btn.dataset.copied;
        }, 1600);
      } catch {
        /* ignore */
      }
    });
  }
}

function badgeLabel(step: (typeof DEMO_STEPS)[number]): string {
  if (!step.awake) return "asleep";
  return step.lidOpen ? "awake" : "awake · lid closed";
}

function wireDemo() {
  const root = document.querySelector<HTMLElement>("[data-demo-root]");
  if (!root) return;

  const badge = root.querySelector<HTMLElement>("[data-demo-badge]");
  const badgeDot = root.querySelector<HTMLElement>("[data-demo-badge-dot]");
  const badgeLabelEl = root.querySelector<HTMLElement>("[data-demo-badge-label]");
  const lid = root.querySelector<HTMLElement>("[data-demo-lid]");
  const screen = root.querySelector<HTMLElement>("[data-demo-screen]");
  const hinge = root.querySelector<HTMLElement>("[data-demo-hinge]");
  const pulse = root.querySelector<HTMLElement>("[data-demo-pulse]");
  const zzz = root.querySelector<HTMLElement>("[data-demo-zzz]");
  const copy = root.querySelector<HTMLElement>("[data-demo-copy]");
  const agentPing = root.querySelector<HTMLElement>("[data-demo-agent-ping]");
  const agentCore = root.querySelector<HTMLElement>("[data-demo-agent-core]");
  const agentLabel = root.querySelector<HTMLElement>("[data-demo-agent-label]");
  const title = root.querySelector<HTMLElement>("[data-demo-title]");
  const sub = root.querySelector<HTMLElement>("[data-demo-sub]");
  const bars = [
    ...root.querySelectorAll<HTMLElement>(".demo-bar"),
  ];

  let index = 0;
  let timer: ReturnType<typeof setInterval> | undefined;

  const paint = (stepIndex: number) => {
    const step = DEMO_STEPS[stepIndex];
    if (!step) return;

    if (badge && badgeDot && badgeLabelEl) {
      badgeLabelEl.textContent = badgeLabel(step);
      badge.classList.toggle("bg-accent-soft", step.awake);
      badge.classList.toggle("text-accent", step.awake);
      badge.classList.toggle("bg-black/[0.06]", !step.awake);
      badge.classList.toggle("text-ink-3", !step.awake);
      badge.classList.toggle("shadow-glow", Boolean(step.emphasize && step.awake));
      badgeDot.classList.toggle("bg-accent", step.awake);
      badgeDot.classList.toggle("bg-ink-3", !step.awake);
    }

    if (lid) lid.style.height = step.lidOpen ? "118px" : "13px";
    if (screen) screen.style.opacity = step.lidOpen ? "1" : "0";
    if (hinge) hinge.style.opacity = step.lidOpen ? "0" : "1";
    if (pulse) {
      pulse.classList.toggle("animate-pulse-ring", step.awake && !step.lidOpen);
      pulse.style.opacity = step.awake && !step.lidOpen ? "1" : "0";
    }
    if (zzz) {
      zzz.style.opacity = step.awake ? "0" : "1";
      zzz.style.transform = step.awake ? "translateY(8px)" : "translateY(-6px)";
    }

    if (agentPing) agentPing.style.display = step.agent === "working" ? "" : "none";
    if (agentCore) {
      agentCore.classList.toggle("bg-accent", step.agent === "working");
      agentCore.classList.toggle("bg-ink-3", step.agent !== "working");
    }
    if (agentLabel) {
      agentLabel.textContent =
        step.agent === "working" ? "agent working" : "agent idle";
    }
    if (title) title.textContent = step.title;
    if (sub) sub.textContent = step.sub;
    if (copy) {
      copy.classList.remove("demo-copy-in");
      // restart fade
      void copy.offsetWidth;
      copy.classList.add("demo-copy-in");
    }

    if (stepIndex === 0) {
      for (const bar of bars) {
        bar.style.transition = "none";
        bar.style.width = "0%";
      }
      // Force reflow so the fill animation restarts on loop.
      void root.offsetWidth;
    }

    for (let i = 0; i < bars.length; i++) {
      const bar = bars[i];
      if (!bar) continue;
      const fill = i <= stepIndex;
      bar.style.transition =
        i === stepIndex ? `width ${DEMO_MS}ms linear` : "width 0.3s ease";
      bar.style.width = fill ? "100%" : "0%";
    }
  };

  const start = () => {
    if (timer) return;
    paint(0);
    timer = setInterval(() => {
      index = (index + 1) % DEMO_STEPS.length;
      paint(index);
    }, DEMO_MS);
  };

  const stop = () => {
    if (!timer) return;
    clearInterval(timer);
    timer = undefined;
  };

  const io = new IntersectionObserver(
    (entries) => {
      for (const entry of entries) {
        if (entry.isIntersecting) start();
        else stop();
      }
    },
    { rootMargin: "-20% 0px -20% 0px", threshold: 0 },
  );
  io.observe(root);

  if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
    paint(0);
    return;
  }
}

reveal();
wireCopy();
wireDemo();
