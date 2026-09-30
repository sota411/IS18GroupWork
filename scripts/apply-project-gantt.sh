#!/usr/bin/env bash
set -euo pipefail

OWNER="sota411"
PROJECT_NUMBER="5"
REPO="sota411/IS18GroupWork"
PROJECT_URL="https://github.com/users/sota411/projects/5"

command -v gh >/dev/null 2>&1 || {
  echo "ERROR: GitHub CLI (gh) が見つかりません。"
  echo "Arch Linux: sudo pacman -S github-cli"
  exit 1
}

if ! gh auth status >/dev/null 2>&1; then
  echo "ERROR: gh にログインしていません。"
  echo "実行: gh auth login"
  exit 1
fi

if ! gh project view "\${PROJECT_NUMBER}" --owner "\${OWNER}" >/dev/null 2>&1; then
  echo "ERROR: Project #\${PROJECT_NUMBER} を操作できません。"
  echo
  echo "Projects の権限が足りない場合は、先に次を実行してください:"
  echo "  gh auth refresh -s project"
  exit 1
fi

echo "==> Project #\${PROJECT_NUMBER} をリポジトリにリンク"
gh project link "\${PROJECT_NUMBER}" --owner "\${OWNER}" --repo "\${REPO}" >/dev/null 2>&1 || true

ensure_date_field() {
  local field_name="$1"
  if gh project field-list "\${PROJECT_NUMBER}" --owner "\${OWNER}" --format json --jq '.fields[].name' | grep -Fxq "\${field_name}"; then
    echo "==> \${field_name}: 既存"
  else
    echo "==> \${field_name}: 作成"
    gh project field-create "\${PROJECT_NUMBER}" \
      --owner "\${OWNER}" \
      --name "\${field_name}" \
      --data-type DATE >/dev/null
  fi
}

ensure_date_field "Start date"
ensure_date_field "Target date"

TASKS=$(cat <<'EOF'
1|2026-09-30|2026-09-30
2|2026-09-30|2026-10-01
3|2026-10-01|2026-10-02
4|2026-10-02|2026-10-04
5|2026-10-02|2026-10-04
6|2026-10-05|2026-10-07
7|2026-10-05|2026-10-07
8|2026-10-07|2026-10-08
9|2026-10-08|2026-10-10
10|2026-10-10|2026-10-12
11|2026-10-11|2026-10-13
12|2026-10-09|2026-10-14
13|2026-10-14|2026-10-16
14|2026-10-16|2026-10-18
15|2026-10-18|2026-10-21
16|2026-10-21|2026-10-24
17|2026-10-22|2026-10-28
18|2026-10-26|2026-10-28
19|2026-10-28|2026-11-03
20|2026-11-02|2026-11-04
EOF
)

echo "==> Issue #1〜#20 を Project に追加して日付を設定"

while IFS='|' read -r issue start target; do
  [[ -z "\${issue}" ]] && continue

  url="https://github.com/\${REPO}/issues/\${issue}"
  printf "  #%s  %s -> %s ... " "\${issue}" "\${start}" "\${target}"

  gh project item-add "\${PROJECT_NUMBER}" \
    --owner "\${OWNER}" \
    --url "\${url}" >/dev/null 2>&1 || true

  gh project item-edit "\${PROJECT_NUMBER}" \
    --owner "\${OWNER}" \
    --url "\${url}" \
    --field "Start date" \
    --date "\${start}" >/dev/null

  gh project item-edit "\${PROJECT_NUMBER}" \
    --owner "\${OWNER}" \
    --url "\${url}" \
    --field "Target date" \
    --date "\${target}" >/dev/null

  echo "OK"
done <<< "\${TASKS}"

echo
echo "==> 設定結果"
gh project item-list "\${PROJECT_NUMBER}" \
  --owner "\${OWNER}" \
  --limit 100 \
  --field "Start date" \
  --field "Target date"

echo
echo "完了: \${PROJECT_URL}"
echo
echo "GitHub で Project #\${PROJECT_NUMBER} を開き、View の Layout を Roadmap にしてください。"
echo "Roadmap の Date fields で Start date / Target date を選べば、バー表示されます。"
