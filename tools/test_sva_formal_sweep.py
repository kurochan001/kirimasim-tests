"""Boundary, binding and evidence checks; no external solver is required."""

import copy
from dataclasses import asdict
import json
from pathlib import Path
import tempfile
import unittest
from unittest import mock

import sva_formal_cases as cases
import sva_formal_sweep as sweep
from sva_reference import formal
from sva_reference.module import parse_module
from sva_reference.parser import parse_sequence


class ParameterCasesTests(unittest.TestCase):
    def test_documented_parameter_matrix_is_complete_and_unique(self):
        catalogue = cases.catalogue()
        self.assertEqual(len(catalogue), 111)
        self.assertEqual(len({case.name for case in catalogue}),111)
        for family in ["delay","first","repeat"]:
            self.assertEqual({case.parameters for case in catalogue if case.family==family},
                             {(lo,hi) for lo in range(4) for hi in range(lo,4)})
        self.assertEqual({case.parameters for case in catalogue if case.family=="within"},
                         {(inner,outer) for outer in range(1,4) for inner in range(1,outer+1)})

    def test_zero_and_equal_boundaries_have_explicit_reference_cases(self):
        catalogue={case.name:case for case in cases.catalogue()}
        self.assertEqual(catalogue["repeat_0_0"].reference,{0:"1"})
        self.assertIn(1,catalogue["delay_0_0"].reference)
        self.assertIn("h_x[1] && h_x[0]",catalogue["within_1_1"].reference[2])
        self.assertIn("h_c[0]",catalogue["tie_1"].reference[2])

    def test_every_export_has_unrestricted_inputs_and_a_real_comparison(self):
        for case in cases.catalogue():
            model,metadata=sweep.export(case)
            self.assertIn("(* anyseq *)",model)
            self.assertIn("assert(actual_count==reference_count)",model)
            self.assertNotIn("assume",model)
            self.assertGreater(metadata["states"],0)

    def test_negative_controls_are_present_only_at_selected_boundaries(self):
        controls=[case for case in cases.catalogue() if len(sweep.plan(case))>2]
        self.assertEqual({case.name for case in controls},{"tie_1","within_1_1","repeat_0_0"})
        for case in controls:
            model,_=sweep.export(case)
            wrong,_=sweep.export(case,mutation=True)
            self.assertNotEqual(model,wrong)
            self.assertEqual(model.split("always @* begin assert")[0],wrong.split("always @* begin assert")[0])


class SourceBindingTests(unittest.TestCase):
    def test_boolean_predicate_abstraction_allows_aliases_but_preserves_repetition(self):
        pattern=parse_sequence("a ##1 b")
        bound=sweep.predicate_binding(pattern,parse_sequence("(x & y) ##1 (x & y)"))
        self.assertIsNotNone(bound)
        self.assertEqual(bound["a"],bound["b"])
        self.assertIsNone(sweep.predicate_binding(parse_sequence("a ##1 a"),parse_sequence("x ##1 y")))

    def test_named_boolean_sequences_do_not_collapse_into_boolean_or(self):
        module=parse_module('''module m; sequence s; a; endsequence
          c: cover sequence (@(posedge clk) s or s); endmodule''')
        named=module.directives[0].spec.body
        plain=parse_sequence("a or a")
        self.assertNotEqual(sweep.skeleton(named),sweep.skeleton(plain))

    def fixture(self,directory,source):
        root=Path(directory)
        path=root/"tests/ch16/test_tiny.sv"
        path.parent.mkdir(parents=True)
        path.write_text(source)
        manifest=root/"manifest.json"
        manifest.write_text("{}")
        return root,manifest,path

    def test_wrapper_is_bound_once_and_predicates_are_reviewable(self):
        with tempfile.TemporaryDirectory() as directory:
            root,manifest,_=self.fixture(directory,'''module m;
              sequence s; (x & y) ##1 z; endsequence
              c: cover sequence (@(posedge clk) s); endmodule''')
            with mock.patch.object(sweep,"ROOT",root),mock.patch.object(sweep.m3,"MANIFEST",manifest),mock.patch.object(sweep,"PILOTS",{"test_tiny":None}):
                result=sweep.bindings()
        self.assertEqual(len(result["fragments"]),1)
        fragment=result["fragments"][0]
        self.assertEqual(fragment["cases"],["delay_1_1"])
        self.assertIn("binary",fragment["predicates"]["delay_1_1"]["a"])
        self.assertEqual(result["directives"][0]["assertion"].strip(),"@(posedge clk) s")

    def test_unmatched_directives_remain_visible_and_parse_errors_propagate(self):
        with tempfile.TemporaryDirectory() as directory:
            root,manifest,path=self.fixture(directory,"module m; a: assert property (@(posedge clk) x); endmodule")
            with mock.patch.object(sweep,"ROOT",root),mock.patch.object(sweep.m3,"MANIFEST",manifest),mock.patch.object(sweep,"PILOTS",{"test_tiny":None}):
                result=sweep.bindings()
                self.assertEqual(result["directives"][0]["status"],"no_family_match")
                path.write_text("module m; a: assert property (@(posedge clk) x ##); endmodule")
                with self.assertRaises(ValueError):
                    sweep.bindings()

    def test_emit_only_never_reads_suite_expectations_or_invokes_a_tool(self):
        original_text,original_bytes=Path.read_text,Path.read_bytes
        def text(path,*args,**kwargs):
            if path.suffix==".expected":raise AssertionError("expectation read")
            return original_text(path,*args,**kwargs)
        def data(path,*args,**kwargs):
            if path.suffix==".expected":raise AssertionError("expectation read")
            return original_bytes(path,*args,**kwargs)
        with tempfile.TemporaryDirectory() as directory,mock.patch.object(Path,"read_text",text),mock.patch.object(Path,"read_bytes",data),mock.patch.object(sweep.subprocess,"Popen",side_effect=AssertionError("external tool")):
            result=sweep.run(directory,"unused-sby",emit_only=True)
            self.assertEqual(len(list(Path(directory).glob("*.sv"))),111)
        self.assertFalse(result["ok"])
        self.assertFalse(result["source_changed"])

    def test_current_population_is_fully_accounted_for_without_claiming_whole_tests(self):
        result=sweep.bindings()
        self.assertEqual(len(result["population"]),38)
        self.assertEqual(len(result["directives"]),188)
        self.assertTrue(any(d["status"]=="no_family_match" for d in result["directives"]))
        ids={(r["test"],r["directive"],tuple(r["subtree"])) for r in result["fragments"]}
        self.assertEqual(len(ids),len(result["fragments"]))
        self.assertTrue(all(r["scope"]=="Boolean sequence fragment only" for r in result["fragments"]))


class EvidenceTests(unittest.TestCase):
    def report(self,case):
        source,metadata=sweep.export(case)
        jobs=[]
        for mode,mutant in sweep.plan(case):
            jobs.append({"case":formal.job_name(case.name,mode,mutant),"mode":mode,"mutation":mutant,
                         "status":"PASS","expected":"PASS","rc":0,"ok":True,"traces":[],
                         "depth":metadata["depth"],"family":case.family,"expression":case.expression,"parameters":list(case.parameters),
                         "model_sha256":sweep.sha(source.encode()),
                         "sby_sha256":sweep.sha(formal.sby_text(mode,metadata["depth"],30).encode())})
        return {"schema":1,"source_hashes":sweep.hashes(),"bindings":{},"models":json.loads(json.dumps([asdict(case)])),
                "jobs":jobs,"counts":{"PASS":2},"source_changed":False,"ok":True,"timeout":30}

    def test_saved_evidence_rejects_stale_incomplete_or_mislabelled_proofs(self):
        case=next(c for c in cases.catalogue() if c.name=="repeat_1_1")
        report=self.report(case)
        with mock.patch.object(cases,"catalogue",return_value=[case]),mock.patch.object(sweep,"bindings",return_value={}):
            self.assertTrue(sweep.validate(report))
            for change in [lambda x:x.update(source_hashes={}),lambda x:x.update(bindings={"stale":True}),
                           lambda x:x.update(jobs=x["jobs"][:1]),lambda x:x.update(models=[]),
                           lambda x:x["jobs"][0].update(model_sha256="0"*64),
                           lambda x:x["jobs"][0].update(status="UNKNOWN"),
                           lambda x:x["jobs"][0].update(depth=1),lambda x:x.update(counts={})]:
                bad=copy.deepcopy(report);change(bad)
                with self.assertRaises(ValueError):sweep.validate(bad)

    def test_existing_outputs_are_not_overwritten(self):
        with tempfile.TemporaryDirectory() as directory:
            path=Path(directory)/"keep";path.write_text("previous run")
            with self.assertRaisesRegex(ValueError,"new or empty"):
                sweep.run(directory,"unused-sby",emit_only=True)
            self.assertEqual(path.read_text(),"previous run")


if __name__=="__main__":
    unittest.main()
