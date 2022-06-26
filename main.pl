
	run :- 
		write('\e[H\e[2J'),
		write("Welcome!"),nl,
		repeat,
		write("> Enter load, consult or quit"),nl,
		write("> "),
		read(Command),
		do(Command),
		Command = quit.
		
	do(load) :- 
		reconsult('D:/KNTU/Term6/AI/project/AI-1.0/knowledgebase.pl'),
		load_rules,
		write("> Successfully loaded"),nl,!.
	do(consult) :- solve,!.
	do(quit) :- write("Goodbye"),nl,!.
	do(X) :- 
		write(X), 
		write(" is not a legal command, try again."),nl.
	
	solve :-
		retractall(attr_value(_,_)),
		attributes(As),
		find_disease(As,1),
		disease(Disease),
		write("Disease is "), write(Disease),nl,!.
	solve :- write("No answers found"),nl.
	
	find_disease(Attrs,Index) :-
		length(Attrs,X),
		L1 is Index - 1,
		X = L1,!.
	find_disease(Attrs,Index) :-
		not(disease(_)),
		get(Attrs,Index,A),
		not(attr_value(A,_)),
		values(A,Vs),
		menuask(A,Vs),
		Index1 is Index + 1,
		find_disease(Attrs,Index1),!.
	find_disease(Attrs,Index) :-
		not(disease(_)),
		get(Attrs,Index,A),
		attr_value(A,_),
		Index1 is Index + 1,
		find_disease(Attrs,Index1).
	find_disease(_,_).
		
	menuask(Attr,Menulist) :-
		write('What is the value for '),
		write(Attr),write('?'),nl,
		write(Menulist),nl,
		read(V),
		check_val(V,Attr,Menulist),
		asserta(attr_value(Attr,V)).
		
	check_val(X,_,Menulist) :- member(X, Menulist), !.
	check_val(X,Attr,Menulist) :-
		write(X),write(' is not a legal value, try again.'),nl,
		menuask(Attr,Menulist).
		
		