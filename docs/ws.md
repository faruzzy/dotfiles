# ws: a workspace per branch

`ws` (`bin/ws`) gives every branch its own **workspace**: a git worktree, a tmux session named
`<repo>/<branch>` with Neovim in window 1 and Claude in window 2. Switching work means switching
sessions, never stashing, and each branch keeps its own editor, agents and dev servers.

It also reviews other people's pull requests overnight, so in the morning each one is waiting in its
own workspace with Claude's review open.

Nothing is stored about workspaces themselves: `git worktree list` and tmux sessions are the source
of truth.

## Commands

| Command | What it does |
|---|---|
| `ws` | Pick a workspace (fzf). Also `prefix W` in tmux |
| `ws new <branch>` | Create (or switch to) the workspace for a branch in the current repo |
| `ws pr <number>` | The same for a GitHub pull request |
| `ws done` | Remove the current workspace: session, worktree and branch |
| `ws review` | Review other people's new PRs with Claude, each in its workspace |
| `ws prune` | Remove reviewed workspaces whose PR was merged or closed |
| `ws serve on\|off` | Whether a repo's dev server follows you between its workspaces |

`--no-claude` on `ws new` / `ws pr` skips the Claude window.

### `ws new <branch>`

Run it from anywhere in a repo (its main checkout or one of its worktrees). The branch comes from,
in order:

1. the local branch, if it exists
2. `origin/<branch>`, tracked
3. a new branch from the default branch (`origin/main`), freshly fetched. **Not** from the branch
   you're on: to start from another branch, create it first (`git branch <new> <base>`) so rule 1
   applies

The worktree lands in `~/github/.worktrees/<repo>/<branch>`, where `<repo>` is the repo's path
under `~/github` (e.g. `work/customer-portal`). Running it again for the same branch switches to
the existing workspace.

A new worktree only gets tracked files, so `ws` copies the main checkout's gitignored `.env*` and
`*.pem` files (e.g. mkcert certificates for a dev server on HTTPS). It doesn't install
dependencies; it prints the command to run (`npm ci`, `pnpm install`, ...).

### `ws pr <number>`

A workspace for a pull request. A PR from the same repo checks out its branch (tracking origin, so
you can push to it); a PR from a fork becomes a local `pr/<number>` branch from GitHub's
`pull/<number>/head`.

### `ws` (the picker)

| Key | Action |
|---|---|
| `enter` | Open the workspace (recreates its session if it was closed) |
| `ctrl-d` | Remove it (`ws done`, with all its checks) after a `y` |

Each row shows what needs attention:

| Marker | Meaning |
|---|---|
| `●` / `○` | Its tmux session is open / closed |
| `3 changed` | Uncommitted changes |
| `↑2` `↓1` | Commits ahead of / behind its upstream |
| `upstream gone (merged?)`, `no upstream`, `fork PR #7`, `detached` | Branch state |
| `▶ dev :8005` | A package script running there (`npm run dev`, ...) and its ports; `(frontend:2)` when it runs in another tmux session |
| `claude`, `claude working`, `claude waiting 4m` | Claude in that session, and how long it has waited for you |
| `review: SOUND, 0 blocker, 2 should-fix` | `ws review`'s verdict for the checked-out commit |
| `review outdated` | The branch moved since the last review |

The preview shows recent commits, uncommitted changes, the review report, and running scripts with
their PID, start time and tmux window.

### `ws done`

Run it inside the workspace. It removes the session (and everything running in it), the worktree
and the branch, after checking that nothing is lost. It refuses when:

- there are uncommitted changes
- `.env*` / `*.pem` files differ from the main checkout's (copy what you need first)
- the branch has commits on no remote, or its remote branch was deleted without its commits landing
  in the default branch (squash merges count as landed)
- a Neovim in the session, or anywhere holding the worktree's files, has unsaved buffers

It moves you to your previous session first, so the terminal stays open. Claude's conversation is
kept: running `ws new` for that branch again continues it.

### `ws review`

Reviews pull requests by other people, in the repos you list, that changed since the start of the
previous working day (Friday's, on a Monday). A PR is reviewed when it's open, not a draft, not
yours, and nobody has reviewed its **current head commit**: neither `ws` nor you on GitHub. So:

- in the morning, it reviews everything new since yesterday
- run it again in the afternoon, and only PRs with new commits since are reviewed again; that
  review is told about the earlier one and says which findings the new commits resolved
- a PR you already reviewed yourself at that commit is left alone

For each PR it creates or updates the workspace (without opening a session or installing
dependencies), checks out the PR's head, and runs Claude with your reviewer prompt plus a brief: the
diff, the commits, and the PR description as the author's intent. A workspace with your own changes
or commits, or a Neovim with unsaved buffers, is left alone; the next run tries again.

```sh
ws review              # newest first, at most 8 PRs, 2 at a time
ws review --max 3
ws review --dry-run    # list what would be reviewed
```

**Reading the reviews:** open `ws`. Reviewed workspaces show the verdict and the preview shows the
report. `ws review` doesn't open sessions, so opening a reviewed workspace creates one, and its
Claude window starts with `--continue`: the review conversation is right there. Ask follow-ups, or
have it check a claim, with the code at hand.

**Untrusted input:** PR descriptions and code are written by others and could try to instruct
Claude. Reviews run with `claude -p --restricted`: Claude can only read and search files, with no
shell, network, edits, MCP servers or your settings. It doesn't run tests or type checks, and its
report says so under *Could not verify*.

**Reports** live outside the worktree, so they never block `ws done`:
`~/.local/state/ws/reviews/<repo>/<branch>/<commit>.md`, next to the diff that was reviewed. A
review that fails or comes back incomplete saves nothing, so the next run retries it.

#### Configuration

`~/.config/ws/review.json` (machine-local, not in this repo) lists the repos and the reviewer
prompt:

```json
{
  "repos": [
    "~/github/work/customer-portal",
    "~/github/work/lodgelink-ui"
  ],
  "prompt": "~/.claude/skills/red-team/reviewer.md"
}
```

The prompt file holds the reviewer's instructions; `ws` appends the brief and asks for a final
`VERDICT:` line, which the picker shows.

#### Every weekday at 6:30

`install.sh` schedules `ws review` with launchd on any Mac that has `~/.config/ws/review.json`. The
job runs `bin/ws-review-daily` (listed under that name in System Settings → Login Items), which
loads `PATH` from `~/.zshenv` and `GITHUB_TOKEN` from `~/.extra`.

- A Mac asleep at 6:30 runs it on wake; one that's shut down skips the day.
- The summary arrives as a notification ("4 PRs reviewed for $3.10, 1 with blockers"), as does the reason a
  run stopped. macOS sends them as Script Editor: allow its notifications in System Settings.
- If a configured checkout is missing or GitHub fails to list its PRs, the run finishes reviewing the
  reachable repos, names the unavailable ones in its summary, and exits with status 1.
- Output goes to `~/Library/Logs/ws-review.log`.
- `bin/ws-review-daily --dry-run` tries the scheduled run without reviewing anything.

### `ws prune`

Removes the workspaces, branches and reports of reviewed PRs that GitHub reports as merged or
closed. It lists them and asks first (`--yes` doesn't). `ws review`'s summary says when there's
something to prune.

It only removes a workspace exactly as `ws review` left it, and keeps (saying why) one that:

- has uncommitted changes, or commits since the review
- has `.env*` / `*.pem` files that differ from the main checkout's
- has a Neovim with unsaved buffers
- isn't under `~/github/.worktrees`

It also deletes leftover reports of closed PRs whose workspace you already removed.

### Dev servers follow you

For repos listed in `~/.config/ws/serve.json` (machine-local), the dev server runs in whichever of
the repo's workspaces you're in, so the browser always shows the workspace you're looking at:

```json
{
  "~/github/work/customer-portal": { "command": "npm run dev", "setup": "npm ci" }
}
```

A tmux hook runs on every session switch: the picker, `prefix s`, `prefix Tab`, `ws new` / `ws pr`.
When you land in a workspace of a listed repo:

1. If its server already runs there, nothing happens.
2. The repo's server in any other workspace (the main checkout included, and one you started by
   hand) is stopped, and `ws` waits until its port is free. The new one gets the same port, so the
   URL in the browser stays the same; a server that found the port taken would quietly pick
   another.
3. `setup` runs first when `node_modules` is missing or older than `package-lock.json`.
4. `command` starts in a `server` window of the workspace's session, in the background. Its logs
   stay there.

The tmux status line says `ws: dev server → <workspace>` when it moves. Only that repo's server
moves: other scripts (Storybook, tests) and other repos' servers keep running. Switching to a
session that isn't a workspace of a listed repo changes nothing, and neither does a fork PR's
workspace (`pr/<n>`), whose code comes from outside the team. Serving a colleague's PR runs its
code on your Mac, as running it by hand would.

`ws serve off` leaves the server where it is (say, the main checkout's, while you read PRs);
`ws serve on` follows again, starting with the session you're in.

## A typical day

1. **Morning:** the 6:30 run has reviewed overnight PRs. `prefix W`, go through the rows with a
   `review:` verdict, open one, and continue the conversation with Claude, or comment on GitHub.
2. **Your own work:** `ws new CP-1234_feature` (or `ws pr 123` for a colleague's PR you're taking
   over). Commit, push, open the PR.
3. **Afternoon:** `ws review` again for PRs updated since the morning.
4. **Cleanup:** `ws done` in a workspace once its branch is merged; `ws prune` for reviewed PRs that
   closed.

## Settings

| Variable | Default | |
|---|---|---|
| `WS_ROOT` | `~/github/.worktrees` | Where worktrees go |
| `XDG_CONFIG_HOME` | `~/.config` | `ws/review.json`, `ws/serve.json` |
| `XDG_STATE_HOME` | `~/.local/state` | `ws/reviews/`, `ws/serve-paused` |
| `CLAUDE_CONFIG_DIR` | `~/.claude` | Where Claude keeps conversations (for `--continue`) |

## Tests

`tests/ws` runs everything in isolation (scratch `HOME`, its own tmux server, stand-ins for `gh`,
`claude` and `npm`), so it never touches real repos or sessions.
