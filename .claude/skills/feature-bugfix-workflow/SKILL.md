---
name: feature-bugfix-workflow
description: The required end-to-end workflow for developing a feature (story) or fixing a bug in comtec-academy. Use whenever the user asks to build/add a feature, implement a story, or fix/reproduce a bug. Covers opening the GitHub issue, branch + PR, status labels, mandatory Cucumber test, timing the work, and merging to main + closing the issue.
---

# Feature / Bugfix workflow

Every feature (story) or bugfix in **comtec-academy** follows the same seven
steps, in order. Do not skip a step or reorder them. Each unit of work lives in
its own GitHub issue, its own branch, and its own PR, and ends merged to `main`
with the issue closed.

**Preconditions**
- `gh` CLI must be installed and authenticated (`gh auth status`). All issue/PR
  operations go through `gh`; it infers the repo from `origin`
  (`git@github.com:assaf416/comtec-academy.git`).
- This is a WSL-hosted Rails app. Run tooling through mise, e.g.
  `~/.local/bin/mise exec -- bin/cucumber` and `... bin/rails`.
- Ensure the labels exist once, up front (ignore "already exists" errors):
  ```bash
  gh label create "Story"        2>/dev/null || true
  gh label create "bug"          2>/dev/null || true
  gh label create "started"      2>/dev/null || true
  gh label create "completed"    2>/dev/null || true
  ```

Record timing so we know how long each story took (step 5). Capture a start
epoch the moment you begin implementation:
```bash
t_start=$(date +%s)
```

---

## Step 1 — Open the GitHub issue (story or bug)

Create the issue **before writing any code**. The body must describe three
things: what we are building/the bug, the solution, and how it will be tested.

**Feature / story:**
```bash
gh issue create --label "Story" --title "<story name>" --body "$(cat <<'EOF'
## Description
<what we are developing and why>

## Proposed solution
<how you will implement it>

## How it will be tested
<the Cucumber scenario(s) that prove acceptance>

## Acceptance criteria
- [ ] ...

## Gherkin
```gherkin
Feature: ...
  Scenario: ...
    Given ...
    When ...
    Then ...
```
EOF
)"
```

**Bug:** same command with `--label "bug"`, and a body that instead documents
**Steps to reproduce**, **Expected vs. Actual**, the proposed fix, and a
**regression** Gherkin scenario that fails while the bug exists.

Capture the issue number returned (referred to below as `<n>`).

## Step 2 — Create a branch and PR, link the PR in the issue

Branch off `main` (per repo naming): `story/<n>-<slug>` or `bug/<n>-<slug>`.
```bash
git checkout main && git pull
git checkout -b story/<n>-<short-kebab-slug>
```
Push and open a **draft** PR early so the issue and PR are linked from the
start. The PR body must close the issue:
```bash
git push -u origin HEAD
gh pr create --draft --title "<same as issue>" \
  --body "Closes #<n>

<short summary of the story/bug>"
```
Then post the PR URL back onto the issue as a comment so it is linked there:
```bash
pr_url=$(gh pr view --json url --jq .url)
gh issue comment <n> --body "PR: $pr_url"
```

## Step 3 — Mark the issue "started"

The moment implementation begins:
```bash
gh issue edit <n> --add-label "started"
```
(If a `plan.json` entry exists for this story, also set `status:"in_progress"`
and `started_at` = now.)

## Step 4 — Always add a Cucumber test

Every story/bug **must** ship a Cucumber test. Add a `.feature` file under
`features/` and any new steps under `features/step_definitions/`. Prefer
domain/model-level steps and reuse the existing shared steps
(`auth_steps.rb`, `ui_steps.rb`, etc.) rather than duplicating. The test starts
red and expresses the acceptance criteria (or the regression, for a bug).

Then record the created test file name(s) on the issue:
```bash
gh issue comment <n> --body "Cucumber test(s): features/<name>.feature (+ features/step_definitions/<name>_steps.rb)"
```

## Step 5 — Implement until green, then record status + timing

Implement the code until the new test **and the whole suite** pass:
```bash
~/.local/bin/mise exec -- bin/cucumber           # full suite, must be green
```
When everything is green, compute elapsed time and post it, then flip the
labels:
```bash
elapsed=$(( $(date +%s) - t_start ))
printf 'Completed. Development time: %dh %dm %ds (%ds total)\n' \
  $((elapsed/3600)) $((elapsed%3600/60)) $((elapsed%60)) "$elapsed"

gh issue comment <n> --body "$(printf 'Done — all tests green.\nDevelopment time: %dm %ds (%ds total).' $((elapsed/60)) $((elapsed%60)) "$elapsed")"
gh issue edit <n> --remove-label "started" --add-label "completed"
```
Keep the timing on the issue so we can see how long each story took. If a
`plan.json` entry exists, also set `status:"completed"`, `completed_at`,
`last_tested_at`, and the `code_generation_seconds` /
`test_generation_seconds` fields.

## Step 6 — Commit and merge the branch to `main`

Commit the code + test, mark the PR ready, and merge into `main`:
```bash
git add -A
git commit -m "<story/bug summary> (closes #<n>)"
git push
gh pr ready
gh pr merge --merge --delete-branch
```
(Use whatever merge strategy the repo prefers; `--merge` keeps history simple.
`--delete-branch` cleans up the feature branch.)

## Step 7 — Close the issue

`gh pr merge` with a `Closes #<n>` PR body normally auto-closes the issue.
Confirm it, and close explicitly if it is still open:
```bash
gh issue view <n> --json state --jq .state    # expect CLOSED
gh issue close <n> 2>/dev/null || true
```

---

## Checklist (all must be true before you're done)

1. [ ] Issue opened describing the feature/bug, the solution, and how it's tested
2. [ ] Branch + PR created; PR URL linked on the issue (`Closes #<n>`)
3. [ ] Issue labeled `started` at implementation start
4. [ ] Cucumber test added under `features/`; test file name(s) noted on the issue
5. [ ] Full Cucumber suite green; status `completed` + development time recorded on the issue
6. [ ] Code committed and branch merged to `main`
7. [ ] GitHub issue closed
