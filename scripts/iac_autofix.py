#!/usr/bin/env python3
"""
iac_autofix.py — Auto-fix IaC errors from Checkov, TFLint, and Pre-commit
using Claude or Gemini depending on the LLM_PROVIDER environment variable.

Usage:
    LLM_PROVIDER=claude  python3 scripts/iac_autofix.py --error-file errors.txt
    LLM_PROVIDER=gemini  python3 scripts/iac_autofix.py --error-file errors.txt

Environment variables:
    LLM_PROVIDER          : "claude" (default) or "gemini"
    ANTHROPIC_API_KEY     : Required when LLM_PROVIDER=claude
    GEMINI_API_KEY        : Required when LLM_PROVIDER=gemini
    CLAUDE_MODEL          : Optional — default: claude-sonnet-5-5
    GEMINI_MODEL          : Optional — default: gemini-3.7-flash
    DRY_RUN               : Set to "true" to print fixes without writing files
"""

import argparse
import os
import subprocess
import sys
import textwrap


# ──────────────────────────────────────────────
# Config
# ──────────────────────────────────────────────

SUPPORTED_PROVIDERS = ("claude", "gemini")

DEFAULT_CLAUDE_MODEL = "claude-sonnet-5-5"
DEFAULT_GEMINI_MODEL = "gemini-3.7-flash"


SYSTEM_PROMPT = textwrap.dedent("""
    You are an expert in Infrastructure as Code (IaC) security and quality.
    Your task is to fix Terraform/OpenTofu files based on errors from Checkov,
    TFLint, and pre-commit hooks.

    Rules:
    - Return ONLY corrected file contents, nothing else.
    - Use this exact format for each file, including the separator line:

    ### path/to/file.tf
    <full corrected file content>

    ### path/to/other.tf
    <full corrected file content>

    - Do NOT truncate file contents — return the complete corrected file.
    - Do NOT add explanations, comments, or markdown outside the format above.
    - Preserve all existing logic; only fix what is reported in the errors.
    - If a file has no errors, do not include it in the output.
""").strip()


# ──────────────────────────────────────────────
# Helpers
# ──────────────────────────────────────────────

def resolve_provider() -> str:
    provider = os.environ.get("LLM_PROVIDER", "claude").lower().strip()
    if provider not in SUPPORTED_PROVIDERS:
        print(f"[ERROR] LLM_PROVIDER='{provider}' is not supported. Choose: {SUPPORTED_PROVIDERS}")
        sys.exit(1)
    return provider


def resolve_model(provider: str) -> str:
    if provider == "claude":
        return os.environ.get("CLAUDE_MODEL", DEFAULT_CLAUDE_MODEL)
    return os.environ.get("GEMINI_MODEL", DEFAULT_GEMINI_MODEL)


def get_changed_tf_files() -> list[str]:
    """Returns .tf files changed in the current PR/commit."""
    result = subprocess.run(
        ["git", "diff", "--name-only", "HEAD~1"],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        # Fallback: all .tf files tracked by git
        result = subprocess.run(
            ["git", "ls-files", "*.tf"],
            capture_output=True,
            text=True,
        )
    files = [f.strip() for f in result.stdout.strip().split("\n") if f.strip().endswith(".tf")]
    return files


def read_tf_files(files: list[str]) -> str:
    content = ""
    for path in files:
        if os.path.isfile(path):
            with open(path) as f:
                content += f"\n\n### {path}\n{f.read()}"
        else:
            print(f"[WARN] File not found, skipping: {path}")
    return content.strip()


def build_prompt(errors: str, tf_content: str) -> str:
    return textwrap.dedent(f"""
        Fix the following IaC errors found in the Terraform/OpenTofu files below.

        ── ERRORS ──────────────────────────────────────────
        {errors}

        ── TERRAFORM FILES ──────────────────────────────────
        {tf_content}
    """).strip()


def parse_fixes(output: str) -> dict[str, str]:
    """Parses LLM output into {filepath: corrected_content} dict."""
    fixes = {}
    sections = output.split("### ")
    for section in sections[1:]:
        lines = section.strip().split("\n")
        filepath = lines[0].strip()
        content = "\n".join(lines[1:]).strip()
        if filepath.endswith(".tf") and content:
            fixes[filepath] = content
    return fixes


def apply_fixes(fixes: dict[str, str], dry_run: bool) -> None:
    if not fixes:
        print("[INFO] No fixes to apply.")
        return

    for filepath, content in fixes.items():
        if dry_run:
            print(f"\n[DRY RUN] Would fix: {filepath}")
            print("─" * 60)
            print(content[:500] + ("..." if len(content) > 500 else ""))
        else:
            os.makedirs(os.path.dirname(filepath) or ".", exist_ok=True)
            with open(filepath, "w") as f:
                f.write(content)
            print(f"[FIXED] {filepath}")


# ──────────────────────────────────────────────
# LLM Clients
# ──────────────────────────────────────────────

def fix_with_claude(prompt: str, model: str) -> str:
    try:
        import anthropic
    except ImportError:
        print("[ERROR] 'anthropic' package not installed. Run: pip install anthropic")
        sys.exit(1)

    api_key = os.environ.get("ANTHROPIC_API_KEY")
    if not api_key:
        print("[ERROR] ANTHROPIC_API_KEY is not set.")
        sys.exit(1)

    print(f"[INFO] Using Claude — model: {model}")
    client = anthropic.Anthropic(api_key=api_key)

    response = client.messages.create(
        model=model,
        max_tokens=8192,
        system=SYSTEM_PROMPT,
        messages=[{"role": "user", "content": prompt}],
    )
    return response.content[0].text


def fix_with_gemini(prompt: str, model: str) -> str:
    try:
        import google.generativeai as genai
    except ImportError:
        print("[ERROR] 'google-generativeai' package not installed. Run: pip install google-generativeai")
        sys.exit(1)

    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        print("[ERROR] GEMINI_API_KEY is not set.")
        sys.exit(1)

    print(f"[INFO] Using Gemini — model: {model}")
    genai.configure(api_key=api_key)

    gemini_model = genai.GenerativeModel(
        model_name=model,
        system_instruction=SYSTEM_PROMPT,
    )
    response = gemini_model.generate_content(prompt)
    return response.text


# ──────────────────────────────────────────────
# Entry point
# ──────────────────────────────────────────────

def main() -> None:
    parser = argparse.ArgumentParser(description="Auto-fix IaC errors using an LLM.")
    parser.add_argument(
        "--error-file",
        required=True,
        help="Path to the aggregated error file (checkov + tflint + pre-commit output)",
    )
    parser.add_argument(
        "--tf-files",
        nargs="*",
        help="Explicit list of .tf files to include (default: git diff HEAD~1)",
    )
    args = parser.parse_args()

    dry_run = os.environ.get("DRY_RUN", "false").lower() == "true"
    provider = resolve_provider()
    model = resolve_model(provider)

    # Read errors
    if not os.path.isfile(args.error_file):
        print(f"[ERROR] Error file not found: {args.error_file}")
        sys.exit(1)

    with open(args.error_file) as f:
        errors = f.read().strip()

    if not errors:
        print("[INFO] No errors found in error file. Nothing to fix.")
        sys.exit(0)

    # Read Terraform files
    tf_files = args.tf_files if args.tf_files else get_changed_tf_files()
    if not tf_files:
        print("[WARN] No .tf files found to fix.")
        sys.exit(0)

    print(f"[INFO] Files to analyze: {tf_files}")
    tf_content = read_tf_files(tf_files)

    if not tf_content:
        print("[WARN] Could not read any .tf file content.")
        sys.exit(0)

    # Build prompt and call LLM
    prompt = build_prompt(errors, tf_content)

    if provider == "claude":
        output = fix_with_claude(prompt, model)
    else:
        output = fix_with_gemini(prompt, model)

    # Parse and apply
    fixes = parse_fixes(output)
    print(f"[INFO] Files to fix: {list(fixes.keys())}")
    apply_fixes(fixes, dry_run=dry_run)

    if not dry_run and fixes:
        print("[INFO] All fixes applied. Ready for git commit.")


if __name__ == "__main__":
    main()