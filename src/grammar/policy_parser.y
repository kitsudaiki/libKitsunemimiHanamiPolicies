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
#include <map>
#include <vector>
#include <iostream>
#include <libKitsunemimiHanamiCommon/enums.h>

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
#include <libKitsunemimiHanamiPolicies/policy.h>

# undef YY_DECL
# define YY_DECL \
    Kitsunemimi::Hanami::PolicyParser::symbol_type policylex (Kitsunemimi::Hanami::PolicyParserInterface& driver)
YY_DECL;

std::map<std::string, Kitsunemimi::Hanami::PolicyEntry> tempPolicy;
Kitsunemimi::Hanami::PolicyEntry tempPolicyEntry;
std::vector<std::string> tempRules;
}

// Token
%define api.token.prefix {Policy_}
%token
    END  0  "end of file"
    BRAKET_OPEN  "["
    BRAKET_CLOSE "]"
    MINUS  "-"
    COMMA  ","
    ASSIGN  ":"
    GET  "GET"
    PUT  "PUT"
    POST  "POST"
    DELETE  "DELETE"
;

%token <std::string> IDENTIFIER "identifier"
%token <std::string> PATH "path"

%type  <HttpType> request_type
%type  <std::string> endpoint;

%%
%start policy_content;

policy_content:
    policy_content "[" "identifier" "]" component_policy_content
    {
        driver.m_result->insert(std::make_pair($3, tempPolicy));
    }
|
    "[" "identifier" "]" component_policy_content
    {
        driver.m_result->clear();
        driver.m_result->insert(std::make_pair($2, tempPolicy));
    }

component_policy_content:
    component_policy_content endpoint policy_entry
    {
        tempPolicy.insert(std::make_pair($2, tempPolicyEntry));
    }
|
    endpoint policy_entry
    {
        tempPolicy.clear();
        tempPolicy.insert(std::make_pair($1, tempPolicyEntry));
    }

policy_entry:
    policy_entry "-" request_type ":" rule_list
    {
        if($3 == HttpType::GET_TYPE) {
            tempPolicyEntry.getRules = tempRules;
        }
        if($3 == HttpType::POST_TYPE) {
            tempPolicyEntry.postRules = tempRules;
        }
        if($3 == HttpType::PUT_TYPE) {
            tempPolicyEntry.putRules = tempRules;
        }
        if($3 == HttpType::DELETE_TYPE) {
            tempPolicyEntry.deleteRules = tempRules;
        }
    }
|
    "-" request_type ":" rule_list
    {
        tempPolicyEntry.getRules.clear();
        tempPolicyEntry.postRules.clear();
        tempPolicyEntry.putRules.clear();
        tempPolicyEntry.deleteRules.clear();

        if($2 == HttpType::GET_TYPE) {
            tempPolicyEntry.getRules = tempRules;
        }
        if($2 == HttpType::POST_TYPE) {
            tempPolicyEntry.postRules = tempRules;
        }
        if($2 == HttpType::PUT_TYPE) {
            tempPolicyEntry.putRules = tempRules;
        }
        if($2 == HttpType::DELETE_TYPE) {
            tempPolicyEntry.deleteRules = tempRules;
        }
    }

rule_list:
    rule_list "," "identifier"
    {
        tempRules.push_back($3);
    }
|
    "identifier"
    {
        tempRules.clear();
        tempRules.push_back($1);
    }


endpoint:
    "path"
    {
        $$ = $1;
    }
|
    "identifier"
    {
        $$ = $1;
    }

request_type:
    "GET"
    {
        $$ = HttpType::GET_TYPE;
    }
|
    "POST"
    {
        $$ = HttpType::POST_TYPE;
    }
|
    "PUT"
    {
        $$ = HttpType::PUT_TYPE;
    }
|
    "DELETE"
    {
        $$ = HttpType::DELETE_TYPE;
    }

%%

void Kitsunemimi::Hanami::PolicyParser::error(const Kitsunemimi::Hanami::location& location,
                                              const std::string& message)
{
    driver.error(location, message);
}
