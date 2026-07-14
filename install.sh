#!/usr/bin/env bash
# One-command installer for the "ai-security-research-assistant" OpenCode skill.
#
# Usage (once this repo is on GitHub):
#   curl -fsSL https://raw.githubusercontent.com/<YOUR_GH_USER>/<YOUR_REPO>/main/install.sh | bash
#
# Or run locally from inside the extracted/cloned folder:
#   bash install.sh
#
# Installs to the OpenCode GLOBAL skills directory so it works in every
# project, on Termux/Linux/macOS, without touching any repo.

set -euo pipefail

SKILL_NAME="secure-development-assistant"

# EDIT THIS after you push the skill folder to your own GitHub repo:
REPO_URL="https://github.com/Rishav7324/ai-security-research-assistant.git"

TARGET_DIR="${HOME}/.config/opencode/skills/${SKILL_NAME}"
SCRIPT_DIR="$(pwd)"

echo "==> Installing OpenCode skill: ${SKILL_NAME}"
mkdir -p "${HOME}/.config/opencode/skills"

# Clean up the old pre-upgrade skill name, if present, so there's no stale duplicate.
OLD_TARGET="${HOME}/.config/opencode/skills/ai-security-research-assistant"
if [ -d "${OLD_TARGET}" ]; then
  echo "==> Removing old skill folder (renamed to ${SKILL_NAME})..."
  rm -rf "${OLD_TARGET}"
fi

# Remove any previous install so this is safe to re-run (idempotent).
if [ -d "${TARGET_DIR}" ]; then
  echo "==> Existing install found, replacing it..."
  rm -rf "${TARGET_DIR}"
fi

if [ -d "${SCRIPT_DIR}/${SKILL_NAME}" ]; then
  # Case 1: running locally, skill folder sits next to this script
  echo "==> Copying local skill folder..."
  cp -r "${SCRIPT_DIR}/${SKILL_NAME}" "${TARGET_DIR}"

elif [ -f "${SCRIPT_DIR}/SKILL.md" ]; then
  # Case 2: script itself lives inside the skill folder
  echo "==> Copying current folder as the skill..."
  mkdir -p "${TARGET_DIR}"
  cp -r "${SCRIPT_DIR}/." "${TARGET_DIR}/"
  rm -f "${TARGET_DIR}/install.sh"

else
  # Case 3: piped via curl | bash with no local files -> pull from GitHub
  if ! command -v git >/dev/null 2>&1; then
    echo "ERROR: git not found. Install git first (e.g. 'pkg install git' on Termux)." >&2
    exit 1
  fi
  echo "==> Cloning skill from ${REPO_URL} ..."
  git clone --depth 1 "${REPO_URL}" "/tmp/${SKILL_NAME}-install"
  SRC="/tmp/${SKILL_NAME}-install"
  [ -d "${SRC}/${SKILL_NAME}" ] && SRC="${SRC}/${SKILL_NAME}"
  mkdir -p "${TARGET_DIR}"
  cp -r "${SRC}/." "${TARGET_DIR}/"
  rm -rf "${TARGET_DIR}/.git" "${TARGET_DIR}/install.sh"
  rm -rf "/tmp/${SKILL_NAME}-install"
fi

echo ""
echo "✅ Installed at: ${TARGET_DIR}"
echo "   Restart your OpenCode session — the skill will show up automatically"
echo "   whenever you're building auth/login/session/API/billing features, or"
echo "   ask for a security review of existing code/config."
