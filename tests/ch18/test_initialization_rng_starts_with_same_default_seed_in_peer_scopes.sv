/*
:name: test_initialization_rng_starts_with_same_default_seed_in_peer_scopes
:description: Peer modules interfaces programs and packages start their initialization RNGs from the default seed
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_initialization_rng_starts_with_same_default_seed_in_peer_scopes.expected
*/
// Each host has one static thread or object, so seed consumption order
// across different kinds of static initialization does not affect the check.
`timescale 1ns/1ns
package rng_types;
  class rng_probe;
    rand bit [63:0] value;

    function bit [255:0] gather();
      bit [255:0] result;
      for (int i = 0; i < 4; i++) begin
        if (!randomize())
          $fatal(1, "unconstrained object randomize failed");
        result[i*64 +: 64] = value;
      end
      return result;
    endfunction
  endclass
endpackage

package rng_pkg_a;
  rng_types::rng_probe probe = new;
  function bit [255:0] collect();
    return probe.gather();
  endfunction
endpackage

package rng_pkg_b;
  rng_types::rng_probe probe = new;
  function bit [255:0] collect();
    return probe.gather();
  endfunction
endpackage

module rng_mod(output bit [127:0] thread_bits, output bit ready);
  initial begin
    #1;
    for (int i = 0; i < 4; i++)
      thread_bits[i*32 +: 32] = $urandom;
    ready = 1;
  end
endmodule

interface rng_iface;
  bit [127:0] thread_bits;
  bit ready = 0;

  initial begin
    #1;
    for (int i = 0; i < 4; i++)
      thread_bits[i*32 +: 32] = $urandom;
    ready = 1;
  end
endinterface

program rng_program(output bit [127:0] thread_bits, output bit ready);
  initial begin
    #1;
    for (int i = 0; i < 4; i++)
      thread_bits[i*32 +: 32] = $urandom;
    ready = 1;
    #100;
  end
endprogram

module test_initialization_rng_starts_with_same_default_seed_in_peer_scopes;
  wire [127:0] module_a, module_b, program_a, program_b;
  wire module_ready_a, module_ready_b, program_ready_a, program_ready_b;

  rng_mod module_left(module_a, module_ready_a);
  rng_mod module_right(module_b, module_ready_b);
  rng_iface iface_left();
  rng_iface iface_right();
  rng_program program_left(program_a, program_ready_a);
  rng_program program_right(program_b, program_ready_b);

  initial begin
    bit [255:0] package_a, package_b;
    #3;
    package_a = rng_pkg_a::collect();
    package_b = rng_pkg_b::collect();
    $display("completed module=%b%b interface=%b%b program=%b%b",
             module_ready_a, module_ready_b, iface_left.ready, iface_right.ready,
             program_ready_a, program_ready_b);
    $display("peer static threads module=%0d interface=%0d program=%0d",
             module_a == module_b,
             iface_left.thread_bits == iface_right.thread_bits,
             program_a == program_b);
    $display("package object=%0d", package_a == package_b);
    $finish(0);
  end
endmodule
