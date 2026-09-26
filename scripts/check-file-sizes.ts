#!/usr/bin/env bun
import { $ } from "bun";
import { readFileSync } from "node:fs";

const repoRoot = (await $`git rev-parse --show-toplevel`.text()).trim();
process.chdir(repoRoot);

const budgetsFile = Bun.argv[2] ?? "scripts/file-size-budgets.json";
const budgets = JSON.parse(readFileSync(budgetsFile, "utf8")) as {
  default_lines: number;
  files: Record<string, number>;
};

const tracked = (await $`git ls-files`.text()).split("\n").filter(Boolean);
const suffix = /\.(ts|tsx|js|mjs|cjs|md|mdx|css|json|toml|ya?ml|swift|sh)$/;
const excluded = /(^bun\.lock$)/;

let fail = false;
let checked = 0;

for (const file of tracked) {
  if (!suffix.test(file) || excluded.test(file)) continue;
  const path = `${repoRoot}/${file}`;
  if (!(await Bun.file(path).exists())) continue;
  checked += 1;
  const lines = (await Bun.file(path).text()).split("\n").length;
  const budget = budgets.files[file] ?? budgets.default_lines;
  if (lines > budget) {
    console.log(`FAIL: ${file}: ${lines} lines > budget ${budget}`);
    fail = true;
  }
}

if (fail) {
  console.error(`file size budget check failed (checked ${checked} files)`);
  process.exit(1);
}

console.log(
  `file size budget check passed (${checked} files, default budget ${budgets.default_lines} lines)`,
);
