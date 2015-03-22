PACKAGES=core,compiler-libs.common,ppx_tools.metaquot
FLAGS=-thread -safe-string -short-paths -package $(PACKAGES)

all: lib.ml

myppx_ppx: myppx_ppx.ml
	ocamlfind ocamlopt $(FLAGS) -linkpkg $< -o myppx_ppx

psql.cmx: psql.ml
	ocamlfind ocamlopt $(FLAGS) -c $<

lib.ml: lib.ml.in myppx_ppx psql.cmx
	ocamlfind ocamlopt $(FLAGS) -c -dsource -ppx ./myppx_ppx -impl $< 2>| $@

.PHONY: clean
clean:
	rm -rf *.{cmi,cmx,o} myppx_ppx lib.ml
