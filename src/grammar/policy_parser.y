/**
 * @file        policy_parser.y
 *
 * @author      Tobias Anker <tobias.anker@kitsunemimi.moe>
 *
 * @copyright   Apache License Version 2.0
 *
 *      Copyright 2021 Tobias Anker
 *
 *      Licensed under the Apache License, Version 2.0 (the "License");
 *      you may not use this file except in compliance with the License.
 *      You may obtain a copy of the License at
 *
 *          http://www.apache.org/licenses/LICENSE-2.0
 *
 *      Unless required by applicable law or agreed to in writing, software
 *      distributed under the License is distributed on an "AS IS" BASIS,
 *      WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *      See the License for the specific language governing permissions and
 *      limitations under the License.
 */

%skeleton "lalr1.cc"

%defines
%require "3.0.4"

%define parser_class_name {PolicyParser}

%define api.prefix {policy}
%define api.namespace {Kitsunemimi::Hanami}
%define api.token.constructor
%define api.value.type variant
%define parse.assert

%code requires
{
#include <string>
#include <iostream>
#include <libKitsunemimiCommon/common_items/data_items.h>

using Kitsunemimi::DataItem;
using Kitsunemimi::DataArray;
using Kitsunemimi::DataValue;
using Kitsunemimi::DataMap;

namespace Kitsunemimi
{
namespace Hanami
{

class PolicyParserInterface;

}  // namespace Hanami
}  // namespace Kitsunemimi
}

// The parsing context.
%param { Kitsunemimi::Hanami::PolicyParserInterface& driver }

%locations

%code
{
#include <policy_parsing/policy_parser_interface.h>
# undef YY_DECL
# define YY_DECL \
    Kitsunemimi::Hanami::PolicyParser::symbol_type policylex (Kitsunemimi::Hanami::PolicyParserInterface& driver)
YY_DECL;
}

// Token
%define api.token.prefix {Policy_}
%token
    END  0  "end of file"
    DELIMITER  "---"
    MINUS  "-"
    COMMA  ","
    ASSIGN  ":"
;

%token <std::string> IDENTIFIER "identifier"

%type  <DataMap*> policy_content
%type  <DataMap*> policy_object_content
%type  <DataArray*> rule_list

%%
%start startpoint;


startpoint:
    policy_content
    {
        driver.setOutput($1);
    }

policy_content:
    policy_content "---" "identifier" policy_object_content
    {
        $1->insert($3, $4);
        $$ = $1;
    }
|
    "identifier" policy_object_content
    {
        $$ = new DataMap();
        $$->insert($1, $2);
    }

policy_object_content:
    policy_object_content "-" "identifier" ":" rule_list
    {
        $1->insert($3, $5);
        $$ = $1;
    }
|
    "-" "identifier" ":" rule_list
    {
        $$ = new DataMap();
        $$->insert($2, $4);
    }

rule_list:
    rule_list "," "identifier"
    {
        $1->append(new DataValue($3));
        $$ = $1;
    }
|
    "identifier"
    {
        $$ = new DataArray();
        $$->append(new DataValue($1));
    }

%%

void Kitsunemimi::Hanami::PolicyParser::error(const Kitsunemimi::Hanami::location& location,
                                              const std::string& message)
{
    driver.error(location, message);
}
