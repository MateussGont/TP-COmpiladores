/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */
%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

/*
 *  Add Your own definitions here
 */
int begin_full_comment = 0;

%}

/*
 * Define names for regular expressions here.
 */

DIGIT       [0-9]
MAXLETTER   [A-Z]
MINLETTER   [a-z]
LETTER      ({MINLETTER}|{MAXLETTER})
TYPEID      {MAXLETTER}({LETTER}|{DIGIT}|_)*
OBJECTID    {MINLETTER}({LETTER}|{DIGIT}|_)*
INVALID		  "`"|"!"|"#"|"$"|"%"|"^"|"&"|"|"|[\\]|">"|"?"|"["|"]"|"'"

%x COMMENT STRING ERROR_STRING
%%

 /*
  *  Restricted  chars
  */

"."   {return '.';}
"@"   {return '@';}
"~"   {return '~';}


"*"   {return '*';}
"/"   {return '/';}
"+"   {return '+';}
"-"   {return '-';}
"<="  {return LE;}
"<"   {return'<';}
"="   {return'=';}


"<-"  {return ASSIGN;}
"=>"  {return DARROW;}

":"   {return ':';}
";"   {return ';';}
"{"   {return '{';}
"}"   {return '}';}
"("   {return '(';}
")"   {return ')';}
","   {return ',';}

 /*
  * CEHCK !!!!!!!!!!!!!!!!!!!!!!!!!
  */

{INVALID} {
  cool_yylval.error_msg = yytext;
  return ERROR;
}



 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */


"self"                            { cool_yylval.symbol = idtable.add_string(yytext); return OBJECTID; }
"SELF_TYPE"                       { cool_yylval.symbol = idtable.add_string(yytext); return TYPEID; }
[cC][lL][aA][sS][sS]              { return CLASS; }
[eE][lL][sS][eE]                  { return ELSE; }
f[aA][lL][sS][eE]                 { cool_yylval.boolean = false;  return BOOL_CONST; }
[fF][iI]                          {  return FI; }
[iI][fF]                          {  return IF; }
[iI][nN]                          {  return IN; }
[iI][nN][hH][eE][rR][iI][tT][sS]  { return INHERITS; }
[iI][sS][vV][oO][iI][dD]          {  return ISVOID; }
[lL][eE][tT]                      {  return LET; }
[lL][oO][oO][pP]                  {  return LOOP; }
[pP][oO][oO][lL]                  { return POOL; }
[tT][hH][eE][nN]                  { return THEN; }
[wW][hH][iI][lL][eE]              {  return WHILE; }
[cC][aA][sS][eE]                  {  return ESAC; }
[eE][sS][aA][cC]                  {  return ESAC; }
[nN][eE][wW]                      {  return NEW; }
[oO][fF]                          { return OF; }
[nN][oO][tT]                      {return NOT; }
t[rR][uU][eE]                     { cool_yylval.boolean = true;  return BOOL_CONST; }

 /*
  *  The multiple-character operators.
  */

{OBJECTID}  { cool_yylval.symbol = idtable.add_string(yytext); return OBJECTID; }

{TYPEID}    { cool_yylval.symbol = idtable.add_string(yytext); return TYPEID; }

{DIGIT}+	  { cool_yylval.symbol = inttable.add_string(yytext); return INT_CONST; }



 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */
\"                  {
                        string_buf_ptr = string_buf;
                        BEGIN(STRING);
                    }
<STRING>{
    \"              {
                        *string_buf_ptr = '\0';
                        BEGIN(INITIAL);
                        cool_yylval.symbol = stringtable.add_string(string_buf);
                        return STR_CONST;
                    }
    \n              {
                        ++curr_lineno;
                        BEGIN(INITIAL);
                        cool_yylval.error_msg = "Unterminated string constant";
                        return ERROR;
                    }
    [^\\\n\0\"]+    {
                        if (string_buf_ptr + yyleng >
                                &string_buf[MAX_STR_CONST - 1]) {
                            BEGIN(ERROR_STRING);
                            cool_yylval.error_msg = "String constant too long";
                            return ERROR;
                        }
                        strcpy(string_buf_ptr, yytext);
                        string_buf_ptr += yyleng;
                    }
    \\?\0           {
                        BEGIN(ERROR_STRING);
                        cool_yylval.error_msg = "String contains null character";
                        return ERROR;
                    }
    "\\n"           *string_buf_ptr++ = '\n';

    "\\t"           *string_buf_ptr++ = '\t';

    "\\b"           *string_buf_ptr++ = '\b';

    "\\f"           *string_buf_ptr++ = '\f';

    "\\"[^\0]	    *string_buf_ptr++ = yytext[1];

    .               *string_buf_ptr++ = *yytext;
    \\\n            {
                        ++curr_lineno;
                        *string_buf_ptr++ = '\n';
                    }
    <<EOF>>         {
                        BEGIN(INITIAL);
                        cool_yylval.error_msg = "EOF in string constant";
                        return ERROR;
                    }
    (.)             {
                      cool_yylval.error_msg = yytext;
                      return ERROR;
                    }
}
<ERROR_STRING>{
    \"          BEGIN(INITIAL);
    \n          {
                    ++curr_lineno;
                    BEGIN(INITIAL);
                }
    \\.         ;
    [^\\\n\"]+  ;
}

 /*
  *  Comments
  */

(--[^\n]+)       ;
"*)"             {
                    cool_yylval.error_msg = "Unmatched *)";
                    return ERROR;
                  }

"(*"            { 
                  ++begin_full_comment;
                  BEGIN(COMMENT);
                }
<COMMENT>{
      "(*"              {
                          BEGIN(COMMENT);
                          ++begin_full_comment;
                        }
      "*)"              {
                          if (--begin_full_comment < 1)
                            {
                              BEGIN(INITIAL);
                            }
                        }
      \\.               ;
      [^(*\\\n]*        ;
      "("+[^(*\\\n]*    ; 
      "*"+[^)*\\\n]*    ;
      \n                ++curr_lineno;     
      <<EOF>>   {
                  BEGIN(INITIAL);
                  cool_yylval.error_msg = "EOF in comment";
                  return ERROR;
                }

}

 /*
  *  Remove whitespace and count line
  */

[\t\v\f\r ]+    ;
\n+             curr_lineno += yyleng;

%%
