/*
:name: test_library_map_relative_directory_path_aliases
:description: Relative directory slash and slash-star match the same files, as do bare and dot-prefixed globs
:tags: ch33
:type: simulation
:lrm: 1800-2023 33.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: path_aliases_config
:expected_exit: 0
:expected_stdout: @test_library_map_relative_directory_path_aliases.expected
:files: libmap_aliases/maps/directories.map libmap_aliases/maps/slash/base.v libmap_aliases/maps/slash/item.sv libmap_aliases/maps/slash/child/decoy.sv libmap_aliases/maps/star/base.v libmap_aliases/maps/star/item.sv libmap_aliases/maps/star/child/decoy.sv libmap_aliases/maps/no_dot/names.map libmap_aliases/maps/no_dot/pattern.v libmap_aliases/maps/no_dot/decoy.sv libmap_aliases/maps/with_dot/names.map libmap_aliases/maps/with_dot/pattern.v libmap_aliases/maps/with_dot/decoy.sv libmap_aliases/fallback.sv
*/
`timescale 1ns/1ns
module path_aliases_top;
  wire [7:0] sv, ssv, wv, wsv, bare, dotted, bare_decoy, dotted_decoy;
  wire [7:0] slash_decoy, star_decoy;
  slash_v u_sv(sv);
  slash_sv u_ssv(ssv);
  star_v u_wv(wv);
  star_sv u_wsv(wsv);
  slash_nested u_slash_decoy(slash_decoy);
  star_nested u_star_decoy(star_decoy);
  no_dot u_bare(bare);
  with_dot u_dotted(dotted);
  no_dot_decoy u_bare_decoy(bare_decoy);
  with_dot_decoy u_dotted_decoy(dotted_decoy);

  initial begin
    #1;
    $display("slash=%0d,%0d slash-star=%0d,%0d", sv, ssv, wv, wsv);
    $display("nested slash=%0d slash-star=%0d", slash_decoy, star_decoy);
    $display("bare=%0d,%0d dot-slash=%0d,%0d", bare, bare_decoy, dotted, dotted_decoy);
  end
endmodule

config path_aliases_config;
  design work.path_aliases_top;
  instance path_aliases_top.u_sv use slashLib.slash_v;
  instance path_aliases_top.u_ssv use slashLib.slash_sv;
  instance path_aliases_top.u_wv use starLib.star_v;
  instance path_aliases_top.u_wsv use starLib.star_sv;
  instance path_aliases_top.u_slash_decoy liblist slashLib fallbackLib;
  instance path_aliases_top.u_star_decoy liblist starLib fallbackLib;
  instance path_aliases_top.u_bare use bareLib.no_dot;
  instance path_aliases_top.u_dotted use dotLib.with_dot;
  instance path_aliases_top.u_bare_decoy liblist bareLib fallbackLib;
  instance path_aliases_top.u_dotted_decoy liblist dotLib fallbackLib;
endconfig
