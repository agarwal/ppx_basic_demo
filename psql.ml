open Core.Std
open Asttypes
open Parsetree
open Longident
open Ast_helper
open Ast_convenience

type t = [`Int32 | `Text | `Timestamptz | `Interval | `Uuid]

let t_of_ocaml_type (t:core_type) : t =
  match t with
  | [%type: int32] -> `Int32
  | [%type: string] -> `Text
  | [%type: Time.t] -> `Timestamptz
  | [%type: Time.Span.t] -> `Interval
  | [%type: Uuid.t] -> `Uuid
  | _ -> failwith "unsupported type"

let t_to_ocaml_type (t:t) : core_type =
  match t with
  | `Int32 -> [%type: int32]
  | `Text -> [%type: string]
  | `Timestamptz -> [%type: Time.t]
  | `Interval -> [%type: Time.Span.t]
  | `Uuid ->
    let x : core_type = [%type: Uuid.t] in
    [%type: [%t x]]
