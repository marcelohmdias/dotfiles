#!/bin/sh

cd "$HERDR_ACTIVE_PANE_CWD" 2>/dev/null || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

# --- Símbolos (iguais ao seu gitmux) ---
SYM_BRANCH=' '
SYM_HASH=':'
SYM_INSERTIONS=' '
SYM_DELETIONS=' '
SYM_MODIFIED=' '
SYM_AHEAD=' '
SYM_BEHIND=' '
SYM_UNTRACKED=' '
SYM_STAGED=' '
SYM_CONFLICT=' '
SYM_STASHED=' '

# --- 1. Branch ou Hash (detached) ---
branch=$(git symbolic-ref --short HEAD 2>/dev/null)
if [ -n "$branch" ]; then
  out="${SYM_BRANCH}${branch}"
else
  hash=$(git rev-parse --short HEAD 2>/dev/null)
  out="${SYM_BRANCH}${SYM_HASH}${hash}"
fi

# --- 2. Divergence (behind primeiro, pois swap_divergence: false) ---
porcelain=$(git status --porcelain=v2 --branch 2>/dev/null)
ab=$(printf "%s\n" "$porcelain" | awk '/^# branch\.ab / {print $3, $4}')
ahead=$(printf "%s" "$ab" | awk '{gsub(/\+/,"",$1); print $1+0}')
behind=$(printf "%s" "$ab" | awk '{gsub(/-/,"",$2); print $2+0}')

div=""
[ "$behind" -gt 0 ] && div="${div}${SYM_BEHIND}${behind} "
[ "$ahead" -gt 0 ] && div="${div}${SYM_AHEAD}${ahead} "
[ -n "$div" ] && out="$out ${div% }"

# --- 3. Stats (linhas inseridas e deletadas) ---
stats_raw=$(git diff --numstat HEAD 2>/dev/null | awk '{ins+=$1; del+=$2} END {print ins+0, del+0}')
ins=$(printf "%s" "$stats_raw" | awk '{print $1}')
del=$(printf "%s" "$stats_raw" | awk '{print $2}')

stats=""
[ "$ins" -gt 0 ] && stats="${stats}${SYM_INSERTIONS}${ins} "
[ "$del" -gt 0 ] && stats="${stats}${SYM_DELETIONS}${del} "
[ -n "$stats" ] && out="$out ${stats% }"

# --- 4. Flags (staged, conflicts, modified, untracked, stashed) ---
staged=$(printf "%s\n" "$porcelain" | awk '/^[12] [MARCDU]./ {c++} END {print c+0}')
modified=$(printf "%s\n" "$porcelain" | awk '/^[12] .[MARCDU]/ {c++} END {print c+0}')
conflicts=$(printf "%s\n" "$porcelain" | awk '/^u / {c++} END {print c+0}')
untracked=$(printf "%s\n" "$porcelain" | awk '/^\? / {c++} END {print c+0}')
stashed=$(git rev-list --walk-reflogs --count refs/stash 2>/dev/null || echo 0)

flags=""
[ "$staged" -gt 0 ] && flags="${flags}${SYM_STAGED}${staged} "
[ "$conflicts" -gt 0 ] && flags="${flags}${SYM_CONFLICT}${conflicts} "
[ "$modified" -gt 0 ] && flags="${flags}${SYM_MODIFIED}${modified} "
[ "$untracked" -gt 0 ] && flags="${flags}${SYM_UNTRACKED}${untracked} "
[ "$stashed" -gt 0 ] && flags="${flags}${SYM_STASHED}${stashed} "

# hide_clean: true (só adiciona flags se houver alterações)
[ -n "$flags" ] && out="$out ${flags% }"

echo "$out"
