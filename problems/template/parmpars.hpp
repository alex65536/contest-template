// ParmPars.hpp version 0.2.1 (beta)
// This is useful to parse parameters, interpreting them as variables.

/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2017 Alexander Kernozhitsky
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#ifndef PARMPARS_HPP
#define PARMPARS_HPP

#include <map>
#include <string>
#include <sstream>
#include <exception>

class ParamParserException : public std::exception {
private:
	std::string description;
public:
	virtual const char* what() const throw() {
		return description.c_str();
	}
	
	ParamParserException(const std::string &description)
		: description(description) {
	}
};

namespace IntegerTools {
	bool isInt(const std::string &str) {
		if (str.size() == 0) {
			return false;
		}
		size_t beg = 0;
		if (str[0] == '+' || str[0] == '-') {
			if (str.size() == 1) {
				return false;
			}
			beg = 1;
		}
		for (size_t i = beg; i < str.size(); i++) {
			if (!('0' <= str[i] && str[i] <= '9')) {
				return false;
			}
		}
		return true;
	}
	
	int64_t strToInt(const std::string &str) {
		std::istringstream is(str);
		int64_t res;
		is >> res;
		return res;
	}
	
	std::string intToStr(int64_t val) {
		std::ostringstream os;
		os << val;
		return os.str();
	}
}

namespace StringTools {
	std::string unescape(std::string str) {
		if (
			str.size() == 0 ||
			!(str.front() == '\"' && str.back() == '\"')
		) {
			return str;
		}
		bool backslashed = false;
		std::string ans;
		ans.reserve(str.size());
		for (size_t i = 1; i + 1 < str.size(); i++) {
			if (backslashed) {
				switch (str[i]) {
					case '\'' : {
						ans += '\'';
					} break;
					case '\"' : {
						ans += '\"';
					} break;
					case '?' : {
						ans += '\?';
					} break;
					case '\\' : { 
						ans += '\\';
					} break;
					case 'a' : {
						ans += '\a';
					} break;
					case 'b' : {
						ans += '\b';
					} break;
					case 'f' : {
						ans += '\f';
					} break;
					case 'n' : {
						ans += '\n';
					} break;
					case 'r' : {
						ans += '\r';
					} break;
					case 't' : {
						ans += '\t';
					} break;
					case 'v' : {
						ans += '\v';
					} break;
					default: {
						ans += '\\';
						ans += str[i];
					}
				}
				backslashed = false;
			} else if (str[i] == '\\') {
				backslashed = true;
			} else {
				ans += str[i];
			}
		}
		if (backslashed) {
			ans += '\\';
		}
		return ans;
	}
}

class ParamParser {
private:
	bool initialized;
	std::map<std::string, std::string> consts;
	std::map<std::string, std::string> params;
	
	std::string getValue(const std::string &key, const std::string &defaultValue) {
		if (!params.count(key)) {
			return defaultValue;
		}
		std::string value = params[key];
		if (consts.count(value)) {
			value = consts[value];
		}
		return value;
	}
	
	void checkInternalState() {
		if (!initialized) {
			throw ParamParserException("This object is not initialized!");
		}
	}
public:
	std::string stringValue(const std::string &key, const std::string &defaultValue = "") {
		checkInternalState();
		std::string value = getValue(key, defaultValue);
		return StringTools::unescape(value);
	}
	
	int64_t intValue(const std::string &key, int64_t defaultValue = 0) {
		checkInternalState();
		std::string value = getValue(key, IntegerTools::intToStr(defaultValue));
		if (!IntegerTools::isInt(value)) {
			throw ParamParserException("Param \"" + key + "\" which value is \"" + value + "\" is not an integer!");
		}
		return IntegerTools::strToInt(value);
	}
	
	void defineConst(const std::string &key, const std::string &value) {
		checkInternalState();
		if (consts.count(key)) {
			throw ParamParserException("Constant named \"" + key + "\" already exists!");
		}
		consts[key] = value;
	}
	
	void defineConst(const std::string &key, int64_t value) {
		checkInternalState();
		defineConst(key, IntegerTools::intToStr(value));
	}
	
	ParamParser(int argc, char *argv[])
		: initialized(true) {
		for (int i = 1; i < argc; i++) {
			std::string arg = argv[i]; 
			size_t delimPos = arg.find("=");
			if (delimPos == std::string::npos) {
				continue;
			}
			std::string key = arg.substr(0, delimPos);
			std::string value = arg.substr(delimPos + 1);
			params[key] = value;
		}
	}
	
	ParamParser()
		: initialized(false) {
	}
};

ParamParser parser;

void initParamParser(int argc, char **argv) {
	parser = ParamParser(argc, argv);
}

#define DECLARE_INT(name) int64_t name = parser.intValue(#name);
#define DECLARE_INT_D(name, def) int64_t name = parser.intValue(#name, def);

#define DECLARE_STR(name) std::string name = parser.stringValue(#name);
#define DECLARE_STR_D(name, def) std::string name = parser.stringValue(#name, def);

#endif
