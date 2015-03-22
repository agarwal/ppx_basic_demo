open Core.Std
open Asttypes
open Parsetree

let error msg =
  Or_error.error_string msg
  |> fun x -> Or_error.tag x "[@@myppx]"
  |> ok_exn

let structure_items_of_type_declaration (t:type_declaration) : structure_item list =
  if t.ptype_params <> [] then
    error "type parameters not allowed"
  else if t.ptype_cstrs <> [] then
    error "type constraints not allowed"
  else match t.ptype_kind with
  | Ptype_abstract
  | Ptype_variant _
  | Ptype_open
    -> error "only record types allowed"
  | Ptype_record label_decs -> [
    [%stri
     let x = 42
    ]
  ]

let structure_items_of_item mapper (x : structure_item) : structure_item list =
  let x = mapper.Ast_mapper.structure_item mapper x in
  match x.pstr_desc with
  | Pstr_type (t::[]) -> (
    match Ast_convenience.find_attr "myppx" t.ptype_attributes with
    | None -> [x]
    | Some (PPat _) | Some (PTyp _) | Some (PStr (_::_)) ->
      error "expected empty payload"
    | Some (PStr []) ->
      let x = {x with pstr_desc = (Pstr_type [t])} in
      x::(structure_items_of_type_declaration t)
  )
  | _ -> [x]
;;

let structure_mapper mapper structure =
  List.map structure ~f:(structure_items_of_item mapper)
  |> List.concat

let mapper = Ast_mapper.{default_mapper with
  structure = structure_mapper;
}

let () = Ast_mapper.run_main(fun _argv -> mapper)
