# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Exercise real adapter Popen builds separately from runtime and normalization."""
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import time
import unittest
from unittest.mock import patch

import random_cross_compare as compare
import run_icarus
import run_verilator
import suite_results


class ComparisonPhaseCaptureTests(unittest.TestCase):
    def capture(self, simulator='icarus', build_code=0, normalization_code=0,
                timeout=False, missing_compiler=False, drift=None):
        with tempfile.TemporaryDirectory() as temporary:
            root=Path(temporary);directory=root/'evidence';directory.mkdir()
            source=root/'case.sv';source.write_text('/*\n:oracle: spec\n*/\nmodule t; endmodule\n')
            expected=root/'case.expected';expected.write_text('ok\n')
            compiled=root/'case.vvp';compiled.write_text('previous-build')
            runtime=root/('vvp' if simulator=='icarus' else 'Vt')
            runtime.write_text('#!/usr/bin/env python3\nimport pathlib,sys\n'+(
                'p=pathlib.Path(sys.argv[0]);p.write_text(p.read_text()+"#changed\\n")\n' if drift=='binary' else
                'pathlib.Path(sys.argv[1]).write_text("changed")\n' if drift=='input' else '')+
                'print("ok")\n')
            runtime.chmod(0o755)
            normalizer=root/'normalize_output.py';normalizer.write_text(
                'import sys\nsys.stdout.write(sys.stdin.read())\n'+f'raise SystemExit({normalization_code})\n')
            adapter=run_icarus if simulator=='icarus' else run_verilator
            originals=(subprocess.run,run_icarus.execute,run_verilator.execute,suite_results.expected_output)
            def runner(*args):
                command=[str(root/'absent-compiler')] if missing_compiler else [sys.executable,'-c',
                    'import pathlib,sys,time;print("build-out",flush=True);'
                    'print("build-err",file=sys.stderr,flush=True);'
                    'pathlib.Path(sys.argv[1]).write_text("new-build");'+
                    ('time.sleep(5);' if timeout else '')+f'raise SystemExit({build_code})',str(compiled)]
                try:
                    build=adapter.execute(command,0.01 if timeout else 5)
                except subprocess.TimeoutExpired:
                    return False,'timed out (compile)'
                if build.returncode:return False,'compile failed: build-err'
                run=subprocess.run([str(runtime),str(compiled)],capture_output=True,text=True)
                normalized=subprocess.run([sys.executable,str(normalizer)],input=run.stdout,
                                          capture_output=True,text=True)
                return normalized.stdout=='ok\n',''  # Actual adapters judge normalized text only.
            try:
                with patch.object(adapter,'run',side_effect=runner):
                    if missing_compiler:
                        with self.assertRaises(FileNotFoundError):
                            compare.worker(simulator,source,expected,str(runtime),1,directory)
                    else:compare.worker(simulator,source,expected,str(runtime),1,directory)
            finally:
                self.assertIs(subprocess.run,originals[0])
                self.assertIs(run_icarus.execute,originals[1])
                self.assertIs(run_verilator.execute,originals[2])
                self.assertIs(suite_results.expected_output,originals[3])
            phases=json.loads((directory/'phases.json').read_text())
            for phase in phases:
                phase['captured_stdout']=(directory/phase['stdout']).read_text()
                phase['captured_stderr']=(directory/phase['stderr']).read_text()
            result=json.loads((directory/'worker.json').read_text()) if (directory/'worker.json').exists() else None
            return phases,result

    def check_success(self,simulator):
        phases,result=self.capture(simulator)
        self.assertEqual([p['kind'] for p in phases],['build','simulation','normalization'])
        self.assertEqual([p['returncode'] for p in phases],[0,0,0])
        self.assertEqual(phases[0]['captured_stdout'],'build-out\n')
        self.assertEqual(phases[0]['captured_stderr'],'build-err\n')
        self.assertEqual(phases[0]['compiled_inputs'],{})
        self.assertEqual(len(phases[1]['compiled_inputs']),1)
        self.assertEqual(result['status'],'pass')
        self.assertEqual(result['returncode'],0)
        self.assertEqual(result['stdout'],phases[1]['stdout'])

    def test_icarus_real_build_runtime_and_normalization_are_distinct(self):
        self.check_success('icarus')

    def test_verilator_real_build_runtime_and_normalization_are_distinct(self):
        self.check_success('verilator')

    def check_compile_failure(self,simulator):
        phases,result=self.capture(simulator,build_code=7)
        self.assertEqual(len(phases),1)
        self.assertEqual(phases[0]['kind'],'build')
        self.assertEqual(phases[0]['returncode'],7)
        self.assertEqual(phases[0]['captured_stderr'],'build-err\n')
        self.assertEqual(result['status'],'known')
        self.assertIsNone(result['returncode'])
        self.assertIsNone(result['stdout'])
        self.assertEqual(result['phases'],'phases.json')

    def test_icarus_nonzero_compile_has_logs_and_no_simulation(self):
        self.check_compile_failure('icarus')

    def test_verilator_nonzero_compile_has_logs_and_no_simulation(self):
        self.check_compile_failure('verilator')

    def test_adapter_timeout_preserves_incomplete_attempt_and_restores_hooks(self):
        phases,result=self.capture(timeout=True)
        self.assertEqual(len(phases),1)
        self.assertEqual(phases[0]['kind'],'build')
        self.assertTrue(phases[0]['timed_out'])
        self.assertIsNone(phases[0]['returncode'])
        self.assertNotEqual(result['status'],'pass')
        self.assertIsNone(result['returncode'])

    def test_build_exception_preserves_attempt_and_restores_both_adapters(self):
        phases,result=self.capture(missing_compiler=True)
        self.assertEqual(len(phases),1)
        self.assertEqual(phases[0]['kind'],'build')
        self.assertEqual(phases[0]['exception'],'FileNotFoundError')
        self.assertIsNone(phases[0]['returncode'])
        self.assertIsNone(result)

    def test_normalization_failure_is_not_a_build_or_runtime_exit(self):
        phases,result=self.capture(normalization_code=4)
        self.assertEqual([p['kind'] for p in phases],['build','simulation','normalization'])
        self.assertEqual([p['returncode'] for p in phases],[0,0,4])
        self.assertEqual(result['returncode'],0)
        self.assertEqual(result['status'],'known')
        self.assertIn('normalization/helper exit',result['reason'])

    def test_runtime_binary_or_compiled_input_drift_invalidates_result(self):
        for drift in ('binary','input'):
            phases,result=self.capture(drift=drift)
            self.assertEqual(result['status'],'stale')
            self.assertTrue(phases[1]['binary_changed'] if drift=='binary' else
                            phases[1]['compiled_inputs_changed'])

    def test_fourstate_verilator_exclusion_does_not_start_or_capture_processes(self):
        with tempfile.TemporaryDirectory() as temporary:
            output=Path(temporary)
            with patch.object(compare,'stage',side_effect=AssertionError('excluded input staged')):
                result=compare.execute({'fourstate':True},output,'verilator',{},1,5,time.monotonic()+5)
            self.assertEqual(result['status'],'unsupported')
            self.assertIsNone(result['returncode'])
            self.assertNotIn('phases',result)
            self.assertEqual(list(output.iterdir()),[])


if __name__=='__main__':
    unittest.main()
