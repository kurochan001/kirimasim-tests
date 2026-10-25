/*
:name: test_identifier_categories_in_declarations
:description: The names a design gives to its module, instances, nets, variables, ports in all three directions, tasks, functions, named blocks, generate blocks, genvars, parameters, types, enumeration values, structure members, interfaces, arrays, dynamic arrays, index variables and formal arguments are identifiers, and each names an object whose value or effect the test prints (IEEE 1800-2023 Sections 5.6 and 5.6.1)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.6 5.6.1 6.18 27.4 A.9.3 A.10
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_identifier_categories_in_declarations.expected
*/
// IEEE 1800-2023 A.9.3: each of these name categories is an identifier:
// module, instance, net, variable, port, input, output and inout port, task,
// function, tf, block, generate block, genvar, parameter, type, enum, member,
// interface, array, dynamic array variable, index variable and formal. §5.6
// and §5.6.1: an identifier is a simple identifier or an escaped one, and a
// simple identifier starts with a letter or an underscore. §6.18: a typedef
// declares a type name. §27.4: a genvar is the constant primary of a loop
// generate construct.
//
// The module test_identifiers has the instance u_leaf of the module id_leaf,
// whose ports i, o and io are an input, an output and an inout, the net n1
// and the wire io1, the variables v1, sum, arr and dyn, the instance bus of
// the interface id_ifc, the task t_add with the formals formal_in and
// formal_out, the function f_mul with the formals formal_a and formal_b, the
// named block blk, the generate block g_loop with its genvar g, the parameter
// P, the localparam LP, the types e_t and pair_t, the enum value E_TWO, the
// members hi and lo, and the index variable i of the foreach loop.
// With v1 = 2 the output of u_leaf is 3 and its inout io is 2; the two
// generate blocks give 1 and 2, so gsum is 3. pr is 8'hA5, t_add makes sum 4
// + 3 = 7, arr[1] is 7, and dyn[0] + dyn[1] is 17; f_mul(3, 4) is 12. The
// enumeration e_t is 2 bits and E_TWO is 2, and pair_t is 8 bits. Icarus
// Verilog 13.0 and Verilator 5.052 produce this output.

`timescale 1ns/1ns

interface id_ifc (input logic clk);
  logic [3:0] d;
  typedef int ifc_int;
  modport mp (input d, clk);
endinterface

module id_leaf (input logic [3:0] i, output logic [3:0] o,
                inout logic [3:0] io);
  assign o = i + 1;
  assign io = i;
endmodule

module test_identifier_categories_in_declarations;
  typedef enum logic [1:0] { E_ONE = 1, E_TWO = 2 } e_t;
  typedef struct packed { logic [3:0] hi; logic [3:0] lo; } pair_t;

  parameter int P = 3;
  localparam [3:0] LP = 4'hC;
  wire [3:0] n1;
  logic [3:0] v1;
  wire [3:0] io1;
  int arr [0:3];
  int dyn [];
  pair_t pr;
  id_ifc bus ();
  e_t e;
  int sum;
  logic clk = 0;

  task automatic t_add(input int formal_in, output int formal_out);
    formal_out = formal_in + P;
  endtask

  function automatic int f_mul(input int formal_a, input int formal_b);
    return formal_a * formal_b;
  endfunction

  for (genvar g = 0; g < 2; g++) begin : g_loop
    wire [3:0] gn;
    assign gn = g + 1;
  end

  wire [3:0] gsum = g_loop[0].gn + g_loop[1].gn;

  id_leaf u_leaf (.i(v1), .o(n1), .io(io1));

  initial begin
    v1 = 4'h2;
    e = E_TWO;
    pr.hi = 4'hA;
    pr.lo = 4'h5;
    arr[1] = 7;
    dyn = new[2];
    dyn[0] = 8;
    dyn[1] = 9;
    sum = 0;
    begin : blk
      sum = 1;
    end
    t_add(4, sum);
    #1;
    $display("cats %0d %h %0d %0d %0d", P, LP, $bits(pair_t), e, $bits(e_t));
    $display("net %h %h %h %h", n1, u_leaf.o, gsum, io1);
    $display("var %h %0d %0d %0d %0d", pr, sum, arr[1], dyn[0] + dyn[1],
             f_mul(3, 4));
    foreach (arr[i]) $display("idx %0d %0d", i, arr[i]);
  end
endmodule
