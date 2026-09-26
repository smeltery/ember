#!/usr/bin/env bun
import { $ } from "bun";
import { dirname } from "node:path";
import { readFileSync } from "node:fs";

const repoRoot = (await $`git rev-parse --show-toplevel`.text()).trim();
process.chdir(repoRoot);

const budgetsFile = Bun.argv[2] ?? "scripts/flat-directory-budgets.json";
const budgets = JSON.parse(readFileSync(budgetsFile, "utf8")) as {
  default_files: number;
  directories: Record<string, { limit: number; reason?: string }>;
};

const tracked = (await $`git ls-files`.text()).split("\n").filter(Boolean);
const skip =
  /(^|\/)(node_modules|target|dist|build|deps|_build|site|fixtures|vendor|\.build)(\/|$)/;
const counts = new Map<string, number>();

for (const file of tracked) {
  if (skip.test(file)) continue;
  const dir = dirname(file);
  counts.set(dir, (counts.get(dir) ?? 0) + 1);
}

let fail = false;
for (const [dir, count] of [...counts.entries()].sort()) {
  const budget = budgets.directories[dir]?.limit ?? budgets.default_files;
  if (count > budget) {
    console.log(`FAIL: ${dir}: ${count} files > budget ${budget}`);
    fail = true;
  }
}

if (fail) {
  console.error("flat directory budget check failed");
  process.exit(1);
}

console.log(
  `flat directory budget check passed (default budget ${budgets.default_files} files/dir)`,
);
