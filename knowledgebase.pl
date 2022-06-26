
	%predicates
	%attribute(fever).
	%attr_value_disease(fever,often,covid_19). 
	%attr_value(fever,sometimes).
	%disease(test).
	
	prepare :- 
		dynamic 
			attribute/1,attr_value/2,
			attr_value_disease/3,disease/1.
	
	load_rules :-
		prepare,
		%remove previous data
		retractall(attribute(_)),
		retractall(attr_value_disease(_,_,_)),
		retractall(disease(_)),
		retractall(attr_value(_,_)),
		%read data from file
		csv_read_file('D:/kntu/Term6/AI/project/AI-1.0/data.csv', Rows),
		maplist(rows_to_list, Rows, Table),
		get(Table,1,Diseases),
		add_attrs(Table,Diseases,2),
		attributes(A),
		write(A),nl,
		make_tree(1,[]).
	
	rows_to_list(Row,List) :- Row =.. [row|List].
	
	%get element of Array at Index
	get(Array,1,Value) :- Array = [X|_],Value = X,!.
	get(Array,Index,Value) :- 
		Index1 is Index - 1,
		Array = [_|X],
		get(X,Index1,Value).
		
	%add all attr_value_disease predicates from table
	add_attrs(Table,_,Index) :- 
		length(Table,X),
		X = Index,!.
	add_attrs(Table,Diseases,Index) :- 
		get(Table,Index,Row),
		Row = [Attr|Values],
		assertz(attribute(Attr)),
		add_attr_value(Diseases,Attr,Values,1),
		Index1 is Index + 1,
		add_attrs(Table,Diseases,Index1).
	
	%add all attr_value_disease predicates from row
	add_attr_value(_,_,Values,Index) :- 
		length(Values,X),
		L1 is Index - 1,
		X = L1,!.
	add_attr_value(Diseases,Attr,Values,Index) :- 
		get(Values,Index,V),
		L1 is Index + 1,
		get(Diseases,L1,D),
		assertz(attr_value_disease(Attr,V,D)),
		add_attr_value(Diseases,Attr,Values,L1).		
	
	%loop on all attributes to make tree
	make_tree(Attr_index,Path_in) :-
        attributes(As),
        get(As,Attr_index,A),
        %write(A),nl,
        values(A,Vs),
        %write(Vs),nl,
        make_branch(A,Vs,Attr_index,Path_in,1).
	
	%find all attributes added as a fact
	attributes(Attrs) :- findall(A,attribute(A),Attrs).
    
	%find all values for Attr
    values(Attr,Values) :- 
        findall(V,attr_value_disease(Attr,V,_),Vs),
        sort(Vs,Values).
	
	%loop on all values to make branch
	make_branch(_,Vs,_,_,Index) :- 
		length(Vs,X),
		L1 is Index - 1,
		X = L1,!.	
	make_branch(A,Vs,Attr_index,Path_in,Index) :- 
		get(Vs,Index,V),
		%write(V),nl,
		find_path(A,V,Attr_index,Path_in,_),
		%write("finished"),nl,
		Index1 is Index + 1,
		%write(A),nl,
		make_branch(A,Vs,Attr_index,Path_in,Index1).
	
	find_path(Attr,Value,Attr_index,Path_in,Path_out) :- 
		findall(A,(attr_value_disease(Attr,Value,A)),Ds),
		%write(Ds),nl,
		possible_diseases(Path_in,1,[],D),
		intersection(Ds,D,Inter),
		%write("disease "),write(Inter),nl,
		length(Inter,L),
        (L =:= 0 -> !;
		(L =:= 1 -> 
		%write("yes"),nl,
		append(Path_in,[[Attr,Value]],P),
		append(P,Inter,Path_out),
		write(Path_out),nl,
        add_rule(Path_out)
		;
		length(Path_in,L1),
        %write("not"),nl,
		%write(L1),nl,
		(L1 =:= 0 -> 
		Path_out = [[Attr,Value]]
		;
		append(Path_in,[[Attr,Value]],Path_out)),
		%write(Path_out),nl,
        Next_attr is Attr_index + 1,
        make_tree(Next_attr,Path_out))).
	
	possible_diseases(Path,Index,D_in,D_out) :- 
		length(Path,X),
		L1 is Index - 1,
		X = L1,
		(X =:= 0 -> 
		findall(D,attr_value_disease(_,_,D),D)
		;
		D = D_in),
		sort(D,D_out),!.
	possible_diseases(Path,Index,D_in,D_out) :- 
		get(Path,Index,Att_val),
		Att_val = [Attr,Value],
		findall(D,attr_value_disease(Attr,Value,D),D1),
		length(D_in,L),
		(L =:= 0 -> D2 = D1;
		intersection(D1,D_in,D2)),
		Index1 is Index + 1,
		possible_diseases(Path,Index1,D2,D_out).
	
	add_rule(Path) :-
		length(Path,L),
		get(Path,L,Disease),
		assertz((disease(Disease)) :- call_all(Path,1)).
		
	call_all(Path,Index) :- 
		length(Path,X),
		L1 is Index,
		X = L1,!.	
	call_all(Path,Index) :- 
		get(Path,Index,Att_val),
		Att_val = [Attr,Value],
		attr_value(Attr,Value),
		Index1 is Index + 1,
		call_all(Path,Index1).
