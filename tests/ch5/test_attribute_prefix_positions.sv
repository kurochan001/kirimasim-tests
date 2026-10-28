/*
:name: test_attribute_prefix_positions
:description: An attribute instance is accepted as the prefix of a module, a declaration, a module item, a statement, a generate item, a port connection and an ANSI port declaration, and the arbitrary attribute names change no value (IEEE 1800-2023 Section 5.12)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.12
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_attribute_prefix_positions.expected
*/
// IEEE 1800-2023 §5.12: "An attribute_instance can appear in the
// SystemVerilog description as a prefix attached to a declaration, a module
// item, a statement, or a port connection." The test puts an attribute
// instance before each of those categories at many grammar-authorized
// positions: a module and a class declaration, a net, variable, parameter,
// localparam and typedef declaration, a function and a task declaration, a
// continuous assignment, a module instance and its named port connection, an
// ANSI port declaration, an always_comb block, an initial block, a loop
// generate and a conditional generate, the items inside them, and statements
// (blocking assignment, if, case, for, repeat, named block, task call), plus
// an interface and a package with one item each. The names are arbitrary and
// have no standard meaning, so §5.12 gives them no operational effect. The
// printed values are those of the same design without attributes: v starts at
// 3, the if makes it 4, the case item 4'h4 leaves ob 0, the for
// adds 2, the repeat subtracts 1, the named block xor 1 gives 4, put(9) makes
// v 9, n follows v as 9, and inc(3) is 4. The output ub of the instance is
// declared before the instance, so the reference does not create an implicit
// net that the later explicit declaration would redeclare (§6.10). A tool
// that rejected any authorized
// prefix position would fail before printing, and one that attached the
// attribute to the wrong element or changed the value would print another
// line. Verilator 5.052 reproduces this output. Icarus Verilog 13.0 rejects
// the attribute before a function declaration with a syntax error even
// though A.1.4 gives module_common_item an attribute prefix, so it cannot be
// the oracle for this test.
module attr_leaf (
  (* pfx_port *) input logic a,
  output logic b
);
  assign b = a;
endmodule

(* pfx_module *) module test_attribute_prefix_positions;
  (* pfx_net *) wire [3:0] n;
  (* pfx_var *) logic [3:0] v;
  (* pfx_comb *) logic [3:0] cv;
  (* pfx_param *) parameter int P = 3;
  (* pfx_localparam *) localparam int L = 4;
  (* pfx_typedef *) typedef logic [3:0] nib_t;

  (* pfx_func *) function automatic int inc(input int a);
    return a + 1;
  endfunction

  (* pfx_task *) task automatic put(input int a);
    v = a[3:0];
  endtask

  (* pfx_assign *) assign n = v;
  (* pfx_always *) always_comb cv = n;

  wire ub;

  (* pfx_inst *) attr_leaf u ((* pfx_conn *) .a(v[0]), .b(ub));
  logic ob;

  (* pfx_gen *) for (genvar g = 0; g < 2; g++) begin : gs
    (* pfx_genitem *) wire [3:0] gw = g[3:0];
  end

  (* pfx_ifgen *) if (L == 4) begin : gif
    (* pfx_ifgenitem *) logic gv;
  end

  (* pfx_class *) class C;
    (* pfx_member *) int m = 7;
  endclass

  (* pfx_init *) initial begin
    C c;
    nib_t t;
    c = new();
    t = 4'h0;
    (* pfx_stmt *) v = 4'h3;
    (* pfx_if *) if (P == 3) v = v + 1;
    else v = 4'h0;
    (* pfx_case *) case (v)
      4'h4: ob = 1'b0;
      default: ob = 1'b1;
    endcase
    (* pfx_for *) for (int i = 0; i < 2; i++) v = v + 1;
    (* pfx_repeat *) repeat (1) v = v - 1;
    (* pfx_block *) begin : blk
      v = v ^ 4'h1;
      t = v;
    end
    (* pfx_call *) put(4'h9);
    #1;
    $display("v=%h n=%h ob=%b inc=%0d", v, n, ob, inc(P));
    $display("gen=%h class=%0d t=%h cv=%h", gs[1].gw, c.m, t, cv);
  end
endmodule

(* pfx_interface *) interface attr_ifc;
  (* pfx_ifcitem *) logic s;
endinterface

(* pfx_package *) package attr_pkg;
  (* pfx_pkgitem *) parameter int Q = 5;
endpackage
