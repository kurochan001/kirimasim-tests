/*
:name: test_explicit_zero_return_after_function_result_passed_by_ref
:description: An explicit zero return supersedes an earlier write through ref (IEEE 1800-2023 Section 13.4.1)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4.1 13.5.2
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_explicit_zero_return_after_function_result_passed_by_ref.expected
:expected_exit: 0
*/
// load writes five to the implicit result variable. The explicit return
// evaluates five AND the selected mask, including zero for mask two.

module test_explicit_zero_return_after_function_result_passed_by_ref;
  class database;
    static function void load(ref int result);
      result = 5;
    endfunction
  endclass
  class masker;
    function int selected(int requested);
      selected = 0;
      database::load(selected);
      return selected & requested;
    endfunction
  endclass

  initial begin
    automatic masker m = new;
    int first, second, third;
    first = m.selected(1);
    second = m.selected(2);
    third = m.selected(4);
    $display("CHECK masks=%0d/%0d/%0d", first, second, third);
    $finish;
  end
endmodule
