CLASS Stack {
    item: String;
    prev: Stack;

    init(i: String, p: Stack): Stack {
        {
            item <- i;
            prev <- p;
            self;
        }   
    };

    lookBellow(): Stack {
        prev
    };

    str(): String {
        item
    };

    setPrev(s:Stack):Object{
	    prev<-s
	};

    setItem(i:String):Object{
        item<-i
    };
};

class Main inherits IO {
    a2iobj: A2I <- new A2I;
    main(): Object {{
    let continue: Bool <- true,
            stack: Stack,
            tmpStack: Stack,
            input: String
        in
        {
            while continue loop
            {
                out_string(">");
                input<-in_string();
                if input ="x" then {continue<-false;}
			    else 
                {
                    if input ="e" then {stack<-evalstack(stack);}
                    else
                    {
                        if input ="d" then {printstack(stack);}
                        else
                        {
                            tmpStack<-stack;
                            stack<-(new Stack).init(input,tmpStack);
                        }
                        fi;
                    }
                    fi;
                }
                fi;
            }
            pool;
        };
            
        
    }};

    printstack(s: Stack): Object {{
        let temp:Stack <- s
        in
        while not isvoid temp 
		    loop 
				{
                    out_string(temp.str());
                    out_string("\n");
				    temp<-temp.lookBellow();
				}
			pool;
    }};

    swapstack(s: Stack): Stack {{
        
        let temp:Stack <- s.lookBellow(),
            temp2:Stack <- s.lookBellow().lookBellow()
        in
        {
            s.setPrev(new Stack);
            temp.setPrev(s);
            s.setPrev(temp2);
            temp;
        };
        
    }};

    sumstack(s: Stack): Stack {{
        
        let temp:Stack <- s.lookBellow(),
            x:String <- s.str(),
            y:String <- temp.str(),
            sum:Int
        in
        {
            sum <- a2iobj.a2i(x) + a2iobj.a2i(y);
            temp.setItem(a2iobj.i2a(sum));
            temp;
        };
        
    }};

    evalstack(s: Stack): Stack {{
        (*out_string("eval\n");*)
        if not isvoid s then 
        {
            let command:String <- s.str()
            in
            {
                if command ="s" then 
                {
                    (*out_string("trade\n");*)
                    s<-swapstack(s.lookBellow());
                }
                else 
                {
                    if command ="+" then 
                    {
                        (*out_string("plus\n");*)
                        s<-sumstack(s.lookBellow());
                    }
                    else
                    {
                        out_string("");
                    }
                    fi;
                }
                fi;
                s;
            };
        }
        else
        {
            s;
        }
        fi;
        
        
    }};
};
(* sakjdhasjkdh
sdkijhaiudhas
sjkdhuahds
sjkdhahsd
slkjadhak*)
