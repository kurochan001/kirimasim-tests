/*
:name: test_vpi_class_definition_and_specialization_value_access_differ
:description: Class definition variables lack values and specialization variables expose only their static storage
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.31 37.32 37.17
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_class_definition_and_specialization_value_access_differ.expected
:vpi_c: @test_vpi_class_definition_and_specialization_value_access_differ.c
*/
module test_vpi_class_definition_and_specialization_value_access_differ;
  class receipt #(int code = 0);
    static int shared = code * 100;
    int own;
    function new(int value);
      own = value;
    endfunction
  endclass

  typedef receipt #(3) first_type;
  typedef receipt #(7) second_type;
  first_type one = new(31), another = new(37);
  second_type two = new(73);

  initial begin
    first_type::shared = 307;
    second_type::shared = 709;
    #1 $vt_probe_class_value_routes;
    first_type::shared = 311;
    #1 $vt_probe_class_value_routes;
    $display("instance values=%0d %0d %0d static values=%0d %0d",
             one.own, another.own, two.own, first_type::shared, second_type::shared);
  end
endmodule
