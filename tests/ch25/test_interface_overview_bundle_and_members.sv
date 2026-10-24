/*
:name: test_interface_overview_bundle_and_members
:description: An interface instance bundles its parameters, constants, variables, nets, subroutines, type-parameter members, processes and continuous assignments, passes through one port, and its members are referenced through the instance or port name (IEEE 1800-2023 Section 25.2)
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_overview_bundle_and_members.expected
*/
// IEEE 1800-2023 §25.2: an interface is a named bundle of nets and variables
// that a design instantiates and that can be accessed through a port as a
// single item, with its members referenced where needed. It can also hold
// parameters, constants, functions, tasks, members whose type is passed in as
// a type parameter, initial and always procedures and continuous assignments,
// and its members are referenced relative to the instance name. ov_bus has
// all of these; ov_user reaches the variable data, the net data_inv and the
// member tag of type T through its one port b, and calls the task put
// through it; the top module reads the parameter W, the localparam DEPTH, the
// const variable K and calls the function scaled through the instance name.
// bus overrides W to 12 and T to shortint, so tag has 16 bits and holds -5.
// The always procedure copies data into copy when data changes, and the
// initial procedure sets started.
// Oracle checks: Icarus Verilog 13.0 does not support interface ports.

interface ov_bus #(parameter int W = 8, parameter type T = byte);
  localparam int DEPTH = 2 * W;
  const int K = 3;
  logic [W-1:0] data;
  wire [W-1:0] data_inv;
  T tag;
  logic [W-1:0] copy;
  bit started;

  assign data_inv = ~data;
  initial started = 1'b1;
  always @(data) copy = data;

  function automatic int scaled(input int v);
    return v * K;
  endfunction

  task automatic put(input logic [W-1:0] v, input T t);
    data = v;
    tag = t;
  endtask
endinterface

module ov_user(ov_bus b);
  initial begin
    #1 b.put(12'h3C5, -5);
    #1 $display("user: data=%h data_inv=%h tag=%0d", b.data, b.data_inv, b.tag);
  end
endmodule

module test_interface_overview_bundle_and_members;
  ov_bus #(.W(12), .T(shortint)) bus ();
  ov_user u (bus);

  initial begin
    #3 $display("top: W=%0d DEPTH=%0d K=%0d bits(tag)=%0d",
                bus.W, bus.DEPTH, bus.K, $bits(bus.tag));
    $display("top: scaled(4)=%0d copy=%h started=%0d", bus.scaled(4), bus.copy, bus.started);
  end
endmodule
