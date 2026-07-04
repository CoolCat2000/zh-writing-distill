#!/bin/sh
# 备份现有 AGENTS.md/CLAUDE.md，写入新的 AGENTS.md，并创建 CLAUDE.md 软链接。

set -eu

ROOT="."
CONTENT_FILE=""
READ_STDIN="0"
TIMESTAMP=""

usage() {
  echo "用法：sh scripts/write_memory_files.sh --root <目录> (--stdin | --content-file <文件>) [--timestamp yyyyMMddHHmmss]" >&2
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --root)
      [ "$#" -ge 2 ] || { usage; exit 2; }
      ROOT="$2"
      shift 2
      ;;
    --stdin)
      READ_STDIN="1"
      shift
      ;;
    --content-file)
      [ "$#" -ge 2 ] || { usage; exit 2; }
      CONTENT_FILE="$2"
      shift 2
      ;;
    --timestamp)
      [ "$#" -ge 2 ] || { usage; exit 2; }
      TIMESTAMP="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "错误：未知参数：$1" >&2
      usage
      exit 2
      ;;
  esac
done

if [ "$READ_STDIN" = "1" ] && [ -n "$CONTENT_FILE" ]; then
  echo "错误：--stdin 和 --content-file 只能选择一个。" >&2
  exit 2
fi

if [ "$READ_STDIN" = "0" ] && [ -z "$CONTENT_FILE" ]; then
  echo "错误：必须提供 --stdin 或 --content-file。" >&2
  exit 2
fi

if [ ! -d "$ROOT" ]; then
  echo "错误：目标目录不存在或不是目录：$ROOT" >&2
  exit 1
fi

if [ -z "$TIMESTAMP" ]; then
  TIMESTAMP="$(date +%Y%m%d%H%M%S)"
fi

TMP_FILE="$ROOT/.AGENTS.md.tmp_$TIMESTAMP"
trap 'rm -f "$TMP_FILE"' EXIT HUP INT TERM

if [ "$READ_STDIN" = "1" ]; then
  cat > "$TMP_FILE"
else
  if [ ! -f "$CONTENT_FILE" ]; then
    echo "错误：内容文件不存在：$CONTENT_FILE" >&2
    exit 1
  fi
  cp "$CONTENT_FILE" "$TMP_FILE"
fi

if [ ! -s "$TMP_FILE" ]; then
  echo "错误：AGENTS.md 内容为空，已停止写入。" >&2
  exit 1
fi

# 保证文件以换行结尾，避免后续追加内容粘连。
tail_byte="$(tail -c 1 "$TMP_FILE" 2>/dev/null || true)"
if [ "$tail_byte" != "" ]; then
  printf '\n' >> "$TMP_FILE"
fi

backup_existing() {
  path="$1"
  name="$2"

  if [ ! -e "$path" ] && [ ! -L "$path" ]; then
    return 0
  fi

  backup="$ROOT/$name.bak_$TIMESTAMP"
  index=1
  while [ -e "$backup" ] || [ -L "$backup" ]; do
    backup="$ROOT/$name.bak_${TIMESTAMP}_$index"
    index=$((index + 1))
  done

  mv "$path" "$backup"
  echo "已备份：$backup"
}

backup_existing "$ROOT/AGENTS.md" "AGENTS.md"
backup_existing "$ROOT/CLAUDE.md" "CLAUDE.md"

mv "$TMP_FILE" "$ROOT/AGENTS.md"
trap - EXIT HUP INT TERM

if ! ln -s "AGENTS.md" "$ROOT/CLAUDE.md"; then
  echo "错误：创建 CLAUDE.md 软链接失败。请确认当前文件系统允许创建符号链接。" >&2
  exit 1
fi

echo "已写入：$ROOT/AGENTS.md"
echo "已创建软链接：$ROOT/CLAUDE.md -> AGENTS.md"
