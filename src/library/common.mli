(*
 * This file is part of Bisect.
 * Copyright (C) 2008-2012 Xavier Clerc.
 *
 * Bisect is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * Bisect is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *)

(** This module provides type definitions, and functions used by the
    various parts of Bisect. *)


type point_definition = {
    offset : int; (** Point offset, relative to file beginning. *)
    identifier : int; (** Point identifier, unique in file. *)
  }
(** The type of point definitions, that is places of interest in the
    source code. *)

(** {6 Utility functions} *)

val try_finally : 'a -> ('a -> 'b) -> ('a -> unit) -> 'b
(** [try_finally x f h] implements the try/finally logic.
    [f] is the body of the try clause, while [h] is the finally handler.
    Errors raised by handler are silently ignored. *)

val try_in_channel : bool -> string -> (in_channel -> 'a) -> 'a
(** [try_in_channel bin filename f] is equivalent to [try_finally x f h]
    where:
    - [x] is an input channel for file [filename] (opened in binary mode
      iff [bin] is [true]);
    - [h] just closes the input channel.
    Raises an exception if any error occurs. *)

val try_out_channel : bool -> string -> (out_channel -> 'a) -> 'a
(** [try_out_channel bin filename f] is equivalent to [try_finally x f h]
    where:
    - [x] is an output channel for file [filename] (opened in binary mode
      iff [bin] is [true]);
    - [h] just closes the output channel.
    Raises an exception if any error occurs. *)


(** {6 I/O functions} *)

exception Invalid_file of string
(** Exception to be raised when a read file does not conform to the Bisect
    format. The parameter is the name of the incriminated file. *)

exception Unsupported_version of string
(** Exception to be raised when a read file has a format whose version is
    unsupported. The parameter is the name of the incriminated file. *)

exception Modified_file of string
(** Exception to be raised when the source file has been modified since
    instrumentation. The parameter is the name of the incriminated
    file. *)

val write_runtime_data :
  out_channel -> (string * (int array * string)) list -> unit
(** [write_runtime_data oc d] writes the runtime data [d] to the output
    channel [oc] using the Bisect file format. The runtime data list [d]
    encodes a map (through an association list) from files to arrays of
    integers (the value at index {i i} being the number of times point
    {i i} has been visited). The arrays are paired with point definition
    lists, giving the location of each point in the file.

    Raises [Sys_error] if an i/o error occurs. *)

val write_points : point_definition list -> string
(** [write_points pts] converts the point definitions [pts] to a string. The
    string is a binary byte sequence; it is not meant to be legible. *)

val read_runtime_data' : string -> (string * (int array * string)) list
(** [read_runtime_data f] reads the runtime data from file [f].

    Raises [Sys_error] if an i/o error occurs. May also raise
    [Invalid_file], [Unsupported_version], or [Modified_file]. *)

val read_points' : string -> point_definition list
(** [read_points s] reads point definitions from the string [s]. *)

val read_runtime_data : string -> (string * int array) list
  [@@ocaml.deprecated "read_runtime_data' will take the place of this function"]

val read_points : string -> point_definition list
  [@@ocaml.deprecated "read_points' will take the place of this function"]
