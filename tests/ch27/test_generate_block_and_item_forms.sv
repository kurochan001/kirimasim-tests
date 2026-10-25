/*
:name: test_generate_block_and_item_forms
:description: A generate region may hold no items, a generate block is one item or a labeled begin-end, a loop may initialize a genvar with or without the keyword and update it by assignment, compound assignment or a prefix or postfix increment or decrement, and a case item takes several constants or a default with or without a colon (IEEE 1800-2023 Sections 27.3 to 27.5)
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.3 27.4 27.5 A.4.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_block_and_item_forms.expected
*/
// IEEE 1800-2023 §27.3 with A.4.2: a generate region is generate, then any
// number of generate items, then endgenerate, so an empty region is legal.
// A generate block is either one generate item or begin-end with an optional
// identifier before begin and after it (and after end). A loop generate may
// write genvar in front of the initialized identifier or leave it out, and it
// may update the index by an assignment, a compound assignment, a prefix
// increment or a postfix decrement. A case generate item takes a list of
// constants, and a default item takes an optional colon.
//
// Each generate block below drives one net with gi_drv, whose output is the
// genvar value of that block, so the printed nets show which blocks were
// elaborated and with which index. a_single is a loop whose block is the one
// instance, w_add a loop with a compound assignment, w_pre a loop with the
// prefix label form (named g_pre, which nothing refers to), w_post a loop
// that counts down by a postfix decrement, and w_if and w_case the selected
// alternatives. g_dflt takes the default of a case with a colon. g_items
// holds the three kinds of generate item: an interface instance, a
// continuous assignment and an always_comb.
// Icarus Verilog 13.0 does not accept the identifier before begin (the
// prefix label of g_pre); Verilator 5.052 does and reproduces the output.

module gi_drv #(parameter int V = 0) (output logic o);
  assign o = V[0];
endmodule

interface gi_ifc;
  logic sig;
endinterface

module test_generate_block_and_item_forms;
  localparam int SEL = 3;
  localparam int SEL2 = 7;

  generate
  endgenerate

  wire [1:0] w_single, w_add, w_pre, w_post;
  wire w_if, w_case, w_default, w_colon, w_items;

  for (genvar a = 0; a < 2; a = a + 1)
    gi_drv #(.V(a)) u_single (.o(w_single[a]));

  for (genvar b = 0; b < 2; b += 1) begin : g_add
    gi_drv #(.V(b)) u (.o(w_add[b]));
  end

  genvar e;
  for (e = 0; e < 2; e = e + 1) g_pre : begin
    gi_drv #(.V(e)) u (.o(w_pre[e]));
  end

  for (genvar d = 1; d >= 0; d--) begin : g_post
    gi_drv #(.V(d)) u (.o(w_post[d]));
  end

  if (SEL == 3) begin : g_if
    gi_drv #(.V(1)) u (.o(w_if));
  end : g_if
  else begin : g_if
    gi_drv #(.V(0)) u (.o(w_if));
  end

  case (SEL)
    0, 1: begin : g_case
      gi_drv #(.V(0)) u (.o(w_case));
    end
    2, 3: begin : g_case
      gi_drv #(.V(1)) u (.o(w_case));
    end
  endcase

  case (SEL2)
    0: assign w_default = 1'b0;
    default gi_drv #(.V(1)) u (.o(w_default));
  endcase

  case (SEL2 + 1)
    0, 1: begin : g_dflt
      assign w_colon = 1'b0;
    end
    default : begin : g_dflt
      assign w_colon = 1'b1;
    end
  endcase

  if (SEL == 3) begin : g_items
    gi_ifc fi ();
    logic x;
    always_comb x = 1'b1;
    assign fi.sig = x;
    assign w_items = fi.sig;
  end

  initial begin
    #1 $display("single=%b add=%b pre=%b post=%b", w_single, w_add, w_pre, w_post);
    $display("if=%b case=%b default=%b colon=%b items=%b",
             w_if, w_case, w_default, w_colon, w_items);
  end
endmodule
