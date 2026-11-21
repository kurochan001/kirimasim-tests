// Copyright (c) 2026 The kirimasim Authors
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Compiled next to bench/bus_fabric.sv, unchanged, for the holdout waveform
// conditions of Icarus Verilog and Verilator: every signal of the bus_fabric
// hierarchy is recorded (21.7.1.2, $dumpvars with level 0). kirimasim records
// the same scope with --wave=FILE instead. The file name comes from the macro
// HOLDOUT_WAVE_FILE; the format from the simulator's option (vvp -fst, or
// --trace / --trace-fst when built with the other compiler).
`timescale 1ns/1ns
module holdout_waveform;
  initial begin
    $dumpfile(`HOLDOUT_WAVE_FILE);
    $dumpvars(0, bus_fabric);
  end
endmodule
