/**
 * @file        policy.cpp
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

#include <libKitsunemimiHanamiPolicies/policy.h>

#include <libKitsunemimiCommon/common_items/data_items.h>
#include <policy_parsing/policy_parser_interface.h>

namespace Kitsunemimi
{
namespace Hanami
{

/**
 * @brief Policy::Policy
 */
Policy::Policy() {}

/**
 * @brief Policy::~Policy
 */
Policy::~Policy() {}

/**
 * @brief parse policy-file content
 *
 * @param input input-string with policy-definition to parse
 * @param errorMessage reference for the output of the error-message
 *
 * @return true, if parsing was successfull, else false
 */
bool
Policy::parse(const std::string &input,
              std::string &errorMessage)
{
    if(input.size() == 0) {
        return false;
    }

    PolicyParserInterface* parser = PolicyParserInterface::getInstance();
    return parser->parse(&m_policyRules, input, errorMessage);
}

/**
 * @brief check if request is allowed by policy
 *
 * @param component name of the requested component
 * @param endpoint requested endpoint of the component
 * @param type http-request-type
 * @param group group which has to be checked
 *
 * @return true, if check was successfully, else false
 */
bool
Policy::checkUserAgainstPolicy(const std::string &component,
                               const std::string &endpoint,
                               const HttpRequestType type,
                               const std::string &group)
{
    std::map<std::string, std::map<std::string, PolicyEntry>>::const_iterator component_it;
    component_it = m_policyRules.find(component);

    if(component_it != m_policyRules.end())
    {
        std::map<std::string, PolicyEntry>::const_iterator endpoint_it;
        endpoint_it = component_it->second.find(endpoint);

        if(endpoint_it != component_it->second.end()) {
            return checkEntry(endpoint_it->second,  type, group);
        }
    }

    return false;
}

/**
 * @brief Policy::checkEntry
 * @param entry
 * @param type
 * @param group
 * @return
 */
bool
Policy::checkEntry(const PolicyEntry &entry,
                   const HttpRequestType type,
                   const std::string &group)
{
    switch(type)
    {
        case GET_TYPE:
            return checkRuleList(entry.getRules, group);
            break;
        case POST_TYPE:
            return checkRuleList(entry.postRules, group);
            break;
        case PUT_TYPE:
            return checkRuleList(entry.putRules, group);
            break;
        case DELETE_TYPE:
            return checkRuleList(entry.deleteRules, group);
            break;
        case HEAD_TYPE:
            break;
        case UNKNOWN_HTTP_TYPE:
            break;
    }

    return false;
}

/**
 * @brief Policy::checkRuleList
 * @param rules
 * @param group
 * @return
 */
bool
Policy::checkRuleList(const std::vector<std::string> &rules,
                      const std::string &group)
{
    for(const std::string& rule : rules)
    {
        if(rule == group) {
            return true;
        }
    }

    return false;
}

}
}
