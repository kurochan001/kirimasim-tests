/*
:name: test_dpi_nested_noncontext_call_cannot_inherit_export_permission
:description: An exported function calling a noncontext import must not give it permission to call another export
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dpi_nested_noncontext_call_cannot_inherit_export_permission.expected
:dpi_c: @test_dpi_nested_noncontext_call_cannot_inherit_export_permission.c
:expected_stderr_regex: (?im:^[^\n]*(?:error|invalid|illegal)[^\n]*(?:DPI|export)[^\n]*(?:non.?context|context required|requires? (?:a )?context))
*/
module test_dpi_nested_noncontext_call_cannot_inherit_export_permission;
  import "DPI-C" context function int br_enter_chain(input bit forbid_context, input int tag);
  import "DPI-C" context function int br_context_child(input int tag);
  import "DPI-C" function int br_noncontext_child(input int tag);
  export "DPI-C" function br_sv_bridge;
  export "DPI-C" function br_sv_marker;

  int callbacks;

  function automatic int br_sv_marker(int tag);
    callbacks++;
    $display("export reached tag=%0d", tag);
    return tag + 200;
  endfunction

  function automatic int br_sv_bridge(bit forbid_context, int tag);
    return forbid_context ? br_noncontext_child(tag) : br_context_child(tag);
  endfunction

  initial begin
    int legal_result;
    legal_result = br_enter_chain(0, 5);
    $display("legal result=%0d calls=%0d", legal_result, callbacks);
    $display("attempting nested noncontext export");
    void'(br_enter_chain(1, 7));
  end
endmodule
