/*
:name: test_vpi_definition_handles_cannot_read_or_write_class_storage
:description: Class definition handles reject value operations for member variables and named events
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.31 38.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_definition_handles_cannot_read_or_write_class_storage.expected
:expected_stderr_regex: (?im)\A(?=[\s\S]*^own read error: [^\n]+)(?=[\s\S]*^own write error: [^\n]+)(?=[\s\S]*^shared read error: [^\n]+)(?=[\s\S]*^shared write error: [^\n]+)(?=[\s\S]*^pulse read error: [^\n]+)(?=[\s\S]*^pulse write error: [^\n]+)[\s\S]*\Z
:vpi_c: @vpi_class_scope_access_probes.c
*/
module test_vpi_definition_handles_cannot_read_or_write_class_storage;
  class state_cell;
    int own;
    static int shared;
    event pulse;
  endclass
  state_cell object_instance;
  event live_pulse;
  bit fired;

  always @(live_pulse) fired = 1;

  initial begin
    object_instance = new;
    object_instance.own = 19;
    state_cell::shared = 17;
    #1 $vt_check_members(0);
    #1 $display("storage=%0d/%0d live event fired=%0d",
                object_instance.own, state_cell::shared, fired);
  end
endmodule
