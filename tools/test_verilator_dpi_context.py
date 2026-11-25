"""Regression tests for matching DPI wrapper definitions and their call sites."""

import unittest

from run_verilator_dpi_context import inspect


GENERATED = """\
void Vcontext__Vdpiimwrap_cell__h65_context_TOP(const ::VerilatedScope* __Vscopep) {
    Verilated::dpiContext(__Vscopep, __Vfilenamep, __Vlineno);
    int status = h65_context(delta__Vcvt);
}
void Vcontext__Vdpiimwrap_cell__h65_arguments_TOP(int item, int& count) {
    int status = h65_arguments(item__Vcvt, &count__Vcvt);
}
void exercise() {
    Vcontext__Vdpiimwrap_cell__h65_context_TOP(vlSymsp->__Vscopep_top__left, 3);
    Vcontext__Vdpiimwrap_cell__h65_arguments_TOP(17, count);
    Vcontext__Vdpiimwrap_cell__h65_context_TOP(vlSymsp->__Vscopep_top__right, 4);
    Vcontext__Vdpiimwrap_cell__h65_arguments_TOP(33, count);
    Vcontext__Vdpiimwrap_cell__h65_context_TOP(vlSymsp->__Vscopep_top__left, 8);
    Vcontext__Vdpiimwrap_cell__h65_arguments_TOP(27, count);
}
"""


class VerilatorDpiCodegenTests(unittest.TestCase):
    def test_context_and_ordinary_wrap_and_call_as_expected(self):
        self.assertEqual(len(inspect(GENERATED)), 4)
        self.assertTrue(all(inspect(GENERATED).values()))

    def test_correct_wrapper_still_needs_distinct_instance_scopes(self):
        wrong = GENERATED.replace("__Vscopep_top__right", "__Vscopep_top__left")
        checks = inspect(wrong)
        self.assertFalse(checks["context_passes_instance_scopes"])
        self.assertTrue(checks["context_initialized_before_call"])

    def test_ordinary_scope_setter_and_scope_argument_are_detected(self):
        wrong = GENERATED.replace("int status = h65_arguments", "Verilated::dpiContext(scope);\n    int status = h65_arguments")
        wrong = wrong.replace("_h65_arguments_TOP(17, count)", "_h65_arguments_TOP(__Vscopep_top__left, 17, count)")
        checks = inspect(wrong)
        self.assertFalse(checks["ordinary_keeps_original_arguments"])
        self.assertFalse(checks["ordinary_has_no_scope_argument"])


if __name__ == "__main__":
    unittest.main()
