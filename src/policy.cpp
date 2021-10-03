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
Policy::~Policy()
{
    clear();
}

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
    PolicyParserInterface* parser = PolicyParserInterface::getInstance();

    // parse ini-template into a json-tree
    DataMap* result = nullptr;
    if(input.size() > 0) {
        result = parser->parse(input, errorMessage);
    } else {
        result = new DataMap();
    }

    // process a failure
    if(result == nullptr) {
        return false;
    }

    clear();

    m_policyRules = result;

    return true;
}

/**
 * @brief check if request is allowed by policy
 *
 * @param component name of the requested component
 * @param endpoint requested endpoint of the component
 * @param group group which has to be checked
 *
 * @return true, if check was successfully, else false
 */
bool
Policy::checkUserAgainstPolicy(const std::string &component,
                               const std::string &endpoint,
                               const std::string &group)
{
    DataItem* item = nullptr;

    // check component
    item = m_policyRules->get(component);
    if(item == nullptr) {
        return false;
    }

    // check endpoint within component
    item = item->get(endpoint);
    if(item == nullptr) {
        return false;
    }

    // check group
    std::vector<DataItem*>* userList = &item->toArray()->m_array;
    for(uint32_t i = 0; i < userList->size(); i++)
    {
        if(group == std::string(userList->at(i)->toValue()->m_content.stringValue)) {
            return true;
        }
    }

    return false;
}

/**
 * @brief clear data, which are hold by this object
 */
void
Policy::clear()
{
    if(m_policyRules != nullptr)
    {
        delete m_policyRules;
        m_policyRules = nullptr;
    }
}

}
}
