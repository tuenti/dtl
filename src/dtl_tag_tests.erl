%% Copyright (c) 2013- Thomas Allen <thomas@oinksoft.com>
%%
%% Permission is hereby granted, free of charge, to any person obtaining
%% a copy of this software and associated documentation files (the
%% "Software"), to deal in the Software without restriction, including
%% without limitation the rights to use, copy, modify, merge, publish,
%% distribute, sublicense, and/or sell copies of the Software, and to
%% permit persons to whom the Software is furnished to do so, subject to
%% the following conditions:
%%
%% The above copyright notice and this permission notice shall be
%% included in all copies or substantial portions of the Software.
%%
%% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
%% EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
%% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
%% NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
%% BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
%% ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
%% CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
%% SOFTWARE.

%% @doc Test template tag mechanisms.
-module(dtl_tag_tests).

-behaviour(dtl_library).

-export([registered_filters/0,
         registered_tags/0]).

%% Tags
-export([regular/2, render_regular/2,
         simple/2,
         simple_list/2,
         simple_named/2,
         show_o/2]).

-include("test.hrl").
-include_lib("eunit/include/eunit.hrl").

registered_filters() -> [].
registered_tags() -> [regular,
                      simple,
                      simple_list,
                      simple_named,
                      {{dtl_tag, inclusion_tag, "included.html"},
                       show_o}].

regular_custom_tags_test() ->
    ?COMPARE_TEMPLATES([
        {Out, <<"{% load dtl_tag_tests %}", In/binary>>} ||
            {Out, In} <- [{<<"<div>\n\nTest\n\n</div>">>,
                           <<"<div>\n\n{% regular \"Stuff\" %}\n\n</div>">>}]
    ], dtl_context:new()).

simple_tags_test_() ->
    ?COMPARE_TEMPLATES([
        {Out, <<"{% load dtl_tag_tests %}", In/binary>>} ||
            {Out, In} <- [{<<"Simple">>, <<"{% simple %}">>},
                          {<<"List">>, <<"{% simple_list %}">>},
                          {<<"Named `simple_named'">>,
                           <<"{% simple_named %}">>}]
    ], dtl_context:new()).

inclusion_tag_test_() ->
    ?COMPARE_TEMPLATES([
        {Out, <<"{% load dtl_tag_tests %}", In/binary>>} ||
            {Out, In} <- [{<<"O!\n">>, <<"{% show_o %}">>}]
    ], dtl_context:new()).

%%
%% Tags
%%

regular(Parser, _Token) ->
    Node = dtl_node:new("regular", {?MODULE, render_regular}),
    {ok, Node, Parser}.

render_regular(_Node, _Ctx) ->
    <<"Test">>.

simple(Parser, _Token) ->
    {ok, <<"Simple">>, Parser}.

simple_list(Parser, _Token) ->
    {ok, "List", Parser}.

simple_named(Parser, _Token) ->
    {ok, dtl_node:new("simple_named", fun (Node, _Ctx) ->
        Name = list_to_binary(dtl_node:name(Node)),
        <<"Named `", Name/binary, "'">>
     end), Parser}.

show_o([], []) ->
    [{o, <<"O!">>}].
