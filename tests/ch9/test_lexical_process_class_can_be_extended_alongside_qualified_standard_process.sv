/*
:name: test_lexical_process_class_can_be_extended_alongside_qualified_standard_process
:description: A lexical process class can be extended while qualified std process retains its separate identity
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.7 26.7 8.13 G.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_lexical_process_class_can_be_extended_alongside_qualified_standard_process.expected
*/
module test_lexical_process_class_can_be_extended_alongside_qualified_standard_process;
  class process;
    virtual function int label();
      return 31;
    endfunction
  endclass

  typedef process local_process;
  class derived_process extends local_process;
    virtual function int label();
      return 67;
    endfunction
  endclass

  typedef std::process runtime_process;

  initial begin
    derived_process derived;
    local_process local_handle;
    runtime_process current, repeated;
    derived = new;
    local_handle = derived;
    current = runtime_process::self();
    repeated = std::process::self();
    if (current == null) $fatal(1, "current process handle is missing");
    $display("lexical label=%0d standard-running=%b same-thread=%b",
             local_handle.label(), current.status() == std::process::RUNNING, current == repeated);
  end
endmodule
