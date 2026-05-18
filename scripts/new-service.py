#!/usr/bin/env python3
"""Generate a new service from a scaffold template."""

from __future__ import annotations

import argparse
import re
import shutil
from pathlib import Path


def to_pascal_case(name: str) -> str:
    parts = re.split(r"[^a-zA-Z0-9]", name)
    return "".join(p[:1].upper() + p[1:] for p in parts if p)


def render(text: str, tokens: dict[str, str]) -> str:
    for key, value in tokens.items():
        text = text.replace(f"{{{{ {key} }}}}", value)
    return text


def generate(template: str, service_name: str, output_dir: Path, force: bool) -> None:
    repo_root = Path(__file__).resolve().parents[1]
    scaffold_dir = repo_root / "templates" / template / "scaffold"

    if not scaffold_dir.is_dir():
        raise SystemExit(f"Template scaffold not found: {scaffold_dir}")

    if output_dir.exists():
        if not force:
            raise SystemExit(f"Output directory exists: {output_dir}. Use --force to replace.")
        shutil.rmtree(output_dir)

    tokens = {
        "service_name": service_name,
        "service_pascal": to_pascal_case(service_name),
    }

    for source in sorted(scaffold_dir.rglob("*")):
        rel = source.relative_to(scaffold_dir)
        target_rel = Path(render(str(rel), tokens))
        target = output_dir / target_rel

        if source.is_dir():
            target.mkdir(parents=True, exist_ok=True)
            continue

        target.parent.mkdir(parents=True, exist_ok=True)

        if source.suffix in {".png", ".jpg", ".jpeg", ".ico", ".gif"}:
            shutil.copy2(source, target)
            continue

        content = source.read_text(encoding="utf-8")
        target.write_text(render(content, tokens), encoding="utf-8")

    print(f"Generated {template} service '{service_name}' at {output_dir}")


def main() -> None:
    parser = argparse.ArgumentParser(description="Scaffold a service from templates/*/scaffold")
    parser.add_argument("template", help="Template folder name, e.g. service-dotnet")
    parser.add_argument("service_name", help="Service name, e.g. billing-api")
    parser.add_argument(
        "--output-dir",
        default="",
        help="Target directory (default: examples/<service_name>)",
    )
    parser.add_argument("--force", action="store_true", help="Replace output directory if it exists")

    args = parser.parse_args()
    repo_root = Path(__file__).resolve().parents[1]
    output_dir = Path(args.output_dir) if args.output_dir else repo_root / "examples" / args.service_name

    if not output_dir.is_absolute():
        output_dir = (repo_root / output_dir).resolve()

    generate(args.template, args.service_name, output_dir, args.force)


if __name__ == "__main__":
    main()
