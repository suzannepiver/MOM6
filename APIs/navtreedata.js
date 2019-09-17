/*
@licstart  The following is the entire license notice for the
JavaScript code in this file.

Copyright (C) 1997-2019 by Dimitri van Heesch

This program is free software; you can redistribute it and/or modify
it under the terms of version 2 of the GNU General Public License as published by
the Free Software Foundation

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

@licend  The above is the entire license notice
for the JavaScript code in this file
*/
var NAVTREE =
[
  [ "MOM6", "index.html", [
    [ "MOM6 APIs", "index.html", null ],
    [ "Diagnostics", "Diagnostics.html", [
      [ "The \"diag_table\"", "Diagnostics.html#diag_table", [
        [ "Title section", "Diagnostics.html#diag_table_title", null ],
        [ "File section", "Diagnostics.html#diag_table_files", null ],
        [ "Field section", "Diagnostics.html#diag_table_fields", null ],
        [ "Example", "Diagnostics.html#diag_table_example", null ]
      ] ],
      [ "Native diagnostics", "Diagnostics.html#native_diagnostics", null ],
      [ "Vertically remapped diagnostics", "Diagnostics.html#remapped_diagnostics", [
        [ "Diagnostic vertical coordinates", "Diagnostics.html#diag_table_vertical_coords", null ]
      ] ],
      [ "APIs for diagnostics", "Diagnostics.html#diagnostics_implementation", [
        [ "Artifacts of posting frequency for diagnostics", "Diagnostics.html#diag_post_frequency", null ]
      ] ]
    ] ],
    [ "Horizontal indexing and memory", "Horizontal_indexing.html", [
      [ "Loops and staggered variables", "Horizontal_indexing.html#Staggering", [
        [ "Soft convention for loop variables", "Horizontal_indexing.html#Soft_convention", null ]
      ] ],
      [ "Declaration of variables", "Horizontal_indexing.html#Memory", null ],
      [ "Calculating a global index", "Horizontal_indexing.html#Global_index", null ]
    ] ],
    [ "Run-time Parameter System", "Runtime_parameter_system.html", [
      [ "Getting parameters into MOM6", "Runtime_parameter_system.html#reading_params", [
        [ "Namelist parameters (<tt>input.nml</tt>)", "Runtime_parameter_system.html#mom6_namelist", null ],
        [ "Other MOM6-relevant FMS parameters", "Runtime_parameter_system.html#fms_params", null ],
        [ "MOM6 parameter file syntax", "Runtime_parameter_system.html#param_syntax", null ],
        [ "Logging of parameters", "Runtime_parameter_system.html#param_logging", null ],
        [ "Error checking of parameters and parameter files", "Runtime_parameter_system.html#param_checking", null ]
      ] ]
    ] ],
    [ "Tracer Advection", "Advection.html", [
      [ "Flux advection", "Advection.html#Flux_advection", null ],
      [ "Tracer reconstruction", "Advection.html#Tracer_reconstruction", null ]
    ] ],
    [ "Todo List", "todo.html", null ],
    [ "F90 modules", "annotated.html", [
      [ "F90 module list", "annotated.html", "annotated_dup" ],
      [ "Module functions and variables", "functions.html", [
        [ "All", "functions.html", "functions_dup" ],
        [ "Functions/Subroutines", "functions_func.html", "functions_func" ],
        [ "Variables", "functions_vars.html", "functions_vars" ]
      ] ]
    ] ],
    [ "Source files", "files.html", [
      [ "File list", "files.html", "files_dup" ],
      [ "Globals", "globals.html", [
        [ "All", "globals.html", null ],
        [ "Functions/Subroutines", "globals_func.html", null ],
        [ "Macros", "globals_defs.html", null ]
      ] ]
    ] ]
  ] ]
];

var NAVTREEINDEX =
[
"Advection.html",
"MOM__EOS_8F90.html#a5d8b3af2f7c594c5219d75228ac50dd9",
"MOM__EOS__Wright_8F90.html#a576d1ff13c93f4a3ffbd483d43a78ab7",
"MOM__coms_8F90.html#a7af397491bbb8f8e6e9a268492bebc33",
"MOM__diagnostics_8F90.html",
"MOM__forcing__type_8F90.html#a44ade8a584921047fcf960f4cdb9914c",
"MOM__memory__macros_8h.html#aaa460a40dc3a031a51f91dd370a6cd9b",
"MOM__remapping_8F90.html#a40ab417b859bc139c78739f29291641f",
"MOM__tidal__mixing_8F90.html#aa77238da241cd9c94f24a9bd8d3b2fe1",
"Runtime_parameter_system.html",
"interfacemidas__vertmap_1_1fill__boundaries.html#a7576f278e5bb61728717184d907d94b9",
"interfacemom__io_1_1file__exists.html#a5df813867c2eaf194bef25dd16c0fe7b",
"namespacemom__controlled__forcing.html",
"soliton__initialization_8F90.html",
"structmom_1_1mom__control__struct.html#a4ff33f6bd282d38f932ee28d3f304d38",
"structmom__barotropic_1_1barotropic__cs.html#ab9b69a111c34ac5ac4b24fba46654ddb",
"structmom__controlled__forcing_1_1ctrl__forcing__cs.html#abd92452fa904e717a2add1d178ca8598",
"structmom__diabatic__driver_1_1diabatic__cs.html#a96331d361bc5f775b9428d4acccdb6f3",
"structmom__diagnostics_1_1diagnostics__cs.html#a23e4f5f4fb48652807b7fffd80bdeebf",
"structmom__dyn__horgrid_1_1dyn__horgrid__type.html#ae27be0e53812a8f1bd1c8be17dbbd95e",
"structmom__entrain__diffusive_1_1entrain__diffusive__cs.html#a52e16663b95ee82411a1e7e784a3d229",
"structmom__grid_1_1ocean__grid__type.html#a0345ea2917d3ca5b5ebf4a42d0e89a8d",
"structmom__ice__shelf_1_1ice__shelf__cs.html#a5892a9b94b525d7317d9b498d0cece1f",
"structmom__lateral__mixing__coeffs_1_1varmix__cs.html#a387e24e508fa938f35cc50155e32cc0a",
"structmom__ocean__model__mct_1_1ocean__state__type.html#a9e9321673221d77d72d79b706a4e30a0",
"structmom__open__boundary_1_1file__obc__cs.html#a2deb9d7581c47efd279c7c4fece04c08",
"structmom__restart_1_1mom__restart__cs.html#a087150e928b37ef92c84e989e1d952fc",
"structmom__surface__forcing_1_1surface__forcing__cs.html#a5900d5ef6a3298655ac2915656b36c62",
"structmom__thickness__diffuse_1_1thickness__diffuse__cs.html#a87a42d89b1d2b361f6e82b4bf679cba8",
"structmom__unit__scaling_1_1unit__scale__type.html#a1a734d24b7a23915805fee4745c56302",
"structmom__wave__speed_1_1wave__speed__cs.html#a2c93a316aed8fe0dc700e109ac974a8d",
"time__utils_8F90.html#a9d670caa90ff003951050efb6ccddc99"
];

var SYNCONMSG = 'click to disable panel synchronisation';
var SYNCOFFMSG = 'click to enable panel synchronisation';