/*
:name: test_vpi_class_specializations_are_scopes_with_definition_relations
:description: Class specialization scopes expose variables and class internal scopes lead back to their definitions
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.12 37.31 37.32
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_class_specializations_are_scopes_with_definition_relations.c
:expected_stdout: @test_vpi_class_specializations_are_scopes_with_definition_relations.expected
*/
module test_vpi_class_specializations_are_scopes_with_definition_relations;
  class sized_scope #(int WIDTH = 4);
    logic [WIDTH-1:0] instance_value;
    static int shared_value;

    function int sample();
      begin : sample_scope
        int observed = WIDTH;
        return observed;
      end
    endfunction
  endclass

  sized_scope #(4) narrow_object;
  sized_scope #(7) wide_object;

  initial begin
    narrow_object = new;
    wide_object = new;
    #1 $vt_class_scope_relations;
  end
endmodule
