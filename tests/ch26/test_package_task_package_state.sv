/*
:name: test_package_task_package_state
:description: A package task and function imported in a module header act on the package's own enum variable, parameter and type, and one task call returns the new state (IEEE 1800-2023 Sections 26.4 and 26.3)
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.4 26.3 13.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_task_package_state.expected
*/
// IEEE 1800-2023 §26.4: an import in a module header, before the port list,
// makes the package items visible in the port declarations and in the module
// body. §26.3: the package variables, parameters and types are one set for the
// whole simulation, so the task advance() changes ps_state, which the module
// reads, and its output gives the new state. next_state() chooses the next
// value of the enum.

package ps_pkg;
  parameter int STEP = 3;
  typedef enum logic [1:0] {IDLE, RUN, DONE} state_t;

  state_t ps_state = IDLE;
  int calls = 0;

  function automatic state_t next_state(state_t s);
    case (s)
      IDLE: return RUN;
      RUN:  return DONE;
      default: return IDLE;
    endcase
  endfunction

  task automatic advance(output state_t seen);
    ps_state = next_state(ps_state);
    calls++;
    seen = ps_state;
  endtask
endpackage

module test_package_task_package_state
  import ps_pkg::*;
(
  output state_t seen
);
  initial begin
    advance(seen);
    $display("state=%0d seen=%0d calls=%0d STEP=%0d",
             ps_state, seen, calls, STEP);
    advance(seen);
    $display("state=%0d seen=%0d calls=%0d",
             ps_state, seen, calls);
  end
endmodule
