/*
:name: test_vpi_pattern_constraint_properties
:description: VPI property access for a pure constraint and named nested structure patterns
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.34 37.72 37.3.1 12.6 18.5.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @vpi_pattern_constraint_properties/client.c
:expected_stdout: @test_vpi_pattern_constraint_properties.expected
:files: vpi_pattern_constraint_properties/client.h vpi_pattern_constraint_properties/seed.cpp vpi_pattern_constraint_properties/seeded.expected
*/
module test_vpi_pattern_constraint_properties;
  virtual class pure_owner;
    rand int value;
    pure constraint pending;
  endclass

  class implementation_owner extends pure_owner;
`ifndef OMIT_PURE_IMPLEMENTATION
    constraint pending { value == 41; }
`endif
  endclass

  class fixed_control;
    rand int value;
    constraint : final permanent { value == 62; }
  endclass

`ifdef OVERRIDE_FINAL_CONSTRAINT
  class invalid_override extends fixed_control;
    constraint permanent { value == 77; }
  endclass
`endif

  typedef struct packed { int value; int extra; } leaf_t;
  typedef struct packed { leaf_t left; leaf_t right; } root_t;
  root_t data = '{'{19, 20}, '{30, 31}};

  task automatic classify;
    case (data) matches
`ifdef SWAP_PATTERN_MEMBERS
      '{left: '{extra: .second}, right: '{value: .first}}:
`else
      '{right: '{extra: .second}, left: '{value: .first}}:
`endif
        $display("matched first=%0d second=%0d", first, second);
      default: $display("unexpected pattern case");
    endcase
  endtask

  initial begin
    automatic implementation_owner implemented = new;
    automatic fixed_control fixed = new;
    automatic int implemented_ok = implemented.randomize();
    automatic int fixed_ok = fixed.randomize();
    $display("constraints implemented=%0d/%0d final=%0d/%0d",
             implemented_ok, implemented.value, fixed_ok, fixed.value);
    $vt_pattern_constraint;
    classify();
    $finish(0);
  end
endmodule
