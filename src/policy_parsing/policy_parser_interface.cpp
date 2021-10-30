/**
 * @file        policy_parser_interface.cpp
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

#include <policy_parsing/policy_parser_interface.h>
#include <policy_parser.h>

#include <libKitsunemimiCommon/common_methods/string_methods.h>

# define YY_DECL \
    Kitsunemimi::Hanami::PolicyParser::symbol_type policylex (Kitsunemimi::Hanami::PolicyParserInterface& driver)
YY_DECL;

namespace Kitsunemimi
{
namespace Hanami
{

Kitsunemimi::Hanami::PolicyParserInterface* PolicyParserInterface::m_instance = nullptr;

using Kitsunemimi::splitStringByDelimiter;

/**
 * @brief The class is the interface for the bison-generated parser.
 *        It starts the parsing-process and store the returned values.
 *
 * @param traceParsing If set to true, the scanner prints all triggered rules.
 *                     It is only for better debugging.
 */
PolicyParserInterface::PolicyParserInterface(const bool traceParsing)
{
    m_traceParsing = traceParsing;
}

/**
 * @brief static methode to get instance of the interface
 *
 * @return pointer to the static instance
 */
PolicyParserInterface*
PolicyParserInterface::getInstance()
{
    if(m_instance == nullptr) {
        m_instance = new PolicyParserInterface();
    }

    return m_instance;
}

/**
 * @brief destructor
 */
PolicyParserInterface::~PolicyParserInterface()
{
}

/**
 * @brief parse string
 *
 * @param inputString string which should be parsed
 * @param reference for error-message
 *
 * @return resulting object
 */
bool
PolicyParserInterface::parse(std::map<std::string, std::map<std::string, PolicyEntry>>* result,
                             const std::string &inputString,
                             std::string &errorMessage)
{
    m_lock.lock();

    // init global values
    m_inputString = inputString;
    m_errorMessage = "";
    m_result = result;

    // run parser-code
    this->scan_begin(inputString);
    Kitsunemimi::Hanami::PolicyParser parser(*this);
    int res = parser.parse();
    this->scan_end();

    // handle negative result
    if(res != 0)
    {
        errorMessage = m_errorMessage;
        m_lock.unlock();
        return false;
    }

    m_lock.unlock();

    return true;
}

/**
 * @brief remove quotes at the beginning and end of a string
 *
 * @param input input-string
 *
 * @return cleared string
 */
const std::string
PolicyParserInterface::removeQuotes(const std::string &input)
{
    // precheck
    if(input.length() == 0) {
        return input;
    }

    // clear
    if(input[0] == '\"'
            && input[input.length()-1] == '\"')
    {
        std::string result = "";
        for(uint32_t i = 1; i < input.length()-1; i++) {
            result += input[i];
        }

        return result;
    }

    return input;
}

/**
 * @brief Is called from the parser in case of an error
 *
 * @param location location-object of the bison-parser,
 *                 which contains the informations of the location
 *                 of the syntax-error in the parsed string
 * @param message error-specific message from the parser
 */
void
PolicyParserInterface::error(const Kitsunemimi::Hanami::location& location,
                             const std::string& message)
{
    // get the broken part of the parsed string
    const uint32_t errorStart = location.begin.column;
    const uint32_t errorLength = location.end.column - location.begin.column;
    const uint32_t linenumber = location.begin.line;

    std::vector<std::string> splittedContent;
    splitStringByDelimiter(splittedContent, m_inputString, '\n');

    // -1 because the number starts for user-readability at 1 instead of 0
    const std::string errorStringPart = splittedContent[linenumber - 1].substr(errorStart - 1,
                                                                               errorLength);

    // build error-message
    m_errorMessage =  "ERROR while parsing policy-formated string \n";
    m_errorMessage += "parser-message: " + message + " \n";
    m_errorMessage += "line-number: " + std::to_string(linenumber) + " \n";
    m_errorMessage += "position in line: " + std::to_string(location.begin.column) + " \n";
    m_errorMessage += "broken part in string: \"" + errorStringPart + "\" \n";
}

}  // namespace Policy
}  // namespace Kitsunemimi
