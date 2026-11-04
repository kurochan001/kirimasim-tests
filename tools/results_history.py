#!/usr/bin/env python3
"""Keeps the history of the nightly results and draws it as charts.

Usage:
    python3 tools/results_history.py update --history DIR [--suite-commit SHA]
                                            [--run-url URL] [--time ISO]
                                            [--source nightly|local] RESULT.json ...
    python3 tools/results_history.py render --history DIR

update reads the --json files of the run_*.py scripts (one per simulator, in
the form that tools/suite_results.py describes), compares each simulator's
results with those of its previous run, adds the run to DIR/history.json,
keeps the results as DIR/latest/<simulator>.json, renders, and prints a short
Markdown summaries of the run (the nightly workflow adds them to the job
summary). render writes DIR/charts/*.svg and DIR/README.md / DIR/README.ja.md from
DIR/history.json alone. A simulator that the suite no longer has a runner for
(tools/run_<simulator>.py) stays in the history but is not drawn.

In the nightly workflow (.github/workflows/nightly.yml), DIR is a checkout
of the results branch, and the tests are counted in the checkout of the suite
commit that was run.
"""

import argparse
import datetime as dt
import html
import json
import math
import os
import re
import subprocess
import sys
import unicodedata
from pathlib import Path

import suite_stats

ROOT = Path(__file__).resolve().parent.parent
REPOSITORY = os.environ.get("GITHUB_REPOSITORY", "kurochan001/kirimasim-tests")
SERVER = os.environ.get("GITHUB_SERVER_URL", "https://github.com")
MAX_LISTED = 100       # tests listed per change in history.json
RECENT_RUNS = 30       # rows of the table of recent runs in the report
TEST_COUNT_Y_MAX = 12000  # upper limit of the test-count charts

# Simulators in the order they are shown, with their colors in the light and
# the dark color scheme. Others follow in the order of their ids.
SIMULATORS = {
    "icarus": ("#0969da", "#4493f8"),
    "verilator": ("#8250df", "#ab7df8"),
    "kirimasim": ("#1a7f37", "#3fb950"),
    "lyra": ("#bf3989", "#db61a2"),
    "ghost": ("#bc4c00", "#f0883e"),
}
OTHER_COLORS = [("#1b7c83", "#39c5cf"), ("#953800", "#db6d28"), ("#6e7781", "#8c959f")]
# The shape of each simulator's markers in the line charts. They are drawn as
# outlines, so that markers of equal or close values stay visible together.
MARKERS = {"icarus": "circle", "verilator": "square", "kirimasim": "diamond",
           "lyra": "triangle-down", "ghost": "triangle"}
OTHER_MARKERS = ["triangle", "circle", "square", "diamond"]
# Shown in the report under the table of the latest run, for the simulators in
# that run.
NOTES = {
    "ghost": "Ghost is an unidentified simulator taking part before its "
             "public debut. For now, only its test results step out from behind the curtain. "
             "Its name, source and build logs remain private; build IDs are executable hashes.",
}
STATUS_COLORS = {
    "pass": ("#1a7f37", "#3fb950"),
    "fail": ("#cf222e", "#f85149"),
    "known": ("#8c959f", "#6e7681"),
    "unsupported": ("#bf8700", "#d29922"),
}
STATUS_LABELS = {
    "pass": "match",
    "fail": "differ",
    "known": "known difference",
    "unsupported": "unsupported",
}
STATUS_LABELS_JA = {
    "pass": "一致 (pass)",
    "fail": "不一致 (fail)",
    "known": "既知の差異 (known)",
    "unsupported": "未対応 (unsupported)",
}
NOTES_JA = {
    "ghost": "Ghost は正式公開前に参加している匿名のシミュレータです。"
             "現在公開しているのはテスト結果のみです。名称、ソースコード、ビルドログは非公開で、"
             "ビルドIDには実行ファイルのハッシュを使用します。",
}


def localized(language: str, english: str, japanese: str) -> str:
    if language not in ("en", "ja"):
        raise ValueError(f"unsupported report language: {language}")
    return japanese if language == "ja" else english


# ---------------------------------------------------------------- history


def load_history(directory: Path) -> list[dict]:
    path = directory / "history.json"
    if not path.is_file():
        return []
    return json.loads(path.read_text(encoding="utf-8"))["runs"]


def save_json(path: Path, data) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=1, ensure_ascii=False) + "\n", encoding="utf-8")


def chapter_of(test: str) -> str:
    """"4" for "ch4/test_x" and for a generated test, "gen/ch4/test_x"."""
    return next(p for p in test.split("/") if p.startswith("ch")).removeprefix("ch")


def compare(now: dict[str, dict], before: dict[str, str] | None) -> dict | None:
    """The tests whose result changed since the previous run, or None for a
    simulator's first run. Tests added to or removed from the suite since
    then are only counted."""
    if before is None:
        return None
    passing = sorted(t for t, r in now.items() if r["status"] == "pass"
                     and t in before and before[t] != "pass")
    failing = sorted(t for t, r in now.items() if r["status"] != "pass"
                     and before.get(t) == "pass")
    added = [t for t in now if t not in before]
    return {
        "passing": len(passing),
        "failing": len(failing),
        "passing_tests": passing[:MAX_LISTED],
        "failing_tests": [[t, now[t]["status"], now[t].get("reason", "")]
                          for t in failing[:MAX_LISTED]],
        "added": len(added),
        "added_passing": sum(now[t]["status"] == "pass" for t in added),
        "removed": sum(t not in now for t in before),
    }


def summarize(result: dict, before: dict[str, str] | None) -> dict:
    tests = result["tests"]
    counts = {s: 0 for s in STATUS_LABELS}
    chapters: dict[str, list[int]] = {}
    for test, r in tests.items():
        counts[r["status"]] += 1
        row = chapters.setdefault(chapter_of(test), [0, 0])
        row[0] += r["status"] == "pass"
        row[1] += 1
    return {
        "name": result["name"],
        "version": result["version"],
        "counts": counts,
        "chapters": dict(sorted(chapters.items(), key=lambda kv: int(kv[0]))),
        "changes": compare(tests, before),
    }


def suite_commit() -> str:
    r = subprocess.run(["git", "-C", str(ROOT), "rev-parse", "HEAD"],
                       capture_output=True, text=True)
    return r.stdout.strip()


def update(directory: Path, results: list[Path], commit: str, run_url: str, time: str,
           source: str = "nightly") -> dict:
    stats = suite_stats.collect()
    run = {
        "time": time,
        "suite_commit": commit,
        "run_url": run_url,
        "tests": stats["totals"]["tests"],
        "chapters": {str(c): row["tests"] for c, row in stats["chapters"].items()},
        "simulators": {},
        **({"source": source} if source != "nightly" else {}),
    }
    for path in results:
        result = json.loads(path.read_text(encoding="utf-8"))
        sim = result["simulator"]
        latest = directory / "latest" / f"{sim}.json"
        before = (json.loads(latest.read_text(encoding="utf-8"))["tests"]
                  if latest.is_file() else None)
        run["simulators"][sim] = summarize(result, before)
        save_json(latest, {"name": result["name"], "version": result["version"], "time": time,
                           "suite_commit": commit,
                           **({"source": source} if source != "nightly" else {}),
                           "tests": {t: r["status"] for t, r in result["tests"].items()}})
    run["simulators"] = dict(sorted(run["simulators"].items(), key=lambda kv: sim_order(kv[0])))
    runs = load_history(directory) + [run]
    save_json(directory / "history.json", {"runs": runs})
    render(directory, runs)
    return run


# ---------------------------------------------------------------- labels


def sim_order(sim: str) -> tuple[int, str]:
    order = list(SIMULATORS)
    return (order.index(sim) if sim in order else len(order), sim)


def sim_colors(sim: str, all_sims: list[str]) -> tuple[str, str]:
    if sim in SIMULATORS:
        return SIMULATORS[sim]
    others = [s for s in all_sims if s not in SIMULATORS]
    return OTHER_COLORS[others.index(sim) % len(OTHER_COLORS)]


def sim_marker(sim: str, all_sims: list[str]) -> str:
    if sim in MARKERS:
        return MARKERS[sim]
    others = [s for s in all_sims if s not in MARKERS]
    return OTHER_MARKERS[others.index(sim) % len(OTHER_MARKERS)]


def short_version(version: str) -> str:
    """"13.0" from "Icarus Verilog version 13.0 (stable) (v13_0)", "5.053 devel
    1a2b3c4" from "Verilator 5.053 devel rev v5.052-12-g1a2b3c4", the commit
    from "kirimasim 0.0.0 (commit 6ff7f4aae24a)"."""
    words = version.replace("(", " ").replace(")", " ").split()
    if "commit" in words and words.index("commit") + 1 < len(words):
        return words[words.index("commit") + 1][:9]
    for w in words:
        if w[:1].isdigit() and "." in w:
            commit = re.search(r"-g([0-9a-f]{7,})", version)
            return f"{w} devel {commit.group(1)[:7]}" if "devel" in words and commit else w
    return version


def label(info: dict) -> str:
    return f"{info['name']} {short_version(info['version'])}".strip()


def parse_time(text: str) -> dt.datetime:
    return dt.datetime.fromisoformat(text.replace("Z", "+00:00"))


def matched(info: dict) -> int:
    return info["counts"]["pass"]


def ran(info: dict) -> int:
    return sum(info["counts"].values())


def percent(part: int, whole: int) -> str:
    return f"{100 * part / whole:.1f}%" if whole else "—"


# ---------------------------------------------------------------- SVG

FONT = ('-apple-system,BlinkMacSystemFont,"Segoe UI","Noto Sans",Helvetica,Arial,sans-serif')


def svg_document(width: int, height: int, colors: dict[str, tuple[str, str]], body: list[str],
                 description: str) -> str:
    """An SVG image whose colors follow the viewer's color scheme. colors maps a
    class name to its light and dark color, used as stroke and fill. Lines
    and shapes of class mk are not filled."""
    light = "".join(f".c-{k}{{stroke:{v[0]};fill:{v[0]}}}" for k, v in colors.items())
    dark = "".join(f".c-{k}{{stroke:{v[1]};fill:{v[1]}}}" for k, v in colors.items())
    # After the colors, which would fill lines and markers otherwise.
    unfilled = ".line{fill:none}.mk{fill:none;stroke-width:1.6}"
    style = (
        f"text{{font-family:{FONT};font-size:12px;fill:#1f2328;stroke:none}}"
        ".bg{fill:#ffffff}.muted{fill:#59636e}.title{font-size:15px;font-weight:600}"
        ".grid{stroke:#d1d9e0;stroke-width:1}.axis{stroke:#818b98;stroke-width:1}"
        ".line{fill:none;stroke-width:2}.dashed{stroke-dasharray:5 4}"
        + light + unfilled +
        "@media (prefers-color-scheme:dark){text{fill:#f0f6fc}.bg{fill:#0d1117}"
        ".muted{fill:#9198a1}.grid{stroke:#3d444d}.axis{stroke:#656c76}" + dark
        + unfilled + "}"
    )
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" '
            f'viewBox="0 0 {width} {height}" role="img">\n'
            f"<title>{html.escape(description)}</title>\n<style>{style}</style>\n"
            f'<rect class="bg" width="{width}" height="{height}" rx="6"/>\n'
            + "\n".join(body) + "\n</svg>\n")


def text(x: float, y: float, content: str, cls: str = "", anchor: str = "start",
         extra: str = "") -> str:
    c = f' class="{cls}"' if cls else ""
    return (f'<text x="{x:.1f}" y="{y:.1f}"{c} text-anchor="{anchor}"{extra}>'
            f"{html.escape(content)}</text>")


def nice_ceiling(value: float) -> float:
    if value <= 0:
        return 1
    power = 10 ** math.floor(math.log10(value))
    for m in (1, 2, 2.5, 5, 10):
        if value <= m * power:
            return m * power
    return 10 * power


class TimeAxis:
    """Maps run times to x positions, and chooses the dates to label."""

    def __init__(self, times: list[dt.datetime], left: float, right: float):
        self.left, self.right = left, right
        self.start, self.end = min(times), max(times)
        if self.end - self.start < dt.timedelta(hours=12):
            self.start -= dt.timedelta(days=1)
            self.end += dt.timedelta(days=1)

    def x(self, t: dt.datetime) -> float:
        span = (self.end - self.start).total_seconds()
        return self.left + (self.right - self.left) * (t - self.start).total_seconds() / span

    def ticks(self) -> list[tuple[dt.datetime, str]]:
        """Dates at noon (UTC), the middle of the day they name."""
        days = (self.end - self.start).days + 1
        step = next((s for s in (1, 2, 7, 14, 28, 56, 91, 182, 364) if days / s <= 8), 728)
        fmt = "%Y-%m" if days > 330 else "%m-%d"
        day = dt.datetime.combine(self.start.date(), dt.time(12), dt.timezone.utc)
        if day < self.start:
            day += dt.timedelta(days=1)
        out = []
        while day <= self.end:
            out.append((day, day.strftime(fmt)))
            day += dt.timedelta(days=step)
        return out


def plot_frame(axis: TimeAxis, top: float, bottom: float, y_max: float, y_suffix: str,
               pad: float = 0) -> list[str]:
    """Grid lines, y labels and date ticks. pad widens the plot area beyond the
    first and the last run on each side."""
    body = []
    left, right = axis.left - pad, axis.right + pad
    for i in range(6):
        value = y_max * i / 5
        y = bottom - (bottom - top) * i / 5
        body.append(f'<line class="grid" x1="{left}" x2="{right}" y1="{y:.1f}" y2="{y:.1f}"/>')
        shown = f"{value:g}" if value != int(value) else f"{int(value)}"
        body.append(text(left - 8, y + 4, shown + y_suffix, "muted", "end"))
    body.append(f'<line class="axis" x1="{left}" x2="{right}" y1="{bottom}" y2="{bottom}"/>')
    for t, name in axis.ticks():
        x = axis.x(t)
        body.append(f'<line class="axis" x1="{x:.1f}" x2="{x:.1f}" y1="{bottom}" '
                    f'y2="{bottom + 4}"/>')
        body.append(text(x, bottom + 18, name, "muted", "middle"))
    return body


def marker(shape: str, cls: str, x: float, y: float) -> str:
    """The outline of a marker of the given shape centered at (x, y); "dot" is a
    small filled circle. The circle holds the square and the square the diamond
    and the triangles, so markers at the same point stay visible."""
    if shape == "dot":
        return f'<circle class="c-{cls}" cx="{x:.1f}" cy="{y:.1f}" r="2.5"/>'
    if shape == "square":
        return (f'<rect class="mk c-{cls}" x="{x - 4.5:.1f}" y="{y - 4.5:.1f}" width="9" '
                f'height="9"/>')
    if shape == "diamond":
        points = [(x, y - 3.5), (x + 3.5, y), (x, y + 3.5), (x - 3.5, y)]
    elif shape == "triangle":
        points = [(x, y - 3.5), (x + 3.2, y + 2.5), (x - 3.2, y + 2.5)]
    elif shape == "triangle-down":
        points = [(x, y + 3.5), (x + 3.2, y - 2.5), (x - 3.2, y - 2.5)]
    else:
        return f'<circle class="mk c-{cls}" cx="{x:.1f}" cy="{y:.1f}" r="7.5"/>'
    shown = " ".join(f"{px:.1f},{py:.1f}" for px, py in points)
    return f'<polygon class="mk c-{cls}" points="{shown}"/>'


def legend(entries: list[tuple[str, str, bool, str]], x: float, y: float,
           right: float, language: str = "en") -> tuple[list[str], float]:
    """entries: class name, text, whether the line is dashed, and the shape of
    its markers. Entries go on as many rows as needed before right; returns the
    elements and the baseline of the last row."""
    body = []
    start = x
    for cls, content, dashed, shape in entries:
        units = (sum(2 if unicodedata.east_asian_width(c) in ("W", "F") else 1 for c in content)
                 if language == "ja" else len(content))
        width = 36 + 7 * units
        if x > start and x + width - 10 > right:
            x, y = start, y + 20
        dash = " dashed" if dashed else ""
        body.append(f'<line class="line{dash} c-{cls}" x1="{x}" x2="{x + 18}" '
                    f'y1="{y - 4}" y2="{y - 4}"/>')
        body.append(marker(shape, cls, x + 9, y - 4))
        body.append(text(x + 24, y, content))
        x += width
    return body, y


def line_chart(title: str, subtitle: str, runs: list[dict],
               series: list[tuple[str, str, bool, str, list[float | None]]],
               colors: dict[str, tuple[str, str]], y_max: float | None = None,
               y_suffix: str = "", shown=lambda v: f"{v:g}", language: str = "en") -> str:
    """series: class name, legend text, dashed, marker shape, and one value per
    run (None where the run has none). colors maps the class names to their
    colors. The legend gives each series' latest value, written by shown."""
    width = 880
    times = [parse_time(r["time"]) for r in runs]
    axis = TimeAxis(times, 64, width - 28)
    values = [v for *_, vs in series for v in vs if v is not None]
    y_max = y_max or nice_ceiling(max(values, default=1) * 1.05)
    body = [text(20, 28, title, "title"), text(20, 48, subtitle, "muted")]
    entries = []
    for cls, name, dashed, shape, vs in series:
        latest = next((v for v in reversed(vs) if v is not None), None)
        entries.append((cls, name if latest is None else f"{name}: {shown(latest)}",
                        dashed, shape))
    rows, last_row = legend(entries, 20, 74, width - 20, language)
    body += rows
    top = last_row + 18
    bottom = top + 248
    height = int(bottom + 40)
    body += plot_frame(axis, top, bottom, y_max, y_suffix)

    def y(v: float) -> float:
        return bottom - (bottom - top) * v / y_max

    for cls, _, dashed, _, vs in series:
        segment: list[str] = []
        segments = [segment]
        for t, v in zip(times, vs):
            if v is None:
                segment = []
                segments.append(segment)
            else:
                segment.append(f"{axis.x(t):.1f},{y(v):.1f}")
        dash = " dashed" if dashed else ""
        for seg in segments:
            if len(seg) > 1:
                body.append(f'<polyline class="line{dash} c-{cls}" points="{" ".join(seg)}"/>')
    # Markers after all the lines, so that no line covers them. A dashed series
    # has them only while it has a single point, which a line cannot show.
    for cls, _, dashed, shape, vs in series:
        points = [(t, v) for t, v in zip(times, vs) if v is not None]
        if len(runs) <= 60 and (not dashed or len(points) == 1):
            for t, v in points:
                body.append(marker(shape, cls, axis.x(t), y(v)))
    return svg_document(width, height, colors, body, f"{title}: {subtitle}")


def stacked_chart(title: str, subtitle: str, runs: list[dict], sim: str,
                  language: str = "en") -> str:
    """Columns of the results of one simulator by status, one per run."""
    width, height = 880, 340
    top, bottom = 92, height - 40
    times = [parse_time(r["time"]) for r in runs]
    axis = TimeAxis(times, 64 + 16, width - 40)   # room for half a column at each end
    infos = [r["simulators"].get(sim) for r in runs]
    y_max = TEST_COUNT_Y_MAX
    body = [text(20, 28, title, "title"), text(20, 48, subtitle, "muted")]
    used = [s for s in STATUS_LABELS if any(i and i["counts"][s] for i in infos)]
    labels = STATUS_LABELS_JA if language == "ja" else STATUS_LABELS
    x = 20
    for s in used:
        body.append(f'<rect class="c-{s}" x="{x}" y="64" width="12" height="12" rx="2"/>')
        body.append(text(x + 18, 74, labels[s]))
        x += 200 if language == "ja" else 36 + 6.6 * len(labels[s])
    body += plot_frame(axis, top, bottom, y_max, "", 16)
    gaps = [b - a for a, b in zip(times, times[1:])]
    spacing = min((axis.x(times[0] + g) - axis.left for g in gaps), default=40)
    bar = max(2.0, min(28.0, spacing * 0.7))
    for t, info in zip(times, infos):
        if not info:
            continue
        base = bottom
        for s in used:
            h = (bottom - top) * info["counts"][s] / y_max
            if h > 0:
                body.append(f'<rect class="c-{s}" x="{axis.x(t) - bar / 2:.1f}" '
                            f'y="{base - h:.1f}" width="{bar:.1f}" height="{h:.1f}"/>')
            base -= h
    return svg_document(width, height, STATUS_COLORS, body, f"{title}: {subtitle}")


def latest_snapshots(runs: list[dict]) -> dict[str, tuple[dict, dict]]:
    """Each simulator's latest real run and result, retaining its provenance."""
    latest = {}
    for run in runs:
        for sim, info in run["simulators"].items():
            latest[sim] = (run, info)
    return dict(sorted(latest.items(), key=lambda item: sim_order(item[0])))


def heatmap(runs: list[dict], language: str = "en") -> str:
    """The latest chapter results, with the actual date and suite of each column."""
    latest = latest_snapshots(runs)
    sims = list(latest)
    chapters = sorted({c for _, info in latest.values() for c in info["chapters"]}, key=int)
    col, row, head, left = 200, 22, 134, 430 if language == "ja" else 330
    width = left + col * max(len(sims), 1) + 20
    height = head + row * len(chapters) + 20
    title = localized(language, "Matching tests by chapter", "章別の一致テスト数")
    body = [text(20, 28, title, "title"),
            text(20, 48, localized(language,
                "Latest recorded result for each simulator; dates and suite commits can differ",
                "各シミュレータの最新記録（日付・スイートのコミットは列ごとに異なる場合があります）"), "muted")]
    for i, sim in enumerate(sims):
        run, info = latest[sim]
        cx = left + col * i + col / 2
        body.append(text(cx, head - 64, info["name"], "", "middle", ' font-weight="600"'))
        body.append(text(cx, head - 48, short_version(info["version"]), "muted", "middle"))
        body.append(text(cx, head - 32, f"{parse_time(run['time']):%Y-%m-%d %H:%M} UTC",
                         "muted", "middle"))
        body.append(text(cx, head - 16,
                         localized(language, "Suite", "スイート") +
                         f" {run['suite_commit'][:7]} / {run.get('source', 'nightly')}",
                         "muted", "middle"))
    for j, chapter in enumerate(chapters):
        y = head + row * j
        chapter_title = (suite_stats.CHAPTERS_JA if language == "ja" else suite_stats.CHAPTERS).get(
            int(chapter), "")
        body.append(text(20, y + 15, f"{chapter}  {chapter_title}"))
        for i, sim in enumerate(sims):
            passed, total = latest[sim][1]["chapters"].get(chapter, [0, 0])
            x = left + col * i
            if total:
                rate = passed / total
                hue = round(120 * rate)
                body.append(f'<rect x="{x + 2}" y="{y + 2}" width="{col - 4}" height="{row - 4}" '
                            f'rx="3" style="fill:hsl({hue},70%,45%);fill-opacity:0.35"/>')
                content = f"{passed}/{total}  {100 * rate:.0f}%"
            else:
                content = "—"
            body.append(text(x + col / 2, y + 15, content, "", "middle"))
    return svg_document(width, height, {}, body, title)


def has_runner(sim: str) -> bool:
    """Whether the suite has a runner for the simulator, tools/run_<sim>.py.
    The history keeps the results of a simulator whose runner was removed, but
    they are no longer drawn."""
    return (ROOT / "tools" / f"run_{sim}.py").is_file()


def render(directory: Path, runs: list[dict]) -> None:
    runs = [{**r, "simulators": {s: v for s, v in r["simulators"].items() if has_runner(s)}}
            for r in runs]
    if not runs:
        return
    sims = sorted({s for r in runs for s in r["simulators"]}, key=sim_order)
    colors = {"total": ("#59636e", "#9198a1"), **{sim: sim_colors(sim, sims) for sim in sims}}
    last = {sim: next(r["simulators"][sim] for r in reversed(runs) if sim in r["simulators"])
            for sim in sims}
    charts = directory / "charts"
    charts.mkdir(parents=True, exist_ok=True)

    counts = [(sim, label(last[sim]), False, sim_marker(sim, sims),
               [matched(r["simulators"][sim]) if sim in r["simulators"] else None for r in runs])
              for sim in sims]
    rates = [(sim, label(last[sim]), False, sim_marker(sim, sims),
              [100 * matched(r["simulators"][sim]) / ran(r["simulators"][sim])
               if sim in r["simulators"] and ran(r["simulators"][sim]) else None for r in runs])
             for sim in sims]
    for language in ("en", "ja"):
        suffix = ".ja" if language == "ja" else ""
        total = ("total", localized(language, "tests in the suite", "スイートのテスト数"),
                 True, "dot", [r["tests"] for r in runs])
        (charts / f"overview{suffix}.svg").write_text(line_chart(
            localized(language, "Tests that match their expected results", "期待結果に一致するテスト数"),
            localized(language,
                "Recorded runs of the suite; local imports are identified in the report",
                "スイートの実行記録（ローカル取り込みはレポートに明記）"),
            runs, counts + [total], colors, y_max=TEST_COUNT_Y_MAX, shown=lambda v: f"{v:.0f}",
            language=language),
            encoding="utf-8")
        (charts / f"rate{suffix}.svg").write_text(line_chart(
            localized(language, "Share of the tests that match", "一致したテストの割合"),
            localized(language, "Matching tests out of the tests run, in percent",
                      "実行したテストに占める一致したテストの割合（%）"),
            runs, rates, colors, y_max=100, y_suffix="%", shown=lambda v: f"{v:.1f}%",
            language=language),
            encoding="utf-8")
        (charts / f"chapters{suffix}.svg").write_text(heatmap(runs, language), encoding="utf-8")
        for sim in sims:
            (charts / f"status-{sim}{suffix}.svg").write_text(stacked_chart(
                localized(language, f"{last[sim]['name']}: results by status",
                          f"{last[sim]['name']}：ステータス別の結果"),
                localized(language,
                    "Tests that match, differ, are known differences, or use what the simulator does not support",
                    "一致・不一致・既知の差異・未対応のテスト数"),
                runs, sim, language), encoding="utf-8")
        readme = "README.ja.md" if language == "ja" else "README.md"
        (directory / readme).write_text(report(runs, sims, language), encoding="utf-8")
    current_status = {f"status-{sim}{suffix}.svg" for sim in sims for suffix in ("", ".ja")}
    for old in charts.glob("status-*.svg"):
        if old.name not in current_status:
            old.unlink()


# ---------------------------------------------------------------- report


def commit_link(commit: str) -> str:
    return f"[`{commit[:7]}`]({SERVER}/{REPOSITORY}/commit/{commit})" if commit else "—"


def change_text(changes: dict | None, language: str = "en") -> str:
    if changes is None:
        return localized(language, "first run", "初回実行")
    parts = []
    if changes["passing"]:
        parts.append(localized(language, f"{changes['passing']} newly match",
                               f"新たに一致 {changes['passing']}件"))
    if changes["failing"]:
        parts.append(localized(language, f"{changes['failing']} no longer match",
                               f"一致しなくなったテスト {changes['failing']}件"))
    if changes["added"]:
        parts.append(localized(language,
            f"{changes['added']} new tests ({changes['added_passing']} match)",
            f"新規テスト {changes['added']}件（一致 {changes['added_passing']}件）"))
    if changes["removed"]:
        parts.append(localized(language, f"{changes['removed']} tests removed",
                               f"削除されたテスト {changes['removed']}件"))
    return localized(language, ", ", "、").join(parts) or localized(language, "no change", "変化なし")


def latest_table(run: dict, language: str = "en") -> str:
    lines = [localized(language,
             "| Simulator | Version | Match | Differ | Known differences | Unsupported | Since the previous run |",
             "| シミュレータ | バージョン | 一致 (pass) | 不一致 (fail) | 既知の差異 (known) | 未対応 (unsupported) | 前回実行からの変化 |"),
             "| --- | --- | ---: | ---: | ---: | ---: | --- |"]
    for sim, info in run["simulators"].items():
        c = info["counts"]
        lines.append(f"| {info['name']} | {info['version']} | {c['pass']} "
                     f"({percent(c['pass'], ran(info))}) | {c['fail']} | {c['known']} | "
                     f"{c['unsupported']} | {change_text(info['changes'], language)} |")
    return "\n".join(lines)


def latest_results_table(runs: list[dict], language: str = "en") -> str:
    """Keep partial/local updates visible beside older, honestly dated results."""
    lines = [localized(language,
             "| Simulator | Version | Run (UTC) | Suite | Source | Match | Differ | Known differences | Unsupported |",
             "| シミュレータ | バージョン | 実行 (UTC) | スイート | 取り込み元 | 一致 (pass) | 不一致 (fail) | 既知の差異 (known) | 未対応 (unsupported) |"),
             "| --- | --- | --- | --- | --- | ---: | ---: | ---: | ---: |"]
    for run, info in latest_snapshots(runs).values():
        counts = info["counts"]
        lines.append(
            f"| {info['name']} | {info['version']} | {parse_time(run['time']):%Y-%m-%d %H:%M} "
            f"| {commit_link(run['suite_commit'])} | {run.get('source', 'nightly')} "
            f"| {counts['pass']} ({percent(counts['pass'], ran(info))}) | {counts['fail']} "
            f"| {counts['known']} | {counts['unsupported']} |")
    return "\n".join(lines)


def changes_section(run: dict, language: str = "en") -> str:
    out = []
    for sim, info in run["simulators"].items():
        changes = info["changes"]
        if not changes or not (changes["passing"] or changes["failing"]):
            continue
        out.append(f"### {info['name']}")
        out.append("")
        if changes["passing"]:
            listed = ", ".join(f"`{t}`" for t in changes["passing_tests"])
            more = changes["passing"] - len(changes["passing_tests"])
            out.append(localized(language, f"Newly match ({changes['passing']}): {listed}",
                                 f"新たに一致（{changes['passing']}件）: {listed}")
                       + (localized(language, f" and {more} more", f"、ほか{more}件") if more else ""))
            out.append("")
        if changes["failing"]:
            out.append(localized(language, f"No longer match ({changes['failing']}):",
                                 f"一致しなくなったテスト（{changes['failing']}件）:"))
            out.append("")
            for test, status, reason in changes["failing_tests"]:
                why = f" — {reason}" if reason else ""
                labels = STATUS_LABELS_JA if language == "ja" else STATUS_LABELS
                out.append(f"- `{test}`: {labels[status]}{why}")
            more = changes["failing"] - len(changes["failing_tests"])
            if more:
                out.append(localized(language, f"- and {more} more", f"- ほか{more}件"))
            out.append("")
    if not out:
        return localized(language, "No test changed its result since the previous run.\n",
                         "前回実行から結果が変わったテストはありません。\n")
    return "\n".join(out)


def reader_note(run: dict, language: str = "en", chapter: bool = False) -> str:
    """Link explanations beside the numbers, in the report's own language."""
    page = "faq.md" if language == "ja" else "faq.en.md"
    faq = f"{SERVER}/{REPOSITORY}/blob/{run['suite_commit']}/docs/{page}"
    if chapter:
        return localized(language,
            f"Cells show matching tests / recorded results, including known and unsupported in the denominator: "
            f"[8/10 example]({faq}#q12-what-percentage-does-by-chapter-show). "
            f"This is [not requirement coverage]({faq}#q15-is-the-nightly-match-rate-requirement-coverage).",
            f"各セルは一致数／結果登録数で、known・unsupportedも分母に含みます。[8/10の具体例]({faq}#q12-what-percentage-does-by-chapter-show)と、"
            f"[要求カバレッジとの違い]({faq}#q15-is-the-nightly-match-rate-requirement-coverage)を確認してください。")
    return localized(language,
        f"A green workflow does not mean every test passed: "
        f"[why Differ can remain]({faq}#q11-why-can-nightly-be-green-with-differ-results). "
        f"Read [status meanings and per-test evidence]({faq}#q9-what-do-match-differ-known-difference-and-unsupported-mean) before comparing totals.",
        f"緑のworkflowは全テストの合格を意味しません。[Nightlyが緑でもDifferが残る理由]({faq}#q11-why-can-nightly-be-green-with-differ-results)と、"
        f"[区分・個別テストの確認先]({faq}#q9-what-do-match-differ-known-difference-and-unsupported-mean)を読んでから件数を比較してください。")


def summary(run: dict, language: str = "en") -> str:
    """The Markdown that the nightly workflow adds to its job summary."""
    heading = localized(language,
        f"## Nightly results\n\nSuite commit {commit_link(run['suite_commit'])}, {run['tests']} tests.",
        f"## 夜間実行結果\n\nスイートのコミット {commit_link(run['suite_commit'])}、テスト{run['tests']}件。")
    return (f"{heading}\n\n{reader_note(run, language)}\n\n{latest_table(run, language)}\n\n"
            + localized(language, "## Changes\n\n", "## 変更点\n\n")
            + changes_section(run, language))


def report(runs: list[dict], sims: list[str], language: str = "en") -> str:
    run = runs[-1]
    when = parse_time(run["time"])
    workflow = f"{SERVER}/{REPOSITORY}/actions/workflows/nightly.yml"
    tr = lambda english, japanese: localized(language, english, japanese)
    chart = lambda name: f"charts/{name.removesuffix('.svg')}{'.ja' if language == 'ja' else ''}.svg?v={when:%Y%m%dT%H%M%S}"
    link_label = (tr("local result", "ローカル実行結果") if run.get("source") == "local"
                  else tr("workflow run", "ワークフロー実行"))
    run_link = tr(", ", "、") + f"[{link_label}]({run['run_url']})" if run.get("run_url") else ""
    lines = [
        tr("# Nightly results of kirimasim-tests", "# kirimasim-tests の夜間実行結果"),
        "",
        "[English](README.md) / [日本語](README.ja.md)",
        "",
        tr(f"The [nightly workflow]({workflow}) of [kirimasim-tests]({SERVER}/{REPOSITORY}) "
        "writes this branch. Each night it runs every test of the suite's main branch with "
        "each simulator, adds the results to `history.json` and draws the charts below. "
        "Local runs can also be imported and are marked `local`. "
        "A test matches when its output and specified checks agree with the expected result, "
        "or an illegal design is rejected with the required diagnostic; see the suite's "
        "README for what each status means.",
        f"[kirimasim-tests]({SERVER}/{REPOSITORY}) の[夜間ワークフロー]({workflow})がこのブランチを更新します。"
        "毎晩、main ブランチの全テストを各シミュレータで実行し、結果を `history.json` に追加して、以下の図を生成します。"
        "ローカル実行の結果も取り込むことができ、`local` と表示します。"
        "出力と指定された検査が期待結果に一致する場合、または不正な設計が必要な診断付きで拒否される場合に、テストを「一致」と数えます。"
        "各ステータスの意味はスイートの README を参照してください。"),
        "",
        tr(f"Latest run: {when:%Y-%m-%d %H:%M} UTC, suite commit {commit_link(run['suite_commit'])}, "
           f"{run['tests']} tests{run_link}.",
           f"最新の実行: {when:%Y-%m-%d %H:%M} UTC、スイートのコミット {commit_link(run['suite_commit'])}、"
           f"テスト{run['tests']}件{run_link}。"),
        "",
        tr("## Latest results per simulator", "## シミュレータごとの最新結果"),
        "",
        tr("Each row and chapter-table column uses that simulator's most recent recorded run. "
        "Dates, suite commits and test counts can differ; older results retain their own "
        "dates and are not treated as part of the latest run.",
        "各行と章別表の各列には、そのシミュレータの最新の実行記録を使います。"
        "実行日時、スイートのコミット、テスト数は異なる場合があります。"
        "古い結果の日時はそのまま保持し、最新の実行に含まれる結果としては扱いません。"),
        "",
        reader_note(run, language),
        "",
        latest_results_table(runs, language),
        "",
        *[f"{(NOTES_JA if language == 'ja' else NOTES)[sim]}\n" for sim in sims if sim in NOTES],
        f"![{tr('Tests that match their expected results', '期待結果に一致するテスト数')}]({chart('overview.svg')})",
        "",
        f"![{tr('Share of the tests that match', '一致したテストの割合')}]({chart('rate.svg')})",
        "",
        tr("## Changes in the latest run", "## 最新の実行での変化"),
        "",
        tr("Tests that match now but did not in the previous run of the same simulator, and "
        "tests that matched then but do not now. Tests added to the suite are counted in the "
        "table above.",
        "同じシミュレータの前回実行では一致せず今回は一致したテストと、前回は一致したものの今回は一致しなくなったテストです。"
        "スイートに追加されたテストの件数は上の表に示します。"),
        "",
        changes_section(run, language),
        tr("## By chapter", "## 章別の結果"),
        "",
        reader_note(run, language, chapter=True),
        "",
        f"![{tr('Matching tests by chapter', '章別の一致テスト数')}]({chart('chapters.svg')})",
        "",
        tr("## Each simulator over time", "## シミュレータごとの推移"),
        "",
    ]
    for sim in sims:
        name = next(r["simulators"][sim]["name"] for r in reversed(runs) if sim in r["simulators"])
        lines += [f"![{tr(f'{name}: results by status', f'{name}：ステータス別の結果')}]({chart(f'status-{sim}.svg')})", ""]
    header = tr("| Run (UTC) | Suite | Tests | ", "| 実行 (UTC) | スイート | テスト数 | ") + " | ".join(
        next(r["simulators"][s]["name"] for r in reversed(runs) if s in r["simulators"])
        for s in sims) + " |"
    lines += [tr("## Recent runs", "## 最近の実行"), "",
              tr("Matching tests of each simulator, with the change since its previous run. "
                 "The version is shown when it changed.",
                 "各シミュレータの一致したテスト数と、その前回実行からの増減です。バージョンは変更されたときに表示します。"), "",
              header, "| --- | --- | ---: |" + " ---: |" * len(sims)]
    previous_version: dict[str, str] = {}
    rows = []
    for r in runs:
        cells = []
        for sim in sims:
            info = r["simulators"].get(sim)
            if info is None:
                cells.append("—")
                continue
            ch = info["changes"]
            delta = ""
            if ch and (ch["passing"] or ch["failing"] or ch["added_passing"]):
                delta = f" (+{ch['passing'] + ch['added_passing']} −{ch['failing']})"
            version = short_version(info["version"])
            shown = f" `{version}`" if previous_version.get(sim) != version else ""
            previous_version[sim] = version
            cells.append(f"{matched(info)}{delta}{shown}")
        link = (f"[{parse_time(r['time']):%Y-%m-%d %H:%M}]({r['run_url']})" if r.get("run_url")
                else f"{parse_time(r['time']):%Y-%m-%d %H:%M}")
        if r.get("source") == "local":
            link += " (local)"
        rows.append(f"| {link} | {commit_link(r['suite_commit'])} | {r['tests']} | "
                    + " | ".join(cells) + " |")
    lines += list(reversed(rows))[:RECENT_RUNS]
    lines += [
        "",
        tr("## Files", "## ファイル"),
        "",
        tr("- `history.json`: one entry per run, with the counts of each simulator by status "
           "and by chapter, and the tests whose result changed.",
           "- `history.json`: 実行ごとに1件の記録。各シミュレータのステータス別・章別の件数と、結果が変わったテストを保存します。"),
        tr("- `latest/<simulator>.json`: the result of every test in the latest run of each "
           "simulator, which the next run is compared with.",
           "- `latest/<simulator>.json`: 各シミュレータの最新実行における全テストの結果。次回実行の比較元になります。"),
        tr("- `charts/*.svg`: the charts above.",
           "- `charts/*.svg`: 上記の図。日本語版は `.ja.svg`、英語版は `.svg` です。"),
        "",
    ]
    return "\n".join(lines)


# ---------------------------------------------------------------- main


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    sub = ap.add_subparsers(dest="command", required=True)
    up = sub.add_parser("update", help="add a run and render")
    up.add_argument("--history", type=Path, required=True, help="directory of the history")
    up.add_argument("--suite-commit", default=None, help="commit of the suite (default: HEAD)")
    up.add_argument("--run-url", default="", help="URL of the workflow or imported result")
    up.add_argument("--time", default=None, help="time of the run, ISO 8601 (default: now)")
    up.add_argument("--source", choices=("nightly", "local"), default="nightly",
                    help="origin of this run (default: nightly)")
    up.add_argument("results", nargs="+", type=Path, help="--json files of the runners")
    rd = sub.add_parser("render", help="draw the charts and the report again")
    rd.add_argument("--history", type=Path, required=True, help="directory of the history")
    args = ap.parse_args()

    if args.command == "render":
        render(args.history, load_history(args.history))
        return 0
    time = args.time or dt.datetime.now(dt.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    run = update(args.history, args.results, args.suite_commit or suite_commit(),
                 args.run_url, time, args.source)
    sys.stdout.write(summary(run))
    sys.stdout.write("\n<details>\n<summary>日本語</summary>\n\n" + summary(run, "ja")
                     + "\n</details>\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
