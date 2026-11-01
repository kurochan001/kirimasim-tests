#!/usr/bin/env python3
"""Normal-exit fault controls for typed mailbox/class aliases on known inputs."""

import argparse
import json
from pathlib import Path
import shutil
import sys

import qualify_assertion_wait as helper
import run_verilator
import suite_results

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / 'generators'))
import interaction_mailbox as model


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--verilator', default='verilator')
    parser.add_argument('--seed', type=int, default=1)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    binary = str(Path(shutil.which(args.verilator) or args.verilator).resolve())
    version = suite_results.tool_version([binary, '--version'])
    if not version.startswith('Verilator 5.052 '):
        parser.error('controls require fixed Verilator 5.052')
    if args.output.exists():
        parser.error('use a new evidence path; do not overwrite a saved execution')
    parents = dict(zip(('base', 'wide', 'after', 'try_peek', 'medium', 'bit'), model.MODEL.anchors[:6]))
    faults = (
        ('clone_queued_object', 'base', '    target_box.put(a);',
         '    tail_item = new;\n    tail_item.payload = a.payload;\n'
         '    tail_item.tag = a.tag;\n    target_box.put(tail_item);'),
        ('reverse_fifo_order', 'base', '    target_box.put(a);\n    target_box.put(b);',
         '    target_box.put(b);\n    target_box.put(a);'),
        ('bounded_becomes_unbounded', 'base', 'localparam int BOUND = 2;', 'localparam int BOUND = 0;'),
        ('get_retains_message', 'base', '    target_box.get(r);', '    target_box.peek(r);'),
        ('peek_consumes_message', 'wide', '    target_box.peek(r);', '    target_box.get(r);'),
        ('try_get_retains_message', 'after', 'result = target_box.try_get(r);',
         'result = target_box.try_peek(r);'),
        ('try_peek_consumes_message', 'try_peek', 'result = target_box.try_peek(r);',
         'result = target_box.try_get(r);'),
        ('lose_before_alias_write', 'base', '    a.payload = before_value;', '    ;'),
        ('lose_received_writeback', 'base', '    r.payload = through_value;', '    ;'),
        ('lose_after_alias_write', 'after', '    a.payload = after_value;', '    ;'),
        ('guard_carries_sibling', 'medium', 'guard_box.put(g);', 'guard_box.put(b);'),
        ('guard_shares_target_queue', 'wide', 'guard_box = new();', 'guard_box = target_box;'),
        ('null_message_becomes_object', 'wide', 'message = null;', 'message = c;'),
        ('truncate_payload_above_64', 'wide', 'b.payload = init_b;',
         "b.payload = word_t'(64'(init_b));"),
        ('clone_received_object', 'base', '    r.payload = through_value;',
         '    tail_item = new;\n    tail_item.payload = r.payload;\n'
         '    tail_item.tag = r.tag;\n    r = tail_item;\n    r.payload = through_value;'),
        ('guard_write_hits_sibling', 'bit', 'held_guard.payload = guard_value;',
         'b.payload = guard_value;'),
        ('drop_admitted_third_message', 'wide', 'result = target_box.try_put(message);', 'result = 0;'),
        ('fetch_uses_sibling_handle', 'base', '    target_box.get(r);', '    r = b;'),
        ('guard_input_aliases_target', 'base', 'g.payload = init_g;', 'g.payload = init_a;'),
    )

    def runner(test):
        passed, reason = run_verilator.run(test, binary, args.seed)
        return ('pass' if passed else 'fail'), reason

    result = helper.qualify(model, parents, faults, runner,
                            {'simulator': 'verilator', 'version': version, 'seed': args.seed,
                             'runner_sha256': suite_results.runner_digest('verilator'),
                             'scope': 'six typed, known-input selected controls; no typeless or four-state qualification'})
    result['qualification_helper_sha256'] = result.pop('qualification_sha256')
    result['qualification_sha256'] = helper.sha(Path(__file__).read_text())
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, ensure_ascii=False, indent=2) + '\n')
    return 0 if result['all_controls_pass'] and result['all_faults_detected'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
