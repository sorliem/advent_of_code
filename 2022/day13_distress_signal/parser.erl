-module(parser).

-export([
    evaluate_expression/1
]).

-spec evaluate_expression(string) -> any().
evaluate_expression(Expression) ->
    {ok, Tokens, _} = erl_scan:string(Expression),    % scan the code into tokens
    io:format("tokens = ~p\n", [Tokens]),
    {ok, Parsed} = erl_parse:parse_exprs(Tokens),     % parse the tokens into an abstract form
    io:format("parsed = ~p\n", [Parsed]),
    {value, Result, _} = erl_eval:exprs(Parsed, []),  % evaluate the expression, return the value
    Result.

